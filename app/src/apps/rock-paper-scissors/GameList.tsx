import { SuiObjectData } from "@mysten/sui/client";
import { bcs } from "@mysten/sui/bcs";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { RPS_PACKAGE_ID as PACKAGE_ID } from "../../constants";
import { fromB58 } from "@mysten/bcs";
import { Game } from "./ActiveGame";
import { fromB64 } from "@mysten/sui/utils";
import { Transaction } from "@mysten/sui/transactions";
import { useEnokiFlow } from "@mysten/enoki/react";

type Params = {
    account: SuiObjectData;
    onJoin?: (digest: string) => {};
};

export const NewGameEvent = bcs.struct("NewGame", {
    matchId: bcs.Address,
    rounds: bcs.u8(),
});

export function GameList({ account, onJoin }: Params) {
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const { data: events, error } = useSuiClientQuery("queryEvents", {
        limit: 50,
        query: { MoveEventType: `${PACKAGE_ID}::game::NewGame` },
        order: "descending",
    });

    const { data: active, error: objectsError } = useSuiClientQuery(
        "multiGetObjects",
        {
            ids: events
                ? events.data.map(
                      (evt) => NewGameEvent.parse(fromB58(evt.bcs)).matchId,
                  )
                : [],
            options: { showBcs: true },
        },
    );

    if (!events || !active) return <></>;
    if (error) return <div>Error: {error.message}</div>;
    if (objectsError) return <div>Error: {objectsError.message}</div>;

    const vacant = active!
        .map((e) => (e.data?.bcs as { bcsBytes: string }).bcsBytes)
        .map((e) => Game.parse(fromB64(e)))
        .filter((e) => e.guest === null);

    return (
        <>
            {vacant && vacant.length > 0 && (
                <div className="connect">
                    <button onClick={joinRandom}>Join ({vacant.length})</button>
                </div>
            )}
        </>
    );

    /** Join a random session from the vacant list (may fail if someone took the spot) */
    async function joinRandom() {
        vacant?.sort(() => Math.random() - 0.5);
        const tx = new Transaction();
        tx.moveCall({
            target: `${PACKAGE_ID}::game::join_game`,
            arguments: [tx.objectRef(account), tx.object(vacant[0].id)],
        });

        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        console.log(result);
        onJoin && onJoin(result.digest);
    }
}
