// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// SuiNS-backed name registry. An `Instance` locks a SuiNS name (or subname)
/// and acts as the parent authority for the leaf records under it: any address
/// registers `<label>.<name>` resolving to itself, renames it and removes it.
///
/// The leaf's target address in the SuiNS registry is the source of truth for
/// ownership, so the instance keeps no state besides the name.
module commander_names::commander_names;

use std::string::String;
use sui::clock::Clock;
use suins::{
    controller,
    domain::{Self, Domain},
    registry::Registry,
    subdomain_registration::SubDomainRegistration,
    suins::SuiNS,
    suins_registration::SuinsRegistration
};
use suins_subdomains::subdomains;

/// The sender is not the creator of the instance.
const ENotCreator: u64 = 0;
/// The instance already holds a name.
const ENameAlreadySet: u64 = 1;
/// The instance holds no name.
const ENoName: u64 = 2;
/// The label is already registered under the held name.
const ELabelTaken: u64 = 3;
/// There is no leaf record for the label.
const ENoRecord: u64 = 4;
/// The leaf record does not resolve to the sender.
const ENotOwner: u64 = 5;
/// The held name is not of the requested kind.
const EKindMismatch: u64 = 6;
/// The instance still holds a name.
const ENotEmpty: u64 = 7;

/// The name locked in the instance: a second-level name or a subname.
public enum Name has store {
    Registration(SuinsRegistration),
    SubDomain(SubDomainRegistration),
}

/// Shared object holding the name and serving leaf records under it.
public struct Instance has key {
    id: UID,
    /// The only address allowed to deposit, withdraw and delete.
    creator: address,
    /// The name all leaf records are created under.
    name: Option<Name>,
}

/// Create an empty instance; the sender becomes its creator.
public fun new(ctx: &mut TxContext): Instance {
    Instance { id: object::new(ctx), creator: ctx.sender(), name: option::none() }
}

/// Share the instance.
public fun share(self: Instance) {
    transfer::share_object(self)
}

/// Delete an empty instance. Creator only.
public fun delete(self: Instance, ctx: &TxContext) {
    assert!(ctx.sender() == self.creator, ENotCreator);
    assert!(self.name.is_none(), ENotEmpty);
    let Instance { id, creator: _, name } = self;
    name.destroy_none();
    id.delete()
}

// === Name ===

/// Lock a second-level name (`name.sui`) in the instance. Creator only, while
/// the instance is empty.
public fun deposit_name(self: &mut Instance, name: SuinsRegistration, ctx: &TxContext) {
    self.deposit(Name::Registration(name), ctx)
}

/// Lock a subname (`sub.name.sui`) in the instance. Creator only, while the
/// instance is empty. The subname must have been created with `allow_creation`,
/// or registration aborts in SuiNS.
public fun deposit_subname(self: &mut Instance, name: SubDomainRegistration, ctx: &TxContext) {
    self.deposit(Name::SubDomain(name), ctx)
}

/// Take the second-level name out. Creator only. Leaf records stay in SuiNS
/// and are managed by the instance again once the same name is deposited.
public fun withdraw_name(self: &mut Instance, ctx: &TxContext): SuinsRegistration {
    match (self.withdraw(ctx)) {
        Name::Registration(nft) => nft,
        Name::SubDomain(_sub) => abort EKindMismatch,
    }
}

/// Take the subname out. Creator only.
public fun withdraw_subname(self: &mut Instance, ctx: &TxContext): SubDomainRegistration {
    match (self.withdraw(ctx)) {
        Name::SubDomain(sub) => sub,
        Name::Registration(_nft) => abort EKindMismatch,
    }
}

// === Leaf records ===

/// Register the leaf `<label>.<name>` resolving to the sender.
public fun register(
    self: &Instance,
    suins: &mut SuiNS,
    label: String,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let domain = self.subdomain(label);
    assert!(!self.is_taken(suins.registry(), domain, clock), ELabelTaken);
    subdomains::new_leaf(suins, self.parent(), clock, domain.to_string(), ctx.sender(), ctx)
}

/// Rename the sender's leaf `<label>.<name>` to `<new_label>.<name>`. Keeps it
/// the sender's default name if it was one.
public fun rename(
    self: &Instance,
    suins: &mut SuiNS,
    label: String,
    new_label: String,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let domain = self.owned_leaf(suins, label, ctx);
    let registry: &Registry = suins.registry();
    let is_default = registry.reverse_lookup(ctx.sender()) == option::some(domain);
    subdomains::remove_leaf(suins, self.parent(), clock, domain.to_string());
    self.register(suins, new_label, clock, ctx);
    if (is_default) self.set_default(suins, new_label, ctx)
}

/// Remove the sender's leaf `<label>.<name>`. SuiNS drops the sender's default
/// name if it was this leaf.
public fun remove(
    self: &Instance,
    suins: &mut SuiNS,
    label: String,
    clock: &Clock,
    ctx: &TxContext,
) {
    let domain = self.owned_leaf(suins, label, ctx);
    subdomains::remove_leaf(suins, self.parent(), clock, domain.to_string())
}

/// Make the sender's leaf `<label>.<name>` their default name in the SuiNS
/// reverse registry (address to name). Forward resolution needs no extra step.
public fun set_default(self: &Instance, suins: &mut SuiNS, label: String, ctx: &TxContext) {
    let domain = self.owned_leaf(suins, label, ctx);
    controller::set_reverse_lookup(suins, domain.to_string(), ctx)
}

// === Reads ===

/// The address `<label>.<name>` resolves to, if the leaf exists.
public fun resolve(self: &Instance, suins: &SuiNS, label: String): Option<address> {
    leaf_target(suins.registry(), self.subdomain(label))
}

/// The creator of the instance.
public fun creator(self: &Instance): address { self.creator }

/// Whether a name is locked in the instance.
public fun has_name(self: &Instance): bool { self.name.is_some() }

/// The locked name, e.g. `commander.sui`. Aborts if there is none.
public fun domain_name(self: &Instance): String { self.parent().domain_name() }

// === Internal ===

fun deposit(self: &mut Instance, name: Name, ctx: &TxContext) {
    assert!(ctx.sender() == self.creator, ENotCreator);
    assert!(self.name.is_none(), ENameAlreadySet);
    self.name.fill(name)
}

fun withdraw(self: &mut Instance, ctx: &TxContext): Name {
    assert!(ctx.sender() == self.creator, ENotCreator);
    assert!(self.name.is_some(), ENoName);
    self.name.extract()
}

/// The locked `SuinsRegistration`, the parent of every leaf; for a subname, the wrapped one.
fun parent(self: &Instance): &SuinsRegistration {
    assert!(self.name.is_some(), ENoName);
    match (self.name.borrow()) {
        Name::Registration(nft) => nft,
        Name::SubDomain(sub) => sub.nft(),
    }
}

/// `<label>.<name>` as a validated `Domain`.
fun subdomain(self: &Instance, label: String): Domain {
    let mut name = label;
    name.append_utf8(b".");
    name.append(self.parent().domain_name());
    domain::new(name)
}

/// `<label>.<name>` after checking that it is a leaf resolving to the sender.
fun owned_leaf(self: &Instance, suins: &SuiNS, label: String, ctx: &TxContext): Domain {
    let domain = self.subdomain(label);
    let target = leaf_target(suins.registry(), domain);
    assert!(target.is_some(), ENoRecord);
    assert!(target.destroy_some() == ctx.sender(), ENotOwner);
    domain
}

/// Whether SuiNS would refuse a new leaf at `domain`: a leaf under the held
/// name or a live node record. Expired records and leaves of a previous holder
/// of the name are overridden by SuiNS.
fun is_taken(self: &Instance, registry: &Registry, domain: Domain, clock: &Clock): bool {
    let record = registry.lookup(domain);
    if (record.is_none()) return false;
    let record = record.destroy_some();
    if (record.is_leaf_record()) {
        record.nft_id() == object::id(self.parent())
    } else {
        !record.has_expired(clock)
    }
}

/// Target address of the leaf record at `domain`, `none` if there is no leaf.
fun leaf_target(registry: &Registry, domain: Domain): Option<address> {
    let record = registry.lookup(domain);
    if (record.is_some() && record.borrow().is_leaf_record()) {
        record.destroy_some().target_address()
    } else {
        option::none()
    }
}
