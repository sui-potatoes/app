import "./go-game.css";
import { Board as PlayableBoard } from "./Board";
import { useEffect, useState } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { bcs } from "@mysten/sui.js/bcs";
import { fromB64 } from "@mysten/bcs";
import { Link, useNavigate, useParams } from "react-router-dom";
import { formatAddress } from "@mysten/sui.js/utils";

const Move = bcs.struct("Move", {
  x: bcs.u8(),
  y: bcs.u8(),
});

const Account = bcs.struct("Account", {
  id: bcs.Address,
  games: bcs.vector(bcs.Address),
});

const Players = bcs.struct("Players", {
  player1: bcs.option(bcs.Address),
  player2: bcs.option(bcs.Address),
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
  players: Players,
  // Board is incomplete parsing, so must go last!
  board: Board,
});

export function App() {
  const { id: urlGameId } = useParams();
  const flow = useEnokiFlow();
  const zkLogin = useZkLogin();
  const client = useSuiClient();
  const packageId = useNetworkVariable("goPackageId");
  const navigate = useNavigate();

  const size = 13;
  const [account, setAccount] = useState<typeof Account | any | null>(null);
  const [canInteract, setCanInteract] = useState(false);
  const [turn, setTurn] = useState<1 | 2>(1);
  const [game, setGame] = useState<typeof Game.$inferType | null>(null);
  const [data, setData] = useState<number[][]>(
    Array(size).fill(Array(size).fill(0)),
  );
  const { data: accounts, refetch } = useSuiClientQuery("getOwnedObjects", {
    owner: zkLogin.address!,
    filter: { MoveModule: { package: packageId, module: "game" } },
    options: { showContent: true, showBcs: true },
  });

  const { data: gameData, refetch: fetchGame } = useSuiClientQuery(
    "getObject",
    {
      id: urlGameId || "",
      options: { showBcs: true },
    },
    {
      enabled: !!urlGameId,
    },
  );

  useEffect(() => {
    // can create a new game if there are no games
    if (!gameData && !accounts?.data.length) {
      setCanInteract(true);
    }

    if (accounts?.data.length) {
      // @ts-ignore
      setAccount(Account.parse(fromB64(accounts?.data[0].data?.bcs?.bcsBytes)));
    }

    // if there is a cap but no game, we're waiting for the fetch
    if (!urlGameId) return;
    if (!gameData?.data) return;

    const game = Game.parse(
      fromB64((gameData?.data!.bcs! as { bcsBytes: string }).bcsBytes),
    );

    // game is found, set the board state
    setData(game.board.data);
    setTurn(game.board.turn as 1 | 2);
    setGame(game);
    setCanInteract(true);
  }, [gameData, accounts, urlGameId]);

  useEffect(() => {
    const id = setInterval(fetchGame, 1000);
    return () => clearInterval(id);
  }, []);

  // pardon my copipasta
  useEffect(() => {
    if (!game) return;

    const players = [];
    game?.players.player1 && players.push(game.players.player1);
    game?.players.player2 && players.push(game.players.player2);
  }, [turn]);

  // Not logged in
  if (!zkLogin.address) return <div>Connect wallet</div>;

  // No account, create one
  if (!account)
    return <button className="button" onClick={() => newAccount()}>Create account</button>;

  // No game found
  if (urlGameId && !game) return <div>Loading...</div>;

  // Account exists
  if (!urlGameId && account)
    return (
      <>
        <ul className="my-games">
          <li className="list-title" style={{listStyle: 'none'}}>My Games</li>
          {(account.games as string[]).map((game, i) => {
            return (
              <li key={`game-${i}`}>
                <Link to={`/go/${game}`}>{formatAddress(game)}</Link>
              </li>
            );
          })}
          <button disabled={!canInteract} onClick={() => newGame()}>
            New game
          </button>
        </ul>
      </>
    );

  if (!game) return <div>Loading...</div>;

  const players = [];
  game?.players.player1 && players.push(game.players.player1);
  game?.players.player2 && players.push(game.players.player2);

  const isMyGame = players.includes(account.id);
  const myColor = game.players.player1 === account.id ? 1 : 2;
  const isMyTurn = isMyGame && turn === myColor;
  const lastMove = game.board.moves.slice(-1)[0];

  return (
    game && (
      <>
        <PlayableBoard
          disabled={!canInteract && !isMyTurn}
          size={size}
          data={data}
          lastMove={lastMove}
          turn={myColor}
          zoom={(19 - size / 2) * 10 + "%"}
          onClick={handleClick}
        />
        <p>
          {!players.includes(account.id) && players.length == 1 && (
            <button disabled={!canInteract} onClick={() => joinGame()}>
              Join?
            </button>
          )}
        </p>
        <p style={{ padding: "0 10px" }}>
          {players.length == 1 && "Waiting for players"}
          {isMyGame && (isMyTurn ? "Your turn" : "Opponent's turn")}
        </p>
        <div className="buttons">
          {game && (
            <button>
              <a
                type="button"
                className="explorer-link"
                href={`https://suiscan.xyz/testnet/object/${game.id}`}
              >
                Game (Explorer)
              </a>
            </button>
          )}
          <button
            style={{ visibility: isMyGame ? "visible" : "hidden" }}
            disabled={!canInteract}
            className="explorer-link"
            onClick={endGame}
          >
            Quit / End game
          </button>
        </div>
      </>
    )
  );

  async function handleClick(x: number, y: number) {
    if (!isMyTurn) return console.log("Not your turn");
    if (data[x][y] !== 0) return console.log("Cell is already occupied");
    if (!account) return console.log("Account not found");
    if (!game) return console.log("Game not found");
    if (!canInteract)
      return console.log("Not your turn, or the state is loading");

    setCanInteract(false);

    const inspect = new TransactionBlock();
    inspect.moveCall({
      target: `${packageId}::game::board_state`,
      arguments: [
        inspect.object(game.id),
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
    const updatedGame = Game.parse(new Uint8Array(boardBytes[0][1]));

    setTurn(updatedGame.board.turn as 1 | 2);
    setData(updatedGame.board.data);

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::play`,
      arguments: [
        txb.object(game.id),
        txb.object(account.id),
        txb.pure.u8(x),
        txb.pure.u8(y),
        txb.object("0x6"),
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

  async function newAccount() {
    setCanInteract(false);
    const txb = new TransactionBlock();
    txb.moveCall({ target: `${packageId}::game::new_account` });
    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });
    refetch();
    setAccount(null);
  }

  /** Creates a new Game Object and starts a new game. */
  async function newGame(size: 9 | 13 | 19 = 13) {
    if (!account) return console.log("Account not found");
    setCanInteract(false);
    console.log("Creating new game");
    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::new`,
      arguments: [txb.object(account.id), txb.pure.u8(size)],
    });
    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });
    refetch();
    navigate(`/go`);
  }

  async function joinGame() {
    setCanInteract(false);
    if (!account) return console.log("Account not found");
    if (!game) return console.log("Game not found");

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::join`,
      arguments: [txb.object(game.id), txb.object(account.id)],
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
    if (!game) return console.log("No game found");
    if (!account) return console.log("Account not found");
    if (!isMyGame) return console.log("Not your game");

    const action =
      game.players.player1 && game.players.player2 ? "quit" : "wrap_up";

    const txb = new TransactionBlock();
    txb.moveCall({
      target: `${packageId}::game::${action}`,
      arguments: [txb.object(game.id), txb.object(account.id)],
    });
    await flow.sponsorAndExecuteTransactionBlock({
      network: "testnet", // @ts-ignore
      client,
      transactionBlock: txb,
    });
    refetch();
  }
}
