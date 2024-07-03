import * as reified from "../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../index";
import {Point} from "../point/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui/client";

/* ============================== Room =============================== */

export function isRoom(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::room::Room`; }

export interface RoomFields { size: ToField<"u64">; exit: ToField<Point>; lifes: ToField<Vector<Point>> }

export type RoomReified = Reified< Room, RoomFields >;

export class Room implements StructClass { static readonly $typeName = `${PKG_V1}::room::Room`; static readonly $numTypeParams = 0;

 readonly $typeName = Room.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::room::Room`;

 readonly $typeArgs: [];

 readonly size: ToField<"u64">; readonly exit: ToField<Point>; readonly lifes: ToField<Vector<Point>>

 private constructor(typeArgs: [], fields: RoomFields, ) { this.$fullTypeName = composeSuiType( Room.$typeName, ...typeArgs ) as `${typeof PKG_V1}::room::Room`; this.$typeArgs = typeArgs;

 this.size = fields.size;; this.exit = fields.exit;; this.lifes = fields.lifes; }

 static reified( ): RoomReified { return { typeName: Room.$typeName, fullTypeName: composeSuiType( Room.$typeName, ...[] ) as `${typeof PKG_V1}::room::Room`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Room.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Room.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Room.fromBcs( data, ), bcs: Room.bcs, fromJSONField: (field: any) => Room.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Room.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Room.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Room.fetch( client, id, ), new: ( fields: RoomFields, ) => { return new Room( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Room.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Room>> { return phantom(Room.reified( )); } static get p() { return Room.phantom() }

 static get bcs() { return bcs.struct("Room", {

 size: bcs.u64(), exit: Point.bcs, lifes: bcs.vector(Point.bcs)

}) };

 static fromFields( fields: Record<string, any> ): Room { return Room.reified( ).new( { size: decodeFromFields("u64", fields.size), exit: decodeFromFields(Point.reified(), fields.exit), lifes: decodeFromFields(reified.vector(Point.reified()), fields.lifes) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Room { if (!isRoom(item.type)) { throw new Error("not a Room type");

 }

 return Room.reified( ).new( { size: decodeFromFieldsWithTypes("u64", item.fields.size), exit: decodeFromFieldsWithTypes(Point.reified(), item.fields.exit), lifes: decodeFromFieldsWithTypes(reified.vector(Point.reified()), item.fields.lifes) } ) }

 static fromBcs( data: Uint8Array ): Room { return Room.fromFields( Room.bcs.parse(data) ) }

 toJSONField() { return {

 size: this.size.toString(),exit: this.exit.toJSONField(),lifes: fieldToJSON<Vector<Point>>(`vector<${Point.$typeName}>`, this.lifes),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Room { return Room.reified( ).new( { size: decodeFromJSONField("u64", field.size), exit: decodeFromJSONField(Point.reified(), field.exit), lifes: decodeFromJSONField(reified.vector(Point.reified()), field.lifes) } ) }

 static fromJSON( json: Record<string, any> ): Room { if (json.$typeName !== Room.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Room.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Room { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isRoom(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Room object`); } return Room.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Room> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Room object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isRoom(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Room object`); }
 return Room.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }
