-- colors from: https://github.com/AlexvZyl/nordic.nvim

local M = {}

M.palette = {
	none = "NONE",
	base = "#1b1f26",
	surface = "#242933",
	text = "#BBC3D4",
	text_dim = "#C0C8D8",

	black = {
		base = "#191D24",
		bright = "#1E222A",
		dim = "#222630",
	},

	gray = {
		base = "#2E3440",
		bright = "#3B4252",
		dim = "#434C5E",
		alt1 = "#4C566A",
		alt2 = "#60728A",
	},

	white = {
		base = "#D8DEE9",
		bright = "#E5E9F0",
		dim = "#ECEFF4",
	},
	blue = {
		base = "#5E81AC",
		bright = "#81A1C1",
		dim = "#88C0D0",
	},
	cyan = {
		base = "#8FBCBB",
		bright = "#9FC6C5",
		dim = "#80B3B2",
	},
	red = {
		base = "#BF616A",
		bright = "#C5727A",
		dim = "#B74E58",
	},
	orange = {
		base = "#D08770",
		bright = "#D79784",
		dim = "#CB775D",
	},
	yellow = {
		base = "#EBCB8B",
		bright = "#EFD49F",
		dim = "#E7C173",
	},
	green = {
		base = "#A3BE8C",
		bright = "#B1C89D",
		dim = "#97B67C",
	},
	magenta = {
		base = "#B48EAD",
		bright = "#BE9DB8",
		dim = "#A97EA1",
	},
}

function M.bright_color(key)
	return M.palette[key].bright
end

function M.base_color(key)
	return M.palette[key].base
end

function M.dim_color(key)
	return M.palette[key].bright
end

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

return M
