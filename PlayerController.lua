--[[
    made with https://2dengine.com/?p=platformers
 ]]

PlayerController = Object:extend()

local generateJump

local pressedJumpKey = false
local pressingJumpKey = false
local wantsToJump = false
local lastGroundedTime = 0
local lastJumpInputTime = -1
local elapsedTime = 0

-- params can define the following variables:
-- Jump = A table defining 2 of the following variables = maxHeight, timeToApex, gravity, initVelocity
-- speed = A number defining player's horizontal speed when input is pressed
-- maxVelocity = A Vector2 defining player's x and y max Velocity
function PlayerController:new(player, params)
    assert(params.speed ~= nil and params.Jump ~= nil, "PlayerController:new() must takes at least a 'Jump' <table> and a 'speed' <number> as parameters.")

    self.player = player
    self.gravityScale = 1
    self.velocity = Vector2(0, 0)

    self._speed = params.speed
    self._Jump = generateJump(params.Jump)
    self._maxVelocity = params.maxVelocity or Vector2(self._speed, self._Jump.initVelocity)
    self._damping = 0
    self._isGrounded = false
    self._isJumping = false
end

function PlayerController:update(dt)
    elapsedTime = elapsedTime + dt
    pressingJumpKey = input.jump > 0

    -- player horizontal move
    self.velocity.x = self._speed * input.x

    -------------------
    --- Player Jump ---
    -------------------
    if self._isGrounded then
        self.gravityScale = 1
        self._isJumping = false
        lastGroundedTime = elapsedTime
        -- store jump input before landing on ground
        if elapsedTime - lastJumpInputTime < 0.15 then
            wantsToJump = true
            lastJumpInputTime = 0
        end
    end
    -- jump even when falling off edges after a small time
    if (wantsToJump and self._isGrounded or
        not self._isJumping and elapsedTime - lastGroundedTime < 0.1 and pressedJumpKey) then
        self.velocity.y = self._Jump.initVelocity
        self._isJumping = true
        wantsToJump = false
        pressedJumpKey = false
    end
    -- jump lower when released Jump Key
    if not pressingJumpKey and self._isJumping then
        self.gravityScale = 2
    end

    ---------------
    --- Physics ---
    ---------------

    -- apply down force to the player
	self.velocity.y = self.velocity.y - self._Jump.gravity * self.gravityScale * dt
    -- apply damping aka friction/ air resistance
    self.velocity = self.velocity / (1 + self._damping*dt)
    -- clamp player's velocity
    self.velocity:clamp(self._maxVelocity, -1 * self._maxVelocity)

    -----------------
    --- Collision ---
    -----------------
	local collider_offset = Vector2(self.player.collider.x, self.player.collider.y)
    local nextPos = self.player.pos + self.velocity*dt
    local actualX, actualY, cols, len = g_world:check(self.player,
        nextPos.x + collider_offset.x, nextPos.y + collider_offset.y)

    self._isGrounded = false
    if len > 0 then
        -- if collision is detected
        for _, col in ipairs(cols) do
			local normal = Vector2(col.normal)
			if(col.other:is(Platform)) then
				local platform = col.other
				if normal == Vector2.up then
					self.velocity.y = 0
					self._isGrounded = true
					-- if platform moves
					if(Vector2.magnitude(platform.speed) > 0) then
						actualY = actualY + platform.speed.y * dt
					end
				elseif normal == Vector2.down then
					self.velocity.y = 0
				end
			end
    	end
    else
		-- if no collision is detected
    end
	self.player.pos.x = actualX - collider_offset.x
	self.player.pos.y = actualY - collider_offset.y
	g_world:update(self.player, actualX, actualY)
end

-- might be called as:
-- generateJump(maxHeight, timeToApex)
-- generateJump(table)
-- where table contains 2 of the 4 values {maxHeight, gravity, initVelocity, timeToApex}
-- note: if "initJumpVelocity" is not a multiple of "g" the maximum height is reached between frames
generateJump = function(maxHeight, timeToApex)
    local Jump = maxHeight -- maxHeight was actually received as a table
    if(type(maxHeight) ~= "table") then
        Jump = {maxHeight = maxHeight, timeToApex = timeToApex}
    end

    -- defining Jump's maxHeight/gravity/initVelocity/timeToApex
    if(Jump.maxHeight and Jump.gravity) then
        Jump.initVelocity = math.sqrt(2*Jump.gravity*Jump.maxHeight)
        Jump.timeToApex = Jump.initVelocity/Jump.gravity
    elseif(Jump.maxHeight and Jump.initVelocity) then
        Jump.gravity = Jump.initVelocity^2 / (2*Jump.maxHeight)
        Jump.timeToApex = Jump.initVelocity/Jump.gravity
    elseif(Jump.maxHeight and Jump.timeToApex) then
        Jump.gravity = (2*Jump.maxHeight)/(Jump.timeToApex^2)
        Jump.initVelocity = math.sqrt(2*Jump.gravity*Jump.maxHeight)
    elseif(Jump.gravity and Jump.initVelocity) then
        Jump.timeToApex = Jump.initVelocity / Jump.gravity
        Jump.maxHeight = (Jump.gravity * Jump.timeToApex^2) / 2
    elseif(Jump.gravity and Jump.timeToApex) then
        Jump.initVelocity = Jump.gravity * Jump.timeToApex
        Jump.maxHeight = (Jump.gravity * Jump.timeToApex^2) / 2
    elseif(Jump.initVelocity and Jump.timeToApex) then
        Jump.gravity = Jump.timeToApex/Jump.initVelocity
        Jump.maxHeight = (Jump.gravity * Jump.timeToApex^2) / 2
    else
        error(Debug.getInfo(2) .. "Wrong call in generateJump. Parameter must define 2 of the following: (maxHeight, gravity, initVelocity, timeToApex). Example: generateJump({gravity = 10, initVelocity = 5})" )
    end

    return Jump
end


function PlayerController:keypressed(key)
	for _, k in ipairs(Input.jump) do
		if (key == k) then
	        lastJumpInputTime = elapsedTime
	        pressedJumpKey = true
		end
    end
end

function PlayerController:keyreleased(key)
	for _, k in ipairs(Input.jump) do
		if (key == k) then
        	pressedJumpKey = false
		end
    end
end
