---@class VanillaInventory
---@field inventory_type number
---@field hovering boolean
---@field hovering_spot number
---@field hovering_spot_level number
---@field quick table
---@field full table
---@field quick.inv_position number
---@field quick.widget_item any
---@field quick.frame_click number
---@field quick.frame_release number
---@field full.inv_position number
---@field full.widget_item any
---@field full.frame_click number
---@field full.frame_release number
VanillaInventory = {}
VanillaInventory.__index = VanillaInventory

function VanillaInventory:new()
    local obj = setmetatable({}, self)
    obj.inventory_type = 0
    obj.hovering = false
    obj.hovering_spot = nil
    obj.hovering_spot_level = nil
    obj.quick = {
        inv_position = nil,
        widget_item = nil,
        frame_click = 0,
        frame_release = 0,
    }
    obj.full = {
        inv_position = nil,
        widget_item = nil,
        frame_click = 0,
        frame_release = 0,
    }
    return obj
end