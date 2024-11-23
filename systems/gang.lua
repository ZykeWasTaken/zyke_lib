local system = nil
local systems = {
    {fileName = "zyke_gangs", variable = "zyke"}
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        system = systems[i].variable
        break
    end
end

if (not system) then
    for i = 1, #systems do
        AddEventHandler("onResourceStart", function(resName)
            if (resName == systems[i].fileName) then
                system = systems[i].variable
            end
        end)
    end
end

return system