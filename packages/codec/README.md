# Codec

This library implements 3 most popular encoding schemes: HEX (Base16), Base64, and Urlencode. The latter is extremely useful in building [Data URLs](https://datatracker.ietf.org/doc/html/rfc2397) with the [%-encoding scheme](https://datatracker.ietf.org/doc/html/rfc3986).

Additionally, it implements `base64url` and a `potatoes` encoding scheme which is based on the standard HEX encoding but replaces the `ABCDEF` symbols with `POTAES` (all unique letters in "potatoes").

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/codec
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
codec = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/codec", rev = "codec@v3" }
```

Exported address of this package is:

```toml
codec = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project;

use codec::hex;

public fun do() {
    let _ = hex::encode(b"hey y'all");
}
```

## General principles

All of the modules in this package follow the same signature scheme to make it
intuitive to use. Every module consists of two public functions: `encode` and
`decode`, both stay the same in every scheme implementation. The `String` type
is always `std::string::String`.

```move
use codec::hex;
use std::string::String;

// while the type annotation is not necessary, we've added it to be explicit
let encoded: String = hex::encode(b"hello, potato!"); // takes vector<u8>
let decoded: vector<u8> = hex::decode(b"DEADBEEF".to_string()); // takes String
```

## Available Codecs

Each encoding is placed into a separate module, here is a full list:

### HEX

Implements the Base16 encoding scheme. The module is called `hex`.

```move
use codec::hex;
use std::string::String;

let encoded: String = hex::encode(b"hello, potato!");
let decoded: vector<u8> = hex::decode(b"DEADBEEF".to_string());
```

### Base64

Implements the Base64 encoding scheme. The module is called `base64`.

```move
use codec::base64;
use std::string::String;

let encoded: String = base64::encode(b"hello, potato!");
let decoded: vector<u8> = base64::decode(b"SGVsbG8sIHBvdGF0byE=".to_string());
```

### Base64url

Implements the Base64url encoding - a URL-friendly modification of `base64`, using slightly different dictionary and lack of padding `==`.

```move
use codec::base64url;
use std::string::String;

let encoded: String = base64url::encode(b"hello, potato!");
let decoded: vector<u8> = base64url::decode(b"SGVsbG8sIHBvdGF0byE".to_string());
```

### URL Encoding

Implements the URL encoding scheme. The module is called `urlencode`.

```move
use codec::urlencode;
use std::string::String;

let encoded: String = urlencode::encode(b"hello, potato!");
let decoded: vector<u8> = urlencode::decode(b"hello%2C%20potato%21".to_string());
```

### Potatoes

Implements the POTAES encoding scheme. The module is called `potatoes`.

```move
use codec::potatoes;
use std::string::String;

let encoded: String = potatoes::encode(b"hello, potato!");
let decoded: vector<u8> = potatoes::decode(b"10potatoes".to_string());
```

## Changelog

### v3 - adds `base64url`

-   adds `base64url` encoding scheme
-   increases performance of encoding by 5%
-   fixes bug in encoding of large values in `base64`

### v2 - performance and stability

-   overall performance improvements

### v1 - hello world

Adds encoding schemes:

-   `hex.move` - for Base16 (HEX)
-   `potatoes.move` - for POTAES encoding, derivative of HEX
-   `base64.move` - for Base64 encoding
-   `urlencode.move` - for URL encoding

## License

This package is licensed under MIT.
