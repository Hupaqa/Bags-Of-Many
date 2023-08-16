dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )

function kick(entity_who_kicked)
    local active_item = get_active_item()
    -- Checking entity name if contains uinversal so this script is not called when holding another bag
    if active_item ~= nil and is_bag(active_item) and name_contains(active_item, "universal") then
        -- BAG OVERRIDE TO CHANGE WHICH BAG IS PICKING UP THE ITEM
        local bag_pickup_override = get_bag_pickup_override(active_item)
        if bag_pickup_override and bag_pickup_override ~= 0 then
            if is_player_root_entity(bag_pickup_override) then
                active_item = bag_pickup_override
            else
                toggle_bag_pickup_override(active_item, 0)
            end
        end
        bag_pickup_action(entity_who_kicked, active_item)
    end
end