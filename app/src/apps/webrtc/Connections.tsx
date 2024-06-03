// import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { bcs } from "@mysten/sui/bcs";
import {
    useCurrentAccount,
    useSignAndExecuteTransaction,
    useSuiClient,
    useSuiClientQuery,
} from "@mysten/dapp-kit";
import { useState } from "react";
import { SuiObjectRef } from "@mysten/sui/client";
import { fromB64 } from "@mysten/bcs";
import { formatAddress } from "@mysten/sui/utils";

const Message = bcs.struct("OfferOrAnswer", {
    id: bcs.Address,
    from: bcs.Address,
    sdp: bcs.String,
});

type ConnectionsProps = {
    onTargetSelect?: (addr: string) => void;
    onAccept?: (addr: MessageDetails) => void;
};

type MessageDetails = {
    objectRef: SuiObjectRef;
    contents: typeof Message.$inferType;
};

export function Connections({ onAccept, onTargetSelect }: ConnectionsProps) {
    const account = useCurrentAccount();
    const client = useSuiClient();
    const packageId = useNetworkVariable("webrtcPackageId");
    const [canInteract, setCanInteract] = useState(true);

    const { data: answers } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: account?.address || "",
            filter: { StructType: `${packageId}::webrtc::Answer` },
            options: { showBcs: true },
        },
        { enabled: !!account?.address },
    );

    const { data: offers } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: account?.address || "",
            filter: { StructType: `${packageId}::webrtc::Offer` },
            options: { showBcs: true },
        },
        { enabled: !!account?.address },
    );

    const { mutateAsync: signAndExecuteTransaction } =
        useSignAndExecuteTransaction({
            execute: ({ bytes, signature }) => {
                return client.executeTransactionBlock({
                    transactionBlock: bytes,
                    signature,
                    options: { showEffects: true },
                });
            },
        });

    return (
        <>
            <p>
                <button
                    disabled={!canInteract || !account?.address}
                    onClick={() => sendPing()}
                >
                    Let them know you're here
                </button>
            </p>

            <ul>
                {offers?.data.map(({ data: offer }) => {
                    if (!offer) return null;
                    const { digest, objectId, version } = offer;
                    const contents = Message.parse(
                        fromB64((offer.bcs as { bcsBytes: string }).bcsBytes),
                    );

                    const value = {
                        contents,
                        objectRef: { digest, objectId, version },
                    };

                    return (
                        <li key={offer?.objectId}> 
                            <button
                                disabled={!canInteract || !account?.address}
                                onClick={() => onAccept && onAccept(value)}
                            >
                                Accept (from {offer.objectId})
                            </button>
                        </li>
                    );
                })}
            </ul>
        </>
    );

    async function sendPing() {
        // if (!zkLogin.address) return;
        if (!canInteract) return;
        if (!account?.address) return;

        setCanInteract(false);
        const tx = new Transaction();
        const address = tx.pure.string(account.address);

        tx.moveCall({
            target: `${packageId}::webrtc::ping`,
            arguments: [address],
        });

        const { digest } = await signAndExecuteTransaction({ transaction: tx });
        setCanInteract(true);
    }
}
