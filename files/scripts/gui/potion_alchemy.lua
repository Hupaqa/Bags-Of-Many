--- @param ui_id integer
--- @param pos_x number
--- @param pos_y number
--- @return boolean
--- Draws the alchemy button GUI and returns whether it was clicked or right-clicked.
function draw_alchemy_button_gui(gui_id, ui_id, pos_x, pos_y)
    GuiZSetForNextWidget(gui_id, 1)
    local clicked, right_clicked = GuiImageButton(gui_id, ui_id, pos_x, pos_y, "", "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_button_gui.png")
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui_id)
    if hovered then
        GuiText(gui_id, pos_x, pos_y+15, "$alchemy_table_gui_toggle")
    end
    return clicked or right_clicked
end

---@return boolean
--- Checks if there is a potion in the alchemy table.
function is_potion_in_table()
    return BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item ~= nil or BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item ~= nil or BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item ~= nil
end

---@param item integer
---@return boolean
--- Checks if the specified item is in the alchemy table.
function is_item_in_alchemy_table(item)
    return BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item == item or BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item == item or BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item == item
end

---@return boolean
--- Checks if any material is selected in the alchemy table.
function is_material_in_alchemy_table_selected()
    local left_material_selected = false
    if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item and BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item] then
        for _, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item]) do
            if value then
                left_material_selected = true
                break
            end
        end
    end
    if left_material_selected then
        return true
    end
    local combined_material_selected = false
    if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item and BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item] then
        for _, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item]) do
            if value then
                combined_material_selected = true
                break
            end
        end
    end
    if combined_material_selected then
        return true
    end
    local right_material_selected = false
    if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item and BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item] then
        for _, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item]) do
            if value then
                right_material_selected = true
                break
            end
        end
    end
    if right_material_selected then
        return true
    end
    return false
end

---@return boolean
--- Checks if any potion spots of the potion alchemy table are hovered.
function is_potion_spot_hovered()
    local left_hovered = BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.hovered ~= nil and BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.hovered
    local combined_hovered = BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.hovered ~= nil and BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.hovered
    local right_hovered = BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.hovered ~= nil and BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.hovered
    return (left_hovered ~= nil and combined_hovered ~= nil and right_hovered ~= nil) and (left_hovered or combined_hovered or right_hovered)
end

--- Resets the potion spots tables to their initial state.
--- This function clears the left, combined, and right potion spots in the alchemy table.
function reset_potion_spots_tables()
    reset_table(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy)
    reset_table(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy)
    reset_table(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy)
end

--- Resets the hovered state of the potion spots in the alchemy table.
--- This function clears the hovered state for the left, combined, and right potion spots.
function reset_potion_spots_hovered()
    reset_hovered_table(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy)
    reset_hovered_table(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy)
    reset_hovered_table(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy)
end

---@param hold_spot any
---@param item any
--- Removes the specified item from the hold spot if it matches.
--- Used to move a potion from one spot to another in the alchemy table.
function remove_duplicate_potion_in_spots(hold_spot, item)
    if hold_spot == item then
        hold_spot = nil
    end
end

--- Resets the potion alchemy GUI state.
function clean_potion_gui()
    if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item and not is_player_root_entity(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item) then
        BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item = nil
    end
    if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item and not is_player_root_entity(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item) then
        BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item = nil
    end
    if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item and not is_player_root_entity(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item) then
        BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item = nil
    end
end

--- GUI 

--- @param gui_id userdata
---@param ui_id function
---@param pos_x number
---@param pos_y number
---@param pos_z number
--- Sets up the potion mixing GUI.
function potion_mixing_gui(gui_id, ui_id, pos_x, pos_y, pos_z)
    clean_potion_gui()
    potion_alchemy_spots(gui_id, ui_id, pos_x, pos_y, pos_z)
    potion_alchemy_table(gui_id, ui_id, pos_x, pos_y, pos_z + 1)
end

--- @param gui_id userdata
---@param ui_id function
---@param pos_x number
---@param pos_y number
---@param pos_z number
--- Draws the potion alchemy spots in the GUI.
function potion_alchemy_spots(gui_id, ui_id, pos_x, pos_y, pos_z)
    if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item then
        potion_alchemy_table_content(gui_id, ui_id, BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item, pos_x-130, pos_y+2, pos_z)
    end
    if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item then
        potion_alchemy_table_content(gui_id, ui_id, BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item, pos_x, pos_y+75, pos_z)
    end
    if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item then
        potion_alchemy_table_content(gui_id, ui_id, BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item, pos_x+70, pos_y+2, pos_z)
    end

    potion_unselect_all(gui_id, ui_id, pos_x - 10, pos_y + 13, pos_z)
    potion_alchemy_transfer(gui_id, ui_id, pos_x - 10, pos_y + 24, pos_z)
    potion_alchemy_delete_chosen(gui_id, ui_id, pos_x +50, pos_y + 34, pos_z)
    potion_alchemy_amount_slider(gui_id, ui_id, pos_x - 2, pos_y + 48, pos_z)

    potion_alchemy_left_spot(gui_id, ui_id, pos_x+4, pos_y+8, pos_z)
    potion_alchemy_combined_spot(gui_id, ui_id, pos_x+20, pos_y+11, pos_z)
    potion_alchemy_right_spot(gui_id, ui_id, pos_x+46, pos_y+12, pos_z)
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Draws the potion alchemy table with a move button.
function potion_alchemy_table(gui_id, ui_id, pos_x, pos_y, pos_z)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.NoPositionTween)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.ClickCancelsDoubleClick)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.NoSound)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.IsExtraDraggable)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawNoHoverAnimation)
    GuiZSetForNextWidget(gui_id, 1)
    GuiImageButton(gui_id, ui_id(), pos_x-12, pos_y, "", "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_move_button_invisible.png")
    local _, _, _, _, _, draw_width, draw_height, draw_x, draw_y = GuiGetPreviousWidgetInfo(gui_id)
    local hovered = last_widget_is_being_hovered(gui_id)
    if draw_x ~= 0 and draw_y ~= 0 and draw_x ~= pos_x and draw_y ~= pos_y then
        pos_x = (draw_x - draw_width / 2) + 12
        pos_y = draw_y - draw_height / 2
        bags_mod_state.alchemy_pos_x = pos_x
        bags_mod_state.alchemy_pos_y = pos_y
        ModSettingSetNextValue("BagsOfMany.alchemy_pos_x", pos_x, false)
        ModSettingSetNextValue("BagsOfMany.alchemy_pos_y", pos_y, false)
    elseif hovered then
        GuiZSetForNextWidget(gui_id, 1)
        GuiColorSetForNextWidget(gui_id, 1, 1, 0.2, 1)
        GuiText(gui_id, pos_x + 10, pos_y, GameTextGet("$alchemy_table_move_button"))
        auto_draw_background_box(gui_id, 2, 3, 6)
    end
    GuiZSetForNextWidget(gui_id, 1)
    GuiImage(gui_id, ui_id(), pos_x-12, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_move_button.png", 1, 1)
    GuiZSetForNextWidget(gui_id, pos_z + 4)
    GuiImage(gui_id, ui_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_table.png", 1, 1 ,1)
    GuiZSetForNextWidget(gui_id, pos_z + 5)
    GuiImage(gui_id, ui_id(), pos_x -3, pos_y - 3, "mods/bags_of_many/files/ui_gfx/potion_mixing/alchemy_table_background.png", 1, 1)
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Draws the left potion spot in the alchemy table.
function potion_alchemy_left_spot(gui_id, ui_id, pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui_id, pos_z - 1)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.NoPositionTween)
    GuiImage(gui_id, ui_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_left_number.png", 1, 1 ,1)
    local potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_empty_spot.png"
    if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item then
        add_potion_color(gui_id, BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item)
        if is_potion(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion.png"
        elseif is_powder_stash(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/material_pouch.png"
            pos_x = pos_x - 2
            pos_y = pos_y - 2
        end
    else
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawNoHoverAnimation)
    end
    if BAGS_OF_MANY_GUI_STATES.dragged_item_table.item and is_potion(BAGS_OF_MANY_GUI_STATES.dragged_item_table.item) then
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawWobble)
    end
    GuiZSetForNextWidget(gui_id, pos_z)
    local left_spot_rc, left_spot_lc = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", potion_sprite)
    local left_hovered = last_widget_is_being_hovered(gui_id)
    if left_spot_lc or left_spot_rc then
        BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item = nil
    end
    if left_hovered and not dragging_possible_swap then
        reset_potion_spots_hovered()
        BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.hovered = true
    end
end

--- @param gui_id userdata
--- @param ui_id function
---@param pos_x number
---@param pos_y number
---@param pos_z number
--- Draws the combined potion spot in the alchemy table.
function potion_alchemy_combined_spot(gui_id, ui_id, pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui_id, pos_z - 1)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.NoPositionTween)
    GuiImage(gui_id, ui_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_combined_number.png", 1, 1 ,1)
    local potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_empty_spot.png"
    if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item then
        add_potion_color(gui_id, BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item)
        if is_potion(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion.png"
        elseif is_powder_stash(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/material_pouch.png"
            pos_x = pos_x - 2
            pos_y = pos_y - 2
        end
    else
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawNoHoverAnimation)
    end
    if BAGS_OF_MANY_GUI_STATES.dragged_item_table.item and is_potion(BAGS_OF_MANY_GUI_STATES.dragged_item_table.item) then
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawWobble)
    end
    GuiZSetForNextWidget(gui_id, pos_z)
    local combined_spot_rc, combined_spot_lc = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", potion_sprite)
    local combined_hovered = last_widget_is_being_hovered(gui_id)
    if combined_spot_lc or combined_spot_rc then
        BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item = nil
    end
    if combined_hovered and not dragging_possible_swap then
        reset_potion_spots_hovered()
        BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.hovered = true
    end
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Draws the right potion spot in the alchemy table.
function potion_alchemy_right_spot(gui_id, ui_id,pos_x, pos_y, pos_z)
    GuiZSetForNextWidget(gui_id, pos_z - 1)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.NoPositionTween)
    GuiImage(gui_id, ui_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_right_number.png", 1, 1 ,1)
    local potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion_empty_spot.png"
    if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item then
        add_potion_color(gui_id, BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item)
        if is_potion(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/potion.png"
        elseif is_powder_stash(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item) then
            potion_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/material_pouch.png"
            pos_x = pos_x - 2
            pos_y = pos_y - 2
        end
    else
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawNoHoverAnimation)
    end
    if BAGS_OF_MANY_GUI_STATES.dragged_item_table.item and is_potion(BAGS_OF_MANY_GUI_STATES.dragged_item_table.item) then
        GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawWobble)
    end
    GuiZSetForNextWidget(gui_id, pos_z)
    local right_spot_rc, right_spot_lc = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", potion_sprite)
    if right_spot_lc or right_spot_rc then
        BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item = nil
    end
    local right_hovered = last_widget_is_being_hovered(gui_id)
    if right_hovered and not dragging_possible_swap then
        reset_potion_spots_hovered()
        BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.hovered = true
    end
end

--- @param gui_id userdata
--- @param ui_id function
---@param potion number
---@param pos_x number
---@param pos_y number
---@param pos_z number
--- Draws the content of the potion alchemy table, allowing material selection.
function potion_alchemy_table_content(gui_id, ui_id, potion, pos_x, pos_y, pos_z)
    local materials = get_potion_contents(potion)
    if materials and #materials > 0 then
        local height = 48
        if #materials < 4 then
            height = #materials * 12
        end
        GuiBeginScrollContainer(gui_id, ui_id(), pos_x, pos_y, 100, height, true, 3, 3)
        local position_y = 0
        for i = 1, #materials do
            local game_text = GameTextGet(materials[i].name)
            local potion_content_button_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/button_unchecked.png"
            if BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion] and BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion][materials[i].id] then
                potion_content_button_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/button_checked.png"
            end
            GuiZSetForNextWidget(gui_id, 2)
            local left_click, right_click = GuiImageButton(gui_id, ui_id(), 0, position_y, "", potion_content_button_sprite)
            if left_click or right_click then
                if not BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion] then
                    BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion] = {}
                end
                if BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion][materials[i].id] then
                    BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion][materials[i].id] = false
                else
                    BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[potion][materials[i].id] = true
                end
            end
            GuiText(gui_id, 12, position_y, string.format("%.2f", materials[i].amount) .. "% " .. string.upper(game_text:sub(1,1)) .. game_text:sub(2, #game_text))
            position_y = position_y + 12
        end
        GuiEndScrollContainer(gui_id)
        draw_background_click_capture(gui_id, pos_x, pos_y, pos_z + 1, 100 + 6, height + 6)
    end
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Deletes the selected potion contents in the alchemy table.
--- This function checks if any potion contents are selected and deletes them based on the specified amount.
function potion_alchemy_delete_chosen(gui_id, ui_id, pos_x, pos_y, pos_z)
    local delete_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/thrashcan_disabled.png"
    if is_material_in_alchemy_table_selected() then
        delete_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/thrashcan.png"
    end
    GuiZSetForNextWidget(gui_id, 3)
    GuiOptionsAddForNextWidget(gui_id, GUI_OPTION.DrawNoHoverAnimation)
    local left_click, right_click = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", delete_sprite)
    local hover = last_widget_is_being_hovered(gui_id)
    if hover then
        GuiZSetForNextWidget(gui_id, 1)
        GuiColorSetForNextWidget(gui_id, 1, 0.2, 0.2, 1)
        GuiText(gui_id, pos_x + 20, pos_y, GameTextGet("$alchemy_table_delete_button").." ("..tostring(bags_mod_state.alchemy_amount_transfered/10).."%)")
        auto_draw_background_box(gui_id, 2, 3, 6)
    end
    if left_click or right_click then
        if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item then
            if BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item] then
                for index, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item]) do
                    if value then
                        local amount_left = delete_potion_specific_content_quantity(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item, index, bags_mod_state.alchemy_amount_transfered)
                        if amount_left <= 0 then
                            BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item][index] = nil
                        end
                    end
                end
            end
        end
        if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item then
            if BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item] then
                for index, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item]) do
                    if value then
                        local amount_left = delete_potion_specific_content_quantity(BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item, index, bags_mod_state.alchemy_amount_transfered)
                        if amount_left <= 0 then
                            BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item][index] = nil
                        end
                    end
                end
            end
        end
        if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item then
            if BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item] then
                for index, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item]) do
                    if value then
                        local amount_left = delete_potion_specific_content_quantity(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item, index, bags_mod_state.alchemy_amount_transfered)
                        if amount_left <= 0 then
                            BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item][index] = nil
                        end
                    end
                end
            end
        end
    end
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Sets the amount slider for potion alchemy.
--- This function creates a slider to adjust the amount of potion contents to be transferred or deleted.
function potion_alchemy_amount_slider(gui_id, ui_id, pos_x, pos_y, pos_z)
    local alchemy_amount_transfered = math.ceil(GuiSlider(gui_id, ui_id(), pos_x, pos_y,"", bags_mod_state.alchemy_amount_transfered, 0, 1000, 10, 0.1, " ", 62)/10)
    if alchemy_amount_transfered <= 0 then
        alchemy_amount_transfered = 1
    end
    local hovered = last_widget_is_being_hovered(gui_id)
    if hovered then
        GuiZSetForNextWidget(gui_id, 1)
        GuiText(gui_id, pos_x, pos_y + 10, "AMOUNT = "..tostring(bags_mod_state.alchemy_amount_transfered/10).."%")
    end
    bags_mod_state.alchemy_amount_transfered = alchemy_amount_transfered * 10
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Transfers the selected potion contents from the left and right spots to the combined spot in the alchemy table.
function potion_alchemy_transfer(gui_id, ui_id, pos_x, pos_y, pos_z)
    local transfer_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/transfer_button.png"
    if not BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item then
        transfer_sprite = "mods/bags_of_many/files/ui_gfx/potion_mixing/transfer_button_disabled.png"
    end
    GuiZSetForNextWidget(gui_id, 3)
    local left_click, right_click = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", transfer_sprite)
    local hover = last_widget_is_being_hovered(gui_id)
    if hover then
        GuiZSetForNextWidget(gui_id, 1)
        GuiColorSetForNextWidget(gui_id, 1, 1, 0.2, 1)
        GuiText(gui_id, pos_x + 20, pos_y, GameTextGet("$alchemy_table_transfer_button").." ("..tostring(bags_mod_state.alchemy_amount_transfered/10).."%)")
        auto_draw_background_box(gui_id, 2, 3, 6)
    end
    if BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item and (left_click or right_click) then
        if BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item then
            for index, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item] or {}) do
                if value then
                    transfer_potion_specific_content(BAGS_OF_MANY_GUI_STATES.left_spot_alchemy.item, BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item, index, bags_mod_state.alchemy_amount_transfered)
                end
            end
        end
        if BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item then
            for index, value in pairs(BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons[BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item] or {}) do
                if value then
                    transfer_potion_specific_content(BAGS_OF_MANY_GUI_STATES.right_spot_alchemy.item, BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy.item, index, bags_mod_state.alchemy_amount_transfered)
                end
            end
        end
    end
end

--- @param gui_id userdata
--- @param ui_id function
--- @param pos_x number
--- @param pos_y number
--- @param pos_z number
--- Unselects all materials in the alchemy table.
function potion_unselect_all(gui_id, ui_id, pos_x, pos_y, pos_z)
    if is_material_in_alchemy_table_selected() then
        local unselect_all_button = "mods/bags_of_many/files/ui_gfx/potion_mixing/unselect_all_button.png"
        GuiZSetForNextWidget(gui_id, 3)
        local left_click, right_click = GuiImageButton(gui_id, ui_id(), pos_x, pos_y, "", unselect_all_button)
        local hover = last_widget_is_being_hovered(gui_id)
        if hover then
            GuiZSetForNextWidget(gui_id, 1)
            GuiColorSetForNextWidget(gui_id, 1, 1, 0.2, 1)
            GuiText(gui_id, pos_x + 20, pos_y, GameTextGet("$alchemy_table_unselect_all_materials"))
            auto_draw_background_box(gui_id, 2, 3, 6)
        end
        if left_click or right_click then
            BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons = {}
        end
    end
end