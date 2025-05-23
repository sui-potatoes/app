// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module date::date_tests;

use date::date;
use std::unit_test::assert_eq;

#[test]
fun utc_date_time() {
    assert_eq!(date::new(0).to_utc_string(), b"Thu, 01 Jan 1970 00:00:00 GMT".to_string());
    assert_eq!(date::new(86400000).to_utc_string(), b"Fri, 02 Jan 1970 00:00:00 GMT".to_string());
    assert_eq!(
        date::new(1747409967000).to_utc_string(),
        b"Fri, 16 May 2025 15:39:27 GMT".to_string(),
    );
    assert_eq!(
        date::new(1609459200000).to_utc_string(),
        b"Fri, 01 Jan 2021 00:00:00 GMT".to_string(),
    );
    assert_eq!(
        date::new(1715853600000).to_utc_string(),
        b"Thu, 16 May 2024 10:00:00 GMT".to_string(),
    );
    assert_eq!(
        date::new(1893456000000).to_utc_string(),
        b"Tue, 01 Jan 2030 00:00:00 GMT".to_string(),
    );
    assert_eq!(
        date::new(2145916800000).to_utc_string(),
        b"Fri, 01 Jan 2038 00:00:00 GMT".to_string(),
    );

    assert_eq!(
        date::new(1747901403000).to_utc_string(),
        b"Thu, 22 May 2025 08:10:03 GMT".to_string(),
    );
}

#[test]
fun iso_date_time() {
    assert_eq!(date::new(0).to_iso_string(), b"1970-01-01T00:00:00.000Z".to_string());
    assert_eq!(date::new(15).to_iso_string(), b"1970-01-01T00:00:00.015Z".to_string());

    assert_eq!(
        date::new(0).tz_east_m(90).to_iso_string(),
        b"1970-01-01T01:30:00.000+01:30".to_string(),
    );
}

#[test]
fun format_year() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"y", b"0");
    assert_format!(0, b"yy", b"70");
    assert_format!(0, b"yyyy", b"1970");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"y", b"5");
    assert_format!(1747409967000, b"yy", b"25");
    assert_format!(1747409967000, b"yyyy", b"2025");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"y", b"5");
    assert_format!(1747901403000, b"yy", b"25");
    assert_format!(1747901403000, b"yyyy", b"2025");

    // Fri, 01 Jan 2038 00:00:00 GMT
    assert_format!(2145916800000, b"y", b"8");
    assert_format!(2145916800000, b"yy", b"38");
    assert_format!(2145916800000, b"yyyy", b"2038");
}

#[test]
fun format_month() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"M", b"1");
    assert_format!(0, b"MM", b"01");
    assert_format!(0, b"MMM", b"Jan");
    assert_format!(0, b"MMMM", b"January");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"M", b"5");
    assert_format!(1747901403000, b"MM", b"05");
    assert_format!(1747901403000, b"MMM", b"May");
    assert_format!(1747901403000, b"MMMM", b"May");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"M", b"5");
    assert_format!(1747409967000, b"MM", b"05");
    assert_format!(1747409967000, b"MMM", b"May");
    assert_format!(1747409967000, b"MMMM", b"May");
}

#[test]
fun format_day() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"d", b"1");
    assert_format!(0, b"dd", b"01");
    assert_format!(0, b"ddd", b"Thu");
    assert_format!(0, b"dddd", b"Thursday");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"d", b"22");
    assert_format!(1747901403000, b"dd", b"22");
    assert_format!(1747901403000, b"ddd", b"Thu");
    assert_format!(1747901403000, b"dddd", b"Thursday");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"d", b"16");
    assert_format!(1747409967000, b"dd", b"16");
    assert_format!(1747409967000, b"ddd", b"Fri");
    assert_format!(1747409967000, b"dddd", b"Friday");
}

#[test]
fun format_hour() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"h", b"12");
    assert_format!(0, b"hh", b"12");
    assert_format!(0, b"H", b"0");
    assert_format!(0, b"HH", b"00");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"h", b"8");
    assert_format!(1747901403000, b"hh", b"08");
    assert_format!(1747901403000, b"H", b"8");
    assert_format!(1747901403000, b"HH", b"08");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"h", b"3");
    assert_format!(1747409967000, b"hh", b"03");
    assert_format!(1747409967000, b"H", b"15");
    assert_format!(1747409967000, b"HH", b"15");
}

#[test]
fun format_minute() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"m", b"0");
    assert_format!(0, b"mm", b"00");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"m", b"10");
    assert_format!(1747901403000, b"mm", b"10");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"m", b"39");
    assert_format!(1747409967000, b"mm", b"39");
}

#[test]
fun format_second() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"s", b"0");
    assert_format!(0, b"ss", b"00");
    assert_format!(1000, b"s", b"1");
    assert_format!(10000, b"ss", b"10");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"s", b"3");
    assert_format!(1747901403000, b"ss", b"03");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"s", b"27");
    assert_format!(1747409967000, b"ss", b"27");
}

#[test]
fun format_am_pm() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"hh tt", b"12 AM");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"hh tt", b"08 AM");

    // Fri, 16 May 2025 15:39:27 GMT
    assert_format!(1747409967000, b"hh tt", b"03 PM");
}

#[test]
fun format_escape() {
    assert_format!(0, b"'mm:yy:hh'", b"mm:yy:hh");
    assert_format!(0, b"'MM:HH:YY' MM", b"MM:HH:YY 01");
}

#[test]
fun combo_format() {
    // Thu, 01 Jan 1970 00:00:00 GMT
    assert_format!(0, b"MM/yyyy", b"01/1970");
    assert_format!(0, b"dd/MM/yyyy", b"01/01/1970");
    assert_format!(0, b"dd/MM/yyyy HH:mm:ss", b"01/01/1970 00:00:00");

    // Thu, 22 May 2025 08:10:03 GMT
    assert_format!(1747901403000, b"MM/yyyy", b"05/2025");
    assert_format!(1747901403000, b"dd/MM/yyyy", b"22/05/2025");
    assert_format!(1747901403000, b"dd/MM/yyyy HH:mm:ss", b"22/05/2025 08:10:03");

    // Fri, 01 Jan 2038 00:00:00 GMT
    assert_format!(2145916899000, b"dd-MM-yy - tt - HH::mm::ss", b"01-01-38 - AM - 00::01::39");
    assert_format!(1747409967000, b"ddd, dd MMM yyyy HH:mm:ss", b"Fri, 16 May 2025 15:39:27");
}

#[test]
fun format_eq_utc() {
    assert_utc_format!(0);
    assert_utc_format!(86400000);
    assert_utc_format!(1747409967000);
    assert_utc_format!(1609459200000);
    assert_utc_format!(1715853600000);
    assert_utc_format!(1893456000000);
    assert_utc_format!(2145916800000);
}

#[test]
fun format_juzy() {
    assert_format!(
        1747906219000,
        b"'You are a man of culture' YYYY-MM-DD",
        b"You are a man of culture 2025-05-22",
    );
}

/// Asserts that the formatted date matches the expected string.
macro fun assert_format($timestamp: u64, $format: vector<u8>, $expected: vector<u8>) {
    let expected = $expected;
    assert_eq!(date::new($timestamp).format($format), expected.to_string());
}

/// Asserts that the UTC date string matches the same formatted string.
macro fun assert_utc_format($timestamp: u64) {
    let date = date::new($timestamp);
    assert_eq!(date.to_utc_string(), date.format(b"ddd, dd MMM yyyy HH:mm:ss 'GMT'"));
}
