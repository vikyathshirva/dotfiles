local status, cmp = pcall(require, "cmp")
if (not status) then return end
local lspkind = require 'lspkind'
-- Direct monkey patch for the LSP client's _resolve_bufnr function
-- This is what's causing your error
local function apply_bufnr_patch()
  -- Path to the file with the issue
  local file_path = vim.api.nvim_get_runtime_file("lua/vim/lsp/client.lua", false)[1]
  if file_path then
    -- Load the module
    local client = require('vim.lsp.client')
    -- Store the original function
    local original_resolve_bufnr = client._resolve_bufnr
    -- Replace with our fixed version
    client._resolve_bufnr = function(bufnr, method)
      if type(bufnr) == 'function' then
        -- If bufnr is a function, use current buffer instead
        return vim.api.nvim_get_current_buf(), method
      end
      -- Otherwise use the original function
      return original_resolve_bufnr(bufnr, method)
    end
  end
end

-- Apply the patch immediately
apply_bufnr_patch()

local function formatForTailwindCSS(entry, vim_item)
  if vim_item.kind == 'Color' then
    -- Handle both string and table documentation
    local doc = entry.completion_item.documentation
    local doc_str

    if type(doc) == 'table' and doc.value then
      doc_str = doc.value
    elseif type(doc) == 'string' then
      doc_str = doc
    else
      doc_str = ""
    end

    if doc_str then
      local _, _, r, g, b = string.find(doc_str, '^rgb%((%d+), (%d+), (%d+)')
      if r then
        local color = string.format('%02x', r) .. string.format('%02x', g) .. string.format('%02x', b)
        local group = 'Tw_' .. color
        if vim.fn.hlID(group) < 1 then
          vim.api.nvim_set_hl(0, group, { fg = '#' .. color })
        end
        vim_item.kind = "●"
        vim_item.kind_hl_group = group
        return vim_item
      end
    end
  end

  vim_item.kind = lspkind.symbolic(vim_item.kind) and lspkind.symbolic(vim_item.kind) or vim_item.kind
  return vim_item
end


-- local function formatForTailwindCSS(entry, vim_item)
--   if vim_item.kind == 'Color' and entry.completion_item.documentation then
--     local _, _, r, g, b = string.find(entry.completion_item.documentation, '^rgb%((%d+), (%d+), (%d+)')
--     if r then
--       local color = string.format('%02x', r) .. string.format('%02x', g) .. string.format('%02x', b)
--       local group = 'Tw_' .. color
--       if vim.fn.hlID(group) < 1 then
--         vim.api.nvim_set_hl(0, group, { fg = '#' .. color })
--       end
--       vim_item.kind = "●"
--       vim_item.kind_hl_group = group
--       return vim_item
--     end
--   end
--   vim_item.kind = lspkind.symbolic(vim_item.kind) and lspkind.symbolic(vim_item.kind) or vim_item.kind
--   return vim_item
-- end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      maxwidth = 50,
      before = function(entry, vim_item)
        vim_item = formatForTailwindCSS(entry, vim_item)
        return vim_item
      end
    })
  }
})

vim.cmd [[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]]
