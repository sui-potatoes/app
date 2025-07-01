# Grid

Grid is a library which helps implement grid-based games and applications. It provides the `Grid`
type and a set of utilities and macros to work with it.

- [Installing](#installing)
- [Usage](#usage)
    - [Using Grid](#using-grid)
    - [Point](#point)
    - [Direction](#direction)
    - [Cursor](#cursor)
- [Examples](#examples)
- [License](#license)

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/grid
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
grid = { git = "https://github.com/sui-potatoes/grid.git", subdir = "packages/grid", rev = "grid@v1" }
```

Exported address of this package is:

```toml
grid = "0x..."
```

## Usage

The package features 4 modules, each implementing a feature:

- `grid::grid` - defines the `Grid` type and its methods
- `grid::point` - defines the `Point` type
- `grid::direction` - implements direction bitmaps
- `grid::cursor` - defines the `Cursor` type and its methods

### Using Grid

### Point

Point represents a `Point` on a plane as `x` and `y` coordinates, where `x` is the row, and `y` is the column.

```move
use grid::point;

#[test]
fun test_point() {
    // create a `Point` at `(0, 1)`
    let point = point::new(0, 1);
    let (x, y) = point.into_values();

    // get all Moore neighbors of the Point
    // excludes the point
    let moore_neighbors = point.moore(1);

    // get all Von-Neumann neighbors of the Point
    // excludes the point
    let von_neumann_neighbors = point.von_neumann(1);

    // prints as a pair: `(1, 2)`
    let printed = point.to_string();
}
```

### Direction

### Cursor

## License

This package is licensed under the [MIT license](https://github.com/sui-potatoes/app/tree/main/LICENSE).
