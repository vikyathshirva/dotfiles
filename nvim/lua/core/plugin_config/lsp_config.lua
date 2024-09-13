--vim.lsp.set_log_level("debug")

local status, nvim_lsp = pcall(require, "lspconfig")
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
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  --local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  --buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }


  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  --buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  --buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
end

--protocol.CompletionItemKind = {
--  '', -- Text
--  '', -- Method
--  '', -- Function
--  '', -- Constructor
--  '', -- Field
--  '', -- Variable
--  '', -- Class
--  'ﰮ', -- Interface
--  '', -- Module
--  '', -- Property
--  '', -- Unit
--  '', -- Value
--  '', -- Enum
--  '', -- Keyword
--  '﬌', -- Snippet
--  '', -- Color
--  '', -- File
--  '', -- Reference
--  '', -- Folder
--  '', -- EnumMember
--  '', -- Constant
--  '', -- Struct
--  '', -- Event
--  'ﬦ', -- Operator
--  '', -- TypeParameter
--}

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

nvim_lsp.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,

  --  settings = {
  --    java = {
  --      format = {
  --        settings = {
  --          -- Use Google Java style guidelines for formatting
  --          -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
  --          -- and place it in the ~/.local/share/eclipse directory
  --          url = "/.local/share/eclipse/eclipse-java-google-style.xml",
  --          profile = "GoogleStyle",
  --        },
  --      },
  --      signatureHelp = { enabled = true },
  --      contentProvider = { preferred = 'fernflower' },  -- Use fernflower to decompile library code
  --      -- Specify any completion options
  --      completion = {
  --        favoriteStaticMembers = {
  --          "org.hamcrest.MatcherAssert.assertThat",
  --          "org.hamcrest.Matchers.*",
  --          "org.hamcrest.CoreMatchers.*",
  --          "org.junit.jupiter.api.Assertions.*",
  --          "java.util.Objects.requireNonNull",
  --          "java.util.Objects.requireNonNullElse",
  --          "org.mockito.Mockito.*"
  --        },
  --        filteredTypes = {
  --          "com.sun.*",
  --          "io.micrometer.shaded.*",
  --          "java.awt.*",
  --          "jdk.*", "sun.*",
  --        },
  --      },
  --      -- Specify any options for organizing imports
  --      sources = {
  --        organizeImports = {
  --          starThreshold = 9999;
  --          staticStarThreshold = 9999;
  --        },
  --      },
  --      -- How code generation should act
  --      codeGeneration = {
  --        toString = {
  --          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
  --        },
  --        hashCodeEquals = {
  --          useJava7Objects = true,
  --        },
  --        useBlocks = true,
  --      },
  --      -- If you are developing in projects with different Java versions, you need
  --      -- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
  --      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  --      -- And search for `interface RuntimeOption`
  --      -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
  --      configuration = {
  --        runtimes = {
  --          {
  --            name = "JavaSE-17",
  --            path = home .. "/.asdf/installs/java/corretto-17.0.4.9.1",
  --          },
  --          {
  --            name = "JavaSE-11",
  --            path = home .. "/.asdf/installs/java/corretto-11.0.16.9.1",
  --          },
  --          {
  --            name = "JavaSE-1.8",
  --            path = home .. "/.asdf/installs/java/corretto-8.352.08.1"
  --          },
  --        }
  --      }
  --    }
  --  },
  -- cmd is the command that starts the language server. Whatever is placed
  -- here is what is passed to the command line to execute jdtls.
  -- Note that eclipse.jdt.ls must be started with a Java version of 17 or higher
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  -- for the full list of options
  --  cmd = {
  --    home .. "/.asdf/installs/java/corretto-17.0.4.9.1/bin/java",
  --    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  --    '-Dosgi.bundles.defaultStartLevel=4',
  --    '-Declipse.product=org.eclipse.jdt.ls.core.product',
  --    '-Dlog.protocol=true',
  --    '-Dlog.level=ALL',
  --    '-Xmx4g',
  --    '--add-modules=ALL-SYSTEM',
  --    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
  --    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
  --    -- If you use lombok, download the lombok jar and place it in ~/.local/share/eclipse
  --    '-javaagent:' .. home .. '/.local/share/eclipse/lombok.jar',
  --
  --    -- The jar file is located where jdtls was installed. This will need to be updated
  --    -- to the location where you installed jdtls
  --    '-jar', vim.fn.glob('/opt/homebrew/Cellar/jdtls/1.18.0/libexec/plugins/org.eclipse.equinox.launcher_*.jar'),
  --
  --    -- The configuration for jdtls is also placed where jdtls was installed. This will
  --    -- need to be updated depending on your environment
  --    '-configuration', '/opt/homebrew/Cellar/jdtls/1.18.0/libexec/config_mac',
  --
  --    -- Use the workspace_folder defined above to store data for this project
  --    '-data', workspace_folder,
  --  },
}


nvim_lsp.sourcekit.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

nvim_lsp.lua_ls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    enable_format_on_save(client, bufnr)
  end,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },

      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
    },
  },
}

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
