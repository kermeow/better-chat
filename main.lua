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
		local c = string:sub(i, i)
		if c == '\\' then
			inSlash = not inSlash
			if not inSlash then
				djui_hud_print_text(output, x, y, scale)
				local r = tonumber(hex:sub(1, 2), 16)
				local g = tonumber(hex:sub(3, 4), 16)
				local b = tonumber(hex:sub(5, 6), 16)
				djui_hud_set_color(r, g, b, djui_hud_get_color().a)
				djui_hud_print_text_colored(string:sub(i + 1, #string), x + (djui_hud_measure_text(output) * scale), y,
					scale)
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

local function string_split(s, sep)
	local parts = {}
	local pattern = "%S+"
	if sep ~= nil then pattern = "([^" .. sep .. "]+)" end
	for part in string.gmatch(s, pattern) do
		table.insert(parts, part)
	end
	return parts
end

local function split_text_into_lines(text, length)
	--[[
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
	--]]

	-- TRIED AND TESTED CODE RIPPED FROM BUBBLE CHAT! (its ok because i made it)
	-- remembers to handle when one word goes past the limit
	-- edited to support colors
	local lines = { "" }
	local current_line = 1

	local words = string_split(text, " ")

	for i, word in next, words do
		local working_line = lines[current_line]
		if i ~= 1 then working_line = working_line .. " " end
		working_line = working_line .. word

		local word_width = djui_hud_measure_text(string_remove_hex(word))
		if word_width >= length then
			working_line = lines[current_line]
			if i ~= 1 then working_line = working_line .. " " end
			for char_index = 1, word:len() do
				local character = word:sub(char_index, char_index)
				working_line = working_line .. character

				local line_width = djui_hud_measure_text(string_remove_hex(working_line))
				if line_width > length then
					current_line = current_line + 1
					working_line = character
				end
				lines[current_line] = working_line
			end
		end

		local line_width = djui_hud_measure_text(string_remove_hex(working_line))
		if line_width > length then
			current_line = current_line + 1
			working_line = word
		end
		lines[current_line] = working_line
	end

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

local MATH_DIVIDE_60 = 1 / 60
local hourOffset = ((get_date_and_time().hour - math.floor(get_time() * MATH_DIVIDE_60 * MATH_DIVIDE_60))) * 60 * 60
local chatLog = {
	{ name = "\\#dcdcdc\\Better\\#545454\\Chat", msg = "Welcome to Better Chat!", time = get_time() + hourOffset }
}

local function hud_render()
	djui_hud_set_resolution(RESOLUTION_DJUI)
	local width = djui_hud_get_screen_width()
	local height = djui_hud_get_screen_height()
	djui_hud_set_font(djui_menu_get_font())

	local y = height
	for i = #chatLog, 1, -1 do
		local message = chatLog[i]
		local hours = math.floor(message.time * MATH_DIVIDE_60 * MATH_DIVIDE_60)
		local minutes = math.floor(message.time * MATH_DIVIDE_60)
		local timeString = tostring(hours % 12) .. ":" .. string.format("%02i", minutes % 60)
		local author = message.name ~= nil and message.name .. "\\#ffffff\\: " or ""
		local messageString = author .. message.msg .. " \\#545454\\(" .. timeString .. ")"
		local messageLines = split_text_into_lines(messageString, width / 3)
		local messageLength = string_table_get_longest(messageLines)
		y = y - (33 * #messageLines)
		djui_hud_set_color(0, 0, 0, 200)
		djui_hud_render_rect(width - messageLength - 4, y, messageLength + 4, #messageLines * 33)
		for c = 1, #messageLines do
			djui_hud_set_color(255, 255, 255, 255)
			djui_hud_print_text_colored(messageLines[c],
				width - djui_hud_measure_text(string_remove_hex(messageLines[c])) - 2, y + (c - 1) * 33, 1)
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
