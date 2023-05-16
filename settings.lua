dofile("data/scripts/lib/mod_settings.lua")

function mod_setting_error_with_title(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 1.0, 0.4, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name .. ": " .. setting.ui_description)
end

function mod_setting_warning_with_title(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 1.0, 1.0, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name .. ": " .. setting.ui_description)
end

function mod_setting_error(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 1.0, 0.4, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_description)
end

function mod_setting_warning(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 1.0, 1.0, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_description)
end

function mod_setting_section(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 0.4, 0.4, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name .. ": " .. setting.ui_description)
end

function mod_setting_section_rgb(mod_id, gui, in_main_menu, im_id, setting)
    local local_bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
    local local_bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
    local local_bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
    local local_bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
    GuiColorSetForNextWidget(gui, 0.4, 0.4, 0.4, 1.0)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name .. ": " .. setting.ui_description)
    GuiColorSetForNextWidget(gui, local_bag_ui_red, local_bag_ui_green, local_bag_ui_blue, local_bag_ui_alpha)
    GuiText(gui, mod_setting_group_x_offset, 0, "BACKGROUND")
end

function mod_setting_warning_inventory_lock(mod_id, gui, in_main_menu, im_id, setting)
    if not ModSettingGet("BagsOfMany.locked") then
        GuiColorSetForNextWidget(gui, 1.0, 1.0, 0.4, 1.0)
        GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_description)
    end
end

local mod_id = "BagsOfMany"
mod_settings_version = 1
mod_settings =
{
    {
        category_id = "bag_position_inventory",
        foldable = true,
        _folded = true,
        ui_name = "Bag Inventory General",
        ui_description = "Options for the of the bags",
        settings = {
            {
                ui_fn = mod_setting_section,
                ui_name = "Position of the bag inventory ui",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "pos_x",
                ui_name = "Horizontal position",
                ui_description = "",
                value_default = 418,
                value_min = 0,
                value_max = 1000,
                value_display_multiplier = 1,
                value_display_formatting = " x = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "pos_y",
                ui_name = "Vertical position",
                ui_description = "",
                value_default = 64,
                value_min = 0,
                value_max = 1000,
                value_display_multiplier = 1,
                value_display_formatting = " y = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "locked",
                ui_name = "Lock Inventory",
                ui_description = "When false, the bag button can be dragged to a new position to display the inventory at a new location",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_warning_inventory_lock,
                ui_name = "Unlocked Position",
                ui_description = "\n   When the button is unlocked you wont be abled to\n" ..
                    "\n   use the sliders to choose the inventory position.\n" ..
                    "\n   If you want to move the inventory position with"..
                    "\n   the sliders first lock the bag position.",
                not_setting = true,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                id = "bag_slots_inventory_wrap",
                ui_name = "Inventory Wrapper",
                ui_description = "Number of inventory slots before newline in ui",
                value_default = "10",
                text_max_length = 3,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section_rgb,
                ui_name = "RGB of the bag inventory ui",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_image_red",
                ui_name = "Red of the background",
                ui_description = "The red in the rgb of the bag ui",
                value_default = 255,
                value_min = 0,
                value_max = 255,
                value_display_multiplier = 1,
                value_display_formatting = " red = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_image_green",
                ui_name = "Green of the background",
                ui_description = "The green in the rgb of the bag ui",
                value_default = 255,
                value_min = 0,
                value_max = 255,
                value_display_multiplier = 1,
                value_display_formatting = " green = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_image_blue",
                ui_name = "Blue of the background",
                ui_description = "The blue in the rgb of the bag ui",
                value_default = 255,
                value_min = 0,
                value_max = 255,
                value_display_multiplier = 1,
                value_display_formatting = " blue = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_image_alpha",
                ui_name = "Alpha of the background",
                ui_description = "The alpha in the rgb of the bag ui",
                value_default = 255,
                value_min = 0,
                value_max = 255,
                value_display_multiplier = 1,
                value_display_formatting = " alpha = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    },
    {
        category_id = "bag_inventory_size",
        foldable = true,
        _folded = true,
        ui_name = "Bag Inventory Size",
        ui_description = "Options for the bags inventories",
        settings = {
            {
                id = "bag_universal_small_size",
                ui_name = "Small Universal Bag Size",
                ui_description = "Size of the small universal bag inventory",
                value_default = "3",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_universal_medium_size",
                ui_name = "Medium Universal Bag Size",
                ui_description = "Size of the medium universal bag inventory",
                value_default = "5",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_universal_big_size",
                ui_name = "Big Universal Bag Size",
                ui_description = "Size of the big universal bag inventory",
                value_default = "8",
				text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    },
    {
        category_id = "bag_inventory_allowed",
        foldable = true,
        _folded = true,
        ui_name = "Bag Allowed Inventory",
        ui_description = "Options for the bags inventories",
        settings = {
            {
                id = "allow_spells",
                ui_name = "Allow Spells in Bags",
                ui_description = "When set to true spells will be allowed to be stored in the bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_wands",
                ui_name = "Allow Wands in Bags",
                ui_description = "When set to true wands will be allowed to be stored in the bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_potions",
                ui_name = "Allow Potions in Bags",
                ui_description = "When set to true potions will be allowed to be stored in the bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_bags_inception",
                ui_name = "Allow Bags in Bags",
                ui_description = "When set to true bags will be allowed to be stored in the bags",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                id = "show_bag_content",
                ui_name = "Show bag contents",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            }
        }
    }
}

function adjust_setting_values(screen_width, screen_height)
	if not screen_width then
		local gui = GuiCreate()
		GuiStartFrame(gui)
		screen_width, screen_height = GuiGetScreenDimensions(gui)
	end
	for i, setting in ipairs(mod_settings) do
		if setting.id == "pos_x" then
			setting.value_max = screen_width - 100
		elseif setting.id == "pos_y" then
			setting.value_max = screen_height - 100
		end
	end
end

function ModSettingsUpdate(init_scope)
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui( gui, in_main_menu )
	new_screen_width, new_screen_height = GuiGetScreenDimensions(gui)
	-- Update settings when resolution changes
	if screen_width ~= new_screen_width or screen_height ~= new_screen_height then
		adjust_setting_values(new_screen_width, new_screen_height)
	end
	screen_width = new_screen_width
	screen_height = new_screen_height

	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end