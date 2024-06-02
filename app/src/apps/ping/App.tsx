import { useState } from "react";
import Ping from "./Ping";

export function App({ slave }: { slave: boolean }) {
    const [remote, setRemote] = useState<RTCSessionDescriptionInit | null>(
        null,
    );

    return (
        <div className="columns">
            <div className="column">
                {slave && (
                    <>
                        <p>Enter the SDP from the host</p>
                        <input
                            onChange={(e) =>
                                setRemote(JSON.parse(e.target.value))
                            }
                        />
                        {remote && <Ping
                            slave={slave}
                            remoteDescription={remote}
                        />}
                    </>
                )}
                {!slave && (
                    <>
                        <Ping onHostClick={(remote) => setRemote(remote)} />
                        <input disabled={true} value={JSON.stringify(remote)} />
                        <button
                            onClick={() => {
                                console.log("copied");
                                navigator.clipboard.writeText(
                                    JSON.stringify(remote),
                                );
                            }}
                        >
                            Copy
                        </button>
                    </>
                )}
            </div>
            {/* <div className="column">
                <Ping remoteDescription={remote} />
            </div> */}
        </div>
    );
}
