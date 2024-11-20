local status_ok, spectre = pcall(require, "spectre")
if not status_ok then
  vim.notify("spectre not found!")
  return
end

spectre.setup( { } )
