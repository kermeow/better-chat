---@class TileInfo
---@field x integer
---@field y integer
---@field w integer
---@field h integer

---@class EmojiAnimationDescriptor
---@field updates_per_frame integer
---@field frames TileInfo[]

---@class EmojiDescriptor
---@field name string
---@field alias string[]
---@field texture TextureInfo
---@field tileInfo TileInfo?
---@field animation EmojiAnimationDescriptor?

---@type EmojiDescriptor[]
local emojis = {}
---@type { [string]: integer }
local emojis_by_alias = {} -- THESE ARE INDEX, NOT THE ACTUAL DESCRIPTION

---@param name string
---@param aliases string[]
---@param texture TextureInfo
---@param tile TileInfo?
---@param animation EmojiAnimationDescriptor?
---@return integer
local function add_emoji_internal(name, aliases, texture, tile, animation)
	if name == nil then
		error("Can't add emoji with no name", 2)
	end
	if #(aliases or {}) == 0 then
		error("Can't add emoji with no aliases", 2)
	end
	if texture == nil then
		error("Can't add emoji with no texture", 2)
	end

	table.insert(emojis, {
		name = name,
		alias = aliases,
		texture = texture,
		tile = tile,
		animation = animation,
	})
	local index = #emojis
	for i, alias in next, aliases do
		if emojis_by_alias[alias] ~= nil then
			print("Emoji with same alias already exists!")
		end
		emojis_by_alias[alias] = index
	end
	return index
end

---Adds an emoji that is a whole texture
---@param name string
---@param aliases string[]
---@param textureName string
---@return integer
function add_emoji(name, aliases, textureName)
	local emoji_idx = add_emoji_internal(name, aliases, get_texture_info(textureName))
	if not emoji_idx then
		error(string.format("Failed to add emoji (%s :%s:)", name, aliases[1]), 2)
	end
	return emoji_idx
end

---Adds an emoji that is a tile of a texture
---@param name string
---@param aliases string[]
---@param textureName string
---@param tx integer
---@param ty integer
---@param tw integer
---@param th integer
---@return integer
function add_emoji_tiled(name, aliases, textureName, tx, ty, tw, th)
	local emoji_idx = add_emoji_internal(name, aliases, get_texture_info(textureName), { x = tx, y = ty, w = tw, h = th })
	if not emoji_idx then
		error(string.format("Failed to add emoji (%s :%s:)", name, aliases[1]), 2)
	end
	return emoji_idx
end

-- TODO: animated emojis


---Adds an alias to an existing emoji
---@param emojiIdx integer
---@param alias string
function add_emoji_alias(emojiIdx, alias)
	if emojis_by_alias[alias] ~= nil then
		error(string.format("Alias :%s: is already used", alias), 2)
	end
	if #emojis < emojiIdx then
		error("Can't add alias to non-existent emoji")
	end

	table.insert(emojis[emojiIdx].alias, alias)
	emojis_by_alias[alias] = emojiIdx
end
