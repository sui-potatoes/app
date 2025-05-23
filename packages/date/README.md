# Date

This package implements date and time in Move: standard UTC string implementation as well
as ISO 8601.

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/date
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
Codec = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/date", rev = "date@v3" }
```

Exported address of this package is:

```toml
date = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project;

use date::date;

public fun utc_date(clock: &Clock): String {
    date::from_clock(clock).to_utc_string()
}
```

## Features

-   supports timestamp -> parsed date conversion with the ability to get current
    minutes, seconds, year and so on
-   supports utc date string printing
-   supports ISO 8601 string printing
-   supports custom date formatting, [see Format](#formatting) for rules

## Formatting

## License

This package is licensed under MIT.
