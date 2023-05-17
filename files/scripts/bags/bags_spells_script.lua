dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/debug.lua" )

local pickup_distance = 20

function kick( entity_who_kicked )
    local player_id = get_player()
    local active_item = get_active_item()
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    -- Checking entity name if contains spells so this script is not called when holding another bag
    if active_item ~= nil and is_bag(active_item) and name_contains(active_item, "spells") then
        local inventory = get_inventory(active_item)
        -- Pickup spells
        if ModSettingGet("BagsOfMany.allow_spells") then
            local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
            add_spells_to_inventory(active_item, inventory, player_id, entities)
        end
    end
end