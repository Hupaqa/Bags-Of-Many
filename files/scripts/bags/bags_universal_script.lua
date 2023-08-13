dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )

local pickup_distance = 20

function kick( entity_who_kicked )
    local player_id = get_player()
    local active_item = get_active_item()
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    -- Checking entity name if contains uinversal so this script is not called when holding another bag
    if active_item ~= nil and is_bag(active_item) and name_contains(active_item, "universal") then
        local inventory = get_inventory(active_item)
        -- Pickup spells
        if ModSettingGet("BagsOfMany.allow_spells") then
            local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
            add_spells_to_inventory(active_item, inventory, player_id, entities)
        end
        -- Pickup wands
        if ModSettingGet("BagsOfMany.allow_wands") then
            local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "wand")
            if ModIsEnabled("variaAddons") then
                local shovels = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "shovel")
                if shovels then
                    for _, shovel in ipairs(shovels) do
                        table.insert(entities, shovel)
                    end
                end
            end
            add_wands_to_inventory(active_item, inventory, player_id, entities)
        end
        -- Pickup potions
        if ModSettingGet("BagsOfMany.allow_potions") then
            local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "potion")
            add_potions_to_inventory(active_item, inventory, player_id, entities)
        end
        -- Pickup items
        if ModSettingGet("BagsOfMany.allow_items") then
            local entities = EntityGetInRadius(pos_x, pos_y, pickup_distance)
            add_items_to_inventory(active_item, inventory, player_id, entities)
        end
        -- Pickup bags
        if ModSettingGet("BagsOfMany.allow_bags_inception") then
            local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "item_pickup")
            add_bags_to_inventory(active_item, inventory, player_id, entities)
        end
    end
end