require("codecompanion").setup({
  adapters = {
    deepseek_code = function()
      return require("codecompanion.adapters").extend("deepseek", {
        name = "deepseek_code",
        url = "http://36.248.76.15:30000/v1/chat/completions",
        -- env = { api_key = function() return os.getenv("DEEPSEEK_API_KEY") end },
        headers = {
          ["Content-Type"] = "application/json",
          ["Authorization"] = "Bearer airtc_physical_test",
        },
        schema = {
          model = {
            default = "deepseek-ai/DeepSeek-V3",
            choices = {
              ["deepseek-ai/DeepSeek-V3"] = { opts = { can_reason = true } },
              ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
            },
          },
        },
      })
    end,
  },
  strategies = {
    chat = { adapter = "deepseek_code" },
    inline = { adapter = "deepseek_code" },
  },
  opts = { language = "Chinese" },
})
