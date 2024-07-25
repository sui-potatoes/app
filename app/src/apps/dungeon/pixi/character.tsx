import { Assets, Spritesheet, SpritesheetData, SpritesheetFrameData } from "pixi.js";

const CHARACTER_SPRITE = "/character.png"}

export async function loadCharacter() {

    // the dimensions of the character sprite
    // contains 6 rows, 4 columns, and 24 frames
    // 352 × 672

    Assets.add({

            frames: {
                "character": {
                    frame: {
                        x: 0,
                        y: 0,
                        width: 88,
                        height: 168
                    }
                },
                "character-attack": {
                    frame: {
                        x: 88,
                        y: 0,
                        width: 88,
                        height: 168
                    }
                },
                "character-die": {
                    frame: {
                        x: 176,
                        y: 0,
                        width: 88,
                        height: 168
                    }
                },
            },
            }
    });

    // const asset = await Assets.load(CHARACTER_SPRITE);
    // return new Spritesheet(asset, FRAME_DATA);
}
