--- @param entity_id integer
--- @return table|nil
function get_biggest_potion_content( entity_id )
    local biggest_potion_content = nil
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if suc_component ~= nil and inv_component ~= nil then
        local capacity = ComponentGetValue2(suc_component, "barrel_size")
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        for i = 1, #counts do
            if counts[i] > 0 then
                local material = {
                    id = i - 1,
                    name = CellFactory_GetUIName(i - 1),
                    amount = (counts[i]/capacity) * (100),
                }
                if biggest_potion_content == nil then
                    biggest_potion_content = material
                elseif biggest_potion_content.amount < material.amount then
                    biggest_potion_content = material
                end
            end
        end
        return biggest_potion_content
    end
end

--- @param entity_id integer
--- @return table
function get_potion_contents( entity_id )
    local materials = {}
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if suc_component ~= nil and inv_component ~= nil then
        local capacity = ComponentGetValue2(suc_component, "barrel_size")
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        for i = 1, #counts do
            if counts[i] > 0 then
                local material = {
                    id = i - 1,
                    name = CellFactory_GetUIName(i - 1),
                    amount = (counts[i]/capacity) * (100),
                }
                table.insert(materials, material)
            end
        end
    end
    for i = 1, #materials do
        for j = i + 1, #materials do
            if materials[i].amount < materials[j].amount then
                local temp_mat = materials[i]
                materials[i] = materials[j]
                materials[j] = temp_mat
            end
        end
    end
    return materials
end

--- @param entity_id integer
--- @return table
function get_potion_materials(entity_id)
    local material_list = {}
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if inv_component ~= nil then
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        for material_id, amount in pairs(counts) do
            if amount > 0 then
                local material_name = CellFactory_GetUIName(material_id - 1)
                table.insert(material_list, material_name)
            end
        end
    end
    return material_list
end

--- @param entity_id integer
--- @return number
function get_potion_avalaible_space(entity_id)
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    local total_material_count = 0
    if suc_component ~= nil and inv_component ~= nil then
        local capacity = ComponentGetValue2(suc_component, "barrel_size")
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        for i = 1, #counts do
            if counts[i] > 0 then
                total_material_count = total_material_count + counts[i]
            end
        end
        return capacity - total_material_count
    end
    return 0
end

--- @param entity_id integer
--- @return number|nil
function get_potion_size(entity_id)
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    if suc_component ~= nil then
        return ComponentGetValue2(suc_component, "barrel_size")
    end
end

--- @param entity_id integer
--- @return number|nil
function get_potion_fill_percent(entity_id)
    local potion_size = get_potion_size(entity_id)
    local potion_space_left = get_potion_avalaible_space(entity_id)
    if potion_size and potion_space_left then
        return (potion_size - potion_space_left)/potion_size
    end
end

--- @param potion_from integer
--- @param potion_to integer
--- @param material_id integer
--- @param amount_transfered number
--- @return nil
function transfer_potion_specific_content(potion_from, potion_to, material_id, amount_transfered)
    local suc_component_one = EntityGetFirstComponentIncludingDisabled(potion_from, "MaterialSuckerComponent")
    local inv_component_one = EntityGetFirstComponentIncludingDisabled(potion_from, "MaterialInventoryComponent")
    local suc_component_two = EntityGetFirstComponentIncludingDisabled(potion_to, "MaterialSuckerComponent")
    local inv_component_two = EntityGetFirstComponentIncludingDisabled(potion_to, "MaterialInventoryComponent")
    if material_id and suc_component_one ~= nil and inv_component_one ~= nil and suc_component_two ~= nil and inv_component_two ~= nil then
        -- local capacity_from = ComponentGetValue2(suc_component_one, "barrel_size")
        local counts_from = ComponentGetValue2(inv_component_one, "count_per_material_type")
        -- local capacity_to = ComponentGetValue2(suc_component_two, "barrel_size")
        local counts_to = ComponentGetValue2(inv_component_two, "count_per_material_type")
        local potion_to_space_left = get_potion_avalaible_space(potion_to)
        local mat_amount_from = counts_from[material_id+1]
        local mat_amount_to = counts_to[material_id+1]
        if amount_transfered > mat_amount_from then
            amount_transfered = mat_amount_from
        end
        if amount_transfered > potion_to_space_left then
            amount_transfered = potion_to_space_left
        end
        local material_name = CellFactory_GetName(material_id)
        AddMaterialInventoryMaterial(potion_to, material_name, mat_amount_to + amount_transfered)
        AddMaterialInventoryMaterial(potion_from, material_name,  mat_amount_from - amount_transfered)
    end
end

--- @param entity_id integer
--- @return nil
function delete_potion_contents(entity_id)
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    if inv_component ~= nil then
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        for i = 1, #counts do
            if counts[i] > 0 then
                local mat_name = CellFactory_GetName(i - 1)
                AddMaterialInventoryMaterial(entity_id, mat_name, 0)
            end
        end
    end
end

--- @param entity_id integer
--- @param material_id integer
--- @return nil
function delete_potion_specific_content(entity_id, material_id)
    local mat_name = CellFactory_GetName(material_id)
    AddMaterialInventoryMaterial(entity_id, mat_name, 0)
end

--- @param entity_id integer
--- @param material_id integer
--- @param amount_deleted number
--- @return number
function delete_potion_specific_content_quantity(entity_id, material_id, amount_deleted)
    local suc_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialSuckerComponent")
    local inv_component = EntityGetFirstComponentIncludingDisabled(entity_id, "MaterialInventoryComponent")
    local material_count
    if suc_component ~= nil and inv_component ~= nil then
        local counts = ComponentGetValue2(inv_component, "count_per_material_type")
        if counts then
            material_count = counts[material_id+1]
        end
    end
    if material_count then
        if amount_deleted > material_count then
            amount_deleted = material_count
        end
        local mat_name = CellFactory_GetName(material_id)
        AddMaterialInventoryMaterial(entity_id, mat_name, material_count - amount_deleted)
        return material_count - amount_deleted
    end
    return 0
end

--- @param potion integer
--- @param material_id integer
--- @param amount number
--- @return nil
function reduce_potion_to_amount(potion, material_id, amount)
    local mat_name = CellFactory_GetName(material_id)
    AddMaterialInventoryMaterial(potion, mat_name, amount)
end

--- @param potion integer
--- @param player integer
--- @return nil
function ingest_potion_material(potion, player)
    local material = get_biggest_potion_content(potion)
    if material and material.id then
        local name = CellFactory_GetName(material.id)
        if name then
            local type = CellFactory_GetType(name)
            if type then
                local amount_consumed = 100
                if material.amount * 10 < 100 then
                    amount_consumed = material.amount * 10
                end
                EntityIngestMaterial(player, type, amount_consumed)
                local mat_name = CellFactory_GetName(material.id)
                AddMaterialInventoryMaterial(potion, mat_name, material.amount * 10 - amount_consumed)
            end
        end
    end
end

--- @param gui userdata
--- @param entity integer
--- @return nil
function add_potion_color(gui, entity)
    local potion_color = GameGetPotionColorUint(entity)
    if potion_color ~= 0 then
        local b = bit.rshift(bit.band(potion_color, 0xFF0000), 16) / 0xFF
        local g = bit.rshift(bit.band(potion_color, 0xFF00), 8) / 0xFF
        local r = bit.band(potion_color, 0xFF) / 0xFF
        GuiColorSetForNextWidget(gui, r, g, b, 1)
    end
end