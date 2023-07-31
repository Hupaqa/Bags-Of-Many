function padding_to_center(width_box, height_box, width_entity, height_entity)
    return math.ceil((width_box - width_entity)/2), math.ceil((height_box - height_entity)/2)
end

function string_contains(text, contains)
    return string.find(text, contains) ~= nil
end

function split_string(inputstr, sep)
    sep = sep or "%s"
    local t= {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

function string_table_to_table(inputstr)
    local t={}
    for str in string.gmatch(inputstr, "([^"..",".."]+)") do
        table.insert(t, str)
    end
    if t then
        for i = 1, #t do
            if i == 1 then
                if string.sub(t[i],1,1) == "{" then
                    local new_val = string.sub(t[i],2,#t[i])
                    t[i] = new_val
                end
            end
            if i == #t then
                if string.sub(t[i],#t[i],#t[i]) == "}" then
                    local new_val = string.sub(t[i],1,#t[i]-1)
                    t[i] = new_val
                end
            end
        end
    end
    return t
end

function table_to_string_table(table)
    local str = ""
    if table then
        for i = 1, #table do
            if i == 1 then
                str = str .. "{"
            end
            str = str .. tostring(table[i])
            if i == #table then
                str = str .. "}"
            else
                str = str .. ","
            end
        end
    end
    return str
end

function find_value_in_table(table, value)
    local index_val
    if table then
        for index, val_in_table in ipairs(table) do
            if tonumber(val_in_table) == tonumber(value) then
                index_val = index
            end
        end
    end
    return index_val
end

function remove_value_in_table(table_in, index)
    local t = {}
    for i = 1, #table_in do
        if i ~= index then
            table.insert(t, table_in[i])
        else
            i = i + 1
        end
    end
    return t
end

function calculate_scale(size_x, size_y, sprite_x, sprite_y)
    return size_x/sprite_x, size_y/sprite_y
end

function map_size(map)
    local count = 0
    for _, _ in pairs(map) do
        count = count + 1
    end
    return count
end

function string_to_map(inputstr)
    local t={}
    local size = 0
    for position in string.gmatch(inputstr, "([^"..",".."]+)") do
        local values = {}
        for val in string.gmatch(position, "([^"..":".."]+)") do
            table.insert(values, val)
        end
        t[values[1]] = values[2]
        size = size + 1
    end
    return t, size
end

function map_to_string(map, size)
    local stringified_array = ""
    local count = 0
    for key, value in pairs(map) do
        stringified_array = stringified_array .. key .. ":" .. value
        if count < size then
            stringified_array = stringified_array .. ","
        end
        count = count + 1
    end
    return stringified_array
end

function get_var_storage_with_name(entity_id, name)
    local variable_storages = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    for _, var_storage in ipairs(variable_storages or {}) do
        local storage_name = ComponentGetValue2(var_storage, "name")
        if storage_name == name then
            return var_storage
        end
    end
end

function calculate_grid(length, nb_items, px_rows, px_columns, direction)
    local grid = {x = {}, y = {}}
    if direction == "column" then
        local nb_columns = math.ceil(nb_items/length)
        local nb_rows = length
        if nb_items < length then
            nb_rows = nb_items
        end
        for i = 1, nb_columns do
            local pos_x, pos_y = 0,0
            pos_x = pos_x + (px_columns * i)
            for j = 1, nb_rows do
                pos_y = pos_y + (px_rows * j)
                table.insert(grid.x, pos_x)
                table.insert(grid.y, pos_y)
            end
        end
    else
        local nb_rows = math.ceil(nb_items/length)
        local nb_columns = length
        if nb_items < length then
            nb_columns = nb_items
        end
        for i = 1, nb_rows do
            local pos_x, pos_y = 0,0
            pos_x = pos_x + (px_rows * i)
            for j = 1, nb_columns do
                pos_y = pos_y + (px_columns * j)
                table.insert(grid.x, pos_x)
                table.insert(grid.y, pos_y)
            end
        end
    end
    return grid
end

function calculate_grid_position(length, px_rows, px_columns, direction, nb_position_used)
    local pos_x, pos_y = 0,0
    if direction == "column" then
        local pos_column = math.floor(nb_position_used/length)
        local pos_row = (nb_position_used % length)
        pos_x = pos_column * px_columns
        pos_y = pos_row * px_rows
    else
        local pos_column = (nb_position_used % length)
        local pos_row = math.floor(nb_position_used/length)
        pos_x = pos_column * px_columns
        pos_y = pos_row * px_rows
    end
    return pos_x, pos_y
end


local random = Random
function bags_of_many_uuid()
    local _, _, day, hour, minute, second = GameGetDateAndTimeLocal()
    SetRandomSeed(day + hour + second, minute + second)
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end