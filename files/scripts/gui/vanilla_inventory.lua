function reset_vanilla_capture_vars()
    vanilla_inventory_table.inventory_type = 0
    vanilla_inventory_table.hovering = false
    vanilla_inventory_table.hovering_spot = nil
    vanilla_inventory_table.hovering_spot_level = nil
end

---@param gui userdata
function draw_vanilla_inventory_v2(gui)
    reset_vanilla_capture_vars()
    local UI_BARS_POS_X = tonumber(MagicNumbersGetValue("UI_BARS_POS_X"))
    local UI_BARS_POS_Y = tonumber(MagicNumbersGetValue("UI_BARS_POS_Y"))
    local UI_FULL_INVENTORY_OFFSET_X = tonumber(MagicNumbersGetValue("UI_FULL_INVENTORY_OFFSET_X"))
    if UI_BARS_POS_X ~= nil and UI_BARS_POS_Y ~= nil and UI_FULL_INVENTORY_OFFSET_X ~= nil then
        if is_inventory_open() then
            draw_vanilla_inventory_capture(gui, UI_BARS_POS_X - 1, UI_BARS_POS_Y, 1)
            draw_vanilla_spell_inventory_capture(gui, UI_FULL_INVENTORY_OFFSET_X + UI_BARS_POS_X, UI_BARS_POS_Y, 1)
            local player = get_player()
            if player then
                local is_colliding = CheckEntityCollideWithWorkshop(player)
                local tinker_points = EntityTinkerPoints(player)
                if is_colliding then
                    tinker_points = tinker_points + 1
                end
                if tinker_points > 0 then
                    draw_vanilla_wand_inventory_capture(gui, 0, 0, 1)
                end
            end
        end
    else
        print_error("Bags of Many: UI_BARS_POS_X or UI_BARS_POS_Y is nil. Please check your MagicNumbers settings.")
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
function draw_vanilla_inventory_capture(gui, pos_x, pos_y, pos_z)
    local vanilla_items = get_player_inventory_quick_table()
    if vanilla_items then
        for i = 0, 7 do
            if i == 4 then
                pos_x = pos_x + 1
            end
            detect_vanilla_inventory_mouse_input(gui, pos_x + (20 * i), pos_y, pos_z, vanilla_items[i], i)
        end
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
function draw_vanilla_wand_inventory_capture(gui, pos_x, pos_y, pos_z)
    local wands = get_player_inventory_wand_table()
    if wands then
        local sprite_added_padding = 0
        local wands_found = 0
        for i = 0, 3 do
            if wands[i] then
                local wand_offset_y = 48 + (63 * wands_found) + sprite_added_padding
                local wand_sprite = get_sprite_file(wands[i])
                if wand_sprite then
                    local _, sprite_size_y = GuiGetImageDimensions(gui, wand_sprite)
                    local sprite_padding = ((sprite_size_y-8)*2)
                    sprite_added_padding = sprite_added_padding + sprite_padding
                    local wands_spell_pos = 33 + sprite_padding
                    detect_vanilla_wand_inventory_mouse_inputV2(gui, pos_x + 25, pos_y + wand_offset_y + wands_spell_pos, pos_z, wands[i], 1)
                end
                wands_found = wands_found + 1
            end
        end
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
function draw_vanilla_spell_inventory_capture(gui, pos_x, pos_y, pos_z)
    local vanilla_spells = get_player_inventory_full_table()
    local x, y = get_inventory_spell_size()
    if vanilla_spells then        
        for i = 0, (x * y) - 1 do
            detect_vanilla_spell_inventory_mouse_input(gui, pos_x + (20 * ((i)%x)), pos_y + (math.floor((i)/x)* 20), pos_z, vanilla_spells[i], i - (x *math.floor((i)/x)), math.floor((i)/x))
        end
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param item integer
---@param inv_spot number
function detect_vanilla_wand_inventory_mouse_inputV2(gui, pos_x, pos_y, pos_z, item, inv_spot)
    if not item or not is_wand(item) then
        return
    end
    local all_spells = EntityGetAllChildren(item)
    local wand_capacity = EntityGetWandCapacity(item)
    local normal_spells = {}
    local permanent_spells = {}
    for _, spell in ipairs(all_spells or {}) do
        -- removing always cast spells from the detection
        if is_spell_permanently_attached(spell) then
            table.insert(permanent_spells, spell)
        else
            -- account for the possiblity that spells are not contiguous in the wand
            local spell_pos = get_item_inventory_slot(spell)
            table.insert(normal_spells, spell_pos + 1, spell)
        end
    end

    for i = 1, wand_capacity do
        local spell
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
        GuiZSetForNextWidget(gui, pos_z)
        GuiImageButton(gui, bags_of_many_new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
        if normal_spells[i] then
            spell = normal_spells[i]
        end
        local _, _, hover = GuiGetPreviousWidgetInfo(gui)
        if hover then
            vanilla_inventory_table.inventory_type = 3
            vanilla_inventory_table.hovering = true
            vanilla_inventory_table.hovering_spot = i - 1
            vanilla_inventory_table.hovering_spot_level = item
            -- mod dragging display ish
            if dragged_item_table.item and not vanilla_inventory_table.quick.widget_item then
                local should_display_hover_anim = false
                if is_spell(dragged_item_table.item) then
                    should_display_hover_anim = true
                end
                if should_display_hover_anim then
                    GuiZSetForNextWidget(gui, 1)
                    GuiImage(gui, bags_of_many_new_id(), pos_x - 1, pos_y - 1, "mods/bags_of_many/files/ui_gfx/full_inventory_box_highlight.png", 1, 1.1)
                end
            end
        end
        if spell and hover and InputIsMouseButtonJustDown(1) then
            -- SHIFT CLICK SWAP
            if InputIsKeyDown(225) and active_item_bag ~= nil then
                shift_clicked = true
                add_item_shift_click(active_item_bag, spell)
            end

            dragged_item_table.item = spell
            dragged_item_table.bag = item
            vanilla_inventory_table.quick.widget_item = spell
            vanilla_inventory_table.quick.frame_click = GameGetFrameNum()
        end
        if spell and not is_inventory_open() and InputIsMouseButtonDown(1) and vanilla_inventory_table.quick.widget_item then
            local player_control_comp = get_player_control_component()
            if player_control_comp then
                local sprite = get_sprite_file(vanilla_inventory_table.quick.widget_item)
                local mouse_x, mouse_y = ComponentGetValue2(player_control_comp, "mMousePositionRaw")
                if mouse_x and mouse_y and sprite then
                    local sprite_size_x, sprite_size_y = GuiGetImageDimensions(gui, sprite)
                    local offset_x, offset_y = padding_to_center(20, 20, sprite_size_x, sprite_size_y)
                    GuiZSetForNextWidget(gui, 1)
                    if is_potion(vanilla_inventory_table.quick.widget_item) then
                        add_potion_color(gui, vanilla_inventory_table.quick.widget_item)
                    end
                    GuiImage(gui, bags_of_many_new_id(), mouse_x/2 + offset_x, mouse_y/2 + offset_y, sprite, 1, 1)
                end
            end
        end
        pos_x = pos_x + 20
        inv_spot = inv_spot + 1
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param item integer
---@param inv_spot number
---@param level number
function detect_vanilla_spell_inventory_mouse_input(gui, pos_x, pos_y, pos_z, item, inv_spot, level)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImageButton(gui, bags_of_many_new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
    local _, _, hover = GuiGetPreviousWidgetInfo(gui)
    if hover then
        vanilla_inventory_table.inventory_type = 2
        vanilla_inventory_table.hovering = true
        vanilla_inventory_table.hovering_spot = inv_spot
        vanilla_inventory_table.hovering_spot_level = level
        -- mod dragging display ish
        if dragged_item_table.item and not vanilla_inventory_table.quick.widget_item then
            local should_display_hover_anim = false
            if is_spell(dragged_item_table.item) then
                should_display_hover_anim = true
            end
            if should_display_hover_anim then
                GuiZSetForNextWidget(gui, 1)
                GuiImage(gui, bags_of_many_new_id(), pos_x - 1, pos_y - 1, "mods/bags_of_many/files/ui_gfx/full_inventory_box_highlight.png", 1, 1.1)
            end
        end
    end
    if item and hover and InputIsMouseButtonJustDown(1) then
        -- SHIFT CLICK SWAP
        if InputIsKeyDown(225) and active_item_bag ~= nil then
            shift_clicked = true
            add_item_shift_click(active_item_bag, item)
        end
        -- JUST USED FOR THE HOVER ANIMATION
        dragged_item_table.item = item
        dragged_item_table.bag = EntityGetParent(item)
        vanilla_inventory_table.quick.widget_item = item
        vanilla_inventory_table.quick.frame_click = GameGetFrameNum()
    end
    if item and not is_inventory_open() and InputIsMouseButtonDown(1) and vanilla_inventory_table.quick.widget_item then
        local player_control_comp = get_player_control_component()
        if player_control_comp then
            local sprite = get_sprite_file(vanilla_inventory_table.quick.widget_item)
            local mouse_x, mouse_y = ComponentGetValue2(player_control_comp, "mMousePositionRaw")
            if mouse_x and mouse_y and sprite then
                local sprite_size_x, sprite_size_y = GuiGetImageDimensions(gui, sprite)
                local offset_x, offset_y = padding_to_center(20, 20, sprite_size_x, sprite_size_y)
                GuiZSetForNextWidget(gui, 1)
                if is_potion(vanilla_inventory_table.quick.widget_item) then
                    add_potion_color(gui, vanilla_inventory_table.quick.widget_item)
                end
                GuiImage(gui, bags_of_many_new_id(), mouse_x/2 + offset_x, mouse_y/2 + offset_y, sprite, 1, 1)
            end
        end
    end
end

---@param gui userdata
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param item integer
---@param inv_spot number
function detect_vanilla_inventory_mouse_input(gui, pos_x, pos_y, pos_z, item, inv_spot)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImageButton(gui, bags_of_many_new_id(), pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/inventory/box/invisible20x20.png")
    local _, _, hover = GuiGetPreviousWidgetInfo(gui)
    if hover then
        vanilla_inventory_table.inventory_type = 1
        vanilla_inventory_table.hovering = true
        vanilla_inventory_table.hovering_spot = inv_spot
        -- mod dragging display ish
        if dragged_item_table.item and not vanilla_inventory_table.quick.widget_item then
            local should_display_hover_anim = true
            if is_item(dragged_item_table.item) and vanilla_inventory_table.hovering_spot <= 3 then
                should_display_hover_anim = false
            elseif is_wand(dragged_item_table.item) and vanilla_inventory_table.hovering_spot >= 4 then
                should_display_hover_anim = false
            elseif is_spell(dragged_item_table.item) then
                should_display_hover_anim = false
            end
            if should_display_hover_anim then
                GuiZSetForNextWidget(gui, 1)
                GuiImage(gui, bags_of_many_new_id(), pos_x - 1, pos_y - 1, "mods/bags_of_many/files/ui_gfx/full_inventory_box_highlight.png", 1, 1.1)
            end
        end
    end
    if item and hover and InputIsMouseButtonJustDown(1) then
        -- SHIFT CLICK SWAP
        if InputIsKeyDown(225) and active_item_bag ~= nil then
            swap_frame = GameGetFrameNum()
            close_inventory_gui_vanilla()
            shift_clicked = true
            add_item_shift_click(active_item_bag, item)
        end
        -- JUST USED FOR THE HOVER ANIMATION
        dragged_item_table.item = item

        vanilla_inventory_table.quick.widget_item = item
        vanilla_inventory_table.quick.frame_click = GameGetFrameNum()
    end
    if item and not is_inventory_open() and InputIsMouseButtonDown(1) and vanilla_inventory_table.quick.widget_item then
        local player_control_comp = get_player_control_component()
        if player_control_comp then
            local sprite = get_sprite_file(vanilla_inventory_table.quick.widget_item)
            local mouse_x, mouse_y = ComponentGetValue2(player_control_comp, "mMousePositionRaw")
            if mouse_x and mouse_y and sprite then
                local sprite_size_x, sprite_size_y = GuiGetImageDimensions(gui, sprite)
                local offset_x, offset_y = padding_to_center(20, 20, sprite_size_x, sprite_size_y)
                GuiZSetForNextWidget(gui, 1)
                if is_potion(vanilla_inventory_table.quick.widget_item) then
                    add_potion_color(gui, vanilla_inventory_table.quick.widget_item)
                end
                GuiImage(gui, bags_of_many_new_id(), mouse_x/2 + offset_x, mouse_y/2 + offset_y, sprite, 1, 1)
            end
        end
    end
end

function detect_vanilla_inventory_mouse_release()
    if InputIsMouseButtonJustUp(1) and vanilla_inventory_table.quick.widget_item then
        if not vanilla_inventory_table.hovering then
            vanilla_inventory_table.quick.frame_release = GameGetFrameNum()
            dragging_possible_swap = true
            dragged_item_table.item = vanilla_inventory_table.quick.widget_item
        else
            -- Reset variables
            reset_table(dragged_item_table)
            vanilla_inventory_table.quick.widget_item = nil
            vanilla_inventory_table.quick.frame_release = 0
        end
    end
end