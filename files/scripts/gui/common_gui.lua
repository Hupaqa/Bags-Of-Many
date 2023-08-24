-- GUI ID SECTION
bag_of_many_current_id = 1
bag_of_many_reserved_ids = {}
-- ID
function bags_of_many_new_id()
    for i = 1, #bag_of_many_reserved_ids do
        if bag_of_many_reserved_ids[i] == bag_of_many_current_id + 1 then
            bag_of_many_current_id = bag_of_many_current_id + 1
        end
    end
    bag_of_many_current_id = bag_of_many_current_id + 1
    return bag_of_many_current_id
end
function bags_of_many_reset_id()
    bag_of_many_current_id = 1
end
function bags_of_many_current_id()
    return bag_of_many_current_id
end
function bags_of_many_reserve_id(id)
    table.insert(bag_of_many_reserved_ids, id)
end
function bags_of_many_reset_reserved_ids()
    bag_of_many_reserved_ids = {}
end