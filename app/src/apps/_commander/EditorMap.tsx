// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Map, MapProps } from "./Map";

type Props = MapProps & {};

export function EditorMap({ grid, texture, highlight, onPoint, onSelect }: Props) {
    return <Map grid={grid} highlight={highlight} texture={texture} onPoint={onPoint} onSelect={onSelect} />;
}
