// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander_names::commander_names_tests;

use commander_names::commander_names::{Self as names, Instance};
use std::{string::String, unit_test::{assert_eq, destroy}};
use sui::{clock::{Self, Clock}, test_scenario::{Self as ts, Scenario}};
use suins::{
    controller::ControllerV2,
    domain,
    registry::{Self, Registry},
    suins::{Self, SuiNS},
    suins_registration::SuinsRegistration
};
use suins_denylist::denylist;
use suins_subdomains::{config, subdomains::{Self, SubDomains}};

const CREATOR: address = @0xC;
const ALICE: address = @0xA;
const BOB: address = @0xB;

const DAY_MS: u64 = 24 * 60 * 60 * 1000;

#[test]
fun create_and_deposit_name() {
    let mut ts = setup();
    let name = sld(&mut ts, b"test.sui");
    ts.next_tx(CREATOR);
    let mut instance = names::new(ts.ctx());
    assert!(!instance.has_name());
    instance.deposit_name(name, ts.ctx());
    assert!(instance.has_name());
    assert_eq!(instance.creator(), CREATOR);
    assert_eq!(instance.domain_name(), b"test.sui".to_string());
    instance.share();
    ts.end();
}

#[test]
fun deposit_subname() {
    let mut ts = setup();
    let parent = sld(&mut ts, b"test.sui");

    ts.next_tx(CREATOR);
    let mut suins = ts.take_shared<SuiNS>();
    let clock = ts.take_shared<Clock>();
    let name = b"sub.test.sui".to_string();
    let sub = subdomains::new(&mut suins, &parent, &clock, name, DAY_MS, true, false, ts.ctx());
    ts::return_shared(suins);
    ts::return_shared(clock);

    let mut instance = names::new(ts.ctx());
    instance.deposit_subname(sub, ts.ctx());
    assert_eq!(instance.domain_name(), b"sub.test.sui".to_string());
    instance.share();

    register(&mut ts, ALICE, b"alice");
    assert_eq!(resolve(&mut ts, b"alice"), option::some(ALICE));

    // the creator takes the subname back and deletes the instance
    ts.next_tx(CREATOR);
    let mut instance = ts.take_shared<Instance>();
    let sub = instance.withdraw_subname(ts.ctx());
    instance.delete(ts.ctx());

    destroy(sub);
    destroy(parent);
    ts.end();
}

#[test]
fun withdraw_and_delete() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");

    ts.next_tx(CREATOR);
    let mut instance = ts.take_shared<Instance>();
    let name = instance.withdraw_name(ts.ctx());
    assert!(!instance.has_name());
    // the same name goes back in and the leaf is managed again
    instance.deposit_name(name, ts.ctx());
    let suins = ts.take_shared<SuiNS>();
    assert_eq!(instance.resolve(&suins, b"alice".to_string()), option::some(ALICE));
    ts::return_shared(suins);
    let name = instance.withdraw_name(ts.ctx());
    instance.delete(ts.ctx());

    destroy(name);
    ts.end();
}

#[test]
fun register_leaf() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    assert_eq!(resolve(&mut ts, b"alice"), option::none());
    register(&mut ts, ALICE, b"alice");
    assert_eq!(resolve(&mut ts, b"alice"), option::some(ALICE));
    ts.end();
}

#[test]
fun rename_leaf() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    rename(&mut ts, ALICE, b"alice", b"ally");
    assert_eq!(resolve(&mut ts, b"alice"), option::none());
    assert_eq!(resolve(&mut ts, b"ally"), option::some(ALICE));
    ts.end();
}

#[test]
fun remove_leaf() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    remove(&mut ts, ALICE, b"alice");
    assert_eq!(resolve(&mut ts, b"alice"), option::none());
    // the label is free again
    register(&mut ts, BOB, b"alice");
    assert_eq!(resolve(&mut ts, b"alice"), option::some(BOB));
    ts.end();
}

#[test]
fun default_name_follows_the_leaf() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    assert_eq!(default_name(&mut ts, ALICE), option::none());
    set_default(&mut ts, ALICE, b"alice");
    assert_eq!(default_name(&mut ts, ALICE), option::some(b"alice.test.sui".to_string()));
    rename(&mut ts, ALICE, b"alice", b"ally");
    assert_eq!(default_name(&mut ts, ALICE), option::some(b"ally.test.sui".to_string()));
    remove(&mut ts, ALICE, b"ally");
    assert_eq!(default_name(&mut ts, ALICE), option::none());
    ts.end();
}

#[test]
fun rename_keeps_other_default() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    register(&mut ts, ALICE, b"ally");
    set_default(&mut ts, ALICE, b"ally");
    rename(&mut ts, ALICE, b"alice", b"alexa");
    assert_eq!(default_name(&mut ts, ALICE), option::some(b"ally.test.sui".to_string()));
    ts.end();
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotOwner)]
fun remove_not_owner() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    remove(&mut ts, BOB, b"alice");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotOwner)]
fun rename_not_owner() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    rename(&mut ts, BOB, b"alice", b"bob");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotOwner)]
fun set_default_not_owner() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    set_default(&mut ts, BOB, b"alice");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENoRecord)]
fun remove_missing() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    remove(&mut ts, ALICE, b"alice");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ELabelTaken)]
fun register_taken_label() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    register(&mut ts, ALICE, b"alice");
    register(&mut ts, BOB, b"alice");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENoName)]
fun register_without_name() {
    let mut ts = setup();
    ts.next_tx(CREATOR);
    names::new(ts.ctx()).share();
    register(&mut ts, ALICE, b"alice");
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotCreator)]
fun deposit_not_creator() {
    let mut ts = setup();
    let name = sld(&mut ts, b"test.sui");
    ts.next_tx(CREATOR);
    names::new(ts.ctx()).share();
    ts.next_tx(ALICE);
    let mut instance = ts.take_shared<Instance>();
    instance.deposit_name(name, ts.ctx());
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENameAlreadySet)]
fun deposit_twice() {
    let mut ts = setup();
    let name = sld(&mut ts, b"test.sui");
    let other = sld(&mut ts, b"other.sui");
    ts.next_tx(CREATOR);
    let mut instance = names::new(ts.ctx());
    instance.deposit_name(name, ts.ctx());
    instance.deposit_name(other, ts.ctx());
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotCreator)]
fun withdraw_not_creator() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    ts.next_tx(ALICE);
    let mut instance = ts.take_shared<Instance>();
    let _name = instance.withdraw_name(ts.ctx());
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::EKindMismatch)]
fun withdraw_wrong_kind() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    ts.next_tx(CREATOR);
    let mut instance = ts.take_shared<Instance>();
    let _sub = instance.withdraw_subname(ts.ctx());
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotEmpty)]
fun delete_not_empty() {
    let mut ts = setup();
    new_instance(&mut ts, b"test.sui");
    ts.next_tx(CREATOR);
    let instance = ts.take_shared<Instance>();
    instance.delete(ts.ctx());
    abort
}

#[test, expected_failure(abort_code = commander_names::commander_names::ENotCreator)]
fun delete_not_creator() {
    let mut ts = setup();
    ts.next_tx(CREATOR);
    names::new(ts.ctx()).share();
    ts.next_tx(ALICE);
    let instance = ts.take_shared<Instance>();
    instance.delete(ts.ctx());
    abort
}

// === Helpers ===

/// Shared `SuiNS` with the registry, denylist, subdomains and controller apps
/// set up, and a shared `Clock` at `0`.
fun setup(): Scenario {
    let mut ts = ts::begin(CREATOR);
    let mut suins = suins::init_for_testing(ts.ctx());
    let cap = suins::create_admin_cap_for_testing(ts.ctx());
    suins.authorize_app_for_testing<SubDomains>();
    suins.authorize_app_for_testing<ControllerV2>();
    cap.add_config(&mut suins, config::default());
    registry::init_for_testing(&cap, &mut suins, ts.ctx());
    denylist::setup(&mut suins, &cap, ts.ctx());
    suins::burn_admin_cap_for_testing(cap);
    suins.share_for_testing();
    clock::create_for_testing(ts.ctx()).share_for_testing();
    ts
}

/// Register a second-level `name` for a year as `CREATOR`.
fun sld(ts: &mut Scenario, name: vector<u8>): SuinsRegistration {
    ts.next_tx(CREATOR);
    let mut suins = ts.take_shared<SuiNS>();
    let clock = ts.take_shared<Clock>();
    let auth = subdomains::auth_for_testing();
    let registry: &mut Registry = suins::app_registry_mut(auth, &mut suins);
    let nft = registry.add_record(domain::new(name.to_string()), 1, &clock, ts.ctx());
    ts::return_shared(suins);
    ts::return_shared(clock);
    nft
}

/// Create an instance as `CREATOR`, lock a fresh `name` in it and share it.
fun new_instance(ts: &mut Scenario, name: vector<u8>) {
    let name = sld(ts, name);
    ts.next_tx(CREATOR);
    let mut instance = names::new(ts.ctx());
    instance.deposit_name(name, ts.ctx());
    instance.share();
}

fun register(ts: &mut Scenario, sender: address, label: vector<u8>) {
    ts.next_tx(sender);
    let instance = ts.take_shared<Instance>();
    let mut suins = ts.take_shared<SuiNS>();
    let clock = ts.take_shared<Clock>();
    instance.register(&mut suins, label.to_string(), &clock, ts.ctx());
    ts::return_shared(instance);
    ts::return_shared(suins);
    ts::return_shared(clock);
}

fun rename(ts: &mut Scenario, sender: address, label: vector<u8>, new_label: vector<u8>) {
    ts.next_tx(sender);
    let instance = ts.take_shared<Instance>();
    let mut suins = ts.take_shared<SuiNS>();
    let clock = ts.take_shared<Clock>();
    instance.rename(&mut suins, label.to_string(), new_label.to_string(), &clock, ts.ctx());
    ts::return_shared(instance);
    ts::return_shared(suins);
    ts::return_shared(clock);
}

fun remove(ts: &mut Scenario, sender: address, label: vector<u8>) {
    ts.next_tx(sender);
    let instance = ts.take_shared<Instance>();
    let mut suins = ts.take_shared<SuiNS>();
    let clock = ts.take_shared<Clock>();
    instance.remove(&mut suins, label.to_string(), &clock, ts.ctx());
    ts::return_shared(instance);
    ts::return_shared(suins);
    ts::return_shared(clock);
}

fun set_default(ts: &mut Scenario, sender: address, label: vector<u8>) {
    ts.next_tx(sender);
    let instance = ts.take_shared<Instance>();
    let mut suins = ts.take_shared<SuiNS>();
    instance.set_default(&mut suins, label.to_string(), ts.ctx());
    ts::return_shared(instance);
    ts::return_shared(suins);
}

fun resolve(ts: &mut Scenario, label: vector<u8>): Option<address> {
    ts.next_tx(CREATOR);
    let instance = ts.take_shared<Instance>();
    let suins = ts.take_shared<SuiNS>();
    let target = instance.resolve(&suins, label.to_string());
    ts::return_shared(instance);
    ts::return_shared(suins);
    target
}

/// The default name of `addr` in the SuiNS reverse registry.
fun default_name(ts: &mut Scenario, addr: address): Option<String> {
    ts.next_tx(CREATOR);
    let suins = ts.take_shared<SuiNS>();
    let registry: &Registry = suins.registry();
    let name = registry.reverse_lookup(addr).map!(|domain| domain.to_string());
    ts::return_shared(suins);
    name
}
