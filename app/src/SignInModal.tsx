// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount, useDAppKit, useWallets } from "@mysten/dapp-kit-react";
import { isEnokiWallet } from "@mysten/enoki";
import { formatAddress } from "@mysten/sui/utils";
import { useEffect, useState, type ReactNode } from "react";

import { useGoogleSignIn } from "./hooks/useGoogleSignIn";
import {
    ATTACHMENTS,
    createPasskey,
    loadStoredPasskey,
    PASSKEY_WALLET_NAME,
    recoverPasskey,
    type Attachment,
} from "./wallets/passkey";

type Props = { open: boolean; onClose: () => void };

function describe(e: unknown): string {
    if (e instanceof DOMException) {
        if (e.name === "NotAllowedError") return "Cancelled or timed out by the authenticator";
        return `${e.name}: ${e.message}`;
    }
    return e instanceof Error ? e.message : String(e);
}

function Card({
    title,
    subtitle,
    children,
}: {
    title: string;
    subtitle: string;
    children: ReactNode;
}) {
    return (
        <section className="flex flex-col gap-4 border border-line p-5">
            <div className="flex flex-col gap-1.5">
                <h3 className="text-sm uppercase tracking-[0.2em] text-foreground">{title}</h3>
                <p className="text-[11px] leading-relaxed text-secondary normal-case">{subtitle}</p>
            </div>
            <div className="mt-auto flex flex-col gap-2">{children}</div>
        </section>
    );
}

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
    const [attachment, setAttachment] = useState<Attachment>("platform");

    const passkeyWallet = wallets.find((w) => w.name === PASSKEY_WALLET_NAME);
    const externalWallets = wallets.filter(
        (w) => !isEnokiWallet(w) && w.name !== PASSKEY_WALLET_NAME,
    );
    const storedPasskey = loadStoredPasskey();

    useEffect(() => {
        if (open && account) onClose();
    }, [open, account, onClose]);

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
    const passkeyContinue = () => run("passkey", connectPasskey);
    const passkeyCreate = () =>
        run("passkey-create", async () => {
            await createPasskey(attachment);
            await connectPasskey();
        });
    const passkeyRecover = () =>
        run("passkey-recover", async () => {
            await recoverPasskey();
            await connectPasskey();
        });
    const connectExternal = (wallet: (typeof wallets)[number]) =>
        run(`wallet:${wallet.name}`, () => dAppKit.connectWallet({ wallet }));

    return (
        <div className="fixed inset-0 z-[200] flex items-center justify-center bg-overlay p-6 backdrop-blur-sm">
            <div className="flex w-full max-w-3xl flex-col gap-6 border border-line bg-surface p-8">
                <div className="flex flex-col gap-1.5">
                    <h2 className="text-sm uppercase tracking-[0.2em] text-foreground">Sign in</h2>
                    <p className="text-[11px] uppercase tracking-wider text-secondary">
                        Pick how you want to hold your account
                    </p>
                </div>

                <div className="h-px w-[60px] bg-line" />

                <div className="grid gap-4 md:grid-cols-3">
                    <Card
                        title="Google"
                        subtitle="zkLogin. Your Google account becomes a Sui address; nothing to install, nothing to back up."
                    >
                        <button
                            className="btn btn-primary"
                            disabled={!canGoogle || !!busy}
                            onClick={google}
                        >
                            {busy === "google" ? "Opening Google…" : "Continue with Google"}
                        </button>
                        {!canGoogle && (
                            <p className="text-[11px] text-secondary normal-case">
                                Google sign-in is not configured in this build.
                            </p>
                        )}
                    </Card>

                    <Card
                        title="Passkey"
                        subtitle="A WebAuthn credential (Touch ID, iCloud Keychain, security key) is the signing key. No extension, no seed phrase."
                    >
                        {storedPasskey ? (
                            <>
                                <button
                                    className="btn btn-primary"
                                    disabled={!!busy}
                                    onClick={passkeyContinue}
                                >
                                    {busy === "passkey" ? "Connecting…" : "Continue with passkey"}
                                </button>
                                <button
                                    className="self-start text-[11px] uppercase tracking-wider text-secondary hover:text-accent"
                                    disabled={!!busy}
                                    onClick={passkeyRecover}
                                >
                                    {busy === "passkey-recover"
                                        ? "sign twice…"
                                        : "use a different passkey"}
                                </button>
                            </>
                        ) : (
                            <>
                                <fieldset className="flex flex-col gap-1.5 text-[11px] uppercase tracking-wider">
                                    {ATTACHMENTS.map((a) => (
                                        <label
                                            key={a.value}
                                            className="flex cursor-pointer items-baseline gap-2"
                                            title={a.hint}
                                        >
                                            <input
                                                type="radio"
                                                name="passkey-attachment"
                                                checked={attachment === a.value}
                                                onChange={() => setAttachment(a.value)}
                                            />
                                            {a.label}
                                        </label>
                                    ))}
                                </fieldset>
                                <button
                                    className="btn btn-primary"
                                    disabled={!!busy}
                                    onClick={passkeyCreate}
                                >
                                    {busy === "passkey-create"
                                        ? "Waiting for authenticator…"
                                        : "Create passkey"}
                                </button>
                                <button
                                    className="self-start text-[11px] uppercase tracking-wider text-secondary hover:text-accent"
                                    disabled={!!busy}
                                    onClick={passkeyRecover}
                                >
                                    {busy === "passkey-recover"
                                        ? "sign twice…"
                                        : "I already have one"}
                                </button>
                            </>
                        )}
                    </Card>

                    <Card
                        title="Wallet"
                        subtitle="Connect a Sui wallet you already use. Browser extensions and the Slush web wallet are detected automatically."
                    >
                        {externalWallets.length === 0 && (
                            <p className="text-[11px] text-secondary normal-case">
                                No wallet detected in this browser.
                            </p>
                        )}
                        {externalWallets.map((w) => (
                            <button
                                key={w.name}
                                className="btn flex items-center gap-3 text-left"
                                disabled={!!busy}
                                onClick={() => connectExternal(w)}
                            >
                                {w.icon && <img src={w.icon} alt="" className="size-4" />}
                                {busy === `wallet:${w.name}` ? "Connecting…" : w.name}
                            </button>
                        ))}
                    </Card>
                </div>

                <div className="flex items-center justify-between gap-4">
                    <p
                        className="min-w-0 truncate text-[11px] text-accent normal-case"
                        title={error ?? ""}
                    >
                        {error ?? (account ? `Signed in as ${formatAddress(account.address)}` : "")}
                    </p>
                    <button className="btn shrink-0" disabled={!!busy} onClick={onClose}>
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    );
}
