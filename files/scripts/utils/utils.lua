-- Returns the (x, y) offset needed to center an image (or rectangle) of size (inner_w, inner_h)
-- inside a box of size (outer_w, outer_h)
---@param outer_w number
---@param outer_h number
---@param inner_w number
---@param inner_h number
---@return integer, integer # pad_x, pad_y
function padding_to_center(outer_w, outer_h, inner_w, inner_h)
    local pad_x = math.floor((outer_w - inner_w) / 2)
    local pad_y = math.floor((outer_h - inner_h) / 2)
    return pad_x, pad_y
end

---@param text string
---@param contains string
---@return boolean
function string_contains(text, contains)
    return string.find(text, contains) ~= nil
end

---@param inputstr string
---@param sep string|nil
---@return table
function split_string(inputstr, sep)
    sep = sep or "%s"
    local t= {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

---@param inputstr string
---@return table
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

-- function table_to_string_table(table)
--     local str = ""
--     if table then
--         for i = 1, #table do
--             if i == 1 then
--                 str = str .. "{"
--             end
--             str = str .. tostring(table[i])
--             if i == #table then
--                 str = str .. "}"
--             else
--                 str = str .. ","
--             end
--         end
--     end
--     return str
-- end

---@param table table
---@param value any
---@return integer|nil
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

---@param table_in table
---@param index integer
---@return table
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

---@param size_x number
---@param size_y number
---@param sprite_x number
---@param sprite_y number
---@return number, number
function calculate_scale(size_x, size_y, sprite_x, sprite_y)
    return size_x/sprite_x, size_y/sprite_y
end

---@param map table
---@return integer
function map_size(map)
    local count = 0
    for _, _ in pairs(map) do
        count = count + 1
    end
    return count
end

---@param inputstr string
---@return table, integer
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

---@param map table
---@param size integer
---@return string
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

---@param entity_id integer
---@param name string
---@return integer|nil
function get_var_storage_with_name(entity_id, name)
    local variable_storages = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
    for _, var_storage in ipairs(variable_storages or {}) do
        local storage_name = ComponentGetValue2(var_storage, "name")
        if storage_name == name then
            return var_storage
        end
    end
end

---@param entity_id integer
---@param name string
---@return integer
function add_var_storage_with_name(entity_id, name)
    if not entity_id or not name then
        return 0
    end
    return EntityAddComponent2(entity_id, "VariableStorageComponent", {
        name=name,
    })
end

---@param length integer
---@param nb_items integer
---@param px_rows number
---@param px_columns number
---@param direction string
---@return table
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

---@param length integer
---@param px_rows number
---@param px_columns number
---@param direction string
---@param nb_position_used integer
---@return number, number
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

---@param table table
---@return table
function reset_table(table)
    for key in pairs(table) do
        table[key] = nil
    end
    return table
end

---@param table table
function print_table(table)
    for key in pairs(table) do
        print(tostring(key))
        print(tostring(table[key]))
    end
end

---@param deg number
---@return number
function deg_to_rad(deg)
    return deg*(math.pi/180)
end

---@param pos_init number
---@return number
function petri_offset_func(pos_init)
    return (math.cos(pos_init * 3.1415)+1) * 0.5 * math.sin(pos_init * 30)
end

---@param xml_path string
---@return string|nil
function extract_png_file_from_xml(xml_path)
    if not xml_path or xml_path == "" then return nil end
    local content = ModTextFileGetContent(xml_path)
    if not content then return nil end
    -- Look for <Sprite ... image_file="..." ... />
    local png = string.match(content, 'image_file="([^"]+%.png)"')
    return png
end