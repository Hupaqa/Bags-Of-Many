dofile_once( "mods/bags_of_many/files/scripts/gui/information_table.lua" )
dofile_once( "mods/bags_of_many/files/scripts/gui/vanilla_inventory.lua" )

BAGS_OF_MANY_GUI_STATES = BAGS_OF_MANY_GUI_STATES or {}

-- BAGS INVENTORY GUI STATES
local dragged_item_table = InformationTable:new()
local hovered_item_table = InformationTable:new()
local left_click_table = InformationTable:new()
local right_click_table = InformationTable:new()

-- VANILLA INVENTORY VARIABLES
local vanilla_inventory_table = VanillaInventory:new()

-- ALCHEMY TABLE SPOTS VARIABLES
local left_spot_alchemy = {
    hovered = nil,
    item = nil,
    bag = nil,
}
local right_spot_alchemy = {
    hovered = nil,
    item = nil,
    bag = nil,
}
local combined_spot_alchemy = {
    hovered = nil,
    item = nil,
    bag = nil,
}
local potion_alchemy_content_buttons = {}

BAGS_OF_MANY_GUI_STATES.dragged_item_table = dragged_item_table
BAGS_OF_MANY_GUI_STATES.hovered_item_table = hovered_item_table
BAGS_OF_MANY_GUI_STATES.left_click_table = left_click_table
BAGS_OF_MANY_GUI_STATES.right_click_table = right_click_table
BAGS_OF_MANY_GUI_STATES.vanilla_inventory_table = vanilla_inventory_table
BAGS_OF_MANY_GUI_STATES.left_spot_alchemy = left_spot_alchemy
BAGS_OF_MANY_GUI_STATES.right_spot_alchemy = right_spot_alchemy
BAGS_OF_MANY_GUI_STATES.combined_spot_alchemy = combined_spot_alchemy
BAGS_OF_MANY_GUI_STATES.potion_alchemy_content_buttons = potion_alchemy_content_buttons

return BAGS_OF_MANY_GUI_STATES
