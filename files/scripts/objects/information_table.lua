---@class InformationTable
---@field item number
---@field position number
---@field bag number
---@field level number
---@field position_x number
---@field position_y number
---@field initial_position_x number
---@field initial_position_y number
InformationTable = {}
InformationTable.__index = InformationTable

function InformationTable:new()
    local obj = setmetatable({}, self)
    obj.item = nil
    obj.position = nil
    obj.bag = nil
    obj.level = nil
    obj.position_x = nil
    obj.position_y = nil
    obj.initial_position_x = nil
    obj.initial_position_y = nil
    return obj
end