// import { useState } from "react";
import { Connections } from "./Connections";
// import { Guest } from "./Guest";
// import { Host } from "./Host";
import { useParams } from "react-router-dom";

type UrlParams = {
    role: "host" | "guest";
};

export function App() {
    const { role: _ } = useParams<UrlParams>();
    // const [hostSdp, setHostSdp] = useState<string | null>(null);
    // const [guestSdp, setGuestSdp] = useState<string | null>(null);

    return (
        <>
            <Host
                onChannelOpen={(c) => c.send("Hello from Host")}
                onCreateOffer={(c) => setHostSdp(JSON.stringify(c))}
                remoteDescription={guestSdp && JSON.parse(guestSdp)}
            />

            <Guest
                remoteDescription={hostSdp && JSON.parse(hostSdp)}
                onDataChannel={(c) => c.send("Hello from Guest")}
                onAnswer={(c) => setGuestSdp(JSON.stringify(c))}
            />

            {/* <Connections
                onTargetSelect={(addr) => sendInvite(addr)}
                onAccept={(addr) => acceptInvite(addr)}
            /> */}
        </>
    );

    function sendInvite(addr: string) {

    }

    function acceptInvite(addr: string) {

    }
}
