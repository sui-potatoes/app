import * as gameMaster from "./game-master/structs";
import * as game from "./game/structs";
import * as player from "./player/structs";
import * as point from "./point/structs";
import * as room from "./room/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) { loader.register(point.Point);
loader.register(room.Room);
loader.register(player.Inventory);
loader.register(player.Player);
loader.register(gameMaster.GameMaster);
loader.register(game.Game);
loader.register(game.Registry);
 }
