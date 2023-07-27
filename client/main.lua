-- On client start, fetch all ESX items as they can only be accessed on the server side for some reason
CreateThread(function()
    while (Framework == nil) do Wait(100) end

    if (Framework == "ESX") then
        Functions.Callback("zyke_lib:GetItems", function(items)
            ESX.Items = items
        end)
    end
end)