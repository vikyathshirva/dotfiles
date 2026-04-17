require("lazy").setup({
  { "catppuccin/nvim",     name = "catppuccin", priority = 1000 },
  "tpope/vim-commentary",
  "mattn/emmet-vim",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "ellisonleao/gruvbox.nvim",
  {
    {
      "nvimtools/none-ls.nvim",
      config = function()
        local nls = require("null-ls")
        local fmt = nls.builtins.formatting
        local dgn = nls.builtins.diagnostics
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        nls.setup({
          sources = {
            -- # FORMATTING #
            -- fmt.google_java_format.with({ extra_args = { "--aosp" } }),
            -- # DIAGNOSTICS #
            dgn.checkstyle.with({
              extra_args = {
                "-c",
                vim.fn.expand("~/.config/checkstyle/twilio_checkstyle.xml"),
              },
            }),
          },
          on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
              vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ bufnr = bufnr })
                end,
              })
            end
          end,
        })
      end,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        "williamboman/mason.nvim",
        "nvimtools/none-ls.nvim",
      },
      opt = {
        ensure_installed = {
          "checkstyle"
        },
      },
    },
  },
  "dracula/vim",
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", }
  },
  "nvim-lualine/lualine.nvim",
  "nvim-treesitter/nvim-treesitter",
  "vim-test/vim-test",
  "lewis6991/gitsigns.nvim",
  "preservim/vimux",
  "christoomey/vim-tmux-navigator",
  "onsails/lspkind-nvim",
  "tpope/vim-fugitive",
  {
    "ruifm/gitlinker.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("gitlinker").setup({
        opts = {
          remote = nil, -- use default remote
          add_current_line_on_normal_mode = true,
          action_callback = require("gitlinker.actions").open_in_browser,
          print_url = false,
        },
        callbacks = {
          ["github.com"] = require("gitlinker.hosts").get_github_type_url,
          ["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url,
          ["bitbucket.org"] = require("gitlinker.hosts").get_bitbucket_type_url,
          ["code.hq.twilio.com"] = require("gitlinker.hosts").get_github_type_url,
        },
        mappings = "<leader>gx",
      })
      -- Manual mapping for gx
      vim.keymap.set("n", "gx", function()
        require("gitlinker").get_buf_range_url("n")
      end, { desc = "Open line in GitHub" })
      vim.keymap.set("v", "gx", function()
        require("gitlinker").get_buf_range_url("v")
      end, { desc = "Open selection in GitHub" })
    end,
  },
  "tpope/vim-surround",
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup()
      vim.keymap.set("n", "<leader>w", function()
        local win = require("window-picker").pick_window()
        if win then
          vim.api.nvim_set_current_win(win)
        end
      end, { desc = "Pick window" })
    end,
  },
  "stevearc/oil.nvim",
  -- completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "nvimdev/lspsaga.nvim",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
        }
      }
    }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_enable = {
        exclude = {
          'jdlts'
        }
      }
    }
  },
  "neovim/nvim-lspconfig",
  "mfussenegger/nvim-dap",
  "hrsh7th/cmp-buffer",
  "hrsh7th/nvim-cmp",
  {
    "mrcjkb/rustaceanvim",
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
  {
    "vinnymeller/swagger-preview.nvim",
    cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },
    build = "npm i",
    config = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  "nvim-telescope/telescope-file-browser.nvim",
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },
    ft = { "java" },
    config = function()
      local wk = require("which-key")
      local home = os.getenv("HOME")

      local function on_jdtls_attach(client, bufnr)
        wk.register({
          ["<leader>cx"] = { name = "+extract" },
          ["<leader>cxv"] = { function() require("jdtls").extract_variable() end, "Extract Variable" },
          -- more mappings...
        }, { buffer = bufnr })
      end

      local function clear_jdtls_workspace(project_name)
        local ws = home .. "/.cache/jdtls/" .. (project_name or "")
        if ws ~= "" and vim.fn.isdirectory(ws) == 1 then
          local choice = vim.fn.confirm("Clean jdtls workspace for " .. (project_name or "<unknown>") .. "?", "&Yes\n&No",
            1)
          if choice == 1 then
            vim.notify("Cleaning JDTLS workspace: " .. ws, vim.log.levels.INFO)
            os.execute("rm -rf " .. ws)
            os.execute("mkdir -p " .. ws)
          end
        end
      end

      local function get_classpath_sources(module_path)
        local cpfile = module_path .. "/.classpath"
        local sources = {}
        if vim.fn.filereadable(cpfile) == 1 then
          local lines = vim.fn.readfile(cpfile)
          local content = table.concat(lines, "\n")
          for path in string.gmatch(content, 'kind="src" path="([^"]+)"') do
            if path:sub(1, 1) == "/" then path = path:sub(2) end
            local abs = module_path .. "/" .. path
            if vim.fn.isdirectory(abs) == 1 then
              table.insert(sources, abs)
            end
          end
        end
        -- Extra generated sources if exist
        local extras = {
          "target/generated-sources/annotations",
          "target/generated-sources/guardrail-twilio-sources",
          "build/generated/sources/annotationProcessor/java/main",
        }
        for _, rel in ipairs(extras) do
          local abs = module_path .. "/" .. rel
          if vim.fn.isdirectory(abs) == 1 then
            table.insert(sources, abs)
          end
        end
        return sources
      end

      local function setup_jdtls()
        local root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git", ".classpath" }
        local rootp = vim.fs.find(root_markers, { upward = true })[1]
        local root_dir = rootp and vim.fs.dirname(rootp) or vim.fn.getcwd()
        local current = vim.fn.expand("%:p")
        local module_path = (function()
          local dir = vim.fn.fnamemodify(current, ":h")
          local root_abs = vim.fn.fnamemodify(root_dir, ":p:h")
          while dir and dir:find(root_abs, 1, true) == 1 do
            if vim.fn.filereadable(dir .. "/.classpath") == 1 or
                vim.fn.filereadable(dir .. "/pom.xml") == 1 or
                vim.fn.filereadable(dir .. "/build.gradle") == 1 or
                vim.fn.filereadable(dir .. "/build.gradle.kts") == 1 then
              return dir
            end
            dir = vim.fn.fnamemodify(dir, ":h")
          end
          return root_dir
        end)()

        local project_name = vim.fn.fnamemodify(root_dir, ":t")
        local workspace_dir = home .. "/.cache/jdtls/" .. project_name .. "/workspace"
        local config_dir = home .. "/.cache/jdtls/" .. project_name .. "/config"
        os.execute("mkdir -p " .. workspace_dir)
        os.execute("mkdir -p " .. config_dir)

        -- Path to lombok jar
        local lombok_version = "1.18.36"
        local lombok_jar = home .. "/.local/share/java/lombok-" .. lombok_version .. ".jar"
        -- Update if path differs, or fetch if missing
        if vim.fn.filereadable(lombok_jar) == 0 then
          vim.notify("Downloading Lombok " .. lombok_version .. "...", vim.log.levels.INFO)
          os.execute("mkdir -p " .. vim.fn.fnamemodify(lombok_jar, ":h"))
          os.execute("curl -L https://projectlombok.org/downloads/lombok-" .. lombok_version .. ".jar -o " .. lombok_jar)
        end

        -- Clear workspace for this project if needed
        clear_jdtls_workspace(project_name)

        local classpath_sources = get_classpath_sources(module_path)

        local is_maven = vim.fn.filereadable(module_path .. "/pom.xml") == 1
        local is_gradle = vim.fn.filereadable(module_path .. "/build.gradle") == 1 or
            vim.fn.filereadable(module_path .. "/build.gradle.kts") == 1

        local cmd = {
          "jdtls",
          -- Lombok agent must be before the launcher jar
          "--jvm-arg=-javaagent:" .. lombok_jar,
          "--jvm-arg=-Xmx4G",
          "--jvm-arg=-XX:+UseG1GC",
          "--jvm-arg=-XX:+UseStringDeduplication",
          "--jvm-arg=-Djdt.ls.useClasspathFile=" .. tostring(vim.fn.filereadable(module_path .. "/.classpath") == 1),
          "--jvm-arg=-Djdt.ls.detectGeneratedClassesWithoutSpecificSourcePath=true",
          "--jvm-arg=-Djdt.annotationProcessing.enabled=true",
          -- you can also add -Declipse.jdt.ls.lombokSupport=true if needed
          "--jvm-arg=-Declipse.jdt.ls.lombokSupport=true",
          "-configuration", config_dir,
          "-data", workspace_dir,
        }

        local source_paths = {}
        if #classpath_sources > 0 then
          source_paths = classpath_sources
        else
          source_paths = {
            "src/main/java",
            "src/test/java",
            "target/generated-sources/annotations",
            "target/generated-sources/guardrail-twilio-sources",
          }
        end

        local config = {
          cmd = cmd,
          root_dir = root_dir,
          on_attach = on_jdtls_attach,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            java = {
              jdt = {
                ls = {
                  lombokSupport = { enabled = true },
                }
              },
              configuration = {
                updateBuildConfiguration = "automatic",
                sourcePaths = source_paths,
                projectPaths = is_maven and { "pom.xml" } or (is_gradle and { "build.gradle", "build.gradle.kts" } or {}),
              },
              compiler = {
                processAnnotations = true,
                annotationProcessingEnabled = true,
              },
              import = {
                maven = { enabled = is_maven },
                gradle = { enabled = is_gradle, wrapper = { enabled = is_gradle } },
              },
              project = {
                encoding = "UTF-8",
                referencedLibraries = {},
                sourceAttachment = { download = true, onDemand = true },
              },
              completion = {
                enabled = true,
                guessMethodArguments = true,
                favoriteStaticMembers = { "org.slf4j.LoggerFactory.getLogger" },
              },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
            },
          },
          flags = { allow_incremental_sync = true, server_side_fuzzy_completion = true },
        }

        vim.notify("Starting JDTLS (with Lombok) for module: " .. module_path, vim.log.levels.INFO)
        require("jdtls").start_or_attach(config)
      end

      -- Autocommand
      local setup_on_first_java = false

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          if not setup_on_first_java then
            setup_jdtls()
            setup_on_first_java = true -- Ensure it runs only once
          end
        end,
      })

      if vim.bo.filetype == "java" then
        setup_jdtls()
      end
    end,
  },
  { "folke/which-key.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "npm install",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ''
      vim.g.mkdp_browser = ''
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_browserfunc = ''
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {}
      }
      vim.g.mkdp_markdown_css = ''
      vim.g.mkdp_highlight_css = ''
      vim.g.mkdp_port = ''
      vim.g.mkdp_page_title = '「${name}」'
      vim.g.mkdp_images_path = '/home/user/.markdown_images'
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_combine_preview = 0
      vim.g.mkdp_combine_preview_auto_refresh = 1
    end,
    ft = { "markdown" },
  },
  {
    'akinsho/flutter-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = true,
  },
{
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      dart = { "dart_format" },
    },
    formatters = {
      dart_format = {
        command = "dart",
        args = { "format", "--stdin" },
      },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
      async = false,
    },
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    -- Autocmd for Dart formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("ConformFormatting", { clear = true }),
      pattern = "*.dart",
      callback = function(ctx)
        conform.format({ bufnr = ctx.buf, async = false })
      end,
    })
  end,
}
})
