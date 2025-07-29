// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

//! This module contains the logic for executing game transactions. It caches
//! used object refs to avoid unnecessary queries and speed up the execution.

// use std::{collections::HashMap, str::FromStr};

// use fastcrypto::ed25519::Ed25519KeyPair;
// use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;

// use crate::config::SUI_COIN_TYPE;

use std::{collections::HashMap, ops::Deref, time::Instant};

use serde::Deserialize;
use sui_crypto::{SuiSigner, ed25519::Ed25519PrivateKey};
use sui_rpc::{
    Client,
    field::FieldMask,
    proto::sui::rpc::v2beta2::{ExecuteTransactionRequest, ListOwnedObjectsRequest},
};
use sui_sdk_types::{
    Address, Identifier, ObjectId, ObjectOut, ObjectReference, Transaction, TransactionEffects,
    TransactionEffectsV2, TypeTag, UserSignature, Version, ZkLoginAuthenticator, ZkLoginInputs,
};
use sui_transaction_builder::{Function, Serialized, TransactionBuilder, unresolved::Input};

use crate::{WithRef, config::SUI_COIN_TYPE};

pub struct TxRunner {
    keypair: Ed25519PrivateKey,
    zkp: ZkLoginInputs,
    client: Client,
    address: Address,
    max_epoch: u64,

    coins: Option<Vec<WithRef<Coin>>>,
    rgp: Option<u64>,

    /// Cache of shared object refs.
    shared_refs: HashMap<ObjectId, SharedObjectRef>,
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

impl TxRunner {
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
                    paths: vec!["transaction.effects.bcs".to_string()],
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

        self.update_coins_from_effects(&effects);

        Ok(effects)
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
