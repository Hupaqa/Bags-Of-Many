function get_player_health()
	local damagemodel = EntityGetFirstComponentIncludingDisabled( get_player(), "DamageModelComponent" )
	local health = 0
	if damagemodel ~= nil then
		health = ComponentGetValue2(damagemodel, "hp")
	end
	return health
end

function get_player_max_health()
	local damagemodels = EntityGetComponent( get_player(), "DamageModelComponent" )
	local maxHealth = 0
	if( damagemodels ~= nil ) then
		for i,v in ipairs(damagemodels) do
			maxHealth = ComponentGetValue2( v, "max_hp" )
			break
		end
	end
	return maxHealth
end

function get_player_flight_left()
	local character_data_comp = EntityGetComponent( get_player(), "CharacterDataComponent" )
	local flying_left = 0
	if( character_data_comp ~= nil ) then
		for i,v in ipairs(character_data_comp) do
			flying_left = ComponentGetValue2( v, "mFlyingTimeLeft" )
			break
		end
	end
	return flying_left
end

function get_player_flight_max()
	local character_data_comp = EntityGetComponent( get_player(), "CharacterDataComponent" )
	local fly_time_max = 0
	if( character_data_comp ~= nil ) then
		for i,v in ipairs(character_data_comp) do
			fly_time_max = ComponentGetValue2( v, "fly_time_max" )
			break
		end
	end
	return fly_time_max
end

function get_player_wand_mana_max(wand)
	local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	local mana_max = 0
	if ability_comp then
		mana_max = ComponentGetValue2(ability_comp,"mana_max")
	end
	return mana_max
end

function get_player_wand_mana(wand)
	local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	local mana = 0
	if ability_comp then
		mana = ComponentGetValue2(ability_comp,"mana")
	end
	return mana
end

function get_player_wand_reload_time_frame(wand)
	local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	local reload_time_frame = 0
	if ability_comp then
		reload_time_frame = ComponentGetValue2(ability_comp,"reload_time_frame")
	end
	return reload_time_frame
end

function get_player_wand_reload_time_frame(wand)
	local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	local reload_time_frame = 0
	if ability_comp then
		reload_time_frame = ComponentGetValue2(ability_comp,"reload_time_frames")
	end
	return reload_time_frame
end

function get_player_wand_reload_next_frame_usable(wand)
	local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	local reload_next_frame_usable = 0
	if ability_comp then
		reload_next_frame_usable = ComponentGetValue2(ability_comp,"mReloadNextFrameUsable")
	end
	return reload_next_frame_usable
end

function get_player_reload_shake()
	local inv_comp = EntityGetFirstComponentIncludingDisabled(get_player(), "InventoryGuiComponent")
	local is_reload_shake = 0
	if inv_comp then
		is_reload_shake = ComponentGetValue2(inv_comp,"mFrameShake_ReloadBar")
	end
	return is_reload_shake
end

function get_player_wallet_target()
	local inv_comp = EntityGetFirstComponentIncludingDisabled(get_player(), "InventoryGuiComponent")
	local wallet_money_target = 0
	if inv_comp then
		wallet_money_target = ComponentGetValue2(inv_comp,"wallet_money_target")
	end
	return wallet_money_target
end

function get_player_has_infinite_wallet()
	local inv_comp = EntityGetFirstComponentIncludingDisabled(get_player(), "InventoryGuiComponent")
	local wallet_infinite = 0
	if inv_comp then
		wallet_infinite = ComponentGetValue2(inv_comp,"mHasReachedInf")
	end
	return wallet_infinite
end

function enable_inherit_comps(entity)
    local inherit_comps = EntityGetComponentIncludingDisabled(entity, "InheritTransformComponent")
    local childs = EntityGetAllChildren(entity)
    for _, child in ipairs(childs or {}) do
        enable_inherit_comps(child)
    end
    for _, inherit_comp in ipairs(inherit_comps or {}) do
        EntitySetComponentIsEnabled(entity, inherit_comp, true)
    end
end

function enable_comp_with_tag_in_inventory(entity)
    local comps = EntityGetAllComponents(entity)
    local childs = EntityGetAllChildren(entity)
    for _, child in ipairs(childs or {}) do
        enable_comp_with_tag_in_inventory(child)
    end
    for _, comp in ipairs(comps or {}) do
        if ComponentHasTag(comp, "enabled_in_inventory") then
            EntitySetComponentIsEnabled(entity, comp, true)
        end
    end
end

function enable_game_effect_in_hand(entity)
	local comps = EntityGetComponentIncludingDisabled(entity, "GameEffectComponent", "enabled_in_hand")
    local childs = EntityGetAllChildren(entity)
    for _, child in ipairs(childs or {}) do
        enable_game_effect_in_hand(child)
    end
    for _, comp in ipairs(comps or {}) do
		EntitySetComponentIsEnabled(entity, comp, true)
    end
end

function clean_bag_components(item)
    local childs = EntityGetAllChildren(item)
	local children_to_delete = {}
    for _, child in ipairs(childs or {}) do
        local name = EntityGetName(child)
        if not (name == "inventory_full" or name == "inventory_quick") then
			table.insert(children_to_delete, child)
        end
    end
	for _, child in ipairs(children_to_delete or {}) do
		EntityKill(child)
	end
end