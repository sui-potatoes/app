
<a name="(svg=0x0)_animation"></a>

# Module `(svg=0x0)::animation`

Implements SVG animations. Animations can be applied to SVG elements to create
interactive and dynamic content.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/SVG_animation_with_SMIL)


<a name="@Usage_0"></a>

#### Usage


Animation can be added to any <code>Shape</code> element by calling <code>add_animation</code> on the
element. The <code>add_animation</code> method takes an <code><a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a></code> struct as an argument.

```rust
use svg::{animation, shape, svg};

// prepare animation
let animation = animation::animate_transform(b"rotate", b"0 5 5", b"360 5 5")
.attribute_name(b"transform")
.duration(b"10s")
.repeat_count(b"indefinite");

// add animation to the shape
let mut rect = shape::rect(10, 10);
rect.add_animation(animation);

// add the shape to the SVG container and print it
let mut svg = svg::svg(vector[0, 0, 120, 120]);
svg.add_root(vector[rect]);
svg.to_string();
```

The <code><a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a></code> struct has several builder methods to set the properties of the
animation. The <code><a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a></code> method can be called on the <code><a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a></code> struct to
convert it to a string.

```rust
use svg::animation;

let animation = animation::animate()
.attribute_name(b"rx")
.values(b"0;5;0")
.duration(b"10s")
.repeat_count(b"indefinite");

animation.to_string();
```


        -  [Usage](#@Usage_0)
-  [Struct `MPath`](#(svg=0x0)_animation_MPath)
-  [Struct `Animation`](#(svg=0x0)_animation_Animation)
-  [Enum `AnimationType`](#(svg=0x0)_animation_AnimationType)
-  [Function `animate`](#(svg=0x0)_animation_animate)
        -  [Description](#@Description_1)
        -  [Usage](#@Usage_2)
-  [Function `animate_motion`](#(svg=0x0)_animation_animate_motion)
        -  [Description](#@Description_3)
        -  [Usage](#@Usage_4)
-  [Function `animate_transform`](#(svg=0x0)_animation_animate_transform)
        -  [Description](#@Description_5)
        -  [Usage](#@Usage_6)
-  [Function `set`](#(svg=0x0)_animation_set)
        -  [Description](#@Description_7)
        -  [Usage](#@Usage_8)
-  [Function `custom`](#(svg=0x0)_animation_custom)
-  [Function `mpath`](#(svg=0x0)_animation_mpath)
        -  [Description](#@Description_9)
        -  [Usage](#@Usage_10)
-  [Function `attribute_name`](#(svg=0x0)_animation_attribute_name)
-  [Function `values`](#(svg=0x0)_animation_values)
-  [Function `duration`](#(svg=0x0)_animation_duration)
-  [Function `repeat_count`](#(svg=0x0)_animation_repeat_count)
-  [Function `attributes_mut`](#(svg=0x0)_animation_attributes_mut)
-  [Macro function `map_attributes`](#(svg=0x0)_animation_map_attributes)
-  [Function `to_string`](#(svg=0x0)_animation_to_string)


<pre><code><b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/print.md#(svg=0x0)_print">print</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_animation_MPath"></a>

## Struct `MPath`

MPath animation, defines a path for an element to follow. Used in the
<code>animateMotion</code> element, and references a <code>path</code> element by id.
- <code>href</code> - the id of the path element to follow.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/mpath)


<pre><code><b>public</b> <b>struct</b> <a href="../svg/animation.md#(svg=0x0)_animation_MPath">MPath</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(svg=0x0)_animation_Animation"></a>

## Struct `Animation`

Animation struct, represents an animation that can be applied to SVG elements.


<pre><code><b>public</b> <b>struct</b> <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_AnimationType">animation::AnimationType</a></code>
</dt>
<dd>
 The type of animation element.
</dd>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 The name of the attribute to animate. Translates to the <code>attributeName</code>
 property in the SVG element.
</dd>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 The path to animate along. Translates to the <code>path</code> property in the SVG element.
 Used in the <code>animateMotion</code> and <code>animateTransform</code> elements.
</dd>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 Duration of the animation. Translates to the <code>dur</code> property in the SVG element.
</dd>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 Number of times to repeat the animation. Translates to the <code>repeatCount</code>
 property in the SVG element.
</dd>
<dt>
<code>attributes: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 A list of other attributes to add to the animation element.
</dd>
</dl>


</details>

<a name="(svg=0x0)_animation_AnimationType"></a>

## Enum `AnimationType`

Animation enum, represents different types of animations that can be
applied to SVG elements.

- <code>Animate</code> - animate animation, animates an attribute from one value to another.
- <code>AnimateMotion</code> - animate motion animation, animates an element along a path.
- <code>AnimateTransform</code> - animate transform animation, animates a transformation.
- <code>Set</code> - set animation, sets the value of an attribute at a specific time.


<pre><code><b>public</b> <b>enum</b> <a href="../svg/animation.md#(svg=0x0)_animation_AnimationType">AnimationType</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Animate</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>AnimateMotion</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>path: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_MPath">animation::MPath</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>AnimateTransform</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>transform_type: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>from: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>to: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Set</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>to: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Custom</code>
</dt>
<dd>
 A custom animation type, passed as a <code>String</code>. Cannot be customized by
 calling the builder methods, does not support attributes modification.
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

</dl>


</details>

<a name="(svg=0x0)_animation_animate"></a>

## Function `animate`

Create a new <code>&lt;<a href="../svg/animation.md#(svg=0x0)_animation_animate">animate</a>&gt;</code> element.
Animates an attribute from one value to another.


<a name="@Description_1"></a>

#### Description


- Element: <code>&lt;<a href="../svg/animation.md#(svg=0x0)_animation_animate">animate</a>&gt;</code>
- Own properties: None.
- Inherited properties:
- <code>attribute</code> - the name of the attribute to animate.
- <code><a href="../svg/animation.md#(svg=0x0)_animation_values">values</a></code> - a list of values to animate between.
- <code>dur</code> - the duration of the animation.
- <code>repeatCount</code> - the number of times to repeat the animation.
- Extended properties:
- <code>begin</code> - the time to start the animation.
- <code>end</code> - the time to end the animation.
- <code>rotate</code> - the rotation of the element.

> Animate is placed inside an element to animate the element.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animate)


<a name="@Usage_2"></a>

#### Usage


```rust
use svg::animation;

let animation = animation::animate()
.attribute_name(b"rx")
.values(b"0;5;0")
.duration(b"10s");

animation.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate">animate</a>(): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate">animate</a>(): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: AnimationType::Animate,
        <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: option::none(),
        attributes: vec_map::empty(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_animate_motion"></a>

## Function `animate_motion`

Create a new <code>&lt;animateMotion&gt;</code> element.


<a name="@Description_3"></a>

#### Description


Animates an element along a path.

- Element: <code>&lt;animateMotion&gt;</code>
- Own properties:
- <code>path</code> - the path to animate along.
- <code><a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a></code> - the path element to follow.
- Inherited properties:
- <code>dur</code> - the duration of the animation.
- <code>repeatCount</code> - the number of times to repeat the animation.
- Extended properties:
- <code>begin</code> - the time to start the animation.
- <code>end</code> - the time to end the animation.
- <code>rotate</code> - the rotation of the element.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateMotion)


<a name="@Usage_4"></a>

#### Usage


```rust
use svg::{animation, shape};

// Animate the <code>r</code> attribute of an element along the specified path.
let animation1 = animation::animate_motion(option::some(b"M10,90 Q90,90 z"), option::none())
.attribute_name(b"r")
.duration(b"10s");

let mut circle = shape::circle(5);
circle.add_animation(animation1);

// Reference a path element by id using <code><a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a></code>.
let mpath = animation::mpath(b"#path");
let animation2 = animation::animate_motion(option::none(), option::some(mpath));

let mut rect = shape::rect(10, 10);
rect.add_animation(animation2);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate_motion">animate_motion</a>(path: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;u8&gt;&gt;, <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_MPath">animation::MPath</a>&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate_motion">animate_motion</a>(path: Option&lt;vector&lt;u8&gt;&gt;, <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>: Option&lt;<a href="../svg/animation.md#(svg=0x0)_animation_MPath">MPath</a>&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: AnimationType::AnimateMotion {
            path: path.map!(|p| p.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>()),
            <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>,
        },
        <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: option::none(),
        attributes: vec_map::empty(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_animate_transform"></a>

## Function `animate_transform`

Create a new <code>&lt;animateTransform&gt;</code> element.


<a name="@Description_5"></a>

#### Description


Animate transform animation.

- Element: <code>&lt;animateTransform&gt;</code>
- Own properties:
- <code>type</code> - the type of transformation to animate.
- <code>from</code> - the starting value of the transformation.
- <code>to</code> - the ending value of the transformation.
- Inherited properties:
- <code>attribute</code> - the name of the attribute to animate.
- <code>dur</code> - the duration of the animation.
- <code>repeatCount</code> - the number of times to repeat the animation.
- <code><a href="../svg/animation.md#(svg=0x0)_animation_values">values</a></code> - the values to animate between.
- Extended properties:
- <code>by</code> - the amount to change the transformation by.
- <code>begin</code> - the time to start the animation.
- <code>end</code> - the time to end the animation.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateTransform)


<a name="@Usage_6"></a>

#### Usage


```rust
use svg::{animation, shape};

let mut shape = shape::rect(10, 10);
let animation = animation::animate_transform(b"rotate", b"0 5 5", b"360 5 5")
.attribute_name(b"r")
.duration(b"10s")
.repeat_count(b"indefinite");

shape.add_animation(animation);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate_transform">animate_transform</a>(transform_type: vector&lt;u8&gt;, from: vector&lt;u8&gt;, to: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_animate_transform">animate_transform</a>(
    transform_type: vector&lt;u8&gt;,
    from: vector&lt;u8&gt;,
    to: vector&lt;u8&gt;,
): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: AnimationType::AnimateTransform {
            transform_type: transform_type.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(),
            from: from.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(),
            to: to.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(),
        },
        <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: option::none(),
        attributes: vec_map::empty(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_set"></a>

## Function `set`

Create a new <code>&lt;<a href="../svg/animation.md#(svg=0x0)_animation_set">set</a>&gt;</code> element.


<a name="@Description_7"></a>

#### Description


Sets the value of an attribute at a specific time.

- Element: <code>&lt;<a href="../svg/animation.md#(svg=0x0)_animation_set">set</a>&gt;</code>
- Own properties:
- <code>to</code> - the value to set the attribute to.
- Inherited properties:
- <code>attribute</code> - the name of the attribute to set.
- <code>dur</code> - the duration of the animation.
- <code>repeatCount</code> - the number of times to repeat the animation.
- Extended properties:
- <code>begin</code> - the time to start the animation.
- <code>end</code> - the time to end the animation.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/set)


<a name="@Usage_8"></a>

#### Usage


```rust
use svg::{animation, shape};

let mut shape = shape::rect(10, 10);
let animation = animation::set(b"5")
.attribute_name(b"r")
.duration(b"10s")
.repeat_count(b"indefinite");

shape.add_animation(animation);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_set">set</a>(to: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_set">set</a>(to: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: AnimationType::Set {
            to: to.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(),
        },
        <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: option::none(),
        attributes: vec_map::empty(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_custom"></a>

## Function `custom`

Create a new custom animation element.

```rust
use svg::{animation, shape};

let mut shape = shape::rect(10, 10);
let animation = animation::custom(b"<custom/>")
shape.add_animation(animation);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_custom">custom</a>(content: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_custom">custom</a>(content: String): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: AnimationType::Custom(content),
        <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: option::none(),
        <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>: option::none(),
        attributes: vec_map::empty(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_mpath"></a>

## Function `mpath`

Create a new <code>&lt;<a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>&gt;</code> element. Special element used in the <code>animateMotion</code> element
to reference a <code>path</code> element by id. Passed as an argument to the <code>animateMotion</code>.


<a name="@Description_9"></a>

#### Description


MPath animation, defines a path for an element to follow. Used in the
<code>animateMotion</code> element, and references a <code>path</code> element by id.
- <code>href</code> - the id of the path element to follow.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/mpath)


<a name="@Usage_10"></a>

#### Usage


```rust
use svg::animation;

animation::mpath(b"#path");
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>(href: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_MPath">animation::MPath</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>(href: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_MPath">MPath</a> { <a href="../svg/animation.md#(svg=0x0)_animation_MPath">MPath</a>(href.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>()) }
</code></pre>



</details>

<a name="(svg=0x0)_animation_attribute_name"></a>

## Function `attribute_name`

Set the name of the attribute to animate.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>(self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>, name: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>(<b>mut</b> self: <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>, name: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    self.<a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>.fill(name.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>());
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_values"></a>

## Function `values`

Set the values to animate between.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>(self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>, <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>(<b>mut</b> self: <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>, <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    self.<a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>.fill(<a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>());
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_duration"></a>

## Function `duration`

Set the duration of the animation.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>(self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>, <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>(<b>mut</b> self: <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>, <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    self.<a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>.fill(<a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>());
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_repeat_count"></a>

## Function `repeat_count`

Set the number of times to repeat the animation.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>(self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>, count: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>(<b>mut</b> self: <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>, count: vector&lt;u8&gt;): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    self.<a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>.fill(count.<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>());
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_attributes_mut"></a>

## Function `attributes_mut`

Get mutable access to the attributes of the animation.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_attributes_mut">attributes_mut</a>(self: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>): &<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_attributes_mut">attributes_mut</a>(self: &<b>mut</b> <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>): &<b>mut</b> VecMap&lt;String, String&gt; {
    &<b>mut</b> self.attributes
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_map_attributes"></a>

## Macro function `map_attributes`

Map over the attributes of the animation.

```rust
let mut animation = animation::animate().map_attributes!(|attrs| {
attrs.insert(b"fill".to_string(), b"red".to_string());
attrs.insert(b"stroke".to_string(), b"black".to_string());
});
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_map_attributes">map_attributes</a>($self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>, $f: |&<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;| -&gt; ()): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_map_attributes">map_attributes</a>($self: <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>, $f: |&<b>mut</b> VecMap&lt;String, String&gt;|): <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> {
    <b>let</b> <b>mut</b> self = $self;
    <b>let</b> attributes = self.<a href="../svg/animation.md#(svg=0x0)_animation_attributes_mut">attributes_mut</a>();
    $f(attributes);
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_animation_to_string"></a>

## Function `to_string`

Convert the animation to a string.

```rust
let animation = animation::animate()
.attribute_name(b"rx")
.values(b"0;5;0")
.duration(b"10s");

animation.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(self: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(self: &<a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a>): String {
    <b>let</b> <a href="../svg/animation.md#(svg=0x0)_animation_Animation">Animation</a> { <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>, <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>, <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>, <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>, <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>, attributes } = self;
    <b>let</b> <b>mut</b> attrs = *attributes;
    <a href="../svg/animation.md#(svg=0x0)_animation_attribute_name">attribute_name</a>.do_ref!(|attr| attrs.insert(b"attributeName".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *attr));
    <a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>.do_ref!(|val| attrs.insert(b"<a href="../svg/animation.md#(svg=0x0)_animation_values">values</a>".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *val));
    <a href="../svg/animation.md#(svg=0x0)_animation_duration">duration</a>.do_ref!(|dur| attrs.insert(b"dur".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *dur));
    <a href="../svg/animation.md#(svg=0x0)_animation_repeat_count">repeat_count</a>.do_ref!(|count| attrs.insert(b"repeatCount".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *count));
    // modify the internal attribute <b>if</b> needed and <b>return</b> the name
    <b>let</b> (name, content) = match (<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>) {
        AnimationType::Animate =&gt; (b"<a href="../svg/animation.md#(svg=0x0)_animation_animate">animate</a>".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), option::none()),
        AnimationType::AnimateMotion { path, <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a> } =&gt; {
            <b>let</b> <b>mut</b> contents = option::none();
            path.do_ref!(|p| attrs.insert(b"path".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *p));
            <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>.do_ref!(|<a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>| contents.fill({
                <b>let</b> <b>mut</b> attrs = vec_map::empty();
                attrs.insert(b"href".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), <a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>.0);
                vector[<a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(b"<a href="../svg/animation.md#(svg=0x0)_animation_mpath">mpath</a>".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), attrs, option::none())]
            }));
            (b"animateMotion".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), contents)
        },
        AnimationType::AnimateTransform { transform_type, from, to } =&gt; {
            attrs.insert(b"type".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *transform_type);
            attrs.insert(b"from".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *from);
            attrs.insert(b"to".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *to);
            (b"animateTransform".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), option::none())
        },
        AnimationType::Set { to } =&gt; {
            attrs.insert(b"to".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), *to);
            (b"<a href="../svg/animation.md#(svg=0x0)_animation_set">set</a>".<a href="../svg/animation.md#(svg=0x0)_animation_to_string">to_string</a>(), option::none())
        },
        AnimationType::Custom(content) =&gt; <b>return</b> *content,
    };
    <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(name, attrs, content)
}
</code></pre>



</details>
