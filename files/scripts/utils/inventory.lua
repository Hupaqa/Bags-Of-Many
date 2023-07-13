dofile_once( "mods/bags_of_many/files/scripts/utils/utils.lua" )

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

function has_bag_container( entity_id )
    local childs = EntityGetAllChildren(entity_id)
    if not childs then
        return false
    end
    for _, child in ipairs(childs) do
        if EntityGetName(child) == "bag_inventory_container" then
            return true
        end
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

function is_wand(entity)
	local tags = EntityGetTags(entity)
    return string.find(tags, "wand") ~= nil
end

function is_item(entity)
	local tags = EntityGetTags(entity)
    return string.find(tags, "item_pickup") ~= nil
end

function is_potion(entity)
    local tags = EntityGetTags(entity)
    return string.find(tags, "potion") ~= nil
end

function is_spell(entity)
    local tags = EntityGetTags(entity)
    return string.find(tags, "card_action") ~= nil
end

function is_bag(entity_id)
    if EntityGetName(entity_id) == nil then
        return false
    end
    return string.find(EntityGetName(entity_id), "bag_") ~= nil
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
            local aiming_vec_x, aiming_vec_y = ComponentGetValue2(control_comp, "mAimingVector")
            GameShootProjectile(get_player_entity(), x, y - 5, x + aiming_vec_x,  y - 5 + aiming_vec_y, item)
        end
    end
end

function drop_all_inventory(bag, orderly)
    local items = get_bag_inventory_items(bag, sort_by_time, sorting_order)
    if orderly then
        local spacing = 4
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

function get_pickable_items_in_radius(radius)
    local closest_entities = EntityGetInRadius(pos_x, pos_y, radius)
    local pickable_items = {}
    for i, entity in ipairs(closest_entities) do
        if is_item(entity) then
            table.insert(pickable_items, entity)
        end
    end
    return pickable_items
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

function add_entity_to_var_storage(bag, entity)
    if bag then
        local variable_storages = EntityGetComponentIncludingDisabled(bag, "VariableStorageComponent")
        for _, var_storage in ipairs(variable_storages or {}) do
            if var_storage then
                local initial_val = ComponentGetValue2(var_storage, "value_string")
                local t = string_table_to_table(initial_val)
                table.insert(t, tostring(entity))
                ComponentSetValue2(var_storage, "value_string", table_to_string_table(t))
            end
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

function swap_item_to_position(item, position)
    local var_storage_one = get_var_storage_with_name(item, "bags_of_many_item_position")
    if var_storage_one then
        ComponentSetValue2(var_storage_one, "value_int", position)
    end
end

function swap_item_position(item_one, item_two)
    if item_one and item_two then
        local bag_one = EntityGetParent(EntityGetParent(item_one))
        local bag_two = EntityGetParent(EntityGetParent(item_two))
        if bag_one == bag_two then
            local var_storage_one = get_var_storage_with_name(item_one, "bags_of_many_item_position")
            local var_storage_two = get_var_storage_with_name(item_two, "bags_of_many_item_position")
            if var_storage_one and var_storage_two then
                local position_one = ComponentGetValue2(var_storage_one, "value_int")
                local position_two = ComponentGetValue2(var_storage_two, "value_int")
                ComponentSetValue2(var_storage_one, "value_int", position_two)
                ComponentSetValue2(var_storage_two, "value_int", position_one)
            end
        else
            -- local var_storage_one = get_var_storage_with_name(bag_one, "bags_of_many_positions")
            -- local var_storage_two = get_var_storage_with_name(bag_two, "bags_of_many_positions")
            -- if var_storage_one and var_storage_two then
            --     local table_positions_one = ComponentGetValue2(var_storage_one, "value_string")
            --     local table_positions_two = ComponentGetValue2(var_storage_two, "value_string")
            --     local map_positions_one, size_one = string_to_map(table_positions_one)
            --     local map_positions_two, size_two = string_to_map(table_positions_two)
            --     local entity_temp = map_positions_one[pos_one]
            --     map_positions_one[pos_one] = map_positions_two[pos_two]
            --     map_positions_two[pos_two] = entity_temp
            --     local map_stringified_one = map_to_string(map_positions_one, size_one)
            --     local map_stringified_two = map_to_string(map_positions_two, size_two)
            --     ComponentSetValue2(var_storage_one, "value_string", map_stringified_one)
            --     ComponentSetValue2(var_storage_two, "value_string", map_stringified_two)
            -- end
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
        local parent = EntityGetParent(entity)
        local root_entity = EntityGetRootEntity(entity)
        if root_entity ~= player_id and not is_bag(root_entity) then
            if not EntityHasTag(parent, "wand") and is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(active_item, inventory, entity)
            end
        end
    end
end

function add_wands_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        local root_entity = EntityGetRootEntity(entity)
        if root_entity ~= player_id and not is_bag(root_entity) then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(active_item, inventory, entity)
            end
        end
    end
end

function add_potions_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        local root_entity = EntityGetRootEntity(entity)
        if root_entity ~= player_id and not is_bag(root_entity) then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(active_item, inventory, entity)
            end
        end
    end
end

function add_items_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if not is_bag(entity) and entity ~= active_item and not EntityHasTag(entity ,"essence") and item_pickup_is_pickable_in_inventory(entity) then
            local root_entity = EntityGetRootEntity(entity)
            if root_entity ~= player_id and not is_bag(root_entity) then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    add_entity_to_inventory_bag(active_item, inventory, entity)
                end
            end
        end
    end
end

function add_bags_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if is_bag(entity) and entity ~= active_item then
            local root_entity = EntityGetRootEntity(entity)
            if root_entity ~= player_id and (root_entity == entity or not is_bag(root_entity)) then
                if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                    add_entity_to_inventory_bag(active_item, inventory, entity)
                end
            end
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

function get_potion_content( entity_id )
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if suc_component ~= nil and inv_component ~= nil then
        local capacity = ComponentGetValue2(suc_component, "barrel_size")
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        local total = 0
        for i = 1, #counts do
            total = total + counts[i]
        end
        local biggest_percent_mat
        if total > 0 then
            for i = 1, #counts do
                local material = {
                    name = CellFactory_GetUIName(i - 1),
                    amount = (capacity/10) * (counts[i]/total)
                }
                if i == 1 then
                    biggest_percent_mat = material
                elseif biggest_percent_mat.amount < material.amount then
                    biggest_percent_mat = material
                end
            end
        end
        return biggest_percent_mat
    end
end

function get_sprite_file( entity_id )
    -- Sprite for the spells and wands
    if EntityHasTag(entity_id, "card_action") or EntityHasTag(entity_id, "wand") then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if item_component then
            return ComponentGetValue2(item_component[1], "image_file")
        end
    -- Sprite for the other items
    else
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "ItemComponent")
        if item_component then
            return ComponentGetValue2(item_component[1], "ui_sprite")
        end
    end
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