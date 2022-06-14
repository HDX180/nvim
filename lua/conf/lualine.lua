local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  vim.notify("lualine not found!")
  return
end

local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn" },
  symbols = { error = " ", warn = " " },
  colored = false,
  update_in_insert = false,
  always_visible = false,
}

local diff = {
  "diff",
  symbols = { added = " ", modified = " ", removed = " " },
  -- diff_color = {
  --   added = { fg = "#98be65" },
  --   modified = { fg = "#ecbe7b" },
  --   removed = { fg = "#ec5f67" },
  -- },
  colored = false,
  cond = hide_in_width
}

local mode = {
  "mode",
  fmt = function(str)
    return "-- " .. str .. " --"
  end,
}


local file_name = {
  'filename',
  file_status = true, -- Displays file status (readonly status, modified status)
  path = 0, -- 0: Just the filename
  -- 1: Relative path
  -- 2: Absolute path

  shorting_target = 40, -- Shortens path to leave 40 spaces in the window
  -- for other components. (terrible name, any suggestions?)
  symbols = {
    modified = ' ●', -- Text to show when the file is modified.
    readonly = ' [ReadOnly]', -- Text to show when the file is non-modifiable or readonly.
    unnamed = '[No Name]', -- Text to show for unnamed buffers.
  },
  -- color = { fg = "#a89bb9", gui='bold,italic'}
}

local filetype = {
  "filetype",
  icons_enabled = false,
  icon = nil,
}

local branch = {
  "branch",
  icons_enabled = true,
  icon = "",
}

local location = {
  "location",
  padding = { left = 1, right = 0 }
}

local fileformat = {
  "fileformat",
  padding = { left = 1, right = 2 }
}

-- cool function for progress
local progress = {
  function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    -- local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
    local chars = { "██", "▇▇", "▆▆", "▅▅", "▄▄", "▃▃", "▂▂", "▁▁", " __", }
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return chars[index]
  end,
  color = { fg = "#ebdbb2" }
}

local spaces = function()
  return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

local explode = function(str)
  local t = {}
  for i = 1, #str do
    t[#t + 1] = cut(str, i, i)
  end

  return t
end

local mysplit = function(str, delimiter)
  -- Handle an edge case concerning the str parameter. Immediately return an
  -- empty table if str == ''.
  if str == '' then return {} end

  -- Handle special cases concerning the delimiter parameter.
  -- 1. If the pattern is nil, split on contiguous whitespace.
  -- 2. If the pattern is an empty string, explode the string.
  -- 3. Protect against patterns that match too much. Such patterns would hang
  --    the caller.
  delimiter = delimiter or '%s+'
  if delimiter == '' then return explode(str) end
  if string.find('', delimiter, 1) then
    local msg = string.format('The delimiter (%s) would match the empty string.',
      delimiter)
    error(msg)
  end

  -- The table `t` will store the found items. `s` and `e` will keep
  -- track of the start and end of a match for the delimiter. Finally,
  -- `position` tracks where to start grabbing the next match.
  local t = {}
  local s, e
  local position = 1
  s, e = string.find(str, delimiter, position)

  while s do
    t[#t + 1] = string.sub(str, position, s - 1)
    position = e + 1
    s, e = string.find(str, delimiter, position)
  end

  -- To get the (potential) last item, check if the final position is
  -- still within the string. If it is, grab the rest of the string into
  -- a final element.
  if position <= #str then
    t[#t + 1] = string.sub(str, position)
  end

  -- Special handling for a (potential) final trailing delimiter. If the
  -- last found end position is identical to the end of the whole string,
  -- then add a trailing empty field.
  if position > #str then
    t[#t + 1] = ''
  end

  return t
end


local session = function()
  local list = mysplit(vim.fn.fnamemodify(vim.v.this_session, ":t"), "__")
  return vim.bo.filetype == " toggleterm" and "term(" .. vim.b.toggle_number .. ") " or " " .. list[#list] .. " "
end

-- add gps module to get the position information
-- local gps = require("nvim-gps")

lualine.setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    -- component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
    -- disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline", "toggleterm" },
    disabled_filetypes = { "alpha", "dashboard", "Outline" },
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    -- lualine_a = { branch, diagnostics },
    lualine_a = { mode },
    lualine_b = { session },
    -- lualine_c = { file_name },
    lualine_c = { branch, diff,
      function()
        return "%="
      end, file_name },

    lualine_x = { diagnostics },
    lualine_y = { spaces, "encoding", filetype, fileformat },
    lualine_z = { location, progress },
    -- lualine_z = { progress },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { file_name },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
})
