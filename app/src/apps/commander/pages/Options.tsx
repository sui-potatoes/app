// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { formatAddress } from "@mysten/sui/utils";
import { useState } from "react";
import { Modal, YesOrNo, Footer } from "./Components";
import { Transaction } from "@mysten/sui/transactions";
import { SuinsClient, SuinsTransaction } from "@mysten/suins";
import { useNetworkVariable } from "../../../networkConfig";
import { useTransactionExecutor } from "../hooks/useTransactionExecutor";
import { useSuinsName } from "../hooks/useSuinsName";
import { COMMANDER_BASE_NAME } from "../../../constants";

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
    const checkIsFullscreen = window.innerHeight == screen.height;
    const [isFullscreen, setIsFullscreen] = useState(checkIsFullscreen);
    const [optModels, setOptModels] = useState(true);
    const { name, modal: suinsModal, showNameModal } = suinsSetting();

    const { data: balanceQuery, isPending } = useSuiClientQuery(
        "getBalance",
        { owner: zkLogin.address! },
        { enabled: !!zkLogin.address },
    );

    return (
        <div className="flex justify-between align-middle flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                <h1 className="block p-1 mb-10 uppercase white page-heading">options / general</h1>
            </div>
            <div className="p-10 text-uppercase text-lg rounded max-w-3xl">
                <div className="options-row">
                    <label>ADDRESS</label>
                    {zkLogin.address && (
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
                    )}
                    {!zkLogin.address && <div>NOT SIGNED IN</div>}
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
                    <label>NAME</label>
                    {!name && zkLogin.address && (
                        <div className="flex">
                            <div className="yes-no" onClick={() => showNameModal()}>
                                SET
                            </div>
                        </div>
                    )}
                    {!name && !zkLogin.address && <div className="yes-no non-interactive">SET</div>}
                    {name && (
                        <div className="flex">
                            {name}.{COMMANDER_BASE_NAME}.sui
                        </div>
                    )}
                </div>
                <div className="options-row">
                    <label>OPTIMIZE MODELS</label>
                    <YesOrNo value={optModels} onChange={setOptModels} />
                </div>
                <div className="options-row">
                    <label>FULLSCREEN</label>
                    <YesOrNo
                        value={isFullscreen}
                        onChange={(v) => {
                            if (v) document.documentElement.requestFullscreen();
                            else document.exitFullscreen();
                            setIsFullscreen(v);
                        }}
                    />
                </div>
            </div>
            {!name && suinsModal}
            <Footer />
        </div>
    );
}

function suinsSetting() {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const name = useSuinsName({ address: zkLogin.address });
    const packageId = useNetworkVariable("commanderRegistryPackageId");
    const registry = useNetworkVariable("commanderNamesObjectId");
    const [showModal, setShowModal] = useState(false);
    const { executeTransaction } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const nsClient = new SuinsClient({ client, network: "testnet" });
    const [suinsName, setSuinsName] = useState("");

    return {
        name,
        showNameModal: () => setShowModal(true),
        modal: (
            <Modal show={showModal} onClose={() => setShowModal(false)}>
                <div
                    className="m-auto border border-grey p-10 w-2xl"
                    onClick={(e) => e.stopPropagation()}
                >
                    <h1 className="text-xl uppercase mb-10 text-center">Choose an in-game name</h1>
                    <input
                        id="suins"
                        type="text"
                        className="bg-black w-full h-10 text-lg text-white border border-grey uppercase p-4"
                        placeholder="Enter name..."
                        onChange={(e) => setSuinsName(e.target.value)}
                        onKeyPress={(e) => e.key === "Enter" && createSuinsName(suinsName)}
                    />
                    <button
                        className="interactive w-full mt-10 §10"
                        onClick={() => createSuinsName(suinsName)}
                    >
                        Save
                    </button>
                </div>
            </Modal>
        ),
    };

    async function createSuinsName(name: string) {
        if (name.length < 3) throw new Error("Name must be at least 3 characters long.");
        if (name.length > 12) throw new Error("Name must be at most 12 characters long.");
        if (!/^[a-zA-Z0-9]*$/.test(name)) throw new Error("Name must be alphanumeric.");

        const tx = new Transaction();
        const registryArg = tx.object(registry);
        const [ns, borrow] = tx.moveCall({
            target: `${packageId}::commander_names::borrow`,
            arguments: [registryArg],
        });

        // @ts-ignore
        const nsTx = new SuinsTransaction(nsClient, tx);
        const subname = nsTx.createSubName({
            parentNft: ns,
            name: `${name}@${COMMANDER_BASE_NAME}`,
            expirationTimestampMs: 1759957200000, // quite random
            allowChildCreation: false,
            allowTimeExtension: false,
        });

        nsTx.setTargetAddress({
            nft: subname,
            address: zkLogin.address,
            isSubname: true,
        });

        nsTx.setDefault(`${name}@${COMMANDER_BASE_NAME}`);

        tx.moveCall({
            target: `${packageId}::commander_names::put_back`,
            arguments: [registryArg, ns, borrow],
        });

        tx.transferObjects([subname], tx.pure.address(zkLogin.address as string));

        const {
            data: { effects },
        } = await executeTransaction!(tx);
        if (effects && effects.status.status === "success") {
            setShowModal(false);
            return location.reload();
        }

        alert("Failed to create name. Reason: " + effects?.status.error);
    }
}

function formatBalance(balance: string) {
    if (!balance) return `0 SUI`;
    let num = balance.slice(0, -9);
    let dec = balance.slice(-9).slice(0, 2);
    return `${num}.${dec} SUI`;
}
