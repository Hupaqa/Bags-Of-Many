dofile_once( "mods/bags_of_many/files/scripts/utils/inventory.lua" )


function spawn_items_for_test()
    local x, y = get_player_pos()
    local items_to_spawn = {
        "data/entities/items/books/base_book.xml",
        "data/entities/items/books/book_corpse.xml",
        "data/entities/items/orbs/orb_00.xml",
        "data/entities/items/pickup/runestones/runestone_null.xml",
        "data/entities/items/pickup/sun/sunseed.xml",
        "data/entities/items/pickup/beamstone.xml",
        "data/entities/items/pickup/bloodmoney_10000.xml",
        "data/entities/items/pickup/brimstone.xml",
        "data/entities/items/pickup/broken_wand.xml",
        "data/entities/items/pickup/chest_random.xml",
        "data/entities/items/pickup/essence_fire.xml",
        "data/entities/items/pickup/evil_eye.xml",
        "data/entities/items/pickup/goldnugget_1000.xml",
        "data/entities/items/pickup/gourd.xml",
        "data/entities/items/pickup/greed_curse.xml",
        "data/entities/items/pickup/heart.xml",
        "data/entities/items/pickup/heart_fullhp.xml",
        "data/entities/items/pickup/musicstone.xml",
        "data/entities/items/pickup/physics_die.xml",
        "data/entities/items/pickup/poopstone.xml",
        "data/entities/items/pickup/powder_stash.xml",
        "data/entities/items/pickup/random_card.xml",
        "data/entities/items/pickup/safe_haven.xml",
        "data/entities/items/pickup/spell_refresh.xml",
        "data/entities/items/pickup/stonestone.xml",
        "data/entities/items/pickup/thunderstone.xml",
        "data/entities/items/pickup/wandstone.xml",
        "data/entities/items/pickup/waterstone.xml",
    }
    
    for i, item in ipairs(items_to_spawn or {}) do
        EntityLoad(item, x - 20 * (i), y)
    end
end

function spawn_spells_for_test(nb_of_spells)
    local x, y = get_player_pos()
    for i = 0, nb_of_spells do
        EntityLoad("data/entities/items/pickup/random_card.xml", x+i, y)
    end
end