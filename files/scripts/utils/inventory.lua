dofile_once( "mods/bags_of_many/files/scripts/utils/utils.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/noita_utils.lua" )

--- @param x number
--- @param y number
--- @param r number
--- @return table
local function get_entities_with_material_inventory_in_radius(x, y, r)
	local ents=EntityGetInRadius(x,y,r)
	local out={}
	for i=1,#ents do
		local eid=ents[i]
		if EntityGetFirstComponentIncludingDisabled(eid,"MaterialInventoryComponent") and EntityHasTag(eid,"item_pickup") then
		--so basically, look for anything with a material component, and make sure that it is an item - because things other than potions have a MaterialInventoryComponent, such as the player - and putting the player inside a bag softlocks the save (pretty funny).
			out[#out+1]=ents[i]
		end
	end
	return out
end

local pickup_distance = 20

--- @param entity_who_kicked integer
--- @param active_item integer
--- @return nil
function bag_pickup_action(entity_who_kicked, active_item)
    if is_universal_bag(active_item) then
        universal_bag_pickup(entity_who_kicked, active_item)
    elseif is_potion_bag(active_item) then
        potion_bag_pickup(entity_who_kicked, active_item)
    elseif is_spell_bag(active_item) then
        spell_bag_pickup(entity_who_kicked, active_item)
    end
end

--- @param entity_who_kicked integer
--- @param active_item integer
--- @return nil
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
        local entities = get_entities_with_material_inventory_in_radius(pos_x, pos_y, pickup_distance)
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

--- @param entity_who_kicked integer
--- @param active_item integer
--- @return nil
function potion_bag_pickup(entity_who_kicked, active_item)
    local inventory = get_inventory(active_item)
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
        -- Pickup potions
    local entities = get_entities_with_material_inventory_in_radius(pos_x, pos_y, pickup_distance)
    add_potions_to_inventory(active_item, inventory, entity_who_kicked, entities)
end

--- @param entity_who_kicked integer
--- @param active_item integer
--- @return nil
function spell_bag_pickup(entity_who_kicked, active_item)
    local inventory = get_inventory(active_item)
    local pos_x, pos_y = EntityGetTransform(entity_who_kicked)
    -- Pickup spells
    local entities = EntityGetInRadiusWithTag(pos_x, pos_y, pickup_distance, "card_action")
    add_spells_to_inventory(active_item, inventory, entity_who_kicked, entities)
end

--- @return integer|nil
function get_player_entity()
	return EntityGetWithTag("player_unit")[1]
end

--- @return integer|nil
function get_player_control_component()
    local player = get_player_entity()
    if player then        
        local control_comp = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
        return control_comp
    end
end

--- @param entity integer
--- @return integer|nil
function get_entity_velocity_component(entity)
    local velocity_comp = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
    return velocity_comp
end

--- @param entity integer
--- @return boolean
function has_material_inventory(entity)
    local material_inv = EntityGetComponentIncludingDisabled(entity, "MaterialInventoryComponent")
    if material_inv then
        return true
    end
    return false
end

--- @param entity_one integer
--- @param entity_two integer
--- @return boolean
function is_same_entity_type(entity_one, entity_two)
    local entity_one_type = -1
    if is_bag(entity_one) then
        entity_one_type = 0
    elseif is_item(entity_one) then
        entity_one_type = 1
    elseif is_spell(entity_one) then
        entity_one_type = 2
    end
    local entity_two_type = -1
    if is_bag(entity_two) then
        entity_two_type = 0
    elseif is_item(entity_two) then
        entity_two_type = 1
    elseif is_spell(entity_two) then
        entity_two_type = 2
    end
    return entity_one_type == entity_two_type
end

--- @param inventory integer
--- @return boolean
function is_bag_inventory(inventory)
    if inventory then
        local inv_parent = EntityGetParent(inventory)
        if inv_parent and is_bag(inv_parent) then
            return true
        end
    end
    return false
end

--- @return boolean
function is_inventory_open()
	local player = get_player_entity()
	if player then
		local inventory_gui_component = EntityGetFirstComponentIncludingDisabled(player, "InventoryGuiComponent")
		if inventory_gui_component then
			return ComponentGetValue2(inventory_gui_component, "mActive")
		end
	end
    return false
end

--- @param entity integer
--- @return boolean
function is_spell_permanently_attached(entity)
    local item_comps = EntityGetComponentIncludingDisabled(entity, "ItemComponent")
    if item_comps then
        for i = 1, #item_comps do
            return ComponentGetValue2(item_comps[i], "permanently_attached")
        end
    end
    return false
end

--- @param bag integer
--- @param item_to_switch integer
--- @return boolean
function is_in_bag_tree(bag, item_to_switch)
    if not item_to_switch then
        return false
    end
    local parent = item_to_switch
    while parent ~= 0 do
        if parent == bag then
            return true
        end
        parent = EntityGetParent(EntityGetParent(parent))
    end
    return false
end

--- @param entity integer
--- @return boolean
function is_player_root_entity(entity)
    local player = get_player_entity()
    if player then
        local root = EntityGetRootEntity(entity)
        if root then
            return root == player
        end
    end
    return false
end

--- @param entity integer
--- @return boolean
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

--- @param entity integer
--- @return boolean
function is_item(entity)
    local ability_component = EntityGetFirstComponentIncludingDisabled(entity, "AbilityComponent")
    local ending_mc_guffin_component = EntityGetFirstComponentIncludingDisabled(entity, "EndingMcGuffinComponent")
    return ((not ability_component) or ending_mc_guffin_component or ComponentGetValue2(ability_component, "use_gun_script")) == false
end

--- @param entity integer
--- @return boolean
function is_item_old(entity)
    if entity then
        local tags = EntityGetTags(entity)
        if tags then
            return string.find(tags, "item_pickup") ~= nil
        end
    end
    return false
end

--- @param entity integer
--- @return boolean
function is_potion(entity)
    if entity then
        local tags = EntityGetTags(entity)
        if tags then
            return string.find(tags, "potion") ~= nil
        end
    end
    return false
end

--- @param entity integer
--- @return boolean
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

--- @param entity integer
--- @return boolean
function is_spell(entity)
    if entity then
        local tags = EntityGetTags(entity)
        if tags then
            return string.find(tags, "card_action") ~= nil
        end    
    end
    return false
end

--- @param entity_id integer
--- @return boolean
function is_bag(entity_id)
    if EntityGetName(entity_id) == nil then
        return false
    end
    return string.find(EntityGetName(entity_id), "bag_") ~= nil
end

--- @param entity_id integer
--- @return boolean
function is_universal_bag(entity_id)
    return name_contains(entity_id, "universal")
end

--- @param entity_id integer
--- @return boolean
function is_potion_bag(entity_id)
    return name_contains(entity_id, "potions")
end

--- @param entity_id integer
--- @return boolean
function is_spell_bag(entity_id)
    return name_contains(entity_id, "spells")
end

--- @param entity_id integer
--- @return boolean
function is_gold_nugget(entity_id)
    return string.find(EntityGetFilename(entity_id), "goldnugget") ~= nil
end

--- @param entity_id integer
--- @return boolean
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

--- @param entity integer
--- @return boolean
function is_shop_item(entity)
    local item_cost_comp = EntityGetFirstComponentIncludingDisabled(entity,"ItemCostComponent")
    if item_cost_comp then
        return true
    end
    return false
end

--- @param entity integer
--- @return boolean
function is_stealable (entity)
    local item_cost_comp = EntityGetFirstComponentIncludingDisabled(entity,"ItemCostComponent")
    if item_cost_comp then
        return ComponentGetValue2(item_cost_comp, "stealable")
    end
    return true
end

--- @param bag_one integer
--- @param bag_two integer
--- @return boolean
function is_bag_one_smaller_than_bag_two(bag_one, bag_two)
    if not is_bag(bag_one) or not is_bag(bag_two) then
        return true
    end
    local first_bag_size = get_bag_size(bag_one)
    local second_bag_size = get_bag_size(bag_two)
    if first_bag_size and second_bag_size then
        return first_bag_size < second_bag_size
    end
    return false
end

--- @param entity integer
--- @return boolean
function is_small_bag(entity)
    return name_contains(entity, "small")
end

--- @param entity integer
--- @return boolean
function is_medium_bag(entity)
    return name_contains(entity, "medium")
end

--- @param entity integer
--- @return boolean
function is_big_bag(entity)
    return name_contains(entity, "big")
end

--- @param entity integer
--- @return integer|nil
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

--- @param entity_id integer
--- @return boolean
function is_allowed_in_potions_bag(entity_id)
    return has_material_inventory(entity_id)
end

--- @param entity_id integer
--- @return boolean
function is_allowed_in_spells_bag(entity_id)
    return is_spell(entity_id)
end

--- @param item_id integer
--- @param bag_id integer
--- @return boolean
function is_allowed_in_bag(item_id, bag_id)
    if is_bag(item_id) and is_in_bag_tree(item_id, bag_id) then
        return false
    end
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

--- @param item_id integer
--- @param inv_id integer
--- @param position integer
--- @return boolean
function is_allowed_in_inventory(item_id, inv_id, position)
    if is_bag(inv_id) then
        return is_allowed_in_bag(item_id, inv_id)
    else
        if is_wand(inv_id) and is_spell(item_id) then
            return true
        end
        local quick_inv = get_player_inventory_quick()
        if is_wand(item_id) and quick_inv and quick_inv == inv_id and position <= 3 then
            return true
        elseif is_item(item_id) and quick_inv and quick_inv == inv_id and position > 3 then
            return true
        end
        local full_inv = get_player_inventory_full()
        if is_spell(item_id) and full_inv and full_inv == inv_id then
            return true
        end
    end
    return false
end

--- @param draw_list table
--- @param item integer
--- @return integer
function find_item_level_in_draw_list(draw_list, item)
    if not draw_list or not item then
        return 0
    end
    local level_item = 0
    for key, value in pairs(draw_list) do
        if value == item then
            level_item = key
        end
    end
    return level_item
end

--- @param draw_list table
--- @param level integer
--- @return table
function remove_draw_list_up_to_level(draw_list, level)
    if not draw_list or not level then
        return {}
    end
    for key, _ in pairs(draw_list) do
        if key >= level then
            draw_list[key] = nil
        end
    end
    return draw_list
end

--- @param draw_list table
--- @param level integer
--- @return table
function remove_draw_list_under_level(draw_list, level)
    if not draw_list or not level then
        return {}
    end
    for key, _ in pairs(draw_list) do
        if key > level then
            draw_list[key] = nil
        end
    end
    return draw_list
end

--- @param entity_id integer
--- @return boolean
function item_pickup_is_pickable_in_inventory(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        local ui_sprite = ComponentGetValue2(item_comp, "ui_sprite")
        return ui_sprite ~= ""
    end
    return false
end

--- @param entity_id integer
--- @param contains_string string
--- @return boolean
function name_contains(entity_id, contains_string)
    if EntityGetName(entity_id) == nil then
        return false
    end
    return string.find(EntityGetName(entity_id), contains_string) ~= nil
end

--- @param bag integer
--- @param maximum integer
--- @return boolean
function is_bag_not_full(bag, maximum)
    local number_of_items = #get_bag_inventory_items(bag, false, false)
    if bag == nil or maximum == nil or number_of_items == nil then
        return false
    end
    return number_of_items < maximum
end

--- @param item integer
--- @param with_movement boolean|nil
--- @param delta_x number|nil
--- @param delta_y number|nil
--- @return nil
function drop_item_from_parent(item, with_movement, delta_x, delta_y)
    if item and type(item) == "number" then
        local active_item = get_active_item()
        if active_item then
            local override_bag = get_bag_pickup_override(active_item)
            if override_bag == item then
                toggle_bag_pickup_override(active_item, 0)
            end
        end
        local root = EntityGetRootEntity(item)
        local x, y, rotation = EntityGetTransform(root)
        if delta_x and delta_y then
            x = x + delta_x
            y = y + delta_y
        end
        remove_bags_of_many_comps(item)
        EntityRemoveFromParent(item)
        if x and y then
            EntityApplyTransform(item, x, y - 5, rotation)
        end
        show_entity(item)
        enable_inherit_comps(item)
        enable_comp_with_tag_in_inventory(item)
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
                    set_entity_touched(item)
                    if velocity_comp then
                        ComponentSetValueVector2(velocity_comp, "mVelocity", aiming_vec_x, aiming_vec_y)
                    end
                end
            end
        end
    end
end

--- @param bag integer
--- @param orderly boolean
--- @param sort_by_time boolean
--- @param sorting_order boolean
--- @return nil
function drop_all_inventory(bag, orderly, sort_by_time, sorting_order)
    local items = get_bag_inventory_items(bag, sort_by_time, sorting_order)
    if orderly then
        local spacing = tonumber(ModSettingGet("BagsOfMany.drop_orderly_distance"))
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

--- @return table|nil
function get_player_inventory_quick_table()
    local vanilla_items = get_player_inventory_quick_items()
    if vanilla_items then
        local vanilla_item_pos = {}
        for i = 1, #vanilla_items do
            local item_slot = get_item_inventory_slot(vanilla_items[i])
            if item_slot then
                if is_item(vanilla_items[i]) then
                    item_slot = item_slot + 4
                end
                vanilla_item_pos[item_slot] = vanilla_items[i]
            end
        end
        return vanilla_item_pos
    end
end

--- @return table|nil, integer|nil
function get_player_inventory_wand_table()
    local vanilla_items = get_player_inventory_quick_items()
    if vanilla_items then
        local vanilla_item_pos = {}
        local nmb_wands = 0
        for i = 1, #vanilla_items do
            if is_wand(vanilla_items[i]) then
                local pos_x = get_item_inventory_slot(vanilla_items[i])
                if pos_x then
                    nmb_wands = nmb_wands + 1
                    vanilla_item_pos[pos_x] = vanilla_items[i]
                end
            end
        end
        return vanilla_item_pos, nmb_wands
    end
end

--- @return table|nil
function get_player_inventory_full_table()
    local vanilla_spells = get_player_inventory_full_items()
    if vanilla_spells then
        local vanilla_spell_table = {}
        for i = 1, #vanilla_spells do
            local x = get_inventory_spell_size()
            local pos_x, pos_y = get_item_inventory_slot(vanilla_spells[i])
            if pos_x and pos_y then
                vanilla_spell_table[pos_x+(pos_y*x)] = vanilla_spells[i]
            end
        end
        return vanilla_spell_table
    end
    return {}
end

--- @param wand integer
--- @return table
function get_wand_spells_table(wand)
    if not is_wand(wand) then
        return {}
    end
    local spells = EntityGetAllChildren(wand)
    if spells then
        local spells_table = {}
        for i = 1, #spells do

            local pos_x, pos_y = get_item_inventory_slot(spells[i])
            if pos_x and pos_y then
                spells_table[pos_x] = spells[i]
            end
        end
        return spells_table
    end
    return {}
end

--- @param wand integer
--- @return table
function get_wand_spells_table_no_always_cast(wand)
    if not is_wand(wand) then
        return {}
    end
    local spells = EntityGetAllChildren(wand)
    if spells then
        local spells_table = {}
        for i = 1, #spells do
            local pos_x = get_item_inventory_slot(spells[i])
            if pos_x and not is_spell_permanently_attached(spells[i]) then
                spells_table[pos_x] = spells[i]
            end
        end
        return spells_table
    end
    return {}
end

--- @return integer|nil
function get_player_inventory_quick()
    local player = EntityGetWithTag("player_unit")
    if player == nil or #player == 0 then
        return nil
    end
    local children = EntityGetAllChildren(player[1])
    if children then
        for _, child in ipairs(children) do
            if EntityGetName(child) == "inventory_quick" then
                return child
            end
        end
    end
    
end

--- @return table|nil
function get_player_inventory_quick_items()
    local player = EntityGetWithTag("player_unit")
    if player == nil or #player == 0 then
        return nil
    end
    local children = EntityGetAllChildren(player[1])
    if children then
        for _, child in ipairs(children) do
            if EntityGetName(child) == "inventory_quick" then
                return EntityGetAllChildren(child)
            end
        end
    end
end

--- @return integer|nil
function get_player_inventory_full()
    local player = EntityGetWithTag("player_unit")
    if player == nil or #player == 0 then
        return nil
    end
    local children = EntityGetAllChildren(player[1])
    if children then
        for _, child in ipairs(children) do
            if EntityGetName(child) == "inventory_full" then
                return child
            end
        end
    end
end

--- @return table|nil
function get_player_inventory_full_items()
    local player = EntityGetWithTag("player_unit")
    if player == nil or #player == 0 then
        return nil
    end
    local children = EntityGetAllChildren(player[1])
    if children then
        for _, child in ipairs(children) do
            if EntityGetName(child) == "inventory_full" then
                return EntityGetAllChildren(child)
            end
        end
    end
end

--- @param entity_id integer
--- @return integer|nil, integer|nil
function get_item_inventory_slot(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
    if item_comp then
        local inv_x, inv_y = ComponentGetValue2(item_comp, "inventory_slot")
        return inv_x, inv_y
    end
end

--- @param entity integer
--- @return integer
function get_item_pickup_frame(entity)
    local var_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    for _, var_storage in ipairs(var_storages or {}) do
        if ComponentGetValue2(var_storage, "name") == "item_pickup_frame" then
            return ComponentGetValue2(var_storage, "value_int")
        end
    end
    return 0
end

--- @param bag integer
--- @return integer|nil
function get_bag_pickup_override(bag)
    local bag_pickup_override_storage = get_var_storage_with_name(bag, "bags_of_many_bag_pickup_override")
    if bag_pickup_override_storage then
        local bag_pickup_override = ComponentGetValue2(bag_pickup_override_storage, "value_int")
        if bag_pickup_override == 0 then
            return nil
        end
        return bag_pickup_override
    end
    return nil
end

--- @param spell integer
--- @return integer|nil
function get_spell_remaining_uses(spell)
    if spell then
        local item_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemComponent")
        if item_comp then
            local uses_remaining = ComponentGetValue2(item_comp, "uses_remaining")
            return uses_remaining
        end
    end
end

--- @param main_bag integer
--- @param secondary_bag integer
--- @return nil
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

--- @param entity integer
--- @return nil
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

--- @param entity integer
--- @return nil
function remove_component_pickup_frame(entity)
    local var_storages = EntityGetComponentIncludingDisabled(entity, "VariableStorageComponent")
    for _, var_storage in ipairs(var_storages or {}) do
        if ComponentGetValue2(var_storage, "name") == "item_pickup_frame" then
            EntityRemoveComponent(entity, var_storage)
        end
    end
end

--- @param entity integer
--- @param position integer
--- @return nil
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

--- @param entity integer
--- @return nil
function remove_item_position(entity)
    local var_storage = get_var_storage_with_name(entity, "bags_of_many_item_position")
    if var_storage then
        EntityRemoveComponent(entity, var_storage)
    end
end

--- @param entity integer
--- @return nil
function add_inherit_comp(entity)
    if EntityGetFirstComponentIncludingDisabled(entity, "InheritTransformComponent") then
        return
    end
    local inherit_comp = EntityGetFirstComponentIncludingDisabled(entity, "InheritTransformComponent", "coop_respawn")
    if not inherit_comp then
        local comp_table_val
        if is_spell(entity) then
            comp_table_val = {only_position = true}
        end
        inherit_comp = EntityAddComponent2(entity, "InheritTransformComponent", comp_table_val)
        ComponentAddTag(inherit_comp, "coop_respawn")
    end
    return inherit_comp
end

--- @param entity integer
--- @return nil
function remove_inherit_comp(entity)
    local inherit_comps = EntityGetComponentIncludingDisabled(entity, "InheritTransformComponent", "coop_respawn")
    for _, inherit_comp in ipairs(inherit_comps or {}) do
        EntityRemoveComponent(entity, inherit_comp)
    end
end

--- @param entity integer
--- @return nil
function disable_inherit_comps(entity)
    local inherit_comps = EntityGetComponentIncludingDisabled(entity, "InheritTransformComponent")
    for _, inherit_comp in ipairs(inherit_comps or {}) do
        EntitySetComponentIsEnabled(entity, inherit_comp, false)
    end
end

--- @param entity integer
--- @param position integer
--- @return nil
function add_bags_of_many_comps(entity, position)
    add_inherit_comp(entity)
    add_item_position(entity, position)
    add_component_pickup_frame(entity)
end

--- @param entity integer
--- @return nil
function remove_bags_of_many_comps(entity)
    remove_inherit_comp(entity)
    remove_item_position(entity)
    remove_component_pickup_frame(entity)
end

--- @param item integer
--- @param position integer
--- @param bag integer
--- @return nil
function swap_item_to_position(item, position, bag)
    -- Prevent bag being placed inside themselves (will cause CRASH)
    if item == bag then
        return
    end

    -- Make sure item is allowed in this bag type
    if not is_allowed_in_bag(item, bag) then
        return
    end

    add_inherit_comp(item)

    local var_storage_one = get_var_storage_with_name(item, "bags_of_many_item_position")
    if not var_storage_one then
        var_storage_one = add_var_storage_with_name(item, "bags_of_many_item_position")
    end
    if var_storage_one then
        local bag_inventory = get_inventory(bag)
        local item_inventory = EntityGetParent(item)
        if bag_inventory ~= item_inventory then
            add_entity_to_inventory(item, bag_inventory)
        end
        ComponentSetValue2(var_storage_one, "value_int", position)
        hide_entity(item)
    end
end

--- @param dragged_item integer
--- @param hovered_item integer
--- @param bag_one integer
--- @param bag_two integer
--- @return nil
function swap_item_position(dragged_item, hovered_item, bag_one, bag_two)
    if dragged_item and hovered_item then
        -- In case for some reason the item is not in a bag ?
        if (not bag_one or not bag_two) then
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
            swap_items_btw_inventories(dragged_item, hovered_item, bag_one, bag_two)
        end
    end
end

--- @param item integer
--- @param bag integer
--- @return nil
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
            add_entity_to_inventory_bag(get_smallest_position_avalaible(bag), bag_inventory, item)
        end
    end
end

--- @param dragged_item integer
--- @param hovered_item integer
--- @param bag_one integer
--- @param bag_two integer
--- @return nil
function swap_items_btw_bags(dragged_item, hovered_item, bag_one, bag_two)
    -- Different bags switching two items
    local var_storage_one = get_var_storage_with_name(dragged_item, "bags_of_many_item_position")
    local var_storage_two = get_var_storage_with_name(hovered_item, "bags_of_many_item_position")
    if var_storage_one and var_storage_two then
        local position_one = ComponentGetValue2(var_storage_one, "value_int")
        local position_two = ComponentGetValue2(var_storage_two, "value_int")
        -- Make sure item can be switched from one bag to the other
        if not is_allowed_in_inventory(dragged_item, bag_two, position_two) or not is_allowed_in_inventory(hovered_item, bag_one, position_one) then
            return
        end
        local inventory_one = EntityGetParent(dragged_item)
        local inventory_two = EntityGetParent(hovered_item)
        ComponentSetValue2(var_storage_one, "value_int", position_two)
        ComponentSetValue2(var_storage_two, "value_int", position_one)
        add_entity_to_inventory(hovered_item, inventory_one)
        add_entity_to_inventory(dragged_item, inventory_two)
    end
end

--- @param dragged_item integer
--- @param hovered_item integer
--- @param entity_one integer
--- @param entity_two integer
--- @return nil
function swap_items_btw_inventories(dragged_item, hovered_item, entity_one, entity_two)
    local var_storage_one = get_var_storage_with_name(dragged_item, "bags_of_many_item_position")
    local var_storage_two = get_var_storage_with_name(hovered_item, "bags_of_many_item_position")
    local position_one
    local position_two
    local inv_entity_one = entity_one
    local inv_entity_two = entity_two
    if is_bag(entity_one) then
        if var_storage_one then
            position_one = ComponentGetValue2(var_storage_one, "value_int")
            inv_entity_one = get_inventory(entity_one)
        end
    else
        position_one = get_item_inventory_slot(dragged_item)
    end
    if is_bag(entity_two) then
        if var_storage_two then
            position_two = ComponentGetValue2(var_storage_two, "value_int")
            inv_entity_two = get_inventory(entity_two)
        end
    else
        position_two = get_item_inventory_slot(hovered_item)
    end
    -- Make sure item can be switched from one bag to the other
    if not is_allowed_in_inventory(dragged_item, entity_two, position_two) or not is_allowed_in_inventory(hovered_item, entity_one, position_one) then
        return
    end
    if var_storage_one then
        add_item_position(hovered_item, position_one)
    else
        set_entity_inventory_position(hovered_item, position_one)
        remove_item_position(hovered_item)
    end
    if var_storage_two then
        add_item_position(dragged_item, position_two)
    else
        set_entity_inventory_position(dragged_item, position_two)
        remove_item_position(dragged_item)
    end
    add_entity_to_inventory(hovered_item, inv_entity_one)
    hide_entity(hovered_item)
    add_entity_to_inventory(dragged_item, inv_entity_two)
    hide_entity(dragged_item)
end

--- @param bag integer
--- @param entity integer
--- @return nil
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

--- @param bag integer
--- @param item integer
--- @return nil
function add_item_shift_click(bag, item)
    local inv_size = get_bag_inventory_size(bag)
    if bag and item and bag ~= item and inv_size and is_allowed_in_bag(item, bag) then
        local inv = get_inventory(bag)
        if is_bag_not_full(bag, inv_size) and inv then
            add_entity_to_inventory_bag(get_smallest_position_avalaible(bag), inv, item)
        end
    end
end

--- @param inventory integer
--- @param path string
--- @return integer|nil
function add_item_to_inventory(inventory, path)
    local item = EntityLoad(path)
    if item then
        GamePickUpInventoryItem(inventory, item)
    else
        GamePrint("Error: Couldn't load the item ["..path.."]!")
    end
    return item
end

--- @param wand integer
--- @param spell integer
--- @param position integer
--- @return nil
function add_item_to_inventory_wand_vanilla(wand, spell, position)
    if wand and spell and position then
        local can_be_added_at_pos = false
        if is_wand(wand) and is_spell(spell) then
            can_be_added_at_pos = true
        end
        local wands_spells = get_wand_spells_table_no_always_cast(wand)
        local item_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemComponent")
        if can_be_added_at_pos and item_comp then
            local wand_spell = wands_spells[position]
            -- Do not move always cast spells if ever trying to swap with them 
            if wand_spell and not is_spell_permanently_attached(wand_spell) then
                -- vanilla item change
                local item_pos = get_item_position(spell)
                local item_bag_inventory = EntityGetParent(spell)
                add_bags_of_many_comps(wand_spell, item_pos)
                add_entity_to_inventory(wand_spell, item_bag_inventory)
            end
            -- bag item
            add_entity_to_vanilla_inventory(spell, wand, position, 0)
        end
    end
end

--- @param item integer
--- @param position integer
--- @return nil
function add_item_to_inventory_quick_vanilla(item, position)
    if item and type(item) == "number" and position then
        local can_be_added_at_pos = true
        if is_item(item) and position <= 3 then
            can_be_added_at_pos = false
        elseif is_wand(item) and position >= 4 then
            can_be_added_at_pos = false
        end
        local player_inv_quick_table = get_player_inventory_quick_table()
        local player_inv_quick = get_player_inventory_quick()
        local item_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
        local player_inv_quick_size = get_inventory_quick_size()
        if can_be_added_at_pos and player_inv_quick_table and player_inv_quick and item_comp and #player_inv_quick_table <= player_inv_quick_size then
            hide_entity(item)
            if not player_inv_quick_table[position] then
                if is_item(item) then
                    position = position - 4
                end
                add_entity_to_vanilla_inventory(item, player_inv_quick, position, 0)
            end
        end
    end
end

--- @param item integer
--- @param pos_x integer
--- @param pos_y integer
--- @return nil
function add_item_to_inventory_full_vanilla(item, pos_x, pos_y)
    if item and type(item) == "number" and pos_x and pos_y then
        local can_be_added_at_pos = true
        if not is_spell(item) then
            can_be_added_at_pos = false
        end
        local player_inv_full_table = get_player_inventory_full_table()
        local player_inv_full = get_player_inventory_full()
        local item_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
        local inv_full_size_x, inv_full_size_y = get_inventory_spell_size()
        if can_be_added_at_pos and player_inv_full_table and player_inv_full and item_comp and #player_inv_full_table <= (inv_full_size_x*inv_full_size_y) then
            hide_entity(item)
            local vanilla_item = player_inv_full_table[pos_x*(pos_y+1)]
            if vanilla_item then
                -- vanilla item change
                local item_pos = get_item_position(item)
                local item_bag_inventory = EntityGetParent(item)
                add_entity_to_inventory_bag(item_pos, item_bag_inventory, vanilla_item)
            end
            -- bag item
            add_entity_to_vanilla_inventory(item, player_inv_full, pos_x, pos_y)
        end
    end
end

--- @param position integer
--- @param inventory integer
--- @param entity integer
--- @return nil
function add_entity_to_inventory_bag(position, inventory, entity)
    hide_entity(entity)
    add_bags_of_many_comps(entity, position)
    add_entity_to_inventory(entity, inventory)
end

--- @param entity integer
--- @param inventory integer
--- @param pos_x integer
--- @param pos_y integer
--- @return nil
function add_entity_to_vanilla_inventory(entity, inventory, pos_x, pos_y)
    hide_entity(entity)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
    if not item_comp then
        return
    end
    add_entity_to_inventory(entity, inventory)
    remove_bags_of_many_comps(entity)
    set_entity_touched(entity)
    set_entity_inventory_position(entity, pos_x, pos_y)
end

--- @param entity integer
--- @param inventory integer
--- @return nil
function add_entity_to_inventory(entity, inventory)
    EntityRemoveFromParent(entity)
    EntityAddChild(inventory, entity)
end

--- @param entity integer
--- @return nil
function remove_entity_from_inventory(entity)
    remove_bags_of_many_comps(entity)
end

--- @param entity integer
--- @return nil
function set_entity_touched(entity)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
    if item_comp then
        ComponentSetValue2(item_comp, "play_hover_animation", false)
        ComponentSetValue2(item_comp, "has_been_picked_by_player", true)
    end
end

--- @param entity integer
--- @param pos_x integer
--- @param pos_y integer
--- @return nil
function set_entity_inventory_position(entity, pos_x, pos_y)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity, "ItemComponent")
    if item_comp and pos_x and pos_y then
        ComponentSetValue2(item_comp, "inventory_slot", pos_x, pos_y)
    end
end

--- @param active_item integer
--- @param inventory integer
--- @param player_id integer
--- @param entities table
--- @return nil
function add_spells_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if EntityGetParent(entity) == 0 then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                if not ModSettingGet("BagsOfMany.allow_holy_mountain_spell_stealing") then
                    if not is_shop_item(entity) then
                        add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
                    end
                else
                    add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
                end
            end
        end
    end
end

--- @param active_item integer
--- @param inventory integer
--- @param player_id integer
--- @param entities table
--- @return nil
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
                add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
            end
        end
    end
end

--- @param active_item integer
--- @param inventory integer
--- @param player_id integer
--- @param entities table
--- @return nil
function add_potions_to_inventory(active_item, inventory, player_id, entities)
    for _, entity in ipairs(entities) do
        if EntityGetParent(entity) == 0 then
            if is_bag_not_full(active_item, get_bag_inventory_size(active_item)) then
                add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
            end
        end
    end
end

--- @param active_item integer
--- @param inventory integer
--- @param player_id integer
--- @param entities table
--- @return nil
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
                    add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
                end
            end
        end
    end
end

--- @param active_item integer
--- @param inventory integer
--- @param player_id integer
--- @param entities table
--- @return nil
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
            add_entity_to_inventory_bag(get_smallest_position_avalaible(active_item), inventory, entity)
        end
    end
end

--- @param entity integer
--- @return integer
function EntityTinkerPoints(entity)
    local tinker_points = 0
    local queue = EntityGetAllChildren(entity) or {}
    local last = #queue + 1
    local current = 1
    while current <= last do
        local check_entity = queue[current]
        local comps = EntityGetComponent(check_entity, "GameEffectComponent") or {}
        for i = 1, #comps do
            local effect = ComponentGetValue2(comps[i], "effect")
            tinker_points = tinker_points + (effect == "EDIT_WANDS_EVERYWHERE" and 1 or 0)
            tinker_points = tinker_points - (effect == "NO_WAND_EDITING" and 1 or 0)
        end
        local children = EntityGetAllChildren(check_entity) or {}
        local new = #children
        for i = 1, new do
            queue[i + last] = children[i]
        end
        last = last + new
        current = current + 1
    end
    return tinker_points
end

--- @param entity integer
--- @return boolean
function CheckEntityCollideWithWorkshop(entity)
    local colliding_with_workshop_entity = false
    local entity_hitbox = EntityGetFirstComponent(entity, "HitboxComponent")
    if entity_hitbox then
        local x, y = EntityGetTransform(entity)
        local entity_min_x = ComponentGetValue2(entity_hitbox, "aabb_min_x") + x
        local entity_max_x = ComponentGetValue2(entity_hitbox, "aabb_max_x") + x
        local entity_min_y = ComponentGetValue2(entity_hitbox, "aabb_min_y") + y
        local entity_max_y = ComponentGetValue2(entity_hitbox, "aabb_max_y") + y
        local workshop_entities = EntityGetWithTag("workshop")
        for _, workshop_entity in ipairs(workshop_entities) do
            local workshop_hitbox = EntityGetFirstComponent(workshop_entity, "HitboxComponent")
            if workshop_hitbox then
                local pos_workshop_x, pos_workshop_y = EntityGetTransform(workshop_entity)
                local min_x = ComponentGetValue2(workshop_hitbox, "aabb_min_x") + pos_workshop_x
                local max_x = ComponentGetValue2(workshop_hitbox, "aabb_max_x") + pos_workshop_x
                local min_y = ComponentGetValue2(workshop_hitbox, "aabb_min_y") + pos_workshop_y
                local max_y = ComponentGetValue2(workshop_hitbox, "aabb_max_y") + pos_workshop_y
                local x_colliding = (entity_min_x > min_x and entity_min_x < max_x) or (entity_max_x > min_x and entity_max_x < max_x)
                local y_colliding = (entity_min_y > min_y and entity_min_y < max_y) or (entity_max_y > min_y and entity_max_y < max_y)
                colliding_with_workshop_entity = x_colliding and y_colliding
                if colliding_with_workshop_entity then
                    return colliding_with_workshop_entity
                end
            end
        end
    end
    return colliding_with_workshop_entity
end

--- @param item integer
--- @return integer|nil, integer|nil
function get_smallest_vanilla_pos_for_item(item)
    if is_spell(item) then
        local full_table = get_player_inventory_full_table()
        local size_x, size_y = get_inventory_spell_size()
        if full_table and size_x and size_y then
            for i = 0, (size_x * size_y), 1 do
                if not full_table[i] then
                    return (i%size_x), math.floor((i)/size_x)
                end
            end
        end
    elseif is_wand(item) then
        local quick_table = get_player_inventory_quick_table()
        if quick_table then
            for i = 0, 3, 1 do
                if not quick_table[i] then
                    return i, 0
                end
            end
        end
    elseif is_item(item) then
        local quick_table = get_player_inventory_quick_table()
        if quick_table then
            for i = 4, 7, 1 do
                if not quick_table[i] then
                    return i, 0
                end
            end
        end
    end
    return nil, nil
end

--- @return integer|nil
function get_active_item()
    local player = EntityGetWithTag("player_unit")[1]
    if player then
        local activeItem = ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component"), "mActualActiveItem")
        return activeItem > 0 and activeItem or nil
    end
end

--- @return nil
function get_active_bag()
    local active_item = get_active_item()
    bag_pickup_override_local = get_bag_pickup_override(active_item)
end

--- @return integer|nil
function get_inventory_two_component()
    local player = get_player()
    if player then
        local inventory_comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
        return inventory_comp
    end
end

--- @return integer|nil, integer|nil
function get_inventory_spell_size()
    local inv_comp = get_inventory_two_component()
    if inv_comp then
        local x = ComponentGetValue2(inv_comp, "full_inventory_slots_x")
        local y = ComponentGetValue2(inv_comp, "full_inventory_slots_y")
        return x, y
    end
end

--- @return integer|nil
function get_inventory_quick_size()
    local inv_comp = get_inventory_two_component()
    if inv_comp then
        local x = ComponentGetValue2(inv_comp, "quick_inventory_slots")
        return x
    end
end

--- @param entity_id integer
--- @return integer|nil
function get_inventory(entity_id)
    for _, child in ipairs(EntityGetAllChildren(entity_id) or {}) do
        if EntityGetName(child) == "inventory_full" then
            return child
        end
    end
end

--- @param entity_id integer
--- @param sort boolean
--- @param order_asc boolean
--- @return table
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

--- @param item integer
--- @return integer|nil
function get_inventory_bag_owner(item)
    local inventory = EntityGetParent(item)
    return EntityGetParent(inventory)
end

--- @param entity_id integer
--- @return table
function get_bag_items(entity_id)
    local inventory = get_inventory(entity_id)
    local items = EntityGetAllChildren(inventory)
    if items then
        return items
    else
        return {}
    end
end

--- @param entity_id integer
--- @return integer
function get_item_position(entity_id)
    local var_storage = get_var_storage_with_name(entity_id, "bags_of_many_item_position")
    if var_storage then
        return ComponentGetValue2(var_storage, "value_int")
    end
    return 0
end

--- @param bag integer
--- @return integer
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

--- @param entity_id integer
--- @return integer
function get_bag_inventory_size(entity_id)
    if entity_id then
        local bag_name = EntityGetName(entity_id)
        if bag_name then
            local size = tonumber(ModSettingGet("BagsOfMany.".. bag_name .. "_size"))
            if not size then
                size = 0
            else
                return math.floor(size)
            end
        end
    end
    return 0
end

--- @param entity_id integer
--- @return string
function get_sprite_file( entity_id )
    local sprite = "mods/bags_of_many/files/ui_gfx/inventory/unidentified_item.png"
    if not entity_id then
        return sprite
    end
    -- Sprite for the spells and wands
    if EntityHasTag(entity_id, "card_action") or is_wand(entity_id) then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if item_component then
            local wand_sprite = ComponentGetValue2(item_component[1], "image_file")
            if string_contains(wand_sprite, ".xml") then
                local png_file = extract_png_file_from_xml(wand_sprite)
                if png_file then
                    sprite = png_file
                end
            elseif wand_sprite and wand_sprite ~= "" then
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

--- @param entity_id integer
--- @return nil
function hide_entity( entity_id )
    local components = EntityGetAllComponents(entity_id)
    local children = EntityGetAllChildren(entity_id)
    for _, child in ipairs(children or {}) do
        hide_entity(child)
    end
    for _, component in ipairs(components or {}) do
        if not ComponentHasTag(component, "enabled_in_inventory") then
            EntitySetComponentIsEnabled(entity_id, component, false)
        end
    end
end

--- @param entity_id integer
--- @return nil
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

--- @param entity integer
--- @return nil
function show_in_hand_effect(entity)
    local items = get_bag_items(entity)
    for _, item in ipairs(items) do
        if is_bag(item) then
            show_in_hand_effect(item)
        else
            local comps = EntityGetAllComponents(item)
            for _, comp in ipairs(comps) do
                if ComponentHasTag(comp, "enabled_in_hand") and ComponentGetTypeName(comp) ~= "SpriteComponent" then
                    EntitySetComponentIsEnabled(item, comp, true)
                end
            end
        end
    end
end

--- @param pos_x number
--- @param pos_y number
--- @param init_x number
--- @param init_y number
--- @param limit_x number
--- @param limit_y number
--- @return boolean
function moved_far_enough(pos_x, pos_y, init_x, init_y, limit_x, limit_y)
    if not pos_x or not pos_y or not init_x or not init_y then
        return true
    end
    local moved_enough = false
    local delta_x = pos_x - init_x
    local delta_y = pos_y - init_y
    if delta_x > limit_x or delta_y > limit_y or delta_x < 0 or delta_y < 0 then
        moved_enough = true
    end
    return moved_enough
end

--- @param inventory table
--- @param order_asc boolean
--- @return nil
function sort_entity_by_pickup_frame(inventory, order_asc)
    insertion_sort_entityId(inventory)
    insertion_sort_frame(inventory)
    if not order_asc then
        inventory = revert_table(inventory)
    end
end

--- @param inventory table
--- @return nil
function sort_entity_by_position(inventory)
    insertion_sort_position(inventory)
end

--- @param array table
--- @return table
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

--- @param array table
--- @return table
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

--- @param array table
--- @return table
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

--- @param x table
--- @return table
function revert_table(x)
    local n, m = #x, #x/2
    for i=1, m do
      x[i], x[n-i+1] = x[n-i+1], x[i]
    end
    return x
end