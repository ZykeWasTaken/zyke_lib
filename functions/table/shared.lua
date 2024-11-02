Functions.table = {}

---@param tbl table
---@return table
function Functions.table.copy(tbl)
    local copy = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Functions.table.copy(v)
        else
            copy[k] = v
        end
    end

    return copy
end

---@param tbl table
---@return table
function Functions.table.deepCopy(tbl)
    local origType = type(tbl)
    local copy

    if (origType == "table") then
        copy = {}

        for origKey, origValue in next, tbl, nil do
            copy[Functions.table.deepCopy(origKey)] = Functions.table.deepCopy(origValue)
        end

        setmetatable(copy, Functions.table.deepCopy(getmetatable(tbl)))
    else -- number, string, boolean, etc
        copy = tbl
    end

    return copy
end

---@param tbl table
---@return integer
function Functions.table.count(tbl)
    if (not tbl) then
        Functions.internalDebug("Attempted to count", type(tbl), "table.")

        return 0
    end

    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

---@param tbl table -- Needs to be an array
---@param desiredString string
---@return boolean, number | nil
function Functions.table.contains(tbl, desiredString)
    if (not tbl) then error("Attempt to scan non-existent table") end

    for idx, string in pairs(tbl) do
        if (desiredString == string) then
            return true, idx
        end
    end

    return false, nil
end

---@param tbl table
---@param predicate function
---@return any, number | string | nil
function Functions.table.find(tbl, predicate)
    if (not tbl) or (type(tbl) ~= "table") then error("Attempt to scan non-existent table") end

    for key, value in pairs(tbl) do
        if (predicate(value)) then
            return value, key
        end
    end

    return nil, nil
end

---@param tbl1 table
---@param tbl2 table
---@return table
function Functions.table.combine(tbl1, tbl2)
    local result = {}

    for k, v in pairs(tbl1) do
        result[k] = v
    end

    for k, v in pairs(tbl2) do
        result[k] = v
    end

    return result
end

---@param tbl table
---@return string
function Functions.table.getRandomDictionaryKey(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys+1] = key
    end

    return keys[math.random(1, #keys)]
end

---@param tbl any[]
---@return table any[]
function Functions.table.ensureUniqueEntries(tbl)
    local seen = {}
    local uniqueEntries = {}

    for _, value in pairs(tbl) do
        if not (seen[value]) then
            table.insert(uniqueEntries, value)
            seen[value] = true
        end
    end

    return uniqueEntries
end

---@param tbl table
---@return boolean
function Functions.table.isArray(tbl)
    if (next(tbl) == nil) then return false end

    for key in pairs(tbl) do
        if (type(key) ~= "number") then return false end
    end

    return true
end

---@param tbl table
---@return boolean
function Functions.table.doesTableHaveEntries(tbl)
    for _ in pairs(tbl) do return true end

    return false
end

return Functions.table