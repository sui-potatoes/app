# ASCII

This package provides a set of utilities and 0-cost macros to work with ASCII
strings in a more explicit way, providing higher readability and sturdiness of
code. See the [Table](#table) section for the full reference.

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
mvr add @potatoes/ascii
```

### Manual

To add this library to your project, add this to your `Move.toml` file under
`[dependencies]` section:

```toml
# goes into [dependencies] section
Date = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/ascii", rev = "ascii@v1" }
```

Exported address of this package is:

```toml
ascii = "0x..."
```

## Usage

In your code, import and use the package as:

```move
module my::awesome_project;

use ascii::ascii;
use ascii::char;
use ascii::control;
use ascii::extended;

public fun check_ascii(bytes: vector<u8>): bool {
    assert!(ascii::is_bytes_printable(&bytes));
    assert!(bytes.all!(|c| char::is_printable!(*c)));

    let space_symbol = char::space!();
    let null = control::null!();
    let cent = extended::cent!();
}
```

See the [Table](#table) section below for calls.

## General Principles

This package is split into 4 modules:

-   `ascii::ascii` - provides general ASCII utilities
-   `ascii::char` - contains printable characters table and checks
-   `ascii::control` - contains control characters table and checks
-   `ascii::extended` - contains extended characters table and checks

## Table

### Control

-   defined in module `ascii::control`
-   supports checks:
    -   `control::is_control!(char: u8): bool`

| Character | Dec | Hex  | Macro                                   |
| --------- | --- | ---- | --------------------------------------- |
| NUL       | 0   | 0x00 | `control::null!()`                      |
| SOH       | 1   | 0x01 | `control::start_of_heading!()`          |
| STX       | 2   | 0x02 | `control::start_of_text!()`             |
| ETX       | 3   | 0x03 | `control::end_of_text!()`               |
| EOT       | 4   | 0x04 | `control::end_of_transmission!()`       |
| ENQ       | 5   | 0x05 | `control::enquiry!()`                   |
| ACK       | 6   | 0x06 | `control::acknowledge!()`               |
| BEL       | 7   | 0x07 | `control::bell!()`                      |
| BS        | 8   | 0x08 | `control::backspace!()`                 |
| HT        | 9   | 0x09 | `control::horizontal_tab!()`            |
| LF        | 10  | 0x0A | `control::line_feed!()`                 |
| VT        | 11  | 0x0B | `control::vertical_tab!()`              |
| FF        | 12  | 0x0C | `control::form_feed!()`                 |
| CR        | 13  | 0x0D | `control::carriage_return!()`           |
| SO        | 14  | 0x0E | `control::shift_out!()`                 |
| SI        | 15  | 0x0F | `control::shift_in!()`                  |
| DLE       | 16  | 0x10 | `control::data_link_escape!()`          |
| DC1       | 17  | 0x11 | `control::device_control_1!()`          |
| DC2       | 18  | 0x12 | `control::device_control_2!()`          |
| DC3       | 19  | 0x13 | `control::device_control_3!()`          |
| DC4       | 20  | 0x14 | `control::device_control_4!()`          |
| NAK       | 21  | 0x15 | `control::negative_acknowledge!()`      |
| SYN       | 22  | 0x16 | `control::synchronous_idle!()`          |
| ETB       | 23  | 0x17 | `control::end_of_transmission_block!()` |
| CAN       | 24  | 0x18 | `control::cancel!()`                    |
| EM        | 25  | 0x19 | `control::end_of_medium!()`             |
| SUB       | 26  | 0x1A | `control::substitute!()`                |
| ESC       | 27  | 0x1B | `control::escape!()`                    |
| FS        | 28  | 0x1C | `control::file_separator!()`            |
| GS        | 29  | 0x1D | `control::group_separator!()`           |
| RS        | 30  | 0x1E | `control::record_separator!()`          |
| US        | 31  | 0x1F | `control::unit_separator!()`            |
| DEL       | 127 | 0xF  | `control::delete!()                     |

### Printable

-   defined in module `ascii::char`
-   supports checks:
    -   `char::is_printable!(char: u8): bool`
    -   `char::is_digit!(char: u8): bool`
    -   `char::is_letter!(char: u8): bool`
    -   `char::is_lowercase!(char: u8): bool`
    -   `char::is_uppercase!(char: u8): bool`
    -   `char::is_alphanumeric!(char: u8): bool`

| Character | Dec | Hex  | Macro                       |
| --------- | --- | ---- | --------------------------- |
| (space)   | 32  | 0x20 | `char::space!()`            |
| !         | 33  | 0x21 | `char::exclamation_mark!()` |
| "         | 34  | 0x22 | `char::double_quote!()`     |
| #         | 35  | 0x23 | `char::hash!()`             |
| $         | 36  | 0x24 | `char::dollar!()`           |
| %         | 37  | 0x25 | `char::percent!()`          |
| &         | 38  | 0x26 | `char::ampersand!()`        |
| '         | 39  | 0x27 | `char::single_quote!()`     |
| (         | 40  | 0x28 | `char::left_paren!()`       |
| )         | 41  | 0x29 | `char::right_paren!()`      |
| \*        | 42  | 0x2A | `char::asterisk!()`         |
| +         | 43  | 0x2B | `char::plus!()`             |
| ,         | 44  | 0x2C | `char::comma!()`            |
| -         | 45  | 0x2D | `char::minus!()`            |
| .         | 46  | 0x2E | `char::period!()`           |
| /         | 47  | 0x2F | `char::forward_slash!()`    |
| 0         | 48  | 0x30 | `char::zero!()`             |
| 1         | 49  | 0x31 | `char::one!()`              |
| 2         | 50  | 0x32 | `char::two!()`              |
| 3         | 51  | 0x33 | `char::three!()`            |
| 4         | 52  | 0x34 | `char::four!()`             |
| 5         | 53  | 0x35 | `char::five!()`             |
| 6         | 54  | 0x36 | `char::six!()`              |
| 7         | 55  | 0x37 | `char::seven!()`            |
| 8         | 56  | 0x38 | `char::eight!()`            |
| 9         | 57  | 0x39 | `char::nine!()`             |
| :         | 58  | 0x3A | `char::colon!()`            |
| ;         | 59  | 0x3B | `char::semicolon!()`        |
| <         | 60  | 0x3C | `char::less_than!()`        |
| =         | 61  | 0x3D | `char::equals!()`           |
| >         | 62  | 0x3E | `char::greater_than!()`     |
| ?         | 63  | 0x3F | `char::question_mark!()`    |
| @         | 64  | 0x40 | `char::at_sign!()`          |
| A         | 65  | 0x41 | `char::A!()`                |
| B         | 66  | 0x42 | `char::B!()`                |
| C         | 67  | 0x43 | `char::C!()`                |
| D         | 68  | 0x44 | `char::D!()`                |
| E         | 69  | 0x45 | `char::E!()`                |
| F         | 70  | 0x46 | `char::F!()`                |
| G         | 71  | 0x47 | `char::G!()`                |
| H         | 72  | 0x48 | `char::H!()`                |
| I         | 73  | 0x49 | `char::I!()`                |
| J         | 74  | 0x4A | `char::J!()`                |
| K         | 75  | 0x4B | `char::K!()`                |
| L         | 76  | 0x4C | `char::L!()`                |
| M         | 77  | 0x4D | `char::M!()`                |
| N         | 78  | 0x4E | `char::N!()`                |
| O         | 79  | 0x4F | `char::O!()`                |
| P         | 80  | 0x50 | `char::P!()`                |
| Q         | 81  | 0x51 | `char::Q!()`                |
| R         | 82  | 0x52 | `char::R!()`                |
| S         | 83  | 0x53 | `char::S!()`                |
| T         | 84  | 0x54 | `char::T!()`                |
| U         | 85  | 0x55 | `char::U!()`                |
| V         | 86  | 0x56 | `char::V!()`                |
| W         | 87  | 0x57 | `char::W!()`                |
| X         | 88  | 0x58 | `char::X!()`                |
| Y         | 89  | 0x59 | `char::Y!()`                |
| Z         | 90  | 0x5A | `char::Z!()`                |
| [         | 91  | 0x5B | `char::left_bracket!()`     |
| \         | 92  | 0x5C | `char::backslash!()`        |
| ]         | 93  | 0x5D | `char::right_bracket!()`    |
| ^         | 94  | 0x5E | `char::caret!()`            |
| \_        | 95  | 0x5F | `char::underscore!()`       |
| `         | 96  | 0x60 | `char::backtick!()`         |
| a         | 97  | 0x61 | `char::a!()`                |
| b         | 98  | 0x62 | `char::b!()`                |
| c         | 99  | 0x63 | `char::c!()`                |
| d         | 100 | 0x64 | `char::d!()`                |
| e         | 101 | 0x65 | `char::e!()`                |
| f         | 102 | 0x66 | `char::f!()`                |
| g         | 103 | 0x67 | `char::g!()`                |
| h         | 104 | 0x68 | `char::h!()`                |
| i         | 105 | 0x69 | `char::i!()`                |
| j         | 106 | 0x6A | `char::j!()`                |
| k         | 107 | 0x6B | `char::k!()`                |
| l         | 108 | 0x6C | `char::l!()`                |
| m         | 109 | 0x6D | `char::m!()`                |
| n         | 110 | 0x6E | `char::n!()`                |
| o         | 111 | 0x6F | `char::o!()`                |
| p         | 112 | 0x70 | `char::p!()`                |
| q         | 113 | 0x71 | `char::q!()`                |
| r         | 114 | 0x72 | `char::r!()`                |
| s         | 115 | 0x73 | `char::s!()`                |
| t         | 116 | 0x74 | `char::t!()`                |
| u         | 117 | 0x75 | `char::u!()`                |
| v         | 118 | 0x76 | `char::v!()`                |
| w         | 119 | 0x77 | `char::w!()`                |
| x         | 120 | 0x78 | `char::x!()`                |
| y         | 121 | 0x79 | `char::y!()`                |
| z         | 122 | 0x7A | `char::z!()`                |
| \{        | 123 | 0x7B | `char::left_brace!()`       |
| \|        | 124 | 0x7C | `char::vertical_bar!()`     |
| \}        | 125 | 0x7D | `char::right_brace!()`      |
| ~         | 126 | 0x7E | `char::tilde!()`            |

### Extended ASCII Set

-   defined in module `ascii::extended`
-   supports checks:
    -   `extended::is_extended!(char: u8): bool`

| Character | Dec | Hex  | Macro                                   |
| --------- | --- | ---- | --------------------------------------- |
| €         | 128 | 0x80 | `extended::euro_sign!()`                |
| ∅         | 129 | 0x81 | `extended::not_used_129!()`             |
| ‚         | 130 | 0x82 | `extended::single_low_quote!()`         |
| ƒ         | 131 | 0x83 | `extended::function!()`                 |
| „         | 132 | 0x84 | `extended::double_low_quote!()`         |
| …         | 133 | 0x85 | `extended::ellipsis!()`                 |
| †         | 134 | 0x86 | `extended::dagger!()`                   |
| ‡         | 135 | 0x87 | `extended::double_dagger!()`            |
| ˆ         | 136 | 0x88 | `extended::circumflex!()`               |
| ‰         | 137 | 0x89 | `extended::per_mille!()`                |
| Š         | 138 | 0x8A | `extended::S_caron!()`                  |
| ‹         | 139 | 0x8B | `extended::single_left_angle_quote!()`  |
| Œ         | 140 | 0x8C | `extended::OE!()`                       |
| ∅         | 141 | 0x8D | `extended::not_used_141!()`             |
| Ž         | 142 | 0x8E | `extended::Z_caron!()`                  |
| ∅         | 143 | 0x8F | `extended::not_used_143!()`             |
| ∅         | 144 | 0x90 | `extended::not_used_144!()`             |
| '         | 145 | 0x91 | `extended::left_single_quote!()`        |
| '         | 146 | 0x92 | `extended::right_single_quote!()`       |
| "         | 147 | 0x93 | `extended::left_double_quote!()`        |
| "         | 148 | 0x94 | `extended::right_double_quote!()`       |
| •         | 149 | 0x95 | `extended::bullet!()`                   |
| –         | 150 | 0x96 | `extended::en_dash!()`                  |
| —         | 151 | 0x97 | `extended::em_dash!()`                  |
| ˜         | 152 | 0x98 | `extended::small_tilde!()`              |
| ™         | 153 | 0x99 | `extended::trademark!()`                |
| š         | 154 | 0x9A | `extended::s_caron!()`                  |
| ›         | 155 | 0x9B | `extended::single_right_angle_quote!()` |
| œ         | 156 | 0x9C | `extended::oe!()`                       |
| ∅         | 157 | 0x9D | `extended::not_used_157!()`             |
| ž         | 158 | 0x9E | `extended::z_caron!()`                  |
| Ÿ         | 159 | 0x9F | `extended::Y_diaeresis!()`              |
| ∅         | 160 | 0xA0 | `extended::non_breaking_space!()`       |
| ¡         | 161 | 0xA1 | `extended::inverted_exclamation!()`     |
| ¢         | 162 | 0xA2 | `extended::cent!()`                     |
| £         | 163 | 0xA3 | `extended::pound!()`                    |
| ¤         | 164 | 0xA4 | `extended::currency!()`                 |
| ¥         | 165 | 0xA5 | `extended::yen!()`                      |
| ¦         | 166 | 0xA6 | `extended::broken_bar!()`               |
| §         | 167 | 0xA7 | `extended::section!()`                  |
| ¨         | 168 | 0xA8 | `extended::diaeresis!()`                |
| ©         | 169 | 0xA9 | `extended::copyright!()`                |
| ª         | 170 | 0xAA | `extended::feminine_ordinal!()`         |
| «         | 171 | 0xAB | `extended::left_angle_quote!()`         |
| ¬         | 172 | 0xAC | `extended::not!()`                      |
| ­         | 173 | 0xAD | `extended::soft_hyphen!()`              |
| ®         | 174 | 0xAE | `extended::registered!()`               |
| ¯         | 175 | 0xAF | `extended::macron!()`                   |
| °         | 176 | 0xB0 | `extended::degree!()`                   |
| ±         | 177 | 0xB1 | `extended::plus_minus!()`               |
| ²         | 178 | 0xB2 | `extended::superscript_2!()`            |
| ³         | 179 | 0xB3 | `extended::superscript_3!()`            |
| ´         | 180 | 0xB4 | `extended::acute!()`                    |
| µ         | 181 | 0xB5 | `extended::micro!()`                    |
| ¶         | 182 | 0xB6 | `extended::pilcrow!()`                  |
| ·         | 183 | 0xB7 | `extended::middle_dot!()`               |
| ¸         | 184 | 0xB8 | `extended::cedilla!()`                  |
| ¹         | 185 | 0xB9 | `extended::superscript_1!()`            |
| º         | 186 | 0xBA | `extended::masculine_ordinal!()`        |
| »         | 187 | 0xBB | `extended::right_angle_quote!()`        |
| ¼         | 188 | 0xBC | `extended::one_quarter!()`              |
| ½         | 189 | 0xBD | `extended::one_half!()`                 |
| ¾         | 190 | 0xBE | `extended::three_quarters!()`           |
| ¿         | 191 | 0xBF | `extended::inverted_question!()`        |
| À         | 192 | 0xC0 | `extended::A_grave!()`                  |
| Á         | 193 | 0xC1 | `extended::A_acute!()`                  |
| Â         | 194 | 0xC2 | `extended::A_circumflex!()`             |
| Ã         | 195 | 0xC3 | `extended::A_tilde!()`                  |
| Ä         | 196 | 0xC4 | `extended::A_diaeresis!()`              |
| Å         | 197 | 0xC5 | `extended::A_ring!()`                   |
| Æ         | 198 | 0xC6 | `extended::AE!()`                       |
| Ç         | 199 | 0xC7 | `extended::C_cedilla!()`                |
| È         | 200 | 0xC8 | `extended::E_grave!()`                  |
| É         | 201 | 0xC9 | `extended::E_acute!()`                  |
| Ê         | 202 | 0xCA | `extended::E_circumflex!()`             |
| Ë         | 203 | 0xCB | `extended::E_diaeresis!()`              |
| Ì         | 204 | 0xCC | `extended::I_grave!()`                  |
| Í         | 205 | 0xCD | `extended::I_acute!()`                  |
| Î         | 206 | 0xCE | `extended::I_circumflex!()`             |
| Ï         | 207 | 0xCF | `extended::I_diaeresis!()`              |
| Ð         | 208 | 0xD0 | `extended::ETH!()`                      |
| Ñ         | 209 | 0xD1 | `extended::N_tilde!()`                  |
| Ò         | 210 | 0xD2 | `extended::O_grave!()`                  |
| Ó         | 211 | 0xD3 | `extended::O_acute!()`                  |
| Ô         | 212 | 0xD4 | `extended::O_circumflex!()`             |
| Õ         | 213 | 0xD5 | `extended::O_tilde!()`                  |
| Ö         | 214 | 0xD6 | `extended::O_diaeresis!()`              |
| ×         | 215 | 0xD7 | `extended::multiplication!()`           |
| Ø         | 216 | 0xD8 | `extended::O_stroke!()`                 |
| Ù         | 217 | 0xD9 | `extended::U_grave!()`                  |
| Ú         | 218 | 0xDA | `extended::U_acute!()`                  |
| Û         | 219 | 0xDB | `extended::U_circumflex!()`             |
| Ü         | 220 | 0xDC | `extended::U_diaeresis!()`              |
| Ý         | 221 | 0xDD | `extended::Y_acute!()`                  |
| Þ         | 222 | 0xDE | `extended::THORN!()`                    |
| ß         | 223 | 0xDF | `extended::sharp_s!()`                  |
| à         | 224 | 0xE0 | `extended::a_grave!()`                  |
| á         | 225 | 0xE1 | `extended::a_acute!()`                  |
| â         | 226 | 0xE2 | `extended::a_circumflex!()`             |
| ã         | 227 | 0xE3 | `extended::a_tilde!()`                  |
| ä         | 228 | 0xE4 | `extended::a_diaeresis!()`              |
| å         | 229 | 0xE5 | `extended::a_ring!()`                   |
| æ         | 230 | 0xE6 | `extended::ae!()`                       |
| ç         | 231 | 0xE7 | `extended::c_cedilla!()`                |
| è         | 232 | 0xE8 | `extended::e_grave!()`                  |
| é         | 233 | 0xE9 | `extended::e_acute!()`                  |
| ê         | 234 | 0xEA | `extended::e_circumflex!()`             |
| ë         | 235 | 0xEB | `extended::e_diaeresis!()`              |
| ì         | 236 | 0xEC | `extended::i_grave!()`                  |
| í         | 237 | 0xED | `extended::i_acute!()`                  |
| î         | 238 | 0xEE | `extended::i_circumflex!()`             |
| ï         | 239 | 0xEF | `extended::i_diaeresis!()`              |
| ð         | 240 | 0xF0 | `extended::eth!()`                      |
| ñ         | 241 | 0xF1 | `extended::n_tilde!()`                  |
| ò         | 242 | 0xF2 | `extended::o_grave!()`                  |
| ó         | 243 | 0xF3 | `extended::o_acute!()`                  |
| ô         | 244 | 0xF4 | `extended::o_circumflex!()`             |
| õ         | 245 | 0xF5 | `extended::o_tilde!()`                  |
| ö         | 246 | 0xF6 | `extended::o_diaeresis!()`              |
| ÷         | 247 | 0xF7 | `extended::division!()`                 |
| ø         | 248 | 0xF8 | `extended::o_stroke!()`                 |
| ù         | 249 | 0xF9 | `extended::u_grave!()`                  |
| ú         | 250 | 0xFA | `extended::u_acute!()`                  |
| û         | 251 | 0xFB | `extended::u_circumflex!()`             |
| ü         | 252 | 0xFC | `extended::u_diaeresis!()`              |
| ý         | 253 | 0xFD | `extended::y_acute!()`                  |
| þ         | 254 | 0xFE | `extended::thorn!()`                    |
| ÿ         | 255 | 0xFF | `extended::y_diaeresis!()`              |

## License

This package is licensed under MIT.
