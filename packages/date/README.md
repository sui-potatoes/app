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
-   supports RFC 1123 (UTC) string printing
-   supports ISO 8601 string printing
-   supports custom date formatting, [see Format](#formatting) for rules

## Formatting

| pattern | alternative | description                                |
| ------- | ----------- | ------------------------------------------ |
| `yyyy`  | `YYYY`      | The year number in four digits (e.g. 2005) |
| `yy`    | `YY`        | The last two digits of the year (e.g. 05)  |
| `y`     | -           | The last digit of the year (e.g. 5)        |
| `MMMM`  | -           | Full month name (output only)              |
| `MMM`   | -           | Three letter month name (e.g. Aug)         |
| `MM`    | -           | Two digit month with leading zero          |
| `M`     | -           | Month number 1-12 without leading zero     |
| `dddd`  | `DDDD`      | Full day name (output only)                |
| `ddd`   | `DDD`       | Three letter day name (e.g. Sat)           |
| `dd`    | `DD`        | Two digit day with leading zero            |
| `d`     | `D`         | Day number 1-31 without leading zero       |
| `HH`    | -           | Two digit 24-hour with leading zero        |
| `H`     | -           | 24-hour 0-23 without leading zero          |
| `hh`    | -           | Two digit 12-hour with leading zero        |
| `h`     | -           | 12-hour 1-12 without leading zero          |
| `mm`    | -           | Two digit minutes with leading zero        |
| `m`     | -           | Minutes 0-59 without leading zero          |
| `ss`    | -           | Two digit seconds with leading zero        |
| `s`     | -           | Seconds 0-59 without leading zero          |
| `tt`    | -           | A.M. or P.M.                               |
| `z`     | -           | UTC offset (e.g. +01:00, -05:00)           |

## Examples

### Constructing From Clock or RFC 1123 String

```move
use sui::clock::Clock;
use date::date;

public fun date_from_clock(c: &Clock) {
    // Handy method for passing `Clock`.
    let date = date::from_clock(c);

    // Print the `Date` as an RFC 1123 String.
    let utc_string = date.to_utc_string();

    // Construct the `Date` from an RFC 1123 String.
    let _date = date.from_utc_string(utc_string);
}
```

### UTC and ISO printing

```move
use std::unit_test::assert_eq;

#[test]
fun try_utc_and_iso() {
    assert_eq!(
        date::new(1747409967000).to_utc_string(), // utc!
        b"Fri, 16 May 2025 15:39:27 GMT".to_string(),
    );

    assert_eq!(
        date::new(1747901403000).to_iso_string(), // iso 8601
        b"2025-05-22T08:10:03.000Z".to_string()
    );
}
```

### Different Formatting

```move
use std::unit_test::assert_eq;

#[test]
fun try_different_formats() {
    let d = date::new(1747901403000).format(b"dd/MM/yyyy HH:mm:ss");
    assert_eq!(d, b"22/05/2025 08:10:03",to_string());

    let d = date::new(2145916899000).format(b"DD-MM-YY - tt - HH::mm::ss");
    assert_eq!(d, b"01-01-38 - AM - 00::01::39".to_string());
}
```

## License

This package is licensed under MIT.
