# `:completion` — enabled modules

`company`, `helm`, `ido`, `ivy` are commented out — `corfu` and `vertico` are this config's picks for the two completion axes (in-buffer code completion vs. minibuffer completion — see the earlier discussion of why these two specifically).

## `corfu (+orderless)`
In-buffer code completion (capf-based). `+orderless` enables space-separated fuzzy/out-of-order matching everywhere it's used (also shared with vertico below).

Other flags available: `+icons` (icons beside completion candidates), `+dabbrev` (enable `dabbrev` as a universal fallback completion source).

No direct requirements.

| Key | Action |
|---|---|
| `C-SPC` | Complete (when not already completing) / insert separator char |
| `TAB` | Indent, or complete on a properly indented line |
| `C-n` / `C-p` | Next / previous candidate |
| `C-S-n` / `C-S-p` | Next / previous doc line |
| `C-h` (evil) | Toggle documentation popup |
| `C-u` / `C-d` (evil) | Next / previous candidate page |
| `RET` | Insert candidate (configurable pass-through if you type your own RET) |
| `C-j` / `C-k` (evil) | Next / previous candidate |
| `C-S-s` | Export candidates to minibuffer |

## `vertico`
Minibuffer completion (M-x, switch-buffer, find-file, search, any `completing-read` prompt) — built on Emacs' native completion machinery instead of a bespoke UI.

Other flags available: `+childframe` (candidates in a GUI child frame, not applicable in a terminal), `+icons` (icons for file/buffer candidates).

Requires `ripgrep` (already installed via `setup.sh` — it's a hard Doom dependency regardless).

| Key | Action |
|---|---|
| `C-j` / `C-k` (evil) | Next / previous candidate |
| `C-M-j` / `C-M-k` (evil) | Next / previous group |
| `C-;` or `SPC a` | Open an `embark-act` menu on the candidate |
| `C-SPC` | Preview the current candidate |
| `C-c C-;` | Export candidate list to a buffer |
| `C-c C-l` | `embark-collect` the candidate list |
| `SPC p f` / `SPC SPC` | Jump to file in project |
| `SPC f f` / `SPC .` | Jump to file from current directory |
| `SPC s i` | Jump to symbol in file |
| `SPC s p` | Search project |
| `SPC s P` | Search another project |
| `SPC s d` | Search this directory |
| `SPC s D` | Search another directory |
| `SPC u` (prefix on the above) | Search with different case-sensitivity/context options |
| `C-c C-e` (in a `wgrep`-backed search-results buffer) | Make the results editable |
| `C-c C-c` / `ZZ` (evil) | Commit edits made to a results buffer |
| `C-c C-k` / `ZQ` (evil) | Abort edits |
