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