Functions = {}

function Functions.CopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Functions.CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Functions.Debug(msg, enabled)
    if (enabled == true) then
        print("^4[Debug]: ^7" .. msg)
    end
end

function Functions.CountTable(tbl)
    local count = 0

    for k, v in pairs(tbl) do
        count = count + 1
    end

    return count
end

-- Formatting the item(s) correctly, no matter what the input is
-- Used for item checking, adding and removing
function Functions.FormatItems(item, amount)
    local formatted = {}

    if (Config.Framework == "QBCore") then
        if (type(item) == "string") then
            formatted[item] = amount or 1
        else
            if (item.name) or (item.item) then
                item = {item}
            end

            for k,v in pairs(item) do
                local _item = (type(v) == "number" and k) or v.name or v.item
                local _amount = (type(v) == "number" and v) or v.amount or v.count or 1

                formatted[_item] = formatted[_item] and formatted[_item] + _amount or _amount
            end
        end
    else
        if (type(item) == "string") then
            table.insert(formatted, {
                name = item,
                count = amount or 1
            })
        else
            if (item.name) or (item.item) then
                item = {item}
            end

            for k,v in pairs(item) do
                local _item = (type(v) == "number" and k) or v.name or v.item
                local _amount = (type(v) == "number" and v) or v.amount or v.count or 1

                table.insert(formatted, {
                    name = _item,
                    count = _amount
                })
            end
        end
    end

    return formatted
end

function Functions.GetFramework()
    return Config.Framework
end

function Functions.GetWeaponType()
    return Config.WeaponType
end
    