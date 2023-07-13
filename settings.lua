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

-- function mod_setting_dev_enabled(mod_id, gui, in_main_menu, im_id, setting)
--     if ModSettingGet("BagsOfMany.dev_enabled") then
--         GuiColorSetForNextWidget(gui, 1.0, 1.0, 1.0, 1.0)
--         GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)
--     end
-- end

local mod_id = "BagsOfMany"
mod_settings_version = 1
mod_settings =
{
    {
        category_id = "bag_position_inventory",
        foldable = true,
        _folded = true,
        ui_name = "Bag General",
        ui_description = "General options for the bags",
        settings = {
            {
                ui_fn = mod_setting_section,
                ui_name = "Starter loadout",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "starter_loadout",
                ui_name = "Starter Loadout",
                ui_description = "When true will start your run with a bag of each type lying around near you.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_NEW_GAME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
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
                value_default = 170,
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
                value_default = 54,
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
                ui_fn = mod_setting_section,
                ui_name = "Inventory Wrapping",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_slots_inventory_wrap",
                ui_name = "Inventory Slots Wrap",
                ui_description = "Number of inventory slots before newline in ui",
                value_default = "16",
                text_max_length = 3,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "spells_slots_inventory_wrap",
                ui_name = "Spells Slots Wrap",
                ui_description = "Number of spells in wand tooltip before newline in ui",
                value_default = "12",
                text_max_length = 2,
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
        ui_name = "Bag Inventory",
        ui_description = "Options for the bags inventories",
        settings = {
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Inventory UI Options",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "only_show_bag_button_when_held",
                ui_name = "Only show bag button when held",
                ui_description = "Will only show the bag button when a bag item is held in the player\nhands, otherwise will always be shown when the inventory is open",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "show_drop_all_inventory_button",
                ui_name = "Show drop all inventory button",
                ui_description = "Will display the drop all inventory button at the end of the inventory UI",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "drop_orderly_distance",
                ui_name = "Drop orderly distance between items",
                ui_description = "Specify the distance between the items when using the drop all items in an orderly fashion.\n (order displayed in the bag)",
                value_default = 12,
                value_min = 0,
                value_max = 20,
                value_display_multiplier = 1,
                value_display_formatting = " alpha = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "show_change_sorting_direction_button",
                ui_name = "Show change sorting direction inventory button",
                ui_description = "Will display the change sorting direction inventory button at the end of the inventory UI",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Inventory Sorting Options",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "sorting_type",
                ui_name = "Inventory sorting type",
                ui_description = "Sort the items in the bag by the order of time of pickup\n or by their positions (time of pickup until moved).\n ON: Sort by time of pickup\n OFF: Sort by positions",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "sorting_order",
                ui_name = "Ascending sorting direction",
                ui_description = "Will sort the items in the bag by the order of time of pickup.\n (with Inventory Sorting type: On)\n ON: Newer items will be at the end of the bag\n OFF: Newer items will be at the beginning of the bag",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "dragging_allowed",
                ui_name = "Dragging in inventory allowed",
                ui_description = "(EXPERIMENTAL-butquitesafe USE AT YOUR OWN RISK)\n Allows to drag items in the inventory bag.\n When sorting by positions will act similarly to the normal inventory. \n When sorting by time of pickup will only allow dropping.",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Allowed Items in Universal Bags",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "allow_spells",
                ui_name = "Allow Spells",
                ui_description = "When set to true spells will be allowed to be stored in the universal bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_wands",
                ui_name = "Allow Wands",
                ui_description = "When set to true wands will be allowed to be stored in the universal bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_potions",
                ui_name = "Allow Potions",
                ui_description = "When set to true potions will be allowed to be stored in the universal bags",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_items",
                ui_name = "Allow Items",
                ui_description = "When set to true items will be allowed to be stored in the universal bags (evil eye, sunseed, etc.)",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_bags_inception",
                ui_name = "Allow Bags",
                ui_description = "When set to true bags will be allowed to be stored in the universal bags",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Universal Bags",
                ui_description = "",
                not_setting = true,
            },
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
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Spell Binders",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_spells_small_size",
                ui_name = "Small Spell Binder Size",
                ui_description = "Size of the small spell binder inventory",
                value_default = "5",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_spells_medium_size",
                ui_name = "Medium Spell Binder Size",
                ui_description = "Size of the medium spell binder inventory",
                value_default = "7",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_spells_big_size",
                ui_name = "Big Spell Binder Size",
                ui_description = "Size of the big spell binder inventory",
                value_default = "10",
				text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Potion Pouchs",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_potions_small_size",
                ui_name = "Small Potion Pouch Size",
                ui_description = "Size of the small potion pouch inventory",
                value_default = "2",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_potions_medium_size",
                ui_name = "Medium Potion Pouch Size",
                ui_description = "Size of the medium potion pouch inventory",
                value_default = "3",
                text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "bag_potions_big_size",
                ui_name = "Big Potion Pouch Size",
                ui_description = "Size of the big potion pouch inventory",
                value_default = "5",
				text_max_length = 2,
				allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    },
    {
        category_id = "bag_spawn_inventory",
        foldable = true,
        _folded = true,
        ui_name = "Bag Spawning",
        ui_description = "Options for the spawning of the bags",
        settings = {
            {
                ui_fn = mod_setting_section,
                ui_name = "General Bag Spawn",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_ratio_vs_potions",
                ui_name = "Bag Spawn Chance",
                ui_description = "General chance of spawning bags, will take up chances for potions spawn.\n(0 -> almost no bags lots of potions & 100 -> lots of bags almost no potions).",
                value_default = 10,
                value_min = 1,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Universal Bag Spawn",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_universal_spawn_chance",
                ui_name = "Universal Bag Ratio",
                ui_description = "General chance of spawning a universal bag versus other bag types.",
                value_default = 20,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_universal_small_spawn_chance",
                ui_name = "Small Universal Bag Spawn Chance",
                ui_description = "General chance of spawning a small universal bag versus other universal bags.",
                value_default = 100,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_universal_medium_spawn_chance",
                ui_name = "Medium Universal Bag Spawn Chance",
                ui_description = "General chance of spawning a medium universal bag versus other universal bags.",
                value_default = 60,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_universal_big_spawn_chance",
                ui_name = "Big Universal Bag Spawn Chance",
                ui_description = "General chance of spawning a big universal bag versus other universal bags.",
                value_default = 20,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Spell Binders Spawn",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_spells_spawn_chance",
                ui_name = "Spells Bag Ratio",
                ui_description = "General chance of spawning a spells bag versus other bag types.",
                value_default = 70,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_spells_small_spawn_chance",
                ui_name = "Small Spells Bag Spawn Chance",
                ui_description = "General chance of spawning a small spells bag versus other spells bags.",
                value_default = 100,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_spells_medium_spawn_chance",
                ui_name = "Medium Spells Bag Spawn Chance",
                ui_description = "General chance of spawning a medium spells bag versus other spells bags.",
                value_default = 60,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_spells_big_spawn_chance",
                ui_name = "Big Spells Bag Spawn Chance",
                ui_description = "General chance of spawning a big spells bag versus other spells bags.",
                value_default = 20,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Potion Pouches Spawn",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "bag_potions_spawn_chance",
                ui_name = "Potions Bag Ratio",
                ui_description = "General chance of spawning a potion bag versus other bag types.",
                value_default = 30,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_potions_small_spawn_chance",
                ui_name = "Small Potions Bag Spawn Chance",
                ui_description = "General chance of spawning a small potions bag versus other potions bags.",
                value_default = 100,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_potions_medium_spawn_chance",
                ui_name = "Medium Potions Bag Spawn Chance",
                ui_description = "General chance of spawning a medium potions bag versus other potions bags.",
                value_default = 60,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "bag_potions_big_spawn_chance",
                ui_name = "Big Potions Bag Spawn Chance",
                ui_description = "General chance of spawning a big potions bag versus other potions bags.",
                value_default = 20,
                value_min = 0,
                value_max = 100,
                value_display_multiplier = 1,
                value_display_formatting = " $0%",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_warning_with_title,
                ui_name = "Bags Spawning Chance",
                ui_description = " \n   'Bag Spawn Chance' replaces some potion spawn with the bags of the mod.\n"..
                    "   The other Spawn Chance options are weighted chance\n"..
                    "   so multiple item can be at 100% or whatever percent.",
                not_setting = true,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_error_with_title,
                ui_name = "Warning on change",
                ui_description = "\n    Changing options in this section require a new game or a game restart\n"..
                "\n    to see the effect of the change. You will need to explore\n"..
                "\n    new zones to see a difference in the spawn chance since\n"..
                "\n    in explored zones the items have already spawned."
                ,
                not_setting = true,
            },
            -- {
            --     ui_fn = mod_setting_vertical_spacing,
            --     not_setting = true,
            -- },
            -- {
            --     id = "dev_enabled",
            --     ui_name = "Developper Mode",
            --     ui_description = "Enable for developper mode",
            --     value_default = false,
            --     scope = MOD_SETTING_SCOPE_RUNTIME,
            -- },
            -- {
            --     ui_fn = mod_setting_dev_enabled,
            --     id = "spawn_all_bags",
            --     ui_name = "Spawn All Bags",
            --     ui_description = "Spawn all bags",
            --     value_default = false,
            --     scope = MOD_SETTING_SCOPE_NEW_GAME,
            -- },
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