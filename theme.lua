local nordic = require("nordic")
local M = {}

M.palette = nordic.palette
M.base_color = nordic.base_color
M.bright_color = nordic.bright_color
M.dim_color = nordic.dim_color

local active_tab = {
	bg_color = M.base_color("gray"),
	fg_color = M.palette.text,
}

local inactive_tab = {
	bg_color = M.base_color("black"),
	fg_color = M.palette.text_dim,
}

function M.command_palette(config)
	config.command_palette_bg_color = M.palette.base
	config.command_palette_fg_color = M.palette.text
	-- config.command_palette_font = config.font
	config.command_palette_font_size = config.font_size
	config.command_palette_rows = 14
end

-- Neovim colors.
function M.colors()
	return {
		foreground = M.palette.text,
		background = M.palette.surface,
		cursor_bg = M.palette.text,
		cursor_border = M.palette.text,
		split = M.palette.text,
		ansi = {
			M.base_color("black"),
			M.base_color("red"),
			M.base_color("green"),
			M.base_color("yellow"),
			M.base_color("blue"),
			M.base_color("magenta"),
			M.base_color("cyan"),
			M.base_color("white"),
		},
		brights = {
			M.palette.gray.alt2,
			M.bright_color("red"),
			M.bright_color("green"),
			M.bright_color("yellow"),
			M.bright_color("blue"),
			M.bright_color("magenta"),
			M.bright_color("cyan"),
			M.bright_color("white"),
		},
		tab_bar = {
			background = M.base_color("black"),
			active_tab = active_tab,
			inactive_tab = inactive_tab,
			inactive_tab_hover = active_tab,
			new_tab = inactive_tab,
			new_tab_hover = active_tab,
			inactive_tab_edge = M.palette.surface,
		},
	}
end

function M.window_frame(config)
	return {
		active_titlebar_bg = M.base_color("black"),
		inactive_titlebar_bg = M.base_color("black"),
		font_size = config.font_size or 10,
		font = config.font,
	}
end

function M.load(config)
	config.colors = M.colors()
	config.window_frame = M.window_frame(config)
	M.command_palette(config)
end

return M
