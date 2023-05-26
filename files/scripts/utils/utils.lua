function padding_to_center(width_box, height_box, width_entity, height_entity)
    return math.ceil((width_box - width_entity)/2), math.ceil((height_box - height_entity)/2)
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
                print("tostring(val_in_table)")
                print(tostring(val_in_table))
                print("tostring(value)")
                print(tostring(value))
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