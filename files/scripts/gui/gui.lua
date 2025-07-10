dofile_once( "mods/bags_of_many/files/scripts/gui/bag_inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inputs.lua" )

function bags_of_many_ui_setup()
    bags_of_many_bag_gui(bags_mod_state.button_pos_x, bags_mod_state.button_pos_y)
end