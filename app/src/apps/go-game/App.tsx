import "./go-game.css";
import { Board as PlayableBoard } from "./Board";
import { useEffect, useState } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { Transaction } from "@mysten/sui/transactions";
import { bcs } from "@mysten/sui/bcs";
import { fromB64 } from "@mysten/bcs";
import { Link, useNavigate, useParams } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";

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

    const [account, setAccount] = useState<typeof Account | any>();
    const [canInteract, setCanInteract] = useState(false);
    const [turn, setTurn] = useState<1 | 2>(1);
    const [game, setGame] = useState<typeof Game.$inferType>();
    const [data, setData] = useState<number[][]>(
        Array(9).fill(Array(9).fill(0)),
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
            setAccount(
                // @ts-ignore
                Account.parse(fromB64(accounts?.data[0].data?.bcs?.bcsBytes!)),
            );
            setCanInteract(true);
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
        setCanInteract(true);
        setGame(game);
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

    // No game found
    if (urlGameId && !game) return <div>Loading...</div>;

    // Account exists
    if (!urlGameId)
        return (
            <>
                <ul className="my-games">
                    <li className="list-title" style={{ listStyle: "none" }}>
                        My Games
                    </li>
                    {account &&
                        (account.games as string[]).map((game, i) => {
                            return (
                                <li key={`game-${i}`}>
                                    <Link to={`/go/${game}`}>
                                        {formatAddress(game)}
                                    </Link>
                                </li>
                            );
                        })}
                    <hr style={{ width: "100px" }} />
                    <li style={{ listStyle: "none" }}>
                        <button
                            disabled={!canInteract}
                            onClick={() => newGame(9)}
                            style={{ listStyle: "none" }}
                        >
                            New 9x9
                        </button>
                    </li>
                    <li style={{ listStyle: "none" }}>
                        <button
                            disabled={!canInteract}
                            onClick={() => newGame(13)}
                            style={{ listStyle: "none" }}
                        >
                            New 13x13
                        </button>
                    </li>
                    <li style={{ listStyle: "none" }}>
                        <button
                            disabled={!canInteract}
                            onClick={() => newGame(19)}
                        >
                            New 19x19
                        </button>
                    </li>
                    <li
                        className="loader"
                        style={{
                            visibility: canInteract ? "hidden" : "visible",
                        }}
                    ></li>
                </ul>
            </>
        );

    if (!game) return <div>Loading...</div>;

    const players = [];
    game.players.player1 && players.push(game.players.player1);
    game.players.player2 && players.push(game.players.player2);

    const isMyGame = players.includes(account?.id);
    const myColor = game.players.player1 === account?.id ? 1 : 2;
    const isMyTurn = isMyGame && turn === myColor;
    const lastMove = game.board.moves.slice(-1)[0];
    const size = game.board.size as 9 | 13 | 19;

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
                    {!players.includes(account?.id) && players.length == 1 && (
                        <button
                            disabled={!canInteract || !account}
                            onClick={() => joinGame()}
                        >
                            Join?{" "}
                            {!account ? "(You have to sign in first)" : ""}
                        </button>
                    )}
                </p>
                <p style={{ padding: "0 10px" }}>
                    {players.length == 1 && "Waiting for players"}
                </p>
                <p style={{ padding: "0 10px" }}>
                    {isMyGame && (isMyTurn ? "Your turn" : "Opponent's turn")}
                </p>
                <div
                    className="loader"
                    style={{
                        visibility: canInteract ? "hidden" : "visible",
                        margin: "10px 0px 0px 10px",
                    }}
                ></div>
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

        const inspect = new Transaction();
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

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::play`,
            arguments: [
                tx.object(game.id),
                tx.object(account.id),
                tx.pure.u8(x),
                tx.pure.u8(y),
                tx.object("0x6"),
            ],
        });

        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        console.log("move played");

        await client.waitForTransaction({ digest: result.digest });
        await fetchGame();
        setCanInteract(true);
    }

    /** Creates a new Game Object and starts a new game. */
    async function newGame(size: 9 | 13 | 19 = 13) {
        setCanInteract(false);
        console.log("Creating new game");
        const tx = new Transaction();
        const accArg = account
            ? tx.object(account.id)
            : tx.moveCall({
                  target: `${packageId}::game::new_account`,
              });

        tx.moveCall({
            target: `${packageId}::game::new`,
            arguments: [accArg, tx.pure.u8(size)],
        });

        // if there wasn't an account, we need to create one
        if (!account) {
            tx.moveCall({
                target: `${packageId}::game::keep`,
                arguments: [accArg],
            });
        }

        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        const { objectChanges } = await client.waitForTransaction({
            digest: result.digest,
            timeout: 10000,
            pollInterval: 500,
            options: { showObjectChanges: true },
        });

        if (!objectChanges) {
            console.log("No object changes");
            return navigate(`/go`);
        }

        const change = objectChanges.find(
            (c) =>
                c.type === "created" &&
                c.objectType === `${packageId}::game::Game`,
        );

        if (change?.type !== "created") {
            console.log("No game created");
            return navigate(`/go`);
        }

        return navigate(`/go/${change.objectId}`);
    }

    async function joinGame() {
        setCanInteract(false);
        if (!game) return console.log("Game not found");

        const tx = new Transaction();
        const accArg = account
            ? tx.object(account.id)
            : tx.moveCall({
                  target: `${packageId}::game::new_account`,
              });

        tx.moveCall({
            target: `${packageId}::game::join`,
            arguments: [tx.object(game.id), tx.object(account.id)],
        });

        if (!account) {
            tx.moveCall({
                target: `${packageId}::game::keep`,
                arguments: [accArg],
            });
        }

        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        await client.waitForTransaction({ digest: result.digest });
        await refetch();
    }

    /** Deletes the game object and ends the game. */
    async function endGame() {
        setCanInteract(false);
        if (!game) return console.log("No game found");
        if (!account) return console.log("Account not found");
        if (!isMyGame) return console.log("Not your game");

        const action =
            game.players.player1 && game.players.player2 ? "quit" : "wrap_up";

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::${action}`,
            arguments: [tx.object(game.id), tx.object(account.id)],
        });
        const result = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            transaction: tx,
        });

        await client.waitForTransaction({ digest: result.digest });
        navigate(`/go`);
    }
}
