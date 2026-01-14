local vague = require("lua/vague")
local M = {}


-- Neovim colors.
function M.colors()
    return vague.colors()
end

function M.window_frame(config)
    return vague.window_frame()
end

function M.command_palette(config)
    local colors = vague.colors()
	config.command_palette_bg_color = colors.background
	config.command_palette_fg_color = colors.foreground
	-- config.command_palette_font = config.font
	config.command_palette_font_size = config.font_size
	config.command_palette_rows = 14
end

function M.load(config)
	config.colors = M.colors()
	config.window_frame = M.window_frame(config)
	M.command_palette(config)
end

return M
