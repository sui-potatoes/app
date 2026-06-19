// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount } from "@mysten/dapp-kit-react";
import { formatAddress, MIST_PER_SUI } from "@mysten/sui/utils";
import { useEffect, useState } from "react";

import { useBalance } from "./hooks/useBalance";

/** Below this the funds prompt appears. Testnet gas is cheap; 0.1 SUI is plenty. */
const LOW_BALANCE = MIST_PER_SUI / 10n;

const FAUCETS = ["https://faucet.suilearn.io/", "https://faucet.sui.io/"];

/**
 * Shell-level prompt shown on any sub-app when the signed-in account is low on
 * testnet SUI. The balance is polled (see `useBalance`) so this closes itself
 * once funds arrive; it offers the public faucets and a copyable address, and
 * can be dismissed with "Okay".
 */
export function FaucetModal() {
    const account = useCurrentAccount();
    const { data: mist, isFetching } = useBalance();
    const [dismissed, setDismissed] = useState(false);
    const [copied, setCopied] = useState(false);

    const isLow = mist !== undefined && mist < LOW_BALANCE;

    // Re-arm the prompt once the balance recovers, so it can return if the
    // account runs low again later in the session.
    useEffect(() => {
        if (mist !== undefined && mist >= LOW_BALANCE) setDismissed(false);
    }, [mist]);

    if (!account || !isLow || dismissed) return null;

    const sui = (Number(mist) / Number(MIST_PER_SUI)).toFixed(4);

    async function copyAddress() {
        if (!account) return;
        try {
            await navigator.clipboard.writeText(account.address);
            setCopied(true);
            setTimeout(() => setCopied(false), 1500);
        } catch (e) {
            console.warn("clipboard write failed:", e);
        }
    }

    return (
        <div className="fixed inset-0 z-[200] flex items-center justify-center bg-overlay p-6 backdrop-blur-sm">
            <div className="flex w-full max-w-sm flex-col gap-6 border border-line bg-surface p-8">
                <div className="flex flex-col gap-1.5">
                    <h2 className="text-sm uppercase tracking-[0.2em] text-foreground">
                        Low balance
                    </h2>
                    <p className="text-[11px] uppercase tracking-wider text-secondary">
                        Request testnet SUI to keep playing
                    </p>
                </div>

                <div className="h-px w-[60px] bg-line" />

                <dl className="flex flex-col gap-3 text-sm uppercase tracking-wider">
                    <div className="flex items-baseline justify-between">
                        <dt className="text-secondary">Balance</dt>
                        <dd className="text-foreground">
                            {sui} <span className="text-secondary">SUI</span>
                            {isFetching && <span className="ml-1.5 text-muted">·</span>}
                        </dd>
                    </div>
                    <div className="flex items-baseline justify-between gap-3">
                        <dt className="text-secondary">Address</dt>
                        <dd>
                            <button
                                onClick={copyAddress}
                                className="normal-case text-foreground transition-colors hover:text-accent"
                                title="Copy address"
                            >
                                {formatAddress(account.address)}{" "}
                                <span className="text-[10px] uppercase tracking-wider text-muted">
                                    {copied ? "copied" : "copy"}
                                </span>
                            </button>
                        </dd>
                    </div>
                </dl>

                <div className="flex flex-col gap-2 text-[11px] uppercase tracking-wider">
                    <span className="text-secondary">Faucets</span>
                    {FAUCETS.map((url) => (
                        <a
                            key={url}
                            href={url}
                            target="_blank"
                            rel="noreferrer"
                            className="transition-colors hover:text-accent"
                        >
                            {url.replace(/^https?:\/\//, "").replace(/\/$/, "")} ↗
                        </a>
                    ))}
                </div>

                <button className="btn w-full" onClick={() => setDismissed(true)}>
                    Okay
                </button>
            </div>
        </div>
    );
}
