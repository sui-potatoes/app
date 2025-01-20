// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[test_only]
/// Currently a test-only module which can be used to build SVG paths.
/// Paths are a standardised way to define shapes in SVG.
module svg::path_builder;

use std::{string::String, unit_test::assert_eq};

/// The builder for the SVG path attribute.
public struct Path has copy, drop {
    contents: vector<Command>,
}

/// The commands that can be used to build a path.
public enum Command has copy, drop {
    MoveTo(u16, u16),
    LineTo(u16, u16),
    HorizontalLineTo(u16),
    VerticalLineTo(u16),
    ClosePath,
    CurveTo(u16, u16, u16, u16, u16, u16),
    SmoothCurveTo(u16, u16, u16, u16),
    QuadraticBezierCurveTo(u16, u16, u16, u16),
    SmoothQuadraticBezierCurveTo(u16, u16),
    EllipticalArc(u16, u16, u16, bool, bool, u16, u16),
}

public fun new(): Path {
    Path { contents: vector[] }
}

/// Adds the `M x y` command to the path.
public fun move_to(mut path: Path, x: u16, y: u16): Path {
    path.contents.push_back(Command::MoveTo(x, y));
    path
}

/// Adds the `L x y` command to the path.
public fun line_to(mut path: Path, x: u16, y: u16): Path {
    path.contents.push_back(Command::LineTo(x, y));
    path
}

/// Adds the `H x` command to the path.
public fun horizontal_line_to(mut path: Path, x: u16): Path {
    path.contents.push_back(Command::HorizontalLineTo(x));
    path
}

/// Adds the `V y` command to the path.
public fun vertical_line_to(mut path: Path, y: u16): Path {
    path.contents.push_back(Command::VerticalLineTo(y));
    path
}

/// Adds the `Z` command to the path.
public fun close_path(mut path: Path): Path {
    path.contents.push_back(Command::ClosePath);
    path
}

/// Adds the `C x1 y1 x2 y2 x y` command to the path.
public fun curve_to(mut path: Path, x1: u16, y1: u16, x2: u16, y2: u16, x: u16, y: u16): Path {
    path.contents.push_back(Command::CurveTo(x1, y1, x2, y2, x, y));
    path
}

/// Adds the `S x2 y2 x y` command to the path.
public fun smooth_curve_to(mut path: Path, x2: u16, y2: u16, x: u16, y: u16): Path {
    path.contents.push_back(Command::SmoothCurveTo(x2, y2, x, y));
    path
}

/// Adds the `Q x1 y1 x y` command to the path.
public fun quadratic_bezier_curve_to(mut path: Path, x1: u16, y1: u16, x: u16, y: u16): Path {
    path.contents.push_back(Command::QuadraticBezierCurveTo(x1, y1, x, y));
    path
}

/// Adds the `T x y` command to the path.
public fun smooth_quadratic_bezier_curve_to(mut path: Path, x: u16, y: u16): Path {
    path.contents.push_back(Command::SmoothQuadraticBezierCurveTo(x, y));
    path
}

/// Adds the `A rx ry x_axis_rotation large_arc_flag sweep_flag x y` command to the path.
public fun elliptical_arc(
    mut path: Path,
    rx: u16,
    ry: u16,
    x_axis_rotation: u16,
    large_arc_flag: bool,
    sweep_flag: bool,
    x: u16,
    y: u16,
): Path {
    path
        .contents
        .push_back(
            Command::EllipticalArc(rx, ry, x_axis_rotation, large_arc_flag, sweep_flag, x, y),
        );
    path
}

/// Converts a path into a `String` that can be used as an SVG path attribute.
public fun to_string(path: &Path): String {
    path.contents.fold!(b"".to_string(), |mut acc, cmd| { acc.append(cmd.to_string()); acc })
}

public use fun command_to_string as Command.to_string;

/// Converts a command to a string.
public fun command_to_string(cmd: &Command): String {
    match (*cmd) {
        Command::MoveTo(x, y) => {
            let mut res = b"M".to_string();
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::LineTo(x, y) => {
            let mut res = b"L".to_string();
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::HorizontalLineTo(x) => {
            let mut res = b"H".to_string();
            res.append(x.to_string());
            res
        },
        Command::VerticalLineTo(y) => {
            let mut res = b"V".to_string();
            res.append(y.to_string());
            res
        },
        Command::ClosePath => b"Z".to_string(),
        Command::CurveTo(x1, y1, x2, y2, x, y) => {
            let mut res = b"C".to_string();
            res.append(x1.to_string());
            res.append(b",".to_string());
            res.append(y1.to_string());
            res.append(b",".to_string());
            res.append(x2.to_string());
            res.append(b",".to_string());
            res.append(y2.to_string());
            res.append(b",".to_string());
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::SmoothCurveTo(x2, y2, x, y) => {
            let mut res = b"S".to_string();
            res.append(x2.to_string());
            res.append(b",".to_string());
            res.append(y2.to_string());
            res.append(b",".to_string());
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::QuadraticBezierCurveTo(x1, y1, x, y) => {
            let mut res = b"Q".to_string();
            res.append(x1.to_string());
            res.append(b",".to_string());
            res.append(y1.to_string());
            res.append(b",".to_string());
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::SmoothQuadraticBezierCurveTo(x, y) => {
            let mut res = b"T".to_string();
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
        Command::EllipticalArc(rx, ry, x_axis_rotation, large_arc_flag, sweep_flag, x, y) => {
            let mut res = b"A".to_string();
            res.append(rx.to_string());
            res.append(b",".to_string());
            res.append(ry.to_string());
            res.append(b",".to_string());
            res.append(x_axis_rotation.to_string());
            res.append(b",".to_string());
            res.append(if (large_arc_flag) {
                b"1"
            } else {
                b"0"
            }.to_string());
            res.append(b",".to_string());
            res.append(if (sweep_flag) {
                b"1"
            } else {
                b"0"
            }.to_string());
            res.append(b",".to_string());
            res.append(x.to_string());
            res.append(b",".to_string());
            res.append(y.to_string());
            res
        },
    }
}

#[test]
fun test_path_builder() {
    let str = new().move_to(10, 10).line_to(20, 20).to_string();
    assert_eq!(str, b"M10,10L20,20".to_string());

    let str = new().move_to(10, 10).horizontal_line_to(20).to_string();
    assert_eq!(str, b"M10,10H20".to_string());

    let str = new().move_to(10, 10).vertical_line_to(20).to_string();
    assert_eq!(str, b"M10,10V20".to_string());

    let str = new().move_to(10, 10).close_path().to_string();
    assert_eq!(str, b"M10,10Z".to_string());

    let str = new().move_to(10, 10).curve_to(20, 20, 30, 30, 40, 40).to_string();
    assert_eq!(str, b"M10,10C20,20,30,30,40,40".to_string());

    let str = new().move_to(10, 10).smooth_curve_to(20, 20, 30, 30).to_string();
    assert_eq!(str, b"M10,10S20,20,30,30".to_string());

    let str = new().move_to(10, 10).quadratic_bezier_curve_to(20, 20, 30, 30).to_string();
    assert_eq!(str, b"M10,10Q20,20,30,30".to_string());

    let str = new().move_to(10, 10).smooth_quadratic_bezier_curve_to(20, 20).to_string();
    assert_eq!(str, b"M10,10T20,20".to_string());

    let str = new().move_to(10, 10).elliptical_arc(20, 20, 30, true, false, 40, 40).to_string();
    assert_eq!(str, b"M10,10A20,20,30,1,0,40,40".to_string());

    let str = new()
        .move_to(10, 10)
        .line_to(20, 20)
        .horizontal_line_to(30)
        .vertical_line_to(40)
        .close_path()
        .curve_to(50, 50, 60, 60, 70, 70)
        .smooth_curve_to(80, 80, 90, 90)
        .quadratic_bezier_curve_to(100, 100, 110, 110)
        .smooth_quadratic_bezier_curve_to(120, 120)
        .elliptical_arc(130, 130, 140, true, false, 150, 150)
        .to_string();

    assert_eq!(
        str,
        b"M10,10L20,20H30V40ZC50,50,60,60,70,70S80,80,90,90Q100,100,110,110T120,120A130,130,140,1,0,150,150".to_string(),
    );
}
