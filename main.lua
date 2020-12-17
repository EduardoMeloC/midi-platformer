midi = require "luamidi"
local MidiSystem = require 'MidiSystem'
require 'Debug'
require 'util'

Object = require 'libs/classic'
bump = require 'libs/bump'

require 'Vector2'
require 'Piano'
require 'Player'
require 'Platform'
require 'Note'

g_Color = {
	white 	= '#FFFFFF',
	black 	= '#000000',
	blue 	= '#6EC1F8',
	darkblue= '#3081EE',
}

g_noteRects = { pressed = {}, released = {}}
g_scrollSpeed = 150;
g_colliders = {}

g_screen = {
	w = love.graphics.getWidth(),
	h = love.graphics.getHeight(),
	canvas = nil
}
g_screen.canvas = love.graphics.newCanvas(g_screen.w, g_screen.h)

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	for k, color in pairs(g_Color) do
		g_Color[k] = hex(color)
	end
	MidiSystem:init()

	g_world = bump.newWorld()
	g_piano = Piano(21)
	g_player = Player(g_screen.w/2, 120)
end

-- up right coordinate system
local coordSystem = Vector2(1, -1)

function love.draw()
	love.graphics.setCanvas(g_screen.canvas)
	love.graphics.clear()
	love.graphics.push()
	love.graphics.scale(coordSystem.x, coordSystem.y)
	love.graphics.translate(0, coordSystem.y * g_screen.h)
	-- draw piano
	love.graphics.setColor(1, 1, 1)
	g_piano:draw()
	g_notes:draw()

	--draw player
	g_player:draw()
	love.graphics.setColor(1, 0, 1)
	--Debug.drawColliders()
	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(g_screen.canvas, 0, 0)
end

function Debug.drawColliders()
	local items, len = g_world:getItems()

	for _, item in pairs(items) do
		local x, y, w, h = g_world:getRect(item)
		love.graphics.rectangle("line", x, y, w, h)
	end
end

function love.update(dt)
	g_player:update(dt)
	g_notes:update(dt)

	MidiSystem:update(dt)
end

function love.quit()
	midi.gc()
end

function love.keypressed(key)
    g_player._PlayerController:keypressed(key)
end

function love.keyreleased(key)
    g_player._PlayerController:keyreleased(key)
end
