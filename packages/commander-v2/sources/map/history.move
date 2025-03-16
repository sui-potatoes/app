// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Stores history of a single Game relaxing the need for event queries and
/// providing a single point of truth.
///
/// It replaces events API, providing all key game events in an easy to read
/// minimalistic representation.
module commander::history;

use sui::event;

/// Stores history of actions.
public struct History(vector<Record>) has drop, store;

/// Event that marks an update in `History` for tx sender.
public struct HistoryUpdated(vector<Record>) has copy, drop;

/// A single record in the history.
public enum Record has copy, drop, store {
    /// Block header for attack action.
    Reload(vector<u16>),
    /// Next turn action.
    NextTurn,
    /// Block header for move action.
    Move(vector<vector<u16>>),
    /// Block header for attack action.
    Attack { origin: vector<u16>, target: vector<u16> },
    /// Recruit is placed on the map.
    RecruitPlaced(u16, u16),
    // === Sub events ===
    Damage(u8),
    Miss,
    Explosion,
    CriticalHit(u8),
    Grenade(u16, u16, u16),
    UnitKIA(ID),
    Dodged,
}

// === History API ===

/// Create empty history.
public fun empty(): History { History(vector[]) }

/// Add a single record.
/// WARNING: if you're adding multiple record in the same transaction,
///     use `append` to emit a single event!
public fun add(h: &mut History, record: Record) {
    let History(history) = h;
    event::emit(HistoryUpdated(vector[record]));
    history.push_back(record);
}

/// Add a new `Record` to the `History` log.
public fun append(h: &mut History, records: vector<Record>) {
    let History(history) = h;
    event::emit(HistoryUpdated(records));
    history.append(records);
}

/// Get the length of the `History` log.
public fun length(h: &History): u64 { h.0.length() }

// === Record Records ===

/// Create new `Record::RecruitPlaced`
public fun new_recruit_placed(x: u16, y: u16): Record { Record::RecruitPlaced(x, y) }

/// Create new `Record::Attack` history record.
public fun new_attack(origin: vector<u16>, target: vector<u16>): Record {
    Record::Attack { origin, target }
}

/// Create new `Record::Dodged` history record.
public fun new_dodged(): Record { Record::Dodged }

/// Create new `Record::Missed` history record.
public fun new_missed(): Record { Record::Miss }

/// Create new `Record::CriticalHit` history record.
public fun new_crit(dmg: u8): Record { Record::CriticalHit(dmg) }

/// Create new `Record::Damage` history record.
public fun new_damage(_x: u16, _y: u16, dmg: u8): Record { Record::Damage(dmg) }

/// Create new `Record::UnitKIA` history record.
public fun new_kia(id: ID): Record { Record::UnitKIA(id) }

/// Create new `Record::Grenade` history record.
public fun new_grenade(r: u16, x: u16, y: u16): Record { Record::Grenade(r, x, y) }

/// Create new `Record::Move` history record.
public fun new_move(steps: vector<vector<u16>>): Record { Record::Move(steps) }

/// Create new `Record::NextTurn` history record.
public fun new_next_turn(): Record { Record::NextTurn }

/// Create new `Record::Reload` history record.
public fun new_reload(x: u16, y: u16): Record { Record::Reload(vector[x, y]) }

// === Reads ===

public fun list_kia(r: &vector<Record>): vector<ID> {
    let mut kias = vector[];
    r.do_ref!(
        |e| match (e) {
            Record::UnitKIA(id) => kias.push_back(*id),
            _ => (),
        },
    );
    kias
}
