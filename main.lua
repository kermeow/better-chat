-- name: Better Chat
-- description: \\#33ffff\\-- Better Chat v1 --\n\n\\#dcdcdc\\Improves on the chat with like emojis n shit :sunglasses:\n\nCreated by: \\#646464\\kermeow\\#dcdcdc\\ & \\#008800\\Squishy6094\n\n\\#aaaaff\\Updates can be found on\nBetter Chat's Github:\n\\#6666ff\\kermeow/better-chat-coop

--[[
	▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
	█░░░░░░░░▀█▄▀▄▀██████░▀█▄▀▄▀██████░
	░░░░░░░░░░░▀█▄█▄███▀░░░ ▀██▄█▄███▀░
--]]

local function djui_hud_print_text_colored(string, x, y, scale)
    if stringStart == nil then stringStart = 1 end

    local output = ''
    local hex = ''

    local inSlash = false
    for i = stringStart, #string do
        local c = string:sub(i,i)
        if c == '\\' then
            inSlash = not inSlash
            if not inSlash then
                djui_hud_print_text(output, x, y, scale)
                local r = tonumber(hex:sub(1,2), 16)
                local g = tonumber(hex:sub(3,4), 16)
                local b = tonumber(hex:sub(5,6), 16)
                djui_hud_set_color(r, g, b, djui_hud_get_color().a)
                djui_hud_print_text_colored(string:sub(i+1,#string), x + (djui_hud_measure_text(output)*scale), y, scale)
                return
            end
        elseif not inSlash then
            output = output .. c
        else
            if c ~= '#' then
                hex = hex .. c
            end
        end
    end
    djui_hud_print_text(output, x, y, scale)
end

local function string_remove_hex(msg)
	local output = ""
	local inColor = false
	for i = 1, #msg do
		if msg:sub(i, i) == "\\" then
			inColor = not inColor
		elseif not inColor then
			output = output .. msg:sub(i, i)
		end
	end
	return output
end

local function split_text_into_lines(text, length)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local lines = {}
    local currentLine = ""
    for i, word in ipairs(words) do
        local measuredWidth = djui_hud_measure_text(string_remove_hex(currentLine .. " " .. word))
        if measuredWidth <= length then
            currentLine = currentLine .. " " .. word
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end
    table.insert(lines, currentLine) -- add the last line

    return lines
end

local function string_table_get_longest(stringTable)
	local maxLength = 0
	for i = 1, #stringTable do
		local length = djui_hud_measure_text(string_remove_hex(stringTable[i]))
		maxLength = maxLength < length and length or maxLength
	end
	return maxLength
end

local MATH_DIVIDE_60 = 1/60
local hourOffset = ((get_date_and_time().hour - math.floor(get_time()*MATH_DIVIDE_60*MATH_DIVIDE_60)))*60*60
local chatLog = {
	{name = "\\#dcdcdc\\Better\\#545454\\Chat", msg = "Welcome to Better Chat!", time = get_time() + hourOffset}
}

local function hud_render()
	djui_hud_set_resolution(RESOLUTION_DJUI)
	local width = djui_hud_get_screen_width()
	local height = djui_hud_get_screen_height()
	djui_hud_set_font(djui_menu_get_font())

	for i = #chatLog, 1, -1 do
		local message = chatLog[i]
		local timeString = tostring(math.floor(message.time*MATH_DIVIDE_60*MATH_DIVIDE_60)%12) .. ":" .. string.format("%02i", math.floor(message.time*MATH_DIVIDE_60)%60)
		local messageString = (message.name ~= nil and message.name .. "\\#ffffff\\: " or "") .. message.msg .. " \\#545454\\(" .. timeString .. ")"
		local messageTable = split_text_into_lines(messageString, width*0.33)
		local messageLength = string_table_get_longest(messageTable)
		local messageY = height - (#chatLog - (#chatLog[i] - 1))*33
		djui_hud_set_color(0, 0, 0, 200)
		djui_hud_render_rect(width - messageLength - 4, messageY, messageLength + 4, (#messageTable - 1)*33)
		for c = 1, #messageTable do
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text_colored(messageTable[c], width - djui_hud_measure_text(string_remove_hex(messageTable[c])) - 2, messageY + (c - 1)*33, 1)
		end
	end
end

_G.djui_chat_message_create = function(msg)
	table.insert(chatLog, {
		name = nil,
		msg = msg,
		time = get_time() + hourOffset
	})
end

---@param m MarioState
local function on_chat_message_create(m, msg)
	local np = gNetworkPlayers[m.playerIndex]
	table.insert(chatLog, {
		name = network_get_player_text_color_string(m.playerIndex) .. np.name,
		msg = msg,
		time = get_time() + hourOffset
	})
	return false
end

hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message_create)
hook_event(HOOK_ON_HUD_RENDER, hud_render)