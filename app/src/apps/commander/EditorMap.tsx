// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Map, MapProps } from "./Map";

type Props = MapProps & {};

export function EditorMap({ grid, onPoint, onSelect }: Props) {
    return <Map
        grid={grid}
        onPoint={onPoint}
        onSelect={onSelect}
    />;
}
