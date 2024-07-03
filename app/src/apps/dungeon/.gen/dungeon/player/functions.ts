import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export function new_( tx: Transaction, size: bigint | TransactionArgument ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::new`, arguments: [ pure(tx, size, `u64`) ], }) }

export function moveDown( tx: Transaction, player: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::move_down`, arguments: [ obj(tx, player) ], }) }

export function moveLeft( tx: Transaction, player: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::move_left`, arguments: [ obj(tx, player) ], }) }

export function moveRight( tx: Transaction, player: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::move_right`, arguments: [ obj(tx, player) ], }) }

export function moveUp( tx: Transaction, player: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::move_up`, arguments: [ obj(tx, player) ], }) }

export function position( tx: Transaction, player: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::position`, arguments: [ obj(tx, player) ], }) }

export interface RepositionArgs { player: TransactionObjectInput; size: bigint | TransactionArgument }

export function reposition( tx: Transaction, args: RepositionArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::player::reposition`, arguments: [ obj(tx, args.player), pure(tx, args.size, `u64`) ], }) }
