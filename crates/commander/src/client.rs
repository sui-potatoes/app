#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::str::FromStr;

use move_core_types::language_storage::StructTag;
use serde::{Deserialize, Serialize};
use sui_json_rpc_types::{ObjectsPage, SuiObjectResponse, SuiRawData};
use sui_sdk::{
    SuiClient, SuiClientBuilder,
    rpc_types::{SuiObjectDataFilter, SuiObjectDataOptions, SuiObjectResponseQuery},
};
use sui_types::base_types::{ObjectID, ObjectRef, SuiAddress};

use crate::{
    config::{
        ARMOR_STRUCT_TAG, COMMANDER_OBJ, COMMANDER_PKG, PRESET_STRUCT_TAG, RECRUIT_STRUCT_TAG,
        REPLAY_STRUCT_TAG, WEAPON_STRUCT_TAG,
    },
    move_types::{Armor, Preset, Recruit, Replay, Weapon},
};

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
    pub async fn get_presets(&self) -> Result<Vec<WithRef<Preset>>, anyhow::Error> {
        let objects = self
            .owned_objects(QueryFilter::Preset, SuiAddress::from_str(COMMANDER_OBJ)?)
            .await?;

        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<WithRef<Preset>>>())
    }

    /// Get all owned `Recruit` objects.
    pub async fn get_recruits(
        &self,
        address: SuiAddress,
    ) -> Result<Vec<WithRef<Recruit>>, anyhow::Error> {
        let objects = self.owned_objects(QueryFilter::Recruit, address).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<WithRef<Recruit>>>())
    }

    /// Get all owned `Replay` objects.
    pub async fn get_replays(
        &self,
        address: SuiAddress,
    ) -> Result<Vec<WithRef<Replay>>, anyhow::Error> {
        let objects = self.owned_objects(QueryFilter::Replay, address).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<WithRef<Replay>>>())
    }

    /// Get all owned `Weapon` objects.
    pub async fn get_weapons(
        &self,
        address: SuiAddress,
    ) -> Result<Vec<WithRef<Weapon>>, anyhow::Error> {
        let objects = self.owned_objects(QueryFilter::Weapon, address).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<WithRef<Weapon>>>())
    }

    /// Get all owned `Armor` objects.
    pub async fn get_armors(
        &self,
        address: SuiAddress,
    ) -> Result<Vec<WithRef<Armor>>, anyhow::Error> {
        let objects = self.owned_objects(QueryFilter::Armor, address).await?;
        Ok(objects
            .data
            .iter()
            .map(parse_bytes)
            .collect::<Vec<WithRef<Armor>>>())
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

fn parse_bytes<'a, T>(obj_data: &'a SuiObjectResponse) -> WithRef<T>
where
    T: Deserialize<'a>,
{
    let data = obj_data.data.as_ref().unwrap();
    if let Some(SuiRawData::MoveObject(object)) = &data.bcs {
        WithRef {
            object_ref: data.object_ref(),
            data: bcs::from_bytes(object.bcs_bytes.as_ref()).unwrap(),
        }
    } else {
        panic!("Unexpected failure in `parse_bytes`");
    }
}

// === Ref Wrapper ===

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WithRef<T> {
    pub object_ref: ObjectRef,
    pub data: T,
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
