// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander_names
module commander_names::commander_names;

use suins::suins_registration::SuinsRegistration;

/// Makes sure the `SuinsRegistration` object is returned.
public struct Borrow(ID)

/// Stores the record for name registration.
public struct CommanderNameRegistry has key {
    id: UID,
    registration: Option<SuinsRegistration>,
}

/// Create a new registry. Make sure to save its ID for future use.
public fun new(registration: SuinsRegistration, ctx: &mut TxContext) {
    transfer::share_object(CommanderNameRegistry {
        id: object::new(ctx),
        registration: option::some(registration),
    })
}

/// Borrow the record to add names / modify something. Normally it's dangerous
/// but we don't care that much on testnet with swappable / resettable names.
public fun borrow(r: &mut CommanderNameRegistry): (SuinsRegistration, Borrow) {
    let reg = r.registration.extract();
    let id = object::id(&reg);
    (reg, Borrow(id))
}

/// Put back the registration object and destroy the `Borrow` obligation.
public fun put_back(r: &mut CommanderNameRegistry, reg: SuinsRegistration, b: Borrow) {
    let Borrow(id) = b;
    assert!(object::id(&reg) == id);
    r.registration.fill(reg)
}
