--- Represents a color using RGBA components.
--- @param r number Red component (0-255)
--- @param g number Green component (0-255)
--- @param b number Blue component (0-255)
--- @param a number Alpha component (0-1)
local RGBA = {}
RGBA.__index = RGBA

function RGBA:new(r, g, b, a)
    local obj = setmetatable({}, self)
    obj.r = r or 1
    obj.g = g or 1
    obj.b = b or 1
    obj.a = a or 1
    return obj
end

function RGBA:toTable()
    return {self.r, self.g, self.b, self.a}
end

function RGBA:clone()
    return RGBA:new(self.r, self.g, self.b, self.a)
end

function RGBA:__tostring()
    return string.format("rgb(%d, %d, %d, %d)", self.r, self.g, self.b, self.a)
end

return RGBA