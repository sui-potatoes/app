// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { EventBus } from "./EventBus";
import { HistoryRecord } from "../types/bcs";

type HistoryRecord = typeof HistoryRecord.$inferType;

const HEADERS: (keyof HistoryRecord)[] = [
    "Reload",
    "NextTurn",
    "Move",
    "Attack",
    "RecruitPlaced",
    "Grenade",
] as const;
type Header = Pick<HistoryRecord, (typeof HEADERS)[number]>;

interface HistoryRef {
    current: HistoryRecord[];
}

export class HistoryPlayer {
    protected idx: number = 0;

    constructor(
        protected bus: EventBus,
        protected ref: HistoryRef,
        protected playerIdx: number = 0,
    ) {
        this.idx = this.ref.current.length - 1;
    }

    next(historyRef: HistoryRef) {
        const header = historyRef.current[this.idx];

        console.log("next", this.idx, header);
        console.log(`Scanning from ${this.idx} / ${historyRef.current.length - 1}`);
        console.log(header.$kind);

        const nextHeaderIdx = historyRef.current
            .slice(this.idx + 1)
            .findIndex((h) => HEADERS.includes(h.$kind));

        if (nextHeaderIdx === -1) {
            return console.log(`No next header found; ${this.idx} / ${historyRef.current.length - 1}`);
        }

        const history = historyRef.current.slice(this.idx, nextHeaderIdx + 1);

        console.log("sending observer event", history);

        this.idx = nextHeaderIdx + 1;
        this.bus.dispatchEvent({
            type: "sui:tx_success",
            history,
        });
    }
}
