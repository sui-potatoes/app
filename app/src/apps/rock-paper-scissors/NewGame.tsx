import { TransactionBlock } from "@mysten/sui.js/transactions";
import { RPS_PACKAGE_ID as PACKAGE_ID } from "../../constants";
import { SuiTransactionBlockResponse } from "@mysten/sui.js/client";
import { SuiObjectRef } from "@mysten/sui.js/bcs";
import { useEnokiFlow } from "@mysten/enoki/react";
import { useSuiClient } from "@mysten/dapp-kit";
import { useState } from "react";

type CreateParams = {
  onSuccess: (res: SuiTransactionBlockResponse) => void;
  account: SuiObjectRef;
};

export function NewGame({ onSuccess, account }: CreateParams) {
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
    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${PACKAGE_ID}::game::new_game`,
      arguments: [txb.objectRef(account), txb.pure.u8(3)],
    });
    setPending(true);
    const result = await flow.sponsorAndExecuteTransactionBlock({
      transactionBlock: txb,
      network: "testnet", // @ts-ignore
      client,
    });
    console.log(result);
    setPending(false);
  }
}
