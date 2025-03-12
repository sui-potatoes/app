// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// @ts-expect-error
import Libraries from "./libraries.md";
import "./libraries.css";

export default function App() {
    return (
        <div className="md:flex justify-center items-center normal-case">
            <div className="markdown max-w-screen-sm">
                <Libraries />
            </div>
        </div>
    );
}
