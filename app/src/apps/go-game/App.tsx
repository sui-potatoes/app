// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./go-game.css";
import { Board } from "./Board";
import { useState, useEffect, useRef, type ReactNode } from "react";
import { useCurrentAccount } from "@mysten/dapp-kit-react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";
import { toast } from "react-hot-toast";
import { GOGAME_PACKAGE_ID as packageId } from "../../constants";
import { explorerUrl } from "../../explorer";
import { useGoogleSignIn } from "../../hooks/useGoogleSignIn";
import { useAccounts } from "./hooks/useAccount";
import { useGame } from "./hooks/useGame";
import { useMyGames } from "./hooks/useMyGames";
import { useOpenGames } from "./hooks/useOpenGames";
import { useGameActions } from "./hooks/useGameActions";
import { applyMove } from "./rules";

const BOARD_SIZES = [9, 13, 19];

const DEMO_BOARD = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0],
    [0, 0, 1, 0, 1, 0, 0, 0, 2, 0, 2, 0, 0],
    [0, 1, 0, 1, 0, 0, 0, 0, 0, 2, 0, 2, 0],
    [0, 0, 1, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0],
    [0, 0, 0, 1, 0, 1, 0, 2, 0, 2, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 1, 0, 2, 0, 2, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0],
    [0, 1, 0, 1, 0, 2, 0, 2, 0, 2, 0, 2, 0],
    [0, 0, 1, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
];

/** A small board-stone glyph used inline in the UI (black / white disc). */
function Stone({ color }: { color: 1 | 2 }) {
    return (
        <span
            className={`inline-block size-2.5 rounded-full border ${
                color === 1 ? "bg-black border-black/40" : "bg-white border-line"
            }`}
        />
    );
}

/** Aligned key/value row for the game-info panel. */
function Row({ label, children }: { label: string; children: ReactNode }) {
    return (
        <div className="flex items-center justify-between gap-3">
            <dt className="text-secondary">{label}</dt>
            <dd className="flex items-center gap-1.5">{children}</dd>
        </div>
    );
}

function timeAgo(ms: number): string {
    const diff = Date.now() - ms;
    const minutes = Math.floor(diff / 60000);
    if (minutes < 1) return "just now";
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    return `${Math.floor(hours / 24)}d ago`;
}

export default function App() {
    const { id: gameId } = useParams();

    if (!gameId) return <Lobby />;
    return <GameView gameId={gameId} />;
}

// ─── Lobby ────────────────────────────────────────────────────────────────────

function Lobby() {
    const navigate = useNavigate();
    const address = useCurrentAccount()?.address;
    const { signIn } = useGoogleSignIn();

    const { data: accounts = [], refetch: refetchAccount } = useAccounts(packageId, address);
    const accountIds = accounts.map((a) => a.id);
    const myGameIds = [...new Set(accounts.flatMap((a) => a.games as string[]))];
    const { data: openGames = [] } = useOpenGames(packageId, accountIds, !!address);
    const { data: myGamesDetails = {} } = useMyGames(myGameIds);
    const actions = useGameActions();

    const [busy, setBusy] = useState(false);

    if (!address) {
        return (
            <div className="flex items-center justify-center relative md:h-[calc(100vh-40px)]">
                <Board
                    disabled
                    size={13}
                    data={DEMO_BOARD}
                    lastMove={{ x: 10, y: 8 }}
                    turn={1}
                    onClick={() => {}}
                />
                <div className="absolute inset-0 z-10 flex items-center justify-center backdrop-blur-sm bg-overlay">
                    <p className="text-sm tracking-wider uppercase text-foreground">
                        <button
                            className="text-brand hover:text-brand uppercase"
                            onClick={() => signIn()}
                        >
                            Sign in
                        </button>{" "}
                        to play
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="flex flex-col gap-3 justify-center md:h-[calc(100vh-40px)] text-sm uppercase tracking-wider leading-tight">
            <div className="flex flex-col md:flex-row gap-8 md:gap-16">
                <div className="flex flex-col gap-3 md:min-w-[300px]">
                    <div>
                        My Games <span className="text-secondary">({myGameIds.length})</span>
                    </div>
                    <div className="w-[60px] h-px bg-line" />
                    {!myGameIds.length ? (
                        <p className="text-secondary">No games yet</p>
                    ) : (
                        <ul className="my-games">
                            {myGameIds.map((id, i) => {
                                const details = myGamesDetails[id];
                                const yourTurn = details && isYourTurn(details);
                                return (
                                    <li
                                        key={`game-${i}`}
                                        className="flex items-baseline gap-3 group"
                                    >
                                        <Link to={`/go/${id}`}>{formatAddress(id)}</Link>
                                        {details && (
                                            <span className="text-secondary text-[11px]">
                                                {details.board.size}×{details.board.size} ·{" "}
                                                {details.players.player1 === details.players.player2
                                                    ? "solo"
                                                    : "versus"}{" "}
                                                · {timeAgo(Number(details.created_at))}
                                            </span>
                                        )}
                                        {yourTurn && (
                                            <span className="text-[11px]" title="your move">
                                                ● your move
                                            </span>
                                        )}
                                    </li>
                                );
                            })}
                        </ul>
                    )}
                </div>
                <div className="flex flex-col gap-3 md:border-l md:pl-8 border-line">
                    <div>
                        Open Games <span className="text-secondary">({openGames.length})</span>
                    </div>
                    <div className="w-[60px] h-px bg-line" />
                    {openGames.length === 0 ? (
                        <p className="text-secondary">No open games</p>
                    ) : (
                        <ul className="my-games">
                            {openGames.map((g) => (
                                <li key={g.id} className="flex items-baseline gap-3">
                                    <Link to={`/go/${g.id}`}>{formatAddress(g.id)}</Link>
                                    <span className="text-secondary text-[11px]">
                                        {g.size}×{g.size} · {timeAgo(g.timestampMs)}
                                    </span>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>
            </div>
            <div className="pt-3">
                <div className="divider w-[200px] mb-4" />
                <div className="flex items-center gap-3">
                    <span className="text-secondary">New game:</span>
                    {BOARD_SIZES.map((size) => (
                        <button
                            key={size}
                            disabled={busy}
                            onClick={() => handleNewGame(size)}
                            className="btn"
                        >
                            {size}×{size}
                        </button>
                    ))}
                </div>
            </div>
            {busy && <div className="spinner" />}
        </div>
    );

    /** Whether it's the user's move in one of their games (solo is always yours). */
    function isYourTurn(details: (typeof myGamesDetails)[string]) {
        if (details.is_over || !details.players.player2) return false;
        if (details.players.player1 === details.players.player2) return true;
        const myColorIsBlack = details.players.player1
            ? accountIds.includes(details.players.player1)
            : false;
        return details.board.is_black === myColorIsBlack;
    }

    async function handleNewGame(size: number) {
        setBusy(true);
        try {
            const newGameId = await actions.newGame(accounts[0] ?? null, size);
            if (newGameId) {
                await toast.success("Game created!");
                await refetchAccount();
                navigate(`/go/${newGameId}`);
            }
        } finally {
            setBusy(false);
        }
    }
}

// ─── Game view ────────────────────────────────────────────────────────────────

function GameView({ gameId }: { gameId: string }) {
    const address = useCurrentAccount()?.address;

    const { data: accounts = [], refetch: refetchAccount } = useAccounts(packageId, address);
    const { data: game, refetch: refetchGame } = useGame(gameId);
    const actions = useGameActions();
    const navigate = useNavigate();

    const [busy, setBusy] = useState(false);
    const [boardData, setBoardData] = useState<number[][]>(Array(9).fill(Array(9).fill(0)));
    const [isBlackTurn, setIsBlackTurn] = useState(true);
    const [lastMove, setLastMove] = useState<{ x: number; y: number } | undefined>();
    const shownMoves = useRef(0);

    // Sync board state from on-chain data, but never overwrite optimistic
    // state with a stale snapshot (polling can lag behind a submitted move)
    useEffect(() => {
        if (!game) return;
        if (game.board.moves.length < shownMoves.current) return;

        shownMoves.current = game.board.moves.length;
        setBoardData(game.board.grid.grid);
        setIsBlackTurn(game.board.is_black);
        const moves = game.board.moves;
        const last = moves.length ? moves[moves.length - 1] : undefined;
        setLastMove(last && { x: last.row, y: last.column });
    }, [game]);

    if (!game) return null;

    const players = [game.players.player1, game.players.player2].filter(Boolean) as string[];
    const isSolo = game.players.player1 === game.players.player2;
    // pick the owned account participating in this game; fall back to the
    // main account for joining as a new player
    const account = accounts.find((a) => players.includes(a.id)) ?? accounts[0] ?? null;
    const isMyGame = account ? players.includes(account.id) : false;
    const myColor = game.players.player1 === account?.id ? "Black" : "White";
    const currentTurn = isBlackTurn ? "Black" : "White";
    const isMyTurn = isMyGame && (isSolo || myColor === currentTurn);
    const size = game.board.size as 9 | 13 | 19;

    return (
        <div className="flex max-md:flex-col max-md:items-center items-center md:h-[calc(100vh-40px)] md:gap-5">
            <div className="max-md:w-full md:flex-1 flex items-center justify-center relative">
                <Board
                    disabled={busy || !isMyTurn || players.length < 2}
                    size={size}
                    data={boardData}
                    lastMove={lastMove}
                    turn={(isBlackTurn ? 1 : 2) as 1 | 2}
                    onClick={handlePlay}
                />
                {game.is_over && (
                    <div className="absolute inset-0 z-10 flex flex-col gap-3 items-center justify-center backdrop-blur-sm bg-overlay">
                        <p className="text-sm tracking-wider uppercase text-secondary">
                            Opponent left the game
                        </p>
                        {isMyGame && (
                            <button
                                disabled={busy}
                                onClick={handleEnd}
                                className="text-accent uppercase"
                            >
                                Wrap Up
                            </button>
                        )}
                    </div>
                )}
                {!game.is_over && players.length < 2 && (
                    <div className="absolute inset-0 z-10 flex flex-col gap-3 items-center justify-center backdrop-blur-sm bg-overlay">
                        <p className="text-sm tracking-wider uppercase text-secondary">
                            Waiting for players
                        </p>
                        <button
                            disabled={busy}
                            onClick={handleJoin}
                            className="text-accent uppercase"
                        >
                            {isMyGame ? "Play Solo" : `Join? ${!account ? "(Sign in first)" : ""}`}
                        </button>
                    </div>
                )}
            </div>
            <div className="flex flex-col gap-4 justify-center text-sm uppercase tracking-wider text-left items-stretch md:w-[210px] md:flex-shrink-0 leading-tight">
                <div className="flex flex-col gap-1.5">
                    <div className="flex items-center gap-2">
                        <Stone color={isBlackTurn ? 1 : 2} />
                        <span>{currentTurn} to play</span>
                    </div>
                    <p className={`text-[11px] ${isMyTurn ? "text-accent" : "text-secondary"}`}>
                        {!isMyGame
                            ? "spectating"
                            : isSolo
                              ? "solo game"
                              : players.length < 2
                                ? "waiting for opponent"
                                : isMyTurn
                                  ? "→ your move"
                                  : "opponent's turn"}
                    </p>
                </div>

                <div className="divider !my-0" />

                <dl className="flex flex-col gap-2 text-[11px]">
                    {isMyGame && (
                        <Row label="You">
                            <Stone color={myColor === "Black" ? 1 : 2} />
                            <span>{myColor}</span>
                        </Row>
                    )}
                    <Row label="Moves">{game.board.moves.length}</Row>
                    <Row label="Captures">
                        <span className="flex items-center gap-2">
                            <Stone color={1} /> {game.board.score.black}
                            <span className="text-muted">/</span>
                            <Stone color={2} /> {game.board.score.white}
                        </span>
                    </Row>
                    <Row label="State">
                        <span className={busy || actions.isExecuting ? "text-accent" : ""}>
                            {busy || actions.isExecuting ? "syncing…" : "on-chain"}
                        </span>
                    </Row>
                </dl>

                <div className="divider !my-0" />

                <div className="flex flex-col gap-2.5 text-[11px]">
                    <a
                        href={explorerUrl(game.id)}
                        target="_blank"
                        className="uppercase hover:text-accent transition-colors"
                    >
                        Explorer ↗
                    </a>
                    {isMyGame && (
                        <button
                            disabled={busy}
                            className="text-left uppercase hover:text-accent transition-colors"
                            onClick={handleEnd}
                        >
                            {isSolo || players.length < 2 ? "End game" : "Resign"}
                        </button>
                    )}
                </div>
                {busy && <div className="spinner" />}
            </div>
        </div>
    );

    async function handlePlay(x: number, y: number) {
        if (busy || !isMyTurn || boardData[x][y] !== 0 || !account || !game) return;

        // show the stone (and local captures) instantly, then lock the board
        // until the transaction is final and its post-state is applied
        setBusy(true);
        shownMoves.current += 1;
        setBoardData(applyMove(boardData, x, y, isBlackTurn ? 1 : 2));
        setIsBlackTurn(!isBlackTurn);
        setLastMove({ x, y });

        try {
            const updated = await actions.play(game, account, x, y);
            if (updated) {
                // authoritative state from the execution response itself
                shownMoves.current = updated.board.moves.length;
                setBoardData(updated.board.grid.grid);
                setIsBlackTurn(updated.board.is_black);
                const moves = updated.board.moves;
                const last = moves.length ? moves[moves.length - 1] : undefined;
                setLastMove(last && { x: last.row, y: last.column });
            } else {
                refetchGame();
            }
        } catch (e) {
            // illegal move or failed transaction — restore on-chain truth
            console.error("move failed:", e);
            shownMoves.current -= 1;
            refetchGame();
        } finally {
            setBusy(false);
        }
    }

    async function handleJoin() {
        setBusy(true);
        try {
            await actions.joinGame(game!, account ?? null);
            await refetchAccount();
            await refetchGame();
        } finally {
            setBusy(false);
        }
    }

    async function handleEnd() {
        if (!account) return;
        setBusy(true);
        try {
            await actions.endGame(game!, account);
            navigate("/go");
        } finally {
            setBusy(false);
        }
    }
}
