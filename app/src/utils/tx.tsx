import {
  ExecuteTransactionBlockParams,
  SuiClient,
  SuiTransactionBlockResponse,
} from "@mysten/sui.js/client";
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
