import "./go-game.css";
import { Board as PlayableBoard } from "./Board";
import { useEffect, useState } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { bcs } from "@mysten/sui.js/bcs";
import { fromB64 } from "@mysten/bcs";

const Move = bcs.struct("Move", {
  x: bcs.u8(),
  y: bcs.u8(),
});

const Board = bcs.struct("Board", {
  data: bcs.vector(bcs.vector(bcs.u8())),
  size: bcs.u8(),
  turn: bcs.u8(),
  moves: bcs.vector(Move),
  scores: bcs.vector(bcs.u64()),
  ko_store: bcs.vector(bcs.vector(bcs.u8())),
});
const Game = bcs.struct("Game", {
  id: bcs.Address,
  board: Board,
});

export function App() {
  const flow = useEnokiFlow();
  const zkLogin = useZkLogin();
  const client = useSuiClient();
  const packageId = useNetworkVariable("goPackageId");

  const size = 9;
  const [canPlay, setCanPlay] = useState(false);
  const [turn, setTurn] = useState<1 | 2>(1);
  const [data, setData] = useState<number[][]>(
    Array(size).fill(Array(size).fill(0)),
  );
  const { data: caps, refetch } = useSuiClientQuery("getOwnedObjects", {
    owner: zkLogin.address!,
    filter: { MoveModule: { package: packageId, module: "game" } },
    options: { showContent: true },
  });

  // @ts-ignore-next-line
  const board_id = caps?.data[0]?.data?.content!.fields!.board_id;
  const { data: game, refetch: fetchGame } = useSuiClientQuery("getObject", {
    id: board_id,
    options: { showBcs: true },
  }, {
    enabled: !!board_id
  });

  useEffect(() => {
    if (!game) return;
    const gameData = Game.parse(
      fromB64((game?.data!.bcs! as { bcsBytes: string }).bcsBytes),
    );
    setData(gameData.board.data);
    setTurn(gameData.board.turn as 1 | 2);
    setCanPlay(true);
  }, [game]);

  if (!zkLogin.address) return <div>Connect wallet</div>;
  if (!caps?.data.length)
    return <button onClick={newGame}>Create a game</button>;
  if (!game) return <div>Loading...</div>;

  return (
    <>
      <PlayableBoard
        disabled={!canPlay}
        size={size}
        data={data}
        turn={turn}
        zoom="150%"
        onClick={handleClick}
      />
      {/* <a className="explorer-link" href={`https://suiscan.xyz/testnet/object/${game.data?.objectId}`}>Explorer link</a> */}
    </>
  );

  async function handleClick(x: number, y: number) {
    if (data[x][y] !== 0) return console.log("Cell is already occupied");
    if (!canPlay) return console.log("Not your turn, or the state is loading");

    setCanPlay(false);

    const inspect = new TransactionBlock();
    inspect.moveCall({
      target: `${packageId}::game::board_state`,
      arguments: [
        inspect.object(board_id),
        inspect.pure.u8(x),
        inspect.pure.u8(y),
      ],
    });
    const res = await client.devInspectTransactionBlock({
      sender: zkLogin.address!, // @ts-ignore
      transactionBlock: inspect,
    });

    if (!res.results || !res.results[0]) {
      console.log("Invalid move");
      setCanPlay(true);
      return;
    }

    if (res.error) {
      console.error(res.error);
      setCanPlay(true);
      return;
    }


    const boardBytes = (res.results[0].returnValues as any);
    const board = Board.parse(new Uint8Array(boardBytes[0][0]));

    setTurn(turn === 1 ? 2 : 1);
    setData(board.data);

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::play`,
      arguments: [
        txb.object(board_id), // @ts-ignore
        txb.object(caps?.data[0].data?.objectId),
        txb.pure.u8(x),
        txb.pure.u8(y),
      ],
    });

    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });

    console.log("move played");
    fetchGame();
    setCanPlay(true);
  }

  async function newGame() {
    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::new`,
      arguments: [txb.pure.u8(size)],
    });
    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });
    refetch();
  }
}
