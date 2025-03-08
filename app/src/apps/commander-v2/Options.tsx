// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useZkLogin } from "@mysten/enoki/react";
import { NavLink } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";
import { Footer } from "./Footer";
import { useState } from "react";

/**
 * Page that stores the options of the user.
 *
 * - top up account balance
 * - view account balance
 * - view address
 *
 * Maybe:
 *
 * - sound options
 * - graphics options
 * - UI size options
 */
export function Options() {
    const zkLogin = useZkLogin();
    const [optModels, setOptModels] = useState(false);
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
                <h1 className="menu-control">options</h1>
                <p className="text-center">Please login to view your options.</p>
                <NavLink className="menu-control" to="/commander">
                    Back
                </NavLink>
            </div>
        );
    }

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                <h1 className="block p-1 mb-10 uppercase white page-heading">options / general</h1>
            </div>
            <div className="p-10 text-uppercase text-lg rounded max-w-3xl">
                <div className="options-row">
                    <label>ADDRESS</label>
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
                </div>
                <div className="options-row">
                    <label>BALANCE</label>
                    <p>
                        {isPending ? "..." : formatBalance(balanceQuery?.totalBalance!)}
                        {balanceQuery && BigInt(balanceQuery?.totalBalance) < 1000000000n && (
                            <>Top up your account to play</>
                        )}
                    </p>
                </div>
                <div className="options-row">
                    <label>OPTIMIZE MODELS</label>
                    <YesOrNo value={optModels} onChange={setOptModels} />
                    {/* <div>
                        <input type="checkbox" />
                    </div> */}
                </div>
            </div>
            <Footer></Footer>
        </div>
    );
}

function YesOrNo({ value, onChange }: { value: boolean; onChange: (v: boolean) => void }) {
    return (
        <div className="flex justify-between">
            <div
                className={"yes-no" + (value ? ' selected' : '')}
                onClick={() => !value && onChange(true)}
            >
                YES
            </div>
            <div
                className={"yes-no" + (!value ? ' selected' : '')}
                onClick={() => value && onChange(false)}
            >
                NO
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
