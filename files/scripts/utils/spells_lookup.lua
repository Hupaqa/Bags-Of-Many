dofile_once("data/scripts/gun/gun_actions.lua")

function lookup_spells()
    local lookup = {}
    for i = 1, #actions do
        lookup[actions[i].id] = actions[i]
        print(tostring(actions[i].id))
    end
    return lookup
end