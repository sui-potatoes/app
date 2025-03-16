// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Contains mappings between assets / items and their metadata.
 *
 * @module metadata
 */

export type Metadata = { description: string; image: string };

export function weaponMetadata(name: string): Metadata {
    return (
        {
            ["standard rifle"]: {
                image: "/images/standard_rifle.svg",
                description:
                    "Standard issue rifle - a sturdy option for any encounter, not too good - not too bad. A couple upgrades won't hurt",
            },
            ["sharpshooter rifle"]: {
                image: "/images/marksman_rifle.svg",
                description:
                    "Sharpshooter rifle delivers best damage at long range. A choice for a marksman skilled enough to score critical hits.",
            },
            ["plasma rifle"]: {
                image: "/images/plasma_rifle.svg",
                description:
                    "Plasma rifle - the best in class, uses bleeding edge technology to provide maximum damage at significant range.",
            },
        }[name.toLowerCase()] || {
            image: "",
            description: "Missing metadata",
        }
    );
}

export function armorMetadata(name: string): Metadata {
    return (
        {
            ["light armor"]: {
                image: "/images/light_armor.svg",
                description:
                    "Modest protection, but light and easy to move in. Increases chance of dodging incoming damage.",
            },
            ["heavy armor"]: {
                image: "/images/heavy_armor.svg",
                description:
                    "Heavy armor provides maximum protection, but at the cost of mobility. A good choice for a tank.",
            },
            ["medium armor"]: {
                image: "/images/medium_armor.svg",
                description:
                    "Medium armor is the most balanced choice - a good compromise between protection and mobility.",
            },
        }[name.toLowerCase()] || {
            image: "",
            description: "Missing metadata",
        }
    );
}
