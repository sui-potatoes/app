
<a name="(svg=0x0)_macros"></a>

# Module `(svg=0x0)::macros`

Module: macros
All of the shapes and containers in the SVG module have a shared set of methods,
for example, <code>to_string</code> and <code>attributes_mut</code>. This module defines a set of macros
which can be used to generate calls to these methods.


-  [Macro function `add_attribute`](#(svg=0x0)_macros_add_attribute)
-  [Macro function `add_class`](#(svg=0x0)_macros_add_class)


<pre><code></code></pre>



<a name="(svg=0x0)_macros_add_attribute"></a>

## Macro function `add_attribute`

Adds an attribute to the shape or updates it if it already exists.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/macros.md#(svg=0x0)_macros_add_attribute">add_attribute</a>&lt;$T&gt;($el: &<b>mut</b> $T, $key: vector&lt;u8&gt;, $value: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/macros.md#(svg=0x0)_macros_add_attribute">add_attribute</a>&lt;$T&gt;($el: &<b>mut</b> $T, $key: vector&lt;u8&gt;, $value: vector&lt;u8&gt;) {
    <b>let</b> el = $el;
    <b>let</b> key = $key;
    <b>let</b> value = $value;
    el.attributes_mut().insert(key.to_string(), value.to_string());
}
</code></pre>



</details>

<a name="(svg=0x0)_macros_add_class"></a>

## Macro function `add_class`

Adds a "class" attribute to the shape or updates it if it already exists.

Can be called on:
- <code>svg::svg::SVG</code>
- <code><a href="../svg/shape.md#(svg=0x0)_shape_Shape">svg::shape::Shape</a></code>
- <code><a href="../svg/container.md#(svg=0x0)_container_Container">svg::container::Container</a></code>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/macros.md#(svg=0x0)_macros_add_class">add_class</a>&lt;$T&gt;($el: &<b>mut</b> $T, $class: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/macros.md#(svg=0x0)_macros_add_class">add_class</a>&lt;$T&gt;($el: &<b>mut</b> $T, $class: vector&lt;u8&gt;) {
    <b>let</b> el = $el;
    <b>let</b> value = $class;
    <b>let</b> key = b"class".to_string();
    <b>let</b> attributes = el.attributes_mut();
    <b>let</b> <b>mut</b> class_list = <b>if</b> (attributes.contains(&key)) {
        <b>let</b> (_, <b>mut</b> list) = attributes.remove(&key);
        list.append(b" ".to_string());
        list
    } <b>else</b> {
        b"".to_string()
    };
    class_list.append(value.to_string());
    attributes.insert(key, class_list);
}
</code></pre>



</details>
