// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Table of non-extended, printable ASCII characters, each macro returns the
/// corresponding ASCII code.
///
/// - Lowercase letters are spelled without a prefix, eg `a` is the ASCII `97`.
/// - Uppercase letters are spelled in uppercase, eg `A` is the ASCII `65`.
module ascii::char;

// === Checks ===

/// Check if a character is printable.
public macro fun is_printable($char: u8): bool { $char >= 32 && $char <= 126 }

/// Check if a character is a digit.
public macro fun is_digit($char: u8): bool { $char >= 48 && $char <= 57 }

/// Check if a character is a letter.
public macro fun is_letter($char: u8): bool { $char >= 65 && $char <= 90 }

/// Check if a character is a lowercase letter.
public macro fun is_lowercase($char: u8): bool { $char >= 97 && $char <= 122 }

/// Check if a character is an uppercase letter.
public macro fun is_uppercase($char: u8): bool { $char >= 65 && $char <= 90 }

/// Check if a character is alphanumeric.
public macro fun is_alphanumeric($char: u8): bool {
    $char >= 48 && $char <= 57 || $char >= 65 && $char <= 90 || $char >= 97 && $char <= 122
}

// === Characters ===

/// Space character.
public macro fun space(): u8 { 32 }

/// Exclamation mark character.
public macro fun exclamation_mark(): u8 { 33 }

/// Double quote character.
public macro fun double_quote(): u8 { 34 }

/// Hash character.
public macro fun hash(): u8 { 35 }

/// Dollar character.
public macro fun dollar(): u8 { 36 }

/// Percent character.
public macro fun percent(): u8 { 37 }

/// Ampersand character.
public macro fun ampersand(): u8 { 38 }

/// Single quote character.
public macro fun single_quote(): u8 { 39 }

/// Left parenthesis character.
public macro fun left_paren(): u8 { 40 }

/// Right parenthesis character.
public macro fun right_paren(): u8 { 41 }

/// Asterisk character.
public macro fun asterisk(): u8 { 42 }

/// Plus character.
public macro fun plus(): u8 { 43 }

/// Comma character.
public macro fun comma(): u8 { 44 }

/// Minus character.
public macro fun minus(): u8 { 45 }

/// Period character.
public macro fun period(): u8 { 46 }

/// Forward slash character.
public macro fun forward_slash(): u8 { 47 }

/// Zero character.
public macro fun zero(): u8 { 48 }

/// One character.
public macro fun one(): u8 { 49 }

/// Two character.
public macro fun two(): u8 { 50 }

/// Three character.
public macro fun three(): u8 { 51 }

/// Four character.
public macro fun four(): u8 { 52 }

/// Five character.
public macro fun five(): u8 { 53 }

/// Six character.
public macro fun six(): u8 { 54 }

/// Seven character.
public macro fun seven(): u8 { 55 }

/// Eight character.
public macro fun eight(): u8 { 56 }

/// Nine character.
public macro fun nine(): u8 { 57 }

/// Colon character.
public macro fun colon(): u8 { 58 }

/// Semicolon character.
public macro fun semicolon(): u8 { 59 }

/// Less than character.
public macro fun less_than(): u8 { 60 }

/// Equals character.
public macro fun equals(): u8 { 61 }

/// Greater than character.
public macro fun greater_than(): u8 { 62 }

/// Question mark character.
public macro fun question_mark(): u8 { 63 }

/// At sign character.
public macro fun at(): u8 { 64 }

/// Uppercase A character.
public macro fun A(): u8 { 65 }

/// Uppercase B character.
public macro fun B(): u8 { 66 }

/// Uppercase C character.
public macro fun C(): u8 { 67 }

/// Uppercase D character.
public macro fun D(): u8 { 68 }

/// Uppercase E character.
public macro fun E(): u8 { 69 }

/// Uppercase F character.
public macro fun F(): u8 { 70 }

/// Uppercase G character.
public macro fun G(): u8 { 71 }

/// Uppercase H character.
public macro fun H(): u8 { 72 }

/// Uppercase I character.
public macro fun I(): u8 { 73 }

/// Uppercase J character.
public macro fun J(): u8 { 74 }

/// Uppercase K character.
public macro fun K(): u8 { 75 }

/// Uppercase L character.
public macro fun L(): u8 { 76 }

/// Uppercase M character.
public macro fun M(): u8 { 77 }

/// Uppercase N character.
public macro fun N(): u8 { 78 }

/// Uppercase O character.
public macro fun O(): u8 { 79 }

/// Uppercase P character.
public macro fun P(): u8 { 80 }

/// Uppercase Q character.
public macro fun Q(): u8 { 81 }

/// Uppercase R character.
public macro fun R(): u8 { 82 }

/// Uppercase S character.
public macro fun S(): u8 { 83 }

/// Uppercase T character.
public macro fun T(): u8 { 84 }

/// Uppercase U character.
public macro fun U(): u8 { 85 }

/// Uppercase V character.
public macro fun V(): u8 { 86 }

/// Uppercase W character.
public macro fun W(): u8 { 87 }

/// Uppercase X character.
public macro fun X(): u8 { 88 }

/// Uppercase Y character.
public macro fun Y(): u8 { 89 }

/// Uppercase Z character.
public macro fun Z(): u8 { 90 }

/// Left square bracket character.
public macro fun left_bracket(): u8 { 91 }

/// Backslash character.
public macro fun backslash(): u8 { 92 }

/// Right square bracket character.
public macro fun right_bracket(): u8 { 93 }

/// Caret character.
public macro fun caret(): u8 { 94 }

/// Underscore character.
public macro fun underscore(): u8 { 95 }

/// Backtick character.
public macro fun backtick(): u8 { 96 }

/// Lowercase a character.
public macro fun a(): u8 { 97 }

/// Lowercase b character.
public macro fun b(): u8 { 98 }

/// Lowercase c character.
public macro fun c(): u8 { 99 }

/// Lowercase d character.
public macro fun d(): u8 { 100 }

/// Lowercase e character.
public macro fun e(): u8 { 101 }

/// Lowercase f character.
public macro fun f(): u8 { 102 }

/// Lowercase g character.
public macro fun g(): u8 { 103 }

/// Lowercase h character.
public macro fun h(): u8 { 104 }

/// Lowercase i character.
public macro fun i(): u8 { 105 }

/// Lowercase j character.
public macro fun j(): u8 { 106 }

/// Lowercase k character.
public macro fun k(): u8 { 107 }

/// Lowercase l character.
public macro fun l(): u8 { 108 }

/// Lowercase m character.
public macro fun m(): u8 { 109 }

/// Lowercase n character.
public macro fun n(): u8 { 110 }

/// Lowercase o character.
public macro fun o(): u8 { 111 }

/// Lowercase p character.
public macro fun p(): u8 { 112 }

/// Lowercase q character.
public macro fun q(): u8 { 113 }

/// Lowercase r character.
public macro fun r(): u8 { 114 }

/// Lowercase s character.
public macro fun s(): u8 { 115 }

/// Lowercase t character.
public macro fun t(): u8 { 116 }

/// Lowercase u character.
public macro fun u(): u8 { 117 }

/// Lowercase v character.
public macro fun v(): u8 { 118 }

/// Lowercase w character.
public macro fun w(): u8 { 119 }

/// Lowercase x character.
public macro fun x(): u8 { 120 }

/// Lowercase y character.
public macro fun y(): u8 { 121 }

/// Lowercase z character.
public macro fun z(): u8 { 122 }

/// Left curly brace character.
public macro fun left_brace(): u8 { 123 }

/// Vertical bar character.
public macro fun vertical_bar(): u8 { 124 }

/// Right curly brace character.
public macro fun right_brace(): u8 { 125 }

/// Tilde character.
public macro fun tilde(): u8 { 126 }
