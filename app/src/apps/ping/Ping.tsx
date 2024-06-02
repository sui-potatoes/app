import { useEffect, useState } from "react";
import { createPeerConnection } from "./lib";

export type PingProps = {
    remoteDescription?: string | null;
    onMessageReceived?: (message: string) => void;
    onChannelOpen?: () => void;
    onHostClick?: (remote: string) => void;
    slave?: boolean;
};

export default function Ping({ remoteDescription, onHostClick }: PingProps) {
    const [sendMessage, setSendMessage] = useState<(message: string) => void>(
        () => () => {},
    );

    useEffect(() => {
        createPeerConnection({
            iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
            remoteDescription: remoteDescription
                ? atob(remoteDescription)
                : undefined,
            onChannelOpen: () => {
                console.log("channel open");
            },
            onMessageReceived: (message) => {
                console.log("message received", message);
            },
        }).then((response) => {
            !remoteDescription &&
                onHostClick &&
                onHostClick(btoa(response.localDescription));
            setInterval(() => response.sendMessage("ping"), 1000);
            setSendMessage((e: string) => sendMessage(e));
        });
    }, [remoteDescription]);

    // To establish the connection, host needs to provide the offer. The offer
    // contains the remote description and the ice candidates.
    //
    // If the slave has the offer, it can create an answer. The answer contains
    // the local description and the ice candidates.
    //
    // Once the connection is established, the host and the slave can send
    // messages to each other.
    //
    // The messages are sent via Channel, not the connection itself.
    // The channel can be both a message channel and a data channel.
    //
    // The slave expects the datachannel event to be fired, while the host
    // creates the data channel. The slave receives it from the event, and
    // then uses to send messages.

    return (
        <>
            <p>
                <button onClick={() => sendMessage && sendMessage("ping")}>
                    ping
                </button>
            </p>
        </>
    );
}
