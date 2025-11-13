--vim.lsp.set_log_level("debug")

local status, nvim_lsp = pcall(require, "lspconfig")
-- At the top of your file, after the requires
local home = os.getenv("HOME")
if not home then
  home = nvim_lsp.fn.expand("~")
end

-- Get JAVA_HOME from environment
local java_home = os.getenv("JAVA_HOME")
if not java_home then
  -- Fallback if JAVA_HOME isn't set
  print("Warning: JAVA_HOME not set. JDTLS might not work correctly.")
  java_home = home .. "/.jenv/versions/current" -- Try a fallback path
end

local workspace_folder = home .. "/.workspace"
if (not status) then return end

local protocol = require('vim.lsp.protocol')

local augroup_format = vim.api.nvim_create_augroup("Format", { clear = true })
local enable_format_on_save = function(_, bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup_format,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr })
    end,
  })
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)


  -- Check if which-key is available
  local status_ok, which_key = pcall(require, "which-key")
  if not status_ok then
    -- Fallback to traditional keymaps if which-key is not available
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    return
  end
end



protocol.CompletionItemKind = {
  '', -- Text
  '', -- Method
  '', -- Function
  '', -- Constructor
  '', -- Field
  '', -- Variable
  '', -- Class
  'ﰮ', -- Interface
  '', -- Module
  '', -- Property
  '', -- Unit
  '', -- Value
  '', -- Enum
  '', -- Keyword
  '﬌', -- Snippet
  '', -- Color
  '', -- File
  '', -- Reference
  '', -- Folder
  '', -- EnumMember
  '', -- Constant
  '', -- Struct
  '', -- Event
  'ﬦ', -- Operator
  '', -- TypeParameter
}
-- Set up completion using nvim_cmp with LSP source
local capabilities = require('cmp_nvim_lsp').default_capabilities()

nvim_lsp.flow.setup {
  on_attach = on_attach,
  capabilities = capabilities
}
nvim_lsp.ts_ls.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  capabilities = capabilities
}
-- nvim_lsp.jdtls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     java = {
--       format = {
--         settings = {
--           url = "/.local/share/eclipse/eclipse-java-google-style.xml",
--           profile = "GoogleStyle",
--         },
--       },
--       signatureHelp = { enabled = true },
--       contentProvider = { preferred = 'fernflower' },
--       completion = {
--         favoriteStaticMembers = {
--           "org.hamcrest.MatcherAssert.assertThat",
--           "org.hamcrest.Matchers.*",
--           "org.hamcrest.CoreMatchers.*",
--           "org.junit.jupiter.api.Assertions.*",
--           "java.util.Objects.requireNonNull",
--           "java.util.Objects.requireNonNullElse",
--           "org.mockito.Mockito.*"
--         },
--         filteredTypes = {
--           "com.sun.*",
--           "io.micrometer.shaded.*",
--           "java.awt.*",
--           "jdk.*", "sun.*",
--         },
--       },
--       sources = {
--         organizeImports = {
--           starThreshold = 9999,
--           staticStarThreshold = 9999,
--         },
--       },
--       codeGeneration = {
--         toString = {
--           template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
--         },
--         hashCodeEquals = {
--           useJava7Objects = true,
--         },
--         useBlocks = true,
--       },
--       -- fixed the configuration section by properly commenting out or removing extra brackets
--       -- configuration = {
--       --   runtimes = {
--       --     {
--       --       name = "javase-17",
--       --       path = home .. "/.asdf/installs/java/corretto-17.0.4.9.1",
--       --     },
--       --     {
--       --       name = "javase-11",
--       --       path = home .. "/.asdf/installs/java/corretto-11.0.16.9.1",
--       --     },
--       --     {
--       --       name = "javase-1.8",
--       --       path = home .. "/.asdf/installs/java/corretto-8.352.08.1"
--       --     },
--       --   }
--       -- }
--     }
--   },
--   cmd = {
--     -- Use JAVA_HOME instead of hardcoded path
--     java_home .. "/bin/java",
--     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--     '-Dosgi.bundles.defaultStartLevel=4',
--     '-Declipse.product=org.eclipse.jdt.ls.core.product',
--     '-Dlog.protocol=true',
--     '-Dlog.level=ALL',
--     '-Xmx4g',
--     '--add-modules=ALL-SYSTEM',
--     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
--     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
--     -- Check if lombok.jar exists
--     '-configuration', '/opt/homebrew/Cellar/jdtls/*/libexec/config_mac',
--     -- Use the workspace folder
--     '-data', workspace_folder,
--   },
-- }

nvim_lsp.sourcekit.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

nvim_lsp.lua_ls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Prevent running in home directory (Lua LS refuses to load it anyway)
    local cwd = vim.fn.getcwd()
    if cwd == vim.loop.os_homedir() then
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
      diagnostics = {
        -- Recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Neovim runtime awareness
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}

-- nvim_lsp.lua_ls.setup {
--   capabilities = capabilities,
--   on_attach = function(client, bufnr)
--     on_attach(client, bufnr)
--     enable_format_on_save(client, bufnr)
--   end,
--   settings = {
--     Lua = {
--       diagnostics = {
--         -- Get the language server to recognize the `vim` global
--         globals = { 'vim' },
--       },

--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = vim.api.nvim_get_runtime_file("", true),
--         checkThirdParty = false
--       },
--     },
--   },
-- }

nvim_lsp.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

nvim_lsp.cssls.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

nvim_lsp.astro.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 4, prefix = "\u{ea71}" },
    severity_sort = true,
  }
)

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = '●'
  },
  update_in_insert = true,
  float = {
    source = 'always', -- Or "if_many"
  },
})
