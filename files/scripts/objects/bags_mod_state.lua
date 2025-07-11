---@class BagsModState
---@field get_file_content function|nil
---@field is_file_exist function|nil
---@field xml_file_png table
---@field lookup_spells table
---@field bag_pickup_override any
---@field button_pos_x number
---@field button_pos_y number
---@field alchemy_pos_x number
---@field alchemy_pos_y number
---@field alchemy_amount_transfered integer
---@field left_mouse_down_frame integer
---@field left_mouse_up_frame integer
---@field button_locked boolean
BagsModState = {}
BagsModState.__index = BagsModState

function BagsModState:new()
    local obj = setmetatable({}, self)
    obj.get_file_content = nil
    obj.is_file_exist = nil
    obj.xml_file_png = {}
    obj.lookup_spells = {}
    obj.bag_pickup_override = nil
    obj.button_pos_x = get_mod_setting_number("BagsOfMany.pos_x", 170)
    obj.button_pos_y = get_mod_setting_number("BagsOfMany.pos_y", 40)
    obj.alchemy_pos_x = get_mod_setting_number("BagsOfMany.alchemy_pos_x", 200)
    obj.alchemy_pos_y = get_mod_setting_number("BagsOfMany.alchemy_pos_y", 70)
    obj.alchemy_amount_transfered = 10
    obj.left_mouse_down_frame = 0
    obj.left_mouse_up_frame = 0
    obj.button_locked = nil
    return obj
end

-- Usage example (in init.lua):
-- bags_mod_state = BagsModState:new()
