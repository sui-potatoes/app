// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use futures::StreamExt;
use sui_rpc::{
    Client,
    field::FieldMask,
    proto::sui::rpc::v2::{GetEpochRequest, GetObjectRequest, ListOwnedObjectsRequest},
};
use sui_sdk_types::Address;

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

    pub async fn get_epoch(&mut self) -> Result<u64, anyhow::Error> {
        let epoch = self
            .client
            .ledger_client()
            .get_epoch(GetEpochRequest::default())
            .await?
            .into_inner()
            .epoch
            .ok_or(anyhow::anyhow!("Epoch not found"))?;

        Ok(epoch.epoch())
    }

    pub async fn get_game(&mut self, game_id: Address) -> Result<Game, anyhow::Error> {
        self.client
            .ledger_client()
            .get_object(
                GetObjectRequest::default()
                    .with_object_id(game_id.to_string())
                    .with_read_mask(FieldMask {
                        paths: vec!["contents".to_string(), "digest".to_string()],
                    }),
            )
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
            .list_owned_objects(
                ListOwnedObjectsRequest::default()
                    .with_owner(COMMANDER_OBJ.to_string())
                    .with_object_type(PRESET_STRUCT_TAG.to_string())
                    .with_read_mask(FieldMask {
                        paths: vec!["contents".to_string(), "digest".to_string()],
                    }),
            )
            .map(|obj| WithRef::from_rpc_object(&obj.unwrap()).unwrap())
            .collect::<Vec<WithRef<Preset>>>()
            .await
    }

    pub async fn list_recruits(&mut self, address: Address) -> Vec<WithRef<Recruit>> {
        self.client
            .list_owned_objects(
                ListOwnedObjectsRequest::default()
                    .with_owner(address.to_string())
                    .with_object_type(RECRUIT_STRUCT_TAG.to_string())
                    .with_page_size(100)
                    .with_read_mask(FieldMask {
                        paths: vec!["contents".to_string(), "digest".to_string()],
                    }),
            )
            .map(|obj| WithRef::from_rpc_object(&obj.unwrap()).unwrap())
            .collect::<Vec<WithRef<Recruit>>>()
            .await
    }

    pub async fn list_replays(&mut self, address: Address) -> Vec<WithRef<Replay>> {
        self.client
            .list_owned_objects(
                ListOwnedObjectsRequest::default()
                    .with_owner(address.to_string())
                    .with_object_type(REPLAY_STRUCT_TAG.to_string())
                    .with_page_size(100)
                    .with_read_mask(FieldMask {
                        paths: vec!["contents".to_string(), "digest".to_string()],
                    }),
            )
            .map(|obj| WithRef::from_rpc_object(&obj.unwrap()).unwrap())
            .collect::<Vec<WithRef<Replay>>>()
            .await
    }
}

impl From<Client> for GameClient {
    fn from(client: Client) -> Self {
        GameClient::new(client)
    }
}
