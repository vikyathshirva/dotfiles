# Telescope E220 Error with {} in Filenames

**Status:** SOLVED

## Problem

When using Telescope's live_grep (`;r`) and scrolling through results, Neovim throws:

```
E5108: Error executing lua: Vim:E220: Missing }.
stack traceback:
    [C]: in function 'expand'
    ...telescope.nvim/lua/telescope/previewers/buffer_previewer.lua:169: in function 'buffer_previewer_maker'
    ...
```

This happens when previewing files that have `{}` in their path (common in JS/TS projects with dynamic routes like `{id}.tsx`, `{slug}.js`).

## Cause

`vim.fn.expand()` interprets `{}` as **brace expansion patterns** (similar to shell brace expansion like `{a,b,c}`). When Telescope's previewer calls `expand("/path/{slug}/file.ts")`, Vim tries to parse `{slug}` as a pattern and fails with `E220: Missing }`.

## Solution

Add this monkey-patch at the top of `lua/core/plugin_config/telescope.lua` (before requiring telescope):

```lua
-- Monkey-patch to fix E220 error with {} in filenames during preview
-- Override vim.fn.expand to handle braces safely
local original_expand = vim.fn.expand
vim.fn.expand = function(path, ...)
  if type(path) == "string" and path:match("[{}]") then
    -- Don't use expand on paths with literal {} - just make absolute
    if path:match("^/") or path:match("^~") then
      -- Already absolute or home-relative, use fnamemodify instead
      return vim.fn.fnamemodify(path, ":p")
    elseif not path:match("^%%") and not path:match("^#") and not path:match("^<") then
      -- Looks like a file path, not a vim expression - make absolute
      local cwd = vim.fn.getcwd()
      return cwd .. "/" .. path
    end
  end
  return original_expand(path, ...)
end
```

## Why It Works

- Detects paths containing `{}` characters
- Bypasses `expand()` for actual file paths and uses `fnamemodify()` instead
- `fnamemodify()` converts to absolute path without pattern interpretation
- Still allows normal vim expressions (`%`, `#`, `<cfile>`, etc.) to work

## Date

2026-03-17
