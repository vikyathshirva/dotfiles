-- vim.lsp.set_log_level("debug")

local status, nvim_lsp = pcall(require, "lspconfig")
if not status then
  return
end

local util = require("lspconfig.util")

local home = vim.loop.os_homedir()
local java_home = os.getenv("JAVA_HOME") or (home .. "/.jenv/versions/current")
local workspace_folder = home .. "/.workspace"

-- Utility: Format on save
local augroup_format = vim.api.nvim_create_augroup("Format", { clear = true })
local function enable_format_on_save(_, bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup_format,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr })
    end,
  })
end

-- on_attach
local function on_attach(client, bufnr)
  local ok, which_key = pcall(require, "which-key")
  if not ok then
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  end
end

-- Capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Pretty icons
local protocol = require("vim.lsp.protocol")
protocol.CompletionItemKind = {
  '', '', '', '', '', '', '', 'ﰮ', '', '', '', '', '',
  '', '﬌', '', '', '', '', '', '', '', '', 'ﬦ', ''
}

-- Shared diagnostic config
vim.diagnostic.config({
  virtual_text = { prefix = '●' },
  update_in_insert = true,
  float = { source = 'always' },
})
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- ======================
--   LANGUAGE SERVERS
-- ======================

-- TypeScript / Flow
nvim_lsp.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
})
nvim_lsp.flow.setup({ on_attach = on_attach, capabilities = capabilities })

-- Swift
nvim_lsp.sourcekit.setup({ on_attach = on_attach, capabilities = capabilities })

-- Tailwind / CSS / Astro
for _, server in ipairs({ "tailwindcss", "cssls", "astro" }) do
  nvim_lsp[server].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- Lua LS — fixed
nvim_lsp.lua_ls.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local cwd = vim.fn.getcwd()
    if cwd == home then
      vim.notify("Lua LS disabled in home directory (" .. cwd .. ")", vim.log.levels.WARN)
      client.stop()
      return
    end
    on_attach(client, bufnr)
    enable_format_on_save(client, bufnr)
  end,
  root_dir = util.root_pattern(".git", "init.lua", "lua") or vim.fn.getcwd(),
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
