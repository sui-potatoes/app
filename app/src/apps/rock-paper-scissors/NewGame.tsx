import { Transaction } from "@mysten/sui/transactions";
import { RPS_PACKAGE_ID as PACKAGE_ID } from "../../constants";
import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import type { Inputs } from "@mysten/sui/transactions";
import { useEnokiFlow } from "@mysten/enoki/react";
import { useSuiClient } from "@mysten/dapp-kit";
import { useState } from "react";

type CreateParams = {
    onSuccess: (res: SuiTransactionBlockResponse) => void;
    account: Parameters<(typeof Inputs)["ObjectRef"]>[0];
};

export function NewGame({ account }: CreateParams) {
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const [pending, setPending] = useState(false);

    return (
        <div className="connect">
            <button disabled={pending} onClick={newGame}>
                new game
            </button>
        </div>
    );

    async function newGame() {
        const tx = new Transaction();
        tx.moveCall({
            target: `${PACKAGE_ID}::game::new_game`,
            arguments: [tx.objectRef(account), tx.pure.u8(3)],
        });
        setPending(true);
        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        console.log(result);
        setPending(false);
    }
}
