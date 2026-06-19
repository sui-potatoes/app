// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// @ts-expect-error: markdown imports are untyped (vite-plugin-react-markdown)
import Libraries from "./libraries.md";
import "./libraries.css";

export default function App() {
    return (
        <div className="flex justify-center normal-case py-8 md:py-16">
            <div className="markdown max-w-screen-sm w-full">
                <Libraries />
            </div>
        </div>
    );
}
