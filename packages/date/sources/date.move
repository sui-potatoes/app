// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: date
///
/// Supports:
/// - ISO 8601
/// - RFC 1123 (UTC string format)
/// - Date / Time formatting
/// - Timezone Offsets according to ISO 8601
///
/// Does not support:
/// - IANA Timezone names
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
/// - `tt` - A.M. or P.M. as two letters: A.M. or P.M. as defined on your system.
/// - `t` - TODO: consider failing here
///
/// Resources:
/// - ISO 8601: https://en.wikipedia.org/wiki/ISO_8601
/// - Microsoft Orchestrator: https://learn.microsoft.com/en-us/system-center/orchestrator/standard-activities/format-date-time?view=sc-orch-2025
module date::date;

use std::{macros::num_to_string, string::String};
use sui::clock::Clock;

const EInvalidMonth: u64 = 0;
const EInvalidDay: u64 = 1;

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
        let is_leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
        let days_in_year = if (is_leap) 366 else 365;

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
        let is_leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
        let days_in_month = if (is_leap && month == 1) 29 else days_in_month[month];

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

/// Create a new `Date` from a UTC string.
/// According to the RFC 1123, the UTC string is in the format of:
/// `ddd, DD MMM YYYY HH:MM:SS GMT`
///
/// Where:
/// - `ddd` is the day of the week in three letters.
/// - `DD` is the day of the month in two digits.
/// - `MMM` is the month in three letters.
/// - `YYYY` is the year in four digits.
public fun from_utc_string(utc: String): Date {
    let days = DAYS;
    let months = MONTHS;
    let mut utc = utc.into_bytes();
    utc.reverse();

    // First 3 elements are the day of the week.
    let day_of_week = vector::tabulate!(3, |_| utc.pop_back());
    let day_of_week = days.find_index!(|d| d == &day_of_week).destroy_or!(abort EInvalidDay) as u8;
    assert!(utc.pop_back() == 44); // comma in ascii is 44
    assert!(utc.pop_back() == 32); // space in ascii is 32

    let day = vector::tabulate!(2, |_| utc.pop_back());
    assert!(utc.pop_back() == 32); // space in ascii is 32

    let month = vector::tabulate!(3, |_| utc.pop_back());
    let month = months.find_index!(|m| m == &month).destroy_or!(abort EInvalidMonth) as u8;
    assert!(utc.pop_back() == 32); // space in ascii is 32

    let year = vector::tabulate!(4, |_| utc.pop_back());
    assert!(utc.pop_back() == 32); // space in ascii is 32

    let hour = vector::tabulate!(2, |_| utc.pop_back());
    assert!(utc.pop_back() == 58); // colon in ascii is 58

    let minute = vector::tabulate!(2, |_| utc.pop_back());
    assert!(utc.pop_back() == 58); // colon in ascii is 58

    let second = vector::tabulate!(2, |_| utc.pop_back());
    assert!(utc.pop_back() == 32); // space in ascii is 32

    let timezone = vector::tabulate!(3, |_| utc.pop_back());
    assert!(timezone == b"GMT");

    Date {
        year: parse_u16!(year),
        month,
        day: parse_u16!(day) as u8,
        day_of_week,
        hour: parse_u16!(hour) as u8,
        minute: parse_u16!(minute) as u8,
        second: parse_u16!(second) as u8,
        millisecond: 0,
        timezone_offset_m: 0,
        timestamp_ms: 0,
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

/// ISO 8601
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

    let mut iso = b"".to_string();
    iso.append(date.year.to_string());
    iso.append_utf8(b"-");
    iso.append((date.month + 1).pad_zero!());
    iso.append_utf8(b"-");
    iso.append(date.day.pad_zero!());
    iso.append_utf8(b"T");
    iso.append(date.hour.pad_zero!());
    iso.append_utf8(b":");
    iso.append(date.minute.pad_zero!());
    iso.append_utf8(b":");
    iso.append(date.second.pad_zero!());
    iso.append_utf8(b".");

    // extra 0 for milliseconds
    if (date.millisecond < 100) iso.append_utf8(b"0");
    iso.append(date.millisecond.pad_zero!());
    iso.append(to_timezone_offset_string!(date.timezone_offset_m));
    iso
}

/// Convert a `Date` to a UTC string.
/// According to the RFC 1123, the UTC string is in the format of:
/// `ddd, DD MMM YYYY HH:MM:SS GMT`
///
/// Where:
/// - `ddd` is the day of the week in three letters.
/// - `DD` is the day of the month in two digits.
/// - `MMM` is the month in three letters.
public fun to_utc_string(date: &Date): String {
    let months = MONTHS;
    let days = DAYS;

    let mut date_time = b"".to_string();
    date_time.append_utf8(days[date.day_of_week as u64]);
    date_time.append_utf8(b", ");
    date_time.append(date.day.pad_zero!());
    date_time.append_utf8(b" ");
    date_time.append_utf8(months[date.month as u64]);
    date_time.append_utf8(b" ");
    date_time.append(date.year.to_string());
    date_time.append_utf8(b" ");
    date_time.append(date.hour.pad_zero!());
    date_time.append_utf8(b":");
    date_time.append(date.minute.pad_zero!());
    date_time.append_utf8(b":");
    date_time.append(date.second.pad_zero!());
    date_time.append_utf8(b" GMT");
    date_time
}

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

/// Format a `Date` to a string.
public fun format(date: &Date, format: vector<u8>): String {
    let months = MONTHS;
    let days = DAYS;
    let months_full = MONTH_NAMES;
    let days_full = DAYS_FULL;
    let mut formatted = b"".to_string();
    let (mut i, len) = (0, format.length());

    while (i < len) {
        match (format[i]) {
            // Year: yyyy / yy / y
            // prettier-ignore
            y @ (Y | YY) => if (
                i + 3 < len && &format[i + 1] == &y && &format[i + 2] == &y && &format[i + 3] == &y
            ) {
                // The year number in four digits. For example, in this format, 2005 would be represented as 2005.
                formatted.append(date.year.to_string());
                i = i + 3;
            } else if (i + 1 < len && format[i + 1] == y) {
                // The last two digits of the year number. For example, in this format, 2005 would be represented as 05.
                formatted.append((date.year % 100).pad_zero!());
                i = i + 1;
            } else {
                // The last digit of the year. For example, 2005 would be represented as 5.
                formatted.append((date.year % 10).to_string());
            },
            // Month: MMMM / MMM / MM / M
            M => if (
                i + 3 < len && format[i + 1] == M && format[i + 2] == M && format[i + 3] == M
            ) {
                // The name of the month spelled in full. This format is supported only for output time. Note: This format is only supported for the output format.
                formatted.append_utf8(months_full[date.month as u64]);
                i = i + 3;
            } else if (i + 2 < len && format[i + 1] == M && format[i + 2] == M) {
                // The name of the month in three letters. For example, August would be represented as Aug.
                formatted.append_utf8(months[date.month as u64]);
                i = i + 2;
            } else if (i + 1 < len && format[i + 1] == M) {
                // Month in two digits. If the month number is a single-digit number, it's displayed with a leading zero.
                formatted.append((date.month + 1).pad_zero!());
                i = i + 1;
            } else {
                // Month as a number from 1 to 12. If the month number is a single-digit number, it's displayed without a leading zero.
                formatted.append((date.month + 1).to_string());
            },
            // Day: dddd / ddd / dd / d OR DDDD / DDD / DD / D
            // prettier-ignore
            d @ (D | DD) => if (
                i + 3 < len && &format[i + 1] == &d && &format[i + 2] == &d && &format[i + 3] == &d
            ) {
                // The full name of the day of the week. For example, Saturday is displayed in full. Note: This format is only supported for the output format.
                formatted.append_utf8(days_full[date.day_of_week as u64]);
                i = i + 3;
            } else if (i + 2 < len && format[i + 1] == d && format[i + 2] == d) {
                // The abbreviated name of the day of the week in three letters. For example, Saturday is abbreviated as “Sat”.
                formatted.append_utf8(days[date.day_of_week as u64]);
                i = i + 2;
            } else if (i + 1 < len && format[i + 1] == d) {
                // Day in two digits. If the day number is a single-digit number, it's displayed with a leading zero.
                formatted.append(date.day.pad_zero!());
                i = i + 1;
            } else {
                // Day as a number from 1 to 31. If the day number is a single-digit number, it's displayed without a leading zero.
                formatted.append(date.day.to_string());
            },
            // Hour: HH / H
            H => if (i + 1 < len && format[i + 1] == H) {
                // Hour in two digits using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed with a leading zero.
                formatted.append(date.hour.pad_zero!());
                i = i + 1;
            } else {
                // Hour as a number from 0 to 23 when using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed without a leading zero.
                formatted.append(date.hour.to_string());
            },
            // Hour: hh / h
            HH => if (i + 1 < len && format[i + 1] == HH) {
                // Hour in two digits using the 12-hour clock. For example, in this format, 1 pm would be represented as 01. If the hour number is a single-digit number, it's displayed with a leading zero.
                formatted.append((if (date.hour == 0) 12 else date.hour % 12).pad_zero!());
                i = i + 1;
            } else {
                // Hour as a number from 1 to 12 when using the 12-hour clock. If the hour number is a single-digit number, it's displayed without a leading zero.
                formatted.append((if (date.hour == 0) 12 else date.hour % 12).to_string());
            },
            // Minute: m
            MM => if (i + 1 < len && format[i + 1] == MM) {
                // Minutes in two digits. If the minute number is a single-digit number, it's displayed with a leading zero.
                formatted.append(date.minute.pad_zero!());
                i = i + 1;
            } else {
                // Minutes as a number from 0 to 59. If the minute number is a single-digit number, it's displayed without a leading zero.
                formatted.append(date.minute.to_string());
            },
            // Second: s
            SS => if (i + 1 < len && format[i + 1] == SS) {
                // Seconds in two digits. If the second number is a single-digit number, it's displayed with a leading zero.
                formatted.append(date.second.pad_zero!());
                i = i + 1;
            } else {
                // Seconds as a number from 0 to 59. If the second number is a single-digit number, it's displayed without a leading zero.
                formatted.append(date.second.to_string());
            },
            // TT: AM/PM
            TT => if (i + 1 < len && format[i + 1] == TT) {
                // A.M. or P.M. as two letters: A.M. or P.M. as defined on your system.
                formatted.append_utf8(if (date.hour < 12) b"AM" else b"PM");
                i = i + 1;
            } else abort,
            // Z: for ISO 8601
            Z if (date.timezone_offset_m != 720) => {
                formatted.append(to_timezone_offset_string!(date.timezone_offset_m));
            },
            // Single quote. Used to escape text in the formatted string.
            // Once seen, scan next characters until another single quote is seen.
            SINGLE_QUOTE => 'search: {
                let mut agg = vector[];
                (i + 1).range_do!(len, |j| {
                    if (format[j] == SINGLE_QUOTE) {
                        i = j;
                        formatted.append_utf8(agg);
                        return 'search
                    };
                    agg.push_back(format[j]);
                });
            },
            _ => formatted.append_utf8(vector[format[i]]),
        };
        i = i + 1;
    };

    formatted
}

use fun u8_pad_zero as u8.pad_zero;
use fun u16_pad_zero as u16.pad_zero;

/// Pad a `u8` number with a leading zero.
macro fun u8_pad_zero($num: u8): String { pad_zero!($num) }

/// Pad a `u16` number with a leading zero.
macro fun u16_pad_zero($num: u16): String { pad_zero!($num) }

macro fun to_timezone_offset_string($offset_m: u16): String {
    let mut res = b"".to_string();
    if ($offset_m > 720) {
        // East
        res.append_utf8(b"+");
        let hours = ($offset_m - 720) / 60;
        let minutes = ($offset_m - 720) % 60;
        res.append(hours.pad_zero!());
        res.append_utf8(b":");
        res.append(minutes.pad_zero!());
        res
    } else if ($offset_m < 720) {
        // West
        res.append_utf8(b"-");
        let hours = (720 - $offset_m) / 60;
        let minutes = (720 - $offset_m) % 60;
        res.append(hours.pad_zero!());
        res.append_utf8(b":");
        res.append(minutes.pad_zero!());
        res
    } else {
        b"Z".to_string()
    }
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

/// Pad a number with a leading zero.
macro fun pad_zero<$T: drop>($num: $T): String {
    let num = $num;
    if (num < 10) vector[48, (num as u8) + 48].to_string() else num_to_string!(num)
}
