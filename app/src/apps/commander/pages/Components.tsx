// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { ReactNode, useEffect } from "react";
import { NavLink } from "react-router-dom";
import { Stats } from "../types/bcs";

export type StatRecord = {
    key: keyof Stats;
    name: string;
    maxValue: number;
    description?: string;
    process?: (s: Stats) => number | [number, number];
};

type StatRecordProps = {
    stats: Stats;
    record: StatRecord;
    modifier?: Stats;
    className?: string;
};

/**
 * Used in stat display for `Armor`, `Weapon` and `Recruit`
 */
export function StatRecord({
    stats,
    className,
    modifier,
    record: { maxValue, key, name, description, process },
}: StatRecordProps) {
    const value = process ? process(stats) : +stats[key];
    const slider =
        typeof value === "number" ? (
            <Slider value={value} maxValue={maxValue} modifier={modifier ? +modifier[key] : 0} />
        ) : (
            <SliderRange range={value} maxValue={maxValue} />
        );

    return (
        <div className={className} title={description}>
            <label>{name}</label>
            <div>{slider}</div>
        </div>
    );
}

export function Footer({ to, text }: { to?: string; text?: string }) {
    return (
        <>
            <NavLink
                to={to || ".."}
                className="fixed flex justify-start bottom-10 left-10 p-10 text-lg hover:underline menu-control back-button"
            >
                {text || "Back"}
            </NavLink>
        </>
    );
}

export function TextInput({}: { value: boolean; onChange: (v: string) => void }) {
    return <input type="text" />;
}

export function Slider({
    value,
    maxValue,
    modifier,
}: {
    value: number;
    maxValue: number;
    modifier: number;
}) {
    const percentValue = (Math.abs(value / maxValue) * 100).toFixed(0);
    const modifierValue = (Math.abs(modifier / maxValue) * 100).toFixed(0);
    return (
        <div className="slider-outer">
            <div
                className={(value >= 0 && "slider-inner") || "slider-inner-negative"}
                style={{ width: Math.max(+percentValue, 0) + "%" }}
            ></div>
            {modifier > 0 && (
                <div
                    className="slider-inner"
                    style={{
                        width: Math.max(+modifierValue - 1.5, 0) + "%",
                        left: Math.max(+percentValue, 0.6) + "%",
                        background: "rgb(34, 45, 132)",
                    }}
                ></div>
            )}
            {modifier < 0 && value + modifier > 0 && (
                <div
                    className="slider-inner-negative"
                    style={{
                        width: modifierValue + "%",
                        left: +percentValue - +modifierValue + "%",
                        background: "rgb(140, 29, 29)",
                    }}
                ></div>
            )}
            <div className="slider-value">
                {value + modifier}
                {/* {modifier > 0 && ` (+${modifier})`} */}
                {/* {modifier < 0 && ` (${modifier})`} */}
            </div>
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

export function GameScreen({
    children,
    title,
    footerTo,
    className,
}: {
    children: ReactNode | ReactNode[];
    title: ReactNode | ReactNode[];
    footerTo?: string;
    className?: string;
}) {
    return (
        <div className="flex justify-start flex-col w-full h-full">
            <div className="text-left p-10 max-w-xl">
                <h1 className="p-1 mb-10 page-heading">{title}</h1>
            </div>
            <div className={`w-auto h-full flex mx-10 ${className}`}>{children}</div>
            <Footer to={footerTo} />
        </div>
    );
}

type ModalProps = {
    children: ReactNode | ReactNode[];
    show: boolean;
    onClose: () => void;
};

export function Modal({ children, show, onClose }: ModalProps) {
    return (
        <div
            className="absolute top-0 left-0 h-screen w-full bg-black/90 overflow-auto"
            style={{ display: show ? "flex" : "none" }}
            onClick={onClose}
        >
            <div className="m-auto">{children}</div>
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
            className="absolute h-screen w-full bg-black/50"
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

/** Modal window loader, supports children for loading */
export function Loader({ text, children }: { text?: string; children?: ReactNode }) {
    // animate the image by rotating it
    useEffect(() => {
        const rr = document.getElementById("rr");
        let angle = 0;
        const interval = setInterval(() => {
            angle += 1;
            rr?.setAttribute(
                "style",
                `transform: rotate(${angle}deg); transform-origin: center; width: 150px`,
            );
        }, 10);
        return () => clearInterval(interval);
    }, []);

    return (
        <>
            <Footer />
            <div className="w-full h-full flex flex-col text-sm items-center justify-center bg-black/50 fixed top-0 left-0 z-50">
                <div className="animate-pulse flex flex-col items-center justify-center">
                    <img id="rr" src="/images/rotorelief.svg" style={{ width: "150px" }} />
                    <div className="text-md mt-4">{text || "Loading..."}</div>
                </div>
                {children}
            </div>
        </>
    );
}
