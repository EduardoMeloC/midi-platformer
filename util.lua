function math.clamp(val, lower, upper)
    assert(val and lower and upper, "math.clamp got wrong input. Usage: math.clamp(val, lower, upper)")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.sign(number)
	return number > 0 and 1 or number == 0 and 0 or -1
end

function hex(hex_color)
	local _,_,r,g,b = hex_color:find('(%x%x)(%x%x)(%x%x)')
	local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255}
	return color
end
