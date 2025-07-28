// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use thiserror::Error;

use crate::zklogin::ZkLoginError;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Failed to get JWT")]
    FailedToGetJwt,

    #[error(transparent)]
    ZkLoginError(ZkLoginError),
}
