# Step 2: Configure ESLint / Prettier / TypeScript

Configure only the tools marked as `missing` or `legacy` in Step 1.
Skip any tool already marked `present` — do not touch its existing config.

---

## ESLint v9+ Flat Config

### 1. Framework Detection

Read `package.json` dependencies (both `dependencies` and `devDependencies`):

| Dependency key | Plugin to include |
|---------------|------------------|
| `react`, `next`, `@vitejs/plugin-react` | `eslint-plugin-react` |
| `next` | `@next/eslint-plugin-next` |
| `typescript` | `typescript-eslint` |
| *(none matched)* | Base JS only |

If detection is ambiguous (e.g., custom framework), ask:
```
What framework does this project use?
  1. React (without Next.js)
  2. Next.js
  3. Vue
  4. None / plain TypeScript
> Enter number
```

### 2. Generate eslint.config.ts

Create `eslint.config.ts` at the project root.

**TypeScript + React (eslint-plugin-react) template:**
```ts
import js from '@eslint/js'
import tseslint from 'typescript-eslint'
import reactPlugin from 'eslint-plugin-react'
import prettierConfig from 'eslint-config-prettier'

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: { react: reactPlugin },
    settings: { react: { version: 'detect' } },
    rules: {},
  },
  prettierConfig,
)
```

**TypeScript + Next.js template:**
```ts
import js from '@eslint/js'
import tseslint from 'typescript-eslint'
import nextPlugin from '@next/eslint-plugin-next'
import prettierConfig from 'eslint-config-prettier'

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: { '@next/next': nextPlugin },
    rules: {
      ...nextPlugin.configs.recommended.rules,
      ...nextPlugin.configs['core-web-vitals'].rules,
    },
  },
  prettierConfig,
)
```

**TypeScript only template:**
```ts
import js from '@eslint/js'
import tseslint from 'typescript-eslint'
import prettierConfig from 'eslint-config-prettier'

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  prettierConfig,
)
```

> `eslint-config-prettier` must always be the **last** config entry to disable style rules
> that conflict with Prettier.

### 3. Install devDependencies

Show the command, then execute:

```bash
# TypeScript + React
pnpm add -D eslint @eslint/js typescript-eslint eslint-plugin-react eslint-config-prettier

# TypeScript + Next.js
pnpm add -D eslint @eslint/js typescript-eslint @next/eslint-plugin-next eslint-config-prettier

# TypeScript only
pnpm add -D eslint @eslint/js typescript-eslint eslint-config-prettier
```

### 4. Add lint script to package.json

Check if `"lint"` script already exists:

- **Exists:** Show the current value and ask:
  ```
  package.json already has "lint": "<current-value>".
  Override with "eslint ."? (y/n)
  ```
  - y → overwrite
  - n → keep existing; record current value as `lintConfig.eslint.command`

- **Does not exist:** Add `"lint": "eslint ."` without asking.

### 5. Handle legacy file

If a legacy config file was found in Step 1 and user chose "migrate":

```
Remove <legacy-file> after creating eslint.config.ts? (y/n, default: y)
```

- y → delete the file
- n → keep it (warn: ESLint v9 will ignore legacy files when flat config is present)

---

## Prettier

### 1. Generate prettier.config.ts

Create `prettier.config.ts` at the project root with sensible defaults:

```ts
import type { Config } from 'prettier'

const config: Config = {
  semi: false,
  singleQuote: true,
  printWidth: 100,
  trailingComma: 'all',
}

export default config
```

> These are defaults. The user can edit the file afterward.

### 2. Install

```bash
pnpm add -D prettier
```

### 3. Add format script

Add `"format": "prettier --write ."` to `package.json` scripts (no confirmation needed if absent).

---

## TypeScript type-check

### 1. Add typecheck script

If `package.json` does not have a script containing `tsc --noEmit`:

Add `"typecheck": "tsc --noEmit"` to scripts.

If a script already contains `tsc --noEmit`, record its name (e.g., `"type-check"`) as `lintConfig.typecheck.command`.

### 2. tsconfig.json

If `tsconfig.json` is missing entirely, ask:
```
No tsconfig.json found. Create a base TypeScript config? (y/n)
```

- y → create a minimal `tsconfig.json`:
  ```json
  {
    "compilerOptions": {
      "target": "ES2022",
      "module": "ESNext",
      "moduleResolution": "Bundler",
      "strict": true,
      "noEmit": true,
      "skipLibCheck": true
    },
    "include": ["**/*.ts", "**/*.tsx"]
  }
  ```
- n → skip. Record `lintConfig.typecheck.configFile` as `null`.

---

## Initial Verification

After all tools are configured, run each installed tool once to confirm it works.
Show the command before running.

```bash
pnpm lint        # ESLint — if errors, offer to run with --fix
pnpm typecheck   # tsc --noEmit
pnpm format      # Prettier --write .
```

For ESLint errors: ask "Run eslint --fix to auto-fix? (y/n)" before applying.

If any command fails to run (e.g., missing node_modules), note it and continue:
```
⚠️  pnpm lint failed — node_modules may not be installed yet.
    Run "pnpm install" first, then re-run /dev setup to verify.
```

---

## lintConfig Registration

After completing configuration, assemble the `lintConfig` object:

```json
{
  "eslint": {
    "version": "v9-flat",
    "configFile": "eslint.config.ts",
    "command": "pnpm lint"
  },
  "prettier": {
    "configFile": "prettier.config.ts",
    "command": "pnpm format"
  },
  "typecheck": {
    "configFile": "tsconfig.json",
    "command": "pnpm typecheck"
  },
  "husky": null
}
```

- Set `null` for any tool that was skipped or already existed (use existing values for `command`).
- `husky` starts as `null`; Step 3 fills it in.
- If an active devlog is present, write this to `_state.json.artifacts.lintConfig`.
