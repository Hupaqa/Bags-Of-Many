---@return table<string, table>
function lookup_spells()
    dofile_once("data/scripts/gun/gun_actions.lua")
    local lookup = {}
    for i = 1, #actions do
        lookup[actions[i].id] = actions[i]
    end
    return lookup
end