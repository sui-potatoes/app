
<a name="ascii_control"></a>

# Module `ascii::control`

Defines ASCII control characters (range 0-31 and 127 (DELETE)).


-  [Macro function `is_control`](#ascii_control_is_control)
-  [Macro function `null`](#ascii_control_null)
-  [Macro function `start_of_heading`](#ascii_control_start_of_heading)
-  [Macro function `start_of_text`](#ascii_control_start_of_text)
-  [Macro function `end_of_text`](#ascii_control_end_of_text)
-  [Macro function `end_of_transmission`](#ascii_control_end_of_transmission)
-  [Macro function `enquiry`](#ascii_control_enquiry)
-  [Macro function `acknowledge`](#ascii_control_acknowledge)
-  [Macro function `bell`](#ascii_control_bell)
-  [Macro function `backspace`](#ascii_control_backspace)
-  [Macro function `horizontal_tab`](#ascii_control_horizontal_tab)
-  [Macro function `line_feed`](#ascii_control_line_feed)
-  [Macro function `vertical_tab`](#ascii_control_vertical_tab)
-  [Macro function `form_feed`](#ascii_control_form_feed)
-  [Macro function `carriage_return`](#ascii_control_carriage_return)
-  [Macro function `shift_out`](#ascii_control_shift_out)
-  [Macro function `shift_in`](#ascii_control_shift_in)
-  [Macro function `data_link_escape`](#ascii_control_data_link_escape)
-  [Macro function `device_control_1`](#ascii_control_device_control_1)
-  [Macro function `device_control_2`](#ascii_control_device_control_2)
-  [Macro function `device_control_3`](#ascii_control_device_control_3)
-  [Macro function `device_control_4`](#ascii_control_device_control_4)
-  [Macro function `negative_acknowledge`](#ascii_control_negative_acknowledge)
-  [Macro function `synchronous_idle`](#ascii_control_synchronous_idle)
-  [Macro function `end_of_transmission_block`](#ascii_control_end_of_transmission_block)
-  [Macro function `cancel`](#ascii_control_cancel)
-  [Macro function `end_of_medium`](#ascii_control_end_of_medium)
-  [Macro function `substitute`](#ascii_control_substitute)
-  [Macro function `escape`](#ascii_control_escape)
-  [Macro function `file_separator`](#ascii_control_file_separator)
-  [Macro function `group_separator`](#ascii_control_group_separator)
-  [Macro function `record_separator`](#ascii_control_record_separator)
-  [Macro function `unit_separator`](#ascii_control_unit_separator)
-  [Macro function `delete`](#ascii_control_delete)


<pre><code></code></pre>



<a name="ascii_control_is_control"></a>

## Macro function `is_control`

Check if a character is a control character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_is_control">is_control</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_is_control">is_control</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 31 || $<a href="../ascii/char.md#ascii_char">char</a> == 127 }
</code></pre>



</details>

<a name="ascii_control_null"></a>

## Macro function `null`

Null character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_null">null</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_null">null</a>(): u8 { 0 }
</code></pre>



</details>

<a name="ascii_control_start_of_heading"></a>

## Macro function `start_of_heading`

Start of heading character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_start_of_heading">start_of_heading</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_start_of_heading">start_of_heading</a>(): u8 { 1 }
</code></pre>



</details>

<a name="ascii_control_start_of_text"></a>

## Macro function `start_of_text`

Start of text character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_start_of_text">start_of_text</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_start_of_text">start_of_text</a>(): u8 { 2 }
</code></pre>



</details>

<a name="ascii_control_end_of_text"></a>

## Macro function `end_of_text`

End of text character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_text">end_of_text</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_text">end_of_text</a>(): u8 { 3 }
</code></pre>



</details>

<a name="ascii_control_end_of_transmission"></a>

## Macro function `end_of_transmission`

End of transmission character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_transmission">end_of_transmission</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_transmission">end_of_transmission</a>(): u8 { 4 }
</code></pre>



</details>

<a name="ascii_control_enquiry"></a>

## Macro function `enquiry`

Enquiry character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_enquiry">enquiry</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_enquiry">enquiry</a>(): u8 { 5 }
</code></pre>



</details>

<a name="ascii_control_acknowledge"></a>

## Macro function `acknowledge`

Acknowledge character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_acknowledge">acknowledge</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_acknowledge">acknowledge</a>(): u8 { 6 }
</code></pre>



</details>

<a name="ascii_control_bell"></a>

## Macro function `bell`

Bell character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_bell">bell</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_bell">bell</a>(): u8 { 7 }
</code></pre>



</details>

<a name="ascii_control_backspace"></a>

## Macro function `backspace`

Backspace character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_backspace">backspace</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_backspace">backspace</a>(): u8 { 8 }
</code></pre>



</details>

<a name="ascii_control_horizontal_tab"></a>

## Macro function `horizontal_tab`

Horizontal tab character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_horizontal_tab">horizontal_tab</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_horizontal_tab">horizontal_tab</a>(): u8 { 9 }
</code></pre>



</details>

<a name="ascii_control_line_feed"></a>

## Macro function `line_feed`

Line feed character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_line_feed">line_feed</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_line_feed">line_feed</a>(): u8 { 10 }
</code></pre>



</details>

<a name="ascii_control_vertical_tab"></a>

## Macro function `vertical_tab`

Vertical tab character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_vertical_tab">vertical_tab</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_vertical_tab">vertical_tab</a>(): u8 { 11 }
</code></pre>



</details>

<a name="ascii_control_form_feed"></a>

## Macro function `form_feed`

Form feed character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_form_feed">form_feed</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_form_feed">form_feed</a>(): u8 { 12 }
</code></pre>



</details>

<a name="ascii_control_carriage_return"></a>

## Macro function `carriage_return`

Carriage return character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_carriage_return">carriage_return</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_carriage_return">carriage_return</a>(): u8 { 13 }
</code></pre>



</details>

<a name="ascii_control_shift_out"></a>

## Macro function `shift_out`

Shift out character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_shift_out">shift_out</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_shift_out">shift_out</a>(): u8 { 14 }
</code></pre>



</details>

<a name="ascii_control_shift_in"></a>

## Macro function `shift_in`

Shift in character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_shift_in">shift_in</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_shift_in">shift_in</a>(): u8 { 15 }
</code></pre>



</details>

<a name="ascii_control_data_link_escape"></a>

## Macro function `data_link_escape`

Data link escape character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_data_link_escape">data_link_escape</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_data_link_escape">data_link_escape</a>(): u8 { 16 }
</code></pre>



</details>

<a name="ascii_control_device_control_1"></a>

## Macro function `device_control_1`

Device control 1 character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_1">device_control_1</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_1">device_control_1</a>(): u8 { 17 }
</code></pre>



</details>

<a name="ascii_control_device_control_2"></a>

## Macro function `device_control_2`

Device control 2 character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_2">device_control_2</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_2">device_control_2</a>(): u8 { 18 }
</code></pre>



</details>

<a name="ascii_control_device_control_3"></a>

## Macro function `device_control_3`

Device control 3 character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_3">device_control_3</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_3">device_control_3</a>(): u8 { 19 }
</code></pre>



</details>

<a name="ascii_control_device_control_4"></a>

## Macro function `device_control_4`

Device control 4 character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_4">device_control_4</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_device_control_4">device_control_4</a>(): u8 { 20 }
</code></pre>



</details>

<a name="ascii_control_negative_acknowledge"></a>

## Macro function `negative_acknowledge`

Negative acknowledge character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_negative_acknowledge">negative_acknowledge</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_negative_acknowledge">negative_acknowledge</a>(): u8 { 21 }
</code></pre>



</details>

<a name="ascii_control_synchronous_idle"></a>

## Macro function `synchronous_idle`

Synchronous idle character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_synchronous_idle">synchronous_idle</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_synchronous_idle">synchronous_idle</a>(): u8 { 22 }
</code></pre>



</details>

<a name="ascii_control_end_of_transmission_block"></a>

## Macro function `end_of_transmission_block`

End of transmission block character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_transmission_block">end_of_transmission_block</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_transmission_block">end_of_transmission_block</a>(): u8 { 23 }
</code></pre>



</details>

<a name="ascii_control_cancel"></a>

## Macro function `cancel`

Cancel character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_cancel">cancel</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_cancel">cancel</a>(): u8 { 24 }
</code></pre>



</details>

<a name="ascii_control_end_of_medium"></a>

## Macro function `end_of_medium`

End of medium character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_medium">end_of_medium</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_end_of_medium">end_of_medium</a>(): u8 { 25 }
</code></pre>



</details>

<a name="ascii_control_substitute"></a>

## Macro function `substitute`

Substitute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_substitute">substitute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_substitute">substitute</a>(): u8 { 26 }
</code></pre>



</details>

<a name="ascii_control_escape"></a>

## Macro function `escape`

Escape character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_escape">escape</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_escape">escape</a>(): u8 { 27 }
</code></pre>



</details>

<a name="ascii_control_file_separator"></a>

## Macro function `file_separator`

File separator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_file_separator">file_separator</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_file_separator">file_separator</a>(): u8 { 28 }
</code></pre>



</details>

<a name="ascii_control_group_separator"></a>

## Macro function `group_separator`

Group separator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_group_separator">group_separator</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_group_separator">group_separator</a>(): u8 { 29 }
</code></pre>



</details>

<a name="ascii_control_record_separator"></a>

## Macro function `record_separator`

Record separator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_record_separator">record_separator</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_record_separator">record_separator</a>(): u8 { 30 }
</code></pre>



</details>

<a name="ascii_control_unit_separator"></a>

## Macro function `unit_separator`

Unit separator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_unit_separator">unit_separator</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_unit_separator">unit_separator</a>(): u8 { 31 }
</code></pre>



</details>

<a name="ascii_control_delete"></a>

## Macro function `delete`

Delete character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_delete">delete</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/control.md#ascii_control_delete">delete</a>(): u8 { 127 }
</code></pre>



</details>
