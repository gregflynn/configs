-- Heavily adapted from https://github.com/berlam/awesome-switcher/blob/master/init.lua

--Copyright (c) 2014-2016		Joren Heit <jorenheit@gmail.com>
--Copyright (c) 2016		Matthias Berla <matthias@berla.net>
--
--Permission to use, copy, modify, and/or distribute this software for any
--purpose with or without fee is hereby granted, provided that the above
--copyright notice and this permission notice appear in all copies.
--
--THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
--WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
--MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
--ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
--WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
--ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
--OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

local mouse = mouse
local table = table
local keygrabber = keygrabber
local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local textbox = require('wibox.widget.textbox')
local client = client
awful.client = require('awful.client')

local FontIcon = require('sanity/util/fonticon')
local display  = require('sanity/util/display')
local text     = require('sanity/util/text')
local markup   = require('lain.util.markup')

local string = string
local debug = debug
local pairs = pairs

local _M = {}

_M.settings = {
	client_opacity_value_selected = 1,
	client_opacity_value_in_focus = 0.5,
	client_opacity_value = 0.5,
	cycle_raise_client = true,
}

_M.preview_visible = false

_M.altTabTable = {}
_M.altTabIndex = 1

_M.source = string.sub(debug.getinfo(1,'S').source, 2)
_M.path = string.sub(_M.source, 1, string.find(_M.source, "/[^/]*$"))

_M.fonticon_margin = 20
_M.popup_text = textbox()
_M.popup_icons = {}
_M.popup_icons_container = wibox.layout.fixed.horizontal()
_M.popup = awful.popup {
    widget = {
        {
            display.center(_M.popup_icons_container),
            display.center(_M.popup_text),
            layout = wibox.layout.fixed.vertical,
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    placement    = awful.placement.centered,
    shape        = gears.shape.rounded_rect,
    visible      = false,
    ontop        = true,
    opacity      = 0.9
}

-- simple function for counting the size of a table
function _M.tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-- this function returns the list of clients to be shown.
function _M.getClients()
	local clients = {}

	-- Get focus history for current tag
	local s = mouse.screen;
	local idx = 0
	local c = awful.client.focus.history.get(s, idx)

	while c do
		table.insert(clients, c)

		idx = idx + 1
		c = awful.client.focus.history.get(s, idx)
	end

	return clients
end

-- here we populate altTabTable using the list of clients taken from
-- _M.getClients(). In case we have altTabTable with some value, the list of the
-- old known clients is restored.
function _M.populateAltTabTable()
	local clients = _M.getClients()

	if _M.tableLength(_M.altTabTable) then
		for ci = 1, #clients do
			for ti = 1, #_M.altTabTable do
				if _M.altTabTable[ti].client == clients[ci] then
					_M.altTabTable[ti].client.opacity = _M.altTabTable[ti].opacity
					break
				end
			end
		end
	end

	_M.altTabTable = {}
    _M.popup_icons = {}
    _M.popup_icons_container:reset()

	for i = 1, #clients do
        table.insert(_M.altTabTable, {
            client = clients[i],
            opacity = clients[i].opacity
        })
        local fi = FontIcon {size = 90}
        table.insert(_M.popup_icons, fi)
        _M.popup_icons_container:add(wibox.container.margin(fi, _M.fonticon_margin, _M.fonticon_margin))
	end
end

-- If the length of list of clients is not equal to the length of altTabTable,
-- we need to repopulate the array and update the UI. This function does this
-- check.
function _M.clientsHaveChanged()
	local clients = _M.getClients()
	return _M.tableLength(clients) ~= _M.tableLength(_M.altTabTable)
end

-- Preview is created here.
function _M.clientOpacity()
	local opacity = _M.settings.client_opacity_value
	if opacity > 1 then opacity = 1 end
	for i,data in pairs(_M.altTabTable) do
		data.client.opacity = opacity
	end

	if client.focus == _M.altTabTable[_M.altTabIndex].client then
		-- Let's normalize the value up to 1.
		local opacityFocusSelected = _M.settings.client_opacity_value_selected + _M.settings.client_opacity_value_in_focus
		if opacityFocusSelected > 1 then opacityFocusSelected = 1 end
		client.focus.opacity = opacityFocusSelected
	else
		-- Let's normalize the value up to 1.
		local opacityFocus = _M.settings.client_opacity_value_in_focus
		if opacityFocus > 1 then opacityFocus = 1 end
		local opacitySelected = _M.settings.client_opacity_value_selected
		if opacitySelected > 1 then opacitySelected = 1 end

		client.focus.opacity = opacityFocus
		_M.altTabTable[_M.altTabIndex].client.opacity = opacitySelected
	end
end

function _M.cycle(dir)
	-- Switch to next client
	_M.altTabIndex = _M.altTabIndex + dir
	if _M.altTabIndex > #_M.altTabTable then
		_M.altTabIndex = 1 -- wrap around
	elseif _M.altTabIndex < 1 then
		_M.altTabIndex = #_M.altTabTable -- wrap around
	end

	if _M.clientsHaveChanged() then
		_M.populateAltTabTable()
	end

	if _M.preview_visible then
		_M.clientOpacity()
	end

    local current_client = _M.altTabTable[_M.altTabIndex].client
	if _M.settings.cycle_raise_client == true then
		current_client:raise()
	end

    -- set the selected client information
    for idx=1, #_M.popup_icons do
        _M.popup_icons[idx]:update(
            display.get_icon_for_client(_M.altTabTable[idx].client) or display.get_default_client_icon(),
            idx == _M.altTabIndex and colors.yellow or colors.gray
        )
    end
    _M.popup_text:set_markup(markup.fg.color(colors.yellow, markup.big(
		string.format('%s (%s)', text.trim(current_client.name), current_client.class))
	))
end

function _M.switch(dir, mod_key1, release_key, mod_key2, key_switch)
	_M.populateAltTabTable()

	if #_M.altTabTable == 0 then
		return
	elseif #_M.altTabTable == 1 then
		_M.altTabTable[1].client:raise()
		return
	end

	-- reset index
	_M.altTabIndex = 1

    _M.preview_visible = true
    _M.popup.visible = true
	_M.clientOpacity()

	-- Now that we have collected all windows, we should run a keygrabber
	-- as long as the user is alt-tabbing:
	keygrabber.run(
		function (mod, key, event)
			-- Stop alt-tabbing when the alt-key is released
			if gears.table.hasitem(mod, mod_key1) then
				if (key == release_key or key == "Escape") and event == "release" then
					if _M.preview_visible == true then
						_M.preview_visible = false
                        _M.popup.visible = false
					end

					if key == "Escape" then
						for i = 1, #_M.altTabTable do
							_M.altTabTable[i].client.opacity = _M.altTabTable[i].opacity
						end
					else
						-- Raise clients in order to restore history
						local c
						for i = 1, _M.altTabIndex - 1 do
							c = _M.altTabTable[_M.altTabIndex - i].client
                            c:raise()
                            client.focus = c
						end

						-- raise chosen client on top of all
						c = _M.altTabTable[_M.altTabIndex].client
						c:raise()
						client.focus = c

						for i = 1, #_M.altTabTable do
							_M.altTabTable[i].client.opacity = _M.altTabTable[i].opacity
						end
					end

					keygrabber.stop()

				elseif key == key_switch and event == "press" then
					if gears.table.hasitem(mod, mod_key2) then
						-- Move to previous client on Shift-Tab
						_M.cycle(-1)
					else
						-- Move to next client on each Tab-press
						_M.cycle( 1)
					end
				end
			end
		end
	)

	-- switch to next client
	_M.cycle(dir)

end -- function altTab

return {switch = _M.switch, settings = _M.settings}
