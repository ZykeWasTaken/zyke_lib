-- Might have to add CreateThread because of delay in searching for framework?

---@param item string
---@param func function
function Functions.registerUsableItem(item, func)
    if (Framework == "ESX") then
        ESX.RegisterUsableItem(item, function(source, itemName, itemData)
            if (Inventory == "QS") then
                itemData = itemName
            elseif (Inventory == "TGIANN") then
                itemData = itemName
            end

            func(source, Formatting.formatItem(itemData))
        end)
    elseif (Framework == "QB") then
        QB.Functions.CreateUseableItem(item, function(source, itemData)
            func(source, Formatting.formatItem(itemData))
        end)
    end
end

return Functions.registerUsableItem