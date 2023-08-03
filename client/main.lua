-- On client start, fetch all ESX items as they can only be accessed on the server side for some reason
CreateThread(function()
    while (Framework == nil) do Wait(250) end

    if (Framework == "ESX") then
        ESX.Items = Functions.Callback("zyke_lib:GetItems", false)
    end
end)