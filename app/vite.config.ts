import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react-swc";
import Markdown from "vite-plugin-react-markdown";

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [Markdown(), tailwindcss(), react()],
});
