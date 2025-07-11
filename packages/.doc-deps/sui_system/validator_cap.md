
<a name="sui_system_validator_cap"></a>

# Module `sui_system::validator_cap`



-  [Struct `UnverifiedValidatorOperationCap`](#sui_system_validator_cap_UnverifiedValidatorOperationCap)
-  [Struct `ValidatorOperationCap`](#sui_system_validator_cap_ValidatorOperationCap)
-  [Function `unverified_operation_cap_address`](#sui_system_validator_cap_unverified_operation_cap_address)
-  [Function `verified_operation_cap_address`](#sui_system_validator_cap_verified_operation_cap_address)
-  [Function `new_unverified_validator_operation_cap_and_transfer`](#sui_system_validator_cap_new_unverified_validator_operation_cap_and_transfer)
-  [Function `into_verified`](#sui_system_validator_cap_into_verified)


<pre><code><b>use</b> <a href="../../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../dependencies/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../dependencies/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../dependencies/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="sui_system_validator_cap_UnverifiedValidatorOperationCap"></a>

## Struct `UnverifiedValidatorOperationCap`

The capability object is created when creating a new <code>Validator</code> or when the
validator explicitly creates a new capability object for rotation/revocation.
The holder address of this object can perform some validator operations on behalf of
the authorizer validator. Thus, if a validator wants to separate the keys for operation
(such as reference gas price setting or tallying rule reporting) from fund/staking, it
could transfer this capability object to another address.
To facilitate rotating/revocation, <code>Validator</code> stores the ID of currently valid
<code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a></code>. Thus, before converting <code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a></code>
to <code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a></code>, verification needs to be done to make sure
the cap object is still valid.


<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a> <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>authorizer_validator_address: <b>address</b></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_system_validator_cap_ValidatorOperationCap"></a>

## Struct `ValidatorOperationCap`

Privileged operations require <code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a></code> for permission check.
This is only constructed after successful verification.


<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>authorizer_validator_address: <b>address</b></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_system_validator_cap_unverified_operation_cap_address"></a>

## Function `unverified_operation_cap_address`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_unverified_operation_cap_address">unverified_operation_cap_address</a>(cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">sui_system::validator_cap::UnverifiedValidatorOperationCap</a>): &<b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_unverified_operation_cap_address">unverified_operation_cap_address</a>(
    cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a>,
): &<b>address</b> {
    &cap.authorizer_validator_address
}
</code></pre>



</details>

<a name="sui_system_validator_cap_verified_operation_cap_address"></a>

## Function `verified_operation_cap_address`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_verified_operation_cap_address">verified_operation_cap_address</a>(cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">sui_system::validator_cap::ValidatorOperationCap</a>): &<b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_verified_operation_cap_address">verified_operation_cap_address</a>(cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a>): &<b>address</b> {
    &cap.authorizer_validator_address
}
</code></pre>



</details>

<a name="sui_system_validator_cap_new_unverified_validator_operation_cap_and_transfer"></a>

## Function `new_unverified_validator_operation_cap_and_transfer`

Should be only called by the friend modules when adding a <code>Validator</code>
or rotating an existing validaotr's <code>operation_cap_id</code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_new_unverified_validator_operation_cap_and_transfer">new_unverified_validator_operation_cap_and_transfer</a>(validator_address: <b>address</b>, ctx: &<b>mut</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_new_unverified_validator_operation_cap_and_transfer">new_unverified_validator_operation_cap_and_transfer</a>(
    validator_address: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): ID {
    // This function needs to be called only by the validator itself, except
    // 1. in genesis where all valdiators are created by @0x0
    // 2. in tests where @0x0 could be used to simplify the setup
    <b>let</b> sender_address = ctx.sender();
    <b>assert</b>!(sender_address == @0x0 || sender_address == validator_address, 0);
    <b>let</b> operation_cap = <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a> {
        id: object::new(ctx),
        authorizer_validator_address: validator_address,
    };
    <b>let</b> operation_cap_id = object::id(&operation_cap);
    transfer::public_transfer(operation_cap, validator_address);
    operation_cap_id
}
</code></pre>



</details>

<a name="sui_system_validator_cap_into_verified"></a>

## Function `into_verified`

Convert an <code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a></code> to <code><a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a></code>.
Should only be called by <code>validator_set</code> module AFTER verification.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_into_verified">into_verified</a>(cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">sui_system::validator_cap::UnverifiedValidatorOperationCap</a>): <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">sui_system::validator_cap::ValidatorOperationCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_into_verified">into_verified</a>(cap: &<a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_UnverifiedValidatorOperationCap">UnverifiedValidatorOperationCap</a>): <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a> {
    <a href="../../dependencies/sui_system/validator_cap.md#sui_system_validator_cap_ValidatorOperationCap">ValidatorOperationCap</a> { authorizer_validator_address: cap.authorizer_validator_address }
}
</code></pre>



</details>
