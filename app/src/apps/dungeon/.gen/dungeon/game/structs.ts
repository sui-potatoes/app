import * as reified from "../../_framework/reified";
import {UID} from "../../_dependencies/source/0x2/object/structs";
import {Table} from "../../_dependencies/source/0x2/table/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../index";
import {Player} from "../player/structs";
import {Room} from "../room/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui/client";

/* ============================== Game =============================== */

export function isGame(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::game::Game`; }

export interface GameFields { id: ToField<UID>; level: ToField<"u8">; difficultyScalar: ToField<"u64">; room: ToField<Room>; player: ToField<Player> }

export type GameReified = Reified< Game, GameFields >;

export class Game implements StructClass { static readonly $typeName = `${PKG_V1}::game::Game`; static readonly $numTypeParams = 0;

 readonly $typeName = Game.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::game::Game`;

 readonly $typeArgs: [];

 readonly id: ToField<UID>; readonly level: ToField<"u8">; readonly difficultyScalar: ToField<"u64">; readonly room: ToField<Room>; readonly player: ToField<Player>

 private constructor(typeArgs: [], fields: GameFields, ) { this.$fullTypeName = composeSuiType( Game.$typeName, ...typeArgs ) as `${typeof PKG_V1}::game::Game`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.level = fields.level;; this.difficultyScalar = fields.difficultyScalar;; this.room = fields.room;; this.player = fields.player; }

 static reified( ): GameReified { return { typeName: Game.$typeName, fullTypeName: composeSuiType( Game.$typeName, ...[] ) as `${typeof PKG_V1}::game::Game`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Game.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Game.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Game.fromBcs( data, ), bcs: Game.bcs, fromJSONField: (field: any) => Game.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Game.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Game.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Game.fetch( client, id, ), new: ( fields: GameFields, ) => { return new Game( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Game.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Game>> { return phantom(Game.reified( )); } static get p() { return Game.phantom() }

 static get bcs() { return bcs.struct("Game", {

 id: UID.bcs, level: bcs.u8(), difficulty_scalar: bcs.u64(), room: Room.bcs, player: Player.bcs

}) };

 static fromFields( fields: Record<string, any> ): Game { return Game.reified( ).new( { id: decodeFromFields(UID.reified(), fields.id), level: decodeFromFields("u8", fields.level), difficultyScalar: decodeFromFields("u64", fields.difficulty_scalar), room: decodeFromFields(Room.reified(), fields.room), player: decodeFromFields(Player.reified(), fields.player) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Game { if (!isGame(item.type)) { throw new Error("not a Game type");

 }

 return Game.reified( ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), level: decodeFromFieldsWithTypes("u8", item.fields.level), difficultyScalar: decodeFromFieldsWithTypes("u64", item.fields.difficulty_scalar), room: decodeFromFieldsWithTypes(Room.reified(), item.fields.room), player: decodeFromFieldsWithTypes(Player.reified(), item.fields.player) } ) }

 static fromBcs( data: Uint8Array ): Game { return Game.fromFields( Game.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,level: this.level,difficultyScalar: this.difficultyScalar.toString(),room: this.room.toJSONField(),player: this.player.toJSONField(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Game { return Game.reified( ).new( { id: decodeFromJSONField(UID.reified(), field.id), level: decodeFromJSONField("u8", field.level), difficultyScalar: decodeFromJSONField("u64", field.difficultyScalar), room: decodeFromJSONField(Room.reified(), field.room), player: decodeFromJSONField(Player.reified(), field.player) } ) }

 static fromJSON( json: Record<string, any> ): Game { if (json.$typeName !== Game.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Game.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Game { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isGame(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Game object`); } return Game.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Game> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Game object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isGame(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Game object`); }
 return Game.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }

/* ============================== Registry =============================== */

export function isRegistry(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::game::Registry`; }

export interface RegistryFields { id: ToField<UID>; users: ToField<Table<"address", "address">>; difficultyScalar: ToField<"u64"> }

export type RegistryReified = Reified< Registry, RegistryFields >;

export class Registry implements StructClass { static readonly $typeName = `${PKG_V1}::game::Registry`; static readonly $numTypeParams = 0;

 readonly $typeName = Registry.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::game::Registry`;

 readonly $typeArgs: [];

 readonly id: ToField<UID>; readonly users: ToField<Table<"address", "address">>; readonly difficultyScalar: ToField<"u64">

 private constructor(typeArgs: [], fields: RegistryFields, ) { this.$fullTypeName = composeSuiType( Registry.$typeName, ...typeArgs ) as `${typeof PKG_V1}::game::Registry`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.users = fields.users;; this.difficultyScalar = fields.difficultyScalar; }

 static reified( ): RegistryReified { return { typeName: Registry.$typeName, fullTypeName: composeSuiType( Registry.$typeName, ...[] ) as `${typeof PKG_V1}::game::Registry`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Registry.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Registry.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Registry.fromBcs( data, ), bcs: Registry.bcs, fromJSONField: (field: any) => Registry.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Registry.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Registry.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Registry.fetch( client, id, ), new: ( fields: RegistryFields, ) => { return new Registry( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Registry.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Registry>> { return phantom(Registry.reified( )); } static get p() { return Registry.phantom() }

 static get bcs() { return bcs.struct("Registry", {

 id: UID.bcs, users: Table.bcs, difficulty_scalar: bcs.u64()

}) };

 static fromFields( fields: Record<string, any> ): Registry { return Registry.reified( ).new( { id: decodeFromFields(UID.reified(), fields.id), users: decodeFromFields(Table.reified(reified.phantom("address"), reified.phantom("address")), fields.users), difficultyScalar: decodeFromFields("u64", fields.difficulty_scalar) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Registry { if (!isRegistry(item.type)) { throw new Error("not a Registry type");

 }

 return Registry.reified( ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), users: decodeFromFieldsWithTypes(Table.reified(reified.phantom("address"), reified.phantom("address")), item.fields.users), difficultyScalar: decodeFromFieldsWithTypes("u64", item.fields.difficulty_scalar) } ) }

 static fromBcs( data: Uint8Array ): Registry { return Registry.fromFields( Registry.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,users: this.users.toJSONField(),difficultyScalar: this.difficultyScalar.toString(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Registry { return Registry.reified( ).new( { id: decodeFromJSONField(UID.reified(), field.id), users: decodeFromJSONField(Table.reified(reified.phantom("address"), reified.phantom("address")), field.users), difficultyScalar: decodeFromJSONField("u64", field.difficultyScalar) } ) }

 static fromJSON( json: Record<string, any> ): Registry { if (json.$typeName !== Registry.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Registry.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Registry { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isRegistry(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Registry object`); } return Registry.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Registry> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Registry object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isRegistry(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Registry object`); }
 return Registry.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }
