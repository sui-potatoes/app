import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../index";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui/client";

/* ============================== GameMaster =============================== */

export function isGameMaster(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::game_master::GameMaster`; }

export interface GameMasterFields { id: ToField<UID> }

export type GameMasterReified = Reified< GameMaster, GameMasterFields >;

export class GameMaster implements StructClass { static readonly $typeName = `${PKG_V1}::game_master::GameMaster`; static readonly $numTypeParams = 0;

 readonly $typeName = GameMaster.$typeName;

 readonly $fullTypeName: `${typeof PKG_V1}::game_master::GameMaster`;

 readonly $typeArgs: [];

 readonly id: ToField<UID>

 private constructor(typeArgs: [], fields: GameMasterFields, ) { this.$fullTypeName = composeSuiType( GameMaster.$typeName, ...typeArgs ) as `${typeof PKG_V1}::game_master::GameMaster`; this.$typeArgs = typeArgs;

 this.id = fields.id; }

 static reified( ): GameMasterReified { return { typeName: GameMaster.$typeName, fullTypeName: composeSuiType( GameMaster.$typeName, ...[] ) as `${typeof PKG_V1}::game_master::GameMaster`, typeArgs: [ ] as [], reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => GameMaster.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => GameMaster.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => GameMaster.fromBcs( data, ), bcs: GameMaster.bcs, fromJSONField: (field: any) => GameMaster.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => GameMaster.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => GameMaster.fromSuiParsedData( content, ), fetch: async (client: SuiClient, id: string) => GameMaster.fetch( client, id, ), new: ( fields: GameMasterFields, ) => { return new GameMaster( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return GameMaster.reified() }

 static phantom( ): PhantomReified<ToTypeStr<GameMaster>> { return phantom(GameMaster.reified( )); } static get p() { return GameMaster.phantom() }

 static get bcs() { return bcs.struct("GameMaster", {

 id: UID.bcs

}) };

 static fromFields( fields: Record<string, any> ): GameMaster { return GameMaster.reified( ).new( { id: decodeFromFields(UID.reified(), fields.id) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): GameMaster { if (!isGameMaster(item.type)) { throw new Error("not a GameMaster type");

 }

 return GameMaster.reified( ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id) } ) }

 static fromBcs( data: Uint8Array ): GameMaster { return GameMaster.fromFields( GameMaster.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): GameMaster { return GameMaster.reified( ).new( { id: decodeFromJSONField(UID.reified(), field.id) } ) }

 static fromJSON( json: Record<string, any> ): GameMaster { if (json.$typeName !== GameMaster.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return GameMaster.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): GameMaster { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isGameMaster(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a GameMaster object`); } return GameMaster.fromFieldsWithTypes( content ); }

 static async fetch( client: SuiClient, id: string ): Promise<GameMaster> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching GameMaster object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isGameMaster(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a GameMaster object`); }
 return GameMaster.fromBcs( fromB64(res.data.bcs.bcsBytes) ); }

 }
