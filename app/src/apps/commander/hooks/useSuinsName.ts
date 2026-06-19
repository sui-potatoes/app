// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { COMMANDER_BASE_NAME } from "../../../constants";

export function useSuinsName({ address }: { address?: string }) {
    const client = useCurrentClient();
    const { data: name } = useQuery({
        queryKey: ["suins-name", address],
        enabled: !!address,
        queryFn: () =>
            client.core
                .defaultNameServiceName({ address: address! })
                .then(({ data }) => data.name ?? null)
                .catch(() => null),
    });

    return name?.includes(COMMANDER_BASE_NAME) ? name.split(".")[0] : undefined;
}
