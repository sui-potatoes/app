
<a name="(svg=0x0)_desc"></a>

# Module `(svg=0x0)::desc`

Defines SVG description elements: <code>&lt;<a href="./desc.md#(svg=0x0)_desc">desc</a>&gt;</code>, <code>&lt;<a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>&gt;</code>, and <code>&lt;<a href="./desc.md#(svg=0x0)_desc_title">title</a>&gt;</code>.

These elements may be used to provide additional information about the SVG content, such as
descriptions, metadata, and titles.


-  [Struct `Desc`](#(svg=0x0)_desc_Desc)
-  [Constants](#@Constants_0)
-  [Function `desc`](#(svg=0x0)_desc_desc)
        -  [Description](#@Description_1)
        -  [Usage](#@Usage_2)
-  [Function `metadata`](#(svg=0x0)_desc_metadata)
        -  [Description](#@Description_3)
        -  [Usage](#@Usage_4)
-  [Function `title`](#(svg=0x0)_desc_title)
        -  [Description](#@Description_5)
        -  [Usage](#@Usage_6)
-  [Function `custom`](#(svg=0x0)_desc_custom)
-  [Function `to_string`](#(svg=0x0)_desc_to_string)


<pre><code><b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./print.md#(svg=0x0)_print">print</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_desc_Desc"></a>

## Struct `Desc`

Special container for SVG descriptions.


<pre><code><b>public</b> <b>struct</b> <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>desc_type: u8</code>
</dt>
<dd>
</dd>
<dt>
<code>content: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(svg=0x0)_desc_TYPE_DESC"></a>



<pre><code><b>const</b> <a href="./desc.md#(svg=0x0)_desc_TYPE_DESC">TYPE_DESC</a>: u8 = 0;
</code></pre>



<a name="(svg=0x0)_desc_TYPE_METADATA"></a>



<pre><code><b>const</b> <a href="./desc.md#(svg=0x0)_desc_TYPE_METADATA">TYPE_METADATA</a>: u8 = 1;
</code></pre>



<a name="(svg=0x0)_desc_TYPE_TITLE"></a>



<pre><code><b>const</b> <a href="./desc.md#(svg=0x0)_desc_TYPE_TITLE">TYPE_TITLE</a>: u8 = 2;
</code></pre>



<a name="(svg=0x0)_desc_TYPE_CUSTOM"></a>



<pre><code><b>const</b> <a href="./desc.md#(svg=0x0)_desc_TYPE_CUSTOM">TYPE_CUSTOM</a>: u8 = 3;
</code></pre>



<a name="(svg=0x0)_desc_desc"></a>

## Function `desc`

Create a new <code>&lt;<a href="./desc.md#(svg=0x0)_desc">desc</a>&gt;</code> element with the given text.


<a name="@Description_1"></a>

#### Description


Provides a description of the SVG content, which can be rendered by user agents in a
tooltip. Authors are encouraged to provide such a description, which can improve accessibility.
However, in the blockchain environment, space optimization is crucial, so it is recommended to
use this element only when necessary.

- Element: <code>&lt;<a href="./desc.md#(svg=0x0)_desc">desc</a>&gt;</code>.
- Owned property: description string.
- Extended properties: None.

[MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/desc)


<a name="@Usage_2"></a>

#### Usage


```rust
use svg::{desc, shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
let desc = desc::desc(b"This is a circle".to_string());
let mut circle = shape::circle(5).move_to(50, 50);

circle.add_desc(desc);
svg.add_root(vector[ circle ]);

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc">desc</a>(content: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc">desc</a>(content: String): <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { desc_type: <a href="./desc.md#(svg=0x0)_desc_TYPE_DESC">TYPE_DESC</a>, content } }
</code></pre>



</details>

<a name="(svg=0x0)_desc_metadata"></a>

## Function `metadata`

Create a new <code>&lt;<a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>&gt;</code> element with the given raw content.


<a name="@Description_3"></a>

#### Description


Organizes arbitrary metadata for the parent element, which can be used by user agents.
Metadata should be structured data, such as elements from other XML namespaces, JSON, or
RDF.

- Element: <code>&lt;<a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>&gt;</code>.
- Owned property: content.
- Extended properties: None.

[MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/metadata)


<a name="@Usage_4"></a>

#### Usage


```rust
use svg::{desc, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_desc(desc::metadata(b"...".to_string()));

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>(content: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>(content: String): <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { desc_type: <a href="./desc.md#(svg=0x0)_desc_TYPE_METADATA">TYPE_METADATA</a>, content } }
</code></pre>



</details>

<a name="(svg=0x0)_desc_title"></a>

## Function `title`

Create a new title description.


<a name="@Description_5"></a>

#### Description


Provides a title for the parent element, which can be rendered by user agents in a tooltip.

- Element: <code>&lt;<a href="./desc.md#(svg=0x0)_desc_title">title</a>&gt;</code>.
- Owned property: title text.
- Extended properties: None.

[MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/title)


<a name="@Usage_6"></a>

#### Usage


```rust
use svg::{desc, shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
let title = desc::title(b"This is a circle");
let mut circle = shape::circle(5).move_to(50, 50);

circle.add_desc(title);
svg.add_root(vector[ circle ]);

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_title">title</a>(text: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_title">title</a>(text: String): <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { desc_type: <a href="./desc.md#(svg=0x0)_desc_TYPE_TITLE">TYPE_TITLE</a>, content: text } }
</code></pre>



</details>

<a name="(svg=0x0)_desc_custom"></a>

## Function `custom`

Insert a custom element into the <code><a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a></code> container.

```rust
use svg::{desc, svg};

let custom = desc::custom("<custom>Custom element</custom>");
let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_desc(custom);

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_custom">custom</a>(text: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_custom">custom</a>(text: String): <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { <a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a> { desc_type: <a href="./desc.md#(svg=0x0)_desc_TYPE_CUSTOM">TYPE_CUSTOM</a>, content: text } }
</code></pre>



</details>

<a name="(svg=0x0)_desc_to_string"></a>

## Function `to_string`

Print the shape as an <code>SVG</code> element.

TODO: replace with constants when compiler bug is fixed.


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_to_string">to_string</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./desc.md#(svg=0x0)_desc_to_string">to_string</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &<a href="./desc.md#(svg=0x0)_desc_Desc">Desc</a>): String {
    <b>let</b> (name, content) = match (<a href="./shape.md#(svg=0x0)_shape">shape</a>.desc_type) {
        0 =&gt; (b"<a href="./desc.md#(svg=0x0)_desc">desc</a>", vector[<a href="./shape.md#(svg=0x0)_shape">shape</a>.content]),
        1 =&gt; (b"<a href="./desc.md#(svg=0x0)_desc_metadata">metadata</a>", vector[<a href="./shape.md#(svg=0x0)_shape">shape</a>.content]),
        2 =&gt; (b"<a href="./desc.md#(svg=0x0)_desc_title">title</a>", vector[<a href="./shape.md#(svg=0x0)_shape">shape</a>.content]),
        3 =&gt; <b>return</b> <a href="./shape.md#(svg=0x0)_shape">shape</a>.content,
        _ =&gt; <b>abort</b>,
    };
    <a href="./print.md#(svg=0x0)_print_print">print::print</a>(name.<a href="./desc.md#(svg=0x0)_desc_to_string">to_string</a>(), vec_map::empty(), option::some(content))
}
</code></pre>



</details>
