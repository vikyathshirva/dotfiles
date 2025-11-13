-- Direct monkey patch for the bufnr issue
local function patch_lsp()
  -- Get the original function
  local client = require('vim.lsp.client')
  local orig_resolve_bufnr = client._resolve_bufnr

  -- Replace it with our patched version
  client._resolve_bufnr = function(bufnr, method)
    -- If bufnr is a function, use current buffer instead
    if type(bufnr) == 'function' then
      return vim.api.nvim_get_current_buf(), method
    end
    -- Otherwise use the original function
    return orig_resolve_bufnr(bufnr, method)
  end
end

-- Try to apply the patch
local success, err = pcall(patch_lsp)
if not success then
  vim.notify("Failed to patch LSP: " .. tostring(err), vim.log.levels.WARN)
end

return true
