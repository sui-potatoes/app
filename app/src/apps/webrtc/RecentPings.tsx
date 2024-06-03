import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { formatAddress } from "@mysten/sui/utils";

export function RecentPings() {
    const packageId = useNetworkVariable("webrtcPackageId");
    const { data: pings } = useSuiClientQuery("queryEvents", {
        query: { MoveEventType: `${packageId}::webrtc::Ping` },
    });

    return (
        <ul>
            {pings?.data.map((event) => {
                const timeElapsed =
                    (Date.now() - (Number(event.timestampMs) || 0)) / 1000;

                return (
                    <li key={event.bcs}>
                        <button>
                            Connect to{" "}
                            {formatAddress(
                                (event.parsedJson as { name: string }).name,
                            )}{" "}
                            {timeElapsed.toFixed(0)}s ago
                        </button>
                    </li>
                );
            })}
        </ul>
    );
}
