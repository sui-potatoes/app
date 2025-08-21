// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use sui_rpc::{
    Client,
    field::FieldMask,
    proto::sui::rpc::v2beta2::{GetObjectRequest, ListOwnedObjectsRequest},
};
use sui_sdk_types::{Address, ObjectId};

use crate::{
    WithRef,
    config::{COMMANDER_OBJ, PRESET_STRUCT_TAG, RECRUIT_STRUCT_TAG, REPLAY_STRUCT_TAG},
    types::{Game, Preset, Recruit, Replay},
};

pub struct GameClient {
    pub client: Client,
}

impl GameClient {
    pub fn new(client: Client) -> Self {
        Self { client }
    }

    pub async fn get_game(&mut self, game_id: ObjectId) -> Result<Game, anyhow::Error> {
        self.client
            .ledger_client()
            .get_object(GetObjectRequest {
                object_id: Some(game_id.to_string()),
                version: None,
                read_mask: Some(FieldMask {
                    paths: vec!["contents".to_string(), "digest".to_string()],
                }),
            })
            .await?
            .into_inner()
            .object
            .ok_or(anyhow::anyhow!("Game not found"))?
            .contents
            .ok_or(anyhow::anyhow!("BCS is not present in object"))?
            .deserialize::<Game>()
            .map_err(|e| anyhow::anyhow!("Failed to deserialize game: {}", e))
    }

    pub async fn list_presets(&mut self) -> Vec<WithRef<Preset>> {
        self.client
            .live_data_client()
            .list_owned_objects(ListOwnedObjectsRequest {
                owner: Some(COMMANDER_OBJ.to_string()),
                object_type: Some(PRESET_STRUCT_TAG.to_string()),
                read_mask: Some(FieldMask {
                    paths: vec!["contents".to_string(), "digest".to_string()],
                }),
                ..Default::default()
            })
            .await
            .unwrap()
            .get_ref()
            .objects
            .iter()
            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
            .collect::<Vec<WithRef<Preset>>>()
    }

    pub async fn list_recruits(&mut self, address: Address) -> Vec<WithRef<Recruit>> {
        self.client
            .live_data_client()
            .list_owned_objects(ListOwnedObjectsRequest {
                owner: Some(address.to_string()),
                object_type: Some(RECRUIT_STRUCT_TAG.to_string()),
                page_size: Some(100),
                read_mask: Some(FieldMask {
                    paths: vec!["contents".to_string(), "digest".to_string()],
                }),
                ..Default::default()
            })
            .await
            .unwrap()
            .get_ref()
            .objects
            .iter()
            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
            .collect::<Vec<WithRef<Recruit>>>()
    }

    pub async fn list_replays(&mut self, address: Address) -> Vec<WithRef<Replay>> {
        self.client
            .live_data_client()
            .list_owned_objects(ListOwnedObjectsRequest {
                owner: Some(address.to_string()),
                object_type: Some(REPLAY_STRUCT_TAG.to_string()),
                page_size: Some(100),
                read_mask: Some(FieldMask {
                    paths: vec!["contents".to_string(), "digest".to_string()],
                }),
                ..Default::default()
            })
            .await
            .unwrap()
            .get_ref()
            .objects
            .iter()
            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
            .collect::<Vec<WithRef<Replay>>>()
    }
}

impl From<Client> for GameClient {
    fn from(client: Client) -> Self {
        GameClient::new(client)
    }
}
