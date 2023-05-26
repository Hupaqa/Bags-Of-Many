dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/testing/item_spawner.lua" )
dofile_once( "mods/bags_of_many/files/gui.lua" )
print("Bags of many enabled start a new run to have the items spawn in your world.")

-- Adding translations
local TRANSLATIONS_FILE = "data/translations/common.csv"
local translations = ModTextFileGetContent(TRANSLATIONS_FILE) .. ModTextFileGetContent("mods/bags_of_many/translations/common.csv")
ModTextFileSetContent(TRANSLATIONS_FILE, translations)
ModLuaFileAppend("data/scripts/item_spawnlists.lua", "mods/bags_of_many/files/scripts/bags_of_many_spawn.lua")
TESTING=true

local LOAD_KEY = "BAGS_OF_MANY_LOAD_DONE"
function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    if not GameHasFlagRun(LOAD_KEY) then
        if ModSettingGet("BagsOfMany.starter_loadout") then
            local x, y = get_player_pos()
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_small.xml", x + 30, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_small.xml", x + 50, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_small.xml", x + 70, y)
        end
        if TESTING then
            add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_medium.xml")
            add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_big.xml")
            spawn_bags_for_test()
        end
        GameAddFlagRun(LOAD_KEY)
    end
end

function OnWorldPreUpdate()
    setup_gui()
end

function OnPausedChanged(is_paused, is_inventory_pause)
    button_locked = ModSettingGet("BagsOfMany.locked")
	if not button_locked then
		ModSettingSetNextValue("BagsOfMany.pos_x", button_pos_x, false)
		ModSettingSetNextValue("BagsOfMany.pos_y", button_pos_y, false)
    else
        button_pos_x = ModSettingGet("BagsOfMany.pos_x")
        button_pos_y = ModSettingGet("BagsOfMany.pos_y")
	end
	only_show_bag_button_when_held = ModSettingGet("BagsOfMany.only_show_bag_button_when_held")
    bag_wrap_number = ModSettingGet("BagsOfMany.bag_slots_inventory_wrap")
    bag_ui_red = tonumber(ModSettingGet("BagsOfMany.bag_image_red"))/255
    bag_ui_green = tonumber(ModSettingGet("BagsOfMany.bag_image_green"))/255
    bag_ui_blue = tonumber(ModSettingGet("BagsOfMany.bag_image_blue"))/255
    bag_ui_alpha = tonumber(ModSettingGet("BagsOfMany.bag_image_alpha"))/255
end