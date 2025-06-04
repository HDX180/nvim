local colorscheme = "catppuccin"

require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    transparent_background = true, -- disables setting the background color.
    term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
    -- dim_inactive = {
    --     enabled = true, -- dims the background color of inactive window
    --     shade = "dark",
    --     percentage = 0.1, -- percentage of the shade to apply to the inactive window
    -- },
})

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
