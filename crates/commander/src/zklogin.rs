// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use axum::{Router, extract::Query, response::Html, routing::get};
use fastcrypto::ed25519::Ed25519PublicKey;
use fastcrypto::encoding::Base64;
use fastcrypto::encoding::Encoding;
use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::convert::Infallible;
use std::sync::Arc;
use std::sync::mpsc::Sender;
use sui_types::base_types::SuiAddress;
use sui_types::crypto::PublicKey;
use sui_types::crypto::ZkLoginPublicIdentifier;
use tokio::sync::Mutex;
use tokio::sync::oneshot;

// use crate::game::Message as GameMessage;
use crate::Message as AppMessage;

const REDIRECT_URI: &str = "http://localhost:5337/";
const STATE: &str = "1234567890";
const NONCE: &str = "1234567890";
const RESPONSE_TYPE: &str = "code";
const SCOPE: &str = "openid";

// Desktop client
const CLIENT_ID: &str = "";
const CLIENT_SECRET: &str = "";

const ENOKI_API_URL: &str = "https://api.enoki.mystenlabs.com/v1/zklogin";
const ENOKI_API_KEY: &str = "";

/// Opens the login page in the default browser. The nonce must be fetch preemptively and stored in the session.
/// It is then used to generate the zkp.
pub fn open_auth_page(nonce: &String) {
    open::that(format!("https://accounts.google.com/o/oauth2/v2/auth?redirect_uri={}&response_type={}&scope={}&state={}&nonce={}&client_id={}", REDIRECT_URI, RESPONSE_TYPE, SCOPE, STATE, nonce, CLIENT_ID)).unwrap();
}

#[derive(Deserialize, Debug)]
pub struct NonceResponse {
    pub nonce: String,
    pub randomness: String,
    pub epoch: u32,
    #[serde(rename = "maxEpoch")]
    pub max_epoch: u32,
    #[serde(rename = "estimatedExpiration")]
    pub estimated_expiration: u64,
}

#[derive(Deserialize, Debug)]
struct DataWrapper<T> {
    data: T,
}

/// Make the first request to the Enoki API to get the nonce. The nonce is then
/// used in the auth request for validation. The rest of the parameters are crucial
/// for the zkp later on too.
pub async fn get_nonce(public_key: &Ed25519PublicKey) -> Result<NonceResponse, anyhow::Error> {
    #[derive(Serialize)]
    struct NonceRequest {
        network: String,
        #[serde(rename = "ephemeralPublicKey")]
        ephemeral_public_key: String,
        #[serde(rename = "additionalEpochs")]
        additional_epochs: u32,
    }

    let request = NonceRequest {
        network: "testnet".to_string(),
        ephemeral_public_key: ephemeral_public_key(public_key),
        additional_epochs: 10,
    };

    println!("Request: {:?}", serde_json::to_string(&request)?);

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/nonce", ENOKI_API_URL))
        .header("Authorization", format!("Bearer {}", ENOKI_API_KEY))
        .header("Content-Type", "application/json")
        .body(serde_json::to_string(&request)?)
        .send()
        .await?;

    let text = response.text().await?;

    println!("Response: {:?}", &text);
    let body = text;
    let data: DataWrapper<NonceResponse> = serde_json::from_str(&body)?;

    Ok(data.data)
}

/// Starts a local web server that listens for the code from the login process. It must listen on the
/// same port as the redirect URI (5337) and the same host (localhost).
pub async fn start_auth_listener(tx: &Sender<AppMessage>) -> Result<Option<String>, anyhow::Error> {
    let main_tx = tx.clone();
    let (shutdown_tx, shutdown_rx) = oneshot::channel::<()>();
    let shutdown_tx = Arc::new(Mutex::new(Some(shutdown_tx)));
    let code = Arc::new(Mutex::new(None));

    // build our application with a route
    let app = Router::new().route(
        "/",
        get({
            let code = code.clone();
            async move |request: Query<HashMap<String, String>>| -> Result<Html<String>, Infallible> {
            println!("Received request: {:?}", request);

            if let Some(shutdown_tx) = shutdown_tx.lock().await.take() {
                shutdown_tx.send(()).unwrap();
            }

            if let Some(received_code) = request.0.get("code") {
                code.clone().lock().await.replace(received_code.clone());
                main_tx.send(AppMessage::Text(format!("Login: {}", received_code))).unwrap();
                Ok(Html("Login successful! You may close this window.".to_string()))
            } else {
                Ok(Html("Login failed. Please, close this window and try again.".to_string()))
            }
        }}),
    );

    let listener = tokio::net::TcpListener::bind("127.0.0.1:5337")
        .await
        .unwrap();

    println!("Listening on port 5337");
    axum::serve(listener, app)
        .with_graceful_shutdown(async move {
            let _ = shutdown_rx.await;
            println!("Shutting down auth listener");
        })
        .await
        .unwrap();

    Ok(code.lock().await.take())
}

#[derive(Deserialize, Debug)]
pub struct JwtResponse {
    pub access_token: String,
    pub expires_in: u32,
    pub id_token: String,
    // pub refresh_token: String,
    pub scope: String,
    pub token_type: String,
}

/// Make a request to Google to get the JWT token based on the authorization code.
pub async fn get_jwt(code: String) -> Result<String, anyhow::Error> {
    let client = reqwest::Client::new();
    // Not sure if this is the best way to do this. We need to set it as a compile-time variable.
    let response = client
        .post("https://oauth2.googleapis.com/token")
        .form(&[
            ("code", &code),
            ("client_id", &CLIENT_ID.to_string()),
            ("client_secret", &CLIENT_SECRET.to_string()),
            ("redirect_uri", &REDIRECT_URI.to_string()),
            ("grant_type", &"authorization_code".to_string()),
        ])
        .send()
        .await?;
    let body = response.text().await?;
    let data: JwtResponse = serde_json::from_str(&body)?;
    Ok(data.id_token)
}

#[derive(Deserialize, Debug)]
pub struct ProofPoints {
    a: Vec<String>,
    b: Vec<Vec<String>>,
    c: Vec<String>,
}

#[derive(Deserialize, Debug)]
pub struct IssBase64Details {
    value: String,
    #[serde(rename = "indexMod4")]
    index_mod4: u32,
}

#[derive(Deserialize, Debug)]
pub struct ZkpResponse {
    #[serde(rename = "proofPoints")]
    pub proof_points: ProofPoints,
    #[serde(rename = "issBase64Details")]
    pub iss_base64_details: IssBase64Details,
    #[serde(rename = "headerBase64")]
    pub header_base64: String,
    #[serde(rename = "addressSeed")]
    pub address_seed: String,
}

/// Make a request to the Enoki API to get the ZKP data.
pub async fn get_zkp(
    jwt: String,
    nonce: NonceResponse,
    public_key: &Ed25519PublicKey,
) -> Result<ZkLoginInputs, anyhow::Error> {
    #[derive(Serialize)]
    struct ZkpRequest {
        network: String,
        #[serde(rename = "ephemeralPublicKey")]
        ephemeral_public_key: String,
        #[serde(rename = "maxEpoch")]
        max_epoch: u32,
        randomness: String,
    }

    let request = ZkpRequest {
        network: "testnet".to_string(),
        ephemeral_public_key: ephemeral_public_key(public_key),
        max_epoch: nonce.max_epoch,
        randomness: nonce.randomness,
    };

    println!("Request: {:?}", serde_json::to_string(&request)?);

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/zkp", ENOKI_API_URL))
        .header("Authorization", format!("Bearer {}", ENOKI_API_KEY))
        .header("Content-Type", "application/json")
        .header("zklogin-jwt", jwt)
        .body(serde_json::to_string(&request)?)
        .send()
        .await?;
    let body = response.text().await?;
    let data: DataWrapper<ZkLoginInputs> = serde_json::from_str(&body)?;
    Ok(data.data)
}

pub fn get_address(zkp: &ZkLoginInputs) -> Result<SuiAddress, anyhow::Error> {
    let pk = PublicKey::ZkLogin(
        ZkLoginPublicIdentifier::new(
            &zkp.get_iss(),
            &zkp.get_address_seed(),
        )
        .unwrap(),
    );
    Ok(SuiAddress::from(&pk))
}

/// Pad the public key with a 0x00 byte to make it 32 bytes long and encode it in base64.
pub fn ephemeral_public_key(public_key: &Ed25519PublicKey) -> String {
    let mut eph_pk_bytes = vec![0x00];
    eph_pk_bytes.extend(public_key.as_ref());
    Base64::encode(eph_pk_bytes)
}
