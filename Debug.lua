local table_string

Debug = {}
Debug.showable = {}
Debug.console = {isOpen = false}
Debug.drawScreenCoordinates = function(x, y)
    love.graphics.setLineWidth(2)
    local prevColor = {love.graphics.getColor()}
    local vectorLen = 10

    love.graphics.setColor(1, 0, 0)
    love.graphics.line(x, y,
        x + coordSystem.x * vectorLen,
        y)

    love.graphics.setColor(0, 1, 0)
    love.graphics.line(x, y,
        x,
        y + coordSystem.y * vectorLen)

    love.graphics.setColor(prevColor)
    love.graphics.setLineWidth(1)
end

function Debug.show(name)
    if(type(name)~= "string") then Debug.err("Debug.show takes a string as parameter") return end
    table.insert(Debug.showable, name)
end

function Debug.hide(name)
    if(type(name)~= "string") then Debug.err("Debug.show takes a string as parameter") return end
    for k, v in pairs(Debug.showable) do
        if v == name then table.remove(Debug.showable, k) end
    end
end

Debug.log = function(...)
    local msg = args_tostring(...)
    print.print = function(s) return io.write(s) end
    print.gray.bold(Debug.getInfo(2))
    print(msg .. '\n')
    Debug.console.log(msg)
end

Debug.warn = function(...)
    local msg = args_tostring(...)
    print.print = function(s) return io.write(s) end
    print.yellow.bold(Debug.getInfo(2))
    print.yellow(msg .. '\n')
    Debug.console.warn(msg)
end

Debug.err = function(...)
    local msg = args_tostring(...)
    print.print = function(s) return io.write(s) end
    print.red.bold(Debug.getInfo(2))
    print.red(msg .. '\n')
    Debug.console.err(msg)
end

Debug.info = function(...)
    local msg = args_tostring(...)
    print.print = function(s) return io.write(s) end
    print.blue.bold(Debug.getInfo(2))
    print.blue(msg .. '\n')
    Debug.console.info(msg)
end

Debug.getInfo = function(level)
    local file = string.sub(debug.getinfo(1+level, 'S').source, 2)
    local line = debug.getinfo(1+level, 'l').currentline
    local func = debug.getinfo(1+level, 'n').name or ""

    local info = file .. ":" .. line .. "(" .. func .. "): "
    return info
end

function table_string(table)
    local str = "{ "
    local index = 1
    for key, value in pairs(table) do
        if(index > 1) then str = str .. ", " end
        index = index + 1
        if(type(value) == "table") then
            str = str .. table_string(value)
        else
            str = str .. key .. ": " .. (type(value) == "boolean" and (value == true and "true" or "false") or value)
        end
    end
    str = str .. " }"
    return str
end

function args_tostring(...)
    local args = {...}

    local msg = ''
    for i, v in ipairs(args) do
        if type(v) == "table" then
            msg = msg .. (v.__tostring and v:__tostring() or table_string(v)) .. (i < #args and ", " or "")
        else
            if type(v) == "boolean" then v = (v and "true" or "false") end
            msg = msg .. v .. (i < #args and ", " or "")
        end
    end

    return msg
end
