// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::rank_tests;

use commander::rank;
use std::{bcs::to_bytes as to_bcs, unit_test::{assert_eq, assert_ref_eq}};

#[test]
fun ranking_system() {
    let mut rank = rank::rookie();

    assert_ref_eq!(&rank, &rank::rookie());
    assert_eq!(rank.to_string(), b"Rookie".to_string());
    assert!(rank::rookie().is_rookie());
    assert!(rank.is_rookie());

    rank.rank_up();
    assert_eq!(rank, rank::squaddie());
    assert_eq!(rank.to_string(), b"Squaddie".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::squaddie().is_squaddie());
    assert!(rank.is_squaddie());

    rank.rank_up();
    assert_eq!(rank, rank::corporal());
    assert_eq!(rank.to_string(), b"Corporal".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::corporal().is_corporal());
    assert!(rank.is_corporal());

    rank.rank_up();
    assert_eq!(rank, rank::sergeant());
    assert_eq!(rank.to_string(), b"Sergeant".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::sergeant().is_sergeant());
    assert!(rank.is_sergeant());

    rank.rank_up();
    assert_eq!(rank, rank::lieutenant());
    assert_eq!(rank.to_string(), b"Lieutenant".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::lieutenant().is_lieutenant());
    assert!(rank.is_lieutenant());

    rank.rank_up();
    assert_eq!(rank, rank::captain());
    assert_eq!(rank.to_string(), b"Captain".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::captain().is_captain());
    assert!(rank.is_captain());

    rank.rank_up();
    assert_eq!(rank, rank::major());
    assert_eq!(rank.to_string(), b"Major".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::major().is_major());
    assert!(rank.is_major());

    rank.rank_up();
    assert_eq!(rank, rank::colonel());
    assert_eq!(rank.to_string(), b"Colonel".to_string());
    assert_eq!(rank, rank::from_bytes(to_bcs(&rank)));
    assert!(rank::colonel().is_colonel());
    assert!(rank.is_colonel());
}
