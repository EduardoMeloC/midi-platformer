Vector2 = Object:extend()

local sortParameters
local assertVector, assertNumber

--- Vector2 constructor
-- Can be called as:
-- Vector2(x, y)
-- Vector2({x, y})
-- Vector2({x = x, y = y})
function Vector2:new(x, y)
    if type(x) == "table" or type(x) == "cdata" then
        x, y = x.x or x[1], x.y or x[2]
    end

    assert(type(x) == "number", "Vector2:new expected <number> for x, but got <" .. type(x) .. ">.")
    assert(type(y) == "number", "Vector2:new expected <number> for x, but got <" .. type(y) .. ">.")

    self.x = x
    self.y = y
end

function Vector2:__add(other)
    self, other = sortParameters(self, other)
    assertVector(other)
    return Vector2(self.x + other.x, self.y + other.y)
end

function Vector2:__sub(other)
    self, other = sortParameters(self, other)
    assertVector(other)
    return Vector2(self.x - other.x, self.y + other.y)
end

function Vector2:__mul(num)
    self, num = sortParameters(self, num)
    assertNumber(num)
    return Vector2(self.x * num, self.y * num)
end

function Vector2:__div(num)
    self, num = sortParameters(self, num)
    assertNumber(num)
    return Vector2(self.x / num, self.y / num)
end

function Vector2:__eq(other)
    if(type(other) ~= "table") then return false end
    if(not other:is(Vector2)) then return false end
    return self.x == other.x and self.y == other.y
end


function Vector2:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vector2.magnitude(vec)
    return math.sqrt(vec.x^2 + vec.y^2)
end

function Vector2.normalize(vec)
    return vec / vec:magnitude()
end

function Vector2.clamp(vector, lower, upper)
    assertVector(vector, lower, upper)
    vector.x = math.clamp(vector.x, lower.x, upper.x)
    vector.y = math.clamp(vector.y, lower.y, upper.y)
    return vector
end

sortParameters = function(self, param)
    -- this function puts actual self in the first parameter position
    if type(self) == "number" then
        self, param = param, self
    end
    return self, param
end

assertVector = function(...)
    for _, other in ipairs{...} do
        str = Debug.getInfo(4) .. debug.getinfo(2, 'n').name .. " takes a <Vector2> as parameter, but received a <" .. type(other) .. ">."
        assert(type(other) == "table", str)
        assert(other:is(Vector2), str)
    end
end

assertNumber = function(...)
    for _, other in ipairs{...} do
        str = Debug.getInfo(4) .. debug.getinfo(2, 'n').name .. " takes a <number> as parameter, but received a <" .. type(other) .. ">."
        assert(type(other) == "number", str)
    end
end

Vector2.zero = Vector2(0, 0)
Vector2.one = Vector2(1, 1)
Vector2.right = Vector2(1, 0)
Vector2.left = Vector2(-1, 0)
Vector2.up = Vector2(0, 1)
Vector2.down = Vector2(0, -1)
