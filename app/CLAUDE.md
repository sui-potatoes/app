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

The app targets Sui **testnet** only. The Google OAuth client ID lives in `src/constants.ts`.

## Architecture

This is a React 19 + TypeScript + Vite single-page app for on-chain games built on the [Sui](https://sui.io) blockchain (testnet), using the Sui TypeScript SDK 2.x (`@mysten/sui`) and dApp Kit 2.x (`@mysten/dapp-kit-react`).

### Core wiring (`src/sui.ts`)

- `dAppKit` — created with `createDAppKit` from `@mysten/dapp-kit-react`; one `SuiGrpcClient` (gRPC-web) per network, Enoki zkLogin wallets registered via `enokiWalletsInitializer`.
- `graphqlClient` — `SuiGraphQLClient`, used only for queries with no gRPC equivalent (e.g. filtered transaction history in go-game's `useOpenGames`).

Provider stack (`main.tsx`): `QueryClientProvider` (TanStack Query) → `DAppKitProvider` → `BrowserRouter` → `App`.

### Authentication

zkLogin via the Enoki **wallet-standard wallets** (`registerEnokiWallets` model): `useGoogleSignIn()` (`src/hooks/useGoogleSignIn.ts`) connects the Google Enoki wallet — OAuth runs in a popup handled by the wallet, there is no redirect-callback handling in the app. The current account comes from `useCurrentAccount()`. New accounts are auto-topped-up from the testnet faucet in `App.tsx` (`requestSuiFromFaucetV2`).

### Data fetching & transactions

All on-chain reads go through the gRPC client's **core API** (`useCurrentClient().core.*`) wrapped in TanStack `useQuery`. Shared hooks in `src/hooks/`:

- `useBcsObjects.ts` — `ObjectRef`/`WithRef` types, `useBcsObject` (single object → BCS parse), `useOwnedBcsObjects` (owned objects by type filter → BCS parse + object ref merge). Object `content` arrives as raw BCS `Uint8Array` — no base64 unwrapping.
- `useSignAndExecute.ts` — sign with the connected wallet (`CurrentAccountSigner`), execute via `client.core.signAndExecuteTransaction`, wait for indexing. Throws on `FailedTransaction`.
- Commander additionally wraps `SerialTransactionExecutor` (gas-object caching for rapid in-game moves) in `apps/commander/hooks/useTransactionExecutor.ts`.

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
