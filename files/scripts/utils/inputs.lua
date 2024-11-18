dofile_once("mods/bags_of_many/files/scripts/utils/keycodes_tables.lua")

Mouse = {
    Position = {
        X = 0,
        Y = 0,
    }
}

function register_click_frame()
    if InputIsMouseButtonJustDown(1) then
        bags_mod_state.left_mouse_down_frame = GameGetFrameNum()
    end
end

function register_release_frame()
    if InputIsMouseButtonJustUp(1) then
        bags_mod_state.left_mouse_up_frame = GameGetFrameNum()
    end
end

function is_dragging()
    if bags_mod_state.left_mouse_down_frame > bags_mod_state.left_mouse_up_frame then
        return true
    end
    return false
end

function calculate_mouse_pos(gui)
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local mouse_raw_x, mouse_raw_y = InputGetMousePosOnScreen()

    local screen_size_x = tonumber(ModSettingGet("BagsOfMany.noita_screen_size_x"))
    local screen_size_y = tonumber(ModSettingGet("BagsOfMany.noita_screen_size_y"))
    if screen_size_x == nil then
        screen_size_x = 1280
    end
    if screen_size_y == nil then
        screen_size_y = 720
    end
    Mouse.Position.X = mouse_raw_x * screen_width / screen_size_x
    Mouse.Position.Y = mouse_raw_y * screen_height / screen_size_y
end

function get_key_pressed_name(value_pressed)
    for key, value in pairs(InputCodes.Key) do
        if value_pressed == value then
            return string.upper(InputCodes.KeyName[key])
        end
    end
    return nil
end

function get_mouse_pressed_name(value_pressed)
    for mouse, value in pairs(InputCodes.Mouse) do
        if value_pressed == value then
            return string.upper(InputCodes.MouseName[mouse])
        end
    end
    return nil
end

function detect_any_key_just_down()
    local just_down_list = {}
    for key, value in pairs(InputCodes.Key) do
        local just_down =  InputIsKeyJustDown(value)
        if just_down then
            table.insert(just_down_list, key)
        end
    end
    return just_down_list
end

function detect_any_mouse_just_down()
    local just_down_list = {}
    for key, value in pairs(InputCodes.Mouse) do
        local just_down =  InputIsMouseButtonJustDown(value)
        if just_down then
            table.insert(just_down_list, key)
        end
    end
    return just_down_list
end

function is_mouse_pos_in_box(pos_x, pos_y, size_x, height_y, mouse_x, mouse_y)
    if mouse_x - (pos_x + size_x) <= 0.0001 then
        mouse_x = math.floor(mouse_x)
    end
    if mouse_y - (pos_y + height_y) <= 0.0001 then
        mouse_y = math.floor(mouse_y)
    end
    if mouse_x >= pos_x and mouse_x <= pos_x + size_x and mouse_y >= pos_y and mouse_y <= pos_y + height_y then
        return true
    end
    return false
end

--- @param pos_x number
--- @param pos_y number
--- @param init_x number
--- @param init_y number
--- @param limit_x number
--- @param limit_y number
--- @return boolean
function moved_past_limit(pos_x, pos_y, init_x, init_y, limit_x, limit_y)
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