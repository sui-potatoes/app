// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useZkLogin } from "@mysten/enoki/react";
import { NavLink } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";

/**
 * Page that stores the settings of the user.
 *
 * - top up account balance
 * - view account balance
 * - view address
 *
 * Maybe:
 *
 * - sound settings
 * - graphics settings
 * - UI size settings
 */
export function Settings() {
    const zkLogin = useZkLogin();
    const { data: balanceQuery, isPending } = useSuiClientQuery(
        "getBalance",
        {
            owner: zkLogin.address!,
        },
        { enabled: !!zkLogin.address },
    );

    if (!zkLogin.address) {
        return (
            <div className="flex justify-center align-middle h-screen flex-col">
                <h1 className="menu-control">Settings</h1>
                <p className="text-center">Please login to view your settings.</p>
                <NavLink className="menu-control" to="/commander">
                    Back
                </NavLink>
            </div>
        );
    }

    return (
        <div className="flex justify-center align-middle h-screen flex-col">
            <div className="bg-black bg-opacity-70 p-5 text-md rounded">
                <h1 className="block p-1 mb-10 text-center text-lg uppercase white">Settings</h1>
                <p className="text-center">
                    Address:{" "}
                    <a
                        onClick={(e) => {
                            e.preventDefault();
                            const target = e.target as HTMLAnchorElement;
                            navigator.clipboard.writeText(zkLogin.address!);
                            target.textContent = `${formatAddress(zkLogin.address!)} (copied)`;
                            setTimeout(() => {
                                target.textContent = `${formatAddress(zkLogin.address!)}`;
                            }, 1000);
                        }}
                    >
                        {formatAddress(zkLogin.address)}
                    </a>
                </p>
                <p className="text-center">
                    Account balance:{" "}
                    {isPending ? "..." : formatBalance(balanceQuery?.totalBalance!)}
                </p>
                {balanceQuery && BigInt(balanceQuery?.totalBalance) < 1000000000n && (
                    <p className="text-center">Top up your account to play</p>
                )}
                <NavLink className="menu-control mt-10" to="/commander">
                    Back
                </NavLink>
            </div>
        </div>
    );
}

function formatBalance(balance: string) {
    if (!balance) return `0 SUI`;
    let num = balance.slice(0, -9);
    let dec = balance.slice(-9).slice(0, 2);
    return `${num}.${dec} SUI`;
}
