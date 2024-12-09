local entity_id = GetUpdatedEntityID()
if not entity_id  or entity_id==0 then return end

local x, y = EntityGetTransform(entity_id)
if x and y then
EntityLoad("mods/bags_of_many/files/entities/bags/bag_potions_small.xml",x,y)
end
