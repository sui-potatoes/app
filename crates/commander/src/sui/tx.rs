// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

//! This module contains the logic for executing game transactions. It caches
//! used object refs to avoid unnecessary queries and speed up the execution.

use std::{collections::HashMap, ops::Deref, str::FromStr, time::Instant};

use serde::Deserialize;
use sui_crypto::{SuiSigner, ed25519::Ed25519PrivateKey};
use sui_rpc::{
    Client,
    field::FieldMask,
    proto::sui::rpc::v2beta2::{
        ExecuteTransactionRequest, GetObjectRequest, ListOwnedObjectsRequest,
    },
};
use sui_sdk_types::{
    Address, IdOperation, Identifier, ObjectDigest, ObjectId, ObjectOut, ObjectReference, Owner,
    Transaction, TransactionEffects, TransactionEffectsV2, TypeTag, UserSignature, Version,
    ZkLoginAuthenticator, ZkLoginInputs,
};
use sui_transaction_builder::{Function, Serialized, TransactionBuilder, unresolved::Input};

use crate::{
    WithRef,
    config::{COMMANDER_OBJ, COMMANDER_PKG, SUI_COIN_TYPE},
    types::Preset,
};

pub struct TxExecutor {
    keypair: Ed25519PrivateKey,
    zkp: ZkLoginInputs,
    client: Client,
    address: Address,
    max_epoch: u64,

    coins: Option<Vec<WithRef<Coin>>>,
    rgp: Option<u64>,

    /// Cache of shared object refs.
    shared_refs: HashMap<ObjectId, SharedObjectRef>,
    /// Cache of owned object refs (also includes coins, but they're tracked in
    /// the `coins` field).
    owned_refs: HashMap<ObjectId, ObjectReference>,
}

#[derive(Debug, Clone)]
pub struct SharedObjectRef {
    id: ObjectId,
    initial_shared_version: Version,
    mutable: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Coin {
    id: ObjectId,
    balance: u64,
}

impl From<WithRef<Coin>> for Input {
    fn from(coin: WithRef<Coin>) -> Self {
        Input::owned(
            *coin.object_ref.object_id(),
            coin.object_ref.version(),
            *coin.object_ref.digest(),
        )
    }
}

impl TxExecutor {
    pub fn new(
        secret_key: Ed25519PrivateKey,
        zkp: ZkLoginInputs,
        max_epoch: u64,
        client: Client,
    ) -> Self {
        let address: Address = zkp
            .public_identifier()
            .unwrap()
            .derive_address()
            .next()
            .unwrap();

        Self {
            address,
            keypair: secret_key,
            zkp,
            client,
            max_epoch,
            coins: None,
            rgp: None,
            shared_refs: HashMap::new(),
            owned_refs: HashMap::new(),
        }
    }

    pub async fn test_tx(&mut self) -> Result<TransactionEffectsV2, anyhow::Error> {
        let gas_coins = self.get_gas_coins().await?;
        let mut ptb = TransactionBuilder::new();
        let input = ptb.input(Serialized(&100u8));

        ptb.move_call(
            Function::new(
                Address::from_hex("0x1")?,
                Identifier::new("option")?,
                Identifier::new("some")?,
                vec![TypeTag::U8],
            ),
            vec![input],
        );

        ptb.set_sender(self.address);
        ptb.add_gas_objects(gas_coins.iter().map(|coin| Input::from(coin.clone())));
        ptb.set_gas_budget(100000000);
        ptb.set_gas_price(1000);
        ptb.set_expiration(self.max_epoch);

        let tx: Transaction = ptb.finish()?;
        Ok(self.execute_tx(tx).await?)
    }

    pub async fn start_game(&mut self, preset: WithRef<Preset>) -> Result<ObjectId, anyhow::Error> {
        let rgp = self.rgp.unwrap_or(1000);
        let gas_coins = self.get_gas_coins().await?;
        let preset_ref = self
            .get_owned_object_ref(*preset.object_ref.object_id())
            .await?;

        let commander = self
            .get_shared_object_ref(ObjectId::from_str(COMMANDER_OBJ)?, true)
            .await?;

        let recruits_num = preset.data.positions.len();
        let mut ptb = TransactionBuilder::new();
        let commander = ptb.input(commander);
        let preset = ptb.input(Input::receiving(
            *preset_ref.object_id(),
            preset_ref.version(),
            *preset_ref.digest(),
        ));

        let game = ptb.move_call(
            Function::new(
                Address::from_hex(COMMANDER_PKG)?,
                Identifier::new("commander")?,
                Identifier::new("new_game")?,
                vec![],
            ),
            vec![commander, preset],
        );

        for _ in 0..recruits_num {
            let name = ptb.input(Serialized(&"Recruit".to_string()));
            let backstory = ptb.input(Serialized(&"Backstory".to_string()));

            let recruit = ptb.move_call(
                Function::new(
                    Address::from_hex(COMMANDER_PKG)?,
                    Identifier::new("recruit")?,
                    Identifier::new("new")?,
                    vec![],
                ),
                vec![name, backstory],
            );

            ptb.move_call(
                Function::new(
                    Address::from_hex(COMMANDER_PKG)?,
                    Identifier::new("commander")?,
                    Identifier::new("place_recruit")?,
                    vec![],
                ),
                vec![game, recruit],
            );
        }

        ptb.move_call(
            Function::new(
                Address::from_hex(COMMANDER_PKG)?,
                Identifier::new("commander")?,
                Identifier::new("share")?,
                vec![],
            ),
            vec![game],
        );

        ptb.set_gas_price(rgp);
        ptb.set_gas_budget(100_000_000);
        ptb.set_sender(self.address);
        ptb.add_gas_objects(gas_coins.iter().map(|coin| Input::from(coin.clone())));
        ptb.set_expiration(self.max_epoch);

        let effects = self.execute_tx(ptb.finish()?).await?;

        // dbg!(&effects.changed_objects);
        // dbg!(&effects.status);

        // The only new shared object in this transaction is the game object.
        // Hence, the search for it is straightforward.
        let game_id = effects
            .changed_objects
            .iter()
            .find(|obj| {
                matches!(
                    obj.output_state,
                    ObjectOut::ObjectWrite {
                        digest: _,
                        owner: Owner::Shared(_)
                    }
                ) && matches!(obj.id_operation, IdOperation::Created)
            })
            .ok_or(anyhow::anyhow!("Game not found in effects"))?
            .object_id;

        Ok(game_id)
    }

    async fn get_gas_coins(&mut self) -> Result<Vec<WithRef<Coin>>, anyhow::Error> {
        match &self.coins {
            Some(coins) => Ok(coins.clone()),
            None => {
                let coins = self
                    .client
                    .live_data_client()
                    .list_owned_objects(ListOwnedObjectsRequest {
                        owner: Some(self.address.to_string()),
                        object_type: Some(SUI_COIN_TYPE.to_string()),
                        read_mask: Some(FieldMask {
                            paths: vec!["contents".to_string(), "digest".to_string()],
                        }),
                        ..Default::default()
                    })
                    .await?
                    .get_ref()
                    .objects
                    .iter()
                    .map(|obj| WithRef::from_rpc_object(obj).unwrap())
                    .collect::<Vec<WithRef<Coin>>>();

                self.coins = Some(coins.clone());
                Ok(coins)
            }
        }
    }

    /// Try to fetch SharedObjectRef from cache, if not found, fetch from the network.
    async fn get_shared_object_ref(
        &mut self,
        id: ObjectId,
        mutable: bool,
    ) -> Result<SharedObjectRef, anyhow::Error> {
        match self.shared_refs.get(&id) {
            Some(shared_ref) => {
                let mut shared_ref = shared_ref.clone();
                shared_ref.mutable = mutable;
                Ok(shared_ref)
            }
            None => {
                let shared_ref = self
                    .client
                    .ledger_client()
                    .get_object(GetObjectRequest {
                        object_id: Some(id.to_string()),
                        version: None,
                        read_mask: Some(FieldMask {
                            paths: vec!["owner".to_string()],
                        }),
                    })
                    .await?;

                let shared_ref = SharedObjectRef {
                    id,
                    initial_shared_version: shared_ref
                        .into_inner()
                        .object
                        .unwrap()
                        .owner
                        .unwrap()
                        .version
                        .unwrap(),
                    mutable: true,
                };

                self.shared_refs.insert(id, shared_ref.clone());
                Ok(shared_ref)
            }
        }
    }

    async fn get_owned_object_ref(
        &mut self,
        id: ObjectId,
    ) -> Result<ObjectReference, anyhow::Error> {
        match self.owned_refs.get(&id) {
            Some(owned_ref) => Ok(owned_ref.clone()),
            None => {
                let owned_ref = self
                    .client
                    .ledger_client()
                    .get_object(GetObjectRequest {
                        object_id: Some(id.to_string()),
                        version: None,
                        read_mask: None,
                    })
                    .await?;
                let object = owned_ref.into_inner().object.unwrap();
                let owned_ref = ObjectReference::new(
                    id,
                    object.version.unwrap(),
                    ObjectDigest::from_str(object.digest.unwrap().as_str()).unwrap(),
                );
                self.owned_refs.insert(id, owned_ref.clone());
                Ok(owned_ref)
            }
        }
    }

    async fn clock(&mut self) -> Result<SharedObjectRef, anyhow::Error> {
        Ok(self
            .get_shared_object_ref(ObjectId::from_str("0x6")?, false)
            .await?)
    }

    async fn execute_tx(&mut self, tx: Transaction) -> Result<TransactionEffectsV2, anyhow::Error> {
        let simple_signature = match self.keypair.sign_transaction(&tx) {
            Ok(UserSignature::Simple(simple)) => simple,
            Ok(_) => return Err(anyhow::anyhow!("Failed to sign transaction")),
            Err(_) => return Err(anyhow::anyhow!("Failed to sign transaction")),
        };

        let zklogin_signature = UserSignature::ZkLogin(Box::new(ZkLoginAuthenticator {
            inputs: self.zkp.clone(),
            signature: simple_signature,
            max_epoch: self.max_epoch,
        }));

        let timer = Instant::now();
        let tx_result = self
            .client
            .execution_client()
            .execute_transaction(ExecuteTransactionRequest {
                transaction: Some(tx.into()),
                signatures: vec![zklogin_signature.into()],
                read_mask: Some(FieldMask {
                    paths: vec![
                        "transaction.effects.bcs".to_string(),
                        "finality".to_string(),
                    ],
                }),
                ..Default::default()
            })
            .await?;

        println!("Execution time: {:?}", timer.elapsed());

        let effects: TransactionEffects = match tx_result.get_ref().transaction.as_ref() {
            Some(tx) => {
                bcs::from_bytes(tx.effects.as_ref().unwrap().bcs.as_ref().unwrap().value()).unwrap()
            }
            None => {
                return Err(anyhow::anyhow!(
                    "Incorrect path specified, transaction missing"
                ));
            }
        };

        let effects = match effects {
            TransactionEffects::V2(effects) => effects.deref().clone(),
            _ => {
                return Err(anyhow::anyhow!(
                    "Unsupported transaction effects version, expected V2"
                ));
            }
        };

        self.process_effects(&effects);

        Ok(effects)
    }

    fn process_effects(&mut self, effects: &TransactionEffectsV2) {
        self.update_refs_from_effects(effects);
        self.update_coins_from_effects(effects);
    }

    fn update_refs_from_effects(&mut self, effects: &TransactionEffectsV2) {
        let version = effects.lamport_version;

        for obj in &effects.changed_objects {
            match obj.id_operation {
                IdOperation::Created => {
                    if let ObjectOut::ObjectWrite { digest, owner } = &obj.output_state {
                        match *owner {
                            Owner::Shared(initial_shared_version) => {
                                self.shared_refs.insert(
                                    obj.object_id,
                                    SharedObjectRef {
                                        id: obj.object_id,
                                        initial_shared_version,
                                        mutable: true,
                                    },
                                );
                            }
                            Owner::Address(_) => {
                                self.owned_refs.insert(
                                    obj.object_id,
                                    ObjectReference::new(obj.object_id, version, *digest),
                                );
                            }
                            _ => {}
                        }
                    }
                }
                IdOperation::None => {
                    if let ObjectOut::ObjectWrite {
                        digest,
                        owner: Owner::Address(_),
                    } = &obj.output_state
                    {
                        self.owned_refs.insert(
                            obj.object_id,
                            ObjectReference::new(obj.object_id, version, *digest),
                        );
                    }
                }
                IdOperation::Deleted => {
                    self.shared_refs.remove(&obj.object_id);
                    self.owned_refs.remove(&obj.object_id);
                }
            }
        }
    }

    fn update_coins_from_effects(&mut self, effects: &TransactionEffectsV2) {
        if let Some(coins) = &mut self.coins {
            for obj in &effects.changed_objects {
                coins
                    .iter_mut()
                    .find(|coin| coin.object_ref.object_id() == &obj.object_id)
                    .map(|coin| {
                        let digest = match &obj.output_state {
                            ObjectOut::NotExist => return,
                            ObjectOut::ObjectWrite { digest, .. } => *digest,
                            ObjectOut::PackageWrite { digest, .. } => *digest,
                        };

                        coin.object_ref =
                            ObjectReference::new(obj.object_id, effects.lamport_version, digest)
                    });
            }
        }
    }
}

impl Into<Input> for SharedObjectRef {
    fn into(self) -> Input {
        Input::shared(self.id, self.initial_shared_version, self.mutable)
    }
}

impl Into<Input> for WithRef<Preset> {
    fn into(self) -> Input {
        Input::receiving(
            *self.object_ref.object_id(),
            self.object_ref.version(),
            *self.object_ref.digest(),
        )
    }
}
