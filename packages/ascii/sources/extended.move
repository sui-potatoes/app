// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines ASCII extended characters (range 128-255).
///
/// All characters are defined as macros, so they can be used in `all!` checks.
///
/// - Characters that mark capital letters have uppercase letter + suffix, eg `A_grave()`.
/// - Characters that mark lowercase letters have lowercase letter + suffix, eg `a_grave()`.
module ascii::extended;

// === Checks ===

/// Check if a character is an extended character.
public macro fun is_extended($char: u8): bool { $char >= 128 && $char <= 255 }

// === Extended characters ===

/// Euro sign character.
public macro fun euro_sign(): u8 { 128 }

/// Not used character.
public macro fun not_used_129(): u8 { 129 }

/// Single low quotation mark character.
public macro fun single_low_quote(): u8 { 130 }

/// Function symbol character.
public macro fun function(): u8 { 131 }

/// Double low quotation mark character.
public macro fun double_low_quote(): u8 { 132 }

/// Horizontal ellipsis character.
public macro fun ellipsis(): u8 { 133 }

/// Dagger character.
public macro fun dagger(): u8 { 134 }

/// Double dagger character.
public macro fun double_dagger(): u8 { 135 }

/// Circumflex accent character.
public macro fun circumflex(): u8 { 136 }

/// Per mille sign character.
public macro fun per_mille(): u8 { 137 }

/// Latin capital letter S with caron character.
public macro fun S_caron(): u8 { 138 }

/// Single left angle quotation mark character.
public macro fun single_left_angle_quote(): u8 { 139 }

/// Latin capital ligature OE character.
public macro fun OE(): u8 { 140 }

/// Not used character.
public macro fun not_used_141(): u8 { 141 }

/// Latin capital letter Z with caron character.
public macro fun Z_caron(): u8 { 142 }

/// Not used character.
public macro fun not_used_143(): u8 { 143 }

/// Not used character.
public macro fun not_used_144(): u8 { 144 }

/// Left single quotation mark character.
public macro fun left_single_quote(): u8 { 145 }

/// Right single quotation mark character.
public macro fun right_single_quote(): u8 { 146 }

/// Left double quotation mark character.
public macro fun left_double_quote(): u8 { 147 }

/// Right double quotation mark character.
public macro fun right_double_quote(): u8 { 148 }

/// Bullet character.
public macro fun bullet(): u8 { 149 }

/// En dash character.
public macro fun en_dash(): u8 { 150 }

/// Em dash character.
public macro fun em_dash(): u8 { 151 }

/// Small tilde character.
public macro fun small_tilde(): u8 { 152 }

/// Trade mark sign character.
public macro fun trade_mark(): u8 { 153 }

/// Latin small letter s with caron character.
public macro fun s_caron(): u8 { 154 }

/// Single right angle quotation mark character.
public macro fun single_right_angle_quote(): u8 { 155 }

/// Latin small ligature oe character.
public macro fun oe(): u8 { 156 }

/// Not used character.
public macro fun not_used_157(): u8 { 157 }

/// Latin small letter z with caron character.
public macro fun z_caron(): u8 { 158 }

/// Latin capital letter Y with diaeresis character.
public macro fun Y_diaeresis(): u8 { 159 }

/// Non-breaking space character.
public macro fun non_breaking_space(): u8 { 160 }

/// Inverted exclamation mark character.
public macro fun inverted_exclamation(): u8 { 161 }

/// Cent sign character.
public macro fun cent(): u8 { 162 }

/// Pound sign character.
public macro fun pound(): u8 { 163 }

/// Currency sign character.
public macro fun currency(): u8 { 164 }

/// Yen sign character.
public macro fun yen(): u8 { 165 }

/// Broken vertical bar character.
public macro fun broken_vertical_bar(): u8 { 166 }

/// Section sign character.
public macro fun section(): u8 { 167 }

/// Diaeresis character.
public macro fun diaeresis(): u8 { 168 }

/// Copyright sign character.
public macro fun copyright(): u8 { 169 }

/// Feminine ordinal indicator character.
public macro fun feminine_ordinal(): u8 { 170 }

/// Left double angle quotation mark character.
public macro fun left_double_angle_quote(): u8 { 171 }

/// Not sign character.
public macro fun not(): u8 { 172 }

/// Soft hyphen character.
public macro fun soft_hyphen(): u8 { 173 }

/// Registered trade mark sign character.
public macro fun registered(): u8 { 174 }

/// Macron character.
public macro fun macron(): u8 { 175 }

/// Degree sign character.
public macro fun degree(): u8 { 176 }

/// Plus-minus sign character.
public macro fun plus_minus(): u8 { 177 }

/// Superscript two character.
public macro fun superscript_two(): u8 { 178 }

/// Superscript three character.
public macro fun superscript_three(): u8 { 179 }

/// Acute accent character.
public macro fun acute(): u8 { 180 }

/// Micro sign character.
public macro fun micro(): u8 { 181 }

/// Pilcrow sign character.
public macro fun pilcrow(): u8 { 182 }

/// Middle dot character.
public macro fun middle_dot(): u8 { 183 }

/// Cedilla character.
public macro fun cedilla(): u8 { 184 }

/// Superscript one character.
public macro fun superscript_one(): u8 { 185 }

/// Masculine ordinal indicator character.
public macro fun masculine_ordinal(): u8 { 186 }

/// Right double angle quotation mark character.
public macro fun right_double_angle_quote(): u8 { 187 }

/// Vulgar fraction one quarter character.
public macro fun one_quarter(): u8 { 188 }

/// Vulgar fraction one half character.
public macro fun one_half(): u8 { 189 }

/// Vulgar fraction three quarters character.
public macro fun three_quarters(): u8 { 190 }

/// Inverted question mark character.
public macro fun inverted_question(): u8 { 191 }

/// Latin capital letter A with grave character.
public macro fun A_grave(): u8 { 192 }

/// Latin capital letter A with acute character.
public macro fun A_acute(): u8 { 193 }

/// Latin capital letter A with circumflex character.
public macro fun A_circumflex(): u8 { 194 }

/// Latin capital letter A with tilde character.
public macro fun A_tilde(): u8 { 195 }

/// Latin capital letter A with diaeresis character.
public macro fun A_diaeresis(): u8 { 196 }

/// Latin capital letter A with ring above character.
public macro fun A_ring(): u8 { 197 }

/// Latin capital letter AE character.
public macro fun AE(): u8 { 198 }

/// Latin capital letter C with cedilla character.
public macro fun C_cedilla(): u8 { 199 }

/// Latin capital letter E with grave character.
public macro fun E_grave(): u8 { 200 }

/// Latin capital letter E with acute character.
public macro fun E_acute(): u8 { 201 }

/// Latin capital letter E with circumflex character.
public macro fun E_circumflex(): u8 { 202 }

/// Latin capital letter E with diaeresis character.
public macro fun E_diaeresis(): u8 { 203 }

/// Latin capital letter I with grave character.
public macro fun I_grave(): u8 { 204 }

/// Latin capital letter I with acute character.
public macro fun I_acute(): u8 { 205 }

/// Latin capital letter I with circumflex character.
public macro fun I_circumflex(): u8 { 206 }

/// Latin capital letter I with diaeresis character.
public macro fun I_diaeresis(): u8 { 207 }

/// Latin capital letter ETH character.
public macro fun ETH(): u8 { 208 }

/// Latin capital letter N with tilde character.
public macro fun N_tilde(): u8 { 209 }

/// Latin capital letter O with grave character.
public macro fun O_grave(): u8 { 210 }

/// Latin capital letter O with acute character.
public macro fun O_acute(): u8 { 211 }

/// Latin capital letter O with circumflex character.
public macro fun O_circumflex(): u8 { 212 }

/// Latin capital letter O with tilde character.
public macro fun O_tilde(): u8 { 213 }

/// Latin capital letter O with diaeresis character.
public macro fun O_diaeresis(): u8 { 214 }

/// Multiplication sign character.
public macro fun multiplication(): u8 { 215 }

/// Latin capital letter O with stroke character.
public macro fun O_stroke(): u8 { 216 }

/// Latin capital letter U with grave character.
public macro fun U_grave(): u8 { 217 }

/// Latin capital letter U with acute character.
public macro fun U_acute(): u8 { 218 }

/// Latin capital letter U with circumflex character.
public macro fun U_circumflex(): u8 { 219 }

/// Latin capital letter U with diaeresis character.
public macro fun U_diaeresis(): u8 { 220 }

/// Latin capital letter Y with acute character.
public macro fun Y_acute(): u8 { 221 }

/// Latin capital letter THORN character.
public macro fun THORN(): u8 { 222 }

/// Latin small letter sharp s character.
public macro fun sharp_s(): u8 { 223 }

/// Latin small letter a with grave character.
public macro fun a_grave(): u8 { 224 }

/// Latin small letter a with acute character.
public macro fun a_acute(): u8 { 225 }

/// Latin small letter a with circumflex character.
public macro fun a_circumflex(): u8 { 226 }

/// Latin small letter a with tilde character.
public macro fun a_tilde(): u8 { 227 }

/// Latin small letter a with diaeresis character.
public macro fun a_diaeresis(): u8 { 228 }

/// Latin small letter a with ring above character.
public macro fun a_ring(): u8 { 229 }

/// Latin small letter ae character.
public macro fun ae(): u8 { 230 }

/// Latin small letter c with cedilla character.
public macro fun c_cedilla(): u8 { 231 }

/// Latin small letter e with grave character.
public macro fun e_grave(): u8 { 232 }

/// Latin small letter e with acute character.
public macro fun e_acute(): u8 { 233 }

/// Latin small letter e with circumflex character.
public macro fun e_circumflex(): u8 { 234 }

/// Latin small letter e with diaeresis character.
public macro fun e_diaeresis(): u8 { 235 }

/// Latin small letter i with grave character.
public macro fun i_grave(): u8 { 236 }

/// Latin small letter i with acute character.
public macro fun i_acute(): u8 { 237 }

/// Latin small letter i with circumflex character.
public macro fun i_circumflex(): u8 { 238 }

/// Latin small letter i with diaeresis character.
public macro fun i_diaeresis(): u8 { 239 }

/// Latin small letter eth character.
public macro fun eth(): u8 { 240 }

/// Latin small letter n with tilde character.
public macro fun n_tilde(): u8 { 241 }

/// Latin small letter o with grave character.
public macro fun o_grave(): u8 { 242 }

/// Latin small letter o with acute character.
public macro fun o_acute(): u8 { 243 }

/// Latin small letter o with circumflex character.
public macro fun o_circumflex(): u8 { 244 }

/// Latin small letter o with tilde character.
public macro fun o_tilde(): u8 { 245 }

/// Latin small letter o with diaeresis character.
public macro fun o_diaeresis(): u8 { 246 }

/// Division sign character.
public macro fun division(): u8 { 247 }

/// Latin small letter o with stroke character.
public macro fun o_stroke(): u8 { 248 }

/// Latin small letter u with grave character.
public macro fun u_grave(): u8 { 249 }

/// Latin small letter u with acute character.
public macro fun u_acute(): u8 { 250 }

/// Latin small letter u with circumflex character.
public macro fun u_circumflex(): u8 { 251 }

/// Latin small letter u with diaeresis character.
public macro fun u_diaeresis(): u8 { 252 }

/// Latin small letter y with acute character.
public macro fun y_acute(): u8 { 253 }

/// Latin small letter thorn character.
public macro fun thorn(): u8 { 254 }

/// Latin small letter y with diaeresis character.
public macro fun y_diaeresis(): u8 { 255 }
