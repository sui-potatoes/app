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

  const size = 13;
  const [canInteract, setCanInteract] = useState(false);
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
  const { data: game, refetch: fetchGame } = useSuiClientQuery(
    "getObject",
    {
      id: board_id,
      options: { showBcs: true },
    },
    {
      enabled: !!board_id,
    },
  );

  useEffect(() => {
    // can create a new game if there are no games
    if (!game && !caps?.data.length) {
      setCanInteract(true);
    }

    // if there is a cap but no game, we're waiting for the fetch
    if (!game) return;
    const gameData = Game.parse(
      fromB64((game?.data!.bcs! as { bcsBytes: string }).bcsBytes),
    );

    // game is found, set the board state
    setData(gameData.board.data);
    setTurn(gameData.board.turn as 1 | 2);
    setCanInteract(true);
  }, [game]);

  if (!zkLogin.address) return <div>Connect wallet</div>;
  if (!caps?.data.length)
    return (
      <button disabled={!canInteract} onClick={() => newGame()}>
        Create a game
      </button>
    );
  if (!game) return <div>Loading...</div>;

  return (
    <>
      <PlayableBoard
        disabled={!canInteract}
        size={size}
        data={data}
        turn={turn}
        zoom={(19 - size / 2) * 10 + "%"}
        onClick={handleClick}
      />
      <div className="buttons">
        <button>
          <a
            type="button"
            className="explorer-link"
            href={`https://suiscan.xyz/testnet/object/${game.data?.objectId}`}
          >
            Explorer
          </a>
        </button>
        <button
          disabled={!canInteract}
          className="explorer-link"
          onClick={endGame}
        >
          End game
        </button>
        <button
          disabled={!canInteract}
          className="explorer-link"
          onClick={() => {}}
        >
          Pass
        </button>
      </div>
    </>
  );

  async function handleClick(x: number, y: number) {
    if (data[x][y] !== 0) return console.log("Cell is already occupied");
    if (!canInteract)
      return console.log("Not your turn, or the state is loading");

    setCanInteract(false);

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
      setCanInteract(true);
      return;
    }

    if (res.error) {
      console.error(res.error);
      setCanInteract(true);
      return;
    }

    const boardBytes = res.results[0].mutableReferenceOutputs as any;
    const game = Game.parse(new Uint8Array(boardBytes[0][1]));

    setTurn(turn === 1 ? 2 : 1);
    setData(game.board.data);

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
    setCanInteract(true);
  }

  /** Creates a new Game Object and starts a new game. */
  async function newGame(size: 9 | 13 | 19 = 13) {
    setCanInteract(false);
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

  /** Deletes the game object and ends the game. */
  async function endGame() {
    setCanInteract(false);
    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::wrap_up`,
      arguments: [
        txb.object(board_id), // @ts-ignore
        txb.object(caps?.data[0].data?.objectId),
      ],
    });
    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });
    refetch();
  }
}
