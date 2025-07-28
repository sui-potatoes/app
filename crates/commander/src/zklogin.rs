// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use axum::{Router, extract::Query, response::Html, routing::get};
use fastcrypto::{
    ed25519::Ed25519PublicKey,
    encoding::{Base64, Encoding},
};
use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::convert::Infallible;
use std::sync::Arc;
use thiserror::Error;
use tokio::sync::Mutex;
use tokio::sync::oneshot;

use crate::errors::Error;

const REDIRECT_URI: &str = "http://localhost:5337/";
const RESPONSE_TYPE: &str = "code";
const SCOPE: &str = "openid";

const CLIENT_ID: &str = env!("GOOGLE_CLIENT_ID");
const CLIENT_SECRET: &str = env!("GOOGLE_CLIENT_SECRET");

const ENOKI_API_URL: &str = "https://api.enoki.mystenlabs.com/v1/zklogin";
const ENOKI_API_KEY: &str = env!("ENOKI_API_KEY");

/// Opens the login page in the default browser. The nonce must be fetch preemptively and stored in the session.
/// It is then used to generate the zkp.
pub fn open_auth_page(nonce: &String) {
    open::that(format!("https://accounts.google.com/o/oauth2/v2/auth?redirect_uri={}&response_type={}&scope={}&nonce={}&client_id={}&service=lso&o2v=2&flowName=GeneralOAuthFlow", REDIRECT_URI, RESPONSE_TYPE, SCOPE, nonce, CLIENT_ID)).unwrap();
}

#[derive(Error, Debug)]
pub enum ZkLoginError {
    #[error("Failed to serialize request")]
    FailedToSerializeRequest,
    #[error("Failed to get nonce")]
    FailedToGetNonce,
    #[error("Failed to get ZKP")]
    FailedToGetZkp,
    #[error("Failed to get address")]
    FailedToGetAddress,
    #[error("Failed to parse response")]
    FailedToParseResponse,
    #[error("Failed to initialize ZKP")]
    FailedZkpInit,
    #[error("Failed to get JWT")]
    FailedToGetJwt,
}

#[derive(Deserialize, Debug)]
pub struct NonceResponse {
    pub nonce: String,
    pub randomness: String,
    pub epoch: u64,
    #[serde(rename = "maxEpoch")]
    pub max_epoch: u64,
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
pub async fn get_nonce(public_key: &Ed25519PublicKey) -> Result<NonceResponse, Error> {
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

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/nonce", ENOKI_API_URL))
        .header("Authorization", format!("Bearer {}", ENOKI_API_KEY))
        .header("Content-Type", "application/json")
        .body(
            serde_json::to_string(&request)
                .map_err(|_| ZkLoginError::FailedToSerializeRequest.into())?,
        )
        .send()
        .await
        .map_err(|_| ZkLoginError::FailedToGetNonce.into())?;

    let text = response
        .text()
        .await
        .map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    let data: DataWrapper<NonceResponse> =
        serde_json::from_str(&text).map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    Ok(data.data)
}

/// Starts a local web server that listens for the code from the login process. It must listen on the
/// same port as the redirect URI (5337) and the same host (localhost).
pub async fn start_auth_listener() -> Result<Option<String>, Error> {
    let (shutdown_tx, shutdown_rx) = oneshot::channel::<()>();
    let shutdown_tx = Arc::new(Mutex::new(Some(shutdown_tx)));
    let code = Arc::new(Mutex::new(None));

    // build our application with a route
    let app = Router::new().route(
        "/",
        get({
            let code = code.clone();
            async move |request: Query<HashMap<String, String>>| -> Result<Html<String>, Infallible> {

            if let Some(shutdown_tx) = shutdown_tx.lock().await.take() {
                shutdown_tx.send(()).unwrap();
            }

            if let Some(received_code) = request.0.get("code") {
                code.clone().lock().await.replace(received_code.clone());
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
pub async fn get_jwt(code: String) -> Result<String, Error> {
    let client = reqwest::Client::new();

    // Not sure if this is the best way to do this. We need to set it as a compile-time variable.
    let response = client
        .post("https://oauth2.googleapis.com/token")
        .form(&[
            ("code", &code),
            ("client_id", &std::env::var("GOOGLE_CLIENT_ID").unwrap()),
            ("client_secret", &std::env::var("GOOGLE_CLIENT_SECRET").unwrap()),
            ("redirect_uri", &REDIRECT_URI.to_string()),
            ("grant_type", &"authorization_code".to_string()),
        ])
        .send()
        .await
        .map_err(|_| ZkLoginError::FailedToGetJwt.into())?;

    let body = response
        .text()
        .await
        .map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    let data: JwtResponse =
        serde_json::from_str(&body).map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    Ok(data.id_token)
}

/// Make a request to the Enoki API to get the ZKP data.
pub async fn get_zkp(
    jwt: String,
    nonce: NonceResponse,
    public_key: &Ed25519PublicKey,
) -> Result<ZkLoginInputs, Error> {
    #[derive(Serialize)]
    struct ZkpRequest {
        network: String,
        #[serde(rename = "ephemeralPublicKey")]
        ephemeral_public_key: String,
        #[serde(rename = "maxEpoch")]
        max_epoch: u64,
        randomness: String,
    }

    let request = ZkpRequest {
        network: "testnet".to_string(),
        ephemeral_public_key: ephemeral_public_key(public_key),
        max_epoch: nonce.max_epoch,
        randomness: nonce.randomness,
    };

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/zkp", ENOKI_API_URL))
        .header("Authorization", format!("Bearer {}", ENOKI_API_KEY))
        .header("Content-Type", "application/json")
        .header("zklogin-jwt", jwt)
        .body(
            serde_json::to_string(&request)
                .map_err(|_| ZkLoginError::FailedToSerializeRequest.into())?,
        )
        .send()
        .await
        .map_err(|_| ZkLoginError::FailedToGetZkp.into())?;

    let body = response
        .text()
        .await
        .map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    let mut data: DataWrapper<ZkLoginInputs> =
        serde_json::from_str(&body).map_err(|_| ZkLoginError::FailedToParseResponse.into())?;

    // This .init() call is critical for parsing the ISS
    Ok(data
        .data
        .init()
        .map_err(|_| ZkLoginError::FailedZkpInit.into())?)
}

/// Pad the public key with a 0x00 byte to make it 32 bytes long and encode it in base64.
pub fn ephemeral_public_key(public_key: &Ed25519PublicKey) -> String {
    let mut eph_pk_bytes = vec![0x00];
    eph_pk_bytes.extend(public_key.as_ref());
    Base64::encode(eph_pk_bytes)
}

// === Into impls ===

impl Into<Error> for ZkLoginError {
    fn into(self) -> Error {
        Error::ZkLoginError(self)
    }
}
