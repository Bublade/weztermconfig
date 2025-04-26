local wezterm = require("wezterm")

local module = {}

local function edit_launch_menu()
	local launch_menu = {}
	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		table.insert(launch_menu, {
			label = "Powershell",
			args = { "pwsh.exe", "-NoLogo" },
		})
		table.insert(launch_menu, {
			label = "CMD",
			args = { "cmd.exe" },
		})
	end
	return launch_menu
end

function module.apply_to_config(config)
	local clm = edit_launch_menu()
	config.launch_menu = clm
end

return module
