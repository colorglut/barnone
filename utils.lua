function tableRemove(t, v)
    local valueIndex

    for i, val in ipairs(t) do
        if val == v then
            valueIndex = i

            break
        end
    end

    return table.remove(t, valueIndex)
end
