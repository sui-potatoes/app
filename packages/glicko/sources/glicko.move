// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Glicko rating on `std::uq64_64` fixed-point arithmetic.
///
/// Every player carries a `rating` and a `deviation` (RD). The deviation is the
/// uncertainty of the rating: newcomers start at `MAX_DEVIATION`, converge
/// towards `MIN_DEVIATION` as they play and drift back up while inactive. The
/// size of a single update is scaled by both players' deviations, so new
/// players converge fast while established ratings stay stable.
///
/// Pure library: no objects, no storage. Keep `Rating` values wherever the
/// application sees fit and call `compute` once after every game to get both
/// players' new ratings.
///
/// Square roots use a seeded Newton iteration instead of the bit-by-bit
/// `sqrt` of the integer modules: the seeds are always within a few tens of
/// percent of the result, so five steps reach fixed-point precision at a
/// fraction of the cost.
///
/// Reference: Glickman, M. E. "The Glicko system" (1995), with a rating period
/// of a single game and the inactivity constant `c` applied per day.
///
/// Traits:
/// - default
module glicko::glicko;

use std::uq64_64::{Self, UQ64_64};

// Fixed-point constants as raw `UQ64_64` values (scaled by `2^64`).

/// `1`.
const ONE_RAW: u128 = 18_446_744_073_709_551_616;
/// `1 / 2`.
const HALF_RAW: u128 = 9_223_372_036_854_775_808;
/// `q = ln(10) / 400`.
const Q_RAW: u128 = 106_187_994_795_999_673;
/// `q^2`.
const Q2_RAW: u128 = 611_267_234_680_495;
/// `3 * q^2 / pi^2`.
const G_COEF_RAW: u128 = 185_802_959_218_819;
/// `5 / 4`: Newton seed for `sqrt(1 + 3 * q^2 * RD^2 / pi^2)`, which lies in
/// `[1.0045, 1.4946]` for every valid deviation.
const G_SEED_RAW: u128 = 23_058_430_092_136_939_520;
/// Newton steps per square root. Quadratic convergence from the seeds used here
/// leaves an error far below `2^-64` after five.
const SQRT_STEPS: u64 = 5;

/// Denominator of the `E_TABLE` entries.
const E6: u128 = 1_000_000;
/// Distance between `E_TABLE` entries, in hundredths of a rating point.
const E_STEP_E2: u128 = 2_500;
// prettier-ignore
/// `E(d) = 1 / (1 + 10^(-d / 400))` for `d = 0, 25, 50, ..., 2000`, in
/// millionths. Values past the end of the table are clamped to the last entry.
const E_TABLE: vector<u32> = vector[
    500000, 535916, 571463, 606288, 640065, 672510, 703385, 732507, 759747,
    785027, 808318, 829633, 849020, 866557, 882338, 896477, 909091, 920305,
    930242, 939022, 946760, 953565, 959537, 964769, 969347, 973346, 976836,
    979878, 982528, 984834, 986840, 988584, 990099, 991415, 992557, 993548,
    994408, 995154, 995801, 996362, 996848, 997269, 997634, 997951, 998225,
    998462, 998668, 998847, 999001, 999135, 999251, 999351, 999438, 999513,
    999578, 999635, 999684, 999726, 999763, 999795, 999822, 999846, 999867,
    999885, 999900, 999913, 999925, 999935, 999944, 999951, 999958, 999963,
    999968, 999973, 999976, 999979, 999982, 999985, 999987, 999988, 999990,
];

/// Rating of a player who has never played.
const DEFAULT_RATING: u64 = 1500;
/// Deviation of a player who has never played; also the upper bound.
const MAX_DEVIATION: u64 = 350;
/// Lower bound of the deviation, keeps established ratings movable.
const MIN_DEVIATION: u64 = 30;
/// `c^2`: growth of `deviation^2` per day of inactivity. A fully converged
/// player returns to `MAX_DEVIATION` after roughly 100 days without games.
const C2_PER_DAY: u64 = 1_200;
const MS_PER_DAY: u64 = 86_400_000;

/// Deviation passed to `new` is outside `[MIN_DEVIATION, MAX_DEVIATION]`.
const EInvalidDeviation: u64 = 0;

/// Rating of a single player.
public struct Rating has copy, drop, store {
    rating: u64,
    deviation: u64,
    /// Number of rated games played.
    games: u64,
    /// Timestamp of the last rated game, used for inactivity growth.
    last_played_ms: u64,
}

/// Result of a game from the perspective of the first player passed to
/// `compute`.
public enum Score has copy, drop {
    Win,
    Draw,
    Loss,
}

/// Rating of a player who has never played.
public fun default(): Rating {
    Rating { rating: DEFAULT_RATING, deviation: MAX_DEVIATION, games: 0, last_played_ms: 0 }
}

/// Create a `Rating` with explicit values and no history.
public fun new(rating: u64, deviation: u64): Rating {
    assert!(deviation >= MIN_DEVIATION && deviation <= MAX_DEVIATION, EInvalidDeviation);
    Rating { rating, deviation, games: 0, last_played_ms: 0 }
}

/// Score of the winning side.
public fun win(): Score { Score::Win }

/// Score of either side in a draw.
public fun draw(): Score { Score::Draw }

/// Score of the losing side.
public fun loss(): Score { Score::Loss }

// === Reads ===

/// Rating in points.
public fun rating(r: &Rating): u64 { r.rating }

/// Rating deviation as stored, without inactivity growth. See `current_deviation`.
public fun deviation(r: &Rating): u64 { r.deviation }

/// Number of rated games played.
public fun games(r: &Rating): u64 { r.games }

/// Timestamp of the last rated game, `0` if none.
public fun last_played_ms(r: &Rating): u64 { r.last_played_ms }

/// Deviation adjusted for the time passed since the last game:
/// `min(sqrt(RD^2 + c^2 * days), MAX_DEVIATION)`. Unchanged within a day.
public fun current_deviation(r: &Rating, now_ms: u64): u64 {
    if (now_ms <= r.last_played_ms) return r.deviation;
    let days = (now_ms - r.last_played_ms) / MS_PER_DAY;
    if (days == 0) return r.deviation;

    let rd = r.deviation;
    let growth = C2_PER_DAY * days;
    let n = rd * rd + growth;
    if (n >= MAX_DEVIATION * MAX_DEVIATION) return MAX_DEVIATION;

    // Integer Newton from `RD + growth / 2RD`, the first-order estimate of the
    // root and an upper bound of it (capped by the maximum, also an upper
    // bound). From above, `y <- (y + n / y) / 2` descends monotonically and
    // stops at `floor(sqrt(n))`.
    let mut y = (rd + growth / (2 * rd)).min(MAX_DEVIATION);
    loop {
        let next = (y + n / y) / 2;
        if (next >= y) return y;
        y = next;
    }
}

/// Expected score of `player` against `opponent`, in millionths.
public fun expected_score(player: &Rating, opponent: &Rating, now_ms: u64): u64 {
    let g = g(opponent.current_deviation(now_ms));
    uq64_64::int_mul(E6, expected(g, player.rating, opponent.rating)) as u64
}

// === Compute ===

/// Compute both ratings after a single game between `a` and `b`, with `score`
/// from `a`'s perspective. Pure: the inputs are the pre-game values, neither is
/// modified, and both results derive from the pre-game values as Glicko
/// requires. Returns `(a', b')`.
public fun compute(a: &Rating, b: &Rating, score: Score, now_ms: u64): (Rating, Rating) {
    let opposite = match (score) {
        Score::Win => Score::Loss,
        Score::Draw => Score::Draw,
        Score::Loss => Score::Win,
    };
    (compute_one(a, b, score, now_ms), compute_one(b, a, opposite, now_ms))
}

#[test_only]
public fun new_for_testing(rating: u64, deviation: u64, games: u64, last_played_ms: u64): Rating {
    Rating { rating, deviation, games, last_played_ms }
}

#[test_only]
/// One side of `compute`, exposed for benchmarking.
public fun compute_one_for_testing(
    player: &Rating,
    opponent: &Rating,
    score: Score,
    now_ms: u64,
): Rating {
    compute_one(player, opponent, score, now_ms)
}

// === Internal ===

/// Rating of `player` after a single game against `opponent`.
fun compute_one(player: &Rating, opponent: &Rating, score: Score, now_ms: u64): Rating {
    let rd = player.current_deviation(now_ms);
    let g = g(opponent.current_deviation(now_ms));
    let e = expected(g, player.rating, opponent.rating);
    let one = uq64_64::from_raw(ONE_RAW);
    let s = match (score) {
        Score::Win => one,
        Score::Draw => uq64_64::from_raw(HALF_RAW),
        Score::Loss => uq64_64::from_raw(0),
    };

    // A = 1 / RD^2 + q^2 * g^2 * E * (1 - E)
    let rd2 = (rd as u128) * (rd as u128);
    let q2 = uq64_64::from_raw(Q2_RAW);
    let a = uq64_64::from_quotient(1, rd2).add(q2.mul(g).mul(g).mul(e).mul(one.sub(e)));

    // |r' - r| = q * g * |s - E| / A
    let is_gain = s.ge(e);
    let diff = if (is_gain) s.sub(e) else e.sub(s);
    let delta = round(uq64_64::from_raw(Q_RAW).mul(g).mul(diff).div(a));

    // RD' = sqrt(1 / A); it never exceeds RD and stays above 0.7 RD, so RD
    // seeds the Newton iteration
    let rd_next = sqrt(one.div(a), uq64_64::from_int(rd));
    let deviation = round(rd_next).max(MIN_DEVIATION).min(MAX_DEVIATION);

    Rating {
        rating: if (is_gain) player.rating + delta else player.rating - delta.min(player.rating),
        deviation,
        games: player.games + 1,
        last_played_ms: now_ms,
    }
}

/// `g(RD) = 1 / sqrt(1 + 3 * q^2 * RD^2 / pi^2)`.
fun g(deviation: u64): UQ64_64 {
    let one = uq64_64::from_raw(ONE_RAW);
    let rd2 = uq64_64::from_int(deviation * deviation);
    let n = one.add(uq64_64::from_raw(G_COEF_RAW).mul(rd2));
    one.div(sqrt(n, uq64_64::from_raw(G_SEED_RAW)))
}

/// `E = 1 / (1 + 10^(-g * (r - r_j) / 400))`. Uses the symmetry
/// `E(-d) = 1 - E(d)` and linear interpolation over `E_TABLE`.
fun expected(g: UQ64_64, rating: u64, opponent: u64): UQ64_64 {
    let (diff, is_higher) = if (rating >= opponent) {
        ((rating - opponent) as u128, true)
    } else {
        ((opponent - rating) as u128, false)
    };

    // effective difference in hundredths of a point
    let d_e2 = uq64_64::int_mul(diff * 100, g);
    let table = E_TABLE;
    let last = table.length() - 1;
    let idx = (d_e2 / E_STEP_E2) as u64;
    let e_e6 = if (idx >= last) table[last] as u128
    else {
        let (lo, hi) = (table[idx] as u128, table[idx + 1] as u128);
        lo + (hi - lo) * (d_e2 % E_STEP_E2) / E_STEP_E2
    };

    let e = uq64_64::from_quotient(e_e6, E6);
    if (is_higher) e else uq64_64::from_raw(ONE_RAW).sub(e)
}

/// Square root by Newton's method, `y <- (y + x / y) / 2`, starting from
/// `seed`. Callers pass a seed within a few tens of percent of the result.
fun sqrt(x: UQ64_64, seed: UQ64_64): UQ64_64 {
    let mut y = seed;
    SQRT_STEPS.do!(|_| y = uq64_64::from_raw((y.to_raw() + x.div(y).to_raw()) >> 1));
    y
}

/// Round to the nearest integer.
fun round(x: UQ64_64): u64 {
    uq64_64::from_raw(x.to_raw() + HALF_RAW).to_int()
}
