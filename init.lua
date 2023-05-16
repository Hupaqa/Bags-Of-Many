dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
print("Bags of many enabled start a new run to have the items spawn in your world.")

button_pos_x = ModSettingGet("BagsOfMany.pos_x")
button_pos_y = ModSettingGet("BagsOfMany.pos_y")
button_locked = ModSettingGet("BagsOfMany.locked")
show_bag_content = ModSettingGet("BagsOfMany.show_bag_content")
bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255

-- Adding translations
local TRANSLATIONS_FILE = "data/translations/common.csv"
local translations = ModTextFileGetContent(TRANSLATIONS_FILE) .. ModTextFileGetContent("mods/bags_of_many/translations/common.csv")
ModTextFileSetContent(TRANSLATIONS_FILE, translations)

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_small.xml")
    add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_medium.xml")
    add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_big.xml")
end

function OnWorldPreUpdate()
    setup_gui()
end

function OnPausedChanged(is_paused, is_inventory_pause)
    button_locked = ModSettingGet("BagsOfMany.locked")
	if not button_locked then
        print(button_pos_x)
        print(button_pos_y)
		ModSettingSetNextValue("BagsOfMany.pos_x", button_pos_x, false)
		ModSettingSetNextValue("BagsOfMany.pos_y", button_pos_y, false)
    else
        button_pos_x = ModSettingGet("BagsOfMany.pos_x")
        button_pos_y = ModSettingGet("BagsOfMany.pos_y")
	end
	show_bag_content = ModSettingGet("BagsOfMany.show_bag_content")
    bag_wrap_number = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")
    bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
    bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
    bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
    bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
end

function split_string(inputstr, sep)
    sep = sep or "%s"
    local t= {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

-- GUI
function setup_gui()
    gui = gui or GuiCreate()
    open = open or false
    
    current_id = 1
    local function new_id()
        current_id = current_id + 1
        return current_id
    end

    GuiStartFrame(gui)
    GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)

    -- Setup the inventory button
    local inventory_open = is_inventory_open()
    if inventory_open and not button_locked then
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiImageButton(gui, 4192922, button_pos_x, button_pos_y, "", "mods/bags_of_many/files/ui_gfx/gui_button_invisible.png")
        local _, _, hovered, x, y, draw_width, draw_height, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
        if draw_x ~= 0 and draw_y ~= 0 and draw_x ~= button_pos_x and draw_y ~= button_pos_y then
			button_pos_x = draw_x - draw_width / 2
			button_pos_y = draw_y - draw_height / 2
            ModSettingSet("BagsOfMany.pos_x", button_pos_x)
		    ModSettingSet("BagsOfMany.pos_y", button_pos_y)
		end
    end
    if inventory_open and GuiImageButton(gui, new_id(), button_pos_x, button_pos_y, "", "mods/bags_of_many/files/ui_gfx/bag_universal_small.png") then
		open = not open
		GlobalsSetValue("BagsOfMany_is_open", open and 1 or 0)
	end

    -- Setup the inventory and its content
    local active_item = get_active_item()
    if inventory_open and is_bag(active_item) then
        local stored_items = get_bag_inventory_items(active_item)
        local qt_of_storage = get_bag_inventory_size(active_item)
        local item_per_line = tonumber(bag_wrap_number)
        if not item_per_line then
            item_per_line = 10
        end
        for i = 0, qt_of_storage-1 do
            local pos_in_line = i%(item_per_line)
            local storage_cell_x = button_pos_x + 26 + 20 * (pos_in_line)
            local storage_cell_y = button_pos_y + 28 * (math.floor(i / item_per_line))
            local center_spell_x = 1
            local center_spell_y = -2
            local center_wand_x = 2
            local center_wand_y = 2
            local center_potion_x = 5
            local center_potion_y = 4

            -- only 1
            if (pos_in_line == 0 and i == qt_of_storage-1) or (pos_in_line == 0 and pos_in_line == item_per_line-1) then
                draw_left_bracket(gui, new_id(), storage_cell_x, storage_cell_y)
                draw_middle(gui, new_id(), storage_cell_x, storage_cell_y)
                draw_right_bracket(gui, new_id(), storage_cell_x, storage_cell_y)
            -- 1 and more
            elseif pos_in_line == 0 then
                draw_left_bracket(gui, new_id(), storage_cell_x, storage_cell_y)
                draw_middle(gui, new_id(), storage_cell_x, storage_cell_y)
            -- last for line
            elseif pos_in_line == item_per_line-1 then
                draw_middle(gui, new_id(), storage_cell_x, storage_cell_y)
                draw_right_bracket(gui, new_id(), storage_cell_x, storage_cell_y)
            -- middle end
            elseif i == qt_of_storage-1 then
                draw_middle(gui, new_id(), storage_cell_x, storage_cell_y)
                draw_right_bracket(gui, new_id(), storage_cell_x, storage_cell_y)
            -- middle
            else
                draw_middle(gui, new_id(), storage_cell_x, storage_cell_y)
            end

            local inventory_position = i + 1
            -- Draw the inventory content
            if stored_items[inventory_position] ~= nil then
                local sprite_path = get_sprite_file(stored_items[inventory_position])
                if sprite_path then
                    GuiZSetForNextWidget(gui, 20)
                    local item_pos_x = storage_cell_x + 2
                    local item_pos_y = storage_cell_y - 1
                    local tooltip
                    -- Centering for wand and tooltip
                    if EntityHasTag(stored_items[inventory_position], "wand") then
                        item_pos_x = item_pos_x + center_wand_x
                        item_pos_y = item_pos_y + center_wand_y
                    -- Centering for spells and tooltip
                    elseif EntityHasTag(stored_items[inventory_position], "card_action") then
                        local item_action_component = EntityGetComponentIncludingDisabled(stored_items[inventory_position], "ItemActionComponent")
                        if item_action_component then
                            local action_id = ComponentGetValue2(item_action_component[1], "action_id")
                            tooltip = action_id
                        end
                        item_pos_x = item_pos_x + center_spell_x
                        item_pos_y = item_pos_y + center_spell_y
                        -- Centering for potion, coloring and tooltip
                    elseif EntityHasTag(stored_items[inventory_position], "potion") then
                        local material = get_potion_content(stored_items[inventory_position])
                        item_pos_x = item_pos_x + center_potion_x
                        item_pos_y = item_pos_y + center_potion_y
                        tooltip = string.upper(GameTextGet(material.name)) .. " " .. "POTION" .. " ( " .. material.amount .. "% FULL )"
                        local potion_color = GameGetPotionColorUint(stored_items[inventory_position])
                        if potion_color ~= 0 then
                            local b = bit.rshift(bit.band(potion_color, 0xFF0000), 16) / 0xFF
                            local g = bit.rshift(bit.band(potion_color, 0xFF00), 8) / 0xFF
                            local r = bit.band(potion_color, 0xFF) / 0xFF
                            GuiColorSetForNextWidget(gui, r, g, b, 1)
                        end
                    end
                    -- Draw the item
                    if GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path) then
                        EntityRemoveFromParent(stored_items[inventory_position])
                        local x, y = EntityGetTransform(active_item)
                        EntityApplyTransform(stored_items[inventory_position], x, y)
                        show_entity(stored_items[inventory_position])
                    end
                    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                    -- Draw the tooltip for potion and spells
                    if hovered and tooltip and not EntityHasTag(stored_items[inventory_position], "wand") then
                        GuiBeginAutoBox(gui)
                        GuiLayoutBeginHorizontal(gui, storage_cell_x, storage_cell_y + 30, true)
                        GuiLayoutBeginVertical(gui, 0, 0)
                        local lines = split_string(tooltip, "\n")
                        for _, line in ipairs(lines) do
                            local offset = line == " " and -7 or 0
                            GuiText(gui, 0, offset, line)
                        end
                        GuiLayoutEnd(gui)
                        GuiLayoutEnd(gui)
                        GuiZSetForNextWidget(gui, 10)
                        GuiEndAutoBoxNinePiece(gui)
                    -- Draw the tooltip for wand 
                    elseif hovered and EntityHasTag(stored_items[inventory_position],"wand") then
                        local tooltip_x = storage_cell_x
                        local tooltip_y = storage_cell_y + 20
                        local wand_capacity = EntityGetWandCapacity(stored_items[inventory_position])
                        for i = 1, wand_capacity do
                            GuiZSetForNextWidget(gui, 31)
                            GuiImage(gui, new_id(), tooltip_x+(20 * (i-1)), tooltip_y, "mods/bags_of_many/files/ui_gfx/full_inventory_box.png", 1, 1, 1)
                            i = i + 1
                        end
                        local wand_spells = EntityGetAllChildren(stored_items[inventory_position])
                        for i = 1, #wand_spells do
                            local spell_sprite = get_sprite_file(wand_spells[i])
                            if spell_sprite then
                                GuiZSetForNextWidget(gui, 30)
                                GuiImage(gui, new_id(), tooltip_x+(20 * (i-1)) + 2, tooltip_y + 2, spell_sprite, 1, 1, 1)
                            end
                        end
                    end
                end 
            end
            i = i + 1
        end
    end
end

function draw_left_bracket(gui, id, pos_x, pos_y)
    GuiZSetForNextWidget(gui, 21)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiImage(gui, id, pos_x - 9, pos_y - 8, "mods/bags_of_many/files/ui_gfx/piece_small_left.png", bag_ui_alpha, 1, 1.1)
end

function draw_middle(gui, id, pos_x, pos_y)
    GuiZSetForNextWidget(gui, 21)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiImage(gui, id, pos_x, pos_y - 8, "mods/bags_of_many/files/ui_gfx/piece_small_middle.png", bag_ui_alpha, 7, 1.1)
end

function draw_right_bracket(gui, id, pos_x, pos_y)
    GuiZSetForNextWidget(gui, 21)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiImage(gui, id, pos_x + 21, pos_y - 8, "mods/bags_of_many/files/ui_gfx/piece_small_right.png", bag_ui_alpha, 1, 1.1)
end