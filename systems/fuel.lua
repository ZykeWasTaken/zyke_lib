local awaitSystemStarting = ...

local systems = {
    {fileName = "ox_fuel", variable = "OX"},
    {fileName = "LegacyFuel", variable = "LegacyFuel"},
    {fileName = "cdn-fuel", variable = "CDNFuel"},
    {fileName = "lc_fuel", variable = "LCFuel"},
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        FuelSystem = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as fuel system^7")

        break
    end
end