---@param gui userdata
---@param id integer
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param r number
---@param g number
---@param b number
---@param alpha number
function draw_left_bracket(gui, id, pos_x, pos_y, pos_z, r, g, b, alpha)
    r = r or 1
    g = g or 1
    b = b or 1
    alpha = alpha or 1
    GuiColorSetForNextWidget(gui, r, g, b, 1)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x-5, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_left.png", alpha, 1)
end

---@param gui userdata
---@param id integer
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param r number
---@param g number
---@param b number
---@param alpha number
function draw_middle(gui, id, pos_x, pos_y, pos_z, r, g, b, alpha)
    r = r or 1
    g = g or 1
    b = b or 1
    alpha = alpha or 1
    GuiColorSetForNextWidget(gui, r, g, b, 1)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_middle.png", alpha, 1)
end

---@param gui userdata
---@param id integer
---@param pos_x number
---@param pos_y number
---@param pos_z number
---@param r number
---@param g number
---@param b number
---@param alpha number
function draw_right_bracket(gui, id, pos_x, pos_y, pos_z, r, g, b, alpha)
    r = r or 1
    g = g or 1
    b = b or 1
    alpha = alpha or 1
    GuiColorSetForNextWidget(gui, r, g, b, alpha)
    GuiZSetForNextWidget(gui, pos_z)
    GuiImage(gui, id, pos_x+20, pos_y - 4, "mods/bags_of_many/files/ui_gfx/inventory/background_right.png", alpha, 1)
end