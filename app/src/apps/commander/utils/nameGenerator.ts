// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { EGender, Name } from "@undergroundsociety/cybername-gen";

/** Generate a random name + backstory for a freshly hired recruit. */
export function generateRecruitName() {
    const name = new Name(EGender.male);

    return {
        name: `${name.firstname} ${name.lastname}`,
        backstory: "Story locked",
    };
}
