import { useState } from "react";
import Ping from "./Ping";

export function App({ slave }: { slave: boolean }) {
    const [remote, setRemote] = useState<string | null>(null);

    return (
        <div className="columns">
            <div className="column">
                {slave && (
                    <>
                        <p>Enter the SDP from the host</p>
                        <input onChange={(e) => setRemote(e.target.value)} />
                        {remote && (
                            <Ping slave={slave} remoteDescription={remote} />
                        )}
                    </>
                )}
                {!slave && (
                    <>
                        <Ping
                            onHostClick={(remote) => {
                                console.log(remote);
                                setRemote(remote);
                            }}
                        />
                        <input disabled={true} value={remote ? remote : ""} />
                        <button
                            onClick={() => {
                                if (!remote) return;
                                console.log("copied");
                                navigator.clipboard.writeText(remote);
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
