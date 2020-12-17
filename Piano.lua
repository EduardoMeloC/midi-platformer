Piano = Object:extend()

local l_createPianoKeys
local l_createNoteID

function Piano:new(white_keys_amount)
	local piano_keys, keys_amount = l_createPianoKeys(white_keys_amount)

	self.x = 0
	self.y = 0
	self.w = g_screen.w
	self.h = g_screen.h * 100 / love.graphics.getHeight()
	self.keys = piano_keys
	self.keys_amount = keys_amount
	self.platform = Platform(self.x, self.y, self.w, self.h, Vector2.zero)
end

function Piano:get_key_by_id(note_value)
	return self.keys[tostring(note_value)]
end

function Piano:draw()
	for _, key in pairs(self.keys) do
		if key.type == 'white' then
			love.graphics.setColor(key.color)
			love.graphics.rectangle("fill", key.x, key.y, key.w, key.h)
		end
	end
	for _, key in pairs(self.keys) do
		if key.type == 'black' then
			love.graphics.setColor(key.color)
			love.graphics.rectangle("fill", key.x, key.y, key.w, key.h)
			love.graphics.setColor(g_Color.black)
			love.graphics.rectangle("line", key.x, key.y, key.w, key.h)
		end
	end
end

-- returns table containing notes
function l_createPianoKeys(white_keys_amount)
	local piano_keys = {}

	local white_keys_amount = white_keys_amount or 29
	local white_width = g_screen.w / white_keys_amount
	local keyboard_height = g_screen.h * 100 / love.graphics.getHeight()
	local note_offset = 1
	love.graphics.setColor(1, 1, 1)
	-- create whites
	local whites = {}
	for i = 0, white_keys_amount-1 do
		table.insert(whites, {
			type = 'white',
			x = white_width * i,
			y = 0,
			w = white_width - note_offset,
			h = keyboard_height,
			color = g_Color.white,
			unpressed_color = g_Color.white,
			pressed_color = g_Color.blue,
		})
	end
	love.graphics.setColor(0, 0, 0)
	-- create blacks
	local blacks = {}
	local create_black = function(i, offset)
		table.insert(blacks, {
			type = 'black',
			x = white_width * i + white_width*2/3 + offset * white_width,
			y = keyboard_height*1/3,--keyboard_height,
			w = white_width*1.5/3,
			h = keyboard_height*2/3,
			color = g_Color.black,
			unpressed_color = g_Color.black,
			pressed_color = g_Color.darkblue
		})
	end
	local offset = 0
	local i = 0
	while i < math.floor(#whites/7)*5 do
		for k = 1, 2 do
			create_black(i, offset)
			i = i + 1
		end
		offset = offset + 1
		for k = 1, 3 do
			create_black(i, offset)
			i = i + 1
		end
		offset = offset + 1
	end
	piano_keys.whites = whites
	piano_keys.blacks = blacks
	local keys_amount = #whites + #blacks
	piano_keys = l_createNoteID(piano_keys, keys_amount)

	return piano_keys, keys_amount
end

function l_createNoteID(notes, keys_amount)
	local ids = {}
	local whites = notes.whites
	local blacks = notes.blacks

	local w = 1
	local b = 1
	local id = 36
	while id < 36 + keys_amount do
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = blacks[b]; b = b+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = blacks[b]; b = b+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = blacks[b]; b = b+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = blacks[b]; b = b+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
		ids[tostring(id)] = blacks[b]; b = b+1; id = id+1;
		ids[tostring(id)] = whites[w]; w = w+1; id = id+1;
	end
	return ids
end
