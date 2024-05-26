import { useState } from "react";

export type ParamOptions = {
    name: string;
    values: string[];
    defaultValue?: string;
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
    const [idx, setIdx] = useState(defaultValue && values.indexOf(defaultValue) || 0);

    return (
        <div className="param">
            <div className="param-name">{name}</div>
            <div className="param-value">
                <button
                    onClick={() => {
                        if (disabled) return;
                        const newIdx = idx === 0 ? (values.length - 1) : (idx - 1);
                        setIdx(newIdx);
                        onChange && onChange(values[newIdx]);
                    }}
                >
                    {"<"}
                </button>
                {isColour ? (
                    <div
                        className="param-colour"
                        style={{ backgroundColor: "#" + values[idx] }}
                    />
                ) : (
                    values[idx]
                )}
                <button
                    onClick={() => {
                        if (disabled) return;
                        const newIdx = idx === values.length - 1 ? 0 : (idx + 1);
                        setIdx(newIdx);
                        onChange && onChange(values[newIdx]);
                    }}
                >
                    {">"}
                </button>
            </div>
        </div>
    );
}
