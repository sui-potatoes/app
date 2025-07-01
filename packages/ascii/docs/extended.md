
<a name="ascii_extended"></a>

# Module `ascii::extended`

Defines ASCII extended characters (range 128-255).

All characters are defined as macros, so they can be used in <code>all!</code> checks.

- Characters that mark capital letters have uppercase letter + suffix, eg <code><a href="./extended.md#ascii_extended_A_grave">A_grave</a>()</code>.
- Characters that mark lowercase letters have lowercase letter + suffix, eg <code><a href="./extended.md#ascii_extended_a_grave">a_grave</a>()</code>.


-  [Macro function `is_extended`](#ascii_extended_is_extended)
-  [Macro function `euro_sign`](#ascii_extended_euro_sign)
-  [Macro function `not_used_129`](#ascii_extended_not_used_129)
-  [Macro function `single_low_quote`](#ascii_extended_single_low_quote)
-  [Macro function `function`](#ascii_extended_function)
-  [Macro function `double_low_quote`](#ascii_extended_double_low_quote)
-  [Macro function `ellipsis`](#ascii_extended_ellipsis)
-  [Macro function `dagger`](#ascii_extended_dagger)
-  [Macro function `double_dagger`](#ascii_extended_double_dagger)
-  [Macro function `circumflex`](#ascii_extended_circumflex)
-  [Macro function `per_mille`](#ascii_extended_per_mille)
-  [Macro function `S_caron`](#ascii_extended_S_caron)
-  [Macro function `single_left_angle_quote`](#ascii_extended_single_left_angle_quote)
-  [Macro function `OE`](#ascii_extended_OE)
-  [Macro function `not_used_141`](#ascii_extended_not_used_141)
-  [Macro function `Z_caron`](#ascii_extended_Z_caron)
-  [Macro function `not_used_143`](#ascii_extended_not_used_143)
-  [Macro function `not_used_144`](#ascii_extended_not_used_144)
-  [Macro function `left_single_quote`](#ascii_extended_left_single_quote)
-  [Macro function `right_single_quote`](#ascii_extended_right_single_quote)
-  [Macro function `left_double_quote`](#ascii_extended_left_double_quote)
-  [Macro function `right_double_quote`](#ascii_extended_right_double_quote)
-  [Macro function `bullet`](#ascii_extended_bullet)
-  [Macro function `en_dash`](#ascii_extended_en_dash)
-  [Macro function `em_dash`](#ascii_extended_em_dash)
-  [Macro function `small_tilde`](#ascii_extended_small_tilde)
-  [Macro function `trade_mark`](#ascii_extended_trade_mark)
-  [Macro function `s_caron`](#ascii_extended_s_caron)
-  [Macro function `single_right_angle_quote`](#ascii_extended_single_right_angle_quote)
-  [Macro function `oe`](#ascii_extended_oe)
-  [Macro function `not_used_157`](#ascii_extended_not_used_157)
-  [Macro function `z_caron`](#ascii_extended_z_caron)
-  [Macro function `Y_diaeresis`](#ascii_extended_Y_diaeresis)
-  [Macro function `non_breaking_space`](#ascii_extended_non_breaking_space)
-  [Macro function `inverted_exclamation`](#ascii_extended_inverted_exclamation)
-  [Macro function `cent`](#ascii_extended_cent)
-  [Macro function `pound`](#ascii_extended_pound)
-  [Macro function `currency`](#ascii_extended_currency)
-  [Macro function `yen`](#ascii_extended_yen)
-  [Macro function `broken_vertical_bar`](#ascii_extended_broken_vertical_bar)
-  [Macro function `section`](#ascii_extended_section)
-  [Macro function `diaeresis`](#ascii_extended_diaeresis)
-  [Macro function `copyright`](#ascii_extended_copyright)
-  [Macro function `feminine_ordinal`](#ascii_extended_feminine_ordinal)
-  [Macro function `left_double_angle_quote`](#ascii_extended_left_double_angle_quote)
-  [Macro function `not`](#ascii_extended_not)
-  [Macro function `soft_hyphen`](#ascii_extended_soft_hyphen)
-  [Macro function `registered`](#ascii_extended_registered)
-  [Macro function `macron`](#ascii_extended_macron)
-  [Macro function `degree`](#ascii_extended_degree)
-  [Macro function `plus_minus`](#ascii_extended_plus_minus)
-  [Macro function `superscript_two`](#ascii_extended_superscript_two)
-  [Macro function `superscript_three`](#ascii_extended_superscript_three)
-  [Macro function `acute`](#ascii_extended_acute)
-  [Macro function `micro`](#ascii_extended_micro)
-  [Macro function `pilcrow`](#ascii_extended_pilcrow)
-  [Macro function `middle_dot`](#ascii_extended_middle_dot)
-  [Macro function `cedilla`](#ascii_extended_cedilla)
-  [Macro function `superscript_one`](#ascii_extended_superscript_one)
-  [Macro function `masculine_ordinal`](#ascii_extended_masculine_ordinal)
-  [Macro function `right_double_angle_quote`](#ascii_extended_right_double_angle_quote)
-  [Macro function `one_quarter`](#ascii_extended_one_quarter)
-  [Macro function `one_half`](#ascii_extended_one_half)
-  [Macro function `three_quarters`](#ascii_extended_three_quarters)
-  [Macro function `inverted_question`](#ascii_extended_inverted_question)
-  [Macro function `A_grave`](#ascii_extended_A_grave)
-  [Macro function `A_acute`](#ascii_extended_A_acute)
-  [Macro function `A_circumflex`](#ascii_extended_A_circumflex)
-  [Macro function `A_tilde`](#ascii_extended_A_tilde)
-  [Macro function `A_diaeresis`](#ascii_extended_A_diaeresis)
-  [Macro function `A_ring`](#ascii_extended_A_ring)
-  [Macro function `AE`](#ascii_extended_AE)
-  [Macro function `C_cedilla`](#ascii_extended_C_cedilla)
-  [Macro function `E_grave`](#ascii_extended_E_grave)
-  [Macro function `E_acute`](#ascii_extended_E_acute)
-  [Macro function `E_circumflex`](#ascii_extended_E_circumflex)
-  [Macro function `E_diaeresis`](#ascii_extended_E_diaeresis)
-  [Macro function `I_grave`](#ascii_extended_I_grave)
-  [Macro function `I_acute`](#ascii_extended_I_acute)
-  [Macro function `I_circumflex`](#ascii_extended_I_circumflex)
-  [Macro function `I_diaeresis`](#ascii_extended_I_diaeresis)
-  [Macro function `ETH`](#ascii_extended_ETH)
-  [Macro function `N_tilde`](#ascii_extended_N_tilde)
-  [Macro function `O_grave`](#ascii_extended_O_grave)
-  [Macro function `O_acute`](#ascii_extended_O_acute)
-  [Macro function `O_circumflex`](#ascii_extended_O_circumflex)
-  [Macro function `O_tilde`](#ascii_extended_O_tilde)
-  [Macro function `O_diaeresis`](#ascii_extended_O_diaeresis)
-  [Macro function `multiplication`](#ascii_extended_multiplication)
-  [Macro function `O_stroke`](#ascii_extended_O_stroke)
-  [Macro function `U_grave`](#ascii_extended_U_grave)
-  [Macro function `U_acute`](#ascii_extended_U_acute)
-  [Macro function `U_circumflex`](#ascii_extended_U_circumflex)
-  [Macro function `U_diaeresis`](#ascii_extended_U_diaeresis)
-  [Macro function `Y_acute`](#ascii_extended_Y_acute)
-  [Macro function `THORN`](#ascii_extended_THORN)
-  [Macro function `sharp_s`](#ascii_extended_sharp_s)
-  [Macro function `a_grave`](#ascii_extended_a_grave)
-  [Macro function `a_acute`](#ascii_extended_a_acute)
-  [Macro function `a_circumflex`](#ascii_extended_a_circumflex)
-  [Macro function `a_tilde`](#ascii_extended_a_tilde)
-  [Macro function `a_diaeresis`](#ascii_extended_a_diaeresis)
-  [Macro function `a_ring`](#ascii_extended_a_ring)
-  [Macro function `ae`](#ascii_extended_ae)
-  [Macro function `c_cedilla`](#ascii_extended_c_cedilla)
-  [Macro function `e_grave`](#ascii_extended_e_grave)
-  [Macro function `e_acute`](#ascii_extended_e_acute)
-  [Macro function `e_circumflex`](#ascii_extended_e_circumflex)
-  [Macro function `e_diaeresis`](#ascii_extended_e_diaeresis)
-  [Macro function `i_grave`](#ascii_extended_i_grave)
-  [Macro function `i_acute`](#ascii_extended_i_acute)
-  [Macro function `i_circumflex`](#ascii_extended_i_circumflex)
-  [Macro function `i_diaeresis`](#ascii_extended_i_diaeresis)
-  [Macro function `eth`](#ascii_extended_eth)
-  [Macro function `n_tilde`](#ascii_extended_n_tilde)
-  [Macro function `o_grave`](#ascii_extended_o_grave)
-  [Macro function `o_acute`](#ascii_extended_o_acute)
-  [Macro function `o_circumflex`](#ascii_extended_o_circumflex)
-  [Macro function `o_tilde`](#ascii_extended_o_tilde)
-  [Macro function `o_diaeresis`](#ascii_extended_o_diaeresis)
-  [Macro function `division`](#ascii_extended_division)
-  [Macro function `o_stroke`](#ascii_extended_o_stroke)
-  [Macro function `u_grave`](#ascii_extended_u_grave)
-  [Macro function `u_acute`](#ascii_extended_u_acute)
-  [Macro function `u_circumflex`](#ascii_extended_u_circumflex)
-  [Macro function `u_diaeresis`](#ascii_extended_u_diaeresis)
-  [Macro function `y_acute`](#ascii_extended_y_acute)
-  [Macro function `thorn`](#ascii_extended_thorn)
-  [Macro function `y_diaeresis`](#ascii_extended_y_diaeresis)


<pre><code></code></pre>



<a name="ascii_extended_is_extended"></a>

## Macro function `is_extended`

Check if a character is an extended character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_is_extended">is_extended</a>($<a href="./char.md#ascii_char">char</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_is_extended">is_extended</a>($<a href="./char.md#ascii_char">char</a>: u8): bool { $<a href="./char.md#ascii_char">char</a> &gt;= 128 && $<a href="./char.md#ascii_char">char</a> &lt;= 255 }
</code></pre>



</details>

<a name="ascii_extended_euro_sign"></a>

## Macro function `euro_sign`

Euro sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_euro_sign">euro_sign</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_euro_sign">euro_sign</a>(): u8 { 128 }
</code></pre>



</details>

<a name="ascii_extended_not_used_129"></a>

## Macro function `not_used_129`

Not used character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_129">not_used_129</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_129">not_used_129</a>(): u8 { 129 }
</code></pre>



</details>

<a name="ascii_extended_single_low_quote"></a>

## Macro function `single_low_quote`

Single low quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_low_quote">single_low_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_low_quote">single_low_quote</a>(): u8 { 130 }
</code></pre>



</details>

<a name="ascii_extended_function"></a>

## Macro function `function`

Function symbol character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_function">function</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_function">function</a>(): u8 { 131 }
</code></pre>



</details>

<a name="ascii_extended_double_low_quote"></a>

## Macro function `double_low_quote`

Double low quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_double_low_quote">double_low_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_double_low_quote">double_low_quote</a>(): u8 { 132 }
</code></pre>



</details>

<a name="ascii_extended_ellipsis"></a>

## Macro function `ellipsis`

Horizontal ellipsis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ellipsis">ellipsis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ellipsis">ellipsis</a>(): u8 { 133 }
</code></pre>



</details>

<a name="ascii_extended_dagger"></a>

## Macro function `dagger`

Dagger character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_dagger">dagger</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_dagger">dagger</a>(): u8 { 134 }
</code></pre>



</details>

<a name="ascii_extended_double_dagger"></a>

## Macro function `double_dagger`

Double dagger character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_double_dagger">double_dagger</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_double_dagger">double_dagger</a>(): u8 { 135 }
</code></pre>



</details>

<a name="ascii_extended_circumflex"></a>

## Macro function `circumflex`

Circumflex accent character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_circumflex">circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_circumflex">circumflex</a>(): u8 { 136 }
</code></pre>



</details>

<a name="ascii_extended_per_mille"></a>

## Macro function `per_mille`

Per mille sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_per_mille">per_mille</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_per_mille">per_mille</a>(): u8 { 137 }
</code></pre>



</details>

<a name="ascii_extended_S_caron"></a>

## Macro function `S_caron`

Latin capital letter S with caron character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_S_caron">S_caron</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_S_caron">S_caron</a>(): u8 { 138 }
</code></pre>



</details>

<a name="ascii_extended_single_left_angle_quote"></a>

## Macro function `single_left_angle_quote`

Single left angle quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_left_angle_quote">single_left_angle_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_left_angle_quote">single_left_angle_quote</a>(): u8 { 139 }
</code></pre>



</details>

<a name="ascii_extended_OE"></a>

## Macro function `OE`

Latin capital ligature OE character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_OE">OE</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_OE">OE</a>(): u8 { 140 }
</code></pre>



</details>

<a name="ascii_extended_not_used_141"></a>

## Macro function `not_used_141`

Not used character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_141">not_used_141</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_141">not_used_141</a>(): u8 { 141 }
</code></pre>



</details>

<a name="ascii_extended_Z_caron"></a>

## Macro function `Z_caron`

Latin capital letter Z with caron character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Z_caron">Z_caron</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Z_caron">Z_caron</a>(): u8 { 142 }
</code></pre>



</details>

<a name="ascii_extended_not_used_143"></a>

## Macro function `not_used_143`

Not used character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_143">not_used_143</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_143">not_used_143</a>(): u8 { 143 }
</code></pre>



</details>

<a name="ascii_extended_not_used_144"></a>

## Macro function `not_used_144`

Not used character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_144">not_used_144</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_144">not_used_144</a>(): u8 { 144 }
</code></pre>



</details>

<a name="ascii_extended_left_single_quote"></a>

## Macro function `left_single_quote`

Left single quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_single_quote">left_single_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_single_quote">left_single_quote</a>(): u8 { 145 }
</code></pre>



</details>

<a name="ascii_extended_right_single_quote"></a>

## Macro function `right_single_quote`

Right single quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_single_quote">right_single_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_single_quote">right_single_quote</a>(): u8 { 146 }
</code></pre>



</details>

<a name="ascii_extended_left_double_quote"></a>

## Macro function `left_double_quote`

Left double quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_double_quote">left_double_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_double_quote">left_double_quote</a>(): u8 { 147 }
</code></pre>



</details>

<a name="ascii_extended_right_double_quote"></a>

## Macro function `right_double_quote`

Right double quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_double_quote">right_double_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_double_quote">right_double_quote</a>(): u8 { 148 }
</code></pre>



</details>

<a name="ascii_extended_bullet"></a>

## Macro function `bullet`

Bullet character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_bullet">bullet</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_bullet">bullet</a>(): u8 { 149 }
</code></pre>



</details>

<a name="ascii_extended_en_dash"></a>

## Macro function `en_dash`

En dash character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_en_dash">en_dash</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_en_dash">en_dash</a>(): u8 { 150 }
</code></pre>



</details>

<a name="ascii_extended_em_dash"></a>

## Macro function `em_dash`

Em dash character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_em_dash">em_dash</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_em_dash">em_dash</a>(): u8 { 151 }
</code></pre>



</details>

<a name="ascii_extended_small_tilde"></a>

## Macro function `small_tilde`

Small tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_small_tilde">small_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_small_tilde">small_tilde</a>(): u8 { 152 }
</code></pre>



</details>

<a name="ascii_extended_trade_mark"></a>

## Macro function `trade_mark`

Trade mark sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_trade_mark">trade_mark</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_trade_mark">trade_mark</a>(): u8 { 153 }
</code></pre>



</details>

<a name="ascii_extended_s_caron"></a>

## Macro function `s_caron`

Latin small letter s with caron character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_s_caron">s_caron</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_s_caron">s_caron</a>(): u8 { 154 }
</code></pre>



</details>

<a name="ascii_extended_single_right_angle_quote"></a>

## Macro function `single_right_angle_quote`

Single right angle quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_right_angle_quote">single_right_angle_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_single_right_angle_quote">single_right_angle_quote</a>(): u8 { 155 }
</code></pre>



</details>

<a name="ascii_extended_oe"></a>

## Macro function `oe`

Latin small ligature oe character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_oe">oe</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_oe">oe</a>(): u8 { 156 }
</code></pre>



</details>

<a name="ascii_extended_not_used_157"></a>

## Macro function `not_used_157`

Not used character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_157">not_used_157</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not_used_157">not_used_157</a>(): u8 { 157 }
</code></pre>



</details>

<a name="ascii_extended_z_caron"></a>

## Macro function `z_caron`

Latin small letter z with caron character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_z_caron">z_caron</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_z_caron">z_caron</a>(): u8 { 158 }
</code></pre>



</details>

<a name="ascii_extended_Y_diaeresis"></a>

## Macro function `Y_diaeresis`

Latin capital letter Y with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Y_diaeresis">Y_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Y_diaeresis">Y_diaeresis</a>(): u8 { 159 }
</code></pre>



</details>

<a name="ascii_extended_non_breaking_space"></a>

## Macro function `non_breaking_space`

Non-breaking space character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_non_breaking_space">non_breaking_space</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_non_breaking_space">non_breaking_space</a>(): u8 { 160 }
</code></pre>



</details>

<a name="ascii_extended_inverted_exclamation"></a>

## Macro function `inverted_exclamation`

Inverted exclamation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_inverted_exclamation">inverted_exclamation</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_inverted_exclamation">inverted_exclamation</a>(): u8 { 161 }
</code></pre>



</details>

<a name="ascii_extended_cent"></a>

## Macro function `cent`

Cent sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_cent">cent</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_cent">cent</a>(): u8 { 162 }
</code></pre>



</details>

<a name="ascii_extended_pound"></a>

## Macro function `pound`

Pound sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_pound">pound</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_pound">pound</a>(): u8 { 163 }
</code></pre>



</details>

<a name="ascii_extended_currency"></a>

## Macro function `currency`

Currency sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_currency">currency</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_currency">currency</a>(): u8 { 164 }
</code></pre>



</details>

<a name="ascii_extended_yen"></a>

## Macro function `yen`

Yen sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_yen">yen</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_yen">yen</a>(): u8 { 165 }
</code></pre>



</details>

<a name="ascii_extended_broken_vertical_bar"></a>

## Macro function `broken_vertical_bar`

Broken vertical bar character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_broken_vertical_bar">broken_vertical_bar</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_broken_vertical_bar">broken_vertical_bar</a>(): u8 { 166 }
</code></pre>



</details>

<a name="ascii_extended_section"></a>

## Macro function `section`

Section sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_section">section</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_section">section</a>(): u8 { 167 }
</code></pre>



</details>

<a name="ascii_extended_diaeresis"></a>

## Macro function `diaeresis`

Diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_diaeresis">diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_diaeresis">diaeresis</a>(): u8 { 168 }
</code></pre>



</details>

<a name="ascii_extended_copyright"></a>

## Macro function `copyright`

Copyright sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_copyright">copyright</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_copyright">copyright</a>(): u8 { 169 }
</code></pre>



</details>

<a name="ascii_extended_feminine_ordinal"></a>

## Macro function `feminine_ordinal`

Feminine ordinal indicator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_feminine_ordinal">feminine_ordinal</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_feminine_ordinal">feminine_ordinal</a>(): u8 { 170 }
</code></pre>



</details>

<a name="ascii_extended_left_double_angle_quote"></a>

## Macro function `left_double_angle_quote`

Left double angle quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_double_angle_quote">left_double_angle_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_left_double_angle_quote">left_double_angle_quote</a>(): u8 { 171 }
</code></pre>



</details>

<a name="ascii_extended_not"></a>

## Macro function `not`

Not sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not">not</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_not">not</a>(): u8 { 172 }
</code></pre>



</details>

<a name="ascii_extended_soft_hyphen"></a>

## Macro function `soft_hyphen`

Soft hyphen character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_soft_hyphen">soft_hyphen</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_soft_hyphen">soft_hyphen</a>(): u8 { 173 }
</code></pre>



</details>

<a name="ascii_extended_registered"></a>

## Macro function `registered`

Registered trade mark sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_registered">registered</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_registered">registered</a>(): u8 { 174 }
</code></pre>



</details>

<a name="ascii_extended_macron"></a>

## Macro function `macron`

Macron character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_macron">macron</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_macron">macron</a>(): u8 { 175 }
</code></pre>



</details>

<a name="ascii_extended_degree"></a>

## Macro function `degree`

Degree sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_degree">degree</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_degree">degree</a>(): u8 { 176 }
</code></pre>



</details>

<a name="ascii_extended_plus_minus"></a>

## Macro function `plus_minus`

Plus-minus sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_plus_minus">plus_minus</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_plus_minus">plus_minus</a>(): u8 { 177 }
</code></pre>



</details>

<a name="ascii_extended_superscript_two"></a>

## Macro function `superscript_two`

Superscript two character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_two">superscript_two</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_two">superscript_two</a>(): u8 { 178 }
</code></pre>



</details>

<a name="ascii_extended_superscript_three"></a>

## Macro function `superscript_three`

Superscript three character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_three">superscript_three</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_three">superscript_three</a>(): u8 { 179 }
</code></pre>



</details>

<a name="ascii_extended_acute"></a>

## Macro function `acute`

Acute accent character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_acute">acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_acute">acute</a>(): u8 { 180 }
</code></pre>



</details>

<a name="ascii_extended_micro"></a>

## Macro function `micro`

Micro sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_micro">micro</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_micro">micro</a>(): u8 { 181 }
</code></pre>



</details>

<a name="ascii_extended_pilcrow"></a>

## Macro function `pilcrow`

Pilcrow sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_pilcrow">pilcrow</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_pilcrow">pilcrow</a>(): u8 { 182 }
</code></pre>



</details>

<a name="ascii_extended_middle_dot"></a>

## Macro function `middle_dot`

Middle dot character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_middle_dot">middle_dot</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_middle_dot">middle_dot</a>(): u8 { 183 }
</code></pre>



</details>

<a name="ascii_extended_cedilla"></a>

## Macro function `cedilla`

Cedilla character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_cedilla">cedilla</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_cedilla">cedilla</a>(): u8 { 184 }
</code></pre>



</details>

<a name="ascii_extended_superscript_one"></a>

## Macro function `superscript_one`

Superscript one character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_one">superscript_one</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_superscript_one">superscript_one</a>(): u8 { 185 }
</code></pre>



</details>

<a name="ascii_extended_masculine_ordinal"></a>

## Macro function `masculine_ordinal`

Masculine ordinal indicator character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_masculine_ordinal">masculine_ordinal</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_masculine_ordinal">masculine_ordinal</a>(): u8 { 186 }
</code></pre>



</details>

<a name="ascii_extended_right_double_angle_quote"></a>

## Macro function `right_double_angle_quote`

Right double angle quotation mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_double_angle_quote">right_double_angle_quote</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_right_double_angle_quote">right_double_angle_quote</a>(): u8 { 187 }
</code></pre>



</details>

<a name="ascii_extended_one_quarter"></a>

## Macro function `one_quarter`

Vulgar fraction one quarter character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_one_quarter">one_quarter</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_one_quarter">one_quarter</a>(): u8 { 188 }
</code></pre>



</details>

<a name="ascii_extended_one_half"></a>

## Macro function `one_half`

Vulgar fraction one half character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_one_half">one_half</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_one_half">one_half</a>(): u8 { 189 }
</code></pre>



</details>

<a name="ascii_extended_three_quarters"></a>

## Macro function `three_quarters`

Vulgar fraction three quarters character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_three_quarters">three_quarters</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_three_quarters">three_quarters</a>(): u8 { 190 }
</code></pre>



</details>

<a name="ascii_extended_inverted_question"></a>

## Macro function `inverted_question`

Inverted question mark character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_inverted_question">inverted_question</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_inverted_question">inverted_question</a>(): u8 { 191 }
</code></pre>



</details>

<a name="ascii_extended_A_grave"></a>

## Macro function `A_grave`

Latin capital letter A with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_grave">A_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_grave">A_grave</a>(): u8 { 192 }
</code></pre>



</details>

<a name="ascii_extended_A_acute"></a>

## Macro function `A_acute`

Latin capital letter A with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_acute">A_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_acute">A_acute</a>(): u8 { 193 }
</code></pre>



</details>

<a name="ascii_extended_A_circumflex"></a>

## Macro function `A_circumflex`

Latin capital letter A with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_circumflex">A_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_circumflex">A_circumflex</a>(): u8 { 194 }
</code></pre>



</details>

<a name="ascii_extended_A_tilde"></a>

## Macro function `A_tilde`

Latin capital letter A with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_tilde">A_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_tilde">A_tilde</a>(): u8 { 195 }
</code></pre>



</details>

<a name="ascii_extended_A_diaeresis"></a>

## Macro function `A_diaeresis`

Latin capital letter A with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_diaeresis">A_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_diaeresis">A_diaeresis</a>(): u8 { 196 }
</code></pre>



</details>

<a name="ascii_extended_A_ring"></a>

## Macro function `A_ring`

Latin capital letter A with ring above character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_ring">A_ring</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_A_ring">A_ring</a>(): u8 { 197 }
</code></pre>



</details>

<a name="ascii_extended_AE"></a>

## Macro function `AE`

Latin capital letter AE character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_AE">AE</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_AE">AE</a>(): u8 { 198 }
</code></pre>



</details>

<a name="ascii_extended_C_cedilla"></a>

## Macro function `C_cedilla`

Latin capital letter C with cedilla character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_C_cedilla">C_cedilla</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_C_cedilla">C_cedilla</a>(): u8 { 199 }
</code></pre>



</details>

<a name="ascii_extended_E_grave"></a>

## Macro function `E_grave`

Latin capital letter E with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_grave">E_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_grave">E_grave</a>(): u8 { 200 }
</code></pre>



</details>

<a name="ascii_extended_E_acute"></a>

## Macro function `E_acute`

Latin capital letter E with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_acute">E_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_acute">E_acute</a>(): u8 { 201 }
</code></pre>



</details>

<a name="ascii_extended_E_circumflex"></a>

## Macro function `E_circumflex`

Latin capital letter E with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_circumflex">E_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_circumflex">E_circumflex</a>(): u8 { 202 }
</code></pre>



</details>

<a name="ascii_extended_E_diaeresis"></a>

## Macro function `E_diaeresis`

Latin capital letter E with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_diaeresis">E_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_E_diaeresis">E_diaeresis</a>(): u8 { 203 }
</code></pre>



</details>

<a name="ascii_extended_I_grave"></a>

## Macro function `I_grave`

Latin capital letter I with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_grave">I_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_grave">I_grave</a>(): u8 { 204 }
</code></pre>



</details>

<a name="ascii_extended_I_acute"></a>

## Macro function `I_acute`

Latin capital letter I with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_acute">I_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_acute">I_acute</a>(): u8 { 205 }
</code></pre>



</details>

<a name="ascii_extended_I_circumflex"></a>

## Macro function `I_circumflex`

Latin capital letter I with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_circumflex">I_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_circumflex">I_circumflex</a>(): u8 { 206 }
</code></pre>



</details>

<a name="ascii_extended_I_diaeresis"></a>

## Macro function `I_diaeresis`

Latin capital letter I with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_diaeresis">I_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_I_diaeresis">I_diaeresis</a>(): u8 { 207 }
</code></pre>



</details>

<a name="ascii_extended_ETH"></a>

## Macro function `ETH`

Latin capital letter ETH character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ETH">ETH</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ETH">ETH</a>(): u8 { 208 }
</code></pre>



</details>

<a name="ascii_extended_N_tilde"></a>

## Macro function `N_tilde`

Latin capital letter N with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_N_tilde">N_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_N_tilde">N_tilde</a>(): u8 { 209 }
</code></pre>



</details>

<a name="ascii_extended_O_grave"></a>

## Macro function `O_grave`

Latin capital letter O with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_grave">O_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_grave">O_grave</a>(): u8 { 210 }
</code></pre>



</details>

<a name="ascii_extended_O_acute"></a>

## Macro function `O_acute`

Latin capital letter O with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_acute">O_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_acute">O_acute</a>(): u8 { 211 }
</code></pre>



</details>

<a name="ascii_extended_O_circumflex"></a>

## Macro function `O_circumflex`

Latin capital letter O with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_circumflex">O_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_circumflex">O_circumflex</a>(): u8 { 212 }
</code></pre>



</details>

<a name="ascii_extended_O_tilde"></a>

## Macro function `O_tilde`

Latin capital letter O with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_tilde">O_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_tilde">O_tilde</a>(): u8 { 213 }
</code></pre>



</details>

<a name="ascii_extended_O_diaeresis"></a>

## Macro function `O_diaeresis`

Latin capital letter O with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_diaeresis">O_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_diaeresis">O_diaeresis</a>(): u8 { 214 }
</code></pre>



</details>

<a name="ascii_extended_multiplication"></a>

## Macro function `multiplication`

Multiplication sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_multiplication">multiplication</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_multiplication">multiplication</a>(): u8 { 215 }
</code></pre>



</details>

<a name="ascii_extended_O_stroke"></a>

## Macro function `O_stroke`

Latin capital letter O with stroke character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_stroke">O_stroke</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_O_stroke">O_stroke</a>(): u8 { 216 }
</code></pre>



</details>

<a name="ascii_extended_U_grave"></a>

## Macro function `U_grave`

Latin capital letter U with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_grave">U_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_grave">U_grave</a>(): u8 { 217 }
</code></pre>



</details>

<a name="ascii_extended_U_acute"></a>

## Macro function `U_acute`

Latin capital letter U with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_acute">U_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_acute">U_acute</a>(): u8 { 218 }
</code></pre>



</details>

<a name="ascii_extended_U_circumflex"></a>

## Macro function `U_circumflex`

Latin capital letter U with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_circumflex">U_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_circumflex">U_circumflex</a>(): u8 { 219 }
</code></pre>



</details>

<a name="ascii_extended_U_diaeresis"></a>

## Macro function `U_diaeresis`

Latin capital letter U with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_diaeresis">U_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_U_diaeresis">U_diaeresis</a>(): u8 { 220 }
</code></pre>



</details>

<a name="ascii_extended_Y_acute"></a>

## Macro function `Y_acute`

Latin capital letter Y with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Y_acute">Y_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_Y_acute">Y_acute</a>(): u8 { 221 }
</code></pre>



</details>

<a name="ascii_extended_THORN"></a>

## Macro function `THORN`

Latin capital letter THORN character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_THORN">THORN</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_THORN">THORN</a>(): u8 { 222 }
</code></pre>



</details>

<a name="ascii_extended_sharp_s"></a>

## Macro function `sharp_s`

Latin small letter sharp s character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_sharp_s">sharp_s</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_sharp_s">sharp_s</a>(): u8 { 223 }
</code></pre>



</details>

<a name="ascii_extended_a_grave"></a>

## Macro function `a_grave`

Latin small letter a with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_grave">a_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_grave">a_grave</a>(): u8 { 224 }
</code></pre>



</details>

<a name="ascii_extended_a_acute"></a>

## Macro function `a_acute`

Latin small letter a with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_acute">a_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_acute">a_acute</a>(): u8 { 225 }
</code></pre>



</details>

<a name="ascii_extended_a_circumflex"></a>

## Macro function `a_circumflex`

Latin small letter a with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_circumflex">a_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_circumflex">a_circumflex</a>(): u8 { 226 }
</code></pre>



</details>

<a name="ascii_extended_a_tilde"></a>

## Macro function `a_tilde`

Latin small letter a with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_tilde">a_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_tilde">a_tilde</a>(): u8 { 227 }
</code></pre>



</details>

<a name="ascii_extended_a_diaeresis"></a>

## Macro function `a_diaeresis`

Latin small letter a with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_diaeresis">a_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_diaeresis">a_diaeresis</a>(): u8 { 228 }
</code></pre>



</details>

<a name="ascii_extended_a_ring"></a>

## Macro function `a_ring`

Latin small letter a with ring above character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_ring">a_ring</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_a_ring">a_ring</a>(): u8 { 229 }
</code></pre>



</details>

<a name="ascii_extended_ae"></a>

## Macro function `ae`

Latin small letter ae character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ae">ae</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_ae">ae</a>(): u8 { 230 }
</code></pre>



</details>

<a name="ascii_extended_c_cedilla"></a>

## Macro function `c_cedilla`

Latin small letter c with cedilla character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_c_cedilla">c_cedilla</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_c_cedilla">c_cedilla</a>(): u8 { 231 }
</code></pre>



</details>

<a name="ascii_extended_e_grave"></a>

## Macro function `e_grave`

Latin small letter e with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_grave">e_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_grave">e_grave</a>(): u8 { 232 }
</code></pre>



</details>

<a name="ascii_extended_e_acute"></a>

## Macro function `e_acute`

Latin small letter e with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_acute">e_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_acute">e_acute</a>(): u8 { 233 }
</code></pre>



</details>

<a name="ascii_extended_e_circumflex"></a>

## Macro function `e_circumflex`

Latin small letter e with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_circumflex">e_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_circumflex">e_circumflex</a>(): u8 { 234 }
</code></pre>



</details>

<a name="ascii_extended_e_diaeresis"></a>

## Macro function `e_diaeresis`

Latin small letter e with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_diaeresis">e_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_e_diaeresis">e_diaeresis</a>(): u8 { 235 }
</code></pre>



</details>

<a name="ascii_extended_i_grave"></a>

## Macro function `i_grave`

Latin small letter i with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_grave">i_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_grave">i_grave</a>(): u8 { 236 }
</code></pre>



</details>

<a name="ascii_extended_i_acute"></a>

## Macro function `i_acute`

Latin small letter i with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_acute">i_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_acute">i_acute</a>(): u8 { 237 }
</code></pre>



</details>

<a name="ascii_extended_i_circumflex"></a>

## Macro function `i_circumflex`

Latin small letter i with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_circumflex">i_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_circumflex">i_circumflex</a>(): u8 { 238 }
</code></pre>



</details>

<a name="ascii_extended_i_diaeresis"></a>

## Macro function `i_diaeresis`

Latin small letter i with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_diaeresis">i_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_i_diaeresis">i_diaeresis</a>(): u8 { 239 }
</code></pre>



</details>

<a name="ascii_extended_eth"></a>

## Macro function `eth`

Latin small letter eth character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_eth">eth</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_eth">eth</a>(): u8 { 240 }
</code></pre>



</details>

<a name="ascii_extended_n_tilde"></a>

## Macro function `n_tilde`

Latin small letter n with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_n_tilde">n_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_n_tilde">n_tilde</a>(): u8 { 241 }
</code></pre>



</details>

<a name="ascii_extended_o_grave"></a>

## Macro function `o_grave`

Latin small letter o with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_grave">o_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_grave">o_grave</a>(): u8 { 242 }
</code></pre>



</details>

<a name="ascii_extended_o_acute"></a>

## Macro function `o_acute`

Latin small letter o with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_acute">o_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_acute">o_acute</a>(): u8 { 243 }
</code></pre>



</details>

<a name="ascii_extended_o_circumflex"></a>

## Macro function `o_circumflex`

Latin small letter o with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_circumflex">o_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_circumflex">o_circumflex</a>(): u8 { 244 }
</code></pre>



</details>

<a name="ascii_extended_o_tilde"></a>

## Macro function `o_tilde`

Latin small letter o with tilde character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_tilde">o_tilde</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_tilde">o_tilde</a>(): u8 { 245 }
</code></pre>



</details>

<a name="ascii_extended_o_diaeresis"></a>

## Macro function `o_diaeresis`

Latin small letter o with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_diaeresis">o_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_diaeresis">o_diaeresis</a>(): u8 { 246 }
</code></pre>



</details>

<a name="ascii_extended_division"></a>

## Macro function `division`

Division sign character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_division">division</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_division">division</a>(): u8 { 247 }
</code></pre>



</details>

<a name="ascii_extended_o_stroke"></a>

## Macro function `o_stroke`

Latin small letter o with stroke character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_stroke">o_stroke</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_o_stroke">o_stroke</a>(): u8 { 248 }
</code></pre>



</details>

<a name="ascii_extended_u_grave"></a>

## Macro function `u_grave`

Latin small letter u with grave character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_grave">u_grave</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_grave">u_grave</a>(): u8 { 249 }
</code></pre>



</details>

<a name="ascii_extended_u_acute"></a>

## Macro function `u_acute`

Latin small letter u with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_acute">u_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_acute">u_acute</a>(): u8 { 250 }
</code></pre>



</details>

<a name="ascii_extended_u_circumflex"></a>

## Macro function `u_circumflex`

Latin small letter u with circumflex character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_circumflex">u_circumflex</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_circumflex">u_circumflex</a>(): u8 { 251 }
</code></pre>



</details>

<a name="ascii_extended_u_diaeresis"></a>

## Macro function `u_diaeresis`

Latin small letter u with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_diaeresis">u_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_u_diaeresis">u_diaeresis</a>(): u8 { 252 }
</code></pre>



</details>

<a name="ascii_extended_y_acute"></a>

## Macro function `y_acute`

Latin small letter y with acute character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_y_acute">y_acute</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_y_acute">y_acute</a>(): u8 { 253 }
</code></pre>



</details>

<a name="ascii_extended_thorn"></a>

## Macro function `thorn`

Latin small letter thorn character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_thorn">thorn</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_thorn">thorn</a>(): u8 { 254 }
</code></pre>



</details>

<a name="ascii_extended_y_diaeresis"></a>

## Macro function `y_diaeresis`

Latin small letter y with diaeresis character.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_y_diaeresis">y_diaeresis</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./extended.md#ascii_extended_y_diaeresis">y_diaeresis</a>(): u8 { 255 }
</code></pre>



</details>
