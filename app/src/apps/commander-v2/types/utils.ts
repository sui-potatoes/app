// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

export type Prefix<T extends string> = T extends `${infer U}:${infer _}` ? U : T;
export type Prefixed<T extends string, P extends string> = `${T}:${P}`;
export type UnPrefixed<T extends string> = T extends `${infer _}:${infer U}` ? U : T;

// test for types
// const b: UnPrefixed<"observer:Attack"> = "Attack";
// const a: Prefixed<"observer", "Attack"> = "observer:Attack";
// const c: Prefix<"observer:Attack"> = "observer";
