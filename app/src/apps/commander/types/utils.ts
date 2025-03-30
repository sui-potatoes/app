// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

export type Prefix<T extends string> = T extends `${infer U}:${infer _}` ? U : T;
export type Prefixed<T extends string, P extends string> = `${T}:${P}`;
export type UnPrefixed<T extends string> = T extends `${infer _}:${infer U}` ? U : T;

/** Transforms an object map into a prefixed declaration while preserving key-value typing */
export type PrefixedEventMap<P extends string, K extends {}, T extends Extract<keyof K, string>> = {
    [U in Prefixed<P, T>]: K[Extract<UnPrefixed<U>, T>];
};

// test for types
// const b: UnPrefixed<"observer:Attack"> = "Attack";
// const a: Prefixed<"observer", "Attack"> = "observer:Attack";
// const c: Prefix<"observer:Attack"> = "observer";
