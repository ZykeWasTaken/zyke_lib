local systems = {
    {fileName = "zyke_gangs", variable = "zyke"}
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        GangSystem = systems[i].variable

        break
    end
end

if (not GangSystem) then
    for i = 1, #systems do
        AddEventHandler("onResourceStart", function(resName)
            if (resName == systems[i].fileName) then
                GangSystem = systems[i].variable
            end
        end)
    end
end