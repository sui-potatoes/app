// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { BcsType, fromBase64 } from "@mysten/bcs";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { SuiClient } from "@mysten/sui/client";
import { QueryObserverBaseResult } from "@tanstack/react-query";
import { useEffect, useState } from "react";

type Props<T> = {
    objectId: string;
    enabled: boolean;
    parser: BcsType<T>;
};

/**
 * Hook to create a transaction executor
 */
export function useQueryObjectBcs<T>({ objectId, parser, enabled }: Props<T>): QueryObserverBaseResult<T | null, Error> {
    const [parsed, setParsed] = useState<T | null>(null);
    const result = useSuiClientQuery(
        "getObject",
        { id: objectId, options: { showBcs: true } },
        { enabled },
    );

    useEffect(() => {
        if (!result.data) return;
        if (!result.data.data) return;
        if (!result.isSuccess) return;

        const object = result.data.data;
        const rawData = object.bcs;

        if (!rawData) {
            throw new Error(`Query failed: expected object '${objectId}', got null`);
        }

        if (rawData?.dataType === "package") {
            throw new Error(`Expected object '${objectId}', got package`);
        }

        const parsedData = parser.parse(fromBase64(rawData.bcsBytes));
        setParsed(parsedData);
    }, [result.data]);

    if (result.isPending) return { ...result, data: null };
    if (result.error) return { ...result, data: null };

    return { ...result, data: parsed };
}
