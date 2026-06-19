// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Home — deliberately sparse. Navigation lives in the sidebar; this page is
 * just a calm title card with room to breathe.
 */
export default function Root() {
    return (
        <div className="flex flex-col justify-center min-h-[calc(100vh-40px)] max-w-2xl">
            <p className="mb-7 text-[11px] uppercase tracking-[0.28em] text-secondary">
                Sui · Testnet
            </p>
            <h1 className="text-4xl font-light lowercase tracking-tight text-foreground md:text-5xl">
                pot8os
            </h1>
            <p className="mt-6 max-w-xs text-sm leading-relaxed text-secondary">
                On-chain games and open-source Move libraries on Sui.
            </p>
        </div>
    );
}
