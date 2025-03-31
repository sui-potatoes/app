# Cyberpunk Name Gen

A simple name generator for creating names for characters in a cyberpunk setting. The generator uses a combination of first names, last names, suffixes, and randomization to create unique names.

## Installation

### Using [MVR](https://docs.suins.io/move-registry)

```shell
mvr add @potatoes/name-gen --network testnet

# or for mainnet
mvr add @potatoes/name-gen --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
NameGen = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/name-gen", rev = "name-gen@v1" }
```

The solution works for both `testnet` and `mainnet` versions. The exported address of this package is:

```toml
name_gen = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project;

use std::string::String;
use name_gen::name_gen;

entry fun generate(r: &Random, ctx: &mut TxContext): String {
    let mut gen = r.new_generator(ctx);
    let male_name = name_gen::new_male_name(&mut gen);
    let _female_name = name_gen::new_female_name(&mut gen); // for female names
    name
}
```

## Implementation guide

The functions provided by the package should be integrated into an application following the standard practices of working with Random (see [Sui Documentation](https://docs.sui.io/guides/developer/advanced/randomness-onchain)). Calls cannot be called directly on the package and must be wrapped into a custom `entry` function which uses the result as a field of a struct or, say, as a parameter of a function.

### Example usage

An example implementation is provided in the [`examples` folder](https://github.com/sui-potatoes/app/tree/main/packages/name-gen/examples). Here is a brief overview of the code:

```move
module 0::hero;

use name_gen::name_gen;
use std::string::String;
use sui::random::Random;

/// The `Hero` who has a name.
public struct Hero has key, store { id: UID, name: String }

// The function MUST be an `entry` function for `Random` to work, and it must be
// called last in the transaction.
entry fun new(rng: &Random, ctx: &mut TxContext) {
    let mut gen = rng.new_generator(ctx); // acquire generator instance
    let name = name_gen::new_male_name(&mut gen); // also `new_female_name`
    transfer::transfer(
        Hero {
            id: object::new(ctx),
            name,
        },
        ctx.sender(),
    );
}
```

### Generating multiple names

If you need to generate multiple names in a single transaction, repeat the steps in the example above, and perform multiple calls in the `new` function. Batching multiple `entry` + `Random` calls in a single transaction is impossible due to [`Random` struct restrictions](https://docs.sui.io/guides/developer/advanced/randomness-onchain).

## Acknowledgements

This implementation is possible and based on the [Underground Society's Cybername Gen](https://github.com/UndergroundSociety-xyz/cybername-gen) , which, in turn, is based on the [Sci Fi Ideas](https://www.scifiideas.com/) name generator.

## License

MIT
