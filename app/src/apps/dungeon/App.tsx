import "./dungeon.css";
import { Board as PlayableBoard } from "./Board";
import { useEffect, useState } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { Transaction } from "@mysten/sui/transactions";
import { fromB64 } from "@mysten/bcs";
import { Link, useNavigate, useParams } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";
import { toast } from "react-hot-toast";
import { Player } from "./.gen/dungeon/player/structs";
import { Game } from "./.gen/dungeon/game/structs";

export function App() {
    const { id: urlGameId } = useParams();
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const packageId = useNetworkVariable("dungeonPackageId");
    const navigate = useNavigate();

    const [games, setGames] = useState<Game[]>();
    const [game, setGame] = useState<Game>();
    type Cell = "empty" | "exit" | "player";
    const [room, setRoom] = useState<Cell[][]>(); // init with room.size x room.size
    
    const { data, refetch } = useSuiClientQuery("getOwnedObjects", {
        owner: zkLogin.address!,
        filter: { MoveModule: { package: packageId, module: "game" } },
        options: { showContent: true },
    });

    useEffect(() => {
        setGame(game);
    }, [games, urlGameId]);

    useEffect(() => {
        const id = setInterval(refetch, 1000);
        return () => clearInterval(id);
    }, []);

    // No game found
    if (urlGameId && !game) return <div>Loading...</div>;

    // Account exists
    if (!urlGameId)
        return (
            <div className="max-md:flex max-md:flex-col gap-3 max-md:justify-center max-md:items-center">
                <div>
                    My Games
                </div>
                <ul className="my-games px-6">
                    {(games?.map((game) => game.id) as string[]).map((game, i) => {
                        return (
                            <li key={`game-${i}`} className="list-disc">
                                <Link to={`/dungeon/${game}`}>
                                    {formatAddress(game)}
                                </Link>
                            </li>
                        );
                    })}
                </ul>
            </div>
        );

    if (!game) return <div>Loading...</div>;
}
