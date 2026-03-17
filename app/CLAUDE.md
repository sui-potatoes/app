# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
pnpm dev          # start dev server
pnpm build        # type-check + build (tsc && vite build)
pnpm lint         # eslint with zero warnings tolerance
pnpm prettify     # format with prettier
pnpm preview      # preview production build
```

No test script is configured despite `jest` being in devDependencies.

## Environment

Requires a `.env` file with:
```
VITE_ENOKI_API_KEY=<key>
```

The app targets Sui **testnet** only. The Google OAuth client ID is hardcoded in `App.tsx`.

## Architecture

This is a React 19 + TypeScript + Vite single-page app for on-chain games built on the [Sui](https://sui.io) blockchain (testnet).

### Provider stack (`main.tsx`)

Providers wrap the app in this order: `QueryClientProvider` → `SuiClientProvider` (testnet) → `EnokiFlowProvider` (zkLogin) → `BrowserRouter` → `App`.

### Authentication

zkLogin via Google OAuth using `@mysten/enoki`. `App.tsx` handles the OAuth redirect callback (`flow.handleAuthCallback()`), stores the pre-auth URL in `localStorage` under `GO_BACK_KEY` to restore navigation after login, and auto-requests testnet SUI from the faucet for new wallets.

### Routing & sub-apps

`App.tsx` defines top-level routes and sidebar. Each sub-app lives in `src/apps/<name>/App.tsx` and is registered as a route:

| Route | App |
|---|---|
| `/go` | Go board game |
| `/character` | Character/NFT builder |
| `/commander/*` | Commander tactical game |
| `/libraries` | Move library docs |

To add a new sub-app: create `src/apps/<name>/`, add a `NavLink` + `<Route>` in `App.tsx`, and add package/object IDs to `constants.ts` and `networkConfig.ts`.

### On-chain integration

- `constants.ts` — deployed Sui package and shared object IDs for each sub-app
- `networkConfig.ts` — wraps constants into `@mysten/dapp-kit`'s `createNetworkConfig`; use `useNetworkVariable("variableName")` in components to access them
- Transactions are built with `@mysten/sui/transactions` `Transaction` class and signed via `flow.getKeypair({ network: "testnet" })`
- On-chain object data is BCS-decoded directly in the frontend using `@mysten/bcs` schema definitions (see `go-game/App.tsx` for examples)
