# Libraries

Reusable Move packages published by Potatoes. All packages are available via the [Move Registry](https://github.com/mystenlabs/mvr) and can be installed with:

```sh
mvr add @potatoes/<name>
```

---

## <a id="codec" href="#codec">#</a> Codec ([source](https://github.com/sui-potatoes/app/tree/main/packages/codec))

Encoding and decoding library supporting HEX, Base64, Base64url, URL encoding, and Potatoes scheme.

```move
use codec::hex;

let encoded = hex::encode(b"hello, potato!");
let decoded = hex::decode(b"DEADBEEF".to_string());
```

Supported encodings: `codec::hex`, `codec::base64`, `codec::base64url`, `codec::urlencode`, `codec::potatoes`

Used in: [Character](/character) for data URLs, [Go Game](/go) for game state encoding.

---

## <a id="format" href="#format">#</a> Format ([source](https://github.com/sui-potatoes/app/tree/main/packages/format))

String templating inspired by Rust's `format!` macro with `dbg!` debugging helper.

```move
use format::format;

let str = format(b"Hello, {}!".to_string(), vector[b"Jane".to_string()]);
dbg!(b"value: {}", vector![42.to_string()]);
```

---

## <a id="grid" href="#grid">#</a> Grid ([source](https://github.com/sui-potatoes/app/tree/main/packages/grid))

2D grid library with cells, directions, and cursor utilities. Designed for grid-based games and applications.

```move
use grid::{cell, direction, cursor};

let neighbors = cell::new(0, 1).moore(1);
let dir = direction::up!() | direction::left!();
let mut cursor = cursor::new(0, 0);
cursor.move_to(direction::down!());
```

Modules: `grid::grid`, `grid::cell`, `grid::direction`, `grid::cursor`

Used in: [Commander](/commander) for tactical combat grid.

---

## <a id="ascii" href="#ascii">#</a> ASCII ([source](https://github.com/sui-potatoes/app/tree/main/packages/ascii))

Zero-cost macros for explicit ASCII string handling. Full character table with printable, control, and extended ASCII.

```move
use ascii::char;

let space = char::space!();
assert!(bytes.all!(|c| char::is_printable!(*c)));
```

Modules: `ascii::ascii`, `ascii::char`, `ascii::control`, `ascii::extended`

---

## <a id="bit-field" href="#bit-field">#</a> Bit Field ([source](https://github.com/sui-potatoes/app/tree/main/packages/bit-field))

Pack and unpack data types into single integers with zero-cost macros. Supports u8 through u128.

```move
let packed: u64 = bit_field::pack_u8!(vector[1, 2, 3, 4]);
let value = bit_field::read_u8_at_offset!(packed, 0); // returns 1
let unpacked = bit_field::unpack_u8!(packed);
```

---

## <a id="date" href="#date">#</a> Date ([source](https://github.com/sui-potatoes/app/tree/main/packages/date))

Date and time formatting supporting RFC 7231, ISO 8601, and custom formats. Works with `sui::clock::Clock`.

```move
use date::date;

let date = date::from_clock(clock);
let utc = date.to_utc_string();    // RFC 7231
let iso = date.to_iso_string();    // ISO 8601
let custom = date.format(b"dd/MM/yyyy HH:mm:ss");
```

---

## <a id="svg" href="#svg">#</a> SVG ([source](https://github.com/sui-potatoes/app/tree/main/packages/svg))

SVG and XML element standard implementation in Move. Build and render SVG images fully on-chain.

---

## <a id="identify" href="#identify">#</a> Identify ([source](https://github.com/sui-potatoes/app/tree/main/packages/identify))

Runtime type identification using dynamic fields. Check and cast types at runtime.

```move
use identify::identify;

if (identify::is_u8<T>()) {
    let value: u8 = identify::as_u8(v, ctx);
}
```

---

## <a id="name-gen" href="#name-gen">#</a> Name Gen ([source](https://github.com/sui-potatoes/app/tree/main/packages/name-gen))

Cyberpunk name generator using on-chain randomness. Generates unique male and female character names.

```move
entry fun new(rng: &Random, ctx: &mut TxContext) {
    let mut gen = rng.new_generator(ctx);
    let name = name_gen::new_male_name(&mut gen);
}
```

Used in: [Commander](/commander) for crew member names.
