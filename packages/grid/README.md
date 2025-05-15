# Grid

Grid is a library which helps implement grid-based games and applications. It provides the `Grid`
type and a set of utilities and macros to work with it.

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

Use the `mvr` to add the library to your project:

```bash
# both mainnet and testnet
mvr add @potatoes/grid
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
Grid = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/grid", rev = "grid@v1" }
```

Exported address of this package is:

```toml
grid = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project;

use grid::grid::{Self, Grid};

public struct Game has key, store {
    id: UID,
    field: Grid<u8>,
}

public fun new(ctx: &mut TxContext): Game {
    Game {
        id: object::new(ctx),
        field: grid::tabulate!(10, 10, |_, _| 0) // all 0's
    }
}
```

## Examples

See application examples built [in the `examples/` directory](https://github.com/sui-potatoes/app/tree/main/packages/grid/examples)

## License

This package is licensed under the [MIT license](https://github.com/sui-potatoes/app/tree/main/LICENSE).
