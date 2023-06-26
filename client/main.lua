-- On client start, fetch all ESX items as they can only be accessed on the server side for some reason
CreateThread(function()
    if (Config.Framework == "ESX") then
        Functions.Callback("zyke_lib:GetItems", function(items)
            ESX.Items = items
        end)
    end
end)