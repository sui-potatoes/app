// import { useState } from "react";
import { useEffect, useState } from "react";
import { useWebRTCConnection } from "./hooks/useWebRTCConnection";

type HostProps = {
    onChannelOpen?: (c: RTCDataChannel) => void;
    onCreateOffer?: (c: RTCSessionDescriptionInit) => void;
    remoteDescription?: RTCSessionDescriptionInit;
    channelOptions?: RTCDataChannelInit;
    connectionOptions?: RTCConfiguration;
};

/**
 * Host initializes the session and send their SDP to the invitee. Then waits
 * for the other party's response.
 */
export function Host({
    onChannelOpen,
    onCreateOffer,
    remoteDescription,
    channelOptions,
    connectionOptions,
}: HostProps) {
    const [channel, setChannel] = useState<RTCDataChannel | null>(null);
    const [ready, setReady] = useState(false);
    const { connection } = useWebRTCConnection(connectionOptions);

    useEffect(() => {
        if (!connection) return;

        console.log("[host] connection created");

        const channel = connection.createDataChannel("data", channelOptions);
        channel.onopen = () => onChannelOpen && onChannelOpen(channel);
        channel.onmessage = (event) => {
            channel.send("Hello from Host");
            console.log(event.data);
        };

        setChannel(channel);

        // Extremely important property of the Host is to not accept any answer
        // until the ice candidate gathering is complete. Otherwise, the connection
        // will keep failing.
        connection.onicecandidate = (event) => {
            if (event.candidate === null) {
                console.log("[host] ice candidate gathering complete");
                setReady(true);
            }
        };

        connection.createOffer().then((offer) => {
            console.log("[host] new offer created");
            connection.setLocalDescription(offer);
            onCreateOffer && onCreateOffer(offer);
        });
    }, [connection]);

    useEffect(() => {
        if (!connection) return;
        if (!remoteDescription) return;
        if (!ready) return;
        if (connection.remoteDescription) return;

        connection.setRemoteDescription(remoteDescription);
    }, [remoteDescription, ready]);

    return (
        <div>
            <h3>Guest</h3>
            <p>{remoteDescription?.type}</p>
            {channel?.readyState}
            <button onClick={() => channel?.send("Hello from Host")}>
                Send
            </button>
        </div>
    );
}
