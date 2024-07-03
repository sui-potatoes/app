import * as package_1 from "../_dependencies/source/0x1/init";
import * as package_2 from "../_dependencies/source/0x2/init";
import * as package_e3bd90fbe8cfdcc861babda8690c44656083460cbf461a2c526e12a4856298dc from "../dungeon/init";
import {structClassLoaderSource as structClassLoader} from "./loader";

let initialized = false; export function initLoaderIfNeeded() { if (initialized) { return }; initialized = true; package_1.registerClasses(structClassLoader);
package_2.registerClasses(structClassLoader);
package_e3bd90fbe8cfdcc861babda8690c44656083460cbf461a2c526e12a4856298dc.registerClasses(structClassLoader);
 }
