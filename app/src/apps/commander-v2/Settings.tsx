// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useZkLogin } from "@mysten/enoki/react";
import { NavLink } from "react-router-dom";

export function Settings() {
    const zkLogin = useZkLogin();
    const { data: balanceQuery, isPending } = useSuiClientQuery("getBalance", {
        owner: zkLogin.address!,
    }, { enabled: !!zkLogin.address });

    return (
        <div className="flex justify-center align-middle h-screen flex-col">
            <h1 className="menu-control">Settings</h1>
            <p className="text-center">Account balance: {isPending ? '...' : formatBalance(balanceQuery?.totalBalance!)}</p>
            <NavLink className="menu-control" to="/commander-v2">Back</NavLink>
        </div>
    );
}

function formatBalance(balance: string) {
    if (!balance) {
        return `0 SUI`;
    }

    let num = balance.slice(0, -9);
    let dec = balance.slice(-9).slice(0, 2);
    return `${num}.${dec} SUI`;
}
