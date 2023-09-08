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