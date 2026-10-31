# Glicko

Glicko rating system implemented in Move on `std::uq64_64` fixed-point arithmetic. A pure library: no
objects, no storage. Keep `Rating` values wherever your application sees fit and call `compute`
once after every game to get both players' new ratings.

Each `Rating` carries a rating and a deviation (RD). The deviation is the uncertainty of the
rating: newcomers start at 350, converge towards 30 as they play and drift back up while
inactive. The size of a single update is scaled by both players' deviations, so new players
converge fast while established ratings stay stable.

## Installing

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
glicko = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/glicko", rev = "glicko@v1" }
```

Exported address of this package is:

```toml
glicko = "0x..."
```

## Usage

```move
module my::ladder;

use glicko::glicko::{Self, Rating};

public struct Ladder has key {
    id: UID,
    ratings: sui::table::Table<address, Rating>,
}

/// Settle a game: both new ratings derive from the pre-game values.
public fun settle(ladder: &mut Ladder, winner: address, loser: address, now_ms: u64) {
    let (w, l) = glicko::compute(&ladder.ratings[winner], &ladder.ratings[loser], glicko::win(), now_ms);
    *&mut ladder.ratings[winner] = w;
    *&mut ladder.ratings[loser] = l;
}
```

## API

- `default()` - rating of a player who has never played (1500 / 350).
- `new(rating, deviation)` - rating with explicit values and no history.
- `win()`, `draw()`, `loss()` - `Score` constructors, from the first player's perspective.
- `compute(&a, &b, score, now_ms): (Rating, Rating)` - both ratings after a single game, `score`
  from `a`'s perspective; pure.
- `expected_score(&player, &opponent, now_ms)` - win probability scaled by `10^6`.
- `current_deviation(&rating, now_ms)` - deviation grown for inactivity, capped at 350.
- `rating()`, `deviation()`, `games()`, `last_played_ms()` - reads.

## Constants

| Name              | Value | Meaning                                                      |
| ----------------- | ----- | ------------------------------------------------------------ |
| `DEFAULT_RATING`  | 1500  | Starting rating                                              |
| `MAX_DEVIATION`   | 350   | Starting deviation and upper bound                           |
| `MIN_DEVIATION`   | 30    | Lower bound, keeps established ratings movable               |
| `C2_PER_DAY`      | 1200  | Growth of `RD^2` per inactive day (30 to 350 in ~100 days)   |

## Implementation notes

- Rating periods are a single game; inactivity is applied per day since the last game.
- All fractional math uses `std::uq64_64` (64 integer bits, 64 fractional bits). Constants are
  stored as raw `2^64`-scaled values.
- Square roots use seeded Newton steps instead of the bit-by-bit integer `sqrt`. The seeds
  are always within a few tens of percent of the result (`5/4` for `g`, the pre-game deviation
  for the new deviation), so five steps converge beyond fixed-point precision. The inactivity
  growth of the deviation uses integer Newton from the first-order estimate `RD + growth / 2RD`,
  which is an upper bound of the root, and returns the cap outright once `RD^2 + growth` reaches
  `350^2`. This is the bulk of the gas saving over a naive implementation.
- The logistic `E(d)` is an 81-entry lookup table over effective rating difference with linear
  interpolation, clamped past 2000 points.
- Results are rounded to whole rating points and whole deviation points. Compared to a floating
  point implementation the error is within one point.
- Ratings saturate at zero and never go negative.

## License

MIT
