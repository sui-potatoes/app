import { useSuiClientQuery } from "@mysten/dapp-kit";
import { CreateAccount } from "./CreateAccount";
import { PACKAGE_ID } from "../../constants";
import { GameInterface } from "./GameInterface";
import { useZkLogin } from "@mysten/enoki/react";
// import { useEnokiFlow, useZkLoginSession } from "@mysten/enoki/react";

import "./rock-paper-scissors.css";

export function App() {
  // const currentAccount = useCurrentAccount();
  const zkLogin = useZkLogin();
  const {
    data: account,
    isPending,
    error,
    refetch,
  } = useSuiClientQuery("getOwnedObjects", {
    owner: zkLogin.address!,
    filter: { MoveModule: { package: PACKAGE_ID, module: "game" } },
    options: { showBcs: true },
  });

  if (error) return <div>Error: {error.message}</div>;
  if (isPending) return <div>{".".repeat(Math.random() * 10)}</div>;

  return account.data.length ? (
    <GameInterface account={account.data[0].data!} />
  ) : (
    <CreateAccount onSuccess={() => refetch()} onError={() => {}} />
  );
}
