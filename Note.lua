Note = Object:extend()

g_notes = {
	pressed = {}, -- pressed notes are indexed by their note_value
	released = {} -- released notes are ipairs (and this must not be changed)
}

function g_notes:update(dt)
	for _, note in pairs(g_notes.pressed) do
		local platform = note.platform
		note.platform.h = platform.h + platform.speed.y * dt
		g_world:update(note.platform, platform.x, platform.y, platform.w, platform.h)
	end
	for i, note in ipairs(g_notes.released) do
		note.platform:update(dt)
		-- clean the note when it is out of the screen
		if note.platform.y > g_screen.h then
			note.platform:destroy()
			table.remove(g_notes.released, i)
		end
	end
end

function g_notes:draw()
	-- draw pressed notes
	for _, note in pairs(g_notes.pressed) do
		love.graphics.setColor(note.color)
		local platform = note.platform
		love.graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
	end
	-- draw released notes
	for _, note in pairs(g_notes.released) do
		love.graphics.setColor(note.color)
		local platform = note.platform
		love.graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
	end
end


function l_get_note_by_id(note_value)
	local pressed_note = g_notes.pressed[tostring(note_value)]
	local released_note = g_notes.released[tostring(note_value)]
	local note = (pressed_note) and pressed_note or released_note

	return note
end

function Note:new(note_value, color, platform)
	self.note_value = note_value
	self.color = color
	-- used for collision
	self.platform = platform
	-- used for drawing
	local piano_key = g_piano:get_key_by_id(note_value)
end

function Note:draw()
	love.graphics.platformangle(
		"fill",
		self.platform.x,
		self.platform.y,
		self.platform.w,
		self.platform.h
	)
end

function g_notes.on_key_pressed(note_value)
	local piano_key = g_piano:get_key_by_id(note_value)
	piano_key.color = piano_key.pressed_color

	local note_color = piano_key.pressed_color
	local platform = Platform(
		piano_key.x,
		piano_key.y + piano_key.h,
		piano_key.w,
		0.01,
		Vector2(0, g_scrollSpeed)
	)
	local note = Note(note_value, note_color, platform)
	g_notes.pressed[tostring(note_value)] = note
end

function g_notes.on_key_released(note_value)
	local piano_key = g_piano:get_key_by_id(note_value)
	piano_key.color = piano_key.unpressed_color

	-- move note from pressed table to released table
	local note = l_get_note_by_id(note_value)
	g_notes.pressed[tostring(note_value)] = nil
	table.insert(g_notes.released, note)
end

table.insert(MidiSystem.OnKeyPressed, g_notes.on_key_pressed)
table.insert(MidiSystem.OnKeyReleased, g_notes.on_key_released)
