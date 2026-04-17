# Claude Context for Neovim Config

## Problem Tracking Convention

When working in this directory (`~/.config/nvim`):

1. **Any nvim problem/error encountered** - create a new `.md` file in `problemsnsol/`
2. **Filename format:** `<short-description>.md`
3. **Initial status:** Always mark as `Status: PENDING`
4. **Update to `Status: SOLVED`** only when solution is confirmed working in the same session

### Template for problem files:

```markdown
# [Problem Title]

**Status:** PENDING

## Problem

[Describe the error/issue]

## Cause

[Root cause if known, or "Under investigation"]

## Solution

[Fix if found, or "TBD"]

## Date

[YYYY-MM-DD]
```
