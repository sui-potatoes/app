import * as reified from "../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../index";
import {Point} from "../point/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui/client";

/* ============================== Inventory =============================== */

export function isInventory(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::player::Inventory`; }

export interface InventoryFields { lifes: ToField<"u8"> }

export type InventoryReified = Reified< Inventory, InventoryFields >;

export class Inventory implements StructClass { static readonly $typeName = `${PKG_V1}::player::Inventory`; static readonly $numTypeParams = 0;

 readonly $typeName = Inventory.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::player::Inventory`;

 readonly $typeArgs: [];

 readonly lifes: ToField<"u8">

 private constructor(typeArgs: [], fields: InventoryFields, ) { this.$fullTypeName = composeSuiType( Inventory.$typeName, ...typeArgs ) as `${typeof PKG_V1}::player::Inventory`; this.$typeArgs = typeArgs;

 this.lifes = fields.lifes; }

 static reified( ): InventoryReified { return { typeName: Inventory.$typeName, fullTypeName: composeSuiType( Inventory.$typeName, ...[] ) as `${typeof PKG_V1}::player::Inventory`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Inventory.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Inventory.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Inventory.fromBcs( data, ), bcs: Inventory.bcs, fromJSONField: (field: any) => Inventory.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Inventory.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Inventory.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Inventory.fetch( client, id, ), new: ( fields: InventoryFields, ) => { return new Inventory( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Inventory.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Inventory>> { return phantom(Inventory.reified( )); } static get p() { return Inventory.phantom() }

 static get bcs() { return bcs.struct("Inventory", {

 lifes: bcs.u8()

}) };

 static fromFields( fields: Record<string, any> ): Inventory { return Inventory.reified( ).new( { lifes: decodeFromFields("u8", fields.lifes) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Inventory { if (!isInventory(item.type)) { throw new Error("not a Inventory type");

 }

 return Inventory.reified( ).new( { lifes: decodeFromFieldsWithTypes("u8", item.fields.lifes) } ) }

 static fromBcs( data: Uint8Array ): Inventory { return Inventory.fromFields( Inventory.bcs.parse(data) ) }

 toJSONField() { return {

 lifes: this.lifes,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Inventory { return Inventory.reified( ).new( { lifes: decodeFromJSONField("u8", field.lifes) } ) }

 static fromJSON( json: Record<string, any> ): Inventory { if (json.$typeName !== Inventory.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Inventory.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Inventory { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isInventory(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Inventory object`); } return Inventory.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Inventory> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Inventory object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isInventory(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Inventory object`); }
 return Inventory.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }

/* ============================== Player =============================== */

export function isPlayer(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::player::Player`; }

export interface PlayerFields { position: ToField<Point>; moves: ToField<Vector<"u64">> }

export type PlayerReified = Reified< Player, PlayerFields >;

export class Player implements StructClass { static readonly $typeName = `${PKG_V1}::player::Player`; static readonly $numTypeParams = 0;

 readonly $typeName = Player.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::player::Player`;

 readonly $typeArgs: [];

 readonly position: ToField<Point>; readonly moves: ToField<Vector<"u64">>

 private constructor(typeArgs: [], fields: PlayerFields, ) { this.$fullTypeName = composeSuiType( Player.$typeName, ...typeArgs ) as `${typeof PKG_V1}::player::Player`; this.$typeArgs = typeArgs;

 this.position = fields.position;; this.moves = fields.moves; }

 static reified( ): PlayerReified { return { typeName: Player.$typeName, fullTypeName: composeSuiType( Player.$typeName, ...[] ) as `${typeof PKG_V1}::player::Player`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Player.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Player.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Player.fromBcs( data, ), bcs: Player.bcs, fromJSONField: (field: any) => Player.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Player.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Player.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Player.fetch( client, id, ), new: ( fields: PlayerFields, ) => { return new Player( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Player.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Player>> { return phantom(Player.reified( )); } static get p() { return Player.phantom() }

 static get bcs() { return bcs.struct("Player", {

 position: Point.bcs, moves: bcs.vector(bcs.u64())

}) };

 static fromFields( fields: Record<string, any> ): Player { return Player.reified( ).new( { position: decodeFromFields(Point.reified(), fields.position), moves: decodeFromFields(reified.vector("u64"), fields.moves) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Player { if (!isPlayer(item.type)) { throw new Error("not a Player type");

 }

 return Player.reified( ).new( { position: decodeFromFieldsWithTypes(Point.reified(), item.fields.position), moves: decodeFromFieldsWithTypes(reified.vector("u64"), item.fields.moves) } ) }

 static fromBcs( data: Uint8Array ): Player { return Player.fromFields( Player.bcs.parse(data) ) }

 toJSONField() { return {

 position: this.position.toJSONField(),moves: fieldToJSON<Vector<"u64">>(`vector<u64>`, this.moves),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Player { return Player.reified( ).new( { position: decodeFromJSONField(Point.reified(), field.position), moves: decodeFromJSONField(reified.vector("u64"), field.moves) } ) }

 static fromJSON( json: Record<string, any> ): Player { if (json.$typeName !== Player.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Player.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Player { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isPlayer(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Player object`); } return Player.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Player> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Player object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isPlayer(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Player object`); }
 return Player.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }
