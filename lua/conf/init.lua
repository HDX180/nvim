local starts_with = function(str, start)
  return str:sub(1, #start) == start
end

local ends_with = function(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end


local M = {}

M.setup = function()
  local config_dir = vim.fn.stdpath('config') .. '/lua/conf'
  -- plugins do not need to load, NOTE: no .lua suffix required
  local unload_plugins = {
    "init", -- we don't need to load init again
    "bufferline",
    "alpha",
  }

  helper_set = {}
  for _, v in pairs(unload_plugins) do
    helper_set[v] = true
  end
  for _, fname in pairs(vim.fn.readdir(config_dir)) do
    if ends_with(fname, ".lua") then
      cut_suffix_fname = fname:sub(1, #fname - #'.lua')
      if helper_set[cut_suffix_fname] == nil then
        local file = "conf." .. cut_suffix_fname
        local status_ok, _ = pcall(require, file)
        if not status_ok then
          vim.notify('Failed loading ' .. fname, vim.log.levels.ERROR)
        end
      end
    end
  end
end

M.setup()
