
<a name="(commander=0x0)_display"></a>

# Module `(commander=0x0)::display`

Implements Sui Object Display for objects in the game.


-  [Struct `DISPLAY`](#(commander=0x0)_display_DISPLAY)
-  [Function `init`](#(commander=0x0)_display_init)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade">weapon_upgrade</a>;
<b>use</b> <a href="../dependencies/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../dependencies/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/display.md#sui_display">sui::display</a>;
<b>use</b> <a href="../dependencies/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/package.md#sui_package">sui::package</a>;
<b>use</b> <a href="../dependencies/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../dependencies/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../dependencies/sui/types.md#sui_types">sui::types</a>;
<b>use</b> <a href="../dependencies/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(commander=0x0)_display_DISPLAY"></a>

## Struct `DISPLAY`



<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/display.md#(commander=0x0)_display_DISPLAY">DISPLAY</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
</dl>


</details>

<a name="(commander=0x0)_display_init"></a>

## Function `init`

Creates Display objects for the Recruit and Weapon objects.


<pre><code><b>fun</b> <a href="../name_gen/display.md#(commander=0x0)_display_init">init</a>(otw: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/display.md#(commander=0x0)_display_DISPLAY">display::DISPLAY</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../name_gen/display.md#(commander=0x0)_display_init">init</a>(otw: <a href="../name_gen/display.md#(commander=0x0)_display_DISPLAY">DISPLAY</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> publisher = package::claim(otw, ctx);
    // Display <b>for</b> the `Recruit` object.
    <b>let</b> recruit_display = {
        <b>let</b> <b>mut</b> <a href="../name_gen/display.md#(commander=0x0)_display">display</a> = display::new&lt;Recruit&gt;(&publisher, ctx);
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"name".to_string(), b"{metadata.name} (Rank: {<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>})".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"description".to_string(), b"{metadata.description}".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.webp".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"link".to_string(),
            b"https://potatoes.app/<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>/<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>/{id}".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.update_version();
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>
    };
    // Display <b>for</b> the `Weapon` object.
    <b>let</b> weapon_display = {
        <b>let</b> <b>mut</b> <a href="../name_gen/display.md#(commander=0x0)_display">display</a> = display::new&lt;Weapon&gt;(&publisher, ctx);
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.webp".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"link".to_string(), b"".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.update_version();
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>
    };
    // Armor <a href="../name_gen/display.md#(commander=0x0)_display">display</a>
    <b>let</b> armor_display = {
        <b>let</b> <b>mut</b> <a href="../name_gen/display.md#(commander=0x0)_display">display</a> = display::new&lt;Armor&gt;(&publisher, ctx);
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>-light.webp".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"link".to_string(), b"".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.update_version();
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>
    };
    // Display <b>for</b> the `DogTag` object.
    <b>let</b> dogtag_display = {
        <b>let</b> <b>mut</b> <a href="../name_gen/display.md#(commander=0x0)_display">display</a> = display::new&lt;DogTag&gt;(&publisher, ctx);
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"name".to_string(), b"{metadata.name} (Rank: {<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>})".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(b"description".to_string(), b"{metadata.description}".to_string());
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.webp".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.add(
            b"link".to_string(),
            b"https://potatoes.app/<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>/<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>/{id}".to_string(),
        );
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>.update_version();
        <a href="../name_gen/display.md#(commander=0x0)_display">display</a>
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
