import { useEffect, useState } from "react";

export type ConnectionProps = RTCConfiguration & {
    label?: string;
    removeSdp?: string;
};

export function useWebRTCConnection(props: ConnectionProps = {}) {
    const [connection, setConnection] = useState<RTCPeerConnection | null>(
        null,
    );

    useEffect(() => {
        if (!connection) {
            const conn = new RTCPeerConnection(props);

            conn.onicecandidate = (event) => {
                if (event.candidate) {
                    console.log("[connection] new ice candidate");
                }

                if (event.candidate === null) {
                    console.log("[connection] ice candidate gathering complete");
                }
            };

            setConnection(conn);
        }

        return () => connection?.close();
    }, []);

    return { connection };
}
