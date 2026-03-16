// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// General utility macros for the Grid package. The macros used to be `public`
/// in the `move-stdlib`, but then the visibility was changed to `public(package)`.
module grid::macros;

public macro fun num_max<$T>($x: $T, $y: $T): $T {
    let x = $x;
    let y = $y;
    if (x > y) x else y
}

public macro fun num_min<$T>($x: $T, $y: $T): $T {
    let x = $x;
    let y = $y;
    if (x < y) x else y
}

public macro fun num_diff<$T>($x: $T, $y: $T): $T {
    let x = $x;
    let y = $y;
    if (x > y) x - y else y - x
}
