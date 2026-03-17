
<a name="commander_display"></a>

# Module `commander::display`

Implements Sui Object Display for objects in the game.


-  [Struct `DISPLAY`](#commander_display_DISPLAY)
-  [Function `init`](#commander_display_init)


<pre><code><b>use</b> <a href="./armor.md#commander_armor">commander::armor</a>;
<b>use</b> <a href="./rank.md#commander_rank">commander::rank</a>;
<b>use</b> <a href="./recruit.md#commander_recruit">commander::recruit</a>;
<b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="./weapon.md#commander_weapon">commander::weapon</a>;
<b>use</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade">commander::weapon_upgrade</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/display.md#sui_display">sui::display</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/package.md#sui_package">sui::package</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/types.md#sui_types">sui::types</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="commander_display_DISPLAY"></a>

## Struct `DISPLAY`



<pre><code><b>public</b> <b>struct</b> <a href="./display.md#commander_display_DISPLAY">DISPLAY</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
</dl>


</details>

<a name="commander_display_init"></a>

## Function `init`

Creates Display objects for the Recruit and Weapon objects.


<pre><code><b>fun</b> <a href="./display.md#commander_display_init">init</a>(otw: <a href="./display.md#commander_display_DISPLAY">commander::display::DISPLAY</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./display.md#commander_display_init">init</a>(otw: <a href="./display.md#commander_display_DISPLAY">DISPLAY</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> publisher = package::claim(otw, ctx);
    // Display <b>for</b> the `Recruit` object.
    <b>let</b> recruit_display = {
        <b>let</b> <b>mut</b> <a href="./display.md#commander_display">display</a> = display::new&lt;Recruit&gt;(&publisher, ctx);
        <a href="./display.md#commander_display">display</a>.add(b"name".to_string(), b"{metadata.name} (Rank: {<a href="./rank.md#commander_rank">rank</a>})".to_string());
        <a href="./display.md#commander_display">display</a>.add(b"description".to_string(), b"{metadata.description}".to_string());
        <a href="./display.md#commander_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="./recruit.md#commander_recruit">recruit</a>.webp".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(
            b"link".to_string(),
            b"https://potatoes.app/<a href="./commander.md#commander_commander">commander</a>/<a href="./recruit.md#commander_recruit">recruit</a>/{id}".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.update_version();
        <a href="./display.md#commander_display">display</a>
    };
    // Display <b>for</b> the `Weapon` object.
    <b>let</b> weapon_display = {
        <b>let</b> <b>mut</b> <a href="./display.md#commander_display">display</a> = display::new&lt;Weapon&gt;(&publisher, ctx);
        <a href="./display.md#commander_display">display</a>.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        <a href="./display.md#commander_display">display</a>.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="./weapon.md#commander_weapon">weapon</a>.webp".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(b"link".to_string(), b"".to_string());
        <a href="./display.md#commander_display">display</a>.update_version();
        <a href="./display.md#commander_display">display</a>
    };
    // Armor <a href="./display.md#commander_display">display</a>
    <b>let</b> armor_display = {
        <b>let</b> <b>mut</b> <a href="./display.md#commander_display">display</a> = display::new&lt;Armor&gt;(&publisher, ctx);
        <a href="./display.md#commander_display">display</a>.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        <a href="./display.md#commander_display">display</a>.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="./armor.md#commander_armor">armor</a>-light.webp".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(b"link".to_string(), b"".to_string());
        <a href="./display.md#commander_display">display</a>.update_version();
        <a href="./display.md#commander_display">display</a>
    };
    // Display <b>for</b> the `DogTag` object.
    <b>let</b> dogtag_display = {
        <b>let</b> <b>mut</b> <a href="./display.md#commander_display">display</a> = display::new&lt;DogTag&gt;(&publisher, ctx);
        <a href="./display.md#commander_display">display</a>.add(b"name".to_string(), b"{metadata.name} (Rank: {<a href="./rank.md#commander_rank">rank</a>})".to_string());
        <a href="./display.md#commander_display">display</a>.add(b"description".to_string(), b"{metadata.description}".to_string());
        <a href="./display.md#commander_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="./recruit.md#commander_recruit">recruit</a>.webp".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.add(
            b"link".to_string(),
            b"https://potatoes.app/<a href="./commander.md#commander_commander">commander</a>/<a href="./recruit.md#commander_recruit">recruit</a>/{id}".to_string(),
        );
        <a href="./display.md#commander_display">display</a>.update_version();
        <a href="./display.md#commander_display">display</a>
    };
    <b>let</b> sender = ctx.sender();
    transfer::public_transfer(recruit_display, sender);
    transfer::public_transfer(weapon_display, sender);
    transfer::public_transfer(dogtag_display, sender);
    transfer::public_transfer(armor_display, sender);
    transfer::public_transfer(publisher, sender);
}
</code></pre>



</details>
