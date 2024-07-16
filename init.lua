dofile_once( "data/scripts/game_helpers.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spawn.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/spells_lookup.lua" )
dofile_once( "mods/bags_of_many/files/scripts/testing/item_spawner.lua" )
dofile_once( "mods/bags_of_many/files/scripts/gui/gui.lua" )
print("Bags of many enabled start a new run to have the items spawn in your world.")

bags_mod_state = {
    get_file_content = nil,
    is_file_exist = nil,
    xml_file_png = {},
    lookup_spells = {},
    bag_pickup_override = nil,
    button_pos_x = ModSettingGet("BagsOfMany.pos_x"),
    button_pos_y = ModSettingGet("BagsOfMany.pos_y"),
    alchemy_pos_x = ModSettingGet("BagsOfMany.alchemy_pos_x"),
    alchemy_pos_y = ModSettingGet("BagsOfMany.alchemy_pos_y"),
    alchemy_amount_transfered = 10,
    left_mouse_down_frame = 0,
    left_mouse_up_frame = 0,
}

-- Adding translations
local TRANSLATIONS_FILE = "data/translations/common.csv"
local translations = ModTextFileGetContent(TRANSLATIONS_FILE) .. ModTextFileGetContent("mods/bags_of_many/translations/common.csv")
ModTextFileSetContent(TRANSLATIONS_FILE, translations)

-- ADDING SPAWN CHANCE
ModLuaFileAppend("data/scripts/item_spawnlists.lua", "mods/bags_of_many/files/scripts/bags_of_many_spawn.lua")

function OnModInit()
    bags_mod_state.get_file_content = ModTextFileGetContent
    bags_mod_state.is_file_exist = ModDoesFileExist
end

local LOAD_KEY = "BAGS_OF_MANY_LOAD_DONE"
local SHOWCASE_LOAD_KEY = "BAGS_OF_MANY_SHOWCASE_LOAD_DONE"
function OnPlayerSpawned(player_entity) -- This runs when player entity has been created
    if not GameHasFlagRun(LOAD_KEY) then
        GameAddFlagRun(LOAD_KEY)
        local x, y = get_player_pos()
        if ModSettingGet("BagsOfMany.starter_loadout") then
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_small.xml", x + 30, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_small.xml", x + 50, y)
            EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_small.xml", x + 70, y)
        end
        -- spawn_items_testing(x, y)
        -- add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_medium.xml")
        -- print(tostring("====================================LOADING WAND===================================="))
        -- local x, y = get_player_pos()
        -- EntityLoad("data/entities/items/starting_wand_rng.xml", x, y)
        -- EntityLoad("data/entities/items/wands/wand_good/wand_good_3.xml", x, y)
        -- add_item_to_inventory(player_entity, "mods/bags_of_many/files/entities/bags/bag_universal_big.xml")
            -- spawn_spells_for_test(90)
        --     spawn_bags_for_test()
        -- end
    end
    if not GameHasFlagRun(SHOWCASE_LOAD_KEY) then
        GameAddFlagRun(SHOWCASE_LOAD_KEY)
        local x, y = get_player_pos()
        if ModSettingGet("BagsOfMany.showcase_loadout") then
            spawn_items_showcase(x, y)
        end
    end
    -- Load a spell table to find their name with their id
    bags_mod_state.lookup_spells = lookup_spells()
end

function spawn_items_testing(x, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_medium.xml", x + 30, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_big.xml", x + 30, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_medium.xml", x + 50, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", x + 50, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_medium.xml", x + 70, y)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_big.xml", x + 70, y)
end

function spawn_items_showcase(x, y)
    local height = -120
    local position_x = 400
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_small.xml", position_x - 20, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_medium.xml", position_x - 10, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_spells_big.xml", position_x, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_small.xml", position_x + 40, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_medium.xml", position_x + 50, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_big.xml", position_x + 60, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_small.xml", position_x + 100, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_medium.xml", position_x + 110, height)
    EntityLoad("mods/bags_of_many/files/entities/bags/bag_universal_big.xml", position_x + 120, height)
end

function OnWorldPreUpdate()
end

function OnWorldPostUpdate()
    bags_of_many_ui_setup()
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
    bags_mod_state.alchemy_pos_x = ModSettingGet("BagsOfMany.alchemy_pos_x")
    bags_mod_state.alchemy_pos_y = ModSettingGet("BagsOfMany.alchemy_pos_y")
end