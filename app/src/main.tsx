// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import React from "react";
import ReactDOM from "react-dom/client";
import "@mysten/dapp-kit/dist/index.css";
import "@radix-ui/themes/styles.css";
import "./index.css";

import { SuiClientProvider } from "@mysten/dapp-kit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { networkConfig } from "./networkConfig.ts";

import { EnokiFlowProvider } from "@mysten/enoki/react";
import { BrowserRouter } from "react-router-dom";
import { App } from "./App.tsx";

const enokiApi = import.meta.env.VITE_ENOKI_API_KEY;
const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
    // <React.StrictMode>
        <QueryClientProvider client={queryClient}>
            <SuiClientProvider
                networks={networkConfig}
                defaultNetwork="testnet"
            >
                <EnokiFlowProvider apiKey={enokiApi}>
                    <BrowserRouter>
                        <App />
                    </BrowserRouter>
                </EnokiFlowProvider>
            </SuiClientProvider>
        </QueryClientProvider>
    // </React.StrictMode>,
);
