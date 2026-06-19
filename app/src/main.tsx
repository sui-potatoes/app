// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import ReactDOM from "react-dom/client";
import "./index.css";

import { DAppKitProvider } from "@mysten/dapp-kit-react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter } from "react-router-dom";

import { App } from "./App.tsx";
import { dAppKit } from "./sui.ts";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
    <QueryClientProvider client={queryClient}>
        <DAppKitProvider dAppKit={dAppKit}>
            <BrowserRouter>
                <App />
            </BrowserRouter>
        </DAppKitProvider>
    </QueryClientProvider>,
);
