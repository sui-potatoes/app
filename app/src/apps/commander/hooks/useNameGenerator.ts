// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { EGender, Name } from "@undergroundsociety/cybername-gen";

export async function useNameGenerator() {
    const name = new Name(EGender.male);

    return {
        name: `${name.firstname} ${name.lastname}`,
        backstory: "Story locked",
    };
}
