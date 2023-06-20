dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )

function enabled_changed( entity_id, is_enabled )
    if is_enabled then
        local player = get_player_entity()
        local x, y = get_player_pos()
        local items = EntityGetInRadiusWithTag(x, y, 100, "item_pickup")
        for index, item in ipairs(items) do
            if item then
                local item_has_interaction = EntityGetComponentIncludingDisabled(item, "InteractableComponent") ~= nil
                if EntityGetRootEntity(item) ~= player and not item_has_interaction then
                    local item_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
                    if item_comp then
                        ComponentSetValue2(item_comp, "is_pickable", false)
                    end
                    local name_entity = EntityGetName(item)
                    EntityAddComponent2(item, "InteractableComponent", {
                        _enabled = true,
                        _tags = "enabled_in_world",
                        radius = 10,
                        ui_text = "Press $0 to pick '".. GameTextGet("$"..name_entity) .. "'!",
                        name = "test"
                    })
                    EntityAddComponent2(item, "LuaComponent", {
                        _enabled = true,
                        _tags = "",
                        script_source_file = "mods/bags_of_many/files/scripts/testing/picker.lua",
                        script_interacting = "mods/bags_of_many/files/scripts/testing/picker.lua",
                        script_item_picked_up = "mods/bags_of_many/files/scripts/testing/picker.lua",
                        execute_every_n_frame = 1,
                        execute_on_added = false
                    })
                end
            end
        end
    end
end