local status_ok, treesitter_context = pcall(require, "treesitter-context")
if not status_ok then
  vim.notify("treesitter_context not found!")
  return
end

treesitter_context.setup( {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  -- throttle = true, -- Throttles plugin updates (may improve performance)
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  separator = nil,
  trim_scope = 'inner', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',
  exact_patterns = {

    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true, 
  },
  zindex = 20, -- The Z-index of the context window
}
)
