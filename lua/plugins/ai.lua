local safe_import = require("utils.safe_import")

return {
  "David-Kunz/gen.nvim",
  opts = {
    model = "llama3:latest", -- The default model to use.
    host = "localhost", -- The host running the Ollama service.
    port = "11434", -- The port on which the Ollama service is listening.
    display_mode = "float", -- The display mode. Can be "float" or "split".
    show_prompt = false, -- Shows the Prompt submitted to Ollama.
    show_model = false, -- Displays which model you are using at the beginning of your chat session.
    no_auto_close = false, -- Never closes the window automatically.
    init = function(options)
      pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
    end,
    -- Function to initialize Ollama
    command = function(options)
      return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
    end,
    debug = false, -- Prints errors and the command which is run.
  },
  config = function()
    local gen = safe_import("gen")
    gen.prompts["Elaborate_Text"] = {
      prompt = "Elaborate the following text:\n$text",
      replace = true,
    }
    gen.prompts["Grammar_check"] = {
      prompt = "Check the grammar of the following text:\n$text",
      replace = false,
    }
  end,
}
