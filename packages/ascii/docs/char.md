
<a name="ascii_char"></a>

# Module `ascii::char`

Table of non-extended, printable ASCII characters, each macro returns the
corresponding ASCII code.

- Lowercase letters are spelled without a prefix, eg <code><a href="../ascii/char.md#ascii_char_a">a</a></code> is the ASCII <code>97</code>.
- Uppercase letters are spelled in uppercase, eg <code><a href="../ascii/char.md#ascii_char_A">A</a></code> is the ASCII <code>65</code>.


-  [Macro function `is_printable`](#ascii_char_is_printable)
-  [Macro function `is_digit`](#ascii_char_is_digit)
-  [Macro function `is_letter`](#ascii_char_is_letter)
-  [Macro function `is_lowercase`](#ascii_char_is_lowercase)
-  [Macro function `is_uppercase`](#ascii_char_is_uppercase)
-  [Macro function `is_alphanumeric`](#ascii_char_is_alphanumeric)
-  [Macro function `space`](#ascii_char_space)
-  [Macro function `exclamation_mark`](#ascii_char_exclamation_mark)
-  [Macro function `double_quote`](#ascii_char_double_quote)
-  [Macro function `hash`](#ascii_char_hash)
-  [Macro function `dollar`](#ascii_char_dollar)
-  [Macro function `percent`](#ascii_char_percent)
-  [Macro function `ampersand`](#ascii_char_ampersand)
-  [Macro function `single_quote`](#ascii_char_single_quote)
-  [Macro function `left_paren`](#ascii_char_left_paren)
-  [Macro function `right_paren`](#ascii_char_right_paren)
-  [Macro function `asterisk`](#ascii_char_asterisk)
-  [Macro function `plus`](#ascii_char_plus)
-  [Macro function `comma`](#ascii_char_comma)
-  [Macro function `minus`](#ascii_char_minus)
-  [Macro function `period`](#ascii_char_period)
-  [Macro function `forward_slash`](#ascii_char_forward_slash)
-  [Macro function `zero`](#ascii_char_zero)
-  [Macro function `one`](#ascii_char_one)
-  [Macro function `two`](#ascii_char_two)
-  [Macro function `three`](#ascii_char_three)
-  [Macro function `four`](#ascii_char_four)
-  [Macro function `five`](#ascii_char_five)
-  [Macro function `six`](#ascii_char_six)
-  [Macro function `seven`](#ascii_char_seven)
-  [Macro function `eight`](#ascii_char_eight)
-  [Macro function `nine`](#ascii_char_nine)
-  [Macro function `colon`](#ascii_char_colon)
-  [Macro function `semicolon`](#ascii_char_semicolon)
-  [Macro function `less_than`](#ascii_char_less_than)
-  [Macro function `equals`](#ascii_char_equals)
-  [Macro function `greater_than`](#ascii_char_greater_than)
-  [Macro function `question_mark`](#ascii_char_question_mark)
-  [Macro function `at`](#ascii_char_at)
-  [Macro function `A`](#ascii_char_A)
-  [Macro function `B`](#ascii_char_B)
-  [Macro function `C`](#ascii_char_C)
-  [Macro function `D`](#ascii_char_D)
-  [Macro function `E`](#ascii_char_E)
-  [Macro function `F`](#ascii_char_F)
-  [Macro function `G`](#ascii_char_G)
-  [Macro function `H`](#ascii_char_H)
-  [Macro function `I`](#ascii_char_I)
-  [Macro function `J`](#ascii_char_J)
-  [Macro function `K`](#ascii_char_K)
-  [Macro function `L`](#ascii_char_L)
-  [Macro function `M`](#ascii_char_M)
-  [Macro function `N`](#ascii_char_N)
-  [Macro function `O`](#ascii_char_O)
-  [Macro function `P`](#ascii_char_P)
-  [Macro function `Q`](#ascii_char_Q)
-  [Macro function `R`](#ascii_char_R)
-  [Macro function `S`](#ascii_char_S)
-  [Macro function `T`](#ascii_char_T)
-  [Macro function `U`](#ascii_char_U)
-  [Macro function `V`](#ascii_char_V)
-  [Macro function `W`](#ascii_char_W)
-  [Macro function `X`](#ascii_char_X)
-  [Macro function `Y`](#ascii_char_Y)
-  [Macro function `Z`](#ascii_char_Z)
-  [Macro function `left_bracket`](#ascii_char_left_bracket)
-  [Macro function `backslash`](#ascii_char_backslash)
-  [Macro function `right_bracket`](#ascii_char_right_bracket)
-  [Macro function `caret`](#ascii_char_caret)
-  [Macro function `underscore`](#ascii_char_underscore)
-  [Macro function `backtick`](#ascii_char_backtick)
-  [Macro function `a`](#ascii_char_a)
-  [Macro function `b`](#ascii_char_b)
-  [Macro function `c`](#ascii_char_c)
-  [Macro function `d`](#ascii_char_d)
-  [Macro function `e`](#ascii_char_e)
-  [Macro function `f`](#ascii_char_f)
-  [Macro function `g`](#ascii_char_g)
-  [Macro function `h`](#ascii_char_h)
-  [Macro function `i`](#ascii_char_i)
-  [Macro function `j`](#ascii_char_j)
-  [Macro function `k`](#ascii_char_k)
-  [Macro function `l`](#ascii_char_l)
-  [Macro function `m`](#ascii_char_m)
-  [Macro function `n`](#ascii_char_n)
-  [Macro function `o`](#ascii_char_o)
-  [Macro function `p`](#ascii_char_p)
-  [Macro function `q`](#ascii_char_q)
-  [Macro function `r`](#ascii_char_r)
-  [Macro function `s`](#ascii_char_s)
-  [Macro function `t`](#ascii_char_t)
-  [Macro function `u`](#ascii_char_u)
-  [Macro function `v`](#ascii_char_v)
-  [Macro function `w`](#ascii_char_w)
-  [Macro function `x`](#ascii_char_x)
-  [Macro function `y`](#ascii_char_y)
-  [Macro function `z`](#ascii_char_z)
-  [Macro function `left_brace`](#ascii_char_left_brace)
-  [Macro function `vertical_bar`](#ascii_char_vertical_bar)
-  [Macro function `right_brace`](#ascii_char_right_brace)
-  [Macro function `tilde`](#ascii_char_tilde)


<pre><code></code></pre>



<a name="ascii_char_is_printable"></a>

## Macro function `is_printable`

Check if a character is printable.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_printable">is_printable</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_printable">is_printable</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 32 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 126 }
</code></pre>



</details>

<a name="ascii_char_is_digit"></a>

## Macro function `is_digit`

Check if a character is a digit.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_digit">is_digit</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_digit">is_digit</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 48 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 57 }
</code></pre>



</details>

<a name="ascii_char_is_letter"></a>

## Macro function `is_letter`

Check if a character is a letter.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_letter">is_letter</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_letter">is_letter</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 65 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 90 }
</code></pre>



</details>

<a name="ascii_char_is_lowercase"></a>

## Macro function `is_lowercase`

Check if a character is a lowercase letter.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_lowercase">is_lowercase</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_lowercase">is_lowercase</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 97 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 122 }
</code></pre>



</details>

<a name="ascii_char_is_uppercase"></a>

## Macro function `is_uppercase`

Check if a character is an uppercase letter.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_uppercase">is_uppercase</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_uppercase">is_uppercase</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool { $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 65 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 90 }
</code></pre>



</details>

<a name="ascii_char_is_alphanumeric"></a>

## Macro function `is_alphanumeric`

Check if a character is alphanumeric.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_alphanumeric">is_alphanumeric</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_is_alphanumeric">is_alphanumeric</a>($<a href="../ascii/char.md#ascii_char">char</a>: u8): bool {
    $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 48 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 57 || $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 65 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 90 || $<a href="../ascii/char.md#ascii_char">char</a> &gt;= 97 && $<a href="../ascii/char.md#ascii_char">char</a> &lt;= 122
}
</code></pre>



</details>

<a name="ascii_char_space"></a>

## Macro function `space`

Space character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_space">space</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_space">space</a>(): u8 { 32 }
</code></pre>



</details>

<a name="ascii_char_exclamation_mark"></a>

## Macro function `exclamation_mark`

Exclamation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_exclamation_mark">exclamation_mark</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_exclamation_mark">exclamation_mark</a>(): u8 { 33 }
</code></pre>



</details>

<a name="ascii_char_double_quote"></a>

## Macro function `double_quote`

Double quote character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_double_quote">double_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_double_quote">double_quote</a>(): u8 { 34 }
</code></pre>



</details>

<a name="ascii_char_hash"></a>

## Macro function `hash`

Hash character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_hash">hash</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_hash">hash</a>(): u8 { 35 }
</code></pre>



</details>

<a name="ascii_char_dollar"></a>

## Macro function `dollar`

Dollar character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_dollar">dollar</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_dollar">dollar</a>(): u8 { 36 }
</code></pre>



</details>

<a name="ascii_char_percent"></a>

## Macro function `percent`

Percent character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_percent">percent</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_percent">percent</a>(): u8 { 37 }
</code></pre>



</details>

<a name="ascii_char_ampersand"></a>

## Macro function `ampersand`

Ampersand character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_ampersand">ampersand</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_ampersand">ampersand</a>(): u8 { 38 }
</code></pre>



</details>

<a name="ascii_char_single_quote"></a>

## Macro function `single_quote`

Single quote character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_single_quote">single_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_single_quote">single_quote</a>(): u8 { 39 }
</code></pre>



</details>

<a name="ascii_char_left_paren"></a>

## Macro function `left_paren`

Left parenthesis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_paren">left_paren</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_paren">left_paren</a>(): u8 { 40 }
</code></pre>



</details>

<a name="ascii_char_right_paren"></a>

## Macro function `right_paren`

Right parenthesis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_paren">right_paren</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_paren">right_paren</a>(): u8 { 41 }
</code></pre>



</details>

<a name="ascii_char_asterisk"></a>

## Macro function `asterisk`

Asterisk character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_asterisk">asterisk</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_asterisk">asterisk</a>(): u8 { 42 }
</code></pre>



</details>

<a name="ascii_char_plus"></a>

## Macro function `plus`

Plus character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_plus">plus</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_plus">plus</a>(): u8 { 43 }
</code></pre>



</details>

<a name="ascii_char_comma"></a>

## Macro function `comma`

Comma character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_comma">comma</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_comma">comma</a>(): u8 { 44 }
</code></pre>



</details>

<a name="ascii_char_minus"></a>

## Macro function `minus`

Minus character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_minus">minus</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_minus">minus</a>(): u8 { 45 }
</code></pre>



</details>

<a name="ascii_char_period"></a>

## Macro function `period`

Period character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_period">period</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_period">period</a>(): u8 { 46 }
</code></pre>



</details>

<a name="ascii_char_forward_slash"></a>

## Macro function `forward_slash`

Forward slash character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_forward_slash">forward_slash</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_forward_slash">forward_slash</a>(): u8 { 47 }
</code></pre>



</details>

<a name="ascii_char_zero"></a>

## Macro function `zero`

Zero character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_zero">zero</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_zero">zero</a>(): u8 { 48 }
</code></pre>



</details>

<a name="ascii_char_one"></a>

## Macro function `one`

One character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_one">one</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_one">one</a>(): u8 { 49 }
</code></pre>



</details>

<a name="ascii_char_two"></a>

## Macro function `two`

Two character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_two">two</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_two">two</a>(): u8 { 50 }
</code></pre>



</details>

<a name="ascii_char_three"></a>

## Macro function `three`

Three character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_three">three</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_three">three</a>(): u8 { 51 }
</code></pre>



</details>

<a name="ascii_char_four"></a>

## Macro function `four`

Four character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_four">four</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_four">four</a>(): u8 { 52 }
</code></pre>



</details>

<a name="ascii_char_five"></a>

## Macro function `five`

Five character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_five">five</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_five">five</a>(): u8 { 53 }
</code></pre>



</details>

<a name="ascii_char_six"></a>

## Macro function `six`

Six character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_six">six</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_six">six</a>(): u8 { 54 }
</code></pre>



</details>

<a name="ascii_char_seven"></a>

## Macro function `seven`

Seven character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_seven">seven</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_seven">seven</a>(): u8 { 55 }
</code></pre>



</details>

<a name="ascii_char_eight"></a>

## Macro function `eight`

Eight character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_eight">eight</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_eight">eight</a>(): u8 { 56 }
</code></pre>



</details>

<a name="ascii_char_nine"></a>

## Macro function `nine`

Nine character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_nine">nine</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_nine">nine</a>(): u8 { 57 }
</code></pre>



</details>

<a name="ascii_char_colon"></a>

## Macro function `colon`

Colon character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_colon">colon</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_colon">colon</a>(): u8 { 58 }
</code></pre>



</details>

<a name="ascii_char_semicolon"></a>

## Macro function `semicolon`

Semicolon character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_semicolon">semicolon</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_semicolon">semicolon</a>(): u8 { 59 }
</code></pre>



</details>

<a name="ascii_char_less_than"></a>

## Macro function `less_than`

Less than character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_less_than">less_than</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_less_than">less_than</a>(): u8 { 60 }
</code></pre>



</details>

<a name="ascii_char_equals"></a>

## Macro function `equals`

Equals character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_equals">equals</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_equals">equals</a>(): u8 { 61 }
</code></pre>



</details>

<a name="ascii_char_greater_than"></a>

## Macro function `greater_than`

Greater than character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_greater_than">greater_than</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_greater_than">greater_than</a>(): u8 { 62 }
</code></pre>



</details>

<a name="ascii_char_question_mark"></a>

## Macro function `question_mark`

Question mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_question_mark">question_mark</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_question_mark">question_mark</a>(): u8 { 63 }
</code></pre>



</details>

<a name="ascii_char_at"></a>

## Macro function `at`

At sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_at">at</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_at">at</a>(): u8 { 64 }
</code></pre>



</details>

<a name="ascii_char_A"></a>

## Macro function `A`

Uppercase A character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_A">A</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_A">A</a>(): u8 { 65 }
</code></pre>



</details>

<a name="ascii_char_B"></a>

## Macro function `B`

Uppercase B character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_B">B</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_B">B</a>(): u8 { 66 }
</code></pre>



</details>

<a name="ascii_char_C"></a>

## Macro function `C`

Uppercase C character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_C">C</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_C">C</a>(): u8 { 67 }
</code></pre>



</details>

<a name="ascii_char_D"></a>

## Macro function `D`

Uppercase D character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_D">D</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_D">D</a>(): u8 { 68 }
</code></pre>



</details>

<a name="ascii_char_E"></a>

## Macro function `E`

Uppercase E character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_E">E</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_E">E</a>(): u8 { 69 }
</code></pre>



</details>

<a name="ascii_char_F"></a>

## Macro function `F`

Uppercase F character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_F">F</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_F">F</a>(): u8 { 70 }
</code></pre>



</details>

<a name="ascii_char_G"></a>

## Macro function `G`

Uppercase G character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_G">G</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_G">G</a>(): u8 { 71 }
</code></pre>



</details>

<a name="ascii_char_H"></a>

## Macro function `H`

Uppercase H character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_H">H</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_H">H</a>(): u8 { 72 }
</code></pre>



</details>

<a name="ascii_char_I"></a>

## Macro function `I`

Uppercase I character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_I">I</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_I">I</a>(): u8 { 73 }
</code></pre>



</details>

<a name="ascii_char_J"></a>

## Macro function `J`

Uppercase J character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_J">J</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_J">J</a>(): u8 { 74 }
</code></pre>



</details>

<a name="ascii_char_K"></a>

## Macro function `K`

Uppercase K character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_K">K</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_K">K</a>(): u8 { 75 }
</code></pre>



</details>

<a name="ascii_char_L"></a>

## Macro function `L`

Uppercase L character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_L">L</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_L">L</a>(): u8 { 76 }
</code></pre>



</details>

<a name="ascii_char_M"></a>

## Macro function `M`

Uppercase M character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_M">M</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_M">M</a>(): u8 { 77 }
</code></pre>



</details>

<a name="ascii_char_N"></a>

## Macro function `N`

Uppercase N character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_N">N</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_N">N</a>(): u8 { 78 }
</code></pre>



</details>

<a name="ascii_char_O"></a>

## Macro function `O`

Uppercase O character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_O">O</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_O">O</a>(): u8 { 79 }
</code></pre>



</details>

<a name="ascii_char_P"></a>

## Macro function `P`

Uppercase P character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_P">P</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_P">P</a>(): u8 { 80 }
</code></pre>



</details>

<a name="ascii_char_Q"></a>

## Macro function `Q`

Uppercase Q character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Q">Q</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Q">Q</a>(): u8 { 81 }
</code></pre>



</details>

<a name="ascii_char_R"></a>

## Macro function `R`

Uppercase R character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_R">R</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_R">R</a>(): u8 { 82 }
</code></pre>



</details>

<a name="ascii_char_S"></a>

## Macro function `S`

Uppercase S character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_S">S</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_S">S</a>(): u8 { 83 }
</code></pre>



</details>

<a name="ascii_char_T"></a>

## Macro function `T`

Uppercase T character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_T">T</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_T">T</a>(): u8 { 84 }
</code></pre>



</details>

<a name="ascii_char_U"></a>

## Macro function `U`

Uppercase U character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_U">U</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_U">U</a>(): u8 { 85 }
</code></pre>



</details>

<a name="ascii_char_V"></a>

## Macro function `V`

Uppercase V character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_V">V</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_V">V</a>(): u8 { 86 }
</code></pre>



</details>

<a name="ascii_char_W"></a>

## Macro function `W`

Uppercase W character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_W">W</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_W">W</a>(): u8 { 87 }
</code></pre>



</details>

<a name="ascii_char_X"></a>

## Macro function `X`

Uppercase X character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_X">X</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_X">X</a>(): u8 { 88 }
</code></pre>



</details>

<a name="ascii_char_Y"></a>

## Macro function `Y`

Uppercase Y character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Y">Y</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Y">Y</a>(): u8 { 89 }
</code></pre>



</details>

<a name="ascii_char_Z"></a>

## Macro function `Z`

Uppercase Z character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Z">Z</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_Z">Z</a>(): u8 { 90 }
</code></pre>



</details>

<a name="ascii_char_left_bracket"></a>

## Macro function `left_bracket`

Left square bracket character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_bracket">left_bracket</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_bracket">left_bracket</a>(): u8 { 91 }
</code></pre>



</details>

<a name="ascii_char_backslash"></a>

## Macro function `backslash`

Backslash character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_backslash">backslash</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_backslash">backslash</a>(): u8 { 92 }
</code></pre>



</details>

<a name="ascii_char_right_bracket"></a>

## Macro function `right_bracket`

Right square bracket character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_bracket">right_bracket</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_bracket">right_bracket</a>(): u8 { 93 }
</code></pre>



</details>

<a name="ascii_char_caret"></a>

## Macro function `caret`

Caret character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_caret">caret</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_caret">caret</a>(): u8 { 94 }
</code></pre>



</details>

<a name="ascii_char_underscore"></a>

## Macro function `underscore`

Underscore character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_underscore">underscore</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_underscore">underscore</a>(): u8 { 95 }
</code></pre>



</details>

<a name="ascii_char_backtick"></a>

## Macro function `backtick`

Backtick character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_backtick">backtick</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_backtick">backtick</a>(): u8 { 96 }
</code></pre>



</details>

<a name="ascii_char_a"></a>

## Macro function `a`

Lowercase a character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_a">a</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_a">a</a>(): u8 { 97 }
</code></pre>



</details>

<a name="ascii_char_b"></a>

## Macro function `b`

Lowercase b character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_b">b</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_b">b</a>(): u8 { 98 }
</code></pre>



</details>

<a name="ascii_char_c"></a>

## Macro function `c`

Lowercase c character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_c">c</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_c">c</a>(): u8 { 99 }
</code></pre>



</details>

<a name="ascii_char_d"></a>

## Macro function `d`

Lowercase d character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_d">d</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_d">d</a>(): u8 { 100 }
</code></pre>



</details>

<a name="ascii_char_e"></a>

## Macro function `e`

Lowercase e character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_e">e</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_e">e</a>(): u8 { 101 }
</code></pre>



</details>

<a name="ascii_char_f"></a>

## Macro function `f`

Lowercase f character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_f">f</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_f">f</a>(): u8 { 102 }
</code></pre>



</details>

<a name="ascii_char_g"></a>

## Macro function `g`

Lowercase g character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_g">g</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_g">g</a>(): u8 { 103 }
</code></pre>



</details>

<a name="ascii_char_h"></a>

## Macro function `h`

Lowercase h character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_h">h</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_h">h</a>(): u8 { 104 }
</code></pre>



</details>

<a name="ascii_char_i"></a>

## Macro function `i`

Lowercase i character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_i">i</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_i">i</a>(): u8 { 105 }
</code></pre>



</details>

<a name="ascii_char_j"></a>

## Macro function `j`

Lowercase j character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_j">j</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_j">j</a>(): u8 { 106 }
</code></pre>



</details>

<a name="ascii_char_k"></a>

## Macro function `k`

Lowercase k character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_k">k</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_k">k</a>(): u8 { 107 }
</code></pre>



</details>

<a name="ascii_char_l"></a>

## Macro function `l`

Lowercase l character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_l">l</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_l">l</a>(): u8 { 108 }
</code></pre>



</details>

<a name="ascii_char_m"></a>

## Macro function `m`

Lowercase m character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_m">m</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_m">m</a>(): u8 { 109 }
</code></pre>



</details>

<a name="ascii_char_n"></a>

## Macro function `n`

Lowercase n character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_n">n</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_n">n</a>(): u8 { 110 }
</code></pre>



</details>

<a name="ascii_char_o"></a>

## Macro function `o`

Lowercase o character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_o">o</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_o">o</a>(): u8 { 111 }
</code></pre>



</details>

<a name="ascii_char_p"></a>

## Macro function `p`

Lowercase p character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_p">p</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_p">p</a>(): u8 { 112 }
</code></pre>



</details>

<a name="ascii_char_q"></a>

## Macro function `q`

Lowercase q character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_q">q</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_q">q</a>(): u8 { 113 }
</code></pre>



</details>

<a name="ascii_char_r"></a>

## Macro function `r`

Lowercase r character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_r">r</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_r">r</a>(): u8 { 114 }
</code></pre>



</details>

<a name="ascii_char_s"></a>

## Macro function `s`

Lowercase s character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_s">s</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_s">s</a>(): u8 { 115 }
</code></pre>



</details>

<a name="ascii_char_t"></a>

## Macro function `t`

Lowercase t character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_t">t</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_t">t</a>(): u8 { 116 }
</code></pre>



</details>

<a name="ascii_char_u"></a>

## Macro function `u`

Lowercase u character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_u">u</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_u">u</a>(): u8 { 117 }
</code></pre>



</details>

<a name="ascii_char_v"></a>

## Macro function `v`

Lowercase v character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_v">v</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_v">v</a>(): u8 { 118 }
</code></pre>



</details>

<a name="ascii_char_w"></a>

## Macro function `w`

Lowercase w character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_w">w</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_w">w</a>(): u8 { 119 }
</code></pre>



</details>

<a name="ascii_char_x"></a>

## Macro function `x`

Lowercase x character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_x">x</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_x">x</a>(): u8 { 120 }
</code></pre>



</details>

<a name="ascii_char_y"></a>

## Macro function `y`

Lowercase y character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_y">y</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_y">y</a>(): u8 { 121 }
</code></pre>



</details>

<a name="ascii_char_z"></a>

## Macro function `z`

Lowercase z character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_z">z</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_z">z</a>(): u8 { 122 }
</code></pre>



</details>

<a name="ascii_char_left_brace"></a>

## Macro function `left_brace`

Left curly brace character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_brace">left_brace</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_left_brace">left_brace</a>(): u8 { 123 }
</code></pre>



</details>

<a name="ascii_char_vertical_bar"></a>

## Macro function `vertical_bar`

Vertical bar character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_vertical_bar">vertical_bar</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_vertical_bar">vertical_bar</a>(): u8 { 124 }
</code></pre>



</details>

<a name="ascii_char_right_brace"></a>

## Macro function `right_brace`

Right curly brace character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_brace">right_brace</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_right_brace">right_brace</a>(): u8 { 125 }
</code></pre>



</details>

<a name="ascii_char_tilde"></a>

## Macro function `tilde`

Tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_tilde">tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../ascii/char.md#ascii_char_tilde">tilde</a>(): u8 { 126 }
</code></pre>



</details>
