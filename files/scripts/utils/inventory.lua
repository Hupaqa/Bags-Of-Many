dofile_once( "mods/bags_of_many/files/scripts/utils/utils.lua" )

local pickup_distance = 20

function bag_pickup_action(entity_who_kicked, active_item)
    if is_universal_bag(active_item) then
        universal_bag_pickup(entity_who_kicked, active_item)
    elseif is_potion_bag(active_item) then
        potion_bag_pickup(entity_who_kicked, active_item)
    elseif is_spell_bag(active_item) then
        spell_bag_pickup(entity_who_kicked, active_item)
    end
end

function universal_bag_pickup(entity_who_kicked, active_item)
    local inventory = get_inventory(active_item)
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    -- Pickup spells
    if ModSettingGet("BagsOfMany.allow_spells") then
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
        add_spells_to_inventory(active_item, inventory, entity_who_kicked, entities)
    end
    -- Pickup wands
    if ModSettingGet("BagsOfMany.allow_wands") then
        local entities = EntityGetInRadius(pos_x, pos_y, pickup_distance)
        local wand_entities = {}
        if entities then
            for _, entity in ipairs(entities) do
                if is_wand(entity) then
                    table.insert(wand_entities, entity)
                end
            end
        end
        add_wands_to_inventory(active_item, inventory, entity_who_kicked, wand_entities)
    end
    -- Pickup potions
    if ModSettingGet("BagsOfMany.allow_potions") then
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "potion")
        add_potions_to_inventory(active_item, inventory, entity_who_kicked, entities)
    end
    -- Pickup items
    if ModSettingGet("BagsOfMany.allow_items") then
        local entities = EntityGetInRadius(pos_x, pos_y, pickup_distance)
        add_items_to_inventory(active_item, inventory, entity_who_kicked, entities)
    end
    -- Pickup bags
    if ModSettingGet("BagsOfMany.allow_bags_inception_universal_bag") or ModSettingGet("BagsOfMany.allow_bags_inception_potion_bag") or ModSettingGet("BagsOfMany.allow_bags_inception_spell_bag") then
        local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "item_pickup")
        add_bags_to_inventory(active_item, inventory, entity_who_kicked, entities)
    end
end

function potion_bag_pickup(entity_who_kicked, active_item)
    local inventory = get_inventory(active_item)
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
        -- Pickup potions
    local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "potion")
    add_potions_to_inventory(active_item, inventory, entity_who_kicked, entities)
end

function spell_bag_pickup(entity_who_kicked, active_item)
    local inventory = get_inventory(active_item)
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    -- Pickup spells
    local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
    add_spells_to_inventory(active_item, inventory, entity_who_kicked, entities)
end

function get_player_entity()
	local players = EntityGetWithTag("player_unit")
	if #players == 0 then return end

	return players[1]
end

function get_player_control_component()
    local player = get_player_entity()
    local control_comp = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    return control_comp
end

function get_entity_velocity_compenent(entity)
    local velocity_comp = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
    return velocity_comp
end

function has_material_inventory(entity)
    local material_inv = EntityGetComponentIncludingDisabled(entity, "MaterialInventoryComponent")
    if material_inv then
        return true
    end
    return false
end

function is_inventory_open()
	local player = get_player_entity()
	if player then
		local inventory_gui_component = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")
		if inventory_gui_component then
			return ComponentGetValue2(inventory_gui_component, "mActive")
		end
	end
end

function is_spell_permanently_attached(entity)
    local item_comps = EntityGetComponentIncludingDisabled(entity, "ItemComponent")
    if item_comps then
        for i = 1, #item_comps do
            return ComponentGetValue2(item_comps[i], "permanently_attached")
        end
    end
end

function is_in_bag_tree(bag, item_to_switch)
    local parent = item_to_switch
    while parent ~= 0 do
        if parent == bag then
            return true
        end
        parent = EntityGetParent(EntityGetParent(parent))
    end
    return false
end

function is_player_root_entity(entity)
    local player = get_player_entity()
    if player then
        local root = EntityGetRootEntity(entity)
        if root then
            return root == player
        end
    end
end

function is_wand(entity)
    local ability_comps = EntityGetComponentIncludingDisabled(entity, "AbilityComponent")
    if ability_comps then
        for _, ability_comp in ipairs(ability_comps) do
            local is_using_gun_script = ComponentGetValue2(ability_comp, "use_gun_script")
            if is_using_gun_script then
                return true
            else
                return false
            end
        end
    end
    return false
end

function is_item(entity)
    if entity then
        local tags = EntityGetTags(entity)
        return string.find(tags, "item_pickup") ~= nil
    else
        return false
    end
end

function is_potion(entity)
    if entity then
        local tags = EntityGetTags(entity)
        return string.find(tags, "potion") ~= nil
    else
        return false
    end
end

function is_powder_stash(entity)
    local is_powder_stash = false
    if entity then
        local sprite_comps = EntityGetComponentIncludingDisabled(entity, "SpriteComponent")
        if sprite_comps then
            for _, sprite_comp in ipairs(sprite_comps) do
                local image_file = ComponentGetValue(sprite_comp, "image_file")
                if image_file and image_file == "data/items_gfx/material_pouch.png" then
                    is_powder_stash = true
                end
            end
        end
        return is_powder_stash
    else
        return false
    end
end

function is_spell(entity)
    if entity then
        local tags = EntityGetTags(entity)
        return string.find(tags, "card_action") ~= nil
    else
        return false
    end
end

function is_bag(entity_id)
    if EntityGetName(entity_id) == nil then
        return false
    end
    return string.find(EntityGetName(entity_id), "bag_") ~= nil
end

function is_universal_bag(entity_id)
    return name_contains(entity_id, "universal")
end

function is_potion_bag(entity_id)
    return name_contains(entity_id, "potions")
end

function is_spell_bag(entity_id)
    return name_contains(entity_id, "spells")
end

function is_gold_nugget(entity_id)
    return string.find(EntityGetFilename(entity_id), "goldnugget") ~= nil
end

function is_allowed_in_universal_bag(entity_id)
    local is_a_spell = false
    local is_a_wand = false
    local is_a_potion = false
    local is_an_item = false
    local is_a_bag = false
    -- Pickup spells
    if ModSettingGet("BagsOfMany.allow_spells") then
        is_a_spell = is_spell(entity_id)
    end
    -- Pickup wands
    if ModSettingGet("BagsOfMany.allow_wands") then
        is_a_wand = is_wand(entity_id)
    end
    -- Pickup potions
    if ModSettingGet("BagsOfMany.allow_potions") then
        is_a_potion = is_potion(entity_id)
    end
    -- Pickup items
    if ModSettingGet("BagsOfMany.allow_items") then
        is_an_item = item_pickup_is_pickable_in_inventory(entity_id)
    end
    -- Pickup bags
    if ModSettingGet("BagsOfMany.allow_bags_inception") then
        is_a_bag = is_bag(entity_id)
    end
    return is_a_spell or is_a_wand or is_a_potion or is_an_item or is_a_bag
end

function is_shop_item(entity)
    local item_cost_comp = EntityGetFirstComponentIncludingDisabled(entity,"ItemCostComponent")
    if item_cost_comp then
        return true
    end
    return false
end

function is_stealable (entity)
    local item_cost_comp = EntityGetFirstComponentIncludingDisabled(entity,"ItemCostComponent")
    if item_cost_comp then
        return ComponentGetValue2(item_cost_comp, "stealable")
    end
    return true
end

function is_bag_one_smaller_than_bag_two(bag_one, bag_two)
    local first_bag_size = get_bag_size(bag_one)
    local second_bag_size = get_bag_size(bag_two)
    if first_bag_size and second_bag_size then
        return first_bag_size < second_bag_size
    end
    return false
end

function is_small_bag(entity)
    return name_contains(entity, "small")
end

function is_medium_bag(entity)
    return name_contains(entity, "medium")
end

function is_big_bag(entity)
    return name_contains(entity, "big")
end

-- 1 is small, 2 is medium, 3 is big, nil is error its not a bag
function get_bag_size(entity)
    if is_small_bag(entity) then
        return 1
    end
    if is_medium_bag(entity) then
        return 2
    end
    if is_big_bag(entity) then
        return 3
    end
end

function is_allowed_in_potions_bag(entity_id)
    return has_material_inventory(entity_id)
end

function is_allowed_in_spells_bag(entity_id)
    return is_spell(entity_id)
end

function is_allowed_in_bag(item_id, bag_id)
    if is_universal_bag(bag_id) then
        local entity_allowed_in_bag = false
        entity_allowed_in_bag = is_allowed_in_universal_bag(item_id)
        if ModSettingGet("BagsOfMany.allow_bags_inception_potion_bag") and is_potion_bag(item_id) then
            entity_allowed_in_bag = true
        elseif ModSettingGet("BagsOfMany.allow_bags_inception_spell_bag") and is_spell_bag(item_id) then
            entity_allowed_in_bag = true
        elseif ModSettingGet("BagsOfMany.allow_bags_inception_universal_bag") and is_universal_bag(item_id) then
            entity_allowed_in_bag = true
        end
        if not ModSettingGet("BagsOfMany.allow_big_bag_in_small_bag") then
            entity_allowed_in_bag = is_bag_one_smaller_than_bag_two(item_id, bag_id)
        end
        return entity_allowed_in_bag
    end
    if is_potion_bag(bag_id) then
        return is_allowed_in_potions_bag(item_id)
    end
    if is_spell_bag(bag_id) then
        return is_allowed_in_spells_bag(item_id)
    end
    return false
end

function find_item_level_in_draw_list(draw_list, item)
    local level_item = 0
    for key, value in pairs(draw_list) do
        if value == item then
            level_item = key
        end
    end
    return level_item
end

function remove_draw_list_up_to_level(draw_list, level)
    for key, _ in pairs(draw_list) do
        if key >= level then
            draw_list[key] = nil
        end
    end
    return draw_list
end

function remove_draw_list_under_level(draw_list, level)
    for key, _ in pairs(draw_list) do
        if key > level then
            draw_list[key] = nil
        end
    end
    return draw_list
end

function item_pickup_is_pickable_in_inventory(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        local ui_sprite = ComponentGetValue2(item_comp, "ui_sprite")
        return ui_sprite ~= ""
    end
    return false
end

function name_contains(entity_id, contains_string)
    if EntityGetName(entity_id) == nil then
        return false
    end
    return string.find(EntityGetName(entity_id), contains_string) ~= nil
end

function is_bag_not_full(bag, maximum)
    return #get_bag_inventory_items(bag, false, false) < maximum
end

function drop_item_from_parent(item, with_movement, delta_x, delta_y)
    if item then
        local active_item = get_active_item()
        if active_item then
            local override_bag = get_bag_pickup_override(active_item)
            if override_bag == item then
                toggle_bag_pickup_override(active_item, 0)
            end
        end
        local root = EntityGetRootEntity(item)
        local x, y = EntityGetTransform(root)
        if delta_x and delta_y then
            x = x + delta_x
            y = y + delta_y
        end
        remove_component_pickup_frame(item)
        remove_item_position(item)
        EntityRemoveFromParent(item)
        EntityApplyTransform(item, x, y - 5)
        show_entity(item)
        local control_comp = get_player_control_component()
        if control_comp and with_movement then
            local player = get_player_entity()
            local aiming_vec_x, aiming_vec_y = ComponentGetValue2(control_comp, "mAimingVector")
            local physic_comp = EntityGetFirstComponentIncludingDisabled(item, "PhysicsBodyComponent")
            if aiming_vec_x and aiming_vec_y then
                if physic_comp and player then
                    GameShootProjectile(player, x, y - 5, x + aiming_vec_x,  y - 5 + aiming_vec_y, item)
                else
                    local velocity_comp = EntityGetFirstComponentIncludingDisabled(item, "VelocityComponent")
                    local item_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
                    if item_comp then
                        ComponentSetValue2(item_comp, "has_been_picked_by_player", true)
                        ComponentSetValue2(item_comp, "play_hover_animation", false)
                    end
                    if velocity_comp then
                        ComponentSetValueVector2(velocity_comp, "mVelocity", aiming_vec_x, aiming_vec_y)
                    end
                end
            end
        end
    end
end

function drop_all_inventory(bag, orderly, sort_by_time, sorting_order)
    local items = get_bag_inventory_items(bag, sort_by_time, sorting_order)
    if orderly then
        local spacing = ModSettingGet("BagsOfMany.drop_orderly_distance")
        if not spacing then
            spacing = 10
        else
            spacing = math.floor(spacing)
        end
        local left_most = -spacing * (#items/2)
        for i, item in ipairs(items or {}) do
            drop_item_from_parent(item, false, left_most + (spacing * (i - 1)), 0)
        end
    else
        for _, item in ipairs(items or {}) do
            drop_item_from_parent(item)
        end
    end
end

function get_player_inventory_quick()
    for _, child in ipairs(EntityGetAllChildren(EntityGetWithTag("player_unit")[1])) do
        if EntityGetName(child) == "inventory_quick" then
            return child
        end
    end
end

function get_player_inventory_full()
    for _, child in ipairs(EntityGetAllChildren(EntityGetWithTag("player_unit")[1])) do
        if EntityGetName(child) == "inventory_full" then
            return child
        end
    end
end

function get_item_pickup_frame(entity)
    local var_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    for _, var_storage in ipairs(var_storages or {}) do
        if ComponentGetValue2(var_storage, "name") == "item_pickup_frame" then
            return ComponentGetValue2(var_storage, "value_int")
        end
    end
    return 0
end

function get_bag_pickup_override(bag)
    local bag_pickup_override_storage = get_var_storage_with_name(bag, "bags_of_many_bag_pickup_override")
    if bag_pickup_override_storage then
        local bag_pickup_override = ComponentGetValue2(bag_pickup_override_storage, "value_int")
        if bag_pickup_override == 0 then
            return nil
        end
        return bag_pickup_override
    end
end

function toggle_bag_pickup_override(main_bag, secondary_bag)
    local bag_pickup_override_storage = get_var_storage_with_name(main_bag, "bags_of_many_bag_pickup_override")
    if not bag_pickup_override_storage then
        bag_pickup_override_storage = EntityAddComponent2(main_bag, "VariableStorageComponent", {
            name="bags_of_many_bag_pickup_override",
        })
    end
    if bag_pickup_override_storage then
        local bag_pickup_override = ComponentGetValue2(bag_pickup_override_storage, "value_int")
        if bag_pickup_override and bag_pickup_override == secondary_bag then
            ComponentSetValue2(bag_pickup_override_storage, "value_int", 0)
        else
            ComponentSetValue2(bag_pickup_override_storage, "value_int", secondary_bag)
        end
    end
end

function add_component_pickup_frame(entity)
    local var_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    local item_has_item_pickup_frame = false
    for _, var_storage in ipairs(var_storages or {}) do
        if ComponentGetValue2(var_storage, "name") == "item_pickup_frame" then
            item_has_item_pickup_frame = true
            ComponentSetValue2(var_storage, "value_int", GameGetFrameNum())
        end
    end
    if not item_has_item_pickup_frame then
        EntityAddComponent2(entity, "VariableStorageComponent", {
            name="item_pickup_frame",
            value_int=GameGetFrameNum(),
        })
    end
end

function remove_component_pickup_frame(entity)
    local var_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    for _, var_storage in ipairs(var_storages or {}) do
        if ComponentGetValue2(var_storage, "name") == "item_pickup_frame" then
            EntityRemoveComponent(entity, var_storage)
        end
    end
end

function add_item_position(entity, position)
    local var_storage = get_var_storage_with_name(entity, "bags_of_many_item_position")
    if var_storage then
        ComponentSetValue2(var_storage, "value_int", position)
    else
        EntityAddComponent2(entity, "VariableStorageComponent", {
            name="bags_of_many_item_position",
            value_int=position,
        })
    end
end

function remove_item_position(entity)
    local var_storage = get_var_storage_with_name(entity, "bags_of_many_item_position")
    if var_storage then
        EntityRemoveComponent(entity, var_storage)
    end
end

-- SWAPS ITEM TO A POSITION (EMPTY POSITION)
function swap_item_to_position(item, position, bag)    
    -- Prevent bag being placed inside themselves (will cause CRASH)
    if item == bag then
        return
    end

    -- Make sure item is allowed in this bag type
    if not is_allowed_in_bag(item, bag) then
        return
    end

    local var_storage_one = get_var_storage_with_name(item, "bags_of_many_item_position")
    if var_storage_one then
        local bag_inventory = get_inventory(bag)
        local item_inventory = EntityGetParent(item)
        if bag_inventory ~= item_inventory then
            EntityRemoveFromParent(item)
            EntityAddChild(bag_inventory, item)
        end
        ComponentSetValue2(var_storage_one, "value_int", position)
    end
end

-- SWAPS ITEM ONE TO ITEM TWO POSITION (SWAP TO NOT EMPTY POSITION)
function swap_item_position(dragged_item, hovered_item)
    if dragged_item and hovered_item then
        local bag_one = EntityGetParent(EntityGetParent(dragged_item))
        local bag_two = EntityGetParent(EntityGetParent(hovered_item))
        -- In case for some reason the item is not in a bag ?
        if not bag_one or not bag_two then
            return
        end

        if bag_one == bag_two then
            local var_storage_one = get_var_storage_with_name(dragged_item, "bags_of_many_item_position")
            local var_storage_two = get_var_storage_with_name(hovered_item, "bags_of_many_item_position")
            if var_storage_one and var_storage_two then
                local position_one = ComponentGetValue2(var_storage_one, "value_int")
                local position_two = ComponentGetValue2(var_storage_two, "value_int")
                ComponentSetValue2(var_storage_one, "value_int", position_two)
                ComponentSetValue2(var_storage_two, "value_int", position_one)
            end
        else
            -- Make sure item can be switched from one bag to the other
            if not is_allowed_in_bag(dragged_item, bag_two) or not is_allowed_in_bag(hovered_item, bag_one) then
                return
            end

            -- Different bags switching two items
            local var_storage_one = get_var_storage_with_name(dragged_item, "bags_of_many_item_position")
            local var_storage_two = get_var_storage_with_name(hovered_item, "bags_of_many_item_position")
            if var_storage_one and var_storage_two then
                local position_one = ComponentGetValue2(var_storage_one, "value_int")
                local position_two = ComponentGetValue2(var_storage_two, "value_int")
                local inventory_one = EntityGetParent(dragged_item)
                local inventory_two = EntityGetParent(hovered_item)
                ComponentSetValue2(var_storage_one, "value_int", position_two)
                ComponentSetValue2(var_storage_two, "value_int", position_one)
                EntityRemoveFromParent(dragged_item)
                EntityRemoveFromParent(hovered_item)
                EntityAddChild(inventory_one, hovered_item)
                EntityAddChild(inventory_two, dragged_item)
            end
        end
    end
end

function swap_item_to_bag(item, bag)
    -- Prevent bag being placed inside themselves (will cause CRASH)
    if item == bag then
        return
    end

    -- Make sure item is allowed in this bag type
    if not is_allowed_in_bag(item, bag) then
        return
    end

    if item and bag then
        local bag_inventory = get_inventory(bag)
        if bag_inventory and bag_inventory ~= bag and is_bag_not_full(bag, get_bag_inventory_size(bag)) then
            EntityRemoveFromParent(item)
            EntityAddChild(bag_inventory, item)
            add_item_position(item, get_smallest_position_avalaible(bag))
        end
    end
end

function remove_entity_from_var_storage(bag, entity)
    if bag then
        local variable_storages = EntityGetComponentIncludingDisabled(bag, "VariableStorageComponent")
        for _, var_storage in ipairs(variable_storages or {}) do
            if var_storage then
                local initial_val = ComponentGetValue2(var_storage, "value_string")
                local t = string_table_to_table(initial_val)
                local index = find_value_in_table(t, entity)
                t = remove_value_in_table(t, index)
                ComponentSetValue2(var_storage, "value_string", table_to_string_table(t))
            end
        end
    end
end

function add_item_to_inventory(inventory, path)
    local item = EntityLoad(path)
    if item then
        GamePickUpInventoryItem(inventory, item)
    else
        GamePrint("Error: Couldn't load the item ["..path.."]!")
    end
    return item
end

function add_entity_to_inventory_bag(bag, inventory, entity)
    add_component_pickup_frame(entity)
    EntityRemoveFromParent(entity)
    EntityAddChild(inventory, entity)
    hide_entity(entity)
    add_item_position(entity, get_smallest_position_avalaible(bag))
end

function add_spells_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if EntityGetParent(entity) == 0 then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                if not ModSettingGet("BagsOfMany.allow_holy_mountain_spell_stealing") then
                    if not is_shop_item(entity) then
                        add_entity_to_inventory_bag(active_item, inventory, entity)
                    end
                else
                    add_entity_to_inventory_bag(active_item, inventory, entity)
                end
            end
        end
    end
end

function add_wands_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        local can_be_picked_up = true
        if not ModSettingGet("BagsOfMany.allow_tower_wand_stealing") then
            if EntityHasTag(entity, "wand_good") then
                can_be_picked_up = false
            end
        end
        if not ModSettingGet("BagsOfMany.allow_holy_mountain_wand_stealing") then
            if is_shop_item(entity) then
                can_be_picked_up = false
            end
        end
        if EntityGetParent(entity) == 0 and can_be_picked_up then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(active_item, inventory, entity)
            end
        end
    end
end

function add_potions_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if EntityGetParent(entity) == 0 then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(active_item, inventory, entity)
            end
        end
    end
end

function add_items_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        local can_be_picked_up = true
        if not ModSettingGet("BagsOfMany.allow_sampo_stealing") then
            if EntityHasTag(entity, "this_is_sampo") then
                can_be_picked_up = false
            end
        end
        if not is_bag(entity) and entity ~= active_item and item_pickup_is_pickable_in_inventory(entity) then
            if EntityGetParent(entity) == 0 and can_be_picked_up then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    add_entity_to_inventory_bag(active_item, inventory, entity)
                end
            end
        end
    end
end

function add_bags_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        local entity_allowed_in_bag = false
        if is_bag(entity) and entity ~= active_item then
            if EntityGetParent(entity) == 0 then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    if ModSettingGet("BagsOfMany.allow_bags_inception_potion_bag") and is_potion_bag(entity) then
                        entity_allowed_in_bag = true
                    elseif ModSettingGet("BagsOfMany.allow_bags_inception_spell_bag") and is_spell_bag(entity) then
                        entity_allowed_in_bag = true
                    elseif ModSettingGet("BagsOfMany.allow_bags_inception_universal_bag") and is_universal_bag(entity) then
                        entity_allowed_in_bag = true
                    end
                    if not ModSettingGet("BagsOfMany.allow_big_bag_in_small_bag") then
                        entity_allowed_in_bag = is_bag_one_smaller_than_bag_two(entity, active_item)
                    end
                end
            end
        end
        if entity_allowed_in_bag then
            add_entity_to_inventory_bag(active_item, inventory, entity)
        end
    end
end

function get_active_item()
    local player = EntityGetWithTag("player_unit")[1]
    if player then
        local activeItem = ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component"), "mActualActiveItem")
        return activeItem > 0 and activeItem or nil
    end
end

function get_inventory( entity_id )
    for _, child in ipairs(EntityGetAllChildren(entity_id) or {}) do
        if EntityGetName(child) == "inventory_full" then
            return child
        end
    end
end

function get_bag_inventory_items(entity_id, sort, order_asc)
    local inventory = get_inventory(entity_id)
    local items = EntityGetAllChildren(inventory)
    if items then
        if sort then
            sort_entity_by_pickup_frame(items, order_asc)
        else
            sort_entity_by_position(items)
        end
        return items
    else
        return {}
    end
end

function get_inventory_bag_owner(item)
    local inventory = EntityGetParent(item)
    return EntityGetParent(inventory)
end

function get_bag_items(entity_id)
    local inventory = get_inventory(entity_id)
    local items = EntityGetAllChildren(inventory)
    if items then
        return items
    else
        return {}
    end
end

function get_item_position(entity_id)
    local var_storage = get_var_storage_with_name(entity_id, "bags_of_many_item_position")
    if var_storage then
        return ComponentGetValue2(var_storage, "value_int")
    end
    return 0
end

function get_smallest_position_avalaible(bag)
    local items = get_bag_items(bag)
    local bag_size = get_bag_inventory_size(bag)
    local smallest_pos = 1
    local i = 1
    while smallest_pos <= bag_size and i <= bag_size do
        local var_storage = get_var_storage_with_name(items[i], "bags_of_many_item_position")
        local restart = false
        if var_storage then
            if ComponentGetValue2(var_storage, "value_int") == smallest_pos then
                smallest_pos = smallest_pos + 1
                restart = true
            end
        end
        if restart then
            i = 1
        else
            i = i + 1
        end
    end
    return smallest_pos
end

function get_bag_inventory_size( entity_id )
    local size = tonumber(ModSettingGet("BagsOfMany.".. EntityGetName(entity_id) .. "_size"))
    if not size then
        size = 0
    else
        return math.floor(size)
    end
end

function get_sprite_file( entity_id )
    local sprite = "mods/bags_of_many/files/ui_gfx/inventory/unidentified_item.png"
    -- Sprite for the spells and wands
    if EntityHasTag(entity_id, "card_action") or is_wand(entity_id) then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if item_component then
            local wand_sprite = ComponentGetValue2(item_component[1], "image_file")
            if wand_sprite and wand_sprite ~= "" then
                sprite = wand_sprite
            end
        end
    -- Sprite for gold nuggets
    elseif is_gold_nugget(entity_id) then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "PhysicsImageShapeComponent")
        if item_component then
            local item_sprite = ComponentGetValue2(item_component[1], "image_file")
            if item_sprite and item_sprite ~= "" then
                sprite = item_sprite
            end
        end
    -- Sprite for the other items
    else
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
        if item_component then
            local item_sprite = ComponentGetValue2(item_component[1], "ui_sprite")
            if item_sprite and item_sprite ~= "" then
                sprite = item_sprite
            end
        end
    end

    -- In case no sprite was found for the item try one last search otherwise will show a unenditified sprite in the bag
    if sprite == "mods/bags_of_many/files/ui_gfx/inventory/unidentified_item.png" then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if item_component then
            local item_sprite = ComponentGetValue2(item_component[1], "image_file")
            if item_sprite and item_sprite ~= "" then
                sprite = item_sprite
            end
        end
    end
    return sprite
end

function hide_entity( entity_id )
    local components = EntityGetAllComponents(entity_id)
    local children = EntityGetAllChildren(entity_id)
    for _, child in ipairs(children or {}) do
        hide_entity(child)
    end
    for _, component in ipairs(components or {}) do
        EntitySetComponentIsEnabled(entity_id, component, false)
    end
end

function show_entity( entity_id )
    local x, y = get_player_pos()
    local components = EntityGetAllComponents(entity_id)
    local components_sprite = EntityGetComponentIncludingDisabled(entity_id, "SpriteParticleEmitterComponent")
    for _, component_sprite in ipairs(components_sprite or {}) do
        if ComponentHasTag(component_sprite, "enabled_in_world") then
            EntitySetComponentIsEnabled(entity_id, component_sprite, true)
        end
    end
    for _, component in ipairs(components or {}) do
        if ComponentHasTag(component, "enabled_in_world") then
            local component_type = ComponentGetTypeName(component)
            if component_type == "SpriteComponent" then
                local file_name = ComponentGetValue2(component, "image_file")
                if file_name and not string.find(file_name, "unidentified.png") then
                    EntitySetComponentIsEnabled(entity_id, component, true)
                end
            else
                EntitySetComponentIsEnabled(entity_id, component, true)
            end
        end
    end
end

function moved_far_enough(pos_x, pos_y, init_x, init_y, limit_x, limit_y)
    local moved_enough = false
    local delta_x = pos_x - init_x
    local delta_y = pos_y - init_y
    if delta_x > limit_x or delta_y > limit_y or delta_x < 0 or delta_y < 0 then
        moved_enough = true
    end
    return moved_enough
end

function sort_entity_by_pickup_frame(inventory, order_asc)
    insertion_sort_entityId(inventory)
    insertion_sort_frame(inventory)
    if not order_asc then
        inventory = revert_table(inventory)
    end
end

function sort_entity_by_position(inventory)
    insertion_sort_position(inventory)
end

function insertion_sort_position(array)
    local len = #array
    for j = 2, len do
        local key = array[j]
        local i = j - 1
        while i > 0 and get_item_position(array[i]) > get_item_position(key) do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = key
    end
    return array
end

function insertion_sort_entityId(array)
    local len = #array
    for j = 2, len do
        local key = array[j]
        local i = j - 1
        while i > 0 and array[i] > key do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = key
    end
    return array
end

function insertion_sort_frame(array)
    local len = #array
    for j = 2, len do
        local key = array[j]
        local i = j - 1
        while i > 0 and get_item_pickup_frame(array[i]) > get_item_pickup_frame(key) do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = key
    end
    return array
end

function revert_table(x)
    local n, m = #x, #x/2
    for i=1, m do
      x[i], x[n-i+1] = x[n-i+1], x[i]
    end
    return x
end