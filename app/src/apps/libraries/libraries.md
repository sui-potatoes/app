# Libraries

This page contains the list of packages published by the members of the potatoes group. They are used in all of the projects on this website, and are available for use in other projects.

## Codec - ultimate encoding solution ([source code](https://github.com/sui-potatoes/app/tree/main/packages/codec))

"Codec" implements a number of encodings in a single package. It can be used for different applications, such as encoding images for the web, or encoding data for storing on the blockchain.

> See the [README](https://github.com/sui-potatoes/app/tree/main/packages/codec) for usage and installation instructions.

```move
use codec::urlencode;

let encoded = urlencode::encode(b"Hello, World!");
let decoded = urlencode::decode(&encoded);

assert!(decoded == b"Hello, World!");
```

Full list of supported encodings in v1:

- `codec::hex`
- `codec::base64`
- `codec::potatoes`
- `codec::urlencode`

Usage on this website:

- [Character](/character) - uses this library to create "data URLs" for inscribed images.</p>
- [Go Game](/go) - uses this library to encode the game state as a Data URL too.</p>
