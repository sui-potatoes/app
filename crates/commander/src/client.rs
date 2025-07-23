#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::move_types::{Armor, Preset, Recruit, Replay, Weapon};
use move_core_types::language_storage::StructTag;
use serde::Deserialize;
use std::str::FromStr;
use sui_json_rpc_types::{ObjectsPage, SuiObjectResponse, SuiRawData};
use sui_sdk::rpc_types::SuiObjectDataFilter;
use sui_sdk::{
    SuiClient, SuiClientBuilder,
    rpc_types::{SuiObjectDataOptions, SuiObjectResponseQuery},
};
use sui_types::base_types::{ObjectID, SuiAddress};

pub const COMMANDER_OBJ: &'static str =
    "0x133420084e1dc366bb9a39d77c4c6a64e9caa553b0a16f704b3f9e7058f98cb7";
pub const PLAYER_ADDRESS: &'static str =
    "0xddb2d7471a381e5080d7c48d5da5baacdd07ddfada4d4cfeec929e27bff44aa9";
pub const COMMANDER_PKG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7";
const REPLAY_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::replay::Replay";
const RECRUIT_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::recruit::Recruit";
const WEAPON_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::weapon::Weapon";
const ARMOR_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::armor::Armor";
const PRESET_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::commander::Preset";

// === Commander Client ===

pub struct CommanderClient(SuiClient);

impl CommanderClient {
    pub async fn new() -> Result<Self, anyhow::Error> {
        Ok(Self(SuiClientBuilder::default().build_testnet().await?))
    }

    pub fn as_inner(&self) -> &SuiClient {
        &self.0
    }

    /// Get all `Preset`s stored in the registry.
    pub async fn get_presets(&self) -> Result<Vec<Preset>, anyhow::Error> {
        let registry = SuiAddress::from_str(COMMANDER_OBJ).unwrap();
        let objects = self.owned_objects(QueryFilter::Preset, registry).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<Preset>>())
    }

    /// Get all owned `Recruit` objects.
    pub async fn get_recruits(&self) -> Result<Vec<Recruit>, anyhow::Error> {
        let player = SuiAddress::from_str(PLAYER_ADDRESS).unwrap();
        let objects = self.owned_objects(QueryFilter::Recruit, player).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<Recruit>>())
    }

    /// Get all owned `Replay` objects.
    pub async fn get_replays(&self) -> Result<Vec<Replay>, anyhow::Error> {
        let player = SuiAddress::from_str(PLAYER_ADDRESS).unwrap();
        let objects = self.owned_objects(QueryFilter::Replay, player).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<Replay>>())
    }

    /// Get all owned `Weapon` objects.
    pub async fn get_weapons(&self) -> Result<Vec<Weapon>, anyhow::Error> {
        let player = SuiAddress::from_str(PLAYER_ADDRESS).unwrap();
        let objects = self.owned_objects(QueryFilter::Weapon, player).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<Weapon>>())
    }

    /// Get all owned `Armor` objects.
    pub async fn get_armors(&self) -> Result<Vec<Armor>, anyhow::Error> {
        let player = SuiAddress::from_str(PLAYER_ADDRESS).unwrap();
        let objects = self.owned_objects(QueryFilter::Armor, player).await?;
        Ok(objects.data.iter().map(parse_bytes).collect::<Vec<Armor>>())
    }

    /// Get all owned objects with the given `QueryFilter`.
    async fn owned_objects(
        &self,
        filter: QueryFilter,
        owner: SuiAddress,
    ) -> Result<ObjectsPage, anyhow::Error> {
        Ok(self
            .0
            .read_api()
            .get_owned_objects(
                owner,
                Some(SuiObjectResponseQuery {
                    filter: Some(filter.into()),
                    options: Some(SuiObjectDataOptions::new().with_bcs()),
                }),
                None,
                Some(50),
            )
            .await?)
    }
}

fn parse_bytes<'a, T>(obj_data: &'a SuiObjectResponse) -> T
where
    T: Deserialize<'a>,
{
    let data = obj_data.data.as_ref().unwrap();
    if let Some(SuiRawData::MoveObject(object)) = &data.bcs {
        bcs::from_bytes(object.bcs_bytes.as_ref()).unwrap()
    } else {
        panic!("Unexpected failure in `parse_bytes`");
    }
}

// === Query Filter ===
pub enum QueryFilter {
    All,
    Replay,
    Recruit,
    Weapon,
    Armor,
    Preset,
}

impl Into<SuiObjectDataFilter> for QueryFilter {
    fn into(self) -> SuiObjectDataFilter {
        match self {
            QueryFilter::All => {
                SuiObjectDataFilter::Package(ObjectID::from_str(COMMANDER_PKG).unwrap())
            }
            QueryFilter::Replay => {
                SuiObjectDataFilter::StructType(StructTag::from_str(REPLAY_STRUCT_TAG).unwrap())
            }
            QueryFilter::Recruit => {
                SuiObjectDataFilter::StructType(StructTag::from_str(RECRUIT_STRUCT_TAG).unwrap())
            }
            QueryFilter::Weapon => {
                SuiObjectDataFilter::StructType(StructTag::from_str(WEAPON_STRUCT_TAG).unwrap())
            }
            QueryFilter::Armor => {
                SuiObjectDataFilter::StructType(StructTag::from_str(ARMOR_STRUCT_TAG).unwrap())
            }
            QueryFilter::Preset => {
                SuiObjectDataFilter::StructType(StructTag::from_str(PRESET_STRUCT_TAG).unwrap())
            }
        }
    }
}
