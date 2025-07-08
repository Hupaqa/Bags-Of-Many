dofile_once("data/scripts/lib/utilities.lua")

---@return integer|nil player_entity_id
function get_player()
    return EntityGetWithTag("player_unit")[1]
end

---@return number, number, number, number, number # x, y position of player
function get_player_pos()
    local player = get_player()
    if not player then return 0, 0, 0, 0, 0 end
    return EntityGetTransform(player)
end

---@param path string
---@param offset_x number|nil
---@param offset_y number|nil
---@return integer|nil entity_id
function spawn_entity(path, offset_x, offset_y)
    local x, y = get_player_pos()
    x = x + (offset_x or 0)
    y = y + (offset_y or 0)
    return EntityLoad(path, x, y)
end