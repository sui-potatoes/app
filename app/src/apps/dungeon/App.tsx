// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Application, Assets, Sprite } from "pixi.js";
import { useEffect, useMemo, useRef, useState } from "react";

export function App() {
    // The application will create a renderer using WebGL, if possible,
    // with a fallback to a canvas render. It will also setup the ticker
    // and the root stage PIXI.Container
    const app = useMemo(() => new Application(), []);
    const canvas = useRef<HTMLCanvasElement>();
    // const canvas = useMemo<HTMLCanvasElement>(() => <canvas height={600} width={800} />, [app]);
    const [initialized, setInitialized] = useState(false);

    useEffect(() => {
        app.init({
            width: 800,
            height: 600,
            hello: true,
            canvas: document.createElement("canvas"),
        })
            .then(async () => {
                const texture = await Assets.load(r
                    "https://pixijs.com/assets/bunny.png",
                );

                const bunny = new Sprite(texture);

                bunny.onclick = () => {
                    console.log("click");
                    bunny.scale.x *= 1.25;
                };

                bunny.width = 100;
                bunny.height = 100;

                // Setup the position of the bunny
                bunny.x = app.renderer.width / 2;
                bunny.y = app.renderer.height / 2;

                // Rotate around the center
                bunny.anchor.x = 0.5;
                bunny.anchor.y = 0.5;

                // Add the bunny to the scene we are building
                app.stage.addChild(bunny);

                // Listen for frame updates
                app.ticker.add(() => {
                    // each frame we spin the bunny around a bit
                    bunny.rotation += 0.01;
                });
            })
            .then(() => {
                canvas.current = app.canvas;
                setInitialized(true);
            });
    }, [app]);

    return (
        <div
            ref={(div) => {
                if (div && canvas.current && div.children.length === 0) {
                    div.appendChild(canvas.current);
                }
            }}
        ></div>
    );
}
