dofile_once( "mods/bags_of_many/files/scripts/utils/noita_utils.lua" )

function throw_item(from_x, from_y, to_x, to_y)
    local entity = GetUpdatedEntityID()
    enable_inherit_comps(entity)
    enable_comp_with_tag_in_inventory(entity)
end