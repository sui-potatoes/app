// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Passkey (WebAuthn, SIP-9) exposed as a wallet-standard wallet.
 *
 * Registering the passkey through the wallet standard means dApp Kit treats it
 * like any other wallet: `useCurrentAccount`, `useBalance`, the faucet prompt
 * and every sub-app work unchanged. The public key is kept in local storage
 * because the authenticator never returns it, so a returning user reconnects
 * without a WebAuthn prompt; signing always prompts.
 */

import type { ClientWithCoreApi, WalletInitializer } from "@mysten/dapp-kit-core";
import {
    BrowserPasskeyProvider,
    findCommonPublicKey,
    PasskeyKeypair,
    type BrowserPasswordProviderOptions,
} from "@mysten/sui/keypairs/passkey";
import { Transaction } from "@mysten/sui/transactions";
import { fromBase64, toBase64 } from "@mysten/sui/utils";
import {
    getWallets,
    ReadonlyWalletAccount,
    StandardConnect,
    StandardDisconnect,
    StandardEvents,
    SuiSignAndExecuteTransaction,
    SuiSignPersonalMessage,
    SuiSignTransaction,
    type StandardConnectFeature,
    type StandardConnectMethod,
    type StandardDisconnectFeature,
    type StandardDisconnectMethod,
    type StandardEventsFeature,
    type StandardEventsListeners,
    type StandardEventsOnMethod,
    type SuiSignAndExecuteTransactionFeature,
    type SuiSignAndExecuteTransactionMethod,
    type SuiSignPersonalMessageFeature,
    type SuiSignPersonalMessageMethod,
    type SuiSignTransactionFeature,
    type SuiSignTransactionMethod,
    type Wallet,
    type WalletAccount,
} from "@mysten/wallet-standard";

import { NETWORK } from "../constants";

// === Persistence ===

/** Local storage slot for the passkey's public key (per network). */
const STORAGE_KEY = `passkey:${NETWORK}`;

export type StoredPasskey = { publicKey: string; credentialId?: string; createdAt: number };

export function loadStoredPasskey(): StoredPasskey | null {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);
        return raw ? (JSON.parse(raw) as StoredPasskey) : null;
    } catch {
        return null;
    }
}

function saveStoredPasskey(value: StoredPasskey | null) {
    try {
        if (value) localStorage.setItem(STORAGE_KEY, JSON.stringify(value));
        else localStorage.removeItem(STORAGE_KEY);
    } catch (e) {
        console.warn("localStorage write failed:", e);
    }
}

// === WebAuthn provider ===

export type Attachment = "platform" | "cross-platform" | "any";

export const ATTACHMENTS: { value: Attachment; label: string; hint: string }[] = [
    { value: "platform", label: "This device", hint: "Touch ID, iCloud Keychain, Windows Hello" },
    { value: "cross-platform", label: "Security key", hint: "YubiKey, or a phone via QR" },
    { value: "any", label: "Any", hint: "Let the browser offer both" },
];

const RP_NAME = "Pot8os";

/**
 * The SDK defaults to `cross-platform` (security keys). For a laptop the
 * platform authenticator is the one people expect, so the attachment is a choice.
 */
export function makePasskeyProvider(attachment: Attachment) {
    return new BrowserPasskeyProvider(RP_NAME, {
        rp: { id: window.location.hostname, name: RP_NAME },
        authenticatorSelection: {
            authenticatorAttachment: attachment === "any" ? undefined : attachment,
            residentKey: "required",
            userVerification: "required",
        },
    } as BrowserPasswordProviderOptions);
}

function restoreKeypair(): PasskeyKeypair | null {
    const stored = loadStoredPasskey();
    if (!stored) return null;
    return new PasskeyKeypair(
        fromBase64(stored.publicKey),
        makePasskeyProvider("any"),
        stored.credentialId ? fromBase64(stored.credentialId) : undefined,
    );
}

function persist(keypair: PasskeyKeypair) {
    const credentialId = keypair.getCredentialId();
    saveStoredPasskey({
        publicKey: toBase64(keypair.getPublicKey().toRawBytes()),
        credentialId: credentialId ? toBase64(credentialId) : undefined,
        createdAt: Date.now(),
    });
}

// === Wallet ===

export const PASSKEY_WALLET_NAME = "Passkey";

const ICON_SVG =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">' +
    '<rect width="32" height="32" rx="6" fill="#1b1b18"/>' +
    '<circle cx="12" cy="16" r="5" fill="none" stroke="#f8f7f5" stroke-width="2.5"/>' +
    '<path d="M17 16h10M23 16v4M27 16v3" stroke="#f8f7f5" stroke-width="2.5" stroke-linecap="round" fill="none"/>' +
    "</svg>";

const ICON = `data:image/svg+xml;base64,${btoa(ICON_SVG)}` as `data:image/svg+xml;base64,${string}`;

type Features = StandardConnectFeature &
    StandardDisconnectFeature &
    StandardEventsFeature &
    SuiSignTransactionFeature &
    SuiSignAndExecuteTransactionFeature &
    SuiSignPersonalMessageFeature;

type Chain = `${string}:${string}`;

class PasskeyWallet implements Wallet {
    readonly version = "1.0.0" as const;
    readonly name = PASSKEY_WALLET_NAME;
    readonly icon = ICON;

    #clients = new Map<Chain, ClientWithCoreApi>();
    #keypair: PasskeyKeypair | null;
    #accounts: ReadonlyWalletAccount[] = [];
    #listeners = new Set<StandardEventsListeners["change"]>();

    constructor(keypair: PasskeyKeypair | null) {
        this.#keypair = keypair;
        this.#rebuildAccounts();
    }

    get chains(): readonly Chain[] {
        return [...this.#clients.keys()];
    }

    get accounts(): readonly WalletAccount[] {
        return this.#accounts;
    }

    get keypair(): PasskeyKeypair | null {
        return this.#keypair;
    }

    get features(): Features {
        return {
            [StandardConnect]: { version: "1.0.0", connect: this.#connect },
            [StandardDisconnect]: { version: "1.0.0", disconnect: this.#disconnect },
            [StandardEvents]: { version: "1.0.0", on: this.#on },
            [SuiSignTransaction]: { version: "2.0.0", signTransaction: this.#signTransaction },
            [SuiSignAndExecuteTransaction]: {
                version: "2.0.0",
                signAndExecuteTransaction: this.#signAndExecuteTransaction,
            },
            [SuiSignPersonalMessage]: {
                version: "1.1.0",
                signPersonalMessage: this.#signPersonalMessage,
            },
        };
    }

    /** Called by the dApp Kit initializer with one client per configured network. */
    setClients(clients: ClientWithCoreApi[]) {
        this.#clients = new Map(
            clients.map((client) => [`sui:${client.network}` as Chain, client]),
        );
        this.#rebuildAccounts();
        this.#emitChange();
    }

    /** Swap the backing keypair (after create / recover / forget). */
    setKeypair(keypair: PasskeyKeypair | null) {
        this.#keypair = keypair;
        this.#rebuildAccounts();
        this.#emitChange();
    }

    #rebuildAccounts() {
        const keypair = this.#keypair;
        this.#accounts = keypair
            ? [
                  new ReadonlyWalletAccount({
                      address: keypair.getPublicKey().toSuiAddress(),
                      publicKey: keypair.getPublicKey().toSuiBytes(),
                      chains: this.chains,
                      features: [
                          SuiSignTransaction,
                          SuiSignAndExecuteTransaction,
                          SuiSignPersonalMessage,
                      ],
                      icon: ICON,
                  }),
              ]
            : [];
    }

    #emitChange() {
        for (const listener of this.#listeners) {
            listener({ accounts: this.#accounts, chains: this.chains });
        }
    }

    #on: StandardEventsOnMethod = (event, listener) => {
        if (event === "change") this.#listeners.add(listener);
        return () => this.#listeners.delete(listener);
    };

    #connect: StandardConnectMethod = async () => {
        if (!this.#keypair) {
            throw new Error("No passkey on this device yet. Create or recover one first.");
        }
        return { accounts: this.#accounts };
    };

    // Disconnect only ends the dApp Kit session. The stored public key stays, so
    // the next sign-in is one click; `forgetPasskey` removes it explicitly.
    #disconnect: StandardDisconnectMethod = async () => {};

    #signerFor(chain: Chain, account: WalletAccount) {
        const client = this.#clients.get(chain);
        if (!client) throw new Error(`Unsupported chain "${chain}".`);
        const keypair = this.#keypair;
        if (!keypair) throw new Error("No passkey on this device.");
        const address = keypair.toSuiAddress();
        if (address !== account.address) {
            throw new Error(`Account ${account.address} is not the connected passkey ${address}.`);
        }
        return { client, keypair, address };
    }

    #signTransaction: SuiSignTransactionMethod = async ({
        transaction,
        account,
        chain,
        signal,
    }) => {
        signal?.throwIfAborted();
        const { client, keypair, address } = this.#signerFor(chain as Chain, account);
        const tx = Transaction.from(await transaction.toJSON());
        tx.setSenderIfNotSet(address);
        return keypair.signTransaction(await tx.build({ client }));
    };

    #signAndExecuteTransaction: SuiSignAndExecuteTransactionMethod = async ({
        transaction,
        account,
        chain,
        signal,
    }) => {
        signal?.throwIfAborted();
        const { client, keypair, address } = this.#signerFor(chain as Chain, account);
        const tx = Transaction.from(await transaction.toJSON());
        tx.setSenderIfNotSet(address);
        const bytes = await tx.build({ client });
        const result = await keypair.signAndExecuteTransaction({ transaction: tx, client });
        const executed = result.Transaction ?? result.FailedTransaction;
        if (!executed?.effects?.bcs) throw new Error("Transaction returned no effects.");
        return {
            bytes: toBase64(bytes),
            signature: executed.signatures[0],
            digest: executed.digest,
            effects: toBase64(executed.effects.bcs),
        };
    };

    #signPersonalMessage: SuiSignPersonalMessageMethod = async ({ message, account, chain }) => {
        const { keypair } = this.#signerFor((chain ?? this.chains[0]) as Chain, account);
        return keypair.signPersonalMessage(message);
    };
}

// === Singleton and public API ===

let wallet: PasskeyWallet | null = null;

/** The app-wide passkey wallet, created lazily from local storage. */
export function getPasskeyWallet(): PasskeyWallet {
    wallet ??= new PasskeyWallet(restoreKeypair());
    return wallet;
}

/** dApp Kit initializer: registers the passkey wallet alongside Enoki and extensions. */
export function passkeyWalletInitializer(): WalletInitializer {
    return {
        id: "passkey-wallet-initializer",
        initialize({ networks, getClient }) {
            const instance = getPasskeyWallet();
            instance.setClients(networks.map((network) => getClient(network)));
            return { unregister: getWallets().register(instance) };
        },
    };
}

/** Whether a passkey public key is stored on this device. */
export function hasStoredPasskey(): boolean {
    return loadStoredPasskey() !== null;
}

/** Create a fresh credential on the authenticator and make it the wallet's account. */
export async function createPasskey(attachment: Attachment): Promise<PasskeyKeypair> {
    const keypair = await PasskeyKeypair.getPasskeyInstance(makePasskeyProvider(attachment));
    persist(keypair);
    getPasskeyWallet().setKeypair(keypair);
    return keypair;
}

/**
 * Recover a passkey created earlier on this origin whose public key is not stored
 * here (new device, cleared storage). Two signatures over distinct messages each
 * yield up to four candidate P-256 keys; the intersection is the real one.
 */
export async function recoverPasskey(): Promise<PasskeyKeypair> {
    const provider = makePasskeyProvider("any");
    const first = await PasskeyKeypair.signAndRecover(
        provider,
        new TextEncoder().encode("pot8os passkey recovery #1"),
    );
    const second = await PasskeyKeypair.signAndRecover(
        provider,
        new TextEncoder().encode("pot8os passkey recovery #2"),
    );
    const publicKey = findCommonPublicKey(first, second);
    const keypair = new PasskeyKeypair(publicKey.toRawBytes(), provider);
    persist(keypair);
    getPasskeyWallet().setKeypair(keypair);
    return keypair;
}

/** Drop the stored public key. The credential itself stays in the authenticator. */
export function forgetPasskey() {
    saveStoredPasskey(null);
    getPasskeyWallet().setKeypair(null);
}
