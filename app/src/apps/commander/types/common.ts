// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

export enum Cover {
    None = 0,
    Low = 1,
    High = 2,
}

export type Tile =
    | { type: "Empty"; unit: number | null }
    | { type: "Unwalkable"; unit: number | null }
    | {
          type: "Cover";
          up: number;
          down: number;
          left: number;
          right: number;
          unit: number | null;
      };
