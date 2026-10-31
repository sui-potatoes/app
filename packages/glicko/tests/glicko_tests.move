// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module glicko::glicko_tests;

use glicko::glicko::{Self, Score};
use std::unit_test::assert_eq;

const HOUR: u64 = 3_600_000;
const DAY: u64 = 86_400_000;

/// Assert `actual` is within `tolerance` of `expected`.
macro fun assert_close($actual: u64, $expected: u64, $tolerance: u64) {
    let (actual, expected, tolerance) = ($actual, $expected, $tolerance);
    assert!(actual.diff(expected) <= tolerance, actual);
}

/// `0` loss, `1` draw, `2` win.
fun score(code: u64): Score {
    match (code) {
        0 => glicko::loss(),
        1 => glicko::draw(),
        _ => glicko::win(),
    }
}

#[test]
fun defaults() {
    let r = glicko::default();
    assert_eq!(r.rating(), 1500);
    assert_eq!(r.deviation(), 350);
    assert_eq!(r.games(), 0);
    assert_eq!(r.last_played_ms(), 0);
}

#[test]
fun expected_score() {
    let a = glicko::new(1500, 350);
    assert_eq!(a.expected_score(&a, 0), 500_000);

    // reference values from a floating point implementation; the two sides
    // are not complementary because `g` uses the opponent's deviation
    let (a, b) = (glicko::new(1500, 200), glicko::new(1400, 30));
    assert_close!(a.expected_score(&b, 0), 639_468, 300);
    assert_close!(b.expected_score(&a, 0), 380_834, 300);

    let (a, b) = (glicko::new(1500, 350), glicko::new(2000, 50));
    assert_close!(a.expected_score(&b, 0), 55_062, 300);

    // far beyond the table is clamped, not aborted
    let (a, b) = (glicko::new(10_000, 30), glicko::new(0, 30));
    assert_close!(a.expected_score(&b, 0), 1_000_000, 100);
    assert_close!(b.expected_score(&a, 0), 0, 100);
}

#[test]
fun compute_matches_reference() {
    // (rating, rd) vs (rating, rd), score -> expected (rating, rd) of the first
    // player; reference values computed with the floating point Glicko
    // formulas. `HOUR` is less than a day after `last_played_ms = 0`, so no
    // inactivity growth applies.
    let cases = vector[
        vector[1500, 350, 1500, 350, 2, 1662, 290],
        vector[1500, 350, 1500, 350, 0, 1338, 290],
        vector[1500, 350, 1500, 350, 1, 1500, 290],
        vector[1500, 200, 1400, 30, 2, 1563, 175],
        vector[1500, 200, 1550, 100, 0, 1427, 176],
        vector[1500, 200, 1700, 300, 0, 1456, 187],
        vector[1500, 50, 1500, 50, 2, 1507, 50],
        vector[2000, 50, 1500, 350, 2, 2001, 50],
        vector[2000, 50, 1500, 350, 0, 1992, 50],
        vector[1500, 350, 2000, 50, 2, 2046, 319],
        vector[1500, 350, 2000, 50, 0, 1468, 319],
        vector[1200, 80, 1800, 60, 1, 1217, 80],
    ];

    cases.do!(|c| {
        let player = glicko::new(c[0], c[1]);
        let opponent = glicko::new(c[2], c[3]);
        let (updated, other) = glicko::compute(&player, &opponent, score(c[4]), HOUR);
        assert_close!(updated.rating(), c[5], 1);
        assert_close!(updated.deviation(), c[6], 1);
        assert_eq!(updated.games(), 1);
        assert_eq!(updated.last_played_ms(), HOUR);

        // the second result is the mirrored computation from pre-game values
        let (mirrored, _) = glicko::compute(&opponent, &player, score(2 - c[4]), HOUR);
        assert_eq!(other, mirrored);
    });
}

#[test]
fun both_sides_move_in_opposite_directions() {
    let (a, b) = (glicko::new(1500, 350), glicko::new(1500, 350));
    let (a2, b2) = glicko::compute(&a, &b, glicko::win(), HOUR);
    assert_eq!(a2.rating(), 1662);
    assert_eq!(b2.rating(), 1338);
    assert_eq!(a2.deviation(), 290);
    assert_eq!(b2.deviation(), 290);

    let (a2, b2) = glicko::compute(&a, &b, glicko::draw(), HOUR);
    assert_eq!(a2.rating(), 1500);
    assert_eq!(b2.rating(), 1500);
}

#[test]
fun rating_saturates_at_zero() {
    let (player, opponent) = (glicko::new(0, 350), glicko::default());
    let (updated, _) = glicko::compute(&player, &opponent, glicko::loss(), HOUR);
    assert_eq!(updated.rating(), 0);
}

#[test]
fun deviation_grows_with_inactivity() {
    let r = glicko::new_for_testing(1500, 50, 1, HOUR);

    assert_eq!(r.current_deviation(HOUR), 50);
    assert_eq!(r.current_deviation(0), 50); // never in the past
    assert_eq!(r.current_deviation(HOUR + DAY - 1), 50); // less than a day

    // RD^2 + 1200 * days: 50 days -> 250, 100 days -> capped at 350
    assert_eq!(r.current_deviation(HOUR + 50 * DAY), 250);
    assert_eq!(r.current_deviation(HOUR + 100 * DAY), 350);
    assert_eq!(r.current_deviation(HOUR + 1000 * DAY), 350);

    // inactivity makes the next update larger than for an active player
    let opponent = glicko::new(1500, 50);
    let (active, _) = glicko::compute(&r, &opponent, glicko::win(), HOUR + 1);
    let (inactive, _) = glicko::compute(&r, &opponent, glicko::win(), HOUR + 100 * DAY);
    assert!(inactive.rating() > active.rating());
    assert!(inactive.deviation() > active.deviation());
    assert_eq!(inactive.games(), 2);
}

#[test]
fun deviation_is_clamped() {
    let mut r = glicko::new(1500, 30);
    let opponent = glicko::new(1500, 30);
    10u64.do!(|_| {
        let (next, _) = glicko::compute(&r, &opponent, glicko::win(), HOUR);
        r = next;
    });
    assert_eq!(r.deviation(), 30);
}

#[test, expected_failure(abort_code = glicko::EInvalidDeviation)]
fun new_rejects_low_deviation() { let _ = glicko::new(1500, 29); }

#[test, expected_failure(abort_code = glicko::EInvalidDeviation)]
fun new_rejects_high_deviation() { let _ = glicko::new(1500, 351); }

// === Benchmarks: single calls, for `sui move test -s` ===

#[test]
fun bench_compute_once() {
    let (a, b) = (glicko::new(1500, 200), glicko::new(1400, 30));
    let (_, _) = glicko::compute(&a, &b, glicko::win(), HOUR);
}

#[test]
fun bench_expected_score_once() {
    let (a, b) = (glicko::new(1500, 200), glicko::new(1400, 30));
    let _ = a.expected_score(&b, HOUR);
}

#[test]
fun bench_baseline() {
    let _ = glicko::new(1500, 200);
}

#[test]
fun bench_compute_one_side() {
    let (a, b) = (glicko::new(1500, 200), glicko::new(1400, 30));
    let _ = glicko::compute_one_for_testing(&a, &b, glicko::win(), HOUR);
}

#[test]
fun bench_current_deviation_growth() {
    // 7 days of inactivity: the square root path, not the cap
    let r = glicko::new_for_testing(1500, 50, 1, HOUR);
    let _ = r.current_deviation(HOUR + 7 * DAY);
}

#[test]
fun current_deviation_matches_integer_sqrt() {
    let days = vector[1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];
    let mut rd = 30;
    while (rd <= 350) {
        let r = glicko::new_for_testing(1500, rd, 1, HOUR);
        days.do_ref!(|d| {
            let expected = (rd * rd + 1_200 * *d).sqrt().min(350);
            assert_eq!(r.current_deviation(HOUR + *d * DAY), expected);
        });
        rd = rd + 10;
    };
}
