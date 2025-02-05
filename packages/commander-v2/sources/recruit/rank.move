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

const EMaxRank: u64 = 1;

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
    *rank = match (rank) {
        Rank::Rookie => Rank::Squaddie,
        Rank::Squaddie => Rank::Corporal,
        Rank::Corporal => Rank::Sergeant,
        Rank::Sergeant => Rank::Lieutenant,
        Rank::Lieutenant => Rank::Captain,
        Rank::Captain => Rank::Major,
        Rank::Major => Rank::Colonel,
        Rank::Colonel => abort EMaxRank,
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
        Rank::Rookie => b"Rookie",
        Rank::Squaddie => b"Squaddie",
        Rank::Corporal => b"Corporal",
        Rank::Sergeant => b"Sergeant",
        Rank::Lieutenant => b"Lieutenant",
        Rank::Captain => b"Captain",
        Rank::Major => b"Major",
        Rank::Colonel => b"Colonel",
    }.to_string()
}
