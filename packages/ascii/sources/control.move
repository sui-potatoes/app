// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines ASCII control characters (range 0-31 and 127 (DELETE)).
module ascii::control;

// === Checks ===

/// Check if a character is a control character.
public macro fun is_control($char: u8): bool { $char <= 31 || $char == 127 }

// === Control characters ===

/// Null character.
public macro fun null(): u8 { 0 }

/// Start of heading character.
public macro fun start_of_heading(): u8 { 1 }

/// Start of text character.
public macro fun start_of_text(): u8 { 2 }

/// End of text character.
public macro fun end_of_text(): u8 { 3 }

/// End of transmission character.
public macro fun end_of_transmission(): u8 { 4 }

/// Enquiry character.
public macro fun enquiry(): u8 { 5 }

/// Acknowledge character.
public macro fun acknowledge(): u8 { 6 }

/// Bell character.
public macro fun bell(): u8 { 7 }

/// Backspace character.
public macro fun backspace(): u8 { 8 }

/// Horizontal tab character.
public macro fun horizontal_tab(): u8 { 9 }

/// Line feed character.
public macro fun line_feed(): u8 { 10 }

/// Vertical tab character.
public macro fun vertical_tab(): u8 { 11 }

/// Form feed character.
public macro fun form_feed(): u8 { 12 }

/// Carriage return character.
public macro fun carriage_return(): u8 { 13 }

/// Shift out character.
public macro fun shift_out(): u8 { 14 }

/// Shift in character.
public macro fun shift_in(): u8 { 15 }

/// Data link escape character.
public macro fun data_link_escape(): u8 { 16 }

/// Device control 1 character.
public macro fun device_control_1(): u8 { 17 }

/// Device control 2 character.
public macro fun device_control_2(): u8 { 18 }

/// Device control 3 character.
public macro fun device_control_3(): u8 { 19 }

/// Device control 4 character.
public macro fun device_control_4(): u8 { 20 }

/// Negative acknowledge character.
public macro fun negative_acknowledge(): u8 { 21 }

/// Synchronous idle character.
public macro fun synchronous_idle(): u8 { 22 }

/// End of transmission block character.
public macro fun end_of_transmission_block(): u8 { 23 }

/// Cancel character.
public macro fun cancel(): u8 { 24 }

/// End of medium character.
public macro fun end_of_medium(): u8 { 25 }

/// Substitute character.
public macro fun substitute(): u8 { 26 }

/// Escape character.
public macro fun escape(): u8 { 27 }

/// File separator character.
public macro fun file_separator(): u8 { 28 }

/// Group separator character.
public macro fun group_separator(): u8 { 29 }

/// Record separator character.
public macro fun record_separator(): u8 { 30 }

/// Unit separator character.
public macro fun unit_separator(): u8 { 31 }

/// Delete character.
public macro fun delete(): u8 { 127 }
