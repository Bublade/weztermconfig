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

return M
