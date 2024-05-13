import {
  ExecuteTransactionBlockParams,
  SuiClient,
  SuiTransactionBlockResponse,
} from "@mysten/sui.js/client";
import { bcs } from "@mysten/sui.js/bcs";
import { fromB64 } from "@mysten/bcs";
// import { TransactionBlock } from "@mysten/sui.js/transactions";



export type ExecuteSignedTransactionBlockParams = {
  client: SuiClient;
  txBytes: string;
  signature: string;
  transactionBlock: any;
  options?: ExecuteTransactionBlockParams;
  onSuccess?: (res: SuiTransactionBlockResponse) => void;
  onError?: (res: string[]) => void;
};

/**
 * Sends a signed transaction to the blockchain. Intended to be used together
 * with the Enoki `flow.sponsorTransactionBlock` function.
 */
export async function sendSignedTx({
  client,
  txBytes,
  signature,
  transactionBlock,
  options,
  onSuccess,
  onError,
}: ExecuteSignedTransactionBlockParams) {

  // console.log(bcs.TransactionData.parse(fromB64(txBytes)))
  // const result = await client.executeTransactionBlock({
  //   transactionBlock,
  //   // signature,
  //   options: {
  //     showObjectChanges: true,
  //     showEffects: true,
  //     ...options,
  //   },
  // });

  // if (result.errors) {
  //   onError && onError(result.errors);
  // }

  // if (!result.errors) {
  //   onSuccess && onSuccess(result);
  // }
}
