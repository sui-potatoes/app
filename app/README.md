# Potatoes Web App

React 19 + TypeScript + Vite single-page app for the Potatoes on-chain games on Sui testnet. It talks to the chain over gRPC (`SuiGrpcClient`) with GraphQL for the one transaction-history query, and signs users in through Enoki zkLogin wallets.

## Requirements

- Node.js 24 (`.nvmrc`; Vercel builds pick it from `engines.node`)
- pnpm 9 (`packageManager` in `package.json`)
- a `.env` with `VITE_ENOKI_API_KEY=<key>`

## Running the application

`pnpm dev` starts the dev server, `pnpm build` type-checks and builds, `pnpm lint` and `pnpm prettify` keep the code tidy.

## Structure

The base application ([App.tsx](./src/App.tsx)) manages routing, sign-in and the low-balance faucet prompt. Each app lives in its own directory under [apps](./src/apps/) and is mounted as a route.

## Adding a new application

1. Create a new directory in [apps](./src/apps/).
2. Add a `NavLink` and a `<Route>` in [App.tsx](./src/App.tsx).
3. Put package and object IDs into [constants.ts](./src/constants.ts).

See [CLAUDE.md](./CLAUDE.md) for the architecture overview.
