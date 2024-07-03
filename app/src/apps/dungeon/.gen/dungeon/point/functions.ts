import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function x( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::point::x`, arguments: [ obj(tx, self) ], }) }

export interface NewArgs { x: bigint | TransactionArgument; y: bigint | TransactionArgument }

export function new_( tx: Transaction, args: NewArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::point::new`, arguments: [ pure(tx, args.x, `u64`), pure(tx, args.y, `u64`) ], }) }

export function y( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::point::y`, arguments: [ obj(tx, self) ], }) }
