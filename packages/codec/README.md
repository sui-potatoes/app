# Codec

This library implements 3 most popular encoding schemes: HEX (Base16), Base64,
and Urlencode. The latter is extremely useful in building
[Data URLs](https://datatracker.ietf.org/doc/html/rfc2397) with the
[%-encoding scheme](https://datatracker.ietf.org/doc/html/rfc3986).

Additionally, it implements a `potatoes` encoding scheme which is based on the
standard HEX encoding but replaces the `ABCDEF` symbols with `POTAES` (all unique
letters in "potatoes").

## Installing

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
Codec = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/codec", rev = "codec@testnet-v1" }
```

If you need a **mainnet** version of this package, use the `mainnet-v1` tag instead:

```toml
# goes into [dependencies] section
Codec = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/codec", rev = "codec@mainnet-v1" }
```


Exported address of this package is:

```toml
codec = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project {
    use codec::hex;

    public fun do() {
        let _ = hex::encode(b"hey y'all");
    }
}
```

## General principles

All of the modules in this package follow the same signature scheme to make it
intuitive to use. Every module consists of two public functions: `encode` and
`decode`, both stay the same in every scheme implementation. The `String` type
is always `std::string::String`.

```rust
use std::string::String;
use potatoes::hex;

// while the type annotation is not necessary, we've added it to be explicit
let encoded: String = hex::encode(b"hello, potato!"); // takes vector<u8>
let decoded: vector<u8> = hex::decode(b"DEADBEEF".to_string()); // takes String
```

## Available Codecs

Each encoding is placed into a separate module, here is a full list:

### HEX

Implements the Base16 encoding scheme. The module is called `hex`.
```rust
use codec::hex;

let encoded: String = hex::encode(b"hello, potato!");
let decoded: vector<u8> = hex::decode(b"DEADBEEF".to_string());
```

### Base64

Implements the Base64 encoding scheme. The module is called `base64`.
```rust
use codec::base64;

let encoded: String = base64::encode(b"hello, potato!");
let decoded: vector<u8> = base64::decode(b"SGVsbG8sIHBvdGF0byE=".to_string());
```

### URL Encoding

Implements the URL encoding scheme. The module is called `urlencode`.
```rust
use codec::urlencode;

let encoded: String = urlencode::encode(b"hello, potato!");
let decoded: vector<u8> = urlencode::decode(b"hello%2C%20potato%21".to_string());
```

### Potatoes

Implements the POTAES encoding scheme. The module is called `potatoes`.
```rust
use codec::potatoes;

let encoded: String = potatoes::encode(b"hello, potato!");
let decoded: vector<u8> = potatoes::decode(b"10POTATOES".to_string());
```

## License

This package is licensed under MIT.
