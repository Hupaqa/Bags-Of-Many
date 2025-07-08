dofile_once("data/scripts/gun/gun_enums.lua")

local spells_type_sprite = {
	[ACTION_TYPE_PROJECTILE] = "data/ui_gfx/inventory/item_bg_projectile.png",
	[ACTION_TYPE_STATIC_PROJECTILE] = "data/ui_gfx/inventory/item_bg_static_projectile.png",
	[ACTION_TYPE_MODIFIER] = "data/ui_gfx/inventory/item_bg_modifier.png",
	[ACTION_TYPE_DRAW_MANY] = "data/ui_gfx/inventory/item_bg_draw_many.png",
	[ACTION_TYPE_MATERIAL] = "data/ui_gfx/inventory/item_bg_material.png",
	[ACTION_TYPE_OTHER] = "data/ui_gfx/inventory/item_bg_other.png",
	[ACTION_TYPE_UTILITY] = "data/ui_gfx/inventory/item_bg_utility.png",
	[ACTION_TYPE_PASSIVE] = "data/ui_gfx/inventory/item_bg_passive.png",
}

---@param entity integer
---@return table<string, any>
function get_wand_info(entity)
    local ability_comp = EntityGetFirstComponentIncludingDisabled(entity, "AbilityComponent")
    local wand_info = {}
    if ability_comp then
        wand_info.shuffle = ComponentObjectGetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty")
        wand_info.actions_per_round = ComponentObjectGetValue2(ability_comp, "gun_config", "actions_per_round")
        wand_info.cast_delay = ComponentObjectGetValue2(ability_comp, "gunaction_config", "fire_rate_wait")
        wand_info.recharge_time = ComponentObjectGetValue2(ability_comp, "gun_config", "reload_time")
        wand_info.mana_max = ComponentGetValue2(ability_comp,"mana_max")
        wand_info.mana_charge_speed = ComponentGetValue2(ability_comp,"mana_charge_speed")
        wand_info.capacity = ComponentObjectGetValue2(ability_comp, "gun_config", "deck_capacity")
        wand_info.spread = ComponentObjectGetValue2(ability_comp, "gunaction_config", "spread_degrees")
    end
    return wand_info
end

---@param entity integer
---@return string|nil
function get_spell_action_id(entity)
    local item_action_component = EntityGetComponentIncludingDisabled(entity, "ItemActionComponent")
    if item_action_component then
        return ComponentGetValue2(item_action_component[1], "action_id")
    end
    return nil
end

---@param entity integer
---@return integer|nil
function get_spell_type(entity)
    local action_id = get_spell_action_id(entity)
    if action_id and bags_mod_state.lookup_spells[action_id] then
        return bags_mod_state.lookup_spells[action_id].type
    end
    return nil
end

---@param entity integer
---@return string|nil
function get_spell_type_sprite(entity)
    local type = get_spell_type(entity)
    if type then
        return spells_type_sprite[type]
    end
    return nil
end