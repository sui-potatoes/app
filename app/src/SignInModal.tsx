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
        return "Cancelled by the authenticator.";
    return e instanceof Error ? e.message : String(e);
}

const GLYPHS = {
    google: (
        <>
            <circle cx="12" cy="8" r="4" />
            <path d="M4 20a8 8 0 0 1 16 0" />
        </>
    ),
    passkey: (
        <>
            <circle cx="8" cy="12" r="4" />
            <path d="M12 12h9M18 12v3.5M21 12v2.5" />
        </>
    ),
    wallet: (
        <>
            <rect x="3" y="6" width="18" height="13" rx="2.5" />
            <path d="M15 12.5h6" />
        </>
    ),
};

function Glyph({ kind }: { kind: keyof typeof GLYPHS }) {
    return (
        <svg
            viewBox="0 0 24 24"
            className="size-6 shrink-0 text-foreground"
            fill="none"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinecap="round"
        >
            {GLYPHS[kind]}
        </svg>
    );
}

/**
 * One sign-in option: a full-width row that is itself the button. `extra` is
 * rendered under the description for a secondary action and does not trigger
 * the row.
 */
function Option({
    glyph,
    icon,
    title,
    description,
    state,
    disabled,
    onClick,
    extra,
}: {
    glyph?: keyof typeof GLYPHS;
    icon?: string;
    title: string;
    description: string;
    state?: string;
    disabled?: boolean;
    onClick: () => void;
    extra?: ReactNode;
}) {
    return (
        <div
            role="button"
            tabIndex={disabled ? -1 : 0}
            aria-disabled={disabled}
            onClick={() => !disabled && onClick()}
            onKeyDown={(e) => e.key === "Enter" && !disabled && onClick()}
            className={`group flex items-center gap-5 px-6 py-5 text-left transition-colors ${
                disabled
                    ? "opacity-40"
                    : "cursor-pointer hover:bg-brand-dim focus-visible:bg-brand-dim"
            }`}
        >
            {icon ? (
                <img src={icon} alt="" className="size-6 shrink-0 rounded-full" />
            ) : (
                glyph && <Glyph kind={glyph} />
            )}
            <div className="flex min-w-0 flex-1 flex-col gap-1">
                <span className="text-[15px] font-medium text-foreground">{title}</span>
                <span className="text-[13px] leading-snug text-foreground/70">{description}</span>
                {extra && <span className="mt-1 text-[12px]">{extra}</span>}
            </div>
            <span className="shrink-0 text-[13px] text-foreground/50 transition-colors group-hover:text-foreground">
                {state ?? "→"}
            </span>
        </div>
    );
}

/**
 * Shell-level sign-in prompt. Google is zkLogin through Enoki, Passkey is the
 * WebAuthn wallet in `wallets/passkey.ts`, and every other wallet-standard
 * wallet the browser exposes gets a row of its own. Closes itself once an
 * account is connected.
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
        if (busy) return;
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

    const state = (name: string, text: string) => (busy === name ? text : undefined);

    return (
        <div
            className="fixed inset-0 z-[200] flex items-center justify-center bg-overlay p-6 normal-case backdrop-blur-sm"
            onClick={onClose}
        >
            <div
                className="flex w-full max-w-md flex-col border border-line bg-surface"
                onClick={(e) => e.stopPropagation()}
            >
                <div className="flex items-start justify-between gap-4 px-6 pt-6 pb-4">
                    <div className="flex flex-col gap-1">
                        <h2 className="text-xl font-light lowercase tracking-tight text-foreground">
                            sign in
                        </h2>
                        <p className="text-[13px] text-foreground/70">
                            Choose how to hold your account.
                        </p>
                    </div>
                    <button
                        className="text-[13px] text-foreground/50 transition-colors hover:text-foreground"
                        onClick={onClose}
                        aria-label="Close"
                    >
                        ✕
                    </button>
                </div>

                <div className="flex flex-col divide-y divide-line border-t border-line">
                    <Option
                        glyph="google"
                        title="Google"
                        description="zkLogin: your Google account becomes a Sui address. Nothing to install or back up."
                        disabled={!canGoogle}
                        state={state("google", "Opening…")}
                        onClick={() => run("google", signInWithGoogle)}
                    />
                    <Option
                        glyph="passkey"
                        title="Passkey"
                        description="Touch ID, iCloud Keychain or a security key signs for you. No extension, no seed phrase."
                        state={state("passkey", "Waiting…")}
                        // Attachment "any" defers to the browser's own chooser.
                        onClick={() =>
                            run("passkey", async () => {
                                if (!hasPasskey) await createPasskey("any");
                                await connectPasskey();
                            })
                        }
                        extra={
                            <button
                                className="text-foreground/60 normal-case underline underline-offset-4 transition-colors hover:text-foreground"
                                onClick={(e) => {
                                    e.stopPropagation();
                                    run("recover", async () => {
                                        await recoverPasskey();
                                        await connectPasskey();
                                    });
                                }}
                            >
                                {busy === "recover"
                                    ? "Sign twice to recover…"
                                    : hasPasskey
                                      ? "Use a different passkey"
                                      : "I already have one"}
                            </button>
                        }
                    />
                    {externalWallets.map((w) => (
                        <Option
                            key={w.name}
                            icon={w.icon}
                            glyph="wallet"
                            title={w.name}
                            description="A wallet you already use."
                            state={state(w.name, "Connecting…")}
                            onClick={() => run(w.name, () => dAppKit.connectWallet({ wallet: w }))}
                        />
                    ))}
                    {externalWallets.length === 0 && (
                        <Option
                            glyph="wallet"
                            title="Wallet"
                            description="No Sui wallet detected in this browser."
                            disabled
                            onClick={() => {}}
                        />
                    )}
                </div>

                {error && (
                    <p className="border-t border-line px-6 py-3 text-[13px] text-foreground">
                        {error}
                    </p>
                )}
            </div>
        </div>
    );
}
