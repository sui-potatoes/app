# Grid

Grid is a library which helps implement grid-based games and applications. It provides the `Grid`
type and a set of utilities and macros to work with it.

-   [Installing](#installing)
-   [Usage](#usage)
    -   [Coordinates System](#coordinates-system)
    -   [Grid](#grid-1)
    -   [Point](#point)
    -   [Direction](#direction)
    -   [Cursor](#cursor)
-   [Examples](#examples)
-   [License](#license)

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

> For example applications build with the `Grid`, [see examples](https://github.com/sui-potatoes/app/tree/main/packages/grid/examples)

The package features 4 modules, each implementing a feature:

-   `grid::grid` - defines the `Grid` type and its methods
-   `grid::point` - defines the `Point` type
-   `grid::direction` - implements direction bitmaps
-   `grid::cursor` - defines the `Cursor` type and its methods

### Coordinates System

In the library, the `x` coordinate stands for the row, and `y` stands for the column. Zero position `(0, 0)` is top-left.

### Grid

> For full reference, refer to the [documentation](https://github.com/sui-potatoes/app/tree/main/packages/grid/docs/grid.md).

Grid is a generic container for any `T`, which offers variety of built-in methods and macros for custom implementations. It
is built in an "interface"-like manner, where dependents of the Grid can choose to implement any of the available methods by
wrapping macro calls.

#### General Grid Methods

| method        | description                                                                            |
| ------------- | -------------------------------------------------------------------------------------- |
| `from_vector` | construct the `Grid` from 2-dimensional vector                                         |
| `tabulate!`   | constructs the `Grid` with elements returned from function `$f`                        |
| `destroy!`    | destroys the `Grid` by calling `$f` on each element                                    |
| `do!`         | same as `destroy` but preserves the order of elements (top -> bottom, left -> right)   |
| `do_ref!`     | apply function `$f` to an immutable reference to an element                            |
| `map!`        | construct a new `Grid` by calling a function `$f` on each element, consumes the value  |
| `map_ref!`    | same as `map!` but does not consume the value, creates a new instance from a reference |
| `traverse!`   | similar to `do_ref!` but the callback `$f` receives coordinates of the Point as well   |

#### Working with Points

| method               | description                                                                                             |
| -------------------- | ------------------------------------------------------------------------------------------------------- |
| `moore`              | get all Moore neighbors of a `Point` in a distance `s`                                                  |
| `von_neumann`        | get all Von Neumann neighbors of a `Point` in a distance `s`                                            |
| `moore_count!`       | count all Moore neighbors of a `Point` in a distance `s` that satisfy predicate `$f`                    |
| `von_neumann_count!` | count all Von Neumann neighbors of a `Point` in a distance `s` that satisfy predicate `$f`              |
| `find_group!`        | finds a group of points that match the predicate `$f` in the neighborhood `$n`                          |
| `trace!`             | traces path from `$p0` to `$p1` in the neighborhood `$n` with `$f` marking if the tile can be walked on |

#### Utilities

| method                | description                                                                       |
| --------------------- | --------------------------------------------------------------------------------- |
| `debug!`              | print the `Grid` to `stdout`. _Only works if `T` implements `to_string()` method_ |
| `to_string!`          | print `Grid` as a `String`. _Only works if `T` implements `to_string()` method_   |
| `from_bcs!`           | peel the `Grid` from `BCS` instance, parse each element with function `$f`        |
| `manhattan_distance!` | get Manhattan distance between two pairs of coordinates                           |
| `chebyshev_distance!` | get Chebyshev distance between two pairs of coordinates                           |

### Point

> For full reference, refer to the [documentation](https://github.com/sui-potatoes/app/tree/main/packages/grid/docs/point.md).

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

> For full reference, refer to the [documentation](https://github.com/sui-potatoes/app/tree/main/packages/grid/docs/direction.md).

Direction defines

### Cursor

> For full reference, refer to the [documentation](https://github.com/sui-potatoes/app/tree/main/packages/grid/docs/cursor.md).

## Examples

Usage examples [are available on GitHub](https://github.com/sui-potatoes/app/tree/main/packages/grid/examples).

Additionally, these applications use Grid package:

-   [Commander](https://github.com/sui-potatoes/app/tree/main/packages/commander)
-   [Go Game](https://github.com/sui-potatoes/app/tree/main/packages/go-game)

## License

This package is licensed under the [MIT license](https://github.com/sui-potatoes/app/tree/main/LICENSE).
