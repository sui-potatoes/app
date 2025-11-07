# Identify - Type Identification Library

Identify is a library that provides a way to identify the type of a value at runtime. It is using type-identification mechanism of dynamic fields to identify the type of a value.

> This library solves a set of very specific and niche use cases. For most common type operations, refer to the [TypeName]() module documentation.

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/identify
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
identify = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/identify", rev = "identify@v1" }
```

Exported address of this package is:

```toml
identify = "0x..."
```

In your code, import and use the package as:

```move
module my::awesome_project;

use identify::identify;

public fun do<T: store>() {
    assert!(identify::is_u8<u8>());
    let value: u8 = identify::as_u8(v, ctx);
}
```

## General principles

Functions of the `identify` module can be split into two categories:

-   `is_xxx` functions, where `xxx` is the name of the type you want to check
-   `as_xxx` functions, where `xxx` is the name of the type you want to identify value as

## Limitations

Identified type must have `store` ability.

### `is`-functions

These functions check if the value is of the given type. They return a boolean value.

```move
assert!(identify::is_u8<u8>());
assert!(!identify::is_bool<u16>());

// for vector, there's no check for the element type
// if you want to check the element type, you can use `is_type` function
assert!(identify::is_vector<T>());

// for custom and framework types, use `is_type` function
assert!(identify::is_type<T, MyType>());
```

### `as`-functions

These functions take a generic input `v` of type `T` and identify it as the type `R`. They return a value of type `R`.

```move
let value: u8 = identify::as_u8(v, ctx);
let value: bool = identify::as_bool(v, ctx);

// for vector, specify the element type
// alternatively, you can use `as_type` function
let value: vector<u8> = identify::as_vector<_, u8>(v, ctx);

// for custom and framework types, use `as_type` function
let value: MyType = identify::as_type<_, MyType>(v, ctx);
```

To better understand the application of these functions, consider an example:

```move
public fun show_identify<T: store>(v: T, ctx: &mut TxContext) {
    if (identify::is_u8<T>()) {
        let value: u8 = identify::as_u8(v, ctx);
        // do something with the `u8` value
    } else if (identify::is_bool<T>()) {
        let value: bool = identify::as_bool(v, ctx);
        // do something with the `bool` value
    } else if (identify::is_type<T, MyType>()) {
        let value: MyType = identify::as_type(v, ctx);
        // do something with the `MyType` value
    } else {
        abort
    }
}
```

## Contributing

For changes, please [open an issue](https://github.com/sui-potatoes/app/issues/new/choose) or submit a [pull request](https://github.com/sui-potatoes/app).

## License

This package is licensed under MIT.
