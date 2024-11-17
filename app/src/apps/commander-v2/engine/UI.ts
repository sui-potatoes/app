// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export type UIEvents = {
    click: { id: string };
    button: { id: string };
};

export class UI extends THREE.EventDispatcher<UIEvents> {
    public readonly domElement: HTMLElement;
    public readonly leftPanel: HTMLElement;
    public readonly rightPanel: HTMLElement;
    public readonly version: string = "v0.0.2-secret-sauce-tracer";

    constructor(domElement: HTMLElement) {
        super();
        this.domElement = domElement;
        this.leftPanel = this.createLeftPanel();
        this.rightPanel = this.createRightPanel();

        this.domElement.append(
            this.leftPanel,
            this.rightPanel,
            this.createVersionTag()
        );
    }

    public createButton(text: string) {
        const div = document.createElement("div");
        div.classList.add("action-button");
        div.textContent = text;
        div.onclick = () => this.dispatchEvent({ type: "button", id: text });
        return div;
    }

    private createRightPanel() {
        const panel = document.createElement("div");
        panel.id = "panel-right";
        panel.className = "fixed h-full right-0 top-0 flex justify-end flex-col text-center bg-black";
        return panel;
    }

    private createLeftPanel() {
        const container = document.createElement("div");
        container.id = "panel-left";
        container.className = "fixed h-full left-0 top-0 flex justify-center flex-col text-center bg-black";
        container.style.width = '100px';
        return container;
    }

    private createVersionTag() {
        const tag = document.createElement("div");
        tag.className = "fixed bottom-0 right-0 p-2 text-xs text-gray-500 lowercase";
        tag.textContent = this.version;
        return tag;
    }
}
