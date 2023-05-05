dofile_once( "mods/bags_of_many/files/scripts/utils/debug.lua" )

function get_player_entity()
	local players = EntityGetWithTag("player_unit")
	if #players == 0 then return end

	return players[1]
end

function has_bag_container( entity_id )
    local childs = EntityGetAllChildren(entity_id)
    if not childs then
        return false
    end
    for i, child in ipairs(childs) do
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

function is_bag(entity_id)
    return EntityGetName(entity_id) == "bag_small"
end

function is_bag_not_full(bag, maximum)
    return #get_bag_inventory_items(bag) < maximum
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

function get_player_inventory()
    for i, child in ipairs(EntityGetAllChildren(EntityGetWithTag("player_unit")[1])) do
        if EntityGetName(child) == "inventory_quick" then
            return child
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
end

function add_item_to_bag_inventory(inventory, item)
    if item then
        EntityAddChild(inventory, item)
        return item
    else
        GamePrint("Error: Couldn't load the item ["..path.."]!")
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
    for i, child in ipairs(EntityGetAllChildren(entity_id) or {}) do
        if EntityGetName(child) == "inventory_full" then
            return child
        end
    end
end

function get_bag_inventory_items( entity_id )
    local inventory = get_inventory(entity_id)
    local items = EntityGetAllChildren(inventory)
    if items then
        return items
    else
        return {}
    end
end

function get_bag_inventory_size( entity_id )
    return ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(entity_id, "Inventory2Component"), "full_inventory_slots_x")
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

function hide_entity( entity_id )
    local components = EntityGetAllComponents(entity_id)
    for _, component in ipairs(components or {}) do
        EntitySetComponentIsEnabled(entity_id, component, false)
    end
end

function show_entity( entity_id )
    local components = EntityGetAllComponents(entity_id)
    for _, component in ipairs(components or {}) do
        local component_type = ComponentGetTypeName(component)
        if component_type == "SpriteComponent" then
            local file_name = ComponentGetValue2(component, "image_file")
            if file_name and not string.find(file_name, "unidentified.png") then
                EntitySetComponentIsEnabled(entity_id, component, true)
            end
        elseif component_type ~= "SpriteParticleEmitterComponent" then
            EntitySetComponentIsEnabled(entity_id, component, true)
        end
    end
end