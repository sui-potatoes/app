// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount, useDAppKit, useWallets } from "@mysten/dapp-kit-react";
import { isEnokiWallet } from "@mysten/enoki";
import { useEffect, useState, type ReactNode } from "react";

import { useGoogleSignIn } from "./hooks/useGoogleSignIn";
import {
    createPasskey,
    loadStoredPasskey,
    PASSKEY_WALLET_NAME,
    recoverPasskey,
} from "./wallets/passkey";

type Props = { open: boolean; onClose: () => void };

function describe(e: unknown): string {
    if (e instanceof DOMException && e.name === "NotAllowedError")
        return "Cancelled by the authenticator";
    return e instanceof Error ? e.message : String(e);
}

/** Monochrome line glyphs so the three cards read as one set. */
const GLYPHS = {
    google: (
        <>
            <circle cx="10" cy="7" r="3.5" />
            <path d="M3.5 17a6.5 6.5 0 0 1 13 0" />
        </>
    ),
    passkey: (
        <>
            <circle cx="7" cy="10" r="3.5" />
            <path d="M10.5 10h7M15 10v3M17.5 10v2" />
        </>
    ),
    wallet: (
        <>
            <rect x="2.5" y="5" width="15" height="11" rx="2" />
            <path d="M12.5 10.5h5" />
        </>
    ),
};

function Glyph({ kind }: { kind: keyof typeof GLYPHS }) {
    return (
        <svg
            viewBox="0 0 20 20"
            className="size-5 text-secondary transition-colors group-hover:text-accent"
            fill="none"
            stroke="currentColor"
            strokeWidth="1.25"
            strokeLinecap="round"
        >
            {GLYPHS[kind]}
        </svg>
    );
}

function Card({
    glyph,
    title,
    subtitle,
    children,
    secondary,
}: {
    glyph: keyof typeof GLYPHS;
    title: string;
    subtitle: string;
    children: ReactNode;
    secondary?: ReactNode;
}) {
    return (
        <section className="group flex flex-col gap-5 border border-line p-6 transition-colors hover:border-accent">
            <Glyph kind={glyph} />
            <div className="flex flex-col gap-2">
                <h3 className="text-sm uppercase tracking-[0.2em] text-foreground">{title}</h3>
                <p className="text-[12px] leading-relaxed text-secondary normal-case">{subtitle}</p>
            </div>
            <div className="mt-auto flex flex-col gap-2">{children}</div>
            {/* fixed-height slot keeps the primary buttons aligned across cards */}
            <div className="flex min-h-4 justify-center text-[10px] uppercase tracking-[0.15em] text-secondary">
                {secondary}
            </div>
        </section>
    );
}

const LINK = "transition-colors hover:text-accent disabled:text-muted";

/**
 * Shell-level sign-in prompt: one card per method. Google is zkLogin through
 * Enoki, Passkey is the WebAuthn wallet in `wallets/passkey.ts`, Wallet is any
 * wallet-standard wallet the browser exposes (extension or Slush web wallet).
 * Closes itself as soon as an account is connected.
 */
export function SignInModal({ open, onClose }: Props) {
    const dAppKit = useDAppKit();
    const wallets = useWallets();
    const account = useCurrentAccount();
    const { canSignIn: canGoogle, signIn: signInWithGoogle } = useGoogleSignIn();

    const [busy, setBusy] = useState<string | null>(null);
    const [error, setError] = useState<string | null>(null);

    const passkeyWallet = wallets.find((w) => w.name === PASSKEY_WALLET_NAME);
    const externalWallets = wallets.filter(
        (w) => !isEnokiWallet(w) && w.name !== PASSKEY_WALLET_NAME,
    );
    const hasPasskey = loadStoredPasskey() !== null;

    useEffect(() => {
        if (open && account) onClose();
    }, [open, account, onClose]);

    useEffect(() => {
        if (!open) return;
        const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
        window.addEventListener("keydown", onKey);
        return () => window.removeEventListener("keydown", onKey);
    }, [open, onClose]);

    if (!open) return null;

    async function run(name: string, fn: () => Promise<unknown>) {
        setBusy(name);
        setError(null);
        try {
            await fn();
        } catch (e) {
            console.warn(e);
            setError(describe(e));
        } finally {
            setBusy(null);
        }
    }

    async function connectPasskey() {
        if (!passkeyWallet) throw new Error("Passkey wallet is not registered");
        await dAppKit.connectWallet({ wallet: passkeyWallet });
    }

    const google = () => run("google", signInWithGoogle);
    // Attachment "any" defers to the browser's own chooser (Touch ID, key, phone).
    const passkey = () =>
        run("passkey", async () => {
            if (!hasPasskey) await createPasskey("any");
            await connectPasskey();
        });
    const recover = () =>
        run("recover", async () => {
            await recoverPasskey();
            await connectPasskey();
        });
    const external = (wallet: (typeof wallets)[number]) =>
        run(wallet.name, () => dAppKit.connectWallet({ wallet }));

    const label = (name: string, idle: string, active: string) => (busy === name ? active : idle);

    return (
        <div
            className="fixed inset-0 z-[200] flex items-center justify-center bg-overlay p-6 backdrop-blur-sm"
            onClick={onClose}
        >
            <div
                className="flex w-full max-w-2xl flex-col gap-6 border border-line bg-surface p-8"
                onClick={(e) => e.stopPropagation()}
            >
                <div className="flex items-baseline justify-between gap-4">
                    <div className="flex flex-col gap-1.5">
                        <h2 className="text-sm uppercase tracking-[0.2em] text-foreground">
                            Sign in
                        </h2>
                        <p className="text-[11px] uppercase tracking-wider text-secondary">
                            Pick how you want to hold your account
                        </p>
                    </div>
                    <button
                        className={`text-[11px] uppercase tracking-[0.15em] text-secondary ${LINK}`}
                        onClick={onClose}
                    >
                        esc
                    </button>
                </div>

                <div className="grid gap-4 md:grid-cols-3">
                    <Card
                        glyph="google"
                        title="Google"
                        subtitle="zkLogin. Your Google account becomes a Sui address. Nothing to install, nothing to back up."
                        secondary={!canGoogle && "not configured"}
                    >
                        <button
                            className="btn w-full"
                            disabled={!canGoogle || !!busy}
                            onClick={google}
                        >
                            {label("google", "Continue", "Opening…")}
                        </button>
                    </Card>

                    <Card
                        glyph="passkey"
                        title="Passkey"
                        subtitle="Touch ID, iCloud Keychain or a security key is the signing key. No extension, no seed phrase."
                        secondary={
                            <button className={LINK} disabled={!!busy} onClick={recover}>
                                {label(
                                    "recover",
                                    hasPasskey ? "use a different passkey" : "I already have one",
                                    "sign twice…",
                                )}
                            </button>
                        }
                    >
                        <button className="btn w-full" disabled={!!busy} onClick={passkey}>
                            {label("passkey", hasPasskey ? "Continue" : "Create", "Waiting…")}
                        </button>
                    </Card>

                    <Card
                        glyph="wallet"
                        title="Wallet"
                        subtitle="A Sui wallet you already use. Extensions and the Slush web wallet are detected automatically."
                        secondary={externalWallets.length === 0 && "none detected"}
                    >
                        {externalWallets.map((w) => (
                            <button
                                key={w.name}
                                className="btn flex w-full items-center justify-center gap-2"
                                disabled={!!busy}
                                onClick={() => external(w)}
                            >
                                {w.icon && (
                                    <img src={w.icon} alt="" className="size-3.5 rounded-full" />
                                )}
                                {label(w.name, w.name, "Connecting…")}
                            </button>
                        ))}
                    </Card>
                </div>

                <p
                    className="min-h-4 truncate text-[11px] uppercase tracking-wider text-accent"
                    title={error ?? ""}
                >
                    {error}
                </p>
            </div>
        </div>
    );
}
