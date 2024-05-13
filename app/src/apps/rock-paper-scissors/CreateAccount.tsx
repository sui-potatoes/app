import { useSuiClient } from "@mysten/dapp-kit";
import { SuiTransactionBlockResponse } from "@mysten/sui.js/client";
import { useEnokiFlow } from "@mysten/enoki/react";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { RPS_PACKAGE_ID as PACKAGE_ID } from "../../constants";

type CreateParams = {
  onSuccess: (res: SuiTransactionBlockResponse) => void;
  onError: (res: any) => void;
};

export function CreateAccount({ onSuccess, onError }: CreateParams) {
  const client = useSuiClient();
  const flow = useEnokiFlow();

  return (
    <div className="connect">
      <button onClick={createAccount}>create account</button>
    </div>
  );

  async function createAccount() {
    const txb = new TransactionBlock();
    txb.moveCall({ target: `${PACKAGE_ID}::game::new_account` });
    const result = await flow.sponsorTransactionBlock({
      // @ts-ignore
      client,
      network: "testnet",
      transactionBlock: txb,
    });

    console.log(result);
    onSuccess;
    onError;

    // sendSignedTx({
    //   client,
    //   digest: result.digest,
    //   txBytes: result.bytes,
    //   transactionBlock: txb,
    //   onSuccess,
    //   onError,
    // });
  }
}
