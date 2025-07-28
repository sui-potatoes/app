// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::zklogin::ZkLoginError;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Failed to get JWT")]
    FailedToGetJwt,

    #[error(transparent)]
    ZkLoginError(ZkLoginError),
}
