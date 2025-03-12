// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { OpenAI } from "openai";
import { EGender, Name } from "@undergroundsociety/cybername-gen";

const openaiKey = import.meta.env.VITE_OPENAI_API_KEY;

export async function useNameGenerator() {
    // if (!openaiKey) {
    const name = new Name(EGender.male);

    return {
        name: `${name.firstname} ${name.lastname}`,
        backstory: "Story locked",
    };
    // }

    const openai = new OpenAI({
        apiKey: openaiKey,
        dangerouslyAllowBrowser: true,
        organization: "org-LbgyoMKieNbw3y0EIFzqHjFH",
        project: "proj_ViXYIpVFHl70ahu6gAXWDeyk",
    });
    const assistantId = "asst_ESENwbgdYzcTnzuJ07kQcb7Q";

    const thread = await openai.beta.threads.create();
    const run = await openai.beta.threads.runs.create(thread.id, {
        assistant_id: assistantId,
        instructions: "",
    });

    let isComplete = false;
    while (!isComplete) {
        let response = await openai.beta.threads.runs.retrieve(thread.id, run.id);
        if (response.status === "completed") {
            isComplete = true;
            break;
        }

        if (response.status === "failed") {
            throw new Error("Failed to generate name");
        }
    }

    const messages = await openai.beta.threads.messages.list(thread.id, {
        limit: 1,
    });

    if (messages.data.length === 0) {
        throw new Error("Failed to generate name");
    }

    const first = messages.data[0].content[0];
    if (first.type !== "text") {
        throw new Error("Failed to generate name");
    }

    // const text = JSON.parse(first.text.value as string);
    // return {
    //     name: text.character_name,
    //     backstory: text.background,
    // }
}
