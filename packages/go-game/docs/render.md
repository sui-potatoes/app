
<a name="go_game_render"></a>

# Module `go_game::render`



-  [Function `svg`](#go_game_render_svg)


<pre><code><b>use</b> (codec=0x0)::base64;
<b>use</b> (codec=0x0)::urlencode;
<b>use</b> (grid=0x0)::grid;
<b>use</b> (grid=0x0)::point;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::animation;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::container;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::coordinate;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::desc;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::filter;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::print;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::shape;
<b>use</b> (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::<a href="./render.md#go_game_render_svg">svg</a>;
<b>use</b> <a href="./go.md#go_game_go">go_game::go</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="go_game_render_svg"></a>

## Function `svg`

Print the board as an SVG.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./render.md#go_game_render_svg">svg</a>(b: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>): (<a href="./render.md#go_game_render_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./render.md#go_game_render_svg">svg</a>(b: &Board): Svg {
    <b>let</b> padding = 1u16;
    <b>let</b> cell_size = 20u16;
    <b>let</b> size = b.size() <b>as</b> u16;
    <b>let</b> width = ((size * (cell_size + 1)) + (size * padding)) <b>as</b> u16;
    // create a new SVG document
    <b>let</b> <b>mut</b> <a href="./render.md#go_game_render_svg">svg</a> = <a href="../../.doc-deps/svg/svg.md#(svg=0x0)_svg">svg::svg</a>(vector[0, 0, width, width]);
    // construct a circle definition <b>for</b> black stones
    <b>let</b> black = shape::circle(10).map_attributes!(|attrs| {
        attrs.insert(b"id".to_string(), b"b".to_string());
        attrs.insert(b"fill".to_string(), b"#000".to_string());
    });
    // construct a circle definition <b>for</b> white stones
    <b>let</b> white = shape::circle(10).map_attributes!(|attrs| {
        attrs.insert(b"id".to_string(), b"w".to_string());
        attrs.insert(b"fill".to_string(), b"#fff".to_string());
        attrs.insert(b"stroke".to_string(), b"#000".to_string());
    });
    // pattern + background definition
    <b>let</b> pattern = shape::custom(b"&lt;pattern id='g' width='21' height='21' x='20' y='20' patternUnits='userSpaceOnUse'&gt;&lt;path d='M 40 0 L 0 0 0 40' fill='none' stroke='gray' stroke-width='0.8'/&gt;&lt;/pattern&gt;".to_string());
    <b>let</b> <b>mut</b> background = shape::rect(width, width);
    background.attributes_mut().insert(b"fill".to_string(), b"url(#g)".to_string());
    <a href="./render.md#go_game_render_svg">svg</a>.add_defs(vector[black, white, pattern]);
    <b>let</b> <b>mut</b> elements = vector[background];
    b.grid().traverse!(|tile, (row, col)| {
        <b>let</b> num = tile.to_number();
        <b>if</b> (num == 0) <b>return</b>;
        <b>let</b> stone = <b>if</b> (num == 1) b"#b" <b>else</b> { b"#w" }.to_string();
        <b>let</b> cx = (row * cell_size) + (row * padding) + 10;
        <b>let</b> cy = (col * cell_size) + (col * padding) + 10;
        elements.push_back(shape::use_(stone).move_to(cx, cy));
    });
    <a href="./render.md#go_game_render_svg">svg</a>.add_root(elements);
    <a href="./render.md#go_game_render_svg">svg</a>
}
</code></pre>



</details>
