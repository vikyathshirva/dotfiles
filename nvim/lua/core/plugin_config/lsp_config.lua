local util = require("lspconfig.util")

local home = vim.loop.os_homedir()
local java_home = os.getenv("JAVA_HOME") or (home .. "/.jenv/versions/current")
local workspace_folder = home .. "/.workspace"

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
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Format on save autocommand
local augroup_format = vim.api.nvim_create_augroup("Format", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup_format,
  callback = function(args)
    local bufnr = args.buf
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup_format,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
})

-- LspAttach autocommand for keymaps and custom setup
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    
    -- Check if lua_ls is trying to attach in home directory
    if client and client.name == "lua_ls" then
      local cwd = vim.fn.getcwd()
      if cwd == home then
        vim.notify("Lua LS disabled in home directory (" .. cwd .. ")", vim.log.levels.WARN)
        vim.lsp.buf_client_detach(bufnr, args.data.client_id)
        return
      end
    end
    
    -- Set up keymaps
    local ok, which_key = pcall(require, "which-key")
    if not ok then
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    end
  end,
})

-- ======================
--   LANGUAGE SERVERS
-- ======================

-- TypeScript / Flow
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
})
vim.lsp.config("flow", {
  capabilities = capabilities,
})

-- Swift
vim.lsp.config("sourcekit", {
  capabilities = capabilities,
})

-- Tailwind / CSS / Astro
for _, server in ipairs({ "tailwindcss", "cssls", "astro" }) do
  vim.lsp.config(server, {
    capabilities = capabilities,
  })
end

-- Lua LS
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  root_dir = function(fname)
    local root = util.root_pattern(".git", "init.lua", "lua")(fname)
    if root and root ~= home then
      return root
    end
    return nil
  end,
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

-- Enable all configured servers
vim.lsp.enable({
  "ts_ls", "flow", "sourcekit", "tailwindcss", "cssls", "astro", "lua_ls"
})
