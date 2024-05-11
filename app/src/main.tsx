import React from "react";
import ReactDOM from "react-dom/client";
import "@mysten/dapp-kit/dist/index.css";
import "@radix-ui/themes/styles.css";

import { SuiClientProvider } from "@mysten/dapp-kit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { networkConfig } from "./networkConfig.ts";

import { EnokiFlowProvider } from "@mysten/enoki/react";
import { BrowserRouter } from "react-router-dom";
import { App } from "./App.tsx";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <SuiClientProvider networks={networkConfig} defaultNetwork="testnet">
        <EnokiFlowProvider apiKey="enoki_public_de660b5b085fcab8b0260d03dfc8cee1">
          <BrowserRouter>
            <App />
          </BrowserRouter>
        </EnokiFlowProvider>
      </SuiClientProvider>
    </QueryClientProvider>
  </React.StrictMode>,
);
