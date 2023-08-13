dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/utils.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/wand_and_spells.lua" )

-- GUI
local gui = gui or GuiCreate()
local positions = {}

-- MOD SETTINGS
local show_bags_without_inventory_open = ModSettingGet("BagsOfMany.show_bags_without_inventory_open")
local only_show_bag_button_when_held = ModSettingGet("BagsOfMany.only_show_bag_button_when_held")
local bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
local bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
local bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
local bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
local dragging_allowed = ModSettingGet("BagsOfMany.dragging_allowed")
local item_per_line = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")

-- BAG AND TOOLTIP TOGGLE
local bag_open = true
local keep_tooltip_open = ModSettingGet("BagsOfMany.keep_tooltip_open")

-- MULTI DEPTH INVENTORY
local last_hover_item = {}
local draw_inventory_list = {}

-- INVISIBLE ACTION FLAGS 
-- DRAGGING VARIABLES
local currently_dragging = false
local dragging_on = false
local dragging_possible_swap = false
local dragging_item = nil
local dragging_item_bag = nil
local dragging_item_level = nil
local dragging_item_position = {}
-- CLICK VARIABLES
local clicked_item = nil
local clicked_invs = {}
local right_clicked_item = nil
local right_clicked_invs = {}
-- HOVERING VARIABLES
local hovered_item = nil
local hovered_invs_bag = nil
local hovered_invs_level = nil
local hovered_invs = {}

-- SORTING FLAG AND OPTION
local sort_type_change_flag = false
local sort_by_time = ModSettingGet("BagsOfMany.sorting_type")
local sort_order_change_flag = false
local sorting_order = ModSettingGet("BagsOfMany.sorting_order")
-- OPTION CHANGE FLAG
local option_changed = false

local drop_no_order = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_drop.png"
local drop_orderly = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_drop_orderly.png"
local dropping_button_sprite = drop_orderly

-- Dragging inventory cell
local dragged_ui_id = nil
local dragged_position = nil
local dragged_bag = nil
local dragged_item = nil
local dragged_position_x = nil
local dragged_position_y = nil

-- NEW VARIABLES
local inventory_bag_table = {}
local dragged_id_reserved = nil
local dragged_item_table = {
    item = nil,
    position = nil,
    bag = nil,
    level = nil,
    position_x = nil,
    position_y = nil
}
local hovered_item_table = {
    item = nil,
    position = nil,
    bag = nil,
    level = nil,
    position_x = nil,
    position_y = nil
}
local left_click_table = {
    item = nil,
    position = nil,
    bag = nil,
    level = nil,
    position_x = nil,
    position_y = nil
}
local right_click_table = {
    item = nil,
    position = nil,
    bag = nil,
    level = nil,
    position_x = nil,
    position_y = nil
}

-- GUI ID SECTION
local current_id = 1
local function new_id()
    if dragged_id_reserved == current_id + 1 then
        current_id = current_id + 2
    else
        current_id = current_id + 1
    end
    return current_id
end
local function skip_id()
    current_id = current_id + 1
end
local function reset_id()
    current_id = 1
end

-- UPDATE THE VALUE OF THE SETTINGS IN THE CODE
function update_settings()
    show_bags_without_inventory_open = ModSettingGet("BagsOfMany.show_bags_without_inventory_open")
    only_show_bag_button_when_held = ModSettingGet("BagsOfMany.only_show_bag_button_when_held")
    bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
    bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
    bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
    bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
    dragging_allowed = ModSettingGet("BagsOfMany.dragging_allowed")
    item_per_line = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")
    dragging_allowed = ModSettingGet("BagsOfMany.dragging_allowed")
    sort_by_time = ModSettingGet("BagsOfMany.sorting_type")
    sorting_order = ModSettingGet("BagsOfMany.sorting_order")
    keep_tooltip_open = ModSettingGet("BagsOfMany.keep_tooltip_open")
end

function reset_item_table(table)
    table = {
        item = nil,
        position = nil,
        bag = nil,
        level = nil,
        position_x = nil,
        position_y = nil
    }
    return table
end

function bag_of_many_setup_gui_v2()
    local pos_x = bags_mod_state.button_pos_x
    local pos_y = bags_mod_state.button_pos_y
    reset_id()

    GuiStartFrame(gui)
    GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)

    local inventory_open = is_inventory_open() or show_bags_without_inventory_open
    local active_item = get_active_item()

    -- Setup the inventory button
    if inventory_open and ((not only_show_bag_button_when_held) or (is_bag(active_item) and only_show_bag_button_when_held)) then
        draw_inventory_button(gui, pos_x, pos_y, active_item)
    end

    local level = 1
    -- Adding held item to the display list and removing every 
    if inventory_bag_table[level] ~= active_item then
        inventory_bag_table = {}
        inventory_bag_table[level] = active_item
    end

    if inventory_open and is_bag(active_item) and bag_open then
        if not option_changed then
            local pos_z = 10
            for bag_level, bag in pairs(inventory_bag_table) do
                -- DISPLAY BAG HOVERED AT BEGINNING OF INVENTORY
                if bag_level ~= 1 then
                    pos_y = positions[bag_level - 1].positions_y[#positions[bag_level - 1].positions_y] - (28 * (bag_level - 2))
                end
                draw_inventory_v2(gui, pos_x, pos_y, pos_z, bag, bag_level)
                -- multi_layer_bag_image(bag, pos_x, pos_y, pos_z, bag_level)
            end
        end
    end

    if dragging_allowed and dragging_possible_swap then
        if dragged_item_table.item and hovered_item_table.item and (dragged_item_table.item ~= hovered_item_table.item) then
            print("Swapping")
            swap_item_position(dragged_item_table.item, hovered_item_table.item)
        elseif dragged_item_table.item and not hovered_item_table.item and hovered_item_table.bag then
            print("POSITION")
            swap_item_to_position(dragged_item_table.item, hovered_item_table.position, hovered_item_table.bag)
        elseif dragged_item_table.item and not hovered_item_table.item and not hovered_item_table.bag then
            print("DROPPING")
            drop_item_from_parent(dragged_item_table.item, true)
        end

        print_table(dragged_item_table)
        reset_table(dragged_item_table)
        print_table(dragged_item_table)
        dragging_possible_swap = false
    end
    hovered_item_table = reset_item_table(hovered_item_table)

    -- OPTION CHANGE PROCESSING
    if sort_order_change_flag then
        sort_order_change_flag = false
        sorting_order = not sorting_order
        ModSettingSetNextValue("BagsOfMany.sorting_order", sorting_order, false)
    end
    if sort_type_change_flag then
        sort_type_change_flag = false
        sort_by_time = not sort_by_time
        ModSettingSetNextValue("BagsOfMany.sorting_type", sort_by_time, false)
    end
end

function multi_layer_bag_image(bag, pos_x, pos_y, pos_z, level)
    local bag_hovered_sprite = get_sprite_file(bag)
    if bag_hovered_sprite then
        local bag_display_x, bag_display_y = pos_x + (5 * (level - 1)), pos_y + (28 * (level - 1))
        -- Background for bag inception display
        local gui_button_image = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button.png"
        local width_background, height_background = GuiGetImageDimensions(gui, gui_button_image, 1)
        local width_img, height_img = GuiGetImageDimensions(gui, bag_hovered_sprite, 1)
        GuiZSetForNextWidget(gui, pos_z+1)
        GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
        GuiImage(gui, new_id(), bag_display_x, bag_display_y, gui_button_image, 1, 1 ,1)
        local pad_x, pad_y = padding_to_center(width_background, height_background, width_img, height_img)
        GuiZSetForNextWidget(gui, pos_z)
        GuiImage(gui, new_id(), bag_display_x + pad_x, bag_display_y + pad_y, bag_hovered_sprite, 1, 1, 1)
        local _, _, hovered_inception_bag = GuiGetPreviousWidgetInfo(gui)
        if hovered_inception_bag then
            local tooltip = generate_tooltip(bag)
            GuiBeginAutoBox(gui)
            GuiLayoutBeginHorizontal(gui, bag_display_x, bag_display_y + 30, true)
            GuiLayoutBeginVertical(gui, 0, 0)
            local lines = split_string(tooltip, "\n")
            for _, line in ipairs(lines) do
                local offset = line == " " and -7 or 0
                GuiText(gui, 0, offset, line)
            end
            GuiLayoutEnd(gui)
            GuiLayoutEnd(gui)
            GuiZSetForNextWidget(gui, 1)
            GuiEndAutoBoxNinePiece(gui)
        end
    end
end

-- GUI
function bag_of_many_setup_gui()
    local pos_x = bags_mod_state.button_pos_x
    local pos_y = bags_mod_state.button_pos_y
    reset_id()

    GuiStartFrame(gui)
    GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)

    local inventory_open = is_inventory_open() or show_bags_without_inventory_open
    local active_item = get_active_item()

    -- Setup the inventory button
    if inventory_open and ((not only_show_bag_button_when_held) or (is_bag(active_item) and only_show_bag_button_when_held)) then
        draw_inventory_button(gui, pos_x, pos_y, active_item)
    end

    -- Setup the inventory and its content
    if inventory_open and is_bag(active_item) and bag_open then
        if active_item and not draw_inventory_list[active_item] then
            draw_inventory_list[active_item] = {}
        end
        local level = 1
        if not option_changed then
            local pos_z = 10
            draw_inventory(gui, pos_x, pos_y, pos_z, active_item, level)
            if draw_inventory_list[active_item] then
                for key, value in pairs(draw_inventory_list[active_item]) do
                    -- DISPLAY BAG HOVERED AT BEGINNING OF INVENTORY
                    pos_y = positions[key-1].positions_y[#positions[key-1].positions_y] - (28 * (key - 2))
                    -- DISPLAY BAG HOVERED INVENTORY
                    draw_inventory(gui, pos_x, pos_y, pos_z, value, key)
                    local bag_hovered_sprite = get_sprite_file(value)
                    if bag_hovered_sprite then
                        local bag_display_x, bag_display_y = pos_x + (5 * (key - 1)), pos_y + (28 * (key - 1))
                        -- Background for bag inception display
                        local gui_button_image = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button.png"
                        local width_background, height_background = GuiGetImageDimensions(gui, gui_button_image, 1)
                        local width_img, height_img = GuiGetImageDimensions(gui, bag_hovered_sprite, 1)
                        GuiZSetForNextWidget(gui, pos_z+1)
                        GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
                        GuiImage(gui, new_id(), bag_display_x, bag_display_y, gui_button_image, 1, 1 ,1)
                        local pad_x, pad_y = padding_to_center(width_background, height_background, width_img, height_img)
                        GuiZSetForNextWidget(gui, pos_z)
                        GuiImage(gui, new_id(), bag_display_x + pad_x, bag_display_y + pad_y, bag_hovered_sprite, 1, 1, 1)
                        local _, _, hovered_inception_bag = GuiGetPreviousWidgetInfo(gui)
                        if hovered_inception_bag then
                            local tooltip = generate_tooltip(value)
                            GuiBeginAutoBox(gui)
                            GuiLayoutBeginHorizontal(gui, bag_display_x, bag_display_y + 30, true)
                            GuiLayoutBeginVertical(gui, 0, 0)
                            local lines = split_string(tooltip, "\n")
                            for _, line in ipairs(lines) do
                                local offset = line == " " and -7 or 0
                                GuiText(gui, 0, offset, line)
                            end
                            GuiLayoutEnd(gui)
                            GuiLayoutEnd(gui)
                            GuiZSetForNextWidget(gui, 1)
                            GuiEndAutoBoxNinePiece(gui)
                        end
                    end
                end
            end
        end

        -- Process inventory dragging
        if dragging_allowed and dragging_possible_swap then
            if not sort_by_time then
                if dragging_item and hovered_item and dragging_item ~= hovered_item then
                    if not is_in_bag_tree(dragging_item, hovered_invs_bag) then
                        swap_item_position(dragging_item, hovered_item)
                    end
                elseif dragging_item and hovered_invs.is_hovering and hovered_invs_bag and dragging_item_bag then
                    if not is_in_bag_tree(dragging_item, hovered_invs_bag) then
                        swap_item_to_position(dragging_item, hovered_invs[hovered_invs_level], hovered_invs_bag)
                    end
                elseif dragging_item and not hovered_invs.is_hovering then
                    drop_item_from_parent(dragging_item, true)
                    active_item = get_active_item()
                    if active_item then
                        draw_inventory_list[active_item] = remove_draw_list_under_level(draw_inventory_list[active_item], level)
                    else
                        draw_inventory_list = {}
                    end
                end
            else
                if dragging_item and hovered_item and dragging_item ~= hovered_item then
                    swap_item_to_bag(dragging_item, hovered_invs_bag)
                elseif dragging_item and hovered_invs.is_hovering and hovered_invs_bag and dragging_item_bag then
                    swap_item_to_bag(dragging_item, hovered_invs_bag)
                elseif dragging_item and not hovered_invs.is_hovering then
                    drop_item_from_parent(dragging_item, true)
                    active_item = get_active_item()
                    if active_item then
                        draw_inventory_list[active_item] = remove_draw_list_under_level(draw_inventory_list[active_item], level)
                    else
                        draw_inventory_list = {}
                    end
                end
            end
        end
    end

    -- OPTION CHANGE PROCESSING
    if sort_order_change_flag then
        sort_order_change_flag = false
        sorting_order = not sorting_order
        ModSettingSetNextValue("BagsOfMany.sorting_order", sorting_order, false)
    end
    if sort_type_change_flag then
        sort_type_change_flag = false
        sort_by_time = not sort_by_time
        ModSettingSetNextValue("BagsOfMany.sorting_type", sort_by_time, false)
    end
    reset_drawing_variables()
end

-- RESET DRAGGING CODE
function reset_drawing_variables()
    if dragging_possible_swap then
        dragging_item_position = {}
        dragging_item = nil
        dragging_item_level = nil
        dragging_item_bag = nil
    end
    dragging_on = false
    dragging_possible_swap = false
    clicked_item = nil
    clicked_invs = {}
    right_clicked_item = nil
    right_clicked_invs = {}
    hovered_invs = {}
    hovered_invs_level = nil
    hovered_invs_bag = nil
    hovered_item = nil
    option_changed = false
end

-- Inventory drawing
function draw_inventory_v2(gui, pos_x, pos_y, pos_z, entity, level)
    local active_item = get_active_item()
    if not pos_z then
        pos_z = 1
    end
    if is_bag(entity) and active_item then
        local storage_size = get_bag_inventory_size(entity)
        if not item_per_line then
            item_per_line = 10
        end

        -- Draw and calculate inventory positions
        positions[level] = inventory(gui, storage_size, item_per_line, pos_x + 25 + (5 * (level - 1)), pos_y + (28 * (level - 1)), pos_z + 100)

        -- Inventory Options
        setup_inventory_options_buttons(entity, level, positions[level].positions_x[#positions[level].positions_x] + 25, positions[level].positions_y[#positions[level].positions_y] - 3, pos_z + 100)

        -- Items drawing loop
        local items = get_bag_inventory_items(entity, sort_by_time, sorting_order)
        if not option_changed then
            draw_inventory_v2_invisible(storage_size, positions[level], entity, level)
            draw_inventory_v2_items(items, positions[level], entity, level, pos_z)
            -- draw_inventory_dragged_item_v2(pos_z)
        end
    else
    end
end

function draw_inventory_v2_invisible(storage_size, positions, bag, level)
    -- LOOP FOR THE INVISIBLE STORAGES
    for i = 1, storage_size do
        local item_pos_x = positions.positions_x[i]
        local item_pos_y = positions.positions_y[i]

        -- Invisible dragging button
        if dragging_allowed then
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
        end
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiZSetForNextWidget(gui, 1)
        GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/visible20x20.png")
        local clicked_inv, right_clicked_inv, hovered_inv, _, _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)

        -- DETECT DRAGGING
        if dragging_allowed then
            if dragged_item_table.item and dragged_item_table.bag == bag and dragged_item_table.level == level and dragged_item_table.position == i then
                dragged_item_table.position_x = draw_x
                dragged_item_table.position_y = draw_y
            end
            if not dragged_item_table.item and button_is_not_at_zero(draw_x, draw_y) and button_has_moved(draw_x, draw_y, item_pos_x, item_pos_y) then
                dragged_item_table.bag = bag
                dragged_item_table.position = i
                dragged_item_table.level = level
                dragged_item_table.position_x = draw_x
                dragged_item_table.position_y = draw_y
                -- dragged_id_reserved = current_id
            end
            if math.floor(draw_x) == 0 and math.floor(draw_y) == 0 and dragged_item_table.level == level and dragged_item_table.bag == bag and dragged_item_table.position == i then
                dragging_possible_swap = true
            end
        end

        -- LEFT CLICK: DROP ITEM
        if clicked_inv and not dragged_item_table.item then
            left_click_table.bag = bag
            left_click_table.position = i
            left_click_table.level = level
        end
        -- RIGHT CLICK: MULTI DEPTH CHANGE
        if right_clicked_inv then
            right_click_table.bag = bag
            right_click_table.position = i
            right_click_table.level = level
        end
        -- HOVERING: SHOW TOOLTIP, ADD BAG TO INVENTORY DRAW OR SWITCH ITEM HOVERED
        if hovered_inv then
            hovered_item_table.bag = bag
            hovered_item_table.position = i
            hovered_item_table.level = level
        end
    end
end

function draw_inventory_v2_items(items, positions, bag, level, pos_z)
    -- LOOP FOR ITEMS
    for i = 1, #items do
        local item = items[i]
        if item then
            local item_position
            if sort_by_time then
                item_position = i
            else
                item_position = get_item_position(item)
            end
            local sprite_path = get_sprite_file(item)
            if item_position then
                local item_pos_x = positions.positions_x[item_position]
                local item_pos_y = positions.positions_y[item_position]
                if item_pos_x and item_pos_y then

                    -- LEFT CLICK: DROP ITEM
                    if left_click_table.position == item_position and left_click_table.level == level and left_click_table.bag == bag then
                        left_click_table.item = item
                        reset_table(left_click_table)
                        drop_item_from_parent(item)
                    end
                    -- RIGHT CLICK: DROP ITEM
                    if right_click_table.position == item_position and right_click_table.level == level and right_click_table.bag == bag then
                        right_click_table.item = item
                        reset_table(right_click_table)
                        drop_item_from_parent(item)
                    end
                    -- HOVERED: DETECT WHICH ITEM IS HOVERED
                    if hovered_item_table.position == item_position and hovered_item_table.level == level and hovered_item_table.bag == bag then
                        item_pos_y = item_pos_y - 1
                        hovered_item_table.item = item
                        -- REMOVE DRAW LIST IF NEEDED
                        -- if last_hover_item[level] ~= item and not dragging_item then
                        --     last_hover_item[level] = item
                        --     remove_draw_list_under_level(inventory_bag_table, level)
                        -- end
                        if not is_bag(item) and not dragged_item_table.item then
                            draw_tooltip(item, item_pos_x, item_pos_y, level)
                        end

                        if is_bag(item) then
                            inventory_bag_table[level + 1] = item
                        end
                    end

                    if dragged_item_table.level == level and dragged_item_table.bag == bag and dragged_item_table.position == i then
                        dragged_item_table.item = item
                    end

                    -- prevent item flash when dragging ends
                    if sprite_path and not(dragged_item_table.item == item and dragging_possible_swap) then
                        if dragged_item_table.item == item then
                            item_pos_x = dragged_item_table.position_x
                            item_pos_y = dragged_item_table.position_y
                        end
                        local img_width, img_height = GuiGetImageDimensions(gui, sprite_path, 1)
                        local pad_x, pad_y = padding_to_center(20, 20, img_width, img_height)
                        item_pos_x = item_pos_x + pad_x
                        item_pos_y = item_pos_y + pad_y
                        add_item_specifity(item, item_pos_x, item_pos_y, pos_z + 2)
                        GuiZSetForNextWidget(gui, pos_z + 1)
                        GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path)
                    end
                end
            end
        end
    end
end

function draw_inventory_dragged_item_v2(pos_z)
    if dragged_item_table.item then
        -- Invisible dragging button
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiZSetForNextWidget(gui, 1)
        GuiImageButton(gui, dragged_id_reserved, dragged_item_table.position_x, dragged_item_table.position_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/visible20x20.png")
        local clicked_inv, right_clicked_inv, hovered_inv, _, _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)

        if not dragged_item_table.item and button_is_not_at_zero(draw_x, draw_y) and button_has_moved(draw_x, draw_y, dragged_item_table.position_x, dragged_item_table.position_y) then
            dragged_item_table.position_x = draw_x
            dragged_item_table.position_y = draw_y
        end
        if math.floor(draw_x) == 0 and math.floor(draw_y) == 0 then
            dragging_possible_swap = true
        end
    end
    if dragged_item_table.item then
        local item = dragged_item_table.item
        local sprite_path = get_sprite_file(item)
        if sprite_path then
            local img_width, img_height = GuiGetImageDimensions(gui, sprite_path, 1)
            local pad_x, pad_y = padding_to_center(20, 20, img_width, img_height)
            local item_pos_x = dragged_item_table.position_x + pad_x
            local item_pos_y = dragged_item_table.position_y + pad_y
            add_item_specifity(item, item_pos_x, item_pos_y, pos_z + 2)
            GuiZSetForNextWidget(gui, pos_z + 1)
            GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path)
        end
    end
end

-- Inventory drawing
function draw_inventory(gui, pos_x, pos_y, pos_z, entity, level)
    local active_item = get_active_item()
    if not pos_z then
        pos_z = 1
    end
    if not keep_tooltip_open then
        draw_inventory_list[entity] = {}
    end
    if is_bag(entity) and active_item then
        local storage_size = get_bag_inventory_size(entity)
        if not item_per_line then
            item_per_line = 10
        end

        -- Draw and calculate inventory positions
        positions[level] = inventory(gui, storage_size, item_per_line, pos_x + 25 + (5 * (level - 1)), pos_y + (28 * (level - 1)), pos_z + 100)

        -- Inventory Options
        setup_inventory_options_buttons(entity, level, positions[level].positions_x[#positions[level].positions_x] + 25, positions[level].positions_y[#positions[level].positions_y] - 3, pos_z + 100)

        -- Items drawing loop
        local items = get_bag_inventory_items(entity, sort_by_time, sorting_order)
        if not option_changed then
            local drag_item_x, drag_item_y = 0,0

            -- LOOP FOR THE INVISIBLE STORAGES
            for i = 1, storage_size do
                local item_pos_x = positions[level].positions_x[i]
                local item_pos_y = positions[level].positions_y[i]

                -- Invisible dragging button
                if dragging_allowed then
                    GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
                end
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
                GuiZSetForNextWidget(gui, 1)
                GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
                local clicked_inv, right_clicked_inv, hovered_inv, _, _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)

                -- DETECT DRAGGING
                if dragging_allowed then
                    if dragging_on and dragging_item_position[dragging_item_level] == i and dragging_item_bag == entity then
                        drag_item_x = draw_x
                        drag_item_y = draw_y
                    end
                    if not dragging_on and button_is_not_at_zero(draw_x, draw_y) and button_has_moved(draw_x, draw_y, item_pos_x, item_pos_y) then
                        dragging_on = true
                        dragging_item_bag = entity
                        dragging_item_level = level
                        dragging_item_position[level] = i
                        drag_item_x = draw_x
                        drag_item_y = draw_y
                    elseif math.floor(draw_x) == 0 and math.floor(draw_y) == 0 and dragging_item_position[level] == i then
                        dragging_on = true
                        dragging_possible_swap = true
                    end
                end

                -- LEFT CLICK: DROP ITEM
                if clicked_inv and not dragging_on then
                    clicked_invs[level] = i
                end
                -- RIGHT CLICK: MULTI DEPTH CHANGE
                if right_clicked_inv then
                    right_clicked_invs[level] = i
                end
                -- HOVERING: SHOW TOOLTIP, ADD BAG TO INVENTORY DRAW OR SWITCH ITEM HOVERED
                if hovered_inv then
                    hovered_invs.is_hovering = true
                    hovered_invs_bag = entity
                    hovered_invs_level = level
                    hovered_invs[level] = i
                end
            end

            -- LOOP FOR ITEMS
            for i = 1, #items do
                local item = items[i]
                if item then
                    local item_position
                    if sort_by_time then
                        item_position = i
                    else
                        item_position = get_item_position(item)
                    end
                    local sprite_path = get_sprite_file(item)
                    if item_position then
                        local item_pos_x = positions[level].positions_x[item_position]
                        local item_pos_y = positions[level].positions_y[item_position]
                        if item_pos_x and item_pos_y then

                            -- LEFT CLICK: DROP ITEM AND CLEAR DRAW LIST
                            if clicked_invs[level] and clicked_invs[level] == item_position then
                                clicked_item = item
                                hovered_invs[level] = {}
                                draw_inventory_list[active_item] = remove_draw_list_under_level(draw_inventory_list[active_item], level)
                                drop_item_from_parent(item)
                            end
                            -- RIGHT CLICK: INCEPTION INVENTORY TOGGLE
                            if right_clicked_invs[level] and right_clicked_invs[level] == item_position then
                                right_clicked_item = item
                                hovered_invs[level] = {}
                                draw_inventory_list[active_item] = remove_draw_list_under_level(draw_inventory_list[active_item], level)
                                drop_item_from_parent(item)
                            end
                            -- HOVERED: DETECT WHICH ITEM IS HOVERED
                            if hovered_invs[level] and hovered_invs[level] == item_position then
                                -- REMOVE DRAW LIST IF NEEDED
                                if last_hover_item[level] ~= item and not dragging_item then
                                    last_hover_item[level] = item
                                    remove_draw_list_under_level(draw_inventory_list[active_item], level)
                                end
                                item_pos_y = item_pos_y - 1
                                hovered_item = item
                                if not is_bag(item) and not dragging_item then
                                    draw_tooltip(item, item_pos_x, item_pos_y, level)
                                end

                                if is_bag(item) then
                                    draw_inventory_list[active_item][level + 1] = item
                                end
                            end

                            -- DISPLAY ITEM
                            if dragging_on and dragging_item_position[level] == item_position and dragging_item_level == level and dragging_item_bag == entity then
                                dragging_item = item
                                item_pos_x = drag_item_x
                                item_pos_y = drag_item_y
                            end

                            -- prevent item flash when dragging ends
                            if not dragging_possible_swap or item ~= dragging_item and button_is_not_at_zero(item_pos_x, item_pos_y) then
                                local img_width, img_height = GuiGetImageDimensions(gui, sprite_path, 1)
                                local pad_x, pad_y = padding_to_center(20, 20, img_width, img_height)
                                item_pos_x = item_pos_x + pad_x
                                item_pos_y = item_pos_y + pad_y
                                add_item_specifity(item, item_pos_x, item_pos_y, pos_z + 2)
                                GuiZSetForNextWidget(gui, pos_z + 1)
                                GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path)
                            end
                        end
                    end
                end
            end
        end
    else
    end
end

function button_is_not_at_zero(draw_x, draw_y)
    return math.floor(draw_x) ~= 0 and math.floor(draw_y) ~= 0
end

function button_has_moved(draw_x, draw_y, item_pos_x, item_pos_y)
    return math.ceil(draw_x) ~= math.ceil(item_pos_x) or math.ceil(draw_y) ~= math.ceil(item_pos_y)
end

function draw_left_bracket(gui, id, pos_x, pos_y, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x-5, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_left.png", bag_ui_alpha, 1)
end

function draw_middle(gui, id, pos_x, pos_y, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_middle.png", bag_ui_alpha, 1)
end

function draw_right_bracket(gui, id, pos_x, pos_y, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x+20, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_right.png", bag_ui_alpha, 1)
end

function draw_inventory_button(gui, pos_x, pos_y, active_item)
    -- Invisible button overlay
    local clicked, hovered_invisible, right_clicked
    if not ModSettingGet("BagsOfMany.locked") then
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiZSetForNextWidget(gui, 1)
        clicked, right_clicked = GuiImageButton(gui, new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
        _, _, hovered_invisible = GuiGetPreviousWidgetInfo(gui)
        local _, _, _, _, _, draw_width, draw_height, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
        if draw_x ~= 0 and draw_y ~= 0 and draw_x ~= pos_x and draw_y ~= pos_y then
            pos_x = draw_x - draw_width / 2
            pos_y = draw_y - draw_height / 2
            bags_mod_state.button_pos_x = pos_x
            bags_mod_state.button_pos_y = pos_y
        end
    else
        GuiZSetForNextWidget(gui, 1)
        clicked, right_clicked = GuiImageButton(gui, new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
        _, _, hovered_invisible = GuiGetPreviousWidgetInfo(gui)
    end

    -- Background button 
    local gui_button_image = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button.png"
    local width_background, height_background = GuiGetImageDimensions(gui, gui_button_image, 1)
    GuiZSetForNextWidget(gui, 3)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local background_button = GuiImage(gui, new_id(), pos_x, pos_y, gui_button_image, 1, 1 ,1)

    -- Bag button
    local bag_sprite = "mods/bags_of_many/files/ui_gfx/inventory/drag_icon.png"
    if is_bag(active_item) then
        bag_sprite = get_sprite_file(active_item)
    end
    local width_img, height_img = GuiGetImageDimensions(gui, bag_sprite, 1)
    local pad_x, pad_y = padding_to_center(width_background, height_background, width_img, height_img)
    GuiZSetForNextWidget(gui, 2)
    local bag_button = GuiImage(gui, new_id(), pos_x + pad_x, pos_y + pad_y, bag_sprite, 1, 1, 1)

    -- Open or close bag
    if clicked then
        bag_open = not bag_open
        GlobalsSetValue("bags_of_many.bag_open", bag_open and 1 or 0)
    end
    -- Show tooltip
    if hovered_invisible then
        if not bag_open then
            GuiText(gui, pos_x, pos_y + 24, "[LMB]" .. GameTextGet("$bag_button_tooltip_closed"))
        else
            GuiText(gui, pos_x, pos_y + 24, "[LMB]" .. GameTextGet("$bag_button_tooltip_opened"))
        end
        if not show_bags_without_inventory_open then
            GuiText(gui, pos_x, pos_y + 34, "[RMB]" .. GameTextGet("$bag_button_tooltip_inventory_closed_closed"))
        else
            GuiText(gui, pos_x, pos_y + 34, "[RMB]" .. GameTextGet("$bag_button_tooltip_inventory_closed_opened"))
        end
    end
    if right_clicked then
        show_bags_without_inventory_open = not show_bags_without_inventory_open
        ModSettingSetNextValue("BagsOfMany.show_bags_without_inventory_open", show_bags_without_inventory_open, false)
    end
end

function draw_inventory_sorting_option(pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local sorting_option_sprite =  "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sorting_by_position.png"
    local sorting_option_tooltip = "$bag_button_sorting_by_position_tooltip"
    if sort_by_time then
        sorting_option_sprite =  "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sorting_by_time.png"
        sorting_option_tooltip = "$bag_button_sorting_by_time_tooltip"
    end
    if GuiImageButton(gui, new_id(), pos_x, pos_y, "", sorting_option_sprite) then
        sort_type_change_flag = true
        option_changed = true
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        GuiText(gui, pos_x + 14, pos_y, GameTextGet(sorting_option_tooltip))
    end
end

function draw_inventory_sorting_direction(pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local sorting_direction_sprite =  "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sort_desc.png"
    local sorting_direction_tooltip = "$bag_button_tooltip_desc_sort"
    if sorting_order then
        sorting_direction_sprite =  "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_sort_asc.png"
        sorting_direction_tooltip = "$bag_button_tooltip_asc_sort"
    end
    if GuiImageButton(gui, new_id(), pos_x, pos_y, "", sorting_direction_sprite) then
        sort_order_change_flag = true
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        GuiText(gui, pos_x + 14, pos_y, GameTextGet(sorting_direction_tooltip))
    end
end

function draw_inventory_drop_button(bag, pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local l_clk, r_clk = GuiImageButton(gui, new_id(), pos_x, pos_y, "", dropping_button_sprite)
    if l_clk then
        if dropping_button_sprite == drop_orderly then
            drop_all_inventory(bag, true)
        else
            drop_all_inventory(bag, false)
        end
    elseif r_clk then
        if dropping_button_sprite == "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_drop_orderly.png" then
            dropping_button_sprite = drop_no_order
        else
            dropping_button_sprite = drop_orderly
        end
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        local text = "$bag_button_tooltip_drop"
        if dropping_button_sprite == "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_drop_orderly.png" then
            text = "$bag_button_tooltip_drop_orderly"
        end
        GuiText(gui, pos_x + 14, pos_y, GameTextGet(text))
        GuiText(gui, pos_x + 14, pos_y + 10, GameTextGet("$bag_button_tooltip_drop_type"))
    end
end

function draw_inventory_multiple_depth_button(pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    local order_sprite = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_multi_depth_display.png"
    if not keep_tooltip_open then
        order_sprite = "mods/bags_of_many/files/ui_gfx/inventory/bag_gui_button_one_depth_display.png"
    end
    if GuiImageButton(gui, new_id(), pos_x, pos_y, "", order_sprite) then
        keep_tooltip_open = not keep_tooltip_open
        ModSettingSetNextValue("BagsOfMany.keep_tooltip_open", keep_tooltip_open, false)
    end
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        local txt_hovered = "$bag_button_tooltip_right_click_on"
        if not keep_tooltip_open then
            txt_hovered = "$bag_button_tooltip_right_click_off"
        end
        GuiText(gui, pos_x + 14, pos_y, GameTextGet(txt_hovered))
    end
end

function generate_tooltip(item)
    local tooltip
    -- Spell tooltip
    if EntityHasTag(item, "card_action") then
        local action_id = get_spell_action_id(item)
        if action_id then
            if bags_mod_state.lookup_spells[action_id] ~= nil then
                local name = bags_mod_state.lookup_spells[action_id].name
                if name then
                    tooltip = name
                end
            else
                tooltip = action_id
            end
        end
    elseif EntityHasTag(item, "potion") then
        local material = get_potion_content(item)
        if material then
            tooltip = string.upper(GameTextGet(material.name)) .. " " .. "POTION" .. " ( " .. material.amount .. "% FULL )"
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

function draw_tooltip(item, pos_x, pos_y, level)
    pos_x = pos_x + (5 * (level - 1))
    local tooltip = generate_tooltip(item)
    if tooltip and not is_bag(item) and (EntityHasTag(item, "potion") or EntityHasTag(item, "card_action") or EntityHasTag(item, "item_pickup")) then
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
        GuiZSetForNextWidget(gui, 1)
        GuiEndAutoBoxNinePiece(gui)
    elseif EntityHasTag(item,"wand") then
        local tooltip_x = pos_x
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
        if spell_tooltip_size_x < text_width then
            spell_tooltip_size_x = text_width
        end
        spell_tooltip_size_y = spell_tooltip_size_y + text_height
        draw_background_box(gui, tooltip_x, tooltip_y, 4, spell_tooltip_size_x, spell_tooltip_size_y, 8, 10, 10, 8)
        tooltip_y = tooltip_y + text_height
        local alpha = 1
        for i = 1, wand_capacity do
            -- Spell background
            local background_pos_x = tooltip_x+(20*((i-1)%spells_per_line))
            local background_pos_y = tooltip_y+(math.floor((i-1)/spells_per_line)*20)
            GuiZSetForNextWidget(gui, 3)
            GuiImage(gui, new_id(), background_pos_x, background_pos_y, "mods/bags_of_many/files/ui_gfx/inventory/inventory_box_inactive_overlay.png", alpha, 1, 1)
            -- Spell sprite
            if wand_spells and wand_spells[i] then
                local spell_sprite = get_sprite_file(wand_spells[i])
                if spell_sprite then
                    GuiZSetForNextWidget(gui, 1)
                    GuiImage(gui, new_id(), background_pos_x+2, background_pos_y+2, spell_sprite, alpha, 1, 1)
                    draw_action_type(wand_spells[i], background_pos_x, background_pos_y, 2, alpha)
                end
            end
        end
    end
end

function draw_action_type(entity, pos_x, pos_y, pos_z, alpha)
    local sprite = get_spell_type_sprite(entity)
    if sprite then
        GuiZSetForNextWidget(gui, pos_z)
        GuiImage(gui, new_id(), pos_x, pos_y, sprite, alpha, 1, 1)
    end
end

function inventory_slot(gui, pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui, pos_z)
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
    GuiImage(gui, new_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/inventory/full_inventory_box.png", bag_ui_alpha, 1, 1)
end

function inventory(gui, size, item_per_line, pos_x, pos_y, pos_z)
    local positions_x = {}
    local positions_y = {}
    for i = 0, size - 1 do
        local pos_in_line = i%(item_per_line)
        local x = pos_x + (pos_in_line * 20)
        local y = pos_y + (math.floor(i/item_per_line) * 27)
        table.insert(positions_x, x)
        table.insert(positions_y, y)
        inventory_slot(gui, x, y, pos_z)

        -- only 1
        if (pos_in_line == 0 and i == size-1) or (pos_in_line == 0 and pos_in_line == item_per_line-1) then
            draw_left_bracket(gui, new_id(), x, y, pos_z + 1)
            draw_middle(gui, new_id(), x, y, pos_z + 1)
            draw_right_bracket(gui, new_id(), x, y, pos_z + 1)
        -- 1 and more
        elseif pos_in_line == 0 then
            draw_left_bracket(gui, new_id(), x, y, pos_z + 1)
            draw_middle(gui, new_id(), x, y, pos_z + 1)
        -- last for line
        elseif pos_in_line == item_per_line-1 then
            draw_middle(gui, new_id(), x, y, pos_z + 1)
            draw_right_bracket(gui, new_id(), x, y, pos_z + 1)
        -- middle end
        elseif i == size-1 then
            draw_middle(gui, new_id(), x, y, pos_z + 1)
            draw_right_bracket(gui, new_id(), x, y, pos_z + 1)
        -- middle
        else
            draw_middle(gui, new_id(), x, y, pos_z + 1)
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
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_mana_max.png", "Mana max", string.format("%.0f", wand.mana_max))
    draw_width_sum, draw_height_sum = add_to_sum_width(draw_width_sum, draw_height_sum, draw_width, draw_height)
    draw_width, draw_height = draw_info_line(pos_x, pos_y + draw_height_sum, "data/ui_gfx/inventory/icon_mana_charge_speed.png", "Mana chg. Spd", string.format("%.0f", wand.mana_charge_speed))
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
        GuiZSetForNextWidget(gui, 1)
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

function setup_inventory_options_buttons(bag, level, pos_x, pos_y, pos_z)
    local nb_button = 0
    local length = 2
    local size = 13
    local direction = "column"
    if ModSettingGet("BagsOfMany.show_drop_all_inventory_button") then
        local pos_x_button, pos_y_button = calculate_grid_position(length, size, size, direction, nb_button)
        nb_button = nb_button + 1
        draw_inventory_drop_button(bag, pos_x + pos_x_button, pos_y + pos_y_button, pos_z)
    end
    if level == 1 and ModSettingGet("BagsOfMany.show_change_sorting_direction_button") then
        local pos_x_button, pos_y_button = calculate_grid_position(length, size, size, direction, nb_button)
        nb_button = nb_button + 1
        draw_inventory_multiple_depth_button(pos_x + pos_x_button, pos_y + pos_y_button, pos_z)
    end
    if ModSettingGet("BagsOfMany.show_change_sorting_direction_button") then
        local pos_x_button, pos_y_button = calculate_grid_position(length, size, size, direction, nb_button)
        nb_button = nb_button + 1
        draw_inventory_sorting_option(pos_x + pos_x_button, pos_y + pos_y_button, pos_z)
    end
    if sort_by_time and ModSettingGet("BagsOfMany.show_change_sorting_direction_button") then
        local pos_x_button, pos_y_button = calculate_grid_position(length, size, size, direction, nb_button)
        nb_button = nb_button + 1
        draw_inventory_sorting_direction(pos_x + pos_x_button, pos_y + pos_y_button, pos_z)
    end
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

function add_potion_color(entity)
    local potion_color = GameGetPotionColorUint(entity)
    if potion_color ~= 0 then
        local b = bit.rshift(bit.band(potion_color, 0xFF0000), 16) / 0xFF
        local g = bit.rshift(bit.band(potion_color, 0xFF00), 8) / 0xFF
        local r = bit.band(potion_color, 0xFF) / 0xFF
        GuiColorSetForNextWidget(gui, r, g, b, 1)
    end
end

function add_item_specifity(entity, x, y, z)
    -- Draw the item
    if EntityHasTag(entity, "card_action") then
        --Draw the action type if its a spell
        draw_action_type(entity, x - 2, y - 2, z, 1)
    elseif EntityHasTag(entity, "potion") then
        -- Add the color to the potion sprite
        add_potion_color(entity)
    end
end