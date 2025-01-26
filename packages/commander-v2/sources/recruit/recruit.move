// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the Recruit - an ownable unit in the game. Recruit contains all the
/// information about the unit, its rank, modifications, gear, stats and more.
///
/// Traits:
/// - default
module commander::recruit;

use commander::{armor::Armor, rank::{Self, Rank}, stats::{Self, Stats}, weapon::Weapon};
use std::string::String;

/// Attempt to equip a `Weapon` while a Recruit already it.
const EAlreadyHasWeapon: u64 = 1;
/// Trying to remove a `Weapon` that does not exist.
const ENoWeapon: u64 = 2;
/// Attempt to equip an `Armor` while a Recruit already has one.
const EAlreadyHasArmor: u64 = 3;
/// Trying to remove an `Armor` that does not exist.
const ENoArmor: u64 = 4;

// Convenience alias which allows simpler conversion from Recruit to Unit.
public use fun commander::unit::from_recruit as Recruit.to_unit;

/// Recruit metadata, contains information about the Recruit that is not
/// directly related to the game mechanics.
public struct Metadata has drop, store {
    name: String,
    backstory: String,
}

/// Defines the Recruit - a unit in the game which users hire, train and send on
/// missions. As the Recruit gains experience, they can be promoted to higher
/// ranks and get access to better equipment and abilities.
public struct Recruit has key, store {
    id: UID,
    /// `Metadata` of the Recruit.
    metadata: Metadata,
    /// `Rank` of the Unit.
    rank: Rank,
    /// `Stats` of the Unit.
    stats: Stats,
    /// Weapon of the Unit. When not set, the Recruit uses the default weapon.
    weapon: Option<Weapon>,
    /// Armor of the Unit. When not set, the Recruit uses the default armor.
    armor: Option<Armor>,
    /// The address that hired the Recruit.
    leader: address,
}

/// DogTag is the only thing left after a Recruit dies in battle.
/// It contains the name and rank of the fallen soldier.
public struct DogTag has key, store {
    id: UID,
    /// The rank of the fallen soldier.
    rank: Rank,
    /// Metadata (including backstory) of the fallen recruit.
    metadata: Metadata,
}

/// Add an armor to the Recruit.
public fun add_armor(r: &mut Recruit, armor: Armor) {
    assert!(r.armor.is_none(), EAlreadyHasArmor);
    r.armor.fill(armor);
}

/// Remove the armor from the Recruit.
public fun remove_armor(r: &mut Recruit): Armor {
    assert!(r.armor.is_some(), ENoArmor);
    r.armor.extract()
}

/// Add a weapon to the Recruit.
/// Aborts if the Recruit already has a weapon.
public fun add_weapon(r: &mut Recruit, weapon: Weapon) {
    assert!(r.weapon.is_none(), EAlreadyHasWeapon);
    r.weapon.fill(weapon);
}

/// Remove the weapon from the Recruit.
/// Aborts if the Recruit does not have a weapon.
public fun remove_weapon(r: &mut Recruit): Weapon {
    assert!(r.weapon.is_some(), ENoWeapon);
    r.weapon.extract()
}

/// Get the armor of the Recruit.
public fun armor(r: &Recruit): &Option<Armor> { &r.armor }

/// Get the weapon of the Recruit.
public fun weapon(r: &Recruit): &Option<Weapon> { &r.weapon }

/// Get the stats of the Recruit.
public fun stats(r: &Recruit): &Stats { &r.stats }

/// Get the rank of the Recruit.
public fun rank(r: &Recruit): &Rank { &r.rank }

/// Get the address of the Recruit's leader.
public fun leader(r: &Recruit): address { r.leader }

/// Get the metadata of the Recruit.
public fun metadata(r: &Recruit): &Metadata { &r.metadata }

/// Promotes the rank of the Recruit.
public fun rank_up(recruit: &mut Recruit) {
    recruit.rank.rank_up()
}

/// Create a new `Recruit` with default values.
public fun default(ctx: &mut TxContext): Recruit {
    Recruit {
        id: object::new(ctx),
        metadata: Metadata {
            name: b"John Doe".to_string(),
            backstory: b"A rookie soldier, ready to prove themselves.".to_string(),
        },
        rank: rank::default(),
        stats: stats::default(),
        weapon: option::none(),
        armor: option::none(),
        leader: ctx.sender(),
    }
}

/// Create a new `Recruit` with the given name and backstory.
/// TODOs:
/// - [ ] restrict who can submit new names and backstory. Right now anyone can
///       create a Recruit with any name and backstory.
public fun new(name: String, backstory: String, ctx: &mut TxContext): Recruit {
    Recruit {
        id: object::new(ctx),
        metadata: Metadata { name, backstory },
        rank: rank::rookie(),
        stats: stats::default(),
        weapon: option::none(),
        armor: option::none(),
        leader: ctx.sender(),
    }
}

/// Dismiss the Recruit, remove them forever from the game.
public fun dismiss(recruit: Recruit): (Option<Weapon>, Option<Armor>) {
    let Recruit { id, weapon, armor, .. } = recruit;
    id.delete();
    (weapon, armor)
}

/// Throw away the DogTag, destroy it and bury the memory.
public fun throw_away(dog_tag: DogTag) {
    let DogTag { id, .. } = dog_tag;
    id.delete();
}

/// Kills the Recruit and returns the DogTag.
public(package) fun kill(recruit: Recruit, ctx: &mut TxContext): DogTag {
    let Recruit { id, rank, weapon, metadata, armor, .. } = recruit;
    id.delete();

    // TODO: figure a way to leave the weapon
    weapon.destroy!(|w| w.destroy());
    armor.destroy!(|a| a.destroy());

    DogTag { id: object::new(ctx), rank, metadata }
}

#[test]
fun test_rank_up_and_accessors() {
    use std::unit_test::{assert_eq, assert_ref_eq};

    let ctx = &mut tx_context::dummy();
    let mut recruit = default(ctx);

    assert_ref_eq!(recruit.rank(), &rank::rookie());

    // tests reads on values to increase coverage
    assert_eq!(recruit.leader(), ctx.sender());
    assert_eq!(recruit.stats().aim(), 65); // default value

    recruit.rank_up();

    assert!(&recruit.rank != &rank::rookie());

    let dog_tag = recruit.kill(ctx);

    assert!(dog_tag.rank.is_squaddie());

    dog_tag.throw_away();
}
