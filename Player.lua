require 'Vector2'
require 'PlayerController'

Player = Object:extend()

Input = {
	left = {'a', 'left'},
	right = {'d', 'right'},
	--up = {'w', 'up'},
	down = {'s', 'down'},
	jump = {'c', 'space', 'up', 'w'}
}

function Input.isDown(button)
	assert(Input[button], "There is no Input button called " .. button)
	for _, key in ipairs(Input[button]) do
		if love.keyboard.isDown(key) then return true end
	end
end

input = {}

function Player:new(x, y)
	self.pos = Vector2(x or 0, y or 0)
	self.w = 32
	self.h = 40
	self.collider = { x = 6, y = 0, w = self.w, h = self.h } -- puts an offset to player position
	self.scale = Vector2(1, 1)

	self._PlayerController = PlayerController(self, { speed = 300, Jump = {maxHeight = 150, timeToApex = 0.4} })
	g_world:add(self, self.pos.x + self.collider.x, self.pos.y + self.collider.y, self.collider.w, self.collider.h)

	self.image = love.graphics.newImage('img/Kat.png')
	self.flipX = 1
end

function Player:update(dt)
	input.x = (Input.isDown('left') and Input.isDown('right')) and 0 or Input.isDown('left') and -1 or Input.isDown('right') and 1 or 0
	if input.x ~= 0 then
		self.flipX = input.x
	end
	input.jump = Input.isDown('jump') and 1 or 0
	self._PlayerController:update(dt)
end

function Player:draw()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1)
	--love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w * self.scale.x, self.h * self.scale.y)
	love.graphics.draw(
		self.image,
		self.pos.x + (self.flipX < 0 and 44 or 0),
		self.pos.y + 22 + 22, 0,
		self.scale.x * 2 * self.flipX,
		self.scale.y*-1 * 2
	)
	love.graphics.setColor(1, 1, 1)
	love.graphics.pop()
end
