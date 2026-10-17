// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import type { BcsType } from "@mysten/sui/bcs";
import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";

/** Minimal object reference; replaces sui 1.x `SuiObjectRef`. */
export type ObjectRef = {
    objectId: string;
    version: string;
    digest: string;
};

/** A BCS-decoded object together with its on-chain reference. */
export type WithRef<T> = T & ObjectRef;

type UseBcsObjectArgs<T> = {
    /** Object id to fetch; query is disabled while empty. */
    id?: string | null;
    /** BCS schema used to decode the object's content. */
    schema: BcsType<T, any>;
    enabled?: boolean;
    refetchInterval?: number;
};

/** Fetch a single object by id and BCS-decode its content. */
export function useBcsObject<T>({
    id,
    schema,
    enabled = true,
    refetchInterval,
}: UseBcsObjectArgs<T>) {
    const client = useCurrentClient();
    return useQuery({
        queryKey: ["object", id],
        enabled: enabled && !!id,
        refetchInterval,
        queryFn: async (): Promise<T> => {
            const { object } = await client.core.getObject({
                objectId: id!,
                include: { content: true },
            });

            return schema.parse(object.content);
        },
    });
}

type UseOwnedBcsObjectsArgs<T, R> = {
    /** Address (or object id) owning the objects. */
    owner?: string | null;
    /** Object type filter: a package, `package::module`, or a full struct tag. */
    type: string;
    /** BCS schema used to decode each object's content. */
    schema: BcsType<T, any>;
    enabled?: boolean;
    refetchInterval?: number;
    gcTime?: number;
    select?: (items: WithRef<T>[]) => R;
};

/**
 * Fetch all objects of a given type owned by an address and BCS-decode them.
 * The decoded fields are merged with the object's `objectId`/`version`/`digest`.
 */
export function useOwnedBcsObjects<T, R = WithRef<T>[]>({
    owner,
    type,
    schema,
    enabled = true,
    refetchInterval,
    gcTime,
    select,
}: UseOwnedBcsObjectsArgs<T, R>) {
    const client = useCurrentClient();
    return useQuery({
        queryKey: ["owned-objects", type, owner],
        enabled: enabled && !!owner,
        refetchInterval,
        gcTime,
        queryFn: async (): Promise<WithRef<T>[]> => {
            const { objects } = await client.core.listOwnedObjects({
                owner: owner!,
                type,
                include: { content: true },
            });

            return objects.map((object) => ({
                ...schema.parse(object.content),
                objectId: object.objectId,
                version: object.version,
                digest: object.digest,
            }));
        },
        select,
    });
}
