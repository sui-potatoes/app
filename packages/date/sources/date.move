// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implementation of the Date type and related functions in Move.
///
/// Supports:
/// - ISO 8601
/// - RFC 7231 (HTTP-date format)
/// - Date / Time formatting
///
/// Does not support:
/// - IANA Timezone names
/// - Timezone Offsets (ISO 8601)
///
/// Formatting:
/// - `yyyy` or `YYYY` - The year number in four digits. For example, in this format, 2005 would be represented as 2005.
/// - `yy` or `YY` - The last two digits of the year number. For example, in this format, 2005 would be represented as 05.
/// - `y` - The last digit of the year. For example, 2005 would be represented as 5.
/// - `MMMM` - The name of the month spelled in full. This format is supported only for output time. Note: This format is only supported for the output format.
/// - `MMM` - The name of the month in three letters. For example, August would be represented as Aug.
/// - `MM` - Month in two digits. If the month number is a single-digit number, it's displayed with a leading zero.
/// - `M` - Month as a number from 1 to 12. If the month number is a single-digit number, it's displayed without a leading zero.
/// - `dddd` or `DDDD` - The full name of the day of the week. For example, Saturday is displayed in full. Note: This format is only supported for the output format.
/// - `ddd` or `DDD` - The abbreviated name of the day of the week in three letters. For example, Saturday is abbreviated as “Sat”.
/// - `dd` or `DD` - Day in two digits. If the day number is a single-digit number, it's displayed with a leading zero.
/// - `d` or `D` - Day as a number from 1 to 31. If the day number is a single-digit number, it's displayed without a leading zero.
/// - `HH` - Hour in two digits using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed with a leading zero.
/// - `H` - Hour as a number from 0 to 23 when using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed without a leading zero.
/// - `hh` - Hour in two digits using the 12-hour clock. For example, in this format, 1 pm would be represented as 01. If the hour number is a single-digit number, it's displayed with a leading zero.
/// - `h` - Hour as a number from 1 to 12 when using the 12-hour clock. If the hour number is a single-digit number, it's displayed without a leading zero.
/// - `mm` - Minutes in two digits. If the minute number is a single-digit number, it's displayed with a leading zero.
/// - `m` - Minutes as a number from 0 to 59. If the minute number is a single-digit number, it's displayed without a leading zero.
/// - `ss` - Seconds in two digits. If the second number is a single-digit number, it's displayed with a leading zero.
/// - `s` - Seconds as a number from 0 to 59. If the second number is a single-digit number, it's displayed without a leading zero.
/// - `tt` - A.M. or P.M. as two letters: AM or PM.
///
/// Resources:
/// - ISO 8601: https://en.wikipedia.org/wiki/ISO_8601
/// - RFC 7231 (HTTP-date format: https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.1.1)
module date::date;

use ascii::char;
use std::{macros::num_to_string, string::String};
use sui::clock::Clock;

const EInvalidMonth: u64 = 0;
const EInvalidDay: u64 = 1;
const EExpectedComma: u64 = 2;
const EExpectedSpace: u64 = 3;
const EExpectedColon: u64 = 4;
const EExpectedTimezone: u64 = 5;
const EInvalidFormat: u64 = 6;
const EExpectedTT: u64 = 7;

/// The days of the week.
const DAYS: vector<vector<u8>> = vector[b"Sun", b"Mon", b"Tue", b"Wed", b"Thu", b"Fri", b"Sat"];

/// The full names of the days of the week.
const DAYS_FULL: vector<vector<u8>> = vector[
    b"Sunday",
    b"Monday",
    b"Tuesday",
    b"Wednesday",
    b"Thursday",
    b"Friday",
    b"Saturday",
];

/// The number of days in each month.
const DAYS_IN_MONTH: vector<u64> = vector[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

// prettier-ignore
/// The months of the year.
const MONTHS: vector<vector<u8>> = vector[
    b"Jan", b"Feb", b"Mar", b"Apr", b"May", b"Jun",
    b"Jul", b"Aug", b"Sep", b"Oct", b"Nov", b"Dec",
];

/// The full names of the months of the year.
const MONTH_NAMES: vector<vector<u8>> = vector[
    b"January",
    b"February",
    b"March",
    b"April",
    b"May",
    b"June",
    b"July",
    b"August",
    b"September",
    b"October",
    b"November",
    b"December",
];

// === ASCII Symbols ===

/// Capital: Y
const Y: u8 = 89;
/// Capital: Z
const Z: u8 = 90;
/// Capital: YY
const YY: u8 = 121;
/// Capital: M
const M: u8 = 77;
/// Capital: D
const D: u8 = 68;
/// Small: d
const DD: u8 = 100;
/// Capital: H
const H: u8 = 72;
/// Small: h
const HH: u8 = 104;
/// Small: m
const MM: u8 = 109;
/// Small: s
const SS: u8 = 115;
/// Small: t
const TT: u8 = 116;
/// Single quote. Used to escape text in the formatted string.
const SINGLE_QUOTE: u8 = 39;

/// A struct representing a date.
public struct Date has copy, drop, store {
    /// The year of the date.
    year: u16,
    /// The month of the date.
    month: u8,
    /// The day of the date.
    day: u8,
    /// The day of the week.
    day_of_week: u8,
    /// The hour of the date.
    hour: u8,
    /// The minute of the date.
    minute: u8,
    /// The second of the date.
    second: u8,
    /// The milliseconds of the date.
    millisecond: u16,
    /// The offset of a timezone in minutes, with 720 being UTC.
    timezone_offset_m: u16,
    /// The timestamp in milliseconds.
    timestamp_ms: u64,
}

/// Create a new `Date` from a timestamp in milliseconds.
public fun new(timestamp_ms: u64): Date {
    let seconds = timestamp_ms / 1000;
    let mut remaining = seconds;

    // == Time of day ==
    let second = remaining % 60;
    remaining = remaining / 60;
    let minute = remaining % 60;
    remaining = remaining / 60;
    let hour = remaining % 24;

    // == Days since epoch ==
    let mut days = seconds / 86400;
    let mut year = 1970u16;

    // == Leap year ==
    loop {
        let days_in_year = if (is_leap_year!(year)) 366 else 365;
        if (days < days_in_year) break
        else {
            year = year + 1;
            days = days - days_in_year;
        };
    };

    // == Month and day ==
    let mut month = 0;
    let days_in_month = DAYS_IN_MONTH;

    loop {
        let days_in_month = if (is_leap_year!(year) && month == 1) {
            29
        } else {
            days_in_month[month]
        };

        if (days < days_in_month) break
        else {
            month = month + 1;
            days = days - days_in_month;
        };
    };

    Date {
        year,
        month: month as u8,
        day: (days + 1) as u8,
        day_of_week: ((seconds / 86400 + 4) % 7) as u8,
        hour: hour as u8,
        minute: minute as u8,
        second: second as u8,
        millisecond: (timestamp_ms % 1000) as u16,
        timezone_offset_m: 720, // UTC by default
        timestamp_ms,
    }
}

/// Create a new `Date` from a `Clock`.
public fun from_clock(clock: &Clock): Date {
    new(clock.timestamp_ms())
}

/// Create a new `Date` from a UTC String (RFC 1123).
/// See HTTP-date format: https://www.rfc-editor.org/rfc/rfc7231#section-7.1.1.1
///
/// According to the RFC 1123, the UTC string is in the format of:
/// `ddd, DD MMM YYYY HH:MM:SS GMT`
///
/// Where:
/// - `ddd` is the day of the week in three letters.
/// - `DD` is the day of the month in two digits.
/// - `MMM` is the month in three letters.
/// - `YYYY` is the year in four digits.
///
/// Aborts if:
/// - The UTC string is not in the correct format.
/// - Incorrect values are used for month or day of the week.
public fun from_utc_string(utc: String): Date {
    let days = DAYS;
    let months = MONTHS;
    let days_in_month = DAYS_IN_MONTH;
    let mut utc = utc.into_bytes();

    assert!(utc.length() == 29, EInvalidFormat);

    utc.reverse();

    // First 3 elements are the day of the week.
    let day_of_week = vector::tabulate!(3, |_| utc.pop_back());
    let day_of_week = days.find_index!(|d| d == &day_of_week).destroy_or!(abort EInvalidDay) as u8;
    assert!(utc.pop_back() == char::comma!(), EExpectedComma); // comma in ascii is 44
    assert!(utc.pop_back() == char::space!(), EExpectedSpace); // space in ascii is 32

    let day = parse_u16!(vector::tabulate!(2, |_| utc.pop_back())) as u8;
    assert!(utc.pop_back() == char::space!(), EExpectedSpace); // space in ascii is 32

    let month = vector::tabulate!(3, |_| utc.pop_back());
    let month = months.find_index!(|m| m == &month).destroy_or!(abort EInvalidMonth) as u8;
    assert!(utc.pop_back() == char::space!(), EExpectedSpace); // space in ascii is 32

    let year = parse_u16!(vector::tabulate!(4, |_| utc.pop_back()));
    assert!(utc.pop_back() == char::space!(), EExpectedSpace); // space in ascii is 32

    let hour = parse_u16!(vector::tabulate!(2, |_| utc.pop_back())) as u8;
    assert!(utc.pop_back() == char::colon!(), EExpectedColon);

    let minute = parse_u16!(vector::tabulate!(2, |_| utc.pop_back())) as u8;
    assert!(utc.pop_back() == char::colon!(), EExpectedColon);

    let second = parse_u16!(vector::tabulate!(2, |_| utc.pop_back())) as u8;
    assert!(utc.pop_back() == char::space!(), EExpectedSpace); // space in ascii is 32

    let timezone = vector::tabulate!(3, |_| utc.pop_back());
    assert!(timezone == b"GMT", EExpectedTimezone);

    // Convert year/month/day/hour/minute/second to timestamp_ms.
    let mut days = 0;

    // Add days for each year since 1970.
    1970u16.range_do!(year, |y| {
        days = days + 365;
        // Add leap year day if applicable.
        if (is_leap_year!(y)) days = days + 1;
    });

    // Add days for each month.
    month.do!(|m| {
        days = days + days_in_month[m as u64];
        // Add leap year day in February if applicable
        if (m == 1 && is_leap_year!(year)) days = days + 1;
    });

    // Add remaining days
    days = days + (day as u64) - 1;

    // Convert to milliseconds
    let timestamp =
        days * 24 * 60 * 60 +
        (hour as u64) * 60 * 60 +
        (minute as u64) * 60 +
        (second as u64);

    Date {
        year,
        month,
        day,
        day_of_week,
        hour,
        minute,
        second,
        millisecond: 0,
        timezone_offset_m: 0,
        timestamp_ms: timestamp * 1000,
    }
}

/// Get the second of a `Date`.
public fun second(date: &Date): u8 { date.second }

/// Get the minute of a `Date`.
public fun minute(date: &Date): u8 { date.minute }

/// Get the hour of a `Date`.
public fun hour(date: &Date): u8 { date.hour }

/// Get the day of a `Date`.
public fun day(date: &Date): u8 { date.day }

/// Get the month of a `Date`.
public fun month(date: &Date): u8 { date.month }

/// Get the year of a `Date`.
public fun year(date: &Date): u16 { date.year }

/// Get the timestamp in milliseconds of a `Date`.
public fun timestamp_ms(date: &Date): u64 { date.timestamp_ms }

/// Print a `Date` in ISO 8601 format as a String.
///
/// Example:
/// ```rust
/// assert!(date.to_iso_string() == b"2025-05-22T15:39:27.000Z".to_string());
/// ```
///
/// See ISO 8601: https://en.wikipedia.org/wiki/ISO_8601
public fun to_iso_string(date: &Date): String {
    let mut date = *date;
    let offset = date.timezone_offset_m as u64;
    if (offset != 720) {
        if (offset > 720) {
            date.timestamp_ms = date.timestamp_ms + (offset - 720) * 60 * 1000;
            date = new(date.timestamp_ms);
            date.timezone_offset_m = offset as u16;
        } else {
            date.timestamp_ms = date.timestamp_ms - (720 - offset) * 60 * 1000;
            date = new(date.timestamp_ms);
            date.timezone_offset_m = offset as u16;
        }
    };

    let mut iso = vector[];
    iso.append(num_to_bytes!(date.year, false));
    iso.push_back(char::minus!());
    iso.append(num_to_bytes!(date.month + 1, true));
    iso.push_back(char::minus!());
    iso.append(num_to_bytes!(date.day, true));
    iso.push_back(char::T!());
    iso.append(num_to_bytes!(date.hour, true));
    iso.push_back(char::colon!());
    iso.append(num_to_bytes!(date.minute, true));
    iso.push_back(char::colon!());
    iso.append(num_to_bytes!(date.second, true));
    iso.push_back(char::period!());

    // extra 0 for milliseconds
    if (date.millisecond < 100) iso.push_back(char::zero!());
    iso.append(num_to_bytes!(date.millisecond, true));
    iso.append(to_timezone_offset_byte_string!(date.timezone_offset_m));
    iso.to_string()
}

/// Convert a `Date` to a UTC string.
/// See RFC 1123: https://www.rfc-editor.org/rfc/rfc7231#section-7.1.1.1
///
/// According to the RFC 1123, the UTC string is in the format of:
/// `ddd, DD MMM YYYY HH:MM:SS GMT`
///
/// Where:
/// - `DDD` is the day of the week in three letters.
/// - `DD` is the day of the month in two digits.
/// - `MMM` is the month in three letters.
///
/// Example:
/// ```rust
/// assert!(date.to_utc_string() == b"Fri, 16 May 2025 15:39:27 GMT".to_string());
/// ```
public fun to_utc_string(date: &Date): String {
    let months = MONTHS;
    let days = DAYS;
    let mut date_time = vector[];

    date_time.append(days[date.day_of_week as u64]);
    date_time.push_back(char::comma!());
    date_time.push_back(char::space!());
    date_time.append(num_to_bytes!(date.day, true));
    date_time.push_back(char::space!());
    date_time.append(months[date.month as u64]);
    date_time.push_back(char::space!());
    date_time.append(num_to_bytes!(date.year, false));
    date_time.push_back(char::space!());
    date_time.append(num_to_bytes!(date.hour, true));
    date_time.push_back(char::colon!());
    date_time.append(num_to_bytes!(date.minute, true));
    date_time.push_back(char::colon!());
    date_time.append(num_to_bytes!(date.second, true));
    date_time.append(b" GMT");
    date_time.to_string()
}

/// Format a `Date` to a string.
public fun format(date: &Date, format: vector<u8>): String {
    let months = MONTHS;
    let days = DAYS;
    let months_full = MONTH_NAMES;
    let days_full = DAYS_FULL;
    let mut formatted = vector[];
    let (mut i, len) = (0, format.length());

    while (i < len) {
        match (format[i]) {
            // Year: yyyy / yy / y
            // prettier-ignore
            y @ (Y | YY) => if (
                i + 3 < len && &format[i + 1] == &y && &format[i + 2] == &y && &format[i + 3] == &y
            ) {
                // The year number in four digits. For example, in this format, 2005 would be represented as 2005.
                formatted.append(num_to_bytes!(date.year, false));
                i = i + 3;
            } else if (i + 1 < len && format[i + 1] == y) {
                // The last two digits of the year number. For example, in this format, 2005 would be represented as 05.
                formatted.append(num_to_bytes!(date.year % 100, true));
                i = i + 1;
            } else {
                // The last digit of the year. For example, 2005 would be represented as 5.
                formatted.append(num_to_bytes!(date.year % 10, false));
            },
            // Month: MMMM / MMM / MM / M
            M => if (
                i + 3 < len && format[i + 1] == M && format[i + 2] == M && format[i + 3] == M
            ) {
                // The name of the month spelled in full. This format is supported only for output time. Note: This format is only supported for the output format.
                formatted.append(months_full[date.month as u64]);
                i = i + 3;
            } else if (i + 2 < len && format[i + 1] == M && format[i + 2] == M) {
                // The name of the month in three letters. For example, August would be represented as Aug.
                formatted.append(months[date.month as u64]);
                i = i + 2;
            } else if (i + 1 < len && format[i + 1] == M) {
                // Month in two digits. If the month number is a single-digit number, it's displayed with a leading zero.
                formatted.append(num_to_bytes!(date.month + 1, true));
                i = i + 1;
            } else {
                // Month as a number from 1 to 12. If the month number is a single-digit number, it's displayed without a leading zero.
                formatted.append(num_to_bytes!(date.month + 1, false));
            },
            // Day: dddd / ddd / dd / d OR DDDD / DDD / DD / D
            // prettier-ignore
            d @ (D | DD) => if (
                i + 3 < len && &format[i + 1] == &d && &format[i + 2] == &d && &format[i + 3] == &d
            ) {
                // The full name of the day of the week. For example, Saturday is displayed in full. Note: This format is only supported for the output format.
                formatted.append(days_full[date.day_of_week as u64]);
                i = i + 3;
            } else if (i + 2 < len && format[i + 1] == d && format[i + 2] == d) {
                // The abbreviated name of the day of the week in three letters. For example, Saturday is abbreviated as “Sat”.
                formatted.append(days[date.day_of_week as u64]);
                i = i + 2;
            } else if (i + 1 < len && format[i + 1] == d) {
                // Day in two digits. If the day number is a single-digit number, it's displayed with a leading zero.
                formatted.append(num_to_bytes!(date.day, true));
                i = i + 1;
            } else {
                // Day as a number from 1 to 31. If the day number is a single-digit number, it's displayed without a leading zero.
                formatted.append(num_to_bytes!(date.day, false));
            },
            // Hour: HH / H
            H => if (i + 1 < len && format[i + 1] == H) {
                // Hour in two digits using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed with a leading zero.
                formatted.append(num_to_bytes!(date.hour, true));
                i = i + 1;
            } else {
                // Hour as a number from 0 to 23 when using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed without a leading zero.
                formatted.append(num_to_bytes!(date.hour, false));
            },
            // Hour: hh / h
            HH => if (i + 1 < len && format[i + 1] == HH) {
                // Hour in two digits using the 12-hour clock. For example, in this format, 1 pm would be represented as 01. If the hour number is a single-digit number, it's displayed with a leading zero.
                let hour = if (date.hour == 0) 12 else date.hour % 12;
                formatted.append(num_to_bytes!(hour, true));
                i = i + 1;
            } else {
                // Hour as a number from 1 to 12 when using the 12-hour clock. If the hour number is a single-digit number, it's displayed without a leading zero.
                let hour = if (date.hour == 0) 12 else date.hour % 12;
                formatted.append(num_to_bytes!(hour, false));
            },
            // Minute: m
            MM => if (i + 1 < len && format[i + 1] == MM) {
                // Minutes in two digits. If the minute number is a single-digit number, it's displayed with a leading zero.
                formatted.append(num_to_bytes!(date.minute, true));
                i = i + 1;
            } else {
                // Minutes as a number from 0 to 59. If the minute number is a single-digit number, it's displayed without a leading zero.
                formatted.append(num_to_bytes!(date.minute, false));
            },
            // Second: s
            SS => if (i + 1 < len && format[i + 1] == SS) {
                // Seconds in two digits. If the second number is a single-digit number, it's displayed with a leading zero.
                formatted.append(num_to_bytes!(date.second, true));
                i = i + 1;
            } else {
                // Seconds as a number from 0 to 59. If the second number is a single-digit number, it's displayed without a leading zero.
                formatted.append(num_to_bytes!(date.second, false));
            },
            // TT: AM/PM
            TT => if (i + 1 < len && format[i + 1] == TT) {
                // A.M. or P.M. as two letters: AM or PM.
                formatted.append(if (date.hour < 12) b"AM" else b"PM");
                i = i + 1;
            } else abort EExpectedTT,
            // Z: for ISO 8601
            Z if (date.timezone_offset_m != 720) => {
                formatted.append(to_timezone_offset_byte_string!(date.timezone_offset_m));
            },
            // Single quote. Used to escape text in the formatted string.
            // Once seen, scan next characters until another single quote is seen.
            SINGLE_QUOTE => 'search: {
                let mut agg = vector[];
                (i + 1).range_do!(len, |j| {
                    if (format[j] == SINGLE_QUOTE) {
                        i = j;
                        formatted.append(agg);
                        return 'search
                    };
                    agg.push_back(format[j]);
                });
            },
            _ => formatted.append(vector[format[i]]),
        };
        i = i + 1;
    };

    formatted.to_string()
}

// === Macros ===

/// Convert a `u16` number to a `vector<u8>`.
macro fun num_to_bytes($num: _, $pad: bool): vector<u8> {
    let num = $num as u16;
    let zero = char::zero!() as u16;

    if (num < 10) {
        if ($pad) vector[zero as u8, (num + zero) as u8] else vector[(num + zero) as u8]
    } else if (num < 100) {
        vector[(num / 10 + zero) as u8, (num % 10 + zero) as u8]
    } else if (num < 1000) {
        vector[(num / 100 + zero) as u8, (num / 10 % 10 + zero) as u8, (num % 10 + zero) as u8]
    } else {
        vector[
            (num / 1000 + zero) as u8,
            (num / 100 % 10 + zero) as u8,
            (num / 10 % 10 + zero) as u8,
            (num % 10 + zero) as u8,
        ]
    }
}

/// Convert a timezone offset in minutes to a string.
/// Currently not used due to lack of timezone support.
macro fun to_timezone_offset_byte_string($offset_m: u16): vector<u8> {
    if ($offset_m == 720) {
        return b"Z"
    };

    let mut res = vector[];
    let (hours, minutes) = if ($offset_m > 720) {
        // East
        res.push_back(char::plus!()); // + sign ASCII: 43
        let hours = ($offset_m - 720) / 60;
        let minutes = ($offset_m - 720) % 60;
        (hours, minutes)
    } else {
        // West
        res.push_back(char::minus!()); // - sign ASCII: 45
        let hours = (720 - $offset_m) / 60;
        let minutes = (720 - $offset_m) % 60;
        (hours, minutes)
    };

    res.append(num_to_bytes!(hours, true));
    res.push_back(char::colon!()); // : sign ASCII: 58
    res.append(num_to_bytes!(minutes, true));
    res
}

/// Check if a year is a leap year.
macro fun is_leap_year($year: u16): bool {
    ($year % 4 == 0 && $year % 100 != 0) || ($year % 400 == 0)
}

/// Parse `u16` from `vector<u8>`. This implementation is intentionally silly,
/// because we know that the max value is 4 digits.
macro fun parse_u16($bytes: vector<u8>): u16 {
    let mut bytes = $bytes;
    bytes.reverse();

    // Skip leading zeros.
    let (mut res, len) = (0u16, bytes.length());
    len.do!(
        |i| match (bytes.pop_back()) {
            n @ _ if (*n >= 48 && *n <= 57) => {
                res = res + (n as u16 - 48) * 10u16.pow(((len - 1) - i) as u8);
            },
            _ => abort,
        },
    );
    res
}

#[test]
fun test_parse_u16() {
    use std::unit_test::assert_eq;

    assert_eq!(parse_u16!(b"0"), 0);
    assert_eq!(parse_u16!(b"01"), 1);
    assert_eq!(parse_u16!(b"02"), 2);
    assert_eq!(parse_u16!(b"10"), 10);
    assert_eq!(parse_u16!(b"2015"), 2015);
    assert_eq!(parse_u16!(b"12"), 12);
    assert_eq!(parse_u16!(b"012"), 12);
}

#[test]
fun test_u16_to_bytes() {
    use std::unit_test::assert_eq;

    assert_eq!(num_to_bytes!(0, false), b"0");
    assert_eq!(num_to_bytes!(1, false), b"1");
    assert_eq!(num_to_bytes!(10, false), b"10");
    assert_eq!(num_to_bytes!(100, false), b"100");
    assert_eq!(num_to_bytes!(1000, false), b"1000");
    assert_eq!(num_to_bytes!(2010, false), b"2010");

    assert_eq!(num_to_bytes!(0, true), b"00");
    assert_eq!(num_to_bytes!(1, true), b"01");
    assert_eq!(num_to_bytes!(10, true), b"10");
    assert_eq!(num_to_bytes!(100, true), b"100");
    assert_eq!(num_to_bytes!(1000, true), b"1000");
    assert_eq!(num_to_bytes!(2010, true), b"2010");
}
