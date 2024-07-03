import {PUBLISHED_AT} from "..";
import {obj, pure} from "../../_framework/util";
import {Transaction, TransactionArgument, TransactionObjectInput} from "@mysten/sui/transactions";

export interface NewArgs { registry: TransactionObjectInput; size: bigint | TransactionArgument }

export function new_( tx: Transaction, args: NewArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::new`, arguments: [ obj(tx, args.registry), pure(tx, args.size, `u64`) ], }) }

export function destroy( tx: Transaction, game: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::destroy`, arguments: [ obj(tx, game) ], }) }

export function init( tx: Transaction, ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::init`, arguments: [ ], }) }

export function difficultyScalar( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::difficulty_scalar`, arguments: [ obj(tx, self) ], }) }

export function level( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::level`, arguments: [ obj(tx, self) ], }) }

export function lose( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::lose`, arguments: [ obj(tx, self) ], }) }

export interface MakeMoveArgs { game: TransactionObjectInput; gen: TransactionObjectInput; dir: bigint | TransactionArgument }

export function makeMove( tx: Transaction, args: MakeMoveArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::make_move`, arguments: [ obj(tx, args.game), obj(tx, args.gen), pure(tx, args.dir, `u64`) ], }) }

export interface MoveArgs { game: TransactionObjectInput; random: TransactionObjectInput; dir: bigint | TransactionArgument }

export function move( tx: Transaction, args: MoveArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::move`, arguments: [ obj(tx, args.game), obj(tx, args.random), pure(tx, args.dir, `u64`) ], }) }

export interface SetDifficultyScalarArgs { self: TransactionObjectInput; gameMaster: TransactionObjectInput; difficultyScalar: bigint | TransactionArgument }

export function setDifficultyScalar( tx: Transaction, args: SetDifficultyScalarArgs ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::set_difficulty_scalar`, arguments: [ obj(tx, args.self), obj(tx, args.gameMaster), pure(tx, args.difficultyScalar, `u64`) ], }) }

export function win( tx: Transaction, self: TransactionObjectInput ) { return tx.moveCall({ target: `${PUBLISHED_AT}::game::win`, arguments: [ obj(tx, self) ], }) }
