
<a name="(date=0x0)_date"></a>

# Module `(date=0x0)::date`

Implementation of the Date type and related functions in Move.

Supports:
- ISO 8601
- RFC 7231 (HTTP-date format)
- Date / Time formatting

Does not support:
- IANA Timezone names
- Timezone Offsets (ISO 8601)

Formatting:
- <code>yyyy</code> or <code>YYYY</code> - The year number in four digits. For example, in this format, 2005 would be represented as 2005.
- <code>yy</code> or <code><a href="./date.md#(date=0x0)_date_YY">YY</a></code> - The last two digits of the year number. For example, in this format, 2005 would be represented as 05.
- <code>MMMM</code> - The name of the month spelled in full. This format is supported only for output time. Note: This format is only supported for the output format.
- <code>MMM</code> - The name of the month in three letters. For example, August would be represented as Aug.
- <code><a href="./date.md#(date=0x0)_date_MM">MM</a></code> - Month in two digits. If the month number is a single-digit number, it's displayed with a leading zero.
- <code><a href="./date.md#(date=0x0)_date_M">M</a></code> - Month as a number from 1 to 12. If the month number is a single-digit number, it's displayed without a leading zero.
- <code>dddd</code> or <code>DDDD</code> - The full name of the day of the week. For example, Saturday is displayed in full. Note: This format is only supported for the output format.
- <code>ddd</code> or <code>DDD</code> - The abbreviated name of the day of the week in three letters. For example, Saturday is abbreviated as “Sat”.
- <code>dd</code> or <code><a href="./date.md#(date=0x0)_date_DD">DD</a></code> - Day in two digits. If the day number is a single-digit number, it's displayed with a leading zero.
- <code>d</code> or <code><a href="./date.md#(date=0x0)_date_D">D</a></code> - Day as a number from 1 to 31. If the day number is a single-digit number, it's displayed without a leading zero.
- <code><a href="./date.md#(date=0x0)_date_HH">HH</a></code> - Hour in two digits using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed with a leading zero.
- <code><a href="./date.md#(date=0x0)_date_H">H</a></code> - Hour as a number from 0 to 23 when using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed without a leading zero.
- <code>hh</code> - Hour in two digits using the 12-hour clock. For example, in this format, 1 pm would be represented as 01. If the hour number is a single-digit number, it's displayed with a leading zero.
- <code>h</code> - Hour as a number from 1 to 12 when using the 12-hour clock. If the hour number is a single-digit number, it's displayed without a leading zero.
- <code>mm</code> - Minutes in two digits. If the minute number is a single-digit number, it's displayed with a leading zero.
- <code>m</code> - Minutes as a number from 0 to 59. If the minute number is a single-digit number, it's displayed without a leading zero.
- <code>ss</code> - Seconds in two digits. If the second number is a single-digit number, it's displayed with a leading zero.
- <code>s</code> - Seconds as a number from 0 to 59. If the second number is a single-digit number, it's displayed without a leading zero.
- <code>SSS</code> - Milliseconds in three digits. If the millisecond number is a single-digit number, it's displayed with a leading zero.
- <code>tt</code> - A.M. or P.M. as two letters: AM or PM.

Resources:
- ISO 8601: https://en.wikipedia.org/wiki/ISO_8601
- RFC 7231 (HTTP-date format: https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.1.1)


-  [Struct `Date`](#(date=0x0)_date_Date)
-  [Constants](#@Constants_0)
-  [Function `new`](#(date=0x0)_date_new)
-  [Function `from_clock`](#(date=0x0)_date_from_clock)
-  [Function `from_utc_string`](#(date=0x0)_date_from_utc_string)
-  [Function `second`](#(date=0x0)_date_second)
-  [Function `minute`](#(date=0x0)_date_minute)
-  [Function `hour`](#(date=0x0)_date_hour)
-  [Function `day`](#(date=0x0)_date_day)
-  [Function `month`](#(date=0x0)_date_month)
-  [Function `year`](#(date=0x0)_date_year)
-  [Function `timestamp_ms`](#(date=0x0)_date_timestamp_ms)
-  [Function `to_iso_string`](#(date=0x0)_date_to_iso_string)
-  [Function `to_utc_string`](#(date=0x0)_date_to_utc_string)
-  [Function `format`](#(date=0x0)_date_format)
-  [Macro function `num_to_bytes`](#(date=0x0)_date_num_to_bytes)
-  [Macro function `to_timezone_offset_byte_string`](#(date=0x0)_date_to_timezone_offset_byte_string)
-  [Macro function `is_leap_year`](#(date=0x0)_date_is_leap_year)
-  [Macro function `parse_u16`](#(date=0x0)_date_parse_u16)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(date=0x0)_date_Date"></a>

## Struct `Date`

A struct representing a date.


<pre><code><b>public</b> <b>struct</b> <a href="./date.md#(date=0x0)_date_Date">Date</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./date.md#(date=0x0)_date_year">year</a>: u16</code>
</dt>
<dd>
 The year of the date.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_month">month</a>: u8</code>
</dt>
<dd>
 The month of the date.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_day">day</a>: u8</code>
</dt>
<dd>
 The day of the date.
</dd>
<dt>
<code>day_of_week: u8</code>
</dt>
<dd>
 The day of the week.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_hour">hour</a>: u8</code>
</dt>
<dd>
 The hour of the date.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_minute">minute</a>: u8</code>
</dt>
<dd>
 The minute of the date.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_second">second</a>: u8</code>
</dt>
<dd>
 The second of the date.
</dd>
<dt>
<code>millisecond: u16</code>
</dt>
<dd>
 The milliseconds of the date.
</dd>
<dt>
<code>timezone_offset_m: u16</code>
</dt>
<dd>
 The offset of a timezone in minutes, with 720 being UTC.
</dd>
<dt>
<code><a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>: u64</code>
</dt>
<dd>
 The timestamp in milliseconds.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(date=0x0)_date_EInvalidMonth"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EInvalidMonth">EInvalidMonth</a>: u64 = 0;
</code></pre>



<a name="(date=0x0)_date_EInvalidDay"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EInvalidDay">EInvalidDay</a>: u64 = 1;
</code></pre>



<a name="(date=0x0)_date_EExpectedComma"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedComma">EExpectedComma</a>: u64 = 2;
</code></pre>



<a name="(date=0x0)_date_EExpectedSpace"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>: u64 = 3;
</code></pre>



<a name="(date=0x0)_date_EExpectedColon"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedColon">EExpectedColon</a>: u64 = 4;
</code></pre>



<a name="(date=0x0)_date_EExpectedTimezone"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedTimezone">EExpectedTimezone</a>: u64 = 5;
</code></pre>



<a name="(date=0x0)_date_EInvalidFormat"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EInvalidFormat">EInvalidFormat</a>: u64 = 6;
</code></pre>



<a name="(date=0x0)_date_EExpectedTT"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedTT">EExpectedTT</a>: u64 = 7;
</code></pre>



<a name="(date=0x0)_date_EExpectedYear"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedYear">EExpectedYear</a>: u64 = 8;
</code></pre>



<a name="(date=0x0)_date_EExpectedSSS"></a>



<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_EExpectedSSS">EExpectedSSS</a>: u64 = 9;
</code></pre>



<a name="(date=0x0)_date_DAYS"></a>

The days of the week.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_DAYS">DAYS</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[83, 117, 110], vector[77, 111, 110], vector[84, 117, 101], vector[87, 101, 100], vector[84, 104, 117], vector[70, 114, 105], vector[83, 97, 116]];
</code></pre>



<a name="(date=0x0)_date_DAYS_FULL"></a>

The full names of the days of the week.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_DAYS_FULL">DAYS_FULL</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[83, 117, 110, 100, 97, 121], vector[77, 111, 110, 100, 97, 121], vector[84, 117, 101, 115, 100, 97, 121], vector[87, 101, 100, 110, 101, 115, 100, 97, 121], vector[84, 104, 117, 114, 115, 100, 97, 121], vector[70, 114, 105, 100, 97, 121], vector[83, 97, 116, 117, 114, 100, 97, 121]];
</code></pre>



<a name="(date=0x0)_date_DAYS_IN_MONTH"></a>

The number of days in each month.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_DAYS_IN_MONTH">DAYS_IN_MONTH</a>: vector&lt;u64&gt; = vector[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
</code></pre>



<a name="(date=0x0)_date_MONTHS"></a>

The months of the year.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_MONTHS">MONTHS</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[74, 97, 110], vector[70, 101, 98], vector[77, 97, 114], vector[65, 112, 114], vector[77, 97, 121], vector[74, 117, 110], vector[74, 117, 108], vector[65, 117, 103], vector[83, 101, 112], vector[79, 99, 116], vector[78, 111, 118], vector[68, 101, 99]];
</code></pre>



<a name="(date=0x0)_date_MONTH_NAMES"></a>

The full names of the months of the year.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_MONTH_NAMES">MONTH_NAMES</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[74, 97, 110, 117, 97, 114, 121], vector[70, 101, 98, 114, 117, 97, 114, 121], vector[77, 97, 114, 99, 104], vector[65, 112, 114, 105, 108], vector[77, 97, 121], vector[74, 117, 110, 101], vector[74, 117, 108, 121], vector[65, 117, 103, 117, 115, 116], vector[83, 101, 112, 116, 101, 109, 98, 101, 114], vector[79, 99, 116, 111, 98, 101, 114], vector[78, 111, 118, 101, 109, 98, 101, 114], vector[68, 101, 99, 101, 109, 98, 101, 114]];
</code></pre>



<a name="(date=0x0)_date_Y"></a>

Capital: Y


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_Y">Y</a>: u8 = 89;
</code></pre>



<a name="(date=0x0)_date_Z"></a>

Capital: Z


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_Z">Z</a>: u8 = 90;
</code></pre>



<a name="(date=0x0)_date_YY"></a>

Capital: YY


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_YY">YY</a>: u8 = 121;
</code></pre>



<a name="(date=0x0)_date_M"></a>

Capital: M


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_M">M</a>: u8 = 77;
</code></pre>



<a name="(date=0x0)_date_D"></a>

Capital: D


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_D">D</a>: u8 = 68;
</code></pre>



<a name="(date=0x0)_date_DD"></a>

Small: d


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_DD">DD</a>: u8 = 100;
</code></pre>



<a name="(date=0x0)_date_H"></a>

Capital: H


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_H">H</a>: u8 = 72;
</code></pre>



<a name="(date=0x0)_date_HH"></a>

Small: h


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_HH">HH</a>: u8 = 104;
</code></pre>



<a name="(date=0x0)_date_MM"></a>

Small: m


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_MM">MM</a>: u8 = 109;
</code></pre>



<a name="(date=0x0)_date_S"></a>

Capital: S


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_S">S</a>: u8 = 83;
</code></pre>



<a name="(date=0x0)_date_SS"></a>

Small: s


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_SS">SS</a>: u8 = 115;
</code></pre>



<a name="(date=0x0)_date_TT"></a>

Small: t


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_TT">TT</a>: u8 = 116;
</code></pre>



<a name="(date=0x0)_date_SINGLE_QUOTE"></a>

Single quote. Used to escape text in the formatted string.


<pre><code><b>const</b> <a href="./date.md#(date=0x0)_date_SINGLE_QUOTE">SINGLE_QUOTE</a>: u8 = 39;
</code></pre>



<a name="(date=0x0)_date_new"></a>

## Function `new`

Create a new <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> from a timestamp in milliseconds.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_new">new</a>(<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>: u64): (<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_new">new</a>(<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>: u64): <a href="./date.md#(date=0x0)_date_Date">Date</a> {
    <b>let</b> seconds = <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> / 1000;
    <b>let</b> <b>mut</b> remaining = seconds;
    // == Time of <a href="./date.md#(date=0x0)_date_day">day</a> ==
    <b>let</b> <a href="./date.md#(date=0x0)_date_second">second</a> = remaining % 60;
    remaining = remaining / 60;
    <b>let</b> <a href="./date.md#(date=0x0)_date_minute">minute</a> = remaining % 60;
    remaining = remaining / 60;
    <b>let</b> <a href="./date.md#(date=0x0)_date_hour">hour</a> = remaining % 24;
    // == Days since epoch ==
    <b>let</b> <b>mut</b> days = seconds / 86400;
    <b>let</b> <b>mut</b> <a href="./date.md#(date=0x0)_date_year">year</a> = 1970u16;
    // == Leap <a href="./date.md#(date=0x0)_date_year">year</a> ==
    <b>loop</b> {
        <b>let</b> days_in_year = <b>if</b> (<a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>!(<a href="./date.md#(date=0x0)_date_year">year</a>)) 366 <b>else</b> 365;
        <b>if</b> (days &lt; days_in_year) <b>break</b>
        <b>else</b> {
            <a href="./date.md#(date=0x0)_date_year">year</a> = <a href="./date.md#(date=0x0)_date_year">year</a> + 1;
            days = days - days_in_year;
        };
    };
    // == Month and <a href="./date.md#(date=0x0)_date_day">day</a> ==
    <b>let</b> <b>mut</b> <a href="./date.md#(date=0x0)_date_month">month</a> = 0;
    <b>let</b> days_in_month = <a href="./date.md#(date=0x0)_date_DAYS_IN_MONTH">DAYS_IN_MONTH</a>;
    <b>loop</b> {
        <b>let</b> days_in_month = <b>if</b> (<a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>!(<a href="./date.md#(date=0x0)_date_year">year</a>) && <a href="./date.md#(date=0x0)_date_month">month</a> == 1) {
            29
        } <b>else</b> {
            days_in_month[<a href="./date.md#(date=0x0)_date_month">month</a>]
        };
        <b>if</b> (days &lt; days_in_month) <b>break</b>
        <b>else</b> {
            <a href="./date.md#(date=0x0)_date_month">month</a> = <a href="./date.md#(date=0x0)_date_month">month</a> + 1;
            days = days - days_in_month;
        };
    };
    <a href="./date.md#(date=0x0)_date_Date">Date</a> {
        <a href="./date.md#(date=0x0)_date_year">year</a>,
        <a href="./date.md#(date=0x0)_date_month">month</a>: <a href="./date.md#(date=0x0)_date_month">month</a> <b>as</b> u8,
        <a href="./date.md#(date=0x0)_date_day">day</a>: (days + 1) <b>as</b> u8,
        day_of_week: ((seconds / 86400 + 4) % 7) <b>as</b> u8,
        <a href="./date.md#(date=0x0)_date_hour">hour</a>: <a href="./date.md#(date=0x0)_date_hour">hour</a> <b>as</b> u8,
        <a href="./date.md#(date=0x0)_date_minute">minute</a>: <a href="./date.md#(date=0x0)_date_minute">minute</a> <b>as</b> u8,
        <a href="./date.md#(date=0x0)_date_second">second</a>: <a href="./date.md#(date=0x0)_date_second">second</a> <b>as</b> u8,
        millisecond: (<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> % 1000) <b>as</b> u16,
        timezone_offset_m: 720, // UTC by default
        <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>,
    }
}
</code></pre>



</details>

<a name="(date=0x0)_date_from_clock"></a>

## Function `from_clock`

Create a new <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> from a <code>Clock</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_from_clock">from_clock</a>(clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>): (<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_from_clock">from_clock</a>(clock: &Clock): <a href="./date.md#(date=0x0)_date_Date">Date</a> {
    <a href="./date.md#(date=0x0)_date_new">new</a>(clock.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>())
}
</code></pre>



</details>

<a name="(date=0x0)_date_from_utc_string"></a>

## Function `from_utc_string`

Create a new <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> from a UTC String (RFC 1123).
See HTTP-date format: https://www.rfc-editor.org/rfc/rfc7231#section-7.1.1.1

According to the RFC 1123, the UTC string is in the format of:
<code>ddd, <a href="./date.md#(date=0x0)_date_DD">DD</a> MMM YYYY <a href="./date.md#(date=0x0)_date_HH">HH</a>:<a href="./date.md#(date=0x0)_date_MM">MM</a>:<a href="./date.md#(date=0x0)_date_SS">SS</a> GMT</code>

Where:
- <code>ddd</code> is the day of the week in three letters.
- <code><a href="./date.md#(date=0x0)_date_DD">DD</a></code> is the day of the month in two digits.
- <code>MMM</code> is the month in three letters.
- <code>YYYY</code> is the year in four digits.

Aborts if:
- The UTC string is not in the correct format.
- Incorrect values are used for month or day of the week.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_from_utc_string">from_utc_string</a>(utc: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_from_utc_string">from_utc_string</a>(utc: String): <a href="./date.md#(date=0x0)_date_Date">Date</a> {
    <b>let</b> days = <a href="./date.md#(date=0x0)_date_DAYS">DAYS</a>;
    <b>let</b> months = <a href="./date.md#(date=0x0)_date_MONTHS">MONTHS</a>;
    <b>let</b> days_in_month = <a href="./date.md#(date=0x0)_date_DAYS_IN_MONTH">DAYS_IN_MONTH</a>;
    <b>let</b> <b>mut</b> utc = utc.into_bytes();
    <b>assert</b>!(utc.length() == 29, <a href="./date.md#(date=0x0)_date_EInvalidFormat">EInvalidFormat</a>);
    utc.reverse();
    // First 3 elements are the <a href="./date.md#(date=0x0)_date_day">day</a> of the week.
    <b>let</b> day_of_week = vector::tabulate!(3, |_| utc.pop_back());
    <b>let</b> day_of_week = days.find_index!(|d| d == &day_of_week).destroy_or!(<b>abort</b> <a href="./date.md#(date=0x0)_date_EInvalidDay">EInvalidDay</a>) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::comma!(), <a href="./date.md#(date=0x0)_date_EExpectedComma">EExpectedComma</a>); // comma in ascii is 44
    <b>assert</b>!(utc.pop_back() == char::space!(), <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>); // space in ascii is 32
    <b>let</b> <a href="./date.md#(date=0x0)_date_day">day</a> = <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>!(vector::tabulate!(2, |_| utc.pop_back())) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::space!(), <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>); // space in ascii is 32
    <b>let</b> <a href="./date.md#(date=0x0)_date_month">month</a> = vector::tabulate!(3, |_| utc.pop_back());
    <b>let</b> <a href="./date.md#(date=0x0)_date_month">month</a> = months.find_index!(|m| m == &<a href="./date.md#(date=0x0)_date_month">month</a>).destroy_or!(<b>abort</b> <a href="./date.md#(date=0x0)_date_EInvalidMonth">EInvalidMonth</a>) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::space!(), <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>); // space in ascii is 32
    <b>let</b> <a href="./date.md#(date=0x0)_date_year">year</a> = <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>!(vector::tabulate!(4, |_| utc.pop_back()));
    <b>assert</b>!(utc.pop_back() == char::space!(), <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>); // space in ascii is 32
    <b>let</b> <a href="./date.md#(date=0x0)_date_hour">hour</a> = <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>!(vector::tabulate!(2, |_| utc.pop_back())) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::colon!(), <a href="./date.md#(date=0x0)_date_EExpectedColon">EExpectedColon</a>);
    <b>let</b> <a href="./date.md#(date=0x0)_date_minute">minute</a> = <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>!(vector::tabulate!(2, |_| utc.pop_back())) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::colon!(), <a href="./date.md#(date=0x0)_date_EExpectedColon">EExpectedColon</a>);
    <b>let</b> <a href="./date.md#(date=0x0)_date_second">second</a> = <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>!(vector::tabulate!(2, |_| utc.pop_back())) <b>as</b> u8;
    <b>assert</b>!(utc.pop_back() == char::space!(), <a href="./date.md#(date=0x0)_date_EExpectedSpace">EExpectedSpace</a>); // space in ascii is 32
    <b>let</b> timezone = vector::tabulate!(3, |_| utc.pop_back());
    <b>assert</b>!(timezone == b"GMT", <a href="./date.md#(date=0x0)_date_EExpectedTimezone">EExpectedTimezone</a>);
    // Convert <a href="./date.md#(date=0x0)_date_year">year</a>/<a href="./date.md#(date=0x0)_date_month">month</a>/<a href="./date.md#(date=0x0)_date_day">day</a>/<a href="./date.md#(date=0x0)_date_hour">hour</a>/<a href="./date.md#(date=0x0)_date_minute">minute</a>/<a href="./date.md#(date=0x0)_date_second">second</a> to <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>.
    <b>let</b> <b>mut</b> days = 0;
    // Add days <b>for</b> each <a href="./date.md#(date=0x0)_date_year">year</a> since 1970.
    1970u16.range_do!(<a href="./date.md#(date=0x0)_date_year">year</a>, |y| {
        days = days + 365;
        // Add leap <a href="./date.md#(date=0x0)_date_year">year</a> <a href="./date.md#(date=0x0)_date_day">day</a> <b>if</b> applicable.
        <b>if</b> (<a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>!(y)) days = days + 1;
    });
    // Add days <b>for</b> each <a href="./date.md#(date=0x0)_date_month">month</a>.
    <a href="./date.md#(date=0x0)_date_month">month</a>.do!(|m| {
        days = days + days_in_month[m <b>as</b> u64];
        // Add leap <a href="./date.md#(date=0x0)_date_year">year</a> <a href="./date.md#(date=0x0)_date_day">day</a> in February <b>if</b> applicable
        <b>if</b> (m == 1 && <a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>!(<a href="./date.md#(date=0x0)_date_year">year</a>)) days = days + 1;
    });
    // Add remaining days
    days = days + (<a href="./date.md#(date=0x0)_date_day">day</a> <b>as</b> u64) - 1;
    // Convert to milliseconds
    <b>let</b> timestamp =
        days * 24 * 60 * 60 +
        (<a href="./date.md#(date=0x0)_date_hour">hour</a> <b>as</b> u64) * 60 * 60 +
        (<a href="./date.md#(date=0x0)_date_minute">minute</a> <b>as</b> u64) * 60 +
        (<a href="./date.md#(date=0x0)_date_second">second</a> <b>as</b> u64);
    <a href="./date.md#(date=0x0)_date_Date">Date</a> {
        <a href="./date.md#(date=0x0)_date_year">year</a>,
        <a href="./date.md#(date=0x0)_date_month">month</a>,
        <a href="./date.md#(date=0x0)_date_day">day</a>,
        day_of_week,
        <a href="./date.md#(date=0x0)_date_hour">hour</a>,
        <a href="./date.md#(date=0x0)_date_minute">minute</a>,
        <a href="./date.md#(date=0x0)_date_second">second</a>,
        millisecond: 0,
        timezone_offset_m: 0,
        <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>: timestamp * 1000,
    }
}
</code></pre>



</details>

<a name="(date=0x0)_date_second"></a>

## Function `second`

Get the second of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_second">second</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_second">second</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u8 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_second">second</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_minute"></a>

## Function `minute`

Get the minute of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_minute">minute</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_minute">minute</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u8 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_minute">minute</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_hour"></a>

## Function `hour`

Get the hour of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_hour">hour</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_hour">hour</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u8 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_day"></a>

## Function `day`

Get the day of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_day">day</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_day">day</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u8 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_day">day</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_month"></a>

## Function `month`

Get the month of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_month">month</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_month">month</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u8 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_year"></a>

## Function `year`

Get the year of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_year">year</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_year">year</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u16 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_year">year</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_timestamp_ms"></a>

## Function `timestamp_ms`

Get the timestamp in milliseconds of a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): u64 { <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> }
</code></pre>



</details>

<a name="(date=0x0)_date_to_iso_string"></a>

## Function `to_iso_string`

Print a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> in ISO 8601 format as a String.

Example:
```rust
assert!(date.to_iso_string() == b"2025-05-22T15:39:27.000Z".to_string());
```

See ISO 8601: https://en.wikipedia.org/wiki/ISO_8601


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_iso_string">to_iso_string</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_iso_string">to_iso_string</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): String {
    <b>let</b> <b>mut</b> <a href="./date.md#(date=0x0)_date">date</a> = *<a href="./date.md#(date=0x0)_date">date</a>;
    <b>let</b> offset = <a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m <b>as</b> u64;
    <b>if</b> (offset != 720) {
        <b>if</b> (offset &gt; 720) {
            <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> = <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> + (offset - 720) * 60 * 1000;
            <a href="./date.md#(date=0x0)_date">date</a> = <a href="./date.md#(date=0x0)_date_new">new</a>(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>);
            <a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m = offset <b>as</b> u16;
        } <b>else</b> {
            <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> = <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a> - (720 - offset) * 60 * 1000;
            <a href="./date.md#(date=0x0)_date">date</a> = <a href="./date.md#(date=0x0)_date_new">new</a>(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_timestamp_ms">timestamp_ms</a>);
            <a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m = offset <b>as</b> u16;
        }
    };
    <b>let</b> <b>mut</b> iso = vector[];
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_year">year</a>, <b>false</b>));
    iso.push_back(char::minus!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> + 1, <b>true</b>));
    iso.push_back(char::minus!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_day">day</a>, <b>true</b>));
    iso.push_back(char::T!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>true</b>));
    iso.push_back(char::colon!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_minute">minute</a>, <b>true</b>));
    iso.push_back(char::colon!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_second">second</a>, <b>true</b>));
    iso.push_back(char::period!());
    // extra 0 <b>for</b> milliseconds
    <b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.millisecond &lt; 100) iso.push_back(char::zero!());
    iso.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.millisecond, <b>true</b>));
    iso.append(<a href="./date.md#(date=0x0)_date_to_timezone_offset_byte_string">to_timezone_offset_byte_string</a>!(<a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m));
    iso.to_string()
}
</code></pre>



</details>

<a name="(date=0x0)_date_to_utc_string"></a>

## Function `to_utc_string`

Convert a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> to a UTC string.
See RFC 1123: https://www.rfc-editor.org/rfc/rfc7231#section-7.1.1.1

According to the RFC 1123, the UTC string is in the format of:
<code>ddd, <a href="./date.md#(date=0x0)_date_DD">DD</a> MMM YYYY <a href="./date.md#(date=0x0)_date_HH">HH</a>:<a href="./date.md#(date=0x0)_date_MM">MM</a>:<a href="./date.md#(date=0x0)_date_SS">SS</a> GMT</code>

Where:
- <code>DDD</code> is the day of the week in three letters.
- <code><a href="./date.md#(date=0x0)_date_DD">DD</a></code> is the day of the month in two digits.
- <code>MMM</code> is the month in three letters.

Example:
```rust
assert!(date.to_utc_string() == b"Fri, 16 May 2025 15:39:27 GMT".to_string());
```


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_utc_string">to_utc_string</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_utc_string">to_utc_string</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>): String {
    <b>let</b> months = <a href="./date.md#(date=0x0)_date_MONTHS">MONTHS</a>;
    <b>let</b> days = <a href="./date.md#(date=0x0)_date_DAYS">DAYS</a>;
    <b>let</b> <b>mut</b> date_time = vector[];
    date_time.append(days[<a href="./date.md#(date=0x0)_date">date</a>.day_of_week <b>as</b> u64]);
    date_time.push_back(char::comma!());
    date_time.push_back(char::space!());
    date_time.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_day">day</a>, <b>true</b>));
    date_time.push_back(char::space!());
    date_time.append(months[<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> <b>as</b> u64]);
    date_time.push_back(char::space!());
    date_time.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_year">year</a>, <b>false</b>));
    date_time.push_back(char::space!());
    date_time.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>true</b>));
    date_time.push_back(char::colon!());
    date_time.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_minute">minute</a>, <b>true</b>));
    date_time.push_back(char::colon!());
    date_time.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_second">second</a>, <b>true</b>));
    date_time.append(b" GMT");
    date_time.to_string()
}
</code></pre>



</details>

<a name="(date=0x0)_date_format"></a>

## Function `format`

Format a <code><a href="./date.md#(date=0x0)_date_Date">Date</a></code> to a string.
See the formatting rules:
- unrecognized symbols are kept as is (except for ambiguous symbols like <code>y</code> or <code><a href="./date.md#(date=0x0)_date_SS">SS</a></code> or <code><a href="./date.md#(date=0x0)_date_S">S</a></code>)
- 'yyyy or 'YYYY' - The year number in four digits. For example, in this format,
2005 would be represented as 2005.
- 'yy' or 'YY' - The last two digits of the year number. For example, in this format,
2005 would be represented as 05.
- 'MMMM' - The name of the month spelled in full. This format is supported only for output time. Note: This format is only supported for the output format.
- 'MMM' - The name of the month in three letters. For example, August would be represented as Aug.
- 'MM' - Month in two digits. If the month number is a single-digit number, it's displayed with a leading zero.
- 'M' - Month as a number from 1 to 12. If the month number is a single-digit number, it's displayed without a leading zero.
- 'dddd' or 'DDDD' - The full name of the day of the week. For example, Saturday is displayed in full. Note: This format is only supported for the output format.
- 'ddd' or 'DDD' - The abbreviated name of the day of the week in three letters. For example, Saturday is abbreviated as “Sat”.
- 'dd' or 'DD' - Day in two digits. If the day number is a single-digit number, it's displayed with a leading zero.
- 'd' or 'D' - Day as a number from 1 to 31. If the day number is a single-digit number, it's displayed without a leading zero.
- 'HH' - Hour in two digits using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed with a leading zero.
- 'H' - Hour as a number from 0 to 23 when using the 24-hour clock. For example, in this format, 1 pm would be represented as 13. If the hour number is a single-digit number, it's displayed without a leading zero.
- 'hh' - Hour in two digits using the 12-hour clock. For example, in this format, 1 pm would be represented as 01. If the hour number is a single-digit number, it's displayed with a leading zero.
- 'h' - Hour as a number from 1 to 12 when using the 12-hour clock. If the hour number is a single-digit number, it's displayed without a leading zero.
- 'mm' - Minutes in two digits. If the minute number is a single-digit number, it's displayed with a leading zero.
- 'm' - Minutes as a number from 0 to 59. If the minute number is a single-digit number, it's displayed without a leading zero.
- 'ss' - Seconds in two digits. If the second number is a single-digit number, it's displayed with a leading zero.
- 's' - Seconds as a number from 0 to 59. If the second number is a single-digit number, it's displayed without a leading zero.
- 'SSS' - Milliseconds in three digits. If the millisecond number is a single-digit number, it's displayed with a leading zero.
- 'tt' - A.M. or P.M. as two letters: AM or PM.


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_format">format</a>(<a href="./date.md#(date=0x0)_date">date</a>: &(<a href="./date.md#(date=0x0)_date">date</a>=0x0)::date::Date, <a href="./date.md#(date=0x0)_date_format">format</a>: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_format">format</a>(<a href="./date.md#(date=0x0)_date">date</a>: &<a href="./date.md#(date=0x0)_date_Date">Date</a>, <a href="./date.md#(date=0x0)_date_format">format</a>: vector&lt;u8&gt;): String {
    <b>let</b> months = <a href="./date.md#(date=0x0)_date_MONTHS">MONTHS</a>;
    <b>let</b> days = <a href="./date.md#(date=0x0)_date_DAYS">DAYS</a>;
    <b>let</b> months_full = <a href="./date.md#(date=0x0)_date_MONTH_NAMES">MONTH_NAMES</a>;
    <b>let</b> days_full = <a href="./date.md#(date=0x0)_date_DAYS_FULL">DAYS_FULL</a>;
    <b>let</b> <b>mut</b> formatted = vector[];
    <b>let</b> (<b>mut</b> i, len) = (0, <a href="./date.md#(date=0x0)_date_format">format</a>.length());
    <b>while</b> (i &lt; len) {
        match (<a href="./date.md#(date=0x0)_date_format">format</a>[i]) {
            // Year: yyyy / yy / y
            // prettier-ignore
            y @ (<a href="./date.md#(date=0x0)_date_Y">Y</a> | <a href="./date.md#(date=0x0)_date_YY">YY</a>) =&gt; <b>if</b> (
                i + 3 &lt; len && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == &y && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == &y && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 3] == &y
            ) {
                // The <a href="./date.md#(date=0x0)_date_year">year</a> number in four digits. For example, in this <a href="./date.md#(date=0x0)_date_format">format</a>, 2005 would be represented <b>as</b> 2005.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_year">year</a>, <b>false</b>));
                i = i + 3;
            } <b>else</b> <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == y) {
                // The last two digits of the <a href="./date.md#(date=0x0)_date_year">year</a> number. For example, in this <a href="./date.md#(date=0x0)_date_format">format</a>, 2005 would be represented <b>as</b> 05.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_year">year</a> % 100, <b>true</b>));
                i = i + 1;
            } <b>else</b> <b>abort</b> <a href="./date.md#(date=0x0)_date_EExpectedYear">EExpectedYear</a>,
            // Month: MMMM / MMM / <a href="./date.md#(date=0x0)_date_MM">MM</a> / <a href="./date.md#(date=0x0)_date_M">M</a>
            <a href="./date.md#(date=0x0)_date_M">M</a> =&gt; <b>if</b> (
                i + 3 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_M">M</a> && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == <a href="./date.md#(date=0x0)_date_M">M</a> && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 3] == <a href="./date.md#(date=0x0)_date_M">M</a>
            ) {
                // The name of the <a href="./date.md#(date=0x0)_date_month">month</a> spelled in full. This <a href="./date.md#(date=0x0)_date_format">format</a> is supported only <b>for</b> output time. Note: This <a href="./date.md#(date=0x0)_date_format">format</a> is only supported <b>for</b> the output <a href="./date.md#(date=0x0)_date_format">format</a>.
                formatted.append(months_full[<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> <b>as</b> u64]);
                i = i + 3;
            } <b>else</b> <b>if</b> (i + 2 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_M">M</a> && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == <a href="./date.md#(date=0x0)_date_M">M</a>) {
                // The name of the <a href="./date.md#(date=0x0)_date_month">month</a> in three letters. For example, August would be represented <b>as</b> Aug.
                formatted.append(months[<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> <b>as</b> u64]);
                i = i + 2;
            } <b>else</b> <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_M">M</a>) {
                // Month in two digits. If the <a href="./date.md#(date=0x0)_date_month">month</a> number is a single-digit number, it's displayed with a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> + 1, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Month <b>as</b> a number from 1 to 12. If the <a href="./date.md#(date=0x0)_date_month">month</a> number is a single-digit number, it's displayed without a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_month">month</a> + 1, <b>false</b>));
            },
            // Day: dddd / ddd / dd / d OR DDDD / DDD / <a href="./date.md#(date=0x0)_date_DD">DD</a> / <a href="./date.md#(date=0x0)_date_D">D</a>
            // prettier-ignore
            d @ (<a href="./date.md#(date=0x0)_date_D">D</a> | <a href="./date.md#(date=0x0)_date_DD">DD</a>) =&gt; <b>if</b> (
                i + 3 &lt; len && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == &d && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == &d && &<a href="./date.md#(date=0x0)_date_format">format</a>[i + 3] == &d
            ) {
                // The full name of the <a href="./date.md#(date=0x0)_date_day">day</a> of the week. For example, Saturday is displayed in full. Note: This <a href="./date.md#(date=0x0)_date_format">format</a> is only supported <b>for</b> the output <a href="./date.md#(date=0x0)_date_format">format</a>.
                formatted.append(days_full[<a href="./date.md#(date=0x0)_date">date</a>.day_of_week <b>as</b> u64]);
                i = i + 3;
            } <b>else</b> <b>if</b> (i + 2 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == d && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == d) {
                // The abbreviated name of the <a href="./date.md#(date=0x0)_date_day">day</a> of the week in three letters. For example, Saturday is abbreviated <b>as</b> “Sat”.
                formatted.append(days[<a href="./date.md#(date=0x0)_date">date</a>.day_of_week <b>as</b> u64]);
                i = i + 2;
            } <b>else</b> <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == d) {
                // Day in two digits. If the <a href="./date.md#(date=0x0)_date_day">day</a> number is a single-digit number, it's displayed with a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_day">day</a>, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Day <b>as</b> a number from 1 to 31. If the <a href="./date.md#(date=0x0)_date_day">day</a> number is a single-digit number, it's displayed without a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_day">day</a>, <b>false</b>));
            },
            // Hour: <a href="./date.md#(date=0x0)_date_HH">HH</a> / <a href="./date.md#(date=0x0)_date_H">H</a>
            <a href="./date.md#(date=0x0)_date_H">H</a> =&gt; <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_H">H</a>) {
                // Hour in two digits using the 24-<a href="./date.md#(date=0x0)_date_hour">hour</a> clock. For example, in this <a href="./date.md#(date=0x0)_date_format">format</a>, 1 pm would be represented <b>as</b> 13. If the <a href="./date.md#(date=0x0)_date_hour">hour</a> number is a single-digit number, it's displayed with a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Hour <b>as</b> a number from 0 to 23 when using the 24-<a href="./date.md#(date=0x0)_date_hour">hour</a> clock. For example, in this <a href="./date.md#(date=0x0)_date_format">format</a>, 1 pm would be represented <b>as</b> 13. If the <a href="./date.md#(date=0x0)_date_hour">hour</a> number is a single-digit number, it's displayed without a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>false</b>));
            },
            // Hour: hh / h
            <a href="./date.md#(date=0x0)_date_HH">HH</a> =&gt; <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_HH">HH</a>) {
                // Hour in two digits using the 12-<a href="./date.md#(date=0x0)_date_hour">hour</a> clock. For example, in this <a href="./date.md#(date=0x0)_date_format">format</a>, 1 pm would be represented <b>as</b> 01. If the <a href="./date.md#(date=0x0)_date_hour">hour</a> number is a single-digit number, it's displayed with a leading zero.
                <b>let</b> <a href="./date.md#(date=0x0)_date_hour">hour</a> = <b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> == 0) 12 <b>else</b> <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> % 12;
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Hour <b>as</b> a number from 1 to 12 when using the 12-<a href="./date.md#(date=0x0)_date_hour">hour</a> clock. If the <a href="./date.md#(date=0x0)_date_hour">hour</a> number is a single-digit number, it's displayed without a leading zero.
                <b>let</b> <a href="./date.md#(date=0x0)_date_hour">hour</a> = <b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> == 0) 12 <b>else</b> <a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> % 12;
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date_hour">hour</a>, <b>false</b>));
            },
            // Minute: m
            <a href="./date.md#(date=0x0)_date_MM">MM</a> =&gt; <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_MM">MM</a>) {
                // Minutes in two digits. If the <a href="./date.md#(date=0x0)_date_minute">minute</a> number is a single-digit number, it's displayed with a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_minute">minute</a>, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Minutes <b>as</b> a number from 0 to 59. If the <a href="./date.md#(date=0x0)_date_minute">minute</a> number is a single-digit number, it's displayed without a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_minute">minute</a>, <b>false</b>));
            },
            // Second: s
            <a href="./date.md#(date=0x0)_date_SS">SS</a> =&gt; <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_SS">SS</a>) {
                // Seconds in two digits. If the <a href="./date.md#(date=0x0)_date_second">second</a> number is a single-digit number, it's displayed with a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_second">second</a>, <b>true</b>));
                i = i + 1;
            } <b>else</b> {
                // Seconds <b>as</b> a number from 0 to 59. If the <a href="./date.md#(date=0x0)_date_second">second</a> number is a single-digit number, it's displayed without a leading zero.
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_second">second</a>, <b>false</b>));
            },
            // Millisecond: SSS
            <a href="./date.md#(date=0x0)_date_S">S</a> =&gt; <b>if</b> (i + 2 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_S">S</a> && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 2] == <a href="./date.md#(date=0x0)_date_S">S</a>) {
                // Milliseconds in three digits. If the millisecond number is a single-digit number, it's displayed with a leading zero.
                <b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.millisecond &lt; 100) formatted.push_back(char::zero!());
                formatted.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(<a href="./date.md#(date=0x0)_date">date</a>.millisecond, <b>true</b>));
                i = i + 2;
            } <b>else</b> <b>abort</b> <a href="./date.md#(date=0x0)_date_EExpectedSSS">EExpectedSSS</a>,
            // <a href="./date.md#(date=0x0)_date_TT">TT</a>: AM/PM
            <a href="./date.md#(date=0x0)_date_TT">TT</a> =&gt; <b>if</b> (i + 1 &lt; len && <a href="./date.md#(date=0x0)_date_format">format</a>[i + 1] == <a href="./date.md#(date=0x0)_date_TT">TT</a>) {
                // A.<a href="./date.md#(date=0x0)_date_M">M</a>. or P.<a href="./date.md#(date=0x0)_date_M">M</a>. <b>as</b> two letters: AM or PM.
                formatted.append(<b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.<a href="./date.md#(date=0x0)_date_hour">hour</a> &lt; 12) b"AM" <b>else</b> b"PM");
                i = i + 1;
            } <b>else</b> <b>abort</b> <a href="./date.md#(date=0x0)_date_EExpectedTT">EExpectedTT</a>,
            // <a href="./date.md#(date=0x0)_date_Z">Z</a>: <b>for</b> ISO 8601
            <a href="./date.md#(date=0x0)_date_Z">Z</a> <b>if</b> (<a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m != 720) =&gt; {
                formatted.append(<a href="./date.md#(date=0x0)_date_to_timezone_offset_byte_string">to_timezone_offset_byte_string</a>!(<a href="./date.md#(date=0x0)_date">date</a>.timezone_offset_m));
            },
            // Single quote. Used to escape text in the formatted string.
            // Once seen, scan next characters until another single quote is seen.
            <a href="./date.md#(date=0x0)_date_SINGLE_QUOTE">SINGLE_QUOTE</a> =&gt; 'search: {
                <b>let</b> <b>mut</b> agg = vector[];
                (i + 1).range_do!(len, |j| {
                    <b>if</b> (<a href="./date.md#(date=0x0)_date_format">format</a>[j] == <a href="./date.md#(date=0x0)_date_SINGLE_QUOTE">SINGLE_QUOTE</a>) {
                        i = j;
                        formatted.append(agg);
                        <b>return</b> 'search
                    };
                    agg.push_back(<a href="./date.md#(date=0x0)_date_format">format</a>[j]);
                });
            },
            _ =&gt; formatted.append(vector[<a href="./date.md#(date=0x0)_date_format">format</a>[i]]),
        };
        i = i + 1;
    };
    formatted.to_string()
}
</code></pre>



</details>

<a name="(date=0x0)_date_num_to_bytes"></a>

## Macro function `num_to_bytes`

Convert a <code>u16</code> number to a <code>vector&lt;u8&gt;</code>.


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>($num: _, $pad: bool): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>($num: _, $pad: bool): vector&lt;u8&gt; {
    <b>let</b> num = $num <b>as</b> u16;
    <b>let</b> zero = char::zero!() <b>as</b> u16;
    <b>if</b> (num &lt; 10) {
        <b>if</b> ($pad) vector[zero <b>as</b> u8, (num + zero) <b>as</b> u8] <b>else</b> vector[(num + zero) <b>as</b> u8]
    } <b>else</b> <b>if</b> (num &lt; 100) {
        vector[(num / 10 + zero) <b>as</b> u8, (num % 10 + zero) <b>as</b> u8]
    } <b>else</b> <b>if</b> (num &lt; 1000) {
        vector[(num / 100 + zero) <b>as</b> u8, (num / 10 % 10 + zero) <b>as</b> u8, (num % 10 + zero) <b>as</b> u8]
    } <b>else</b> {
        vector[
            (num / 1000 + zero) <b>as</b> u8,
            (num / 100 % 10 + zero) <b>as</b> u8,
            (num / 10 % 10 + zero) <b>as</b> u8,
            (num % 10 + zero) <b>as</b> u8,
        ]
    }
}
</code></pre>



</details>

<a name="(date=0x0)_date_to_timezone_offset_byte_string"></a>

## Macro function `to_timezone_offset_byte_string`

Convert a timezone offset in minutes to a string.
Currently not used due to lack of timezone support.


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_timezone_offset_byte_string">to_timezone_offset_byte_string</a>($offset_m: u16): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_to_timezone_offset_byte_string">to_timezone_offset_byte_string</a>($offset_m: u16): vector&lt;u8&gt; {
    <b>if</b> ($offset_m == 720) {
        <b>return</b> b"<a href="./date.md#(date=0x0)_date_Z">Z</a>"
    };
    <b>let</b> <b>mut</b> res = vector[];
    <b>let</b> (hours, minutes) = <b>if</b> ($offset_m &gt; 720) {
        // East
        res.push_back(char::plus!()); // + sign ASCII: 43
        <b>let</b> hours = ($offset_m - 720) / 60;
        <b>let</b> minutes = ($offset_m - 720) % 60;
        (hours, minutes)
    } <b>else</b> {
        // West
        res.push_back(char::minus!()); // - sign ASCII: 45
        <b>let</b> hours = (720 - $offset_m) / 60;
        <b>let</b> minutes = (720 - $offset_m) % 60;
        (hours, minutes)
    };
    res.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(hours, <b>true</b>));
    res.push_back(char::colon!()); // : sign ASCII: 58
    res.append(<a href="./date.md#(date=0x0)_date_num_to_bytes">num_to_bytes</a>!(minutes, <b>true</b>));
    res
}
</code></pre>



</details>

<a name="(date=0x0)_date_is_leap_year"></a>

## Macro function `is_leap_year`

Check if a year is a leap year.


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>($<a href="./date.md#(date=0x0)_date_year">year</a>: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_is_leap_year">is_leap_year</a>($<a href="./date.md#(date=0x0)_date_year">year</a>: u16): bool {
    ($<a href="./date.md#(date=0x0)_date_year">year</a> % 4 == 0 && $<a href="./date.md#(date=0x0)_date_year">year</a> % 100 != 0) || ($<a href="./date.md#(date=0x0)_date_year">year</a> % 400 == 0)
}
</code></pre>



</details>

<a name="(date=0x0)_date_parse_u16"></a>

## Macro function `parse_u16`

Parse <code>u16</code> from <code>vector&lt;u8&gt;</code>. This implementation is intentionally silly,
because we know that the max value is 4 digits.


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>($bytes: vector&lt;u8&gt;): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./date.md#(date=0x0)_date_parse_u16">parse_u16</a>($bytes: vector&lt;u8&gt;): u16 {
    <b>let</b> <b>mut</b> bytes = $bytes;
    bytes.reverse();
    // Skip leading zeros.
    <b>let</b> (<b>mut</b> res, len) = (0u16, bytes.length());
    len.do!(
        |i| match (bytes.pop_back()) {
            n @ _ <b>if</b> (*n &gt;= 48 && *n &lt;= 57) =&gt; {
                res = res + (n <b>as</b> u16 - 48) * 10u16.pow(((len - 1) - i) <b>as</b> u8);
            },
            _ =&gt; <b>abort</b>,
        },
    );
    res
}
</code></pre>



</details>
