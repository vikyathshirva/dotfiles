require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  filters = {
        git_ignored = false, -- Show git ignored files
        dotfiles = false,    -- Show dotfiles
        custom = {
          -- Remove "target" from the default exclusion list
          -- You can add other patterns you want to hide
          -- But don't include "target" here
          "^\\.git$",
          "^\\.DS_Store$",
        },
        exclude = {}, -- Files to explicitly exclude
      },
      
      -- Also make sure hidden files are not excluded
      renderer = {
        highlight_git = true,
        special_files = { "README.md", "pom.xml", "build.gradle" },
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
})

vim.keymap.set('n', '<c-n>', ':NvimTreeFindFileToggle<CR>')
