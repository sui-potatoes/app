import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { SuiObjectRef } from "@mysten/sui.js/bcs";
import { fromB64 } from "@mysten/sui.js/utils";
import { bcs } from "@mysten/sui.js/bcs";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { RPS_PACKAGE_ID as PACKAGE_ID } from "../../constants";
import blake2b from "blake2b";
import { useEffect, useState } from "react";
import { useEnokiFlow } from "@mysten/enoki/react";

type Params = {
  matchId: string;
  account: SuiObjectRef;
};

export const Player = bcs.struct("Player", {
  id: bcs.Address,
  commitment: bcs.option(bcs.vector(bcs.u8())),
  nextMove: bcs.option(bcs.u8()),
});

export const Params = bcs.struct("Params", {
  rounds: bcs.u8(),
});

export const Game = bcs.struct("Game", {
  id: bcs.Address,
  host: Player,
  guest: bcs.option(Player),
  params: Params,
  history: bcs.vector(bcs.Address),
  round: bcs.u8(),
});

export function ActiveGame({ account, matchId }: Params) {
  const client = useSuiClient();
  const [gameData, setGameData] = useState<typeof Game | any>(null);
  const [canPlay, setCanPlay] = useState(false);
  const flow = useEnokiFlow();
  const { data: game, error } = useSuiClientQuery("getObject", {
    id: matchId,
    options: { showBcs: true },
  });

  useEffect(() => {
    if (!game) return;
    const gameData = Game.parse(
      fromB64((game?.data!.bcs! as { bcsBytes: string }).bcsBytes),
    );
    setGameData(gameData);
    if (gameData.guest !== null) {
      setCanPlay(true);
    }

    let isHost = gameData.host.id === account.objectId;
    let player = isHost ? gameData.host : gameData.guest;

    console.log(player);
    console.log(gameData);

    if (player?.commitment !== null && player?.nextMove === null) {
      console.log("should reveal");
      console.log(gameData.id);
      reveal();
    }
  }, [game]);

  if (error) return <div>Error: {error.message}</div>;
  if (!game) return <div>Loading...</div>;

  return (
    <>
      <div id="gameInterface" className={canPlay ? "" : "disabled"}>
        <img
          src="rock.png"
          id="rock"
          className="choice"
          onClick={() => play("rock")}
        />
        <img
          src="paper.png"
          id="paper"
          className="choice"
          onClick={() => play("paper")}
        />
        <img
          src="scissors.png"
          id="scissors"
          className="choice"
          onClick={() => play("scissors")}
        />
      </div>
    </>
  );

  async function play(userChoice: string) {
    if (!canPlay) return;

    const clicked: HTMLImageElement | null = document.querySelector(
      "#" + userChoice,
    );

    clicked!.style!.boxShadow = "";
    clicked!.style!.animation = "move-up 2s ease";
    clicked!.style!.animationFillMode = "forwards";
    clicked?.classList.add("active");

    const move = userChoice === "rock" ? 0 : userChoice === "paper" ? 1 : 2;
    const data = new Uint8Array([move, 1, 2, 3, 4]);
    const hash = Array.from(blake2b(32).update(data).digest());

    window.localStorage.move = move;

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${PACKAGE_ID}::game::commit_move`,
      arguments: [
        txb.object(account.objectId),
        txb.object(matchId),
        txb.pure(bcs.vector(bcs.u8()).serialize(hash)),
      ],
    });

    setCanPlay(false);

    await flow.sponsorAndExecuteTransactionBlock({
      transactionBlock: txb,
      network: "testnet", // @ts-ignore
      client,
    });

    console.log("move committed");
  }

  async function reveal() {
    // can't reveal if both players haven't committed
    if (gameData === null) return;

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${PACKAGE_ID}::game::reveal_move`,
      arguments: [
        txb.object(account.objectId),
        txb.object(matchId),
        txb.pure(bcs.u8().serialize(window.localStorage.move)),
        txb.pure(bcs.vector(bcs.u8()).serialize([1, 2, 3, 4])),
      ],
    });

    await flow.sponsorAndExecuteTransactionBlock({
      transactionBlock: txb,
      network: "testnet", // @ts-ignore
      client,
    });

    console.log("move revealed");

    setCanPlay(true);
  }
}
