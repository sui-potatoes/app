// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: filter
module svg::filter;

use std::string::String;
use sui::vec_map;
use svg::print;

/// The filter element is used to define an SVG filter effect.
public enum Filter has store, copy, drop {
    FeBlend { in: String, in2: String, mode: String },
    FeColorMatrix { in: String, type_: String, values: String },
    FeComponentTransfer { in: String },
    FeComposite {
        in: String,
        in2: String,
        operator: String,
        k1: String,
        k2: String,
        k3: String,
        k4: String,
    },
    FeConvolveMatrix {
        in: String,
        order: String,
        kernelMatrix: String,
        divisor: String,
        bias: String,
        targetX: u16,
        targetY: u16,
        edgeMode: String,
        kernelUnitLength: String,
        preserveAlpha: String,
    },
    FeDiffuseLighting {
        in: String,
        surfaceScale: String,
        diffuseConstant: String,
        kernelUnitLength: String,
        color: String,
        light: String,
    },
    FeDisplacementMap {
        in: String,
        in2: String,
        scale: String,
        xChannelSelector: String,
        yChannelSelector: String,
    },
    FeDistantLight { azimuth: String, elevation: String },
    FeDropShadow { in: String, dx: u16, dy: u16, stdDeviation: String },
    FeFlood { color: String, opacity: String },
    FeFuncA {
        type_: String,
        tableValues: String,
        slope: String,
        intercept: String,
        amplitude: String,
        exponent: String,
        offset: String,
    },
    FeFuncB {
        type_: String,
        tableValues: String,
        slope: String,
        intercept: String,
        amplitude: String,
        exponent: String,
        offset: String,
    },
    FeFuncG {
        type_: String,
        tableValues: String,
        slope: String,
        intercept: String,
        amplitude: String,
        exponent: String,
        offset: String,
    },
    FeFuncR {
        type_: String,
        tableValues: String,
        slope: String,
        intercept: String,
        amplitude: String,
        exponent: String,
        offset: String,
    },
    FeGaussianBlur { in: String, stdDeviation: String },
    FeImage { href: String, result: String },
    FeMerge { in: String },
    FeMergeNode { in: String },
    FeMorphology { in: String, operator: String, radius: String },
    FeOffset { in: String, dx: u16, dy: u16 },
    FePointLight { x: u16, y: u16, z: u16 },
    FeSpecularLighting {
        in: String,
        surfaceScale: String,
        specularConstant: String,
        specularExponent: String,
        kernelUnitLength: String,
        light: String,
    },
    FeSpotLight {
        x: u16,
        y: u16,
        z: u16,
        pointsAtX: u16,
        pointsAtY: u16,
        pointsAtZ: u16,
        specularExponent: String,
        limitingConeAngle: String,
    },
    FeTile { in: String },
    FeTurbulence {
        baseFrequency: String,
        numOctaves: u16,
        seed: String,
        stitchTiles: String,
        type_: String,
    },
}

/// Create a new blend filter.
public fun blend(in: String, in2: String, mode: String): Filter {
    Filter::FeBlend { in, in2, mode }
}

/// Create a new color matrix filter.
public fun color_matrix(in: String, type_: String, values: String): Filter {
    Filter::FeColorMatrix { in, type_, values }
}

/// Create a new component transfer filter.
public fun component_transfer(in: String): Filter {
    Filter::FeComponentTransfer { in }
}

/// Create a new composite filter.
public fun composite(
    in: String,
    in2: String,
    operator: String,
    k1: String,
    k2: String,
    k3: String,
    k4: String,
): Filter {
    Filter::FeComposite { in, in2, operator, k1, k2, k3, k4 }
}

/// Create a new convolve matrix filter.
public fun convolve_matrix(
    in: String,
    order: String,
    kernelMatrix: String,
    divisor: String,
    bias: String,
    targetX: u16,
    targetY: u16,
    edgeMode: String,
    kernelUnitLength: String,
    preserveAlpha: String,
): Filter {
    Filter::FeConvolveMatrix {
        in,
        order,
        kernelMatrix,
        divisor,
        bias,
        targetX,
        targetY,
        edgeMode,
        kernelUnitLength,
        preserveAlpha,
    }
}

/// Create a new diffuse lighting filter.
public fun diffuse_lighting(
    in: String,
    surfaceScale: String,
    diffuseConstant: String,
    kernelUnitLength: String,
    color: String,
    light: String,
): Filter {
    Filter::FeDiffuseLighting {
        in,
        surfaceScale,
        diffuseConstant,
        kernelUnitLength,
        color,
        light,
    }
}

/// Create a new displacement map filter.
public fun displacement_map(
    in: String,
    in2: String,
    scale: String,
    xChannelSelector: String,
    yChannelSelector: String,
): Filter {
    Filter::FeDisplacementMap {
        in,
        in2,
        scale,
        xChannelSelector,
        yChannelSelector,
    }
}

/// Create a new distant light filter.
public fun distant_light(azimuth: String, elevation: String): Filter {
    Filter::FeDistantLight { azimuth, elevation }
}

/// Create a new drop shadow filter.
public fun drop_shadow(in: String, dx: u16, dy: u16, stdDeviation: String): Filter {
    Filter::FeDropShadow { in, dx, dy, stdDeviation }
}

/// Create a new flood filter.
public fun flood(color: String, opacity: String): Filter {
    Filter::FeFlood { color, opacity }
}

/// Create a new function A filter.
public fun func_a(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    offset: String,
): Filter {
    Filter::FeFuncA {
        type_,
        tableValues,
        slope,
        intercept,
        amplitude,
        exponent,
        offset,
    }
}

/// Create a new function B filter.
public fun func_b(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    offset: String,
): Filter {
    Filter::FeFuncB {
        type_,
        tableValues,
        slope,
        intercept,
        amplitude,
        exponent,
        offset,
    }
}

/// Create a new function G filter.
public fun func_g(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    offset: String,
): Filter {
    Filter::FeFuncG {
        type_,
        tableValues,
        slope,
        intercept,
        amplitude,
        exponent,
        offset,
    }
}

/// Create a new function R filter.
public fun func_r(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    offset: String,
): Filter {
    Filter::FeFuncR {
        type_,
        tableValues,
        slope,
        intercept,
        amplitude,
        exponent,
        offset,
    }
}

/// Create a new gaussian blur filter.
public fun gaussian_blur(in: String, stdDeviation: String): Filter {
    Filter::FeGaussianBlur { in, stdDeviation }
}

/// Create a new image filter.
public fun image(href: String, result: String): Filter {
    Filter::FeImage { href, result }
}

/// Create a new merge filter.
public fun merge(in: String): Filter {
    Filter::FeMerge { in }
}

/// Create a new merge node filter.
public fun merge_node(in: String): Filter {
    Filter::FeMergeNode { in }
}

/// Create a new morphology filter.
public fun morphology(in: String, operator: String, radius: String): Filter {
    Filter::FeMorphology { in, operator, radius }
}

/// Create a new offset filter.
public fun offset(in: String, dx: u16, dy: u16): Filter {
    Filter::FeOffset { in, dx, dy }
}

/// Create a new point light filter.
public fun point_light(x: u16, y: u16, z: u16): Filter {
    Filter::FePointLight { x, y, z }
}

/// Create a new specular lighting filter.
public fun specular_lighting(
    in: String,
    surfaceScale: String,
    specularConstant: String,
    specularExponent: String,
    kernelUnitLength: String,
    light: String,
): Filter {
    Filter::FeSpecularLighting {
        in,
        surfaceScale,
        specularConstant,
        specularExponent,
        kernelUnitLength,
        light,
    }
}

/// Create a new spot light filter.
public fun spot_light(
    x: u16,
    y: u16,
    z: u16,
    pointsAtX: u16,
    pointsAtY: u16,
    pointsAtZ: u16,
    specularExponent: String,
    limitingConeAngle: String,
): Filter {
    Filter::FeSpotLight {
        x,
        y,
        z,
        pointsAtX,
        pointsAtY,
        pointsAtZ,
        specularExponent,
        limitingConeAngle,
    }
}

/// Create a new tile filter.
public fun tile(in: String): Filter {
    Filter::FeTile { in }
}

/// Create a new turbulence filter.
public fun turbulence(
    baseFrequency: String,
    numOctaves: u16,
    seed: String,
    stitchTiles: String,
    type_: String,
): Filter {
    Filter::FeTurbulence {
        baseFrequency,
        numOctaves,
        seed,
        stitchTiles,
        type_,
    }
}

public fun to_string(filter: &Filter): String {
    let (elem, attributes) = match (filter) {
        Filter::FeBlend { in, in2, mode } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"in2".to_string(), *in2);
            attrs.insert(b"mode".to_string(), *mode);
            (b"feBlend", attrs)
        },
        Filter::FeColorMatrix { in, type_, values } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"type".to_string(), *type_);
            attrs.insert(b"values".to_string(), *values);
            (b"feColorMatrix", attrs)
        },
        Filter::FeComponentTransfer { in } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            (b"feComponentTransfer", attrs)
        },
        Filter::FeComposite { in, in2, operator, k1, k2, k3, k4 } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"in2".to_string(), *in2);
            attrs.insert(b"operator".to_string(), *operator);
            attrs.insert(b"k1".to_string(), *k1);
            attrs.insert(b"k2".to_string(), *k2);
            attrs.insert(b"k3".to_string(), *k3);
            attrs.insert(b"k4".to_string(), *k4);
            (b"feComposite", attrs)
        },
        Filter::FeConvolveMatrix {
            in,
            order,
            kernelMatrix,
            divisor,
            bias,
            targetX,
            targetY,
            edgeMode,
            kernelUnitLength,
            preserveAlpha,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"order".to_string(), *order);
            attrs.insert(b"kernelMatrix".to_string(), *kernelMatrix);
            attrs.insert(b"divisor".to_string(), *divisor);
            attrs.insert(b"bias".to_string(), *bias);
            attrs.insert(b"targetX".to_string(), (*targetX).to_string());
            attrs.insert(b"targetY".to_string(), (*targetY).to_string());
            attrs.insert(b"edgeMode".to_string(), *edgeMode);
            attrs.insert(b"kernelUnitLength".to_string(), *kernelUnitLength);
            attrs.insert(b"preserveAlpha".to_string(), *preserveAlpha);
            (b"feConvolveMatrix", attrs)
        },
        Filter::FeDiffuseLighting {
            in,
            surfaceScale,
            diffuseConstant,
            kernelUnitLength,
            color,
            light,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"surfaceScale".to_string(), *surfaceScale);
            attrs.insert(b"diffuseConstant".to_string(), *diffuseConstant);
            attrs.insert(b"kernelUnitLength".to_string(), *kernelUnitLength);
            attrs.insert(b"color".to_string(), *color);
            attrs.insert(b"light".to_string(), *light);
            (b"feDiffuseLighting", attrs)
        },
        Filter::FeDisplacementMap {
            in,
            in2,
            scale,
            xChannelSelector,
            yChannelSelector,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"in2".to_string(), *in2);
            attrs.insert(b"scale".to_string(), *scale);
            attrs.insert(b"xChannelSelector".to_string(), *xChannelSelector);
            attrs.insert(b"yChannelSelector".to_string(), *yChannelSelector);
            (b"feDisplacementMap", attrs)
        },
        Filter::FeDistantLight { azimuth, elevation } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"azimuth".to_string(), *azimuth);
            attrs.insert(b"elevation".to_string(), *elevation);
            (b"feDistantLight", attrs)
        },
        Filter::FeDropShadow { in, dx, dy, stdDeviation } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"dx".to_string(), (*dx).to_string());
            attrs.insert(b"dy".to_string(), (*dy).to_string());
            attrs.insert(b"stdDeviation".to_string(), *stdDeviation);
            (b"feDropShadow", attrs)
        },
        Filter::FeFlood { color, opacity } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"color".to_string(), *color);
            attrs.insert(b"opacity".to_string(), *opacity);
            (b"feFlood", attrs)
        },
        Filter::FeFuncA {
            type_,
            tableValues,
            slope,
            intercept,
            amplitude,
            exponent,
            offset,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"type".to_string(), *type_);
            attrs.insert(b"tableValues".to_string(), *tableValues);
            attrs.insert(b"slope".to_string(), *slope);
            attrs.insert(b"intercept".to_string(), *intercept);
            attrs.insert(b"amplitude".to_string(), *amplitude);
            attrs.insert(b"exponent".to_string(), *exponent);
            attrs.insert(b"offset".to_string(), *offset);
            (b"feFuncA", attrs)
        },
        Filter::FeFuncB {
            type_,
            tableValues,
            slope,
            intercept,
            amplitude,
            exponent,
            offset,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"type".to_string(), *type_);
            attrs.insert(b"tableValues".to_string(), *tableValues);
            attrs.insert(b"slope".to_string(), *slope);
            attrs.insert(b"intercept".to_string(), *intercept);
            attrs.insert(b"amplitude".to_string(), *amplitude);
            attrs.insert(b"exponent".to_string(), *exponent);
            attrs.insert(b"offset".to_string(), *offset);
            (b"feFuncB", attrs)
        },
        Filter::FeFuncG {
            type_,
            tableValues,
            slope,
            intercept,
            amplitude,
            exponent,
            offset,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"type".to_string(), *type_);
            attrs.insert(b"tableValues".to_string(), *tableValues);
            attrs.insert(b"slope".to_string(), *slope);
            attrs.insert(b"intercept".to_string(), *intercept);
            attrs.insert(b"amplitude".to_string(), *amplitude);
            attrs.insert(b"exponent".to_string(), *exponent);
            attrs.insert(b"offset".to_string(), *offset);
            (b"feFuncG", attrs)
        },
        Filter::FeFuncR {
            type_,
            tableValues,
            slope,
            intercept,
            amplitude,
            exponent,
            offset,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"type".to_string(), *type_);
            attrs.insert(b"tableValues".to_string(), *tableValues);
            attrs.insert(b"slope".to_string(), *slope);
            attrs.insert(b"intercept".to_string(), *intercept);
            attrs.insert(b"amplitude".to_string(), *amplitude);
            attrs.insert(b"exponent".to_string(), *exponent);
            attrs.insert(b"offset".to_string(), *offset);
            (b"feFuncR", attrs)
        },
        Filter::FeGaussianBlur { in, stdDeviation } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"stdDeviation".to_string(), *stdDeviation);
            (b"feGaussianBlur", attrs)
        },
        Filter::FeImage { href, result } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"href".to_string(), *href);
            attrs.insert(b"result".to_string(), *result);
            (b"feImage", attrs)
        },
        Filter::FeMerge { in } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            (b"feMerge", attrs)
        },
        Filter::FeMergeNode { in } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            (b"feMergeNode", attrs)
        },
        Filter::FeMorphology { in, operator, radius } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"operator".to_string(), *operator);
            attrs.insert(b"radius".to_string(), *radius);
            (b"feMorphology", attrs)
        },
        Filter::FeOffset { in, dx, dy } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"dx".to_string(), (*dx).to_string());
            attrs.insert(b"dy".to_string(), (*dy).to_string());
            (b"feOffset", attrs)
        },
        Filter::FePointLight { x, y, z } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"x".to_string(), (*x).to_string());
            attrs.insert(b"y".to_string(), (*y).to_string());
            attrs.insert(b"z".to_string(), (*z).to_string());
            (b"fePointLight", attrs)
        },
        Filter::FeSpecularLighting {
            in,
            surfaceScale,
            specularConstant,
            specularExponent,
            kernelUnitLength,
            light,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            attrs.insert(b"surfaceScale".to_string(), *surfaceScale);
            attrs.insert(b"specularConstant".to_string(), *specularConstant);
            attrs.insert(b"specularExponent".to_string(), *specularExponent);
            attrs.insert(b"kernelUnitLength".to_string(), *kernelUnitLength);
            attrs.insert(b"light".to_string(), *light);
            (b"feSpecularLighting", attrs)
        },
        Filter::FeSpotLight {
            x,
            y,
            z,
            pointsAtX,
            pointsAtY,
            pointsAtZ,
            specularExponent,
            limitingConeAngle,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"x".to_string(), (*x).to_string());
            attrs.insert(b"y".to_string(), (*y).to_string());
            attrs.insert(b"z".to_string(), (*z).to_string());
            attrs.insert(b"pointsAtX".to_string(), (*pointsAtX).to_string());
            attrs.insert(b"pointsAtY".to_string(), (*pointsAtY).to_string());
            attrs.insert(b"pointsAtZ".to_string(), (*pointsAtZ).to_string());
            attrs.insert(b"specularExponent".to_string(), *specularExponent);
            attrs.insert(b"limitingConeAngle".to_string(), *limitingConeAngle);
            (b"feSpotLight", attrs)
        },
        Filter::FeTile { in } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"in".to_string(), *in);
            (b"feTile", attrs)
        },
        Filter::FeTurbulence {
            baseFrequency,
            numOctaves,
            seed,
            stitchTiles,
            type_,
        } => {
            let mut attrs = vec_map::empty();
            attrs.insert(b"baseFrequency".to_string(), *baseFrequency);
            attrs.insert(b"numOctaves".to_string(), (*numOctaves).to_string());
            attrs.insert(b"seed".to_string(), *seed);
            attrs.insert(b"stitchTiles".to_string(), *stitchTiles);
            attrs.insert(b"type".to_string(), *type_);
            (b"feTurbulence", attrs)
        },
    };

    print::print(elem.to_string(), attributes, option::none())
}
