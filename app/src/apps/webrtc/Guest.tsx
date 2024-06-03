// import { useState } from "react";
import { useEffect, useState } from "react";
import { useWebRTCConnection } from "./hooks/useWebRTCConnection";

type GuestProps = {
    /** The Host's SDP to initialize connection */
    remoteDescription?: RTCSessionDescriptionInit;

    onDataChannel?: (channel: RTCDataChannel) => void;
    onAnswer?: (answer: RTCSessionDescriptionInit) => void;
    connectionOptions?: RTCConfiguration;
    channelOptions?: RTCDataChannelInit;
};

/**
 * To start a session, the guest must be initialized with SDP received from the
 * host. Once a session is established, the guest shares their SDP with the host.
 *
 * The window is expected to be kept until the connection is established and the
 * guest's SDP is shared with the host.
 */
export function Guest({
    remoteDescription,
    onDataChannel,
    onAnswer,
    channelOptions,
    connectionOptions,
}: GuestProps) {
    const [channel, setChannel] = useState<RTCDataChannel | null>(null);
    const { connection } = useWebRTCConnection(connectionOptions);

    connection?.addTrack()

    useEffect(() => {
        if (!connection) return;
        if (!remoteDescription) return;

        connection.ondatachannel = ({ channel }) => {
            onDataChannel && onDataChannel(channel);
            setChannel(channel);
        };

        connection.setRemoteDescription(remoteDescription).then(() => {
            connection.createAnswer().then((answer) => {
                connection.setLocalDescription(answer);
                onAnswer && onAnswer(answer);
            });
        });
    }, [remoteDescription]);

    useEffect(() => {
        if (!channel) return;

        channel.onopen = () => {
            console.log("[guest] channel opened");
        }
        channel.onmessage = (event) => {
            channel.send("Hello from Guest");
            console.log(event.data);
        };
    }, [channel]);

    return (
        <div>
            <h3>Host</h3>
            <p>{remoteDescription?.type}</p>
            {channel?.readyState}
            <button onClick={() => channel?.send("Hello from Guest")}>
                Send
            </button>
        </div>
    );
}
