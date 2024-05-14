import { Route, Routes } from "react-router-dom";
import Root from "./Root.tsx";
import { NavLink } from "react-router-dom";
import { App as GoGame } from "./apps/go-game/App.tsx";
import { App as RockPaperScissors } from "./apps/rock-paper-scissors/App.tsx";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useEffect } from "react";

export function App() {
  const flow = useEnokiFlow();
  const zkLogin = useZkLogin();

  useEffect(() => {
    if (window.location.hash)
      flow.handleAuthCallback().then(() => {
        // @ts-ignore
        window.location = window.location.href.split("#")[0];
      });
  }, []);

  return (
    <div className="container">
      <div className="sidebar">
        <p className="wallet connect">
          <u>
            {(!zkLogin.address && (
              <button
                className="connect"
                onClick={async () => {
                  // Refresh the page to go back to the root path, this is a
                  // workaround for the issue where google auth doesn't work
                  // when the app is hosted on a subpath.
                  history.pushState({}, "", "/");
                  window.location.href = await flow.createAuthorizationURL({
                    provider: "google",
                    clientId:
                      "591411088609-6kbt6b07a6np6mq2mnlq97i150amussh.apps.googleusercontent.com",
                    redirectUrl: window.location.href.split("#")[0],
                    network: "testnet",
                  });
                }}
              >
                Sign In
              </button>
            )) || (
              <button onClick={() => flow.logout()} className="connect">
                Sign Out
              </button>
            )}
          </u>
        </p>
        <ul>
          <li>
            <NavLink to="/go">go game</NavLink>
          </li>
          <li>
            {/* <NavLink  to="/">rock paper scissors (disabled)</NavLink> */}
            <p style={{cursor: 'default'}}>rock paper scissors (disabled)</p>
          </li>
        </ul>
      </div>
      <div className="content">
        <Routes>
          <Route path="/" element={<Root />} />
          <Route path="/go" element={<GoGame />} />
          <Route path="/go/:id" element={<GoGame />} />
          <Route path="/rps" element={<RockPaperScissors />} />
        </Routes>
      </div>
    </div>
  );
}
