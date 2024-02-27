-- Title:        relax.nvim
-- Description:  A plugin that allows you to send HTTP requests from Neovim.
-- Last Change:  24 February 2024
-- Maintainer:   Azpect3120 <https://github.com/Azpect3120>

-- Prevents the plugin from being loaded multiple times. If the loaded
-- variable exists, do nothing more. Otherwise, assign the loaded
-- variable and continue running this instance of the plugin.
if not _G.myPluginLoaded then
  -- Exposes the plugin's functions for use as commands in Neovim.
  vim.api.nvim_create_user_command("Relax", require("relax").display, {})

  -- Ensure plugin is only loaded once
  _G.myPluginLoaded = true
end
