// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the ranking system for the game. Each Recruit gets assigned a rank,
/// normally starting with a `Rookie` and then getting promoted to higher ranks.
///
/// Traits:
/// - default
/// - from_bcs
/// - to_string
module commander::rank;

use std::string::String;
use sui::bcs::{Self, BCS};

/// Defines all available ranks in the game.
public enum Rank has copy, drop, store {
    Rookie,
    Squaddie,
    Corporal,
    Sergeant,
    Lieutenant,
    Captain,
    Major,
    Colonel,
}

/// Default rank for a new Recruit.
public fun default(): Rank { Rank::Rookie }

/// Create a new `Rookie` rank.
public fun rookie(): Rank { Rank::Rookie }

/// Create a new `Squaddie` rank.
public fun squaddie(): Rank { Rank::Squaddie }

/// Create a new `Corporal` rank.
public fun corporal(): Rank { Rank::Corporal }

/// Create a new `Sergeant` rank.
public fun sergeant(): Rank { Rank::Sergeant }

/// Create a new `Lieutenant` rank.
public fun lieutenant(): Rank { Rank::Lieutenant }

/// Create a new `Captain` rank.
public fun captain(): Rank { Rank::Captain }

/// Create a new `Major` rank.
public fun major(): Rank { Rank::Major }

/// Create a new `Colonel` rank.
public fun colonel(): Rank { Rank::Colonel }

/// Promotes the rank of the Recruit.
public fun rank_up(rank: &mut Rank) {
    match (rank) {
        Rank::Rookie => *rank = Rank::Squaddie,
        Rank::Squaddie => *rank = Rank::Corporal,
        Rank::Corporal => *rank = Rank::Sergeant,
        Rank::Sergeant => *rank = Rank::Lieutenant,
        Rank::Lieutenant => *rank = Rank::Captain,
        Rank::Captain => *rank = Rank::Major,
        Rank::Major => *rank = Rank::Colonel,
        Rank::Colonel => (),
    }
}

// === Checks ===

/// Check if the rank is a `Rookie`.
public fun is_rookie(rank: &Rank): bool {
    match (rank) {
        Rank::Rookie => true,
        _ => false,
    }
}

/// Check if the rank is a `Squaddie`.
public fun is_squaddie(rank: &Rank): bool {
    match (rank) {
        Rank::Squaddie => true,
        _ => false,
    }
}

/// Check if the rank is a `Corporal`.
public fun is_corporal(rank: &Rank): bool {
    match (rank) {
        Rank::Corporal => true,
        _ => false,
    }
}

/// Check if the rank is a `Sergeant`.
public fun is_sergeant(rank: &Rank): bool {
    match (rank) {
        Rank::Sergeant => true,
        _ => false,
    }
}

/// Check if the rank is a `Lieutenant`.
public fun is_lieutenant(rank: &Rank): bool {
    match (rank) {
        Rank::Lieutenant => true,
        _ => false,
    }
}

/// Check if the rank is a `Captain`.
public fun is_captain(rank: &Rank): bool {
    match (rank) {
        Rank::Captain => true,
        _ => false,
    }
}

/// Check if the rank is a `Major`.
public fun is_major(rank: &Rank): bool {
    match (rank) {
        Rank::Major => true,
        _ => false,
    }
}

/// Check if the rank is a `Colonel`.
public fun is_colonel(rank: &Rank): bool {
    match (rank) {
        Rank::Colonel => true,
        _ => false,
    }
}

// === Convenience and compatibility ===

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Rank {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): Rank {
    match (bcs.peel_u8()) {
        0 => Rank::Rookie,
        1 => Rank::Squaddie,
        2 => Rank::Corporal,
        3 => Rank::Sergeant,
        4 => Rank::Lieutenant,
        5 => Rank::Captain,
        6 => Rank::Major,
        7 => Rank::Colonel,
        _ => abort,
    }
}

/// Convert the rank to a string. Very useful for debugging and logging.
public fun to_string(rank: &Rank): String {
    match (rank) {
        Rank::Rookie => b"Rookie".to_string(),
        Rank::Squaddie => b"Squaddie".to_string(),
        Rank::Corporal => b"Corporal".to_string(),
        Rank::Sergeant => b"Sergeant".to_string(),
        Rank::Lieutenant => b"Lieutenant".to_string(),
        Rank::Captain => b"Captain".to_string(),
        Rank::Major => b"Major".to_string(),
        Rank::Colonel => b"Colonel".to_string(),
    }
}

// === Tests ===

#[test]
fun test_ranking_system() {
    use std::unit_test::{assert_eq, assert_ref_eq};
    use std::bcs::to_bytes as to_bcs;

    let mut rank = rookie();

    assert_ref_eq!(&rank, &Rank::Rookie);
    assert_eq!(rank.to_string(), b"Rookie".to_string());
    assert!(Self::rookie().is_rookie());
    assert!(rank.is_rookie());

    rank.rank_up();
    assert_eq!(rank, Rank::Squaddie);
    assert_eq!(rank.to_string(), b"Squaddie".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::squaddie().is_squaddie());
    assert!(rank.is_squaddie());

    rank.rank_up();
    assert_eq!(rank, Rank::Corporal);
    assert_eq!(rank.to_string(), b"Corporal".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::corporal().is_corporal());
    assert!(rank.is_corporal());

    rank.rank_up();
    assert_eq!(rank, Rank::Sergeant);
    assert_eq!(rank.to_string(), b"Sergeant".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::sergeant().is_sergeant());
    assert!(rank.is_sergeant());

    rank.rank_up();
    assert_eq!(rank, Rank::Lieutenant);
    assert_eq!(rank.to_string(), b"Lieutenant".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::lieutenant().is_lieutenant());
    assert!(rank.is_lieutenant());

    rank.rank_up();
    assert_eq!(rank, Rank::Captain);
    assert_eq!(rank.to_string(), b"Captain".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::captain().is_captain());
    assert!(rank.is_captain());

    rank.rank_up();
    assert_eq!(rank, Rank::Major);
    assert_eq!(rank.to_string(), b"Major".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::major().is_major());
    assert!(rank.is_major());

    rank.rank_up();
    assert_eq!(rank, Rank::Colonel);
    assert_eq!(rank.to_string(), b"Colonel".to_string());
    assert_eq!(rank, from_bytes(to_bcs(&rank)));
    assert!(Self::colonel().is_colonel());
    assert!(rank.is_colonel());
}
