import { useSuiClient } from "@mysten/dapp-kit";
import { SuiTransactionBlockResponse } from "@mysten/sui.js/client";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { PACKAGE_ID } from "../../constants";

type CreateParams = {
  onSuccess: (res: SuiTransactionBlockResponse) => void;
  onError: (res: any) => void;
};

export function CreateAccount({ onSuccess, onError }: CreateParams) {
  const client = useSuiClient();
  const flow = useEnokiFlow();
  const zkLogin = useZkLogin();
  // const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();

  return (
    <div className="connect">
      <button onClick={createAccount}>create account</button>
    </div>
  );

  async function createAccount() {
    // const keypair = await flow.getKeypair({ network: "testnet" });
    // console.log(keypair);
    const txb = new TransactionBlock();
    txb.moveCall({ target: `${PACKAGE_ID}::game::new_account` });
    const result = await flow.sponsorAndExecuteTransactionBlock({
      transactionBlock: txb,
      network: "testnet", // @ts-ignore
      client
    });

    console.log(result);

    // signAndExecute(
    //   {
    //     transactionBlock: txb,
    //     options: { showObjectChanges: true },
    //   },
    //   {
    //     onSuccess: (res) => onSuccess(res),
    //     onError: (error) => onError(error),
    //   },
    // );
  }
}
