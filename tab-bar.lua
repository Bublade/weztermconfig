local wezterm = require("wezterm")

local M = {}

-- The filled in variant of the < symbol
local LEFT_SIDE = wezterm.nerdfonts.ple_left_half_circle_thick

-- The filled in variant of the > symbol
local RIGHT_SIDE = wezterm.nerdfonts.ple_right_half_circle_thick

---@class tabApps
---@field icon string Icon to display
---@field color string Color of the icon
---@field name string Display name
---@field display_name function Custom function for the name

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

local function format_working_dir(working_dir)
    working_dir = (working_dir ~= nil and working_dir or wezterm.url.parse("file://~"))
    local home_dir = (os.getenv("HOME") or os.getenv("USERPROFILE") or nil)
    local home_dir_path = (home_dir ~= nil and wezterm.url.parse("file://" .. home_dir).file_path or "")
    local show_dir = working_dir.file_path

    if wezterm.target_triple:find('windows') then
        show_dir = show_dir:gsub('^/(%a:)', '%1')
    end

    if string.sub(working_dir.file_path, 1, #home_dir_path) == home_dir_path then
        show_dir = working_dir.file_path == home_dir_path and "~"
        or string.gsub(working_dir.file_path, home_dir_path, "~")
    end

    if #show_dir > 80 then
        show_dir = string.gsub(show_dir, [[/([.]?[a-zA-Z0-9])[^/]+]], "/%1")
    end

    show_dir = string.gsub(show_dir, [[/$]], "")
    return show_dir
end


local function tab_process_info(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return title
    end

    local active_pane_info = tab_info.active_pane
    local pane = wezterm.mux.get_pane(active_pane_info.pane_id)
    local pane_working_dir = pane:get_current_working_dir()
    local show_dir = format_working_dir(pane_working_dir)
    local proc = get_app_proc(pane:get_foreground_process_info())
    local interesting_porc = proc ~= nil and strip_win_exe(proc.name) or ""

    return { interesting_porc, show_dir, proc }
end

local function on_format_title(
    tab,
    _ --[[tabs]],
    _ --[[panes]],
    config,
    _ --[[hover]],
    _ -- [[max_width]]]
)
local tb_colors = config.colors.tab_bar
local tab_colors = (tab.is_active and tb_colors.active_tab or tb_colors.inactive_tab)
local background = tab_colors.bg_color
local foreground = tab_colors.fg_color

local edge_background = (tab.is_active and tb_colors.background or background)
local edge_foreground = background
local tab_proc_info = tab_process_info(tab)
local procname = tab_proc_info[1]

local pane_info = string.format(
    "%s%s:",
    tab.tab_index + 1,
    #tab.panes > 1 and string.format("-%s", tab.active_pane.pane_index + 1) or ""
)

local app = apps_to_show[procname] ~= nil and apps_to_show[procname]
or { icon = "", color = foreground }

local app_display = (
    app.icon ~= "" and (app.icon .. " ")
    or procname ~= nil and (procname .. " ")
    or ""
)

local app_name = (
    app.name ~= "" and (app.name)
    or procname ~= nil and (procname)
    or ""
)

-- if app.display_name ~= nil then
--     app_name = app.display_name(tab_proc_info[3])
-- end

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
        { Text = app_name },
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
    { Text = app_name },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = RIGHT_SIDE },
}
end

local function get_git_branch(cwd_uri)
    if not cwd_uri then
        return nil
    end

    local cwd = cwd_uri.file_path
    if not cwd then
        return nil
    end

    -- Windows sometimes gives file_path as "/C:/Users/..." with a leading slash;
    -- strip it so `git -C` doesn't choke on the malformed path.
    if wezterm.target_triple:find('windows') then
        cwd = cwd:gsub('^/(%a:)', '%1')
    end

    local ok = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree'
    })
    if not ok then
        return nil
    end

    local ok2, stdout = wezterm.run_child_process({
        'git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD'
    })
    if not ok2 then
        return nil
    end


    local branch = stdout:gsub('%s+$', '')
    branch = branch:gsub('^[^/]*/', '')

    local max_len = 24
    if #branch > max_len then
        branch = branch:sub(1, max_len - 1) .. '…'
    end

    return branch

end

---@param apps? tabApps[]
function M.load(apps, config)
    apps = apps or {}
    apps_to_show = apps

    wezterm.on("format-tab-title", on_format_title)
    wezterm.on("update-status", function(window, pane)
        local colors = config.colors;
        local foreground = colors.foreground

        local working_dir = pane:get_current_working_dir()
        local branch = get_git_branch(working_dir)

        local branch_icon = branch and '  '  or ''
        local branch_name = branch and branch or ''

        window:set_left_status(wezterm.format({
            { Foreground = { Color = "#eaa91e"}},
            { Text = ' 󰉋 ' },
            { Foreground = { Color = foreground}},
            { Text = format_working_dir(working_dir) },
            { Text = branch_icon },
            { Text = branch_name },
            { Text = ' ' },
        }))
    end)
    wezterm.on("update-right-status", function(window, _)
        local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
        window:set_right_status(wezterm.format({
            { Text = date },
        }))
    end)
end

return M
