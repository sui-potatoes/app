# Mathematical!

This library implements chains of operations with automatic safe scaling factor and maintaining
precision. Packed into a simple chain-able API. See for yourself!

```rust
use mathematical::formula;

// build the formula
let formula = new()
    .scale(2 << 64)
    .div(10000)
    .add(1)
    .sqrt()
    .mul(412481737123559485879);

let result1 = *&formula.calc_u128(100); // insert the value
let result2 = *&formula.calc_u128(200); // try with another one

std::debug::print(&result1);
std::debug::print(&result2);
```

## Background

Finn wasn't good at math, and nor am I. Especially when it comes to sensitive operations, maintaining
precision, minimizing rounding - well, typical math on chain. This library is intended for folks who
want to avoid being overwhelmed by simple calculations.

![](https://i.imgur.com/6IQBsBU.gif)

## Installing

> Currently, the only supported environment is testnet!

To use this package in your projects, add this to your `Move.toml`:

```toml
[addresses]
Mathematical = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/mathematical", rev = "main" }
```

## API Reference

Formula is constructed using the `new` function and can remain untyped until the result is calculated.
An instance of `Formula` supports following methods: `add`, `sub`, `mul`, `div` and `sqrt`.

```rust
use mathematical::formula;

assert!(formula::new().add(1).sub(10).mul(10).div(10).calc_u8(0) == 1);
```

## Precision Loss Prevention

By default, formula uses scaling factor matching the size of the integer. For `u32` the upscaling will
be `1 << 32`, for `u64` it is `1 << 64` and so on. All values except for `u8` are upscaled by default
when a "dangerous" operation happens: division or sqrt.

## License

Licensed as MIT.

## Authors

Sui Potatoes
