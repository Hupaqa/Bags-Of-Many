dofile("data/scripts/lib/mod_settings.lua")

local mod_version = "1.6.17"

local function last_widget_is_being_hovered(gui)
    local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
    return hovered
end

local function last_widget_is_left_clicked(gui)
    local left_click = GuiGetPreviousWidgetInfo(gui)
    return left_click
end

local function last_widget_size(gui)
    local _, _, _, _, _, width, height = GuiGetPreviousWidgetInfo(gui)
    return width, height
end

local function get_key_pressed_name(value_pressed)
    for key, value in pairs(InputCodes.Key) do
        if value_pressed == value then
            return string.upper(InputCodes.KeyName[key])
        end
    end
    return ""
end

local function get_mouse_pressed_name(value_pressed)
    for mouse, value in pairs(InputCodes.Mouse) do
        if value_pressed == value then
            return string.upper(InputCodes.MouseName[mouse])
        end
    end
    return ""
end

local function detect_any_key_just_down()
    local just_down_list = {}
    for key, value in pairs(InputCodes.Key) do
        local just_down =  InputIsKeyJustDown(value)
        if just_down then
            table.insert(just_down_list, key)
        end
    end
    return just_down_list
end

local function detect_any_mouse_just_down()
    local just_down_list = {}
    for key, value in pairs(InputCodes.Mouse) do
        local just_down =  InputIsMouseButtonJustDown(value)
        if just_down then
            table.insert(just_down_list, key)
        end
    end
    return just_down_list
end

local listening_to_key_press = false
function mod_setting_key_display(mod_id, gui, in_main_menu, im_id, setting)
    local error_msg = "COULD NOT BE DISPLAYED PROPERLY PLEASE REPORT THE PROBLEM"
    local pickup_input_code = ModSettingGet("BagsOfMany.pickup_input_code")
    local pickup_input_type = ModSettingGet("BagsOfMany.pickup_input_type")
    if not in_main_menu and pickup_input_code and pickup_input_type and pickup_input_code ~= "" and pickup_input_type ~= "" then
        if not listening_to_key_press then
            GuiImage(gui, 1, mod_setting_group_x_offset, 0, "mods/bags_of_many/files/ui_gfx/settings/click_rebind_button.png", 0, 1)
            local last_hovered = last_widget_is_being_hovered(gui)
            local button_clicked = last_widget_is_left_clicked(gui)
            local _, button_y = last_widget_size(gui)
            if last_hovered then
                GuiColorSetForNextWidget(gui, 0.75, 0.75, 0.75, 1.0)
            end
            if button_y then
                GuiImage(gui, 1, mod_setting_group_x_offset, -button_y, "mods/bags_of_many/files/ui_gfx/settings/click_rebind_button.png", 1, 1)
            end
            if last_hovered then
                GuiColorSetForNextWidget(gui, 1, 1, 0.71764705882, 1)
                GuiText(gui, mod_setting_group_x_offset, 0, "CLICK TO BEGIN LISTENING TO KEY PRESS...")
            end
            if last_hovered and button_clicked then
                listening_to_key_press = true
            end
        else
            GuiImage(gui, 1, mod_setting_group_x_offset, 0, "mods/bags_of_many/files/ui_gfx/settings/listening_rebind.png", 0, 1)
            local last_hovered = last_widget_is_being_hovered(gui)
            local left_clicked = last_widget_is_left_clicked(gui)
            local _, button_y = last_widget_size(gui)
            if last_hovered then
                GuiColorSetForNextWidget(gui, 0.75, 0.75, 0.75, 1.0)
            end
            if button_y then
                GuiImage(gui, 1, mod_setting_group_x_offset, -button_y, "mods/bags_of_many/files/ui_gfx/settings/listening_rebind.png", 1, 1)
            end
            if last_hovered then
                GuiColorSetForNextWidget(gui, 1, 1, 0.71764705882, 1)
                GuiText(gui, mod_setting_group_x_offset, 0, "CLICK AGAIN TO CANCEL...")
            end
            local cancelling = false
            if last_hovered and left_clicked then
                listening_to_key_press = false
                cancelling = true
            end

            if not cancelling then
                local type_found = nil
                local keys_just_down = detect_any_key_just_down()
                local mouse_just_down = detect_any_mouse_just_down()
                local key_or_mouse_found = nil
                for _, key_code in pairs(keys_just_down or {}) do
                    local key_number = InputCodes.Key[key_code]
                    if key_number then
                        type_found = "Key"
                        key_or_mouse_found = key_number
                        listening_to_key_press = false
                        break
                    end
                end
                for _, mouse_code in pairs(mouse_just_down or {}) do
                    local mouse_number = InputCodes.Mouse[mouse_code]
                    if mouse_number then
                        type_found = "Mouse"
                        key_or_mouse_found = mouse_number
                        listening_to_key_press = false
                        break
                    end
                end
                if key_or_mouse_found and type_found then
                    ModSettingSet("BagsOfMany.pickup_input_type", type_found)
                    ModSettingSetNextValue("BagsOfMany.pickup_input_type", type_found, false)
                    ModSettingSet("BagsOfMany.pickup_input_code", key_or_mouse_found)
                    ModSettingSetNextValue("BagsOfMany.pickup_input_code", key_or_mouse_found, false)
                end
            end
        end
    end
    if in_main_menu then
        GuiColorSetForNextWidget(gui, 1.0, 0.4, 0.4, 1.0)
        GuiText(gui, mod_setting_group_x_offset, 0, "TO MODIFY THIS SETTING ENTER A GAME")
    end
    -- DISPLAY PICKUP CODE NAME
    local pickup_input_code_name = ""
    if pickup_input_type == "Key" then
        pickup_input_code_name = get_key_pressed_name(tonumber(pickup_input_code))
    elseif pickup_input_type == "Mouse" then
        pickup_input_code_name = get_mouse_pressed_name(tonumber(pickup_input_code))
    end
    local message_disp = ""
    if pickup_input_code_name and pickup_input_code_name ~= "" then
        message_disp = "INPUT key/mouse code: " .. "[  " .. pickup_input_code_name .. "  ]"
    end
    if message_disp and message_disp ~= "" then
        GuiText(gui, mod_setting_group_x_offset, 0, message_disp)
    else
        GuiText(gui, mod_setting_group_x_offset, 0, error_msg)
    end
end

function mod_setting_type_display(mod_id, gui, in_main_menu, im_id, setting)
    local pickup_input_code = tostring(ModSettingGet("BagsOfMany.pickup_input_code"))
    local pickup_input_type = tostring(ModSettingGet("BagsOfMany.pickup_input_type"))
    local msg_display = ""
    if pickup_input_code ~= nil and pickup_input_type ~= nil and pickup_input_code ~= "" and pickup_input_type ~= "" then
        msg_display = "Input Type -> ( " .. pickup_input_type .. " ) | Input Code -> ( " .. pickup_input_code .. " )"
    end
    if msg_display and msg_display ~= "" then
        GuiColorSetForNextWidget(gui, 0.55, 0.55, 0.55, 1)
        GuiText(gui, mod_setting_group_x_offset, 0, msg_display)
    else
        GuiText(gui, mod_setting_group_x_offset, 0, "COULD NOT BE DISPLAYED PROPERLY PLEASE REPORT THE PROBLEM")
    end
end

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
        category_id = "bag_keybindings",
        foldable = true,
        _folded = true,
        ui_name = "Bag Keybindings",
        ui_description = "Keybindings for the bags",
        settings = {
            {
                ui_fn = mod_setting_key_display,
                id = "pickup_input_code",
                value_default = "9",
                text_max_length = 4,
				allowed_characters = "0123456789",
                value_display_formatting = "Pickup input code : $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_type_display,
                id = "pickup_input_type",
                ui_name = "Pickup input type",
                value_default = "Key",
                ui_description = "Pickup input type used for the pickup actions.",
                value_display_formatting = "Pickup input type: $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    },
    {
        category_id = "bag_position_inventory",
        foldable = true,
        _folded = true,
        ui_name = "Bag General",
        ui_description = "General options for the bags",
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
                id = "alchemy_pos_x",
                ui_name = "Alchemy horizontal position",
                ui_description = "",
                value_default = 170,
                value_min = 0,
                value_max = 1000,
                value_display_multiplier = 1,
                value_display_formatting = " x = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "alchemy_pos_y",
                ui_name = "Alchemy vertical position",
                ui_description = "",
                value_default = 200,
                value_min = 0,
                value_max = 1000,
                value_display_multiplier = 1,
                value_display_formatting = " y = $0",
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "show_bags_without_inventory_open",
                ui_name = "Show bags without inventory open",
                ui_description = "Show the bags inventory even when the inventory is not open.\n"..
                    "\n    With big wand the bag ui gets hidden by the wand inventory\n"..
                    "\n    so this option allows to show the bags ui without having to open the inventory.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "locked",
                ui_name = "Lock Inventory",
                ui_description = "When false, the bag button can be dragged to a new position to display the inventory at a new location",
                value_default = false,
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
                ui_name = "Gui general options",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "keep_tooltip_open",
                ui_name = "Keep bag tooltip open",
                ui_description = "Show the bag inventory when hovered and then keep it open\n"..
                    "\n    to show items inside and drop them.\n",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "dropdown_style",
                ui_name = "Bag navigation style",
                ui_description = "When set to true will automatically change the bag displayed when hovering it:\n    This allows to quickly check what is inside a bag without cluttering the screen.\n"..
                    "When set to false will need to right click on a bag item to open its display:\n    This helps in switching items from one bag to another.\n",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
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
                ui_fn = mod_setting_section,
                ui_name = "Inventory Interaction Options",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "dragging_allowed",
                ui_name = "Dragging in inventory allowed",
                ui_description = "Allows to drag items in the inventory bag.\n When sorting by positions the inventory will act similarly to the normal inventory. \n When sorting by time of pickup will allow dropping and changing bags.",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "vanilla_dragging_allowed",
                ui_name = "Vanilla inventory interaction allowed",
                ui_description = "Allows to drag items from the vanilla inventory to bags inventory and vice versa.\n    Be aware that transfering wand back to the vanilla inventory\n    can sometimes lag the vanilla inventory display, but it can\n    be fixed with an open/close of the inventory.",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
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
                value_default = false,
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
                id = "allow_bags_inception_universal_bag",
                ui_name = "Allow Universal Bags",
                ui_description = "When set to true universal bags will be allowed to be stored in universal bags",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_bags_inception_potion_bag",
                ui_name = "Allow Potion Pouches",
                ui_description = "When set to true potion pouches will be allowed to be stored in universal bags",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_bags_inception_spell_bag",
                ui_name = "Allow Spell Binders",
                ui_description = "When set to true spell binders will be allowed to be stored in universal bags",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Pickup restrictions",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "allow_holy_mountain_wand_stealing",
                ui_name = "Allow holy mountain WAND stealing with bags",
                ui_description = "When set to true bags will be allowed to steal the wands in holy mountains",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_holy_mountain_spell_stealing",
                ui_name = "Allow holy mountain SPELL stealing with bags",
                ui_description = "When set to true bags will be allowed to steal the spells in holy mountains",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_tower_wand_stealing",
                ui_name = "Allow TOWER wands stealing with bags",
                ui_description = "When set to true bags will be allowed to steal the tower wands (you can take multiple tower wands)",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_sampo_stealing",
                ui_name = "Allow the SAMPO to be picked up with bags",
                ui_description = "When set to true bags will be allowed to pickup the sampo",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            {
                id = "allow_big_bag_in_small_bag",
                ui_name = "Allow bags to carry all bags sizes",
                ui_description = "When set to true any bag size will be allowed to be stored in any bag size.\nWhen set to false only allows bags which are smaller than current bag to be stored in it:\nSMALL -> MEDIUM or BIG\nMEDIUM -> BIG\nNeeds to allow bags in universal bags for this option to have any effect.",
                value_default = true,
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
                ui_name = "Potion Pouches",
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
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
            {
                ui_fn = mod_setting_section,
                ui_name = "Misc",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "drop_orderly_distance",
                ui_name = "Drop orderly distance between items",
                ui_description = "Specify the distance between the items when using the drop all items in an orderly fashion.\n (order displayed in the bag)",
                value_default = 12,
                value_min = 0,
                value_max = 20,
                value_display_multiplier = 1,
                value_display_formatting = " pixels = $0",
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
                id = "showcase_loadout",
                ui_name = "Showcase loadout",
                ui_description = "When true will spawn all the bags of the mod in the mountain at the start.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_NEW_GAME,
            },
            {
                ui_fn = mod_setting_vertical_spacing,
                not_setting = true,
            },
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
    },
    {
        category_id = "bag_abilities",
        foldable = true,
        _folded = true,
        ui_name = "Bag Abilities",
        ui_description = "Bag abilities options",
        settings = {
            {
                ui_fn = mod_setting_section,
                ui_name = "Universal Bag",
                ui_description = "",
                not_setting = true,
            },
            {
                id = "universal_bag_alchemy_table",
                ui_name = "Universal bag alchemy table",
                ui_description = "When true the universal bags have the alchemy table gui available.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
        }
    },
    {
        category_id = "bags_of_many_version",
        foldable = false,
        _folded = true,
        ui_name = "Version: ".. mod_version,
        ui_description = "Current version of the mod",
        settings = {}
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
    listening_to_key_press = false
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

InputCodes = {
    Mouse = {
        Mouse_left = 1,
        Mouse_right = 2,
        Mouse_middle = 3,
        Mouse_wheel_up = 4,
        Mouse_wheel_down = 5,
        Mouse_x1 = 6,
        Mouse_x2 = 7,
    },
    Key = {
        Key_a = 4,
        Key_b = 5,
        Key_c = 6,
        Key_d = 7,
        Key_e = 8,
        Key_f = 9,
        Key_g = 10,
        Key_h = 11,
        Key_i = 12,
        Key_j = 13,
        Key_k = 14,
        Key_l = 15,
        Key_m = 16,
        Key_n = 17,
        Key_o = 18,
        Key_p = 19,
        Key_q = 20,
        Key_r = 21,
        Key_s = 22,
        Key_t = 23,
        Key_u = 24,
        Key_v = 25,
        Key_w = 26,
        Key_x = 27,
        Key_y = 28,
        Key_z = 29,
        Key_1 = 30,
        Key_2 = 31,
        Key_3 = 32,
        Key_4 = 33,
        Key_5 = 34,
        Key_6 = 35,
        Key_7 = 36,
        Key_8 = 37,
        Key_9 = 38,
        Key_0 = 39,
        Key_RETURN = 40,
        Key_ESCAPE = 41,
        Key_BACKSPACE = 42,
        Key_TAB = 43,
        Key_SPACE = 44,
        Key_MINUS = 45,
        Key_EQUALS = 46,
        Key_LEFTBRACKET = 47,
        Key_RIGHTBRACKET = 48,
        Key_BACKSLASH = 49,
        Key_NONUSHASH = 50,
        Key_SEMICOLON = 51,
        Key_APOSTROPHE = 52,
        Key_GRAVE = 53,
        Key_COMMA = 54,
        Key_PERIOD = 55,
        Key_SLASH = 56,
        Key_CAPSLOCK = 57,
        Key_F1 = 58,
        Key_F2 = 59,
        Key_F3 = 60,
        Key_F4 = 61,
        Key_F5 = 62,
        Key_F6 = 63,
        Key_F7 = 64,
        Key_F8 = 65,
        Key_F9 = 66,
        Key_F10 = 67,
        Key_F11 = 68,
        Key_F12 = 69,
        Key_PRINTSCREEN = 70,
        Key_SCROLLLOCK = 71,
        Key_PAUSE = 72,
        Key_INSERT = 73,
        Key_HOME = 74,
        Key_PAGEUP = 75,
        Key_DELETE = 76,
        Key_END = 77,
        Key_PAGEDOWN = 78,
        Key_RIGHT = 79,
        Key_LEFT = 80,
        Key_DOWN = 81,
        Key_UP = 82,
        Key_NUMLOCKCLEAR = 83,
        Key_KP_DIVIDE = 84,
        Key_KP_MULTIPLY = 85,
        Key_KP_MINUS = 86,
        Key_KP_PLUS = 87,
        Key_KP_ENTER = 88,
        Key_KP_1 = 89,
        Key_KP_2 = 90,
        Key_KP_3 = 91,
        Key_KP_4 = 92,
        Key_KP_5 = 93,
        Key_KP_6 = 94,
        Key_KP_7 = 95,
        Key_KP_8 = 96,
        Key_KP_9 = 97,
        Key_KP_0 = 98,
        Key_KP_PERIOD = 99,
        Key_NONUSBACKSLASH = 100,
        Key_APPLICATION = 101,
        Key_POWER = 102,
        Key_KP_EQUALS = 103,
        Key_F13 = 104,
        Key_F14 = 105,
        Key_F15 = 106,
        Key_F16 = 107,
        Key_F17 = 108,
        Key_F18 = 109,
        Key_F19 = 110,
        Key_F20 = 111,
        Key_F21 = 112,
        Key_F22 = 113,
        Key_F23 = 114,
        Key_F24 = 115,
        Key_EXECUTE = 116,
        Key_HELP = 117,
        Key_MENU = 118,
        Key_SELECT = 119,
        Key_STOP = 120,
        Key_AGAIN = 121,
        Key_UNDO = 122,
        Key_CUT = 123,
        Key_COPY = 124,
        Key_PASTE = 125,
        Key_FIND = 126,
        Key_MUTE = 127,
        Key_VOLUMEUP = 128,
        Key_VOLUMEDOWN = 129,
        Key_KP_COMMA = 133,
        Key_KP_EQUALSAS400 = 134,
        Key_INTERNATIONAL1 = 135,
        Key_INTERNATIONAL2 = 136,
        Key_INTERNATIONAL3 = 137,
        Key_INTERNATIONAL4 = 138,
        Key_INTERNATIONAL5 = 139,
        Key_INTERNATIONAL6 = 140,
        Key_INTERNATIONAL7 = 141,
        Key_INTERNATIONAL8 = 142,
        Key_INTERNATIONAL9 = 143,
        Key_LANG1 = 144,
        Key_LANG2 = 145,
        Key_LANG3 = 146,
        Key_LANG4 = 147,
        Key_LANG5 = 148,
        Key_LANG6 = 149,
        Key_LANG7 = 150,
        Key_LANG8 = 151,
        Key_LANG9 = 152,
        Key_ALTERASE = 153,
        Key_SYSREQ = 154,
        Key_CANCEL = 155,
        Key_CLEAR = 156,
        Key_PRIOR = 157,
        Key_RETURN2 = 158,
        Key_SEPARATOR = 159,
        Key_OUT = 160,
        Key_OPER = 161,
        Key_CLEARAGAIN = 162,
        Key_CRSEL = 163,
        Key_EXSEL = 164,
        Key_KP_00 = 176,
        Key_KP_000 = 177,
        Key_THOUSANDSSEPARATOR = 178,
        Key_DECIMALSEPARATOR = 179,
        Key_CURRENCYUNIT = 180,
        Key_CURRENCYSUBUNIT = 181,
        Key_KP_LEFTPAREN = 182,
        Key_KP_RIGHTPAREN = 183,
        Key_KP_LEFTBRACE = 184,
        Key_KP_RIGHTBRACE = 185,
        Key_KP_TAB = 186,
        Key_KP_BACKSPACE = 187,
        Key_KP_A = 188,
        Key_KP_B = 189,
        Key_KP_C = 190,
        Key_KP_D = 191,
        Key_KP_E = 192,
        Key_KP_F = 193,
        Key_KP_XOR = 194,
        Key_KP_POWER = 195,
        Key_KP_PERCENT = 196,
        Key_KP_LESS = 197,
        Key_KP_GREATER = 198,
        Key_KP_AMPERSAND = 199,
        Key_KP_DBLAMPERSAND = 200,
        Key_KP_VERTICALBAR = 201,
        Key_KP_DBLVERTICALBAR = 202,
        Key_KP_COLON = 203,
        Key_KP_HASH = 204,
        Key_KP_SPACE = 205,
        Key_KP_AT = 206,
        Key_KP_EXCLAM = 207,
        Key_KP_MEMSTORE = 208,
        Key_KP_MEMRECALL = 209,
        Key_KP_MEMCLEAR = 210,
        Key_KP_MEMADD = 211,
        Key_KP_MEMSUBTRACT = 212,
        Key_KP_MEMMULTIPLY = 213,
        Key_KP_MEMDIVIDE = 214,
        Key_KP_PLUSMINUS = 215,
        Key_KP_CLEAR = 216,
        Key_KP_CLEARENTRY = 217,
        Key_KP_BINARY = 218,
        Key_KP_OCTAL = 219,
        Key_KP_DECIMAL = 220,
        Key_KP_HEXADECIMAL = 221,
        Key_LCTRL = 224,
        Key_LSHIFT = 225,
        Key_LALT = 226,
        Key_LGUI = 227,
        Key_RCTRL = 228,
        Key_RSHIFT = 229,
        Key_RALT = 230,
        Key_RGUI = 231,
        Key_MODE = 257,
        Key_AUDIONEXT = 258,
        Key_AUDIOPREV = 259,
        Key_AUDIOSTOP = 260,
        Key_AUDIOPLAY = 261,
        Key_AUDIOMUTE = 262,
        Key_MEDIASELECT = 263,
        Key_WWW = 264,
        Key_MAIL = 265,
        Key_CALCULATOR = 266,
        Key_COMPUTER = 267,
        Key_AC_SEARCH = 268,
        Key_AC_HOME = 269,
        Key_AC_BACK = 270,
        Key_AC_FORWARD = 271,
        Key_AC_STOP = 272,
        Key_AC_REFRESH = 273,
        Key_AC_BOOKMARKS = 274,
        Key_BRIGHTNESSDOWN = 275,
        Key_BRIGHTNESSUP = 276,
        Key_DISPLAYSWITCH = 277,
        Key_KBDILLUMTOGGLE = 278,
        Key_KBDILLUMDOWN = 279,
        Key_KBDILLUMUP = 280,
        Key_EJECT = 281,
        Key_SLEEP = 282,
        Key_APP1 = 283,
        Key_APP2 = 284,
        Key_SPECIAL_COUNT = 512
    },
    MouseName = {
        Mouse_left = 'mouse left',
        Mouse_right = 'mouse right',
        Mouse_middle = 'mouse middle',
        Mouse_wheel_up = 'mouse wheel up',
        Mouse_wheel_down = 'mouse wheel down',
        Mouse_x1 = 'mouse x1',
        Mouse_x2 = 'mouse x2',
    },
    KeyName = {
        Key_a = 'a',
        Key_b = 'b',
        Key_c = 'c',
        Key_d = 'd',
        Key_e = 'e',
        Key_f = 'f',
        Key_g = 'g',
        Key_h = 'h',
        Key_i = 'i',
        Key_j = 'j',
        Key_k = 'k',
        Key_l = 'l',
        Key_m = 'm',
        Key_n = 'n',
        Key_o = 'o',
        Key_p = 'p',
        Key_q = 'q',
        Key_r = 'r',
        Key_s = 's',
        Key_t = 't',
        Key_u = 'u',
        Key_v = 'v',
        Key_w = 'w',
        Key_x = 'x',
        Key_y = 'y',
        Key_z = 'z',
        Key_1 = '1',
        Key_2 = '2',
        Key_3 = '3',
        Key_4 = '4',
        Key_5 = '5',
        Key_6 = '6',
        Key_7 = '7',
        Key_8 = '8',
        Key_9 = '9',
        Key_0 = '0',
        Key_RETURN = 'RETURN',
        Key_ESCAPE = 'ESCAPE',
        Key_BACKSPACE = 'BACKSPACE',
        Key_TAB = 'TAB',
        Key_SPACE = 'SPACE',
        Key_MINUS = 'MINUS',
        Key_EQUALS = 'EQUALS',
        Key_LEFTBRACKET = 'LEFT BRACKET',
        Key_RIGHTBRACKET = 'RIGHT BRACKET',
        Key_BACKSLASH = 'BACKSLASH',
        Key_NONUSHASH = 'NON US HASH',
        Key_SEMICOLON = 'SEMICOLON',
        Key_APOSTROPHE = 'APOSTROPHE',
        Key_GRAVE = 'GRAVE',
        Key_COMMA = 'COMMA',
        Key_PERIOD = 'PERIOD',
        Key_SLASH = 'SLASH',
        Key_CAPSLOCK = 'CAPSLOCK',
        Key_F1 = 'F1',
        Key_F2 = 'F2',
        Key_F3 = 'F3',
        Key_F4 = 'F4',
        Key_F5 = 'F5',
        Key_F6 = 'F6',
        Key_F7 = 'F7',
        Key_F8 = 'F8',
        Key_F9 = 'F9',
        Key_F10 = 'F10',
        Key_F11 = 'F11',
        Key_F12 = 'F12',
        Key_PRINTSCREEN = 'PRINT SCREEN',
        Key_SCROLLLOCK = 'SCROLL LOCK',
        Key_PAUSE = 'PAUSE',
        Key_INSERT = 'INSERT',
        Key_HOME = 'HOME',
        Key_PAGEUP = 'PAGE UP',
        Key_DELETE = 'DELETE',
        Key_END = 'END',
        Key_PAGEDOWN = 'PAGE DOWN',
        Key_RIGHT = 'RIGHT',
        Key_LEFT = 'LEFT',
        Key_DOWN = 'DOWN',
        Key_UP = 'UP',
        Key_NUMLOCKCLEAR = 'NUM LOCK CLEAR',
        Key_KP_DIVIDE = 'KP_DIVIDE',
        Key_KP_MULTIPLY = 'KP_MULTIPLY',
        Key_KP_MINUS = 'KP_MINUS',
        Key_KP_PLUS = 'KP_PLUS',
        Key_KP_ENTER = 'KP_ENTER',
        Key_KP_1 = 'KP_1',
        Key_KP_2 = 'KP_2',
        Key_KP_3 = 'KP_3',
        Key_KP_4 = 'KP_4',
        Key_KP_5 = 'KP_5',
        Key_KP_6 = 'KP_6',
        Key_KP_7 = 'KP_7',
        Key_KP_8 = 'KP_8',
        Key_KP_9 = 'KP_9',
        Key_KP_0 = 'KP_0',
        Key_KP_PERIOD = 'KP_PERIOD',
        Key_NONUSBACKSLASH = 'NON US BACKSLASH',
        Key_APPLICATION = 'APPLICATION',
        Key_POWER = 'POWER',
        Key_KP_EQUALS = 'KP_EQUALS',
        Key_F13 = 'F13',
        Key_F14 = 'F14',
        Key_F15 = 'F15',
        Key_F16 = 'F16',
        Key_F17 = 'F17',
        Key_F18 = 'F18',
        Key_F19 = 'F19',
        Key_F20 = 'F20',
        Key_F21 = 'F21',
        Key_F22 = 'F22',
        Key_F23 = 'F23',
        Key_F24 = 'F24',
        Key_EXECUTE = 'EXECUTE',
        Key_HELP = 'HELP',
        Key_MENU = 'MENU',
        Key_SELECT = 'SELECT',
        Key_STOP = 'STOP',
        Key_AGAIN = 'AGAIN',
        Key_UNDO = 'UNDO',
        Key_CUT = 'CUT',
        Key_COPY = 'COPY',
        Key_PASTE = 'PASTE',
        Key_FIND = 'FIND',
        Key_MUTE = 'MUTE',
        Key_VOLUMEUP = 'VOLUME UP',
        Key_VOLUMEDOWN = 'VOLUME DOWN',
        Key_KP_COMMA = 'KP_COMMA',
        Key_KP_EQUALSAS400 = 'KP_EQUALSAS400',
        Key_INTERNATIONAL1 = 'INTERNATIONAL 1',
        Key_INTERNATIONAL2 = 'INTERNATIONAL 2',
        Key_INTERNATIONAL3 = 'INTERNATIONAL 3',
        Key_INTERNATIONAL4 = 'INTERNATIONAL 4',
        Key_INTERNATIONAL5 = 'INTERNATIONAL 5',
        Key_INTERNATIONAL6 = 'INTERNATIONAL 6',
        Key_INTERNATIONAL7 = 'INTERNATIONAL 7',
        Key_INTERNATIONAL8 = 'INTERNATIONAL 8',
        Key_INTERNATIONAL9 = 'INTERNATIONAL 9',
        Key_LANG1 = 'LANG 1',
        Key_LANG2 = 'LANG 2',
        Key_LANG3 = 'LANG 3',
        Key_LANG4 = 'LANG 4',
        Key_LANG5 = 'LANG 5',
        Key_LANG6 = 'LANG 6',
        Key_LANG7 = 'LANG 7',
        Key_LANG8 = 'LANG 8',
        Key_LANG9 = 'LANG 9',
        Key_ALTERASE = 'ALT ERASE',
        Key_SYSREQ = 'SYS REQ',
        Key_CANCEL = 'CANCEL',
        Key_CLEAR = 'CLEAR',
        Key_PRIOR = 'PRIOR',
        Key_RETURN2 = 'RETURN 2',
        Key_SEPARATOR = 'SEPARATOR',
        Key_OUT = 'OUT',
        Key_OPER = 'OPER',
        Key_CLEARAGAIN = 'CLEAR AGAIN',
        Key_CRSEL = 'CRSEL',
        Key_EXSEL = 'EXSEL',
        Key_KP_00 = 'KP_00',
        Key_KP_000 = 'KP_000',
        Key_THOUSANDSSEPARATOR = 'THOUSANDS SEPARATOR',
        Key_DECIMALSEPARATOR = 'DECIMAL SEPARATOR',
        Key_CURRENCYUNIT = 'CURRENCY UNIT',
        Key_CURRENCYSUBUNIT = 'CURRENCY SUBUNIT',
        Key_KP_LEFTPAREN = 'KP_LEFTPAREN',
        Key_KP_RIGHTPAREN = 'KP_RIGHTPAREN',
        Key_KP_LEFTBRACE = 'KP_LEFTBRACE',
        Key_KP_RIGHTBRACE = 'KP_RIGHTBRACE',
        Key_KP_TAB = 'KP_TAB',
        Key_KP_BACKSPACE = 'KP_BACKSPACE',
        Key_KP_A = 'KP_A',
        Key_KP_B = 'KP_B',
        Key_KP_C = 'KP_C',
        Key_KP_D = 'KP_D',
        Key_KP_E = 'KP_E',
        Key_KP_F = 'KP_F',
        Key_KP_XOR = 'KP_XOR',
        Key_KP_POWER = 'KP_POWER',
        Key_KP_PERCENT = 'KP_PERCENT',
        Key_KP_LESS = 'KP_LESS',
        Key_KP_GREATER = 'KP_GREATER',
        Key_KP_AMPERSAND = 'KP_AMPERSAND',
        Key_KP_DBLAMPERSAND = 'KP_DBLAMPERSAND',
        Key_KP_VERTICALBAR = 'KP_VERTICALBAR',
        Key_KP_DBLVERTICALBAR = 'KP_DBLVERTICALBAR',
        Key_KP_COLON = 'KP_COLON',
        Key_KP_HASH = 'KP_HASH',
        Key_KP_SPACE = 'KP_SPACE',
        Key_KP_AT = 'KP_AT',
        Key_KP_EXCLAM = 'KP_EXCLAM',
        Key_KP_MEMSTORE = 'KP_MEMSTORE',
        Key_KP_MEMRECALL = 'KP_MEMRECALL',
        Key_KP_MEMCLEAR = 'KP_MEMCLEAR',
        Key_KP_MEMADD = 'KP_MEMADD',
        Key_KP_MEMSUBTRACT = 'KP_MEMSUBTRACT',
        Key_KP_MEMMULTIPLY = 'KP_MEMMULTIPLY',
        Key_KP_MEMDIVIDE = 'KP_MEMDIVIDE',
        Key_KP_PLUSMINUS = 'KP_PLUSMINUS',
        Key_KP_CLEAR = 'KP_CLEAR',
        Key_KP_CLEARENTRY = 'KP_CLEARENTRY',
        Key_KP_BINARY = 'KP_BINARY',
        Key_KP_OCTAL = 'KP_OCTAL',
        Key_KP_DECIMAL = 'KP_DECIMAL',
        Key_KP_HEXADECIMAL = 'KP_HEXADECIMAL',
        Key_LCTRL = 'LCTRL',
        Key_LSHIFT = 'LSHIFT',
        Key_LALT = 'LALT',
        Key_LGUI = 'LGUI',
        Key_RCTRL = 'RCTRL',
        Key_RSHIFT = 'RSHIFT',
        Key_RALT = 'RALT',
        Key_RGUI = 'RGUI',
        Key_MODE = 'MODE',
        Key_AUDIONEXT = 'AUDIONEXT',
        Key_AUDIOPREV = 'AUDIOPREV',
        Key_AUDIOSTOP = 'AUDIOSTOP',
        Key_AUDIOPLAY = 'AUDIOPLAY',
        Key_AUDIOMUTE = 'AUDIOMUTE',
        Key_MEDIASELECT = 'MEDIASELECT',
        Key_WWW = 'WWW',
        Key_MAIL = 'MAIL',
        Key_CALCULATOR = 'CALCULATOR',
        Key_COMPUTER = 'COMPUTER',
        Key_AC_SEARCH = 'AC_SEARCH',
        Key_AC_HOME = 'AC_HOME',
        Key_AC_BACK = 'AC_BACK',
        Key_AC_FORWARD = 'AC_FORWARD',
        Key_AC_STOP = 'AC_STOP',
        Key_AC_REFRESH = 'AC_REFRESH',
        Key_AC_BOOKMARKS = 'AC_BOOKMARKS',
        Key_BRIGHTNESSDOWN = 'BRIGHTNESS DOWN',
        Key_BRIGHTNESSUP = 'BRIGHTNESS UP',
        Key_DISPLAYSWITCH = 'DISPLAY SWITCH',
        Key_KBDILLUMTOGGLE = 'KB DILLUM TOGGLE',
        Key_KBDILLUMDOWN = 'KB DIL LUM DOWN',
        Key_KBDILLUMUP = 'KB DIL LUM UP',
        Key_EJECT = 'EJECT',
        Key_SLEEP = 'SLEEP',
        Key_APP1 = 'APP1',
        Key_APP2 = 'APP2',
        Key_SPECIAL_COUNT = 'SPECIAL_COUNT'
    }
}