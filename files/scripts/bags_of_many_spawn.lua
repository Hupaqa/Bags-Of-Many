dofile_once("data/scripts/lib/utilities.lua")

local lower_bound = {}
local lower_bound_index
local bags_percent_of_potion = tonumber(ModSettingGet("BagsOfMany.bag_ratio_vs_potions"))/100
local bags_list  = {
    {
        probability = tonumber(ModSettingGet("BagsOfMany.bag_spells_spawn_chance"))/100,
        bags = {
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_spells_small_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_spells_small.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_spells_medium_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_spells_medium.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_spells_big_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_spells_big.xml"},
        }
    },
    {
        probability = tonumber(ModSettingGet("BagsOfMany.bag_potions_spawn_chance"))/100,
        bags = {
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_potions_small_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_potions_small.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_potions_medium_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_potions_medium.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_potions_big_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_potions_big.xml"},
        }
    },
    {
        probability = tonumber(ModSettingGet("BagsOfMany.bag_universal_spawn_chance"))/100,
        bags = {
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_universal_small_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_universal_small.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_universal_medium_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_universal_medium.xml"},
            {probability = tonumber(ModSettingGet("BagsOfMany.bag_universal_big_spawn_chance"))/100, entity_path = "mods/bags_of_many/files/entities/bags/bag_universal_big.xml"},
        }
    }
}

function pick_bag(data, x, y)
    local ox = data.offset_x or 0
    local oy = data.offset_y or 0

    local rnd = random_create( x, y)
    local entity_type = pick_random_from_table_weighted(rnd, bags_list)
    local entity_picked = pick_random_from_table_weighted(rnd, entity_type.bags)
    EntityLoad( entity_picked.entity_path, x + ox, y + oy )
end

for index, spawn in ipairs(spawnlists.potion_spawnlist.spawns) do
    if lower_bound.min == nil or (spawn.value_min ~= nil and lower_bound.min > spawn.value_min) then
        lower_bound.min = spawn.value_min
        lower_bound.max = spawn.value_max
        lower_bound_index = index
    end
end

local bags_chance = lower_bound.max * bags_percent_of_potion

-- print(tostring("BAGS SPAWN CHANCE"))
-- print(tostring((bags_chance/65)*100))

local bags_spawn = {
    value_min = 1,
    value_max = math.floor((bags_chance)-1),
    load_entity_func = pick_bag,
    offset_y = -2,
}

spawnlists.potion_spawnlist.spawns[lower_bound_index].value_min = math.floor(bags_chance)
table.insert(spawnlists.potion_spawnlist.spawns, bags_spawn)