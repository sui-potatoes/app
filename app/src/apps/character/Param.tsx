import { useEffect, useState } from "react";

export type ParamOptions = {
    name: string;
    values: string[];
    value?: string;
    defaultValue: string;
    isColour?: boolean;
    disabled?: boolean;
    onChange?: (value: string) => void;
};

/**
 * A single Param carousel item.
 * Has Left and Right buttons to navigate through the list of params.
 *
 * And shows the current param value in the middle. For colours it shows the
 * colour as a coloured square, for other params it shows the value as text.
 */
export function Param({
    name,
    disabled,
    defaultValue,
    values,
    isColour,
    onChange,
}: ParamOptions) {
    const [idx, setIdx] = useState(0);

    // must be here to re-render when defaultValue changes
    useEffect(() => setIdx(values.indexOf(defaultValue)), [defaultValue]);

    return (
        <div className="flex md:grid grid-cols-2 max-md:justify-between md:max-w-[400px]">
            <div className="md:flex-1 decoration-none uppercase mr-5 text-left">{name}</div>
            <div className="uppercase flex flex-wrap items-center gap-3">
                <button
                    onClick={() => {
                        if (disabled) return;
                        const newIdx = idx === 0 ? values.length - 1 : idx - 1;
                        setIdx(newIdx);
                        onChange && onChange(values[newIdx]);
                    }}
                    className="disabled:opacity-70"
                    disabled={disabled}
                >
                    {"‹"}
                </button>
                {isColour ? (
                    <div
                        className="h-5 w-5"
                        style={{ backgroundColor: "#" + values[idx] }}
                    />
                ) : (
                    values[idx]
                )}
                <button
                    onClick={() => {
                        if (disabled) return;
                        const newIdx = idx === values.length - 1 ? 0 : idx + 1;
                        setIdx(newIdx);
                        onChange && onChange(values[newIdx]);
                    }}
                    className="disabled:opacity-70"
                    disabled={disabled}
                >
                    {"›"}
                </button>
            </div>
        </div>
    );
}
