// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Passkey demo — a WebAuthn account (SIP-9) on Sui testnet, step by step.
 *
 * The passkey itself lives in `wallets/passkey.ts` and is registered with dApp
 * Kit as a wallet, so signing in with it from the sidebar is the same account.
 * This page exposes the mechanics: create / recover, fund from the faucet or a
 * connected wallet, sign a message and a transfer, and log every step.
 */

import {
    useCurrentAccount,
    useCurrentClient,
    useDAppKit,
    useWallets,
} from "@mysten/dapp-kit-react";
import { FaucetRateLimitError, getFaucetHost, requestSuiFromFaucetV2 } from "@mysten/sui/faucet";
import type { PasskeyKeypair } from "@mysten/sui/keypairs/passkey";
import { Transaction } from "@mysten/sui/transactions";
import { formatAddress, fromBase64, isValidSuiAddress, MIST_PER_SUI } from "@mysten/sui/utils";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect, useState, type ReactNode } from "react";

import { NETWORK } from "../../constants";
import { explorerUrl } from "../../explorer";
import { useSignAndExecute } from "../../hooks/useSignAndExecute";
import {
    ATTACHMENTS,
    createPasskey,
    forgetPasskey,
    getPasskeyWallet,
    loadStoredPasskey,
    PASSKEY_WALLET_NAME,
    recoverPasskey,
    type Attachment,
} from "../../wallets/passkey";

// === Helpers ===

const FAUCETS = ["https://faucet.sui.io/", "https://faucet.suilearn.io/"];

function formatSui(mist: bigint | undefined): string {
    if (mist === undefined) return "…";
    return (Number(mist) / Number(MIST_PER_SUI)).toFixed(4);
}

function parseSui(value: string): bigint | null {
    const n = Number(value);
    if (!Number.isFinite(n) || n <= 0) return null;
    return BigInt(Math.round(n * Number(MIST_PER_SUI)));
}

function describe(e: unknown): string {
    if (e instanceof DOMException) {
        // WebAuthn surfaces user cancellation / timeouts as NotAllowedError.
        if (e.name === "NotAllowedError") return "Cancelled or timed out by the authenticator";
        if (e.name === "SecurityError") return `rpId does not match this origin (${e.message})`;
        return `${e.name}: ${e.message}`;
    }
    return e instanceof Error ? e.message : String(e);
}

function hex(byte: number): string {
    return `0x${byte.toString(16).padStart(2, "0")}`;
}

type Entry = { at: number; kind: "info" | "ok" | "error"; text: string; link?: string };

// === UI bits ===

function Card({ title, children }: { title: string; children: ReactNode }) {
    return (
        <section className="flex flex-col gap-4 border border-line bg-surface p-5">
            <h2 className="text-[11px] uppercase tracking-[0.2em] text-secondary">{title}</h2>
            {children}
        </section>
    );
}

function Row({ label, children }: { label: string; children: ReactNode }) {
    return (
        <div className="flex items-baseline justify-between gap-3 text-[12px]">
            <dt className="shrink-0 text-secondary">{label}</dt>
            <dd className="min-w-0 truncate text-right text-foreground">{children}</dd>
        </div>
    );
}

const INPUT = "w-full border border-line bg-transparent px-3 py-2 text-sm text-foreground";

// === Page ===

export default function App() {
    const client = useCurrentClient();
    const dAppKit = useDAppKit();
    const wallets = useWallets();
    const account = useCurrentAccount();
    const signAndExecute = useSignAndExecute();
    const queryClient = useQueryClient();

    const [attachment, setAttachment] = useState<Attachment>("platform");
    const [keypair, setKeypair] = useState<PasskeyKeypair | null>(() => getPasskeyWallet().keypair);
    const [busy, setBusy] = useState<string | null>(null);
    const [log, setLog] = useState<Entry[]>([]);
    const [copied, setCopied] = useState(false);
    const [platformAvailable, setPlatformAvailable] = useState<boolean | null>(null);

    const [topUpAmount, setTopUpAmount] = useState("0.5");
    const [sendAmount, setSendAmount] = useState("0.1");
    const [recipient, setRecipient] = useState("");
    const [message, setMessage] = useState("hello from a passkey");

    const address = keypair?.getPublicKey().toSuiAddress() ?? null;
    const supported =
        typeof window !== "undefined" && window.isSecureContext && "PublicKeyCredential" in window;

    // The passkey is itself a wallet now; a "top up" has to come from another one.
    const otherWallets = wallets.filter((w) => w.name !== PASSKEY_WALLET_NAME);
    const accountIsPasskey = !!account && account.address === address;

    const push = useCallback((kind: Entry["kind"], text: string, link?: string) => {
        setLog((l) => [{ at: Date.now(), kind, text, link }, ...l].slice(0, 60));
    }, []);

    // Platform authenticator availability is a hint for the attachment choice.
    useEffect(() => {
        if (!supported) return;
        PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()
            .then(setPlatformAvailable)
            .catch(() => setPlatformAvailable(null));
    }, [supported]);

    // Prefill the recipient with the connected wallet once it appears.
    useEffect(() => {
        if (account && !accountIsPasskey && !recipient) setRecipient(account.address);
    }, [account, accountIsPasskey, recipient]);

    const balance = useQuery({
        queryKey: ["passkey-balance", address],
        enabled: !!address,
        refetchInterval: 5_000,
        queryFn: async () => {
            const { balance } = await client.core.getBalance({ owner: address! });
            return BigInt(balance.balance);
        },
    });

    function refreshBalance() {
        queryClient.invalidateQueries({ queryKey: ["passkey-balance"] });
    }

    /** Wrap an action: set busy, log errors, always clear busy. */
    async function run(name: string, fn: () => Promise<void>) {
        setBusy(name);
        try {
            await fn();
        } catch (e) {
            console.warn(e);
            push("error", describe(e));
        } finally {
            setBusy(null);
        }
    }

    // === Passkey lifecycle ===

    const create = () =>
        run("create", async () => {
            push(
                "info",
                `Asking the browser for a new ${attachment} credential (rpId ${window.location.hostname})…`,
            );
            const kp = await createPasskey(attachment);
            const pk = kp.getPublicKey();
            setKeypair(kp);
            push(
                "ok",
                `Credential created. P-256 public key ${pk.toRawBytes().length} B → address ${pk.toSuiAddress()}`,
            );
        });

    const recover = () =>
        run("recover", async () => {
            push(
                "info",
                "Recovery: signing two messages, recovering up to four P-256 keys from each, and intersecting…",
            );
            const kp = await recoverPasskey();
            setKeypair(kp);
            push("ok", `Recovered ${kp.getPublicKey().toSuiAddress()}`);
        });

    function forget() {
        forgetPasskey();
        setKeypair(null);
        push(
            "info",
            "Forgot the public key on this device. The credential itself still lives in the authenticator; use Recover to get it back.",
        );
    }

    async function copyAddress() {
        if (!address) return;
        try {
            await navigator.clipboard.writeText(address);
            setCopied(true);
            setTimeout(() => setCopied(false), 1500);
        } catch (e) {
            console.warn("clipboard write failed:", e);
        }
    }

    // === Funding ===

    const faucet = () =>
        run("faucet", async () => {
            if (!address) return;
            push("info", "Requesting testnet SUI from the faucet…");
            try {
                await requestSuiFromFaucetV2({ host: getFaucetHost(NETWORK), recipient: address });
                push("ok", "Faucet accepted the request; the balance updates within a few seconds");
            } catch (e) {
                if (e instanceof FaucetRateLimitError) {
                    push(
                        "error",
                        `Faucet rate-limited. Use ${FAUCETS[0]} or top up from a wallet.`,
                    );
                    return;
                }
                throw e;
            }
        });

    const connect = (wallet: (typeof wallets)[number]) =>
        run("connect", async () => {
            push("info", `Connecting ${wallet.name}…`);
            await dAppKit.connectWallet({ wallet });
            push("ok", `Connected ${wallet.name}`);
        });

    const disconnect = () =>
        run("disconnect", async () => {
            await dAppKit.disconnectWallet();
            push("info", "Wallet disconnected");
        });

    const topUp = () =>
        run("topup", async () => {
            if (!address || !account) return;
            const mist = parseSui(topUpAmount);
            if (!mist) throw new Error("Enter a positive amount");
            push(
                "info",
                `Sending ${topUpAmount} SUI from the connected wallet to the passkey address…`,
            );
            const tx = new Transaction();
            const [coin] = tx.splitCoins(tx.gas, [mist]);
            tx.transferObjects([coin], address);
            const result = await signAndExecute(tx);
            push("ok", `Top-up executed: ${result.digest}`, explorerUrl(result.digest));
            refreshBalance();
        });

    // === Signing with the passkey ===

    const signMessage = () =>
        run("message", async () => {
            if (!keypair) return;
            const bytes = new TextEncoder().encode(message);
            push("info", "Asking the authenticator to sign a personal message…");
            const { signature } = await keypair.signPersonalMessage(bytes);
            const raw = fromBase64(signature);
            const ok = await keypair.getPublicKey().verifyPersonalMessage(bytes, signature);
            push(
                ok ? "ok" : "error",
                `Signature ${raw.length} B, scheme flag ${hex(raw[0])}, local verify = ${ok}`,
            );
        });

    const send = () =>
        run("send", async () => {
            if (!keypair || !address) return;
            const mist = parseSui(sendAmount);
            if (!mist) throw new Error("Enter a positive amount");
            if (!isValidSuiAddress(recipient))
                throw new Error("Recipient is not a valid Sui address");

            const tx = new Transaction();
            tx.setSender(address);
            const [coin] = tx.splitCoins(tx.gas, [mist]);
            tx.transferObjects([coin], recipient);

            push(
                "info",
                "Building: resolving gas coins owned by the passkey address and estimating the budget…",
            );
            const bytes = await tx.build({ client });
            push(
                "info",
                `Transaction is ${bytes.length} B. The authenticator signs blake2b(intent ‖ bytes) as the WebAuthn challenge…`,
            );

            const { signature } = await keypair.signTransaction(bytes);
            const raw = fromBase64(signature);
            push(
                "ok",
                `Signature ${raw.length} B (flag ${hex(raw[0])}: authenticatorData + clientDataJSON + secp256r1 sig + pubkey)`,
            );

            const ok = await keypair.getPublicKey().verifyTransaction(bytes, signature);
            push(ok ? "ok" : "error", `Local verification against the stored public key: ${ok}`);

            push("info", "Submitting to testnet…");
            const result = await client.core.executeTransaction({
                transaction: bytes,
                signatures: [signature],
                include: { effects: true },
            });
            if (result.FailedTransaction) {
                throw new Error(
                    `Transaction failed: ${result.FailedTransaction.status.error?.message}`,
                );
            }
            const digest = result.Transaction.digest;
            push("ok", `Executed ${digest}`, explorerUrl(digest));
            await client.core.waitForTransaction({ digest });
            refreshBalance();
        });

    // === Render ===

    const stored = loadStoredPasskey();
    const lowBalance = balance.data !== undefined && balance.data < MIST_PER_SUI / 100n;

    return (
        <div className="flex flex-col gap-8 py-4 md:py-8 max-w-5xl">
            <header className="flex flex-col gap-2">
                <p className="text-[11px] uppercase tracking-[0.28em] text-secondary">
                    Sui · {NETWORK} · passkeys (SIP-9)
                </p>
                <h1 className="text-2xl font-light lowercase tracking-tight text-foreground">
                    passkey account demo
                </h1>
                <p className="max-w-xl text-sm leading-relaxed text-secondary normal-case">
                    A WebAuthn credential is a P-256 key. Sui derives an address from it and
                    verifies the authenticator's signature on-chain, so the browser's passkey is the
                    wallet. No extension, no seed phrase. The same passkey is offered on the sign-in
                    screen.
                </p>
                {!supported && (
                    <p className="text-sm text-accent normal-case">
                        WebAuthn is unavailable here. Open this page in a secure context (localhost
                        or https) in a browser with passkey support.
                    </p>
                )}
            </header>

            <div className="grid gap-6 md:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]">
                <div className="flex flex-col gap-6 min-w-0">
                    {/* 1. Account */}
                    <Card title="1 · Passkey account">
                        {!keypair ? (
                            <>
                                <fieldset className="flex flex-col gap-2 text-sm">
                                    {ATTACHMENTS.map((a) => (
                                        <label
                                            key={a.value}
                                            className="flex items-baseline gap-3 cursor-pointer"
                                        >
                                            <input
                                                type="radio"
                                                name="attachment"
                                                checked={attachment === a.value}
                                                onChange={() => setAttachment(a.value)}
                                            />
                                            <span className="uppercase tracking-wider">
                                                {a.label}
                                            </span>
                                            <span className="text-[11px] text-secondary normal-case">
                                                {a.hint}
                                                {a.value === "platform" &&
                                                    platformAvailable === false &&
                                                    " · not available on this device"}
                                            </span>
                                        </label>
                                    ))}
                                </fieldset>
                                <div className="flex flex-wrap gap-2">
                                    <button
                                        className="btn btn-primary"
                                        disabled={!supported || !!busy}
                                        onClick={create}
                                    >
                                        {busy === "create"
                                            ? "Waiting for authenticator…"
                                            : "Create passkey"}
                                    </button>
                                    <button
                                        className="btn"
                                        disabled={!supported || !!busy}
                                        onClick={recover}
                                    >
                                        {busy === "recover" ? "Sign twice…" : "Recover existing"}
                                    </button>
                                </div>
                                <p className="text-[11px] text-secondary normal-case">
                                    Recover is for a passkey created earlier on this origin whose
                                    public key is no longer stored here. It needs two signatures.
                                </p>
                            </>
                        ) : (
                            <>
                                <dl className="flex flex-col gap-2">
                                    <Row label="Address">
                                        <button
                                            onClick={copyAddress}
                                            className="hover:text-accent"
                                            title={address ?? ""}
                                        >
                                            {formatAddress(address!)}{" "}
                                            <span className="text-[10px] uppercase tracking-wider text-muted">
                                                {copied ? "copied" : "copy"}
                                            </span>
                                        </button>
                                        {" · "}
                                        <a
                                            className="hover:text-accent"
                                            href={explorerUrl(address!)}
                                            target="_blank"
                                            rel="noreferrer"
                                        >
                                            explorer ↗
                                        </a>
                                    </Row>
                                    <Row label="Balance">
                                        {formatSui(balance.data)} SUI
                                        {balance.isFetching && (
                                            <span className="ml-1.5 text-muted">·</span>
                                        )}
                                    </Row>
                                    <Row label="Public key">
                                        <span
                                            className="font-mono normal-case"
                                            title={keypair.getPublicKey().toBase64()}
                                        >
                                            {keypair.getPublicKey().toBase64().slice(0, 20)}… (33 B,
                                            compressed P-256)
                                        </span>
                                    </Row>
                                    <Row label="Credential id">
                                        {stored?.credentialId
                                            ? "pinned (allowCredentials)"
                                            : "discoverable only"}
                                    </Row>
                                    <Row label="Scheme flag">
                                        {hex(keypair.getPublicKey().flag())}
                                    </Row>
                                    <Row label="Signed in">
                                        {accountIsPasskey ? "yes, as this passkey" : "no"}
                                    </Row>
                                </dl>
                                <div className="flex flex-wrap gap-2">
                                    <button className="btn" disabled={!!busy} onClick={faucet}>
                                        {busy === "faucet" ? "Requesting…" : "Faucet"}
                                    </button>
                                    <button className="btn" disabled={!!busy} onClick={forget}>
                                        Forget on this device
                                    </button>
                                </div>
                                {lowBalance && (
                                    <p className="text-[11px] text-secondary normal-case">
                                        Low balance. Faucet above, or{" "}
                                        {FAUCETS.map((url, i) => (
                                            <span key={url}>
                                                {i > 0 && " · "}
                                                <a
                                                    href={url}
                                                    target="_blank"
                                                    rel="noreferrer"
                                                    className="hover:text-accent"
                                                >
                                                    {url
                                                        .replace(/^https?:\/\//, "")
                                                        .replace(/\/$/, "")}{" "}
                                                    ↗
                                                </a>
                                            </span>
                                        ))}
                                        , or top up from a wallet below.
                                    </p>
                                )}
                            </>
                        )}
                    </Card>

                    {/* 2. Top up from a wallet */}
                    <Card title="2 · Top up from your wallet">
                        {!account || accountIsPasskey ? (
                            <div className="flex flex-col gap-2">
                                {accountIsPasskey && (
                                    <p className="text-[11px] text-secondary normal-case">
                                        You are signed in as this passkey. Connect another wallet to
                                        fund it (this replaces the current session).
                                    </p>
                                )}
                                {otherWallets.length === 0 && (
                                    <p className="text-sm text-secondary normal-case">
                                        No wallets detected. Install a Sui browser wallet to fund
                                        the passkey from it.
                                    </p>
                                )}
                                {otherWallets.map((w) => (
                                    <button
                                        key={w.name}
                                        className="btn flex items-center gap-3 text-left"
                                        disabled={!!busy}
                                        onClick={() => connect(w)}
                                    >
                                        {w.icon && <img src={w.icon} alt="" className="size-4" />}
                                        Connect {w.name}
                                    </button>
                                ))}
                            </div>
                        ) : (
                            <>
                                <dl className="flex flex-col gap-2">
                                    <Row label="Wallet">{formatAddress(account.address)}</Row>
                                </dl>
                                <div className="flex gap-2">
                                    <input
                                        className={INPUT}
                                        type="number"
                                        min="0"
                                        step="0.1"
                                        value={topUpAmount}
                                        onChange={(e) => setTopUpAmount(e.target.value)}
                                        placeholder="SUI"
                                    />
                                    <button
                                        className="btn btn-primary shrink-0"
                                        disabled={!keypair || !!busy}
                                        onClick={topUp}
                                    >
                                        {busy === "topup" ? "Signing…" : "Send to passkey"}
                                    </button>
                                </div>
                                <button
                                    className="self-start text-[11px] uppercase tracking-wider text-secondary hover:text-accent"
                                    disabled={!!busy}
                                    onClick={disconnect}
                                >
                                    disconnect
                                </button>
                            </>
                        )}
                    </Card>

                    {/* 3. Sign with the passkey */}
                    <Card title="3 · Sign with the passkey">
                        <div className="flex flex-col gap-2">
                            <input
                                className={INPUT}
                                type="text"
                                value={recipient}
                                onChange={(e) => setRecipient(e.target.value)}
                                placeholder="recipient 0x…"
                                spellCheck={false}
                            />
                            <div className="flex gap-2">
                                <input
                                    className={INPUT}
                                    type="number"
                                    min="0"
                                    step="0.01"
                                    value={sendAmount}
                                    onChange={(e) => setSendAmount(e.target.value)}
                                    placeholder="SUI"
                                />
                                <button
                                    className="btn btn-primary shrink-0"
                                    disabled={!keypair || !!busy}
                                    onClick={send}
                                >
                                    {busy === "send" ? "Waiting…" : "Transfer"}
                                </button>
                            </div>
                        </div>
                        <div className="h-px w-[60px] bg-line" />
                        <div className="flex gap-2">
                            <input
                                className={INPUT}
                                type="text"
                                value={message}
                                onChange={(e) => setMessage(e.target.value)}
                                placeholder="message"
                            />
                            <button
                                className="btn shrink-0"
                                disabled={!keypair || !!busy}
                                onClick={signMessage}
                            >
                                {busy === "message" ? "Waiting…" : "Sign message"}
                            </button>
                        </div>
                    </Card>
                </div>

                {/* Log */}
                <Card title="Log">
                    {log.length === 0 ? (
                        <p className="text-sm text-secondary normal-case">
                            Nothing yet. Create a passkey to start.
                        </p>
                    ) : (
                        <ol className="flex flex-col gap-2 text-[12px] normal-case">
                            {log.map((entry) => (
                                <li key={entry.at + entry.text} className="flex gap-3 leading-snug">
                                    <span className="shrink-0 font-mono text-muted">
                                        {new Date(entry.at).toLocaleTimeString()}
                                    </span>
                                    <span
                                        className={`min-w-0 break-words ${
                                            entry.kind === "error"
                                                ? "text-accent"
                                                : entry.kind === "ok"
                                                  ? "text-foreground"
                                                  : "text-secondary"
                                        }`}
                                    >
                                        {entry.text}
                                        {entry.link && (
                                            <>
                                                {" "}
                                                <a
                                                    href={entry.link}
                                                    target="_blank"
                                                    rel="noreferrer"
                                                    className="underline hover:text-accent"
                                                >
                                                    view ↗
                                                </a>
                                            </>
                                        )}
                                    </span>
                                </li>
                            ))}
                        </ol>
                    )}
                </Card>
            </div>
        </div>
    );
}
