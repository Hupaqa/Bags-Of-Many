function last_widget_is_being_hovered(gui)
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    return hovered
end

function last_widget_is_left_clicked(gui)
    local left_click = GuiGetPreviousWidgetInfo(gui)
    return left_click
end

function last_widget_is_right_clicked(gui)
    local left_click = GuiGetPreviousWidgetInfo(gui)
    return left_click
end

function last_widget_size(gui)
    local _, _, _, _, _, width, height = GuiGetPreviousWidgetInfo(gui)
    return width, height
end

function last_widget_position(gui)
    local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
    return x, y
end

function draw_background_box(gui, pos_x, pos_y, pos_z, size_x, size_y, pad_top, pad_right, pad_bottom, pad_left)
    size_x = size_x - 1
    size_y = size_y - 1

    if pad_top and (not pad_right and not pad_bottom and not pad_left) then
        pad_right = pad_top
        pad_bottom = pad_top
        pad_left = pad_top
    elseif pad_top and pad_right and (not pad_bottom and not pad_left) then
        pad_bottom = pad_top
        pad_left = pad_right
    elseif not pad_left then
        pad_left = pad_right
    end

    ---- CORNERS
    -- TOP LEFT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x - 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y + pad_bottom + size_y - 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM RIGHT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)

    ---- MIDDLE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/middle_piece.png", 0.99, size_x + pad_left + pad_right - 1, size_y + pad_top + pad_bottom - 1)

    ---- BORDERS
    -- TOP BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
    -- LEFT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- RIGHT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + size_x + pad_right, pos_y - pad_top + 2, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- BOTTOM BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 2, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
end

function auto_draw_background_box(gui, pos_z, pad_top, pad_right, pad_bottom, pad_left)
    local _, _, _, pos_x, pos_y, size_x, size_y = GuiGetPreviousWidgetInfo(gui)
    size_x = size_x - 1
    size_y = size_y - 1

    if pad_top and (not pad_right and not pad_bottom and not pad_left) then
        pad_right = pad_top
        pad_bottom = pad_top
        pad_left = pad_top
    elseif pad_top and pad_right and (not pad_bottom and not pad_left) then
        pad_bottom = pad_top
        pad_left = pad_right
    elseif not pad_left then
        pad_left = pad_right
    end

    ---- CORNERS
    -- TOP LEFT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x - 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- TOP RIGHT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER ONE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y + pad_bottom + size_y - 1, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM LEFT CORNER TWO
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)
    -- BOTTOM RIGHT CORNER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + pad_right + size_x, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/corner_piece.png", 1, 1, 1)

    ---- MIDDLE
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/middle_piece.png", 0.99, size_x + pad_left + pad_right - 1, size_y + pad_top + pad_bottom - 1)

    ---- BORDERS
    -- TOP BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 1, pos_y - pad_top, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
    -- LEFT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left, pos_y - pad_top + 1, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- RIGHT BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x + size_x + pad_right, pos_y - pad_top + 2, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, 1, size_y + pad_top + pad_bottom - 2)
    -- BOTTOM BORDER
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, bags_of_many_new_id(), pos_x - pad_left + 2, pos_y + pad_bottom + size_y, "mods/bags_of_many/files/ui_gfx/inventory/box/border_piece.png", 1, size_x + pad_left + pad_right - 2, 1)
end

function draw_background_click_capture(gui, pos_x, pos_y, pos_z, size_x, size_y)
    GuiZSetForNextWidget(gui, pos_z)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoPositionTween)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.ClickCancelsDoubleClick)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.NoSound)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.DrawNoHoverAnimation)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.AlwaysClickable)
    GuiImage(gui, bags_of_many_new_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_click_prevention.png", 1, size_x, size_y)
    return GuiGetPreviousWidgetInfo(gui)
end

function is_xml_sprite_file(entity_id)
    if entity_id then
        local item_component = EntityGetComponentIncludingDisabled(entity_id, "SpriteComponent")
        if item_component then
            local sprite = ComponentGetValue2(item_component[1], "image_file")
            if string_contains(sprite, ".xml") then
                return true
            end
        end
    end
    return false
end

function extract_png_file_from_xml(xml_file)
    if xml_file then
        if not bags_mod_state.is_file_exist(xml_file) then
            return
        end
        if  bags_mod_state.xml_file_png and bags_mod_state.xml_file_png[xml_file] then
            return bags_mod_state.xml_file_png[xml_file]
        end
        local file_content = bags_mod_state.get_file_content(xml_file)
        if file_content then
            local file_png_with_apostrophe = string.match(file_content, '%".+%.png%"')
            if file_png_with_apostrophe then
                local file_png = string.gsub(file_png_with_apostrophe, '"', "")
                bags_mod_state.xml_file_png[xml_file] = file_png
                return file_png
            end
        end
    end
end
