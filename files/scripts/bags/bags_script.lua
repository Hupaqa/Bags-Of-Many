dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/debug.lua" )

local pickup_distance = 20

function throw_item( from_x, from_y, to_x, to_y )
end

function kick( entity_who_kicked )
    local player_id = get_player()
    local active_item = get_active_item()
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    if is_bag(active_item) then
        -- Pickup spells
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
        for _, entity in ipairs(entities) do
            local parent = EntityGetParent(entity)
            local root_entity = EntityGetRootEntity(entity)
            if root_entity ~= player_id or root_entity == nil then
                if not EntityHasTag(parent, "wand") and is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    EntityRemoveFromParent(entity)
                    local inventory = get_inventory(active_item)
                    EntityAddChild(inventory, entity)
                    hide_entity(entity)
                end
            end
        end
        -- Pickup wands
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "wand")
        for _, entity in ipairs(entities) do
            local root_entity = EntityGetRootEntity(entity)
            if root_entity ~= player_id or root_entity == nil then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    EntityRemoveFromParent(entity)
                    local inventory = get_inventory(active_item)
                    EntityAddChild(inventory, entity)
                    hide_entity(entity)
                end
            end
        end
        -- Pickup potions
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "potion")
        for _, entity in ipairs(entities) do
            local root_entity = EntityGetRootEntity(entity)
            if root_entity ~= player_id or root_entity == nil then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    EntityRemoveFromParent(entity)
                    local inventory = get_inventory(active_item)
                    EntityAddChild(inventory, entity)
                    hide_entity(entity)
                end
            end
        end
    end
end