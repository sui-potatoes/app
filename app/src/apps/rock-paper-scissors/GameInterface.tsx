import { SuiObjectData } from "@mysten/sui/client";
import { bcs } from "@mysten/sui/bcs";
import { fromB64 } from "@mysten/sui/utils";
import { NewGame } from "./NewGame";
import { ActiveGame } from "./ActiveGame";
import { GameList } from "./GameList";

type Params = {
    account: SuiObjectData;
};

export const Account = bcs.struct("Account", {
    address: bcs.Address,
    currentGame: bcs.option(bcs.Address),
    wins: bcs.u32(),
    losses: bcs.u32(),
});

export function GameInterface({ account }: Params) {
    const accData = Account.parse(
        fromB64((account.bcs! as { bcsBytes: string }).bcsBytes),
    );

    return (
        <>
            {accData.currentGame ? (
                <ActiveGame matchId={accData.currentGame} account={account} />
            ) : (
                <>
                    <NewGame account={account} onSuccess={() => {}} />
                    <GameList account={account} />
                </>
            )}
        </>
    );
}
