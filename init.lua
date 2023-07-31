dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spells_lookup.lua" )
dofile_once( "mods/bags_of_many/files/scripts/testing/item_spawner.lua" )
dofile_once( "mods/bags_of_many/files/gui.lua" )
print("Bags of many enabled start a new run to have the items spawn in your world.")

bags_mod_state = {
    lookup_spells = {},
    button_pos_x = ModSettingGet("BagsOfMany.pos_x"),
    button_pos_y = ModSettingGet("BagsOfMany.pos_y")
}

-- Adding translations
local TRANSLATIONS_FILE = "data/translations/common.csv"
local translations = ModTextFileGetContent(TRANSLATIONS_FILE) .. ModTextFileGetContent("mods/bags_of_many/translations/common.csv")
ModTextFileSetContent(TRANSLATIONS_FILE, translations)
ModLuaFileAppend("data/scripts/item_spawnlists.lua", "mods/bags_of_many/files/scripts/bags_of_many_spawn.lua")
TESTING=false

local LOAD_KEY = "BAGS_OF_MANY_LOAD_DONE"
function OnPlayerSpawned(player_entity) -- This runs when player entity has been created
    if not GameHasFlagRun(LOAD_KEY) then
        GameAddFlagRun(LOAD_KEY)
        local x, y = get_player_pos()
        if ModSettingGet("BagsOfMany.starter_loadout") then
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_small.xml", x + 30, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_small.xml", x + 50, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_small.xml", x + 70, y)
        end
        -- if TESTING then
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_medium.xml", x + 30, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_big.xml", x + 30, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_medium.xml", x + 50, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x + 50, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x + 50, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x + 50, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x + 50, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_medium.xml", x + 70, y)
        -- EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_big.xml", x + 70, y)
        -- end
        add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_big.xml")
        EntityLoad("mods/bags_of_many/files/entities/inventory_storage.xml", x, y)
        -- spawn_spells_for_test(90)
    end

    -- Load a spell table to find their name with their id
    bags_mod_state.lookup_spells = lookup_spells()
end

function OnWorldPreUpdate()
    bag_of_many_setup_gui()
end

function OnPausedChanged(is_paused, is_inventory_pause)
    bags_mod_state.button_locked = ModSettingGet("BagsOfMany.locked")
	if not bags_mod_state.button_locked then
		ModSettingSetNextValue("BagsOfMany.pos_x", bags_mod_state.button_pos_x, false)
		ModSettingSetNextValue("BagsOfMany.pos_y", bags_mod_state.button_pos_y, false)
    else
        bags_mod_state.button_pos_x = ModSettingGet("BagsOfMany.pos_x")
        bags_mod_state.button_pos_y = ModSettingGet("BagsOfMany.pos_y")
	end
    update_settings()
end