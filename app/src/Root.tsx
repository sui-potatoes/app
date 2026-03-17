// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

export default function Root() {
    return (
        <div className="flex flex-col justify-center h-[80vh] max-w-md">
            <h1
                className="text-3xl font-light tracking-widest uppercase mb-2"
                style={{ color: "var(--accent-color)" }}
            >
                Pot8os
            </h1>
            <p className="text-sm" style={{ color: "var(--text-secondary)" }}>
                On-chain games and open-source Move libraries on Sui.
            </p>
            <div
                className="mt-6"
                style={{
                    width: "60px",
                    height: "1px",
                    background: "var(--border-color)",
                }}
            />
        </div>
    );
}
