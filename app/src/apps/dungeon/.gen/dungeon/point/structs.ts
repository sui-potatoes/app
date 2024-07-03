import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../index";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui/client";

/* ============================== Point =============================== */

export function isPoint(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::point::Point`; }

export interface PointFields { pos0: ToField<"u64">; pos1: ToField<"u64"> }

export type PointReified = Reified< Point, PointFields >;

export class Point implements StructClass { static readonly $typeName = `${PKG_V1}::point::Point`; static readonly $numTypeParams = 0;

 readonly $typeName = Point.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::point::Point`;

 readonly $typeArgs: [];

 readonly pos0: ToField<"u64">; readonly pos1: ToField<"u64">

 private constructor(typeArgs: [], fields: PointFields, ) { this.$fullTypeName = composeSuiType( Point.$typeName, ...typeArgs ) as `${typeof PKG_V1}::point::Point`; this.$typeArgs = typeArgs;

 this.pos0 = fields.pos0;; this.pos1 = fields.pos1; }

 static reified( ): PointReified { return { typeName: Point.$typeName, fullTypeName: composeSuiType( Point.$typeName, ...[] ) as `${typeof PKG_V1}::point::Point`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => Point.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => Point.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => Point.fromBcs( data, ), bcs: Point.bcs, fromJSONField: (field: any) => Point.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => Point.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => Point.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => Point.fetch( client, id, ), new: ( fields: PointFields, ) => { return new Point( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return Point.reified() }

 static phantom( ): PhantomReified<ToTypeStr<Point>> { return phantom(Point.reified( )); } static get p() { return Point.phantom() }

 static get bcs() { return bcs.struct("Point", {

 pos0: bcs.u64(), pos1: bcs.u64()

}) };

 static fromFields( fields: Record<string, any> ): Point { return Point.reified( ).new( { pos0: decodeFromFields("u64", fields.pos0), pos1: decodeFromFields("u64", fields.pos1) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): Point { if (!isPoint(item.type)) { throw new Error("not a Point type");

 }

 return Point.reified( ).new( { pos0: decodeFromFieldsWithTypes("u64", item.fields.pos0), pos1: decodeFromFieldsWithTypes("u64", item.fields.pos1) } ) }

 static fromBcs( data: Uint8Array ): Point { return Point.fromFields( Point.bcs.parse(data) ) }

 toJSONField() { return {

 pos0: this.pos0.toString(),pos1: this.pos1.toString(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): Point { return Point.reified( ).new( { pos0: decodeFromJSONField("u64", field.pos0), pos1: decodeFromJSONField("u64", field.pos1) } ) }

 static fromJSON( json: Record<string, any> ): Point { if (json.$typeName !== Point.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return Point.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): Point { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isPoint(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a Point object`); } return Point.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<Point> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching Point object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isPoint(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a Point object`); }
 return Point.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }
