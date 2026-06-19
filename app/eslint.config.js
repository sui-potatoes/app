import js from "@eslint/js";
import reactHooks from "eslint-plugin-react-hooks";
import globals from "globals";
import tseslint from "typescript-eslint";

export default tseslint.config({ ignores: ["dist"] }, js.configs.recommended, {
    files: ["**/*.{ts,tsx}"],
    extends: [...tseslint.configs.recommended],
    languageOptions: { globals: globals.browser },
    plugins: { "react-hooks": reactHooks },
    rules: {
        "react-hooks/rules-of-hooks": "error",
        // the engine and BCS-heavy code legitimately uses `any` in places
        "@typescript-eslint/no-explicit-any": "off",
        // `{}` is used as an intentional "no payload" marker in event maps
        "@typescript-eslint/no-empty-object-type": ["error", { allowObjectTypes: "always" }],
        "@typescript-eslint/no-unused-vars": [
            "error",
            { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
        ],
    },
});
