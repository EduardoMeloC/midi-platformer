Platform = Object:extend()

function Platform:new(x, y, w, h, speed)
	assert(type(speed) == 'table' and speed:is(Vector2), "speed must be a Vector2")
	self.x = x or 0
	self.y = y or 0

	self.w = w
	self.h = h

	self.speed = speed -- Vector2
	g_world:add(self, self.x, self.y, self.w, self.h)
end

function Platform:update(dt)
	self.x = self.x + self.speed.x * dt
	self.y = self.y + self.speed.y * dt
	g_world:update(self, self.x, self.y, self.w, self.h)
end

function Platform:destroy()
	g_world:remove(self)
end
