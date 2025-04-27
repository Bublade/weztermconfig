local wezterm = require("wezterm")

local M = {}

-- The filled in variant of the < symbol
local LEFT_SIDE = wezterm.nerdfonts.ple_left_half_circle_thick

-- The filled in variant of the > symbol
local RIGHT_SIDE = wezterm.nerdfonts.ple_right_half_circle_thick

---@class tabApps
---@field icon string Icon to display
---@field color string Color of the icon

---@type tabApps[]
local apps_to_show = {}

local function get_parent_proc(proc)
	if proc ~= nil and proc.pid then
		return wezterm.procinfo.get_info_for_pid(proc.ppid)
	end
	return nil
end

local function strip_win_exe(name)
	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		return string.gsub(name, [[.exe$]], "")
	end
	return name
end

local function get_app_proc(proc)
	if proc == nil then
		return proc
	end

	local proc_name = strip_win_exe(proc.name)

	if apps_to_show[proc_name] ~= nil then
		return proc
	end

	if proc.ppid == nil then
		return proc
	end

	local parent = get_parent_proc(proc)

	if parent == nil or parent.pid == wezterm.procinfo.pid() then
		return proc
	end

	return get_app_proc(parent)
end

local function tab_process_info(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	local active_pane_info = tab_info.active_pane
	local pane = wezterm.mux.get_pane(active_pane_info.pane_id)
	local pane_working_dir = pane:get_current_working_dir()

	local working_dir = (pane_working_dir ~= nil and pane_working_dir or wezterm.url.parse("file://~"))
	local home_dir = (os.getenv("HOME") or os.getenv("USERPROFILE") or nil)
	local home_dir_path = (home_dir ~= nil and wezterm.url.parse("file://" .. home_dir).file_path or "")
	local show_dir = working_dir.file_path

	if string.sub(working_dir.file_path, 1, #home_dir_path) == home_dir_path then
		show_dir = working_dir.file_path == home_dir_path and "~"
			or string.gsub(working_dir.file_path, home_dir_path, "~")
	end

	local proc = get_app_proc(pane:get_foreground_process_info())
	local interesting_porc = proc ~= nil and strip_win_exe(proc.name) or ""

	return { interesting_porc, show_dir }
end

local function on_format_title(
	tab,
	_ --[[tabs]],
	_ --[[panes]],
	config,
	_ --[[hover]],
	max_width
)
	local tb_colors = config.colors.tab_bar
	local tab_colors = (tab.is_active and tb_colors.active_tab or tb_colors.inactive_tab)
	local background = tab_colors.bg_color
	local foreground = tab_colors.fg_color

	local edge_background = (tab.is_active and tb_colors.background or background)
	local edge_foreground = background
	local tab_proc_info = tab_process_info(tab)

	local pane_info = string.format(
		"%s%s:",
		tab.tab_index + 1,
		#tab.panes > 1 and string.format("-%s", tab.active_pane.pane_index + 1) or ""
	)

	local app = apps_to_show[tab_proc_info[1]] ~= nil and apps_to_show[tab_proc_info[1]]
		or { icon = "", color = foreground }

	local app_display = (
		app.icon ~= "" and (app.icon .. " ")
		or tab_proc_info[1] ~= nil and (tab_proc_info[1] .. " ")
		or ""
	)

	local working_dir = tab_proc_info[2]

	if not config.use_fancy_tab_bar and #working_dir > (config.tab_max_width - #app_display - #pane_info) then
		working_dir = string.gsub(working_dir, [[/([.]?[a-zA-Z0-9])[^/]+]], "/%1")
		-- working_dir = wezterm.truncate_left(working_dir, (max_width - #app_display - #pane_info))
	end

	working_dir = string.gsub(working_dir, [[/$]], "")
	working_dir = wezterm.truncate_right(working_dir, max_width - 2)
	local active_other = (tab.tab_index > 0 and tab.is_active)

	if config.use_fancy_tab_bar then
		return {
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = pane_info },
			{ Foreground = { Color = (app.color ~= nil and app.color or foreground) } },
			{ Text = app_display },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = working_dir },
		}
	end

	return {
		{ Background = { Color = (active_other and tb_colors.background or background) } },
		{ Foreground = { Color = (active_other and background or foreground) } },
		{ Text = ((tab.tab_index > 0 and tab.is_active) and LEFT_SIDE or " ") },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = pane_info },
		{ Foreground = { Color = (app.color ~= nil and app.color or foreground) } },
		{ Text = app_display },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = working_dir },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = RIGHT_SIDE },
	}
end

---@param apps? tabApps[]
function M.load(apps)
	apps = apps or {}
	apps_to_show = apps

	wezterm.on("format-tab-title", on_format_title)
	wezterm.on("update-right-status", function(window, _)
		local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
		window:set_right_status(wezterm.format({
			{ Text = date },
		}))
	end)
end

return M
