dofile_once( "mods/bags_of_many/files/scripts/gui/bag_inventory.lua" )
dofile_once( "mods/bags_of_many/files/scripts/utils/inputs.lua" )

function bags_of_many_ui_setup()
    if type(bags_mod_state.button_pos_x) == "number" and type(bags_mod_state.button_pos_y) == "number" then
        bags_of_many_bag_gui(bags_mod_state.button_pos_x, bags_mod_state.button_pos_y)
    else
        print_error("Bags of Many: Button position is not set correctly. Please check your settings. You might need to reset the mod settings file.")
    end
end