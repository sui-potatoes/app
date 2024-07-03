import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function new_( tx: Transaction, size: bigint | TransactionArgument ) { return tx.moveCall({ target: `${PUBLISHED_AT}::room::new`, arguments: [ pure(tx, size, `u64`) ], }) }

export function size( tx: Transaction, room: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::room::size`, arguments: [ obj(tx, room) ], }) }

export interface IsExitArgs { room: TransactionObjectInput; point: TransactionObjectInput }

export function isExit( tx: Transaction, args: IsExitArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::room::is_exit`, arguments: [ obj(tx, args.room), obj(tx, args.point) ], }) }
