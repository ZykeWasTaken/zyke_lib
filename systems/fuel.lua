local systems = {
    {fileName = "ox_fuel", variable = "OX"},
    {fileName = "LegacyFuel", variable = "LegacyFuel"},
}

for i = 1, #systems do
    if (GetResourceState(systems[i].fileName) == "started") then
        FuelSystem = systems[i].variable

        break
    end
end

for i = 1, #systems do
    AddEventHandler("onResourceStart", function(resName)
        if (resName == systems[i].fileName) then
            FuelSystem = systems[i].variable
        end
    end)
end