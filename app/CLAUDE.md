# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
pnpm dev          # start dev server
pnpm build        # type-check + build (tsc && vite build)
pnpm lint         # eslint (typescript-eslint + react-hooks), zero warnings tolerance
pnpm prettify     # format with prettier
pnpm preview      # preview production build
```

## Environment

Requires a `.env` file with:

```
VITE_ENOKI_API_KEY=<key>
```

Node.js 24 (`.nvmrc`; `engines.node` is what Vercel reads — Node 20 is no longer supported there) and pnpm 9. The app targets Sui **testnet** only. The Google OAuth client ID lives in `src/constants.ts`.

## Architecture

This is a React 19 + TypeScript + Vite single-page app for on-chain games built on the [Sui](https://sui.io) blockchain (testnet), using the Sui TypeScript SDK 2.x (`@mysten/sui`) and dApp Kit 2.x (`@mysten/dapp-kit-react`).

### Core wiring (`src/sui.ts`)

- `dAppKit` — created with `createDAppKit` from `@mysten/dapp-kit-react`; one `SuiGrpcClient` (gRPC-web) per network, Enoki zkLogin wallets registered via `enokiWalletsInitializer`.
- `graphqlClient` — `SuiGraphQLClient`, used only for the Move-function-filtered transaction history in go-game's `useOpenGames` (gRPC `listTransactions` returns nothing for that filter on the public fullnode).

Provider stack (`main.tsx`): `QueryClientProvider` (TanStack Query) → `DAppKitProvider` → `BrowserRouter` → `App`.

### Authentication

zkLogin via the Enoki **wallet-standard wallets** (`registerEnokiWallets` model): `useGoogleSignIn()` (`src/hooks/useGoogleSignIn.ts`) connects the Google Enoki wallet — OAuth runs in a popup handled by the wallet, there is no redirect-callback handling in the app. The current account comes from `useCurrentAccount()`. Low balances are handled by `FaucetModal.tsx`: it polls `useBalance` and links the public faucet sites. The app does not call the faucet itself — the testnet faucet's V2 endpoint is disabled, and V3 (`requestSuiFromFaucetV3`) needs an argon2d proof-of-work that plain JS solves at ~100 ms/hash against a difficulty of ~6500, i.e. about ten minutes in a browser tab.

### Data fetching & transactions

All on-chain reads go through the gRPC client's **core API** (`useCurrentClient().core.*`) wrapped in TanStack `useQuery`. Shared hooks in `src/hooks/`:

- `useBcsObjects.ts` — `ObjectRef`/`WithRef` types, `useBcsObject` (single object → BCS parse), `useOwnedBcsObjects` (owned objects by type filter → BCS parse + object ref merge). Object `content` arrives as raw BCS `Uint8Array` — no base64 unwrapping.
- `useSignAndExecute.ts` — sign with the connected wallet (`CurrentAccountSigner`), execute via `client.core.signAndExecuteTransaction`, wait for indexing. Throws on `FailedTransaction`.
- `useTransactionExecutor.ts` — wraps `SerialTransactionExecutor` (gas-object caching for rapid sequential transactions) around the connected account; used by go-game and commander.

BCS helpers (`bcs`, `BcsType`, `fromBase64`, `fromHex`) come from `@mysten/sui/bcs` and `@mysten/sui/utils`, never from `@mysten/bcs` directly: a second copy of `@mysten/bcs` makes its nominal `BcsType` incompatible with the one the SDK uses.

Transaction results use the SDK 2.x tagged union (`result.Transaction` / `result.FailedTransaction`); created/mutated objects are located via `effects.changedObjects` plus the `objectTypes` include. Dry-runs use `client.core.simulateTransaction`; Move aborts surface as structured `SimulationError` (`apps/commander/types/abort-codes.ts`).

### Routing & sub-apps

`App.tsx` defines top-level routes and sidebar. Each sub-app lives in `src/apps/<name>/App.tsx` and is registered as a route:

| Route          | App                     |
| -------------- | ----------------------- |
| `/go`          | Go board game           |
| `/character`   | Character/NFT builder   |
| `/commander/*` | Commander tactical game |
| `/libraries`   | Move library docs       |

To add a new sub-app: create `src/apps/<name>/`, add a `NavLink` + `<Route>` in `App.tsx`, and add package/object IDs to `src/constants.ts` (testnet-only — IDs are imported directly from `constants.ts`).

### Styling

Tailwind CSS 4 (via `@tailwindcss/vite`). The runtime theme palette (CSS variables in `index.css`, light/dark via `.dark-theme`) is exposed to Tailwind through `@theme inline` tokens — use `text-accent`, `text-secondary`, `text-foreground`, `text-muted`, `border-line`, `bg-surface`, `bg-overlay` instead of inline `style={{ color: "var(--accent-color)" }}`.
