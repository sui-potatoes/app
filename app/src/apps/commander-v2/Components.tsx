// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect } from "react";
import { NavLink } from "react-router-dom";

export function Footer({ to, text }: { to?: string; text?: string }) {
    return (
        <div className="fixed w-full flex justify-between bottom-0 left-0 p-10 flex text-lg">
            <NavLink to={to || ".."} className="menu-control back-button">
                {text || "Back"}
            </NavLink>
        </div>
    );
}

export function TextInput({}: { value: boolean; onChange: (v: string) => void }) {
    return <input type="text" />;
}

export function Slider({ value, maxValue }: { value: number; maxValue: number }) {
    const percentValue = (Math.abs(value / maxValue) * 100).toFixed(0);
    return (
        <div className="slider-outer">
            <div
                className={(value >= 0 && "slider-inner") || "slider-inner-negative"}
                style={{ width: percentValue + "%" }}
            ></div>
            <div className="slider-value">{value}</div>
        </div>
    );
}

export function SliderRange({ range, maxValue }: { range: [number, number]; maxValue: number }) {
    const minVal = Math.min(...range);
    const maxVal = Math.max(...range);

    const percentValue = (Math.abs(minVal / maxValue) * 100).toFixed(0);
    const diffPercent = (((maxVal - minVal) / maxValue) * 100).toFixed(0);
    return (
        <div className="slider-outer">
            <div
                className={(minVal >= 0 && "slider-inner") || "slider-inner-negative"}
                style={{ width: percentValue + "%" }}
            ></div>
            <div
                className="slider-inner"
                style={{
                    width: diffPercent + "%",
                    left: percentValue + "%",
                    background: "rgba(128,128,128,0.5)",
                    borderRight: "3px solid grey",
                }}
            ></div>
            <div className="slider-value">
                {minVal}-{maxVal}
            </div>
        </div>
    );
}

export function YesOrNo({ value, onChange }: { value: boolean; onChange: (v: boolean) => void }) {
    return (
        <div className="flex justify-between">
            <div
                className={"yes-no" + (value ? " selected" : "")}
                onClick={() => !value && onChange(true)}
            >
                YES
            </div>
            <div
                className={"yes-no" + (!value ? " selected" : "")}
                onClick={() => value && onChange(false)}
            >
                NO
            </div>
        </div>
    );
}

export function SuinsModal({ show, onClose }: { show: boolean; onClose: () => void }) {
    useEffect(() => {
        if (show == true) {
            document.getElementById("suins")?.focus();
        }
    }, [show]);

    return (
        <div
            className="absolute h-screen w-full bg-black bg-opacity-50"
            style={{ display: show ? "flex" : "none" }}
            onClick={onClose}
        >
            <div
                className="m-auto border border-grey p-10 w-2xl"
                onClick={(e) => e.stopPropagation()}
            >
                <h1 className="text-xl uppercase mb-10 text-center">Choose an in-game name</h1>
                <input
                    id="suins"
                    type="text"
                    className="bg-black w-full h-10 text-lg text-white border border-grey uppercase p-4"
                    placeholder="Enter name..."
                />
                <button className="block w-xl text-xl uppercase border border-grey hover:border-grey mt-10 h-10">
                    Save
                </button>
            </div>
        </div>
    );
}

/** Modal window loader */
export function Loader() {
    return (
        <div className="w-full h-full flex flex-col text-sm items-center justify-center bg-black bg-opacity-50 fixed top-0 left-0 z-50">
            <div className="loader text-md"></div>
            <div className="text-md mt-4">Loading...</div>
        </div>
    );
}
