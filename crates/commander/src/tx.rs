// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

//! This module contains the logic for executing game transactions. It caches
//! used object refs to avoid unnecessary queries and speed up the execution.

use std::{collections::HashMap, str::FromStr};

use fastcrypto::ed25519::Ed25519KeyPair;
use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;
use move_core_types::language_storage::StructTag;
use shared_crypto::intent::{Intent, IntentMessage};
use sui_json_rpc_types::{
    Coin, ObjectChange, SuiObjectDataOptions, SuiObjectResponse, SuiTransactionBlockEffectsAPI,
    SuiTransactionBlockResponse, SuiTransactionBlockResponseOptions,
};

use sui_sdk::SuiClient;
use sui_types::{
    base_types::{ObjectID, ObjectRef, SequenceNumber, SuiAddress},
    crypto::Signature,
    programmable_transaction_builder::ProgrammableTransactionBuilder,
    quorum_driver_types::ExecuteTransactionRequestType,
    signature::GenericSignature,
    transaction::{
        Command, GasData, ObjectArg, ProgrammableMoveCall, ProgrammableTransaction, Transaction,
        TransactionData, TransactionDataV1, TransactionExpiration, TransactionKind,
    },
    type_input::TypeInput,
    zk_login_authenticator::ZkLoginAuthenticator,
};

const SUI_COIN_TYPE: &str = "0x2::sui::SUI";

pub struct TxRunner {
    keypair: Ed25519KeyPair,
    zkp: ZkLoginInputs,
    client: SuiClient,
    address: SuiAddress,
    max_epoch: u64,

    rgp: Option<u64>,
    coins: Option<Vec<Coin>>,

    /// Cache of shared object refs.
    shared_refs: HashMap<ObjectID, SharedObjectRef>,
}

pub struct SharedObjectRef {
    id: ObjectID,
    initial_shared_version: SequenceNumber,
    mutable: bool,
}

impl TxRunner {
    pub fn new(
        keypair: Ed25519KeyPair,
        zkp: ZkLoginInputs,
        max_epoch: u64,
        client: SuiClient,
    ) -> Self {
        Self {
            address: SuiAddress::try_from_unpadded(&zkp).unwrap(),
            keypair,
            zkp,
            client,
            max_epoch,
            rgp: None,
            coins: None,
            shared_refs: HashMap::new(),
        }
    }

    pub async fn test_tx(&mut self) -> Result<(), anyhow::Error> {
        let mut ptb = ProgrammableTransactionBuilder::new();
        let arg = ptb.pure(10u8)?;
        let some_res = ptb.command(Command::MoveCall(
            ProgrammableMoveCall {
                package: ObjectID::from_hex_literal("0x1")?,
                module: "option".to_string(),
                function: "some".to_string(),
                type_arguments: vec![TypeInput::U8],
                arguments: vec![arg],
            }
            .into(),
        ));

        ptb.command(Command::MoveCall(
            ProgrammableMoveCall {
                package: ObjectID::from_hex_literal("0x1")?,
                module: "option".to_string(),
                function: "destroy_some".to_string(),
                type_arguments: vec![TypeInput::U8],
                arguments: vec![some_res],
            }
            .into(),
        ));

        // 0.1 SUI
        let _res = self.execute_tx(ptb.finish(), Some(100000000), None).await?;

        Ok(())
    }

    pub async fn create_demo() {}

    /// Execute a programmable transaction:
    /// 1. Run devInspectTransactionBlock to get the gas cost
    /// 2. Select coins to pay for the gas
    /// 3. Sign & Execute the transaction
    pub async fn execute_tx(
        &mut self,
        ptb: ProgrammableTransaction,
        gas_budget: Option<u64>,
        options: Option<SuiTransactionBlockResponseOptions>,
    ) -> Result<SuiTransactionBlockResponse, anyhow::Error> {
        let gas_price = if let Some(rgp) = self.rgp {
            rgp
        } else {
            let rgp = self.client.read_api().get_reference_gas_price().await?;
            self.rgp = Some(rgp);
            rgp
        };

        let gas_budget = if let Some(gas_budget) = gas_budget {
            gas_budget
        } else {
            // This currently exists only for gas. Can be removed potentially.
            // Manual gas submission saves ~150ms of latency per tx.
            let results = self
                .client
                .read_api()
                .dev_inspect_transaction_block(
                    self.address,
                    TransactionKind::ProgrammableTransaction(ptb.clone()),
                    None,
                    None,
                    None,
                )
                .await?;
            let gas = results.effects.gas_cost_summary().gas_used();
            gas * gas_price
        };

        let gas_coins = self.select_coins(gas_budget).await?;
        let tx = TransactionKind::ProgrammableTransaction(ptb);
        let tx_data = TransactionData::V1(TransactionDataV1 {
            sender: self.address,
            gas_data: GasData {
                payment: gas_coins,
                owner: self.address,
                price: gas_price,
                budget: gas_budget,
            },
            expiration: TransactionExpiration::None,
            kind: tx,
        });

        // Sign with ephemeral key, then create a ZkLogin signature.
        let signature = Signature::new_secure(
            &IntentMessage::new(Intent::sui_transaction(), &tx_data),
            &self.keypair,
        );

        // Wrap the signature in a ZkLoginAuthenticator.
        let signature = GenericSignature::from(ZkLoginAuthenticator::new(
            self.zkp.clone(),
            self.max_epoch,
            signature,
        ));

        // Whatever the options are, we require object changes and effects at all times.
        let res = self
            .client
            .quorum_driver_api()
            .execute_transaction_block(
                // Note: use `from_data` if the signature is not `GenericSignature`.
                Transaction::from_generic_sig_data(tx_data, vec![signature]),
                options
                    .unwrap_or_default()
                    .with_object_changes()
                    .with_effects(),
                Some(ExecuteTransactionRequestType::WaitForEffectsCert),
            )
            .await?;

        // Remove coins from the coin cache if they're marked as deleted in object changes.
        // This way we maintain integrity of the Coin cache.
        if let Some(object_changes) = &res.object_changes {
            let sui_coin_type = StructTag::from_str(SUI_COIN_TYPE).unwrap();

            for change in object_changes {
                match change {
                    ObjectChange::Deleted {
                        object_type,
                        object_id,
                        ..
                    } => {
                        if object_type == &sui_coin_type {
                            if let Some(coins) = &mut self.coins {
                                coins.retain(|coin| coin.coin_object_id != *object_id);
                            }
                        }
                    }
                    _ => {}
                }
            }
        }

        if let Some(effects) = &res.effects {
            println!("Status: {:?}", effects.status());
        }

        Ok(res)
    }

    /// Select coins to pay for the gas. Caches the coins in the `TxRunner` instance.
    pub async fn select_coins(&mut self, amount: u64) -> Result<Vec<ObjectRef>, anyhow::Error> {
        let coins = if let Some(coins) = &self.coins {
            coins
        } else {
            let page = self
                .client
                .coin_read_api()
                .get_coins(self.address, None, None, Some(100))
                .await?;
            self.coins = Some(page.data.clone());
            self.coins.as_ref().unwrap()
        };

        // Pick coins until we have enough for amount.
        let mut total_picked = 0u64;
        let mut picked = vec![];
        for coin in coins {
            if total_picked >= amount {
                break;
            }

            total_picked += coin.balance;
            picked.push(coin.object_ref());
        }

        Ok(picked)
    }

    /// Get a shared object ref from the cache, or query it from the network and
    /// cache it. Shared objects versions do not need to be tracked, easy to use.
    pub async fn shared_object_arg(
        &mut self,
        object_id: ObjectID,
    ) -> Result<ObjectArg, anyhow::Error> {
        let object = self
            .client
            .read_api()
            .get_object_with_options(object_id, SuiObjectDataOptions::new().with_owner())
            .await?;

        if let Some(error) = object.error {
            return Err(anyhow::anyhow!("Object not found {}", error));
        };

        Ok(SharedObjectRef::try_from(object)?.into())
    }
}

// === Impls ===

impl TryFrom<SuiObjectResponse> for SharedObjectRef {
    type Error = anyhow::Error;

    fn try_from(object: SuiObjectResponse) -> Result<Self, Self::Error> {
        if let Some(data) = object.data {
            if let Some(owner) = data.owner {
                Ok(SharedObjectRef {
                    id: data.object_id,
                    initial_shared_version: owner.start_version().unwrap(),
                    // Currently hardcoded. Maybe there's a better way to do this.
                    mutable: true,
                })
            } else {
                return Err(anyhow::anyhow!(
                    "Missing owner, use `with_owner` when querying"
                ));
            }
        } else {
            return Err(anyhow::anyhow!(
                "Missing data, use `with_data` when querying"
            ));
        }
    }
}

impl Into<ObjectArg> for SharedObjectRef {
    fn into(self) -> ObjectArg {
        ObjectArg::SharedObject {
            id: self.id,
            initial_shared_version: self.initial_shared_version,
            mutable: self.mutable,
        }
    }
}
