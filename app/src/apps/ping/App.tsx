import { useState } from "react";
import Ping from "./Ping";

export function App() {
    const [remote, setRemote] = useState<RTCSessionDescriptionInit | null>(
        null,
    );

    return (
        <div className="columns">
            <div className="column">
                <input onChange={(e) => setRemote(JSON.parse(e.target.value))} />
                <Ping remoteDescription={remote} onHostClick={(remote) => setRemote(remote)} />
                <input onChange={() => {}} value={JSON.stringify(remote)} />
                <button onClick={() => setRemote(null)}>Clear</button>
                {/* add a copy buffer */}
                <button onClick={() => {
                    console.log('copied');
                    navigator.clipboard.writeText(JSON.stringify(remote))
                }}>Copy</button>
            </div>
            {/* <div className="column">
                <Ping remoteDescription={remote} />
            </div> */}
        </div>
    );
}
