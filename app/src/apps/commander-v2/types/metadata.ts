// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Contains mappings between assets / items and their metadata.
 *
 * @module metadata
 */

export type Metadata = { description: string; image: string };

export function weaponImgUrls(): string[] {
    return [
        "/images/rifle_standard.svg",
        "/images/rifle_sharpshooter.svg",
        "/images/rifle_plasma.svg",
    ];
}

export function weaponMetadata(name: string): Metadata {
    const urls = weaponImgUrls();
    return (
        {
            ["standard rifle"]: {
                image: urls[0],
                description:
                    "Standard issue rifle - a sturdy option for any encounter, not too good - not too bad. A couple upgrades won't hurt",
            },
            ["sharpshooter rifle"]: {
                image: urls[1],
                description:
                    "Sharpshooter rifle delivers best damage at long range. A choice for a marksman skilled enough to score critical hits.",
            },
            ["plasma rifle"]: {
                image: urls[2],
                description:
                    "Plasma rifle - the best in class, uses bleeding edge technology to provide maximum damage at significant range.",
            },
        }[name.toLowerCase()] || {
            image: "",
            description: "Missing metadata",
        }
    );
}

export function armorImgUrls(): string[] {
    return ["/images/armor_light.svg", "/images/armor_heavy.svg", "/images/armor_medium.svg"];
}

export function armorMetadata(name: string): Metadata {
    const urls = armorImgUrls();
    return (
        {
            ["light armor"]: {
                image: urls[0],
                description:
                    "Modest protection, but light and easy to move in. Increases chance of dodging incoming damage.",
            },
            ["heavy armor"]: {
                image: urls[1],
                description:
                    "Heavy armor provides maximum protection, but at the cost of mobility. A good choice for a tank.",
            },
            ["medium armor"]: {
                image: urls[2],
                description:
                    "Medium armor is the most balanced choice - a good compromise between protection and mobility.",
            },
        }[name.toLowerCase()] || {
            image: "",
            description: "Missing metadata",
        }
    );
}
