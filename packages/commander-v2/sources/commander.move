// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander
module commander::commander;

// use commander::{map::Map, recruit::Recruit};

/// The main object of the game, controls the game state, configuration and
/// serves as the registry for all users and their recruits.
public struct Commander has key {
    id: UID,
}

/// A single instance of the game. A `Game` object is created when a new game is
/// started, it contains the Map and the
public struct Game has key {
    id: UID,
}

