// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { COMMANDER_V2_PACKAGE_ID } from "../../../constants";
import { ObjectRef } from "../../../hooks/useBcsObjects";
import { Game } from "../types/bcs";

type Props = {
    id: string | null;
    enabled?: boolean;
    refetchInterval?: number;
};

export type GameMap = ObjectRef & {
    initialSharedVersion: string;
    map: typeof Game.$inferType;
};

export function useGame({ id, enabled = true, refetchInterval }: Props) {
    const client = useCurrentClient();
    return useQuery({
        queryKey: ["commander", "game", id],
        enabled: enabled && !!id,
        refetchInterval,
        async queryFn(): Promise<GameMap | null> {
            const { object } = await client.core
                .getObject({ objectId: id!, include: { content: true } })
                .catch(() => ({ object: null }));

            if (!object) return null;
            if (object.type !== `${COMMANDER_V2_PACKAGE_ID}::commander::Game`) return null;
            if (object.owner.$kind !== "Shared") return null;

            return {
                objectId: object.objectId,
                version: object.version,
                digest: object.digest,
                initialSharedVersion: object.owner.Shared.initialSharedVersion,
                map: Game.parse(object.content),
            };
        },
    });
}
