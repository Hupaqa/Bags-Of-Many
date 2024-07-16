dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "mods/bags_of_many/files/scripts/gui/common_gui.lua" )
dofile_once( "mods/bags_of_many/files/scripts/gui/utils.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inputs.lua" )
dofile_once("mods/bags_of_many/files/scripts/utils/inputs.lua")

-- GUI SECTION
local gui = gui or GuiCreate()

-- MOD SETTINGS
local show_bags_without_inventory_open = ModSettingGet("BagsOfMany.show_bags_without_inventory_open")
local only_show_bag_button_when_held = ModSettingGet("BagsOfMany.only_show_bag_button_when_held")
local bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
local bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
local bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
local bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
local dragging_allowed = ModSettingGet("BagsOfMany.dragging_allowed")
local item_per_line = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")

function bags_of_many_bag_gui_v3(x, y)
    GuiStartFrame(gui)
    GuiOptionsAdd(gui, GUI_OPTION.NoPositionTween)
    bags_of_many_reset_id()
end

-- function inventory_slot(gui, pos_x, pos_y, pos_z)
--     GuiZSetForNextWidget(gui, pos_z)
--     GuiColorSetForNextWidget(gui, bag_ui_red, bag_ui_green, bag_ui_blue, 1)
--     GuiImage(gui, bags_of_many_new_id(), pos_x, pos_y, "mods/bags_of_many/files/ui_gfx/inventory/full_inventory_box.png", bag_ui_alpha, 1, 1)
-- end