# format && dbg!

This library implements a handy string templating function, inspired by the Rust's `format!`
macro. Additionally, adds a `dbg!` macro wrapper for `format` and `std::debug::print`.

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/format
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
format = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/format", rev = "format@v1" }
```

Exported address of this package is:

```toml
format = "0x..."
```

## Usage

In your code, import and use the package as:

```move
module my::awesome_project;

use format::format::{format, dbg};

public fun do() {
    // format takes a String
    let str = format(b"Hello, {}!".to_string(), vector[
        b"Jane".to_string()
    ]);

    assert!(str == b"Hello, Jane!".to_string());

    // dbg! takes a bytestring `b""`
    dbg!(b"prints: {}; on i = {}", vector[
        10.to_string(),
        0.to_string(),
    ])
}
```

## License

This package is licensed under MIT.
