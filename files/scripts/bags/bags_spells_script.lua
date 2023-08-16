dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )

local pickup_distance = 20

function kick( entity_who_kicked )
    local active_item = get_active_item()
    -- Checking entity name if contains spells so this script is not called when holding another bag
    if active_item ~= nil and is_bag(active_item) and name_contains(active_item, "spells") then
        bag_pickup_action(entity_who_kicked, active_item)
    end
end