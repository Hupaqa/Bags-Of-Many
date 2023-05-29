dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/utils.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )

button_pos_x = ModSettingGet("BagsOfMany.pos_x")
button_pos_y = ModSettingGet("BagsOfMany.pos_y")
button_locked = ModSettingGet("BagsOfMany.locked")
only_show_bag_button_when_held = ModSettingGet("BagsOfMany.only_show_bag_button_when_held")
bag_wrap_number = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")
bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
open = true
sorting = ModSettingGet("BagsOfMany.sorting_order")

current_id = 1
local function new_id()
    current_id = current_id + 1
    return current_id
end
local function reset_id()
    current_id = 1
end

-- GUI
function setup_gui()
    gui = gui or GuiCreate()
    reset_id()

    GuiStartFrame(gui)
    GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)

    local inventory_open = is_inventory_open()
    local active_item = get_active_item()

    -- Setup the inventory button
    if inventory_open and ((not only_show_bag_button_when_held) or (is_bag(active_item) and only_show_bag_button_when_held)) then
        draw_inventory_button(gui, active_item)
    end

    -- Setup the inventory and its content
    if inventory_open and is_bag(active_item) and open then
        draw_inventory_bag(gui, active_item, sorting)
    end
end

function draw_left_bracket(gui, id, pos_x, pos_y)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, 22)
    GuiImage(gui, id, pos_x-5, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_left.png", bag_ui_alpha, 1)
end

function draw_middle(gui, id, pos_x, pos_y)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, 22)
    GuiImage(gui, id, pos_x, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_middle.png", bag_ui_alpha, 1)
end

function draw_right_bracket(gui, id, pos_x, pos_y)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, 22)
    GuiImage(gui, id, pos_x+20, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_right.png", bag_ui_alpha, 1)
end

function draw_inventory_button(gui, active_item)
    if not button_locked then
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiImageButton(gui, 4192922, button_pos_x, button_pos_y, "", "mods/bags_of_many/files/ui_gfx/gui_button_invisible.png")
        local _, _, _, _, _, draw_width, draw_height, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
        if draw_x ~= 0 and draw_y ~= 0 and draw_x ~= button_pos_x and draw_y ~= button_pos_y then
            button_pos_x = draw_x - draw_width / 2
            button_pos_y = draw_y - draw_height / 2
            ModSettingSet("BagsOfMany.pos_x", button_pos_x)
            ModSettingSet("BagsOfMany.pos_y", button_pos_y)
        end
    end
    
    local gui_button_image = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button.png"
    local width_background, height_background = GuiGetImageDimensions(gui, gui_button_image, 1)
    GuiZSetForNextWidget(gui, 20)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local background_button = GuiImageButton(gui, new_id(), button_pos_x, button_pos_y, "", gui_button_image)
    local _, _, hovered_background = GuiGetPreviousWidgetInfo(gui)
    local bag_sprite = "mods/bags_of_many/files/ui_gfx/inventory/drag_icon.png"
    if is_bag(active_item) then
        bag_sprite = get_sprite_file(active_item)
    end
    local width_img, height_img = GuiGetImageDimensions(gui, bag_sprite, 1)
    local pad_x, pad_y = padding_to_center(width_background, height_background, width_img, height_img)
    GuiZSetForNextWidget(gui, 19)
    local bag_button = GuiImageButton(gui, new_id(), button_pos_x + pad_x, button_pos_y + pad_y, "", bag_sprite)
    local _, _, hovered_bag = GuiGetPreviousWidgetInfo(gui)
    if background_button or bag_button then
        open = not open
        GlobalsSetValue("BagsOfMany_is_open", open and 1 or 0)
    end
    if hovered_background or hovered_bag then
        if not open then
            GuiText(gui, button_pos_x, button_pos_y + 20, GameTextGet("$bag_button_tooltip_closed"))
        else
            GuiText(gui, button_pos_x, button_pos_y + 20, GameTextGet("$bag_button_tooltip_opened"))
        end
    end
end

function draw_inventory_drop_button(gui, active_item, pos_x, pos_y)
    GuiZSetForNextWidget(gui, 20)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    if GuiImageButton(gui, new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_drop.png") then
        drop_all_inventory(active_item)
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        GuiText(gui, pos_x + 14, pos_y, GameTextGet("$bag_button_tooltip_drop"))
    end
end

function draw_inventory_sorting_direction_button(gui, active_item, pos_x, pos_y, order_asc)
    GuiZSetForNextWidget(gui, 20)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local order_sprite = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sort_asc.png"
    if not order_asc then
        order_sprite = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sort_desc.png"
    end
    if GuiImageButton(gui, new_id(), pos_x, pos_y, "", order_sprite) then
        sorting = not sorting
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        local txt_hovered = "$bag_button_tooltip_asc_sort"
        if not order_asc then
            txt_hovered = "$bag_button_tooltip_desc_sort"
        end
        GuiText(gui, pos_x + 14, pos_y, GameTextGet(txt_hovered))
    end
end

function generate_tooltip(gui, item)
    local tooltip
    -- Spell tooltip
    if EntityHasTag(item, "card_action") then
        local item_action_component = EntityGetComponentIncludingDisabled(item, "ItemActionComponent")
        if item_action_component then
            local action_id = ComponentGetValue2(item_action_component[1], "action_id")
            if bags_mod_state.lookup_spells[action_id] ~= nil then
                local name = bags_mod_state.lookup_spells[action_id].name
                if name then
                    tooltip = name
                end
            else
                tooltip = action_id
            end
        end
    -- Potion coloring and tooltip
    elseif EntityHasTag(item, "potion") then
        local material = get_potion_content(item)
        if material then
            tooltip = string.upper(GameTextGet(material.name)) .. " " .. "POTION" .. " ( " .. material.amount .. "% FULL )"
        end
        local potion_color = GameGetPotionColorUint(item)
        if potion_color ~= 0 then
            local b = bit.rshift(bit.band(potion_color, 0xFF0000), 16) / 0xFF
            local g = bit.rshift(bit.band(potion_color, 0xFF00), 8) / 0xFF
            local r = bit.band(potion_color, 0xFF) / 0xFF
            GuiColorSetForNextWidget(gui, r, g, b, 1)
        end
    elseif EntityHasTag(item, "item_pickup") then
        local item_component = EntityGetComponentIncludingDisabled(item, "ItemComponent")
        if item_component then
            local item_name = ComponentGetValue2(item_component[1], "item_name")
            if item_name then
                tooltip = GameTextGet(item_name)
            end
        end
    end
    return tooltip
end

function draw_tooltip(gui, item, hovered, tooltip, pos_x, pos_y)
    if hovered and tooltip and (EntityHasTag(item, "potion") or EntityHasTag(item, "card_action") or EntityHasTag(item, "item_pickup")) then
        GuiBeginAutoBox(gui)
        GuiLayoutBeginHorizontal(gui, pos_x, pos_y + 30, true)
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
    elseif hovered and EntityHasTag(item,"wand") then
        local tooltip_x = pos_x+1
        local tooltip_y = pos_y+31
        local spells_per_line = tonumber(ModSettingGet("BagsOfMany.spells_slots_inventory_wrap"))
        local wand_capacity = EntityGetWandCapacity(item)
        local wand_spells = EntityGetAllChildren(item)
        local wand_info = get_wand_info(item)
        
        -- Background
        local slot_size_x, slot_size_y = GuiGetImageDimensions(gui, "mods/bags_of_many/files/ui_gfx/inventory/full_inventory_box.png")
        local spell_tooltip_size_x = slot_size_x * spells_per_line
        if wand_capacity < spells_per_line then
            spell_tooltip_size_x = slot_size_x * wand_capacity
        end
        local spell_tooltip_size_y = slot_size_y * (math.ceil(wand_capacity/spells_per_line))
        local text_width, text_height = draw_wand_infos(tooltip_x, tooltip_y, wand_info)
        -- local text_width, text_height = 0,0
        if spell_tooltip_size_x < text_width then
            spell_tooltip_size_x = text_width
        end
        spell_tooltip_size_y = spell_tooltip_size_y + text_height
        draw_background_box(gui, tooltip_x, tooltip_y, 13, spell_tooltip_size_x, spell_tooltip_size_y, 8, 10, 10, 8)
        tooltip_y = tooltip_y + text_height
        local alpha = 1
        for i = 1, wand_capacity do
            -- Spell background
            local background_pos_x = tooltip_x+(20*((i-1)%spells_per_line))
            local background_pos_y = tooltip_y+(math.floor((i-1)/spells_per_line)*20)
            GuiZSetForNextWidget(gui, 12)
            GuiImage(gui, new_id(), background_pos_x, background_pos_y, "mods/bags_of_many/files/ui_gfx/inventory/inventory_box_inactive_overlay.png", alpha, 1, 1)
            -- Spell sprite
            if wand_spells and wand_spells[i] then
                local spell_sprite = get_sprite_file(wand_spells[i])
                if spell_sprite then
                    GuiZSetForNextWidget(gui, 10)
                    GuiImage(gui, new_id(), background_pos_x+2, background_pos_y+2, spell_sprite, alpha, 1, 1)
                    GuiZSetForNextWidget(gui, 11)
                    GuiImage(gui, new_id(), background_pos_x, background_pos_y, "mods/bags_of_many/files/ui_gfx/inventory/item_bg_projectile.png", alpha, 1, 1)
                end
            end
        end
    end
end

function draw_inventory_bag(gui, active_item, order_asc)
    local stored_items = get_bag_inventory_items(active_item, true, order_asc)
    local qt_of_storage = get_bag_inventory_size(active_item)
    local item_per_line = tonumber(bag_wrap_number)
    if not item_per_line then
        item_per_line = 10
    end
    local positions = inventory(gui, qt_of_storage, item_per_line, button_pos_x + 25, button_pos_y)
    for i = 0, qt_of_storage-1 do
        local storage_cell_x = positions.positions_x[i+1]
        local storage_cell_y = positions.positions_y[i+1]

        local inventory_position = i+1
        -- Draw the inventory content
        local item = stored_items[inventory_position]
        if item ~= nil then
            local sprite_path = get_sprite_file(item)
            if sprite_path then
                local item_pos_x = storage_cell_x
                local item_pos_y = storage_cell_y
                local tooltip = generate_tooltip(gui, item)

                local img_width, img_height = GuiGetImageDimensions(gui, sprite_path, 1)
                local pad_x, pad_y = padding_to_center(20, 20, img_width, img_height)
                item_pos_x = item_pos_x + pad_x
                item_pos_y = item_pos_y + pad_y
                -- Draw the item
                GuiZSetForNextWidget(gui, 15)
                if GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path) then
                    drop_item_from_parent(active_item, item)
                end
                local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                draw_tooltip(gui, item, hovered, tooltip, button_pos_x + 25, storage_cell_y)
            end
        end
        i = i + 1
    end
    if ModSettingGet("BagsOfMany.show_drop_all_inventory_button") then
        draw_inventory_drop_button(gui, active_item, positions.positions_x[#positions.positions_x] + 24, positions.positions_y[#positions.positions_y]+9)
    end
    if ModSettingGet("BagsOfMany.show_change_sorting_direction_button") then
        draw_inventory_sorting_direction_button(gui, active_item, positions.positions_x[#positions.positions_x] + 24, positions.positions_y[#positions.positions_y]-2, sorting)
    end
end

function inventory_slot(gui, pos_x, pos_y)
    GuiZSetForNextWidget(gui, 20)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiImage(gui, new_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/inventory/full_inventory_box.png", bag_ui_alpha, 1, 1)
end

function inventory(gui, size, item_per_line, pos_x, pos_y)
    local positions_x = {}
    local positions_y = {}
    for i = 0, size - 1 do
        local pos_in_line = i%(item_per_line)
        local x = pos_x + (pos_in_line * 20)
        local y = pos_y + (math.floor(i/item_per_line) * 27)
        table.insert(positions_x, x)
        table.insert(positions_y, y)
        inventory_slot(gui, x, y)

        -- only 1
        if (pos_in_line == 0 and i == size-1) or (pos_in_line == 0 and pos_in_line == item_per_line-1) then
            draw_left_bracket(gui, new_id(), x, y)
            draw_middle(gui, new_id(),  x, y)
            draw_right_bracket(gui, new_id(),  x, y)
        -- 1 and more
        elseif pos_in_line == 0 then
            draw_left_bracket(gui, new_id(),  x, y)
            draw_middle(gui, new_id(),  x, y)
        -- last for line
        elseif pos_in_line == item_per_line-1 then
            draw_middle(gui, new_id(),  x, y)
            draw_right_bracket(gui, new_id(),  x, y)
        -- middle end
        elseif i == size-1 then
            draw_middle(gui, new_id(),  x, y)
            draw_right_bracket(gui, new_id(),  x, y)
        -- middle
        else
            draw_middle(gui, new_id(),  x, y)
        end
    end
    return {positions_x = positions_x, positions_y = positions_y}
end

--------- UTILS ---------

function draw_wand_infos(pos_x, pos_y, wand)
    local draw_width_sum, draw_height_sum = 0, 0
    local draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, nil, "WAND", "")
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height + 5)
    local wand_shuffle = "No"
    if wand.shuffle then
        wand_shuffle = "Yes"
    end
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_gun_shuffle.png", "Shuffle", wand_shuffle)
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_gun_actions_per_round.png", "Spells/Cast", tostring(wand.actions_per_round))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_fire_rate_wait.png", "Cast delay", string.format("%.2f s", wand.cast_delay / 60))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_gun_reload_time.png", "Recharg. Time", string.format("%.2f s", wand.recharge_time / 60))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_mana_max.png", "Mana max", tostring(wand.mana_max))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_mana_charge_speed.png", "Mana chg. Spd", tostring(wand.mana_charge_speed))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_gun_capacity.png", "Capacity", tostring(wand.capacity))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_spread_degrees.png", "Spread", tostring(wand.spread) .. " DEG")
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height + 5)
    return draw_width_sum, draw_height_sum
end

function draw_info_line(pos_x, pos_y, image, text, value)
    -- DRAW IMAGE
    local draw_width_sum, draw_height_sum = 0,0
    local draw_width, draw_height = 0,0
    if image ~= nil and image ~= "" then
        GuiZSetForNextWidget(gui, 10)
        GuiImage(gui, new_id(), pos_x, pos_y, image, 1, 1, 1)
        draw_width, _ = GuiGetImageDimensions(gui, image, 1)
        draw_width_sum = draw_width_sum + draw_width + 6
    end
    GuiText(gui, pos_x + draw_width_sum, pos_y - 1, text)
    draw_width, draw_height = get_last_widget_size(gui)
    draw_width_sum = draw_width_sum + draw_width
    draw_height_sum = draw_height_sum + draw_height
    if value ~= nil and value ~= "" then
        draw_width, _ = get_last_widget_size(gui)
        local padding = 60 - draw_width
        if padding < 0 then
            padding = draw_width
        end
        GuiText(gui, pos_x + draw_width_sum + padding, pos_y - 1, value)
        draw_width_sum = draw_width_sum + draw_width + padding
    end
    return draw_width_sum, draw_height_sum
end

function get_last_widget_size(gui)
    local _, _, _, _, _, _, _, _, _, draw_width, draw_height = GuiGetPreviousWidgetInfo(gui)
    return draw_width, draw_height
end

function add_to_sum_width(val_width_sum, val_height_sum, val_width, val_height)
    if val_width_sum < val_width then
        val_width_sum = val_width
    end
    return val_width_sum, val_height_sum + val_height
end

function add_to_sum_height(val_width_sum, val_height_sum, val_width, val_height)
    if val_height_sum < val_height then
        val_height_sum = val_height
    end
    return val_width_sum + val_width, val_height_sum
end

function draw_background_box(gui, pos_x, pos_y, pos_z, size_x, size_y, pad_top, pad_right, pad_bottom, pad_left)
    size_x = size_x - 1
    size_y = size_y - 1

    ---- CORNERS
    -- TOP LEFT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x + pad_right + size_x - 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x + pad_right + size_x, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left, pos_y + pad_bottom + size_y - 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left + 1, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM RIGHT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x + pad_right + size_x, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    
    ---- MIDDLE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left + 1, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/middle_piece.png", 0.99, size_x + pad_left + pad_right - 1, size_y + pad_top + pad_bottom - 1)

    ---- BORDERS
    -- TOP BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left + 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
    -- LEFT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- RIGHT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x + size_x + pad_right, pos_y - pad_top + 2, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- BOTTOM BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, new_id(), pos_x - pad_left + 2, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
end