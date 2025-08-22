-- Transform class definition
local Transform = {}
Transform.__index = Transform

function Transform:new(x, y, z)
    local obj = setmetatable({}, self)
    obj.x = x or 0
    obj.y = y or 0
    obj.z = z or 0
    return obj
end

function Transform:set(x, y, z)
    self.x = x or self.x
    self.y = y or self.y
    self.z = z or self.z
end

function Transform:get()
    return self.x, self.y, self.z
end

function Transform:translate(dx, dy, dz)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
    self.z = self.z + (dz or 0)
end

return Transform