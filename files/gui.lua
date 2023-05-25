dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
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

current_id = 1
local function new_id()
    current_id = current_id + 1
    return current_id
end
local function reset_id()
    current_id = 1
end

function padding_to_center(width_box, height_box, width_entity, height_entity)
    return math.ceil((width_box - width_entity)/2), math.ceil((height_box - height_entity)/2)
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
        draw_inventory_button(gui)
    end

    -- Setup the inventory and its content
    if inventory_open and is_bag(active_item) and open then
        draw_inventory_bag(gui, active_item)
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

function draw_inventory_button(gui)
    if not button_locked then
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
    local gui_button_image = "mods/bags_of_many/files/ui_gfx/bag_gui_button_closed.png"
    if open then
        gui_button_image = "mods/bags_of_many/files/ui_gfx/bag_gui_button_open.png"
    end
    GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, bag_ui_alpha)
    if GuiImageButton(gui, new_id(), button_pos_x, button_pos_y, "", gui_button_image) then
        open = not open
        GlobalsSetValue("BagsOfMany_is_open", open and 1 or 0)
    end
    local _, _, hovered, x, y, draw_width, draw_height, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
    if hovered then
        if not open then
            GuiText(gui, button_pos_x, button_pos_y + 20, GameTextGet("$bag_button_tooltip_closed"))
        else
            GuiText(gui, button_pos_x, button_pos_y + 20, GameTextGet("$bag_button_tooltip_opened"))
        end
    end
end

function generate_tooltip(gui, item)
    local tooltip
    -- Spell tooltip
    if EntityHasTag(item, "card_action") then
        local item_action_component = EntityGetComponentIncludingDisabled(item, "ItemActionComponent")
        if item_action_component then
            local action_id = ComponentGetValue2(item_action_component[1], "action_id")
            tooltip = action_id
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
        local tooltip_x = pos_x
        local tooltip_y = pos_y+25
        local spells_per_line = 12
        local wand_capacity = EntityGetWandCapacity(item)
        for i = 1, wand_capacity do
            local background_pos_x = tooltip_x+(20*((i-1)%spells_per_line))
            local background_pos_y = tooltip_y+(math.floor((i-1)/spells_per_line)*20)
            GuiZSetForNextWidget(gui, 11)
            GuiImage(gui, new_id(), background_pos_x, background_pos_y, "mods/bags_of_many/files/ui_gfx/full_inventory_box.png", 1, 1, 1)
            i = i + 1
        end
        local wand_spells = EntityGetAllChildren(item)
        for i = 1, #wand_spells do
            local background_pos_x = tooltip_x+(20*((i-1)%spells_per_line))
            local background_pos_y = tooltip_y+(math.floor((i-1)/spells_per_line)*20)
            local spell_sprite = get_sprite_file(wand_spells[i])
            if spell_sprite then
                GuiZSetForNextWidget(gui, 10)
                GuiImage(gui, new_id(), background_pos_x+2, background_pos_y+2, spell_sprite, 1, 1, 1)
            end
        end
    end
end

function draw_inventory_bag(gui, active_item)
    local stored_items = get_bag_inventory_items(active_item)
    local qt_of_storage = get_bag_inventory_size(active_item)
    local item_per_line = tonumber(bag_wrap_number)
    if not item_per_line then
        item_per_line = 10
    end
    local positions = inventory(gui, qt_of_storage, item_per_line, button_pos_x + 25, button_pos_y - 2.5)
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
                GuiOptionsAddForNextWidget(gui, GUI_OPTION.IsExtraDraggable)
                if GuiImageButton(gui, new_id(), item_pos_x, item_pos_y, "", sprite_path) then
                    EntityRemoveFromParent(item)
                    local x, y = EntityGetTransform(active_item)
                    EntityApplyTransform(item, x, y)
                    show_entity(item)
                end
                local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
                
                draw_tooltip(gui, item, hovered, tooltip, storage_cell_x, storage_cell_y)
            end
        end
        i = i + 1
    end
end

function has_moved_threshold(gui, thresh_x, thresh_y, init_x, init_y)
    local _, _, _, _, _, _, _, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui)
    return ((init_x - draw_x) > thresh_x or (init_y - draw_y) > thresh_y)
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