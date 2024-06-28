import { Character } from "./App";

type CharOptions = Character & {};

export function Char({
    hair_type,
    body_type,
    skinColour,
    eyesColour,
    hairColour,
    pantsColour,
    baseColour,
    accentColour,
}: CharOptions) {
    return (
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 240">
            <style>{`* { stroke: none; } .s  {fill: #${skinColour} } .e { fill: #${eyesColour} } .h { fill: #${hairColour} } .l { fill: #${pantsColour} } .b { fill: #${baseColour} } .a { fill: #${accentColour} }`}</style>
            <rect x="80" y="100" width="60" height="60" className="b" />{" "}
            {/* body */}
            <rect x="80" y="40" width="60" height="60" className="s" />{" "}
            {/* head */}
            <rect x="80" y="60" width="20" height="20" className="e" />{" "}
            {/* left eye */}
            <rect x="120" y="60" width="20" height="20" className="e" />{" "}
            {/* right eye */}
            <rect x="80" y="160" width="20" height="60" className="l" />{" "}
            <rect x="120" y="160" width="20" height="60" className="l" />{" "}
            <rect x="99" y="160" width="22" height="20" className="l" />{" "}
            {/* legs */}
            {/* <rect
                x="100"
                y="180"
                width="20"
                height="40"
                className="gap"
                fill="#fff"
            />{" "} */}
            {/* gap */}
            <rect x="60" y="100" width="20" height="60" className="s" />{" "}
            {/* left arm */}
            <rect x="140" y="100" width="20" height="60" className="s" />{" "}
            {/* right arm */}
            {/* <g dangerouslySetInnerHTML={{ __html: decodeURIComponent(extra)}} /> */}
            {/* For better UX caching them in the UI, ideally should be devInspect-ed */}
            {hair_type && hair_type == "wind" && (
                <>
                    <rect x="180" y="40" width="20" height="20" className="h" />
                    <rect x="140" y="40" width="40" height="40" className="h" />
                    <rect x="70" y="20" width="80" height="20" className="h" />
                    <rect x="60" y="20" width="20" height="60" className="h" />
                </>
            )}
            {hair_type && hair_type == "flat" && (
                <>
                    <rect x="80" y="20" width="60" height="20" className="h" />
                </>
            )}
            {hair_type && hair_type == "bang" && (
                <>
                    <rect x="120" y="40" width="20" height="20" className="h" />
                    <rect x="80" y="20" width="60" height="20" className="h" />
                </>
            )}
            {hair_type && hair_type == "punk" && (
                <>
                    <rect x="80" y="0" width="40" height="20" className="h" />
                    <rect x="80" y="20" width="60" height="20" className="h" />
                </>
            )}
            {body_type && body_type == "office" && (
                <>
                    <rect
                        x="140"
                        y="100"
                        width="20"
                        height="40"
                        className="a"
                    />
                    <rect
                        x="100"
                        y="100"
                        width="20"
                        height="40"
                        className="a"
                    />
                    <rect x="60" y="100" width="20" height="40" className="a" />
                </>
            )}
            {body_type && body_type == "blazer" && (
                <>
                    <rect
                        x="140"
                        y="100"
                        width="20"
                        height="20"
                        className="a"
                    />
                    <rect x="60" y="100" width="20" height="20" className="a" />
                    <rect
                        x="100"
                        y="120"
                        width="20"
                        height="20"
                        className="b"
                    />
                    <rect
                        x="120"
                        y="100"
                        width="20"
                        height="20"
                        className="b"
                    />
                    <rect x="80" y="100" width="20" height="20" className="b" />
                </>
            )}
            {body_type && body_type == "tshirt" && (
                <>
                    <rect
                        x="140"
                        y="100"
                        width="20"
                        height="20"
                        className="b"
                    />
                    <rect x="60" y="100" width="20" height="20" className="b" />
                </>
            )}
        </svg>
    );
}
