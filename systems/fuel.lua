local fuel = nil

local systems = {
    {fileName = "ox_fuel", variable = "OX"},
    {fileName = "LegacyFuel", variable = "LegacyFuel"},
}

for i = 1, #systems do
    local isStarted = GetResourceState(systems[i].fileName) == "started"

    if (isStarted) then
        fuel = systems[i].variable

        -- Functions.internalDebug("Found", fuel)

        break
    end
end

return fuel