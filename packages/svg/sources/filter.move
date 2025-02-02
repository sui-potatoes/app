// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: filter
///
/// Filters are the biggest enum in the SVG module, with 25 different types of
/// filters. To prevent verifier failure, we avoid using enums for the filter,
/// and instead rely on attributes with String-String pairs and a type attribute.
module svg::filter;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::print;

const TYPE_BLEND: u8 = 0;
const TYPE_COLOR_MATRIX: u8 = 1;
const TYPE_COMPONENT_TRANSFER: u8 = 2;
const TYPE_COMPOSITE: u8 = 3;
const TYPE_CONVOLVE_MATRIX: u8 = 4;
const TYPE_DIFFUSE_LIGHTING: u8 = 5;
const TYPE_DISPLACEMENT_MAP: u8 = 6;
const TYPE_DISTANT_LIGHT: u8 = 7;
const TYPE_DROP_SHADOW: u8 = 8;
const TYPE_FLOOD: u8 = 9;
const TYPE_FUNC_A: u8 = 10;
const TYPE_FUNC_B: u8 = 11;
const TYPE_FUNC_G: u8 = 12;
const TYPE_FUNC_R: u8 = 13;
const TYPE_GAUSSIAN_BLUR: u8 = 14;
const TYPE_IMAGE: u8 = 15;
const TYPE_MERGE: u8 = 16;
const TYPE_MERGE_NODE: u8 = 17;
const TYPE_MORPHOLOGY: u8 = 18;
const TYPE_OFFSET: u8 = 19;
const TYPE_POINT_LIGHT: u8 = 20;
const TYPE_SPECULAR_LIGHTING: u8 = 21;
const TYPE_SPOT_LIGHT: u8 = 22;
const TYPE_TILE: u8 = 23;
const TYPE_TURBULENCE: u8 = 24;

public struct Filter has copy, drop, store {
    filter_type: u8,
    attributes: VecMap<String, String>,
}

/// Create a new blend filter.
public fun blend(in: String, in2: String, mode: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"in2".to_string(), in2);
    attributes.insert(b"mode".to_string(), mode);

    Filter { filter_type: TYPE_BLEND, attributes }
}

/// Create a new color matrix filter.
public fun color_matrix(in: String, type_: String, values: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"type".to_string(), type_);
    attributes.insert(b"values".to_string(), values);

    Filter { filter_type: TYPE_COLOR_MATRIX, attributes }
}

/// Create a new component transfer filter.
public fun component_transfer(in: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);

    Filter { filter_type: TYPE_COMPONENT_TRANSFER, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"in2".to_string(), in2);
    attributes.insert(b"operator".to_string(), operator);
    attributes.insert(b"k1".to_string(), k1);
    attributes.insert(b"k2".to_string(), k2);
    attributes.insert(b"k3".to_string(), k3);
    attributes.insert(b"k4".to_string(), k4);

    Filter { filter_type: TYPE_COMPOSITE, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"order".to_string(), order);
    attributes.insert(b"kernelMatrix".to_string(), kernelMatrix);
    attributes.insert(b"divisor".to_string(), divisor);
    attributes.insert(b"bias".to_string(), bias);
    attributes.insert(b"targetX".to_string(), targetX.to_string());
    attributes.insert(b"targetY".to_string(), targetY.to_string());
    attributes.insert(b"edgeMode".to_string(), edgeMode);
    attributes.insert(b"kernelUnitLength".to_string(), kernelUnitLength);
    attributes.insert(b"preserveAlpha".to_string(), preserveAlpha);

    Filter { filter_type: TYPE_CONVOLVE_MATRIX, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"surfaceScale".to_string(), surfaceScale);
    attributes.insert(b"diffuseConstant".to_string(), diffuseConstant);
    attributes.insert(b"kernelUnitLength".to_string(), kernelUnitLength);
    attributes.insert(b"color".to_string(), color);
    attributes.insert(b"light".to_string(), light);

    Filter { filter_type: TYPE_DIFFUSE_LIGHTING, attributes }
}

/// Create a new displacement map filter.
public fun displacement_map(
    in: String,
    in2: String,
    scale: String,
    xChannelSelector: String,
    yChannelSelector: String,
): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"in2".to_string(), in2);
    attributes.insert(b"scale".to_string(), scale);
    attributes.insert(b"xChannelSelector".to_string(), xChannelSelector);
    attributes.insert(b"yChannelSelector".to_string(), yChannelSelector);

    Filter { filter_type: TYPE_DISPLACEMENT_MAP, attributes }
}

/// Create a new distant light filter.
public fun distant_light(azimuth: String, elevation: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"azimuth".to_string(), azimuth);
    attributes.insert(b"elevation".to_string(), elevation);

    Filter { filter_type: TYPE_DISTANT_LIGHT, attributes }
}

/// Create a new drop shadow filter.
public fun drop_shadow(in: String, dx: u16, dy: u16, stdDeviation: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"dx".to_string(), dx.to_string());
    attributes.insert(b"dy".to_string(), dy.to_string());
    attributes.insert(b"stdDeviation".to_string(), stdDeviation);

    Filter { filter_type: TYPE_DROP_SHADOW, attributes }
}

/// Create a new flood filter.
public fun flood(color: String, opacity: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"color".to_string(), color);
    attributes.insert(b"opacity".to_string(), opacity);

    Filter { filter_type: TYPE_FLOOD, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"type".to_string(), type_);
    attributes.insert(b"tableValues".to_string(), tableValues);
    attributes.insert(b"slope".to_string(), slope);
    attributes.insert(b"intercept".to_string(), intercept);
    attributes.insert(b"amplitude".to_string(), amplitude);
    attributes.insert(b"exponent".to_string(), exponent);
    attributes.insert(b"offset".to_string(), offset);

    Filter { filter_type: TYPE_FUNC_A, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"type".to_string(), type_);
    attributes.insert(b"tableValues".to_string(), tableValues);
    attributes.insert(b"slope".to_string(), slope);
    attributes.insert(b"intercept".to_string(), intercept);
    attributes.insert(b"amplitude".to_string(), amplitude);
    attributes.insert(b"exponent".to_string(), exponent);
    attributes.insert(b"offset".to_string(), offset);

    Filter { filter_type: TYPE_FUNC_B, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"type".to_string(), type_);
    attributes.insert(b"tableValues".to_string(), tableValues);
    attributes.insert(b"slope".to_string(), slope);
    attributes.insert(b"intercept".to_string(), intercept);
    attributes.insert(b"amplitude".to_string(), amplitude);
    attributes.insert(b"exponent".to_string(), exponent);
    attributes.insert(b"offset".to_string(), offset);

    Filter { filter_type: TYPE_FUNC_G, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"type".to_string(), type_);
    attributes.insert(b"tableValues".to_string(), tableValues);
    attributes.insert(b"slope".to_string(), slope);
    attributes.insert(b"intercept".to_string(), intercept);
    attributes.insert(b"amplitude".to_string(), amplitude);
    attributes.insert(b"exponent".to_string(), exponent);
    attributes.insert(b"offset".to_string(), offset);

    Filter { filter_type: TYPE_FUNC_R, attributes }
}

/// Create a new gaussian blur filter.
public fun gaussian_blur(in: String, stdDeviation: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"stdDeviation".to_string(), stdDeviation);

    Filter { filter_type: TYPE_GAUSSIAN_BLUR, attributes }
}

/// Create a new image filter.
public fun image(href: String, result: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"href".to_string(), href);
    attributes.insert(b"result".to_string(), result);

    Filter { filter_type: TYPE_IMAGE, attributes }
}

/// Create a new merge filter.
public fun merge(in: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);

    Filter { filter_type: TYPE_MERGE, attributes }
}

/// Create a new merge node filter.
public fun merge_node(in: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);

    Filter { filter_type: TYPE_MERGE_NODE, attributes }
}

/// Create a new morphology filter.
public fun morphology(in: String, operator: String, radius: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"operator".to_string(), operator);
    attributes.insert(b"radius".to_string(), radius);

    Filter { filter_type: TYPE_MORPHOLOGY, attributes }
}

/// Create a new offset filter.
public fun offset(in: String, dx: u16, dy: u16): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"dx".to_string(), dx.to_string());
    attributes.insert(b"dy".to_string(), dy.to_string());

    Filter { filter_type: TYPE_OFFSET, attributes }
}

/// Create a new point light filter.
public fun point_light(x: u16, y: u16, z: u16): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"x".to_string(), x.to_string());
    attributes.insert(b"y".to_string(), y.to_string());
    attributes.insert(b"z".to_string(), z.to_string());

    Filter { filter_type: TYPE_POINT_LIGHT, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);
    attributes.insert(b"surfaceScale".to_string(), surfaceScale);
    attributes.insert(b"specularConstant".to_string(), specularConstant);
    attributes.insert(b"specularExponent".to_string(), specularExponent);
    attributes.insert(b"kernelUnitLength".to_string(), kernelUnitLength);
    attributes.insert(b"light".to_string(), light);

    Filter { filter_type: TYPE_SPECULAR_LIGHTING, attributes }
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
    let mut attributes = vec_map::empty();
    attributes.insert(b"x".to_string(), x.to_string());
    attributes.insert(b"y".to_string(), y.to_string());
    attributes.insert(b"z".to_string(), z.to_string());
    attributes.insert(b"pointsAtX".to_string(), pointsAtX.to_string());
    attributes.insert(b"pointsAtY".to_string(), pointsAtY.to_string());
    attributes.insert(b"pointsAtZ".to_string(), pointsAtZ.to_string());
    attributes.insert(b"specularExponent".to_string(), specularExponent);
    attributes.insert(b"limitingConeAngle".to_string(), limitingConeAngle);

    Filter { filter_type: TYPE_SPOT_LIGHT, attributes }
}

/// Create a new tile filter.
public fun tile(in: String): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"in".to_string(), in);

    Filter { filter_type: TYPE_TILE, attributes }
}

/// Create a new turbulence filter.
public fun turbulence(
    baseFrequency: String,
    numOctaves: String,
    seed: String,
    stitchTiles: String,
    type_: String,
): Filter {
    let mut attributes = vec_map::empty();
    attributes.insert(b"baseFrequency".to_string(), baseFrequency);
    attributes.insert(b"numOctaves".to_string(), numOctaves);
    attributes.insert(b"seed".to_string(), seed);
    attributes.insert(b"stitchTiles".to_string(), stitchTiles);
    attributes.insert(b"type".to_string(), type_);

    Filter { filter_type: TYPE_TURBULENCE, attributes }
}

/// Get a reference to the attributes of a shape.
public fun attributes(shape: &Filter): &VecMap<String, String> {
    &shape.attributes
}

/// Get a mutable reference to the attributes of a shape.
public fun attributes_mut(shape: &mut Filter): &mut VecMap<String, String> {
    &mut shape.attributes
}

/// Map over the attributes of the animation.
///
/// ```rust
/// let mut animation = shape::circle(10).move_to(20, 20).map_attributes!(|attrs| {
///    attrs.insert(b"fill".to_string(), b"red".to_string());
///    attrs.insert(b"stroke".to_string(), b"black".to_string());
/// });
/// ```
public macro fun map_attributes($self: Filter, $f: |&mut VecMap<String, String>|): Filter {
    let mut self = $self;
    let attributes = self.attributes_mut();
    $f(attributes);
    self
}

/// Get the name of a filter.
///
/// TODO: replace with constants when compiler bug is fixed.
public fun name(filter: &Filter): String {
    match (filter.filter_type) {
        0 => b"feBlend",
        1 => b"feColorMatrix",
        2 => b"feComponentTransfer",
        3 => b"feComposite",
        4 => b"feConvolveMatrix",
        5 => b"feDiffuseLighting",
        6 => b"feDisplacementMap",
        7 => b"feDistantLight",
        8 => b"feDropShadow",
        9 => b"feFlood",
        10 => b"feFuncA",
        11 => b"feFuncB",
        12 => b"feFuncG",
        13 => b"feFuncR",
        14 => b"feGaussianBlur",
        15 => b"feImage",
        16 => b"feMerge",
        17 => b"feMergeNode",
        18 => b"feMorphology",
        19 => b"feOffset",
        20 => b"fePointLight",
        21 => b"feSpecularLighting",
        22 => b"feSpotLight",
        23 => b"feTile",
        24 => b"feTurbulence",
        _ => abort,
    }.to_string()
}

/// Print the filter element as a string.
public fun to_string(filter: &Filter): String {
    print::print(filter.name(), filter.attributes, option::none())
}

#[test_only]
/// Print the `Shape` as a string to console in tests.
public fun debug(self: &Filter) { std::debug::print(&to_string(self)); }
