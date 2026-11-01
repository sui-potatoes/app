
<a name="commander_names_commander_names"></a>

# Module `commander_names::commander_names`

SuiNS-backed name registry. An <code><a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a></code> locks a SuiNS name (or subname)
and acts as the parent authority for the leaf records under it: any address
registers <code>&lt;label&gt;.&lt;name&gt;</code> resolving to itself, renames it and removes it.

The leaf's target address in the SuiNS registry is the source of truth for
ownership, so the instance keeps no state besides the name.


-  [Struct `Instance`](#commander_names_commander_names_Instance)
-  [Enum `Name`](#commander_names_commander_names_Name)
-  [Constants](#@Constants_0)
-  [Function `new`](#commander_names_commander_names_new)
-  [Function `share`](#commander_names_commander_names_share)
-  [Function `delete`](#commander_names_commander_names_delete)
-  [Function `deposit_name`](#commander_names_commander_names_deposit_name)
-  [Function `deposit_subname`](#commander_names_commander_names_deposit_subname)
-  [Function `withdraw_name`](#commander_names_commander_names_withdraw_name)
-  [Function `withdraw_subname`](#commander_names_commander_names_withdraw_subname)
-  [Function `register`](#commander_names_commander_names_register)
-  [Function `rename`](#commander_names_commander_names_rename)
-  [Function `remove`](#commander_names_commander_names_remove)
-  [Function `set_default`](#commander_names_commander_names_set_default)
-  [Function `resolve`](#commander_names_commander_names_resolve)
-  [Function `creator`](#commander_names_commander_names_creator)
-  [Function `has_name`](#commander_names_commander_names_has_name)
-  [Function `domain_name`](#commander_names_commander_names_domain_name)
-  [Function `deposit`](#commander_names_commander_names_deposit)
-  [Function `withdraw`](#commander_names_commander_names_withdraw)
-  [Function `parent`](#commander_names_commander_names_parent)
-  [Function `subdomain`](#commander_names_commander_names_subdomain)
-  [Function `owned_leaf`](#commander_names_commander_names_owned_leaf)
-  [Function `is_taken`](#commander_names_commander_names_is_taken)
-  [Function `leaf_target`](#commander_names_commander_names_leaf_target)


<pre><code><b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/internal.md#std_internal">std::internal</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u128.md#std_u128">std::u128</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bag.md#sui_bag">sui::bag</a>;
<b>use</b> <a href="../../.doc-deps/sui/balance.md#sui_balance">sui::balance</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../../.doc-deps/sui/coin.md#sui_coin">sui::coin</a>;
<b>use</b> <a href="../../.doc-deps/sui/config.md#sui_config">sui::config</a>;
<b>use</b> <a href="../../.doc-deps/sui/deny_list.md#sui_deny_list">sui::deny_list</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_object_field.md#sui_dynamic_object_field">sui::dynamic_object_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/funds_accumulator.md#sui_funds_accumulator">sui::funds_accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/package.md#sui_package">sui::package</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/protocol_config.md#sui_protocol_config">sui::protocol_config</a>;
<b>use</b> <a href="../../.doc-deps/sui/sui.md#sui_sui">sui::sui</a>;
<b>use</b> <a href="../../.doc-deps/sui/table.md#sui_table">sui::table</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/types.md#sui_types">sui::types</a>;
<b>use</b> <a href="../../.doc-deps/sui/url.md#sui_url">sui::url</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_set.md#sui_vec_set">sui::vec_set</a>;
<b>use</b> <a href="../../.doc-deps/suins/constants.md#suins_constants">suins::constants</a>;
<b>use</b> <a href="../../.doc-deps/suins/controller.md#suins_controller">suins::controller</a>;
<b>use</b> <a href="../../.doc-deps/suins/domain.md#suins_domain">suins::domain</a>;
<b>use</b> <a href="../../.doc-deps/suins/name_record.md#suins_name_record">suins::name_record</a>;
<b>use</b> <a href="../../.doc-deps/suins/registry.md#suins_registry">suins::registry</a>;
<b>use</b> <a href="../../.doc-deps/suins/subdomain_registration.md#suins_subdomain_registration">suins::subdomain_registration</a>;
<b>use</b> <a href="../../.doc-deps/suins/suins.md#suins_suins">suins::suins</a>;
<b>use</b> <a href="../../.doc-deps/suins/suins_registration.md#suins_suins_registration">suins::suins_registration</a>;
<b>use</b> <a href="../../.doc-deps/suins_denylist/denylist.md#suins_denylist_denylist">suins_denylist::denylist</a>;
<b>use</b> <a href="../../.doc-deps/suins_subdomains/config.md#suins_subdomains_config">suins_subdomains::config</a>;
<b>use</b> <a href="../../.doc-deps/suins_subdomains/subdomains.md#suins_subdomains_subdomains">suins_subdomains::subdomains</a>;
</code></pre>



<a name="commander_names_commander_names_Instance"></a>

## Struct `Instance`

Shared object holding the name and serving leaf records under it.


<pre><code><b>public</b> <b>struct</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../.doc-deps/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./commander_names.md#commander_names_commander_names_creator">creator</a>: <b>address</b></code>
</dt>
<dd>
 The only address allowed to deposit, withdraw and delete.
</dd>
<dt>
<code>name: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./commander_names.md#commander_names_commander_names_Name">commander_names::commander_names::Name</a>&gt;</code>
</dt>
<dd>
 The name all leaf records are created under.
</dd>
</dl>


</details>

<a name="commander_names_commander_names_Name"></a>

## Enum `Name`

The name locked in the instance: a second-level name or a subname.


<pre><code><b>public</b> <b>enum</b> <a href="./commander_names.md#commander_names_commander_names_Name">Name</a> <b>has</b> store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Registration</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/suins/suins_registration.md#suins_suins_registration_SuinsRegistration">suins::suins_registration::SuinsRegistration</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>SubDomain</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/suins/subdomain_registration.md#suins_subdomain_registration_SubDomainRegistration">suins::subdomain_registration::SubDomainRegistration</a></code>
</dt>
<dd>
</dd>
</dl>

</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="commander_names_commander_names_ENotCreator"></a>

The sender is not the creator of the instance.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENotCreator">ENotCreator</a>: u64 = 0;
</code></pre>



<a name="commander_names_commander_names_ENameAlreadySet"></a>

The instance already holds a name.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENameAlreadySet">ENameAlreadySet</a>: u64 = 1;
</code></pre>



<a name="commander_names_commander_names_ENoName"></a>

The instance holds no name.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENoName">ENoName</a>: u64 = 2;
</code></pre>



<a name="commander_names_commander_names_ELabelTaken"></a>

The label is already registered under the held name.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ELabelTaken">ELabelTaken</a>: u64 = 3;
</code></pre>



<a name="commander_names_commander_names_ENoRecord"></a>

There is no leaf record for the label.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENoRecord">ENoRecord</a>: u64 = 4;
</code></pre>



<a name="commander_names_commander_names_ENotOwner"></a>

The leaf record does not resolve to the sender.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENotOwner">ENotOwner</a>: u64 = 5;
</code></pre>



<a name="commander_names_commander_names_EKindMismatch"></a>

The held name is not of the requested kind.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_EKindMismatch">EKindMismatch</a>: u64 = 6;
</code></pre>



<a name="commander_names_commander_names_ENotEmpty"></a>

The instance still holds a name.


<pre><code><b>const</b> <a href="./commander_names.md#commander_names_commander_names_ENotEmpty">ENotEmpty</a>: u64 = 7;
</code></pre>



<a name="commander_names_commander_names_new"></a>

## Function `new`

Create an empty instance; the sender becomes its creator.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_new">new</a>(ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_new">new</a>(ctx: &<b>mut</b> TxContext): <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a> {
    <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a> { id: object::new(ctx), <a href="./commander_names.md#commander_names_commander_names_creator">creator</a>: ctx.sender(), name: option::none() }
}
</code></pre>



</details>

<a name="commander_names_commander_names_share"></a>

## Function `share`

Share the instance.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_share">share</a>(self: <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_share">share</a>(self: <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>) {
    transfer::share_object(self)
}
</code></pre>



</details>

<a name="commander_names_commander_names_delete"></a>

## Function `delete`

Delete an empty instance. Creator only.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_delete">delete</a>(self: <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_delete">delete</a>(self: <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, ctx: &TxContext) {
    <b>assert</b>!(ctx.sender() == self.<a href="./commander_names.md#commander_names_commander_names_creator">creator</a>, <a href="./commander_names.md#commander_names_commander_names_ENotCreator">ENotCreator</a>);
    <b>assert</b>!(self.name.is_none(), <a href="./commander_names.md#commander_names_commander_names_ENotEmpty">ENotEmpty</a>);
    <b>let</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a> { id, <a href="./commander_names.md#commander_names_commander_names_creator">creator</a>: _, name } = self;
    name.destroy_none();
    id.<a href="./commander_names.md#commander_names_commander_names_delete">delete</a>()
}
</code></pre>



</details>

<a name="commander_names_commander_names_deposit_name"></a>

## Function `deposit_name`

Lock a second-level name (<code>name.sui</code>) in the instance. Creator only, while
the instance is empty.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit_name">deposit_name</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, name: <a href="../../.doc-deps/suins/suins_registration.md#suins_suins_registration_SuinsRegistration">suins::suins_registration::SuinsRegistration</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit_name">deposit_name</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, name: SuinsRegistration, ctx: &TxContext) {
    self.<a href="./commander_names.md#commander_names_commander_names_deposit">deposit</a>(Name::Registration(name), ctx)
}
</code></pre>



</details>

<a name="commander_names_commander_names_deposit_subname"></a>

## Function `deposit_subname`

Lock a subname (<code>sub.name.sui</code>) in the instance. Creator only, while the
instance is empty. The subname must have been created with <code>allow_creation</code>,
or registration aborts in SuiNS.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit_subname">deposit_subname</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, name: <a href="../../.doc-deps/suins/subdomain_registration.md#suins_subdomain_registration_SubDomainRegistration">suins::subdomain_registration::SubDomainRegistration</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit_subname">deposit_subname</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, name: SubDomainRegistration, ctx: &TxContext) {
    self.<a href="./commander_names.md#commander_names_commander_names_deposit">deposit</a>(Name::SubDomain(name), ctx)
}
</code></pre>



</details>

<a name="commander_names_commander_names_withdraw_name"></a>

## Function `withdraw_name`

Take the second-level name out. Creator only. Leaf records stay in SuiNS
and are managed by the instance again once the same name is deposited.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw_name">withdraw_name</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../.doc-deps/suins/suins_registration.md#suins_suins_registration_SuinsRegistration">suins::suins_registration::SuinsRegistration</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw_name">withdraw_name</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, ctx: &TxContext): SuinsRegistration {
    match (self.<a href="./commander_names.md#commander_names_commander_names_withdraw">withdraw</a>(ctx)) {
        Name::Registration(nft) =&gt; nft,
        Name::SubDomain(_sub) =&gt; <b>abort</b> <a href="./commander_names.md#commander_names_commander_names_EKindMismatch">EKindMismatch</a>,
    }
}
</code></pre>



</details>

<a name="commander_names_commander_names_withdraw_subname"></a>

## Function `withdraw_subname`

Take the subname out. Creator only.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw_subname">withdraw_subname</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../.doc-deps/suins/subdomain_registration.md#suins_subdomain_registration_SubDomainRegistration">suins::subdomain_registration::SubDomainRegistration</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw_subname">withdraw_subname</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, ctx: &TxContext): SubDomainRegistration {
    match (self.<a href="./commander_names.md#commander_names_commander_names_withdraw">withdraw</a>(ctx)) {
        Name::SubDomain(sub) =&gt; sub,
        Name::Registration(_nft) =&gt; <b>abort</b> <a href="./commander_names.md#commander_names_commander_names_EKindMismatch">EKindMismatch</a>,
    }
}
</code></pre>



</details>

<a name="commander_names_commander_names_register"></a>

## Function `register`

Register the leaf <code>&lt;label&gt;.&lt;name&gt;</code> resolving to the sender.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_register">register</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<b>mut</b> <a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_register">register</a>(
    self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>,
    suins: &<b>mut</b> SuiNS,
    label: String,
    clock: &Clock,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> domain = self.<a href="./commander_names.md#commander_names_commander_names_subdomain">subdomain</a>(label);
    <b>assert</b>!(!self.<a href="./commander_names.md#commander_names_commander_names_is_taken">is_taken</a>(suins.registry(), domain, clock), <a href="./commander_names.md#commander_names_commander_names_ELabelTaken">ELabelTaken</a>);
    subdomains::new_leaf(suins, self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>(), clock, domain.to_string(), ctx.sender(), ctx)
}
</code></pre>



</details>

<a name="commander_names_commander_names_rename"></a>

## Function `rename`

Rename the sender's leaf <code>&lt;label&gt;.&lt;name&gt;</code> to <code>&lt;new_label&gt;.&lt;name&gt;</code>. Keeps it
the sender's default name if it was one.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_rename">rename</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<b>mut</b> <a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, new_label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_rename">rename</a>(
    self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>,
    suins: &<b>mut</b> SuiNS,
    label: String,
    new_label: String,
    clock: &Clock,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> domain = self.<a href="./commander_names.md#commander_names_commander_names_owned_leaf">owned_leaf</a>(suins, label, ctx);
    <b>let</b> registry: &Registry = suins.registry();
    <b>let</b> is_default = registry.reverse_lookup(ctx.sender()) == option::some(domain);
    subdomains::remove_leaf(suins, self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>(), clock, domain.to_string());
    self.<a href="./commander_names.md#commander_names_commander_names_register">register</a>(suins, new_label, clock, ctx);
    <b>if</b> (is_default) self.<a href="./commander_names.md#commander_names_commander_names_set_default">set_default</a>(suins, new_label, ctx)
}
</code></pre>



</details>

<a name="commander_names_commander_names_remove"></a>

## Function `remove`

Remove the sender's leaf <code>&lt;label&gt;.&lt;name&gt;</code>. SuiNS drops the sender's default
name if it was this leaf.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_remove">remove</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<b>mut</b> <a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_remove">remove</a>(
    self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>,
    suins: &<b>mut</b> SuiNS,
    label: String,
    clock: &Clock,
    ctx: &TxContext,
) {
    <b>let</b> domain = self.<a href="./commander_names.md#commander_names_commander_names_owned_leaf">owned_leaf</a>(suins, label, ctx);
    subdomains::remove_leaf(suins, self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>(), clock, domain.to_string())
}
</code></pre>



</details>

<a name="commander_names_commander_names_set_default"></a>

## Function `set_default`

Make the sender's leaf <code>&lt;label&gt;.&lt;name&gt;</code> their default name in the SuiNS
reverse registry (address to name). Forward resolution needs no extra step.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_set_default">set_default</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<b>mut</b> <a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_set_default">set_default</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, suins: &<b>mut</b> SuiNS, label: String, ctx: &TxContext) {
    <b>let</b> domain = self.<a href="./commander_names.md#commander_names_commander_names_owned_leaf">owned_leaf</a>(suins, label, ctx);
    controller::set_reverse_lookup(suins, domain.to_string(), ctx)
}
</code></pre>



</details>

<a name="commander_names_commander_names_resolve"></a>

## Function `resolve`

The address <code>&lt;label&gt;.&lt;name&gt;</code> resolves to, if the leaf exists.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_resolve">resolve</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_resolve">resolve</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, suins: &SuiNS, label: String): Option&lt;<b>address</b>&gt; {
    <a href="./commander_names.md#commander_names_commander_names_leaf_target">leaf_target</a>(suins.registry(), self.<a href="./commander_names.md#commander_names_commander_names_subdomain">subdomain</a>(label))
}
</code></pre>



</details>

<a name="commander_names_commander_names_creator"></a>

## Function `creator`

The creator of the instance.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_creator">creator</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_creator">creator</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>): <b>address</b> { self.<a href="./commander_names.md#commander_names_commander_names_creator">creator</a> }
</code></pre>



</details>

<a name="commander_names_commander_names_has_name"></a>

## Function `has_name`

Whether a name is locked in the instance.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_has_name">has_name</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_has_name">has_name</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>): bool { self.name.is_some() }
</code></pre>



</details>

<a name="commander_names_commander_names_domain_name"></a>

## Function `domain_name`

The locked name, e.g. <code>commander.sui</code>. Aborts if there is none.


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_domain_name">domain_name</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander_names.md#commander_names_commander_names_domain_name">domain_name</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>): String { self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>().<a href="./commander_names.md#commander_names_commander_names_domain_name">domain_name</a>() }
</code></pre>



</details>

<a name="commander_names_commander_names_deposit"></a>

## Function `deposit`



<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit">deposit</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, name: <a href="./commander_names.md#commander_names_commander_names_Name">commander_names::commander_names::Name</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_deposit">deposit</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, name: <a href="./commander_names.md#commander_names_commander_names_Name">Name</a>, ctx: &TxContext) {
    <b>assert</b>!(ctx.sender() == self.<a href="./commander_names.md#commander_names_commander_names_creator">creator</a>, <a href="./commander_names.md#commander_names_commander_names_ENotCreator">ENotCreator</a>);
    <b>assert</b>!(self.name.is_none(), <a href="./commander_names.md#commander_names_commander_names_ENameAlreadySet">ENameAlreadySet</a>);
    self.name.fill(name)
}
</code></pre>



</details>

<a name="commander_names_commander_names_withdraw"></a>

## Function `withdraw`



<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw">withdraw</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./commander_names.md#commander_names_commander_names_Name">commander_names::commander_names::Name</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_withdraw">withdraw</a>(self: &<b>mut</b> <a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, ctx: &TxContext): <a href="./commander_names.md#commander_names_commander_names_Name">Name</a> {
    <b>assert</b>!(ctx.sender() == self.<a href="./commander_names.md#commander_names_commander_names_creator">creator</a>, <a href="./commander_names.md#commander_names_commander_names_ENotCreator">ENotCreator</a>);
    <b>assert</b>!(self.name.is_some(), <a href="./commander_names.md#commander_names_commander_names_ENoName">ENoName</a>);
    self.name.extract()
}
</code></pre>



</details>

<a name="commander_names_commander_names_parent"></a>

## Function `parent`

The locked <code>SuinsRegistration</code>, the parent of every leaf; for a subname, the wrapped one.


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_parent">parent</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>): &<a href="../../.doc-deps/suins/suins_registration.md#suins_suins_registration_SuinsRegistration">suins::suins_registration::SuinsRegistration</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_parent">parent</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>): &SuinsRegistration {
    <b>assert</b>!(self.name.is_some(), <a href="./commander_names.md#commander_names_commander_names_ENoName">ENoName</a>);
    match (self.name.borrow()) {
        Name::Registration(nft) =&gt; nft,
        Name::SubDomain(sub) =&gt; sub.nft(),
    }
}
</code></pre>



</details>

<a name="commander_names_commander_names_subdomain"></a>

## Function `subdomain`

<code>&lt;label&gt;.&lt;name&gt;</code> as a validated <code>Domain</code>.


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_subdomain">subdomain</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): <a href="../../.doc-deps/suins/domain.md#suins_domain_Domain">suins::domain::Domain</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_subdomain">subdomain</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, label: String): Domain {
    <b>let</b> <b>mut</b> name = label;
    name.append_utf8(b".");
    name.append(self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>().<a href="./commander_names.md#commander_names_commander_names_domain_name">domain_name</a>());
    domain::new(name)
}
</code></pre>



</details>

<a name="commander_names_commander_names_owned_leaf"></a>

## Function `owned_leaf`

<code>&lt;label&gt;.&lt;name&gt;</code> after checking that it is a leaf resolving to the sender.


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_owned_leaf">owned_leaf</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, suins: &<a href="../../.doc-deps/suins/suins.md#suins_suins_SuiNS">suins::suins::SuiNS</a>, label: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../.doc-deps/suins/domain.md#suins_domain_Domain">suins::domain::Domain</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_owned_leaf">owned_leaf</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, suins: &SuiNS, label: String, ctx: &TxContext): Domain {
    <b>let</b> domain = self.<a href="./commander_names.md#commander_names_commander_names_subdomain">subdomain</a>(label);
    <b>let</b> target = <a href="./commander_names.md#commander_names_commander_names_leaf_target">leaf_target</a>(suins.registry(), domain);
    <b>assert</b>!(target.is_some(), <a href="./commander_names.md#commander_names_commander_names_ENoRecord">ENoRecord</a>);
    <b>assert</b>!(target.destroy_some() == ctx.sender(), <a href="./commander_names.md#commander_names_commander_names_ENotOwner">ENotOwner</a>);
    domain
}
</code></pre>



</details>

<a name="commander_names_commander_names_is_taken"></a>

## Function `is_taken`

Whether SuiNS would refuse a new leaf at <code>domain</code>: a leaf under the held
name or a live node record. Expired records and leaves of a previous holder
of the name are overridden by SuiNS.


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_is_taken">is_taken</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">commander_names::commander_names::Instance</a>, registry: &<a href="../../.doc-deps/suins/registry.md#suins_registry_Registry">suins::registry::Registry</a>, domain: <a href="../../.doc-deps/suins/domain.md#suins_domain_Domain">suins::domain::Domain</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_is_taken">is_taken</a>(self: &<a href="./commander_names.md#commander_names_commander_names_Instance">Instance</a>, registry: &Registry, domain: Domain, clock: &Clock): bool {
    <b>let</b> record = registry.lookup(domain);
    <b>if</b> (record.is_none()) <b>return</b> <b>false</b>;
    <b>let</b> record = record.destroy_some();
    <b>if</b> (record.is_leaf_record()) {
        record.nft_id() == object::id(self.<a href="./commander_names.md#commander_names_commander_names_parent">parent</a>())
    } <b>else</b> {
        !record.has_expired(clock)
    }
}
</code></pre>



</details>

<a name="commander_names_commander_names_leaf_target"></a>

## Function `leaf_target`

Target address of the leaf record at <code>domain</code>, <code>none</code> if there is no leaf.


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_leaf_target">leaf_target</a>(registry: &<a href="../../.doc-deps/suins/registry.md#suins_registry_Registry">suins::registry::Registry</a>, domain: <a href="../../.doc-deps/suins/domain.md#suins_domain_Domain">suins::domain::Domain</a>): <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<b>address</b>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander_names.md#commander_names_commander_names_leaf_target">leaf_target</a>(registry: &Registry, domain: Domain): Option&lt;<b>address</b>&gt; {
    <b>let</b> record = registry.lookup(domain);
    <b>if</b> (record.is_some() && record.borrow().is_leaf_record()) {
        record.destroy_some().target_address()
    } <b>else</b> {
        option::none()
    }
}
</code></pre>



</details>
