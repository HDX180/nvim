local status_ok, gitblame = pcall(require, "gitblame")
if not status_ok then
  vim.notify("gitblame not found!")
  return
end

gitblame.setup({
    enabled = true,
    message_template = ' <summary> • <date> • <author> • <<sha>>',
    date_format = '%m-%d-%Y %H:%M',
    ignore_by_filetype = {'NvimTree', 'toggleterm', 'help'},
    -- visual_delay = 1000,  -- 1 second

    -- 性能优化设置
    gitblame_schedule_event = 'CursorHold',
    gitblame_clear_event = 'CursorHoldI',
})
