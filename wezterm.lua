package.path = package.path .. (";" .. ((os.getenv("HOME") or os.getenv("USERPROFILE")) .. [[/.lua_mods/?.lua]]))
-- Pull in the wezterm API
local wezterm = require("wezterm")
local launch_menu = require("launchmenu")
local theme = require("theme")
local tabtitle = require("tabtitle")
local my_hyperlinks = require("my-hyperlinks")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.automatically_reload_config = true

tabtitle.load()
my_hyperlinks.load(config)

config.font = wezterm.font_with_fallback({
	--[[ "FiraCode Nerd Font Mono",]]
	"FiraMono Nerd Font",
	"JetBrains Mono",
})
config.font_size = 10

-- config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 20
theme.load(config)

config.default_prog = { "pwsh.exe" }

config.cell_width = 1.0
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.window_padding = {
	left = ".5cell",
	right = 0,
	top = ".5cell",
	bottom = 0,
}

launch_menu.apply_to_config(config)

config.xcursor_theme = "default"

-- and finally, return the configuration to wezterm
return config
