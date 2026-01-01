local awaitSystemStarting = ...

local systems = {
    {fileName = "Renewed-Banking", variable = "RENEWED_BANKING"},
    {fileName = "RxBanking", variable = "RX_BANKING"},
    {fileName = "okokBanking", variable = "OKOK_BANKING"}
}

for i = 1, #systems do
    local resState = awaitSystemStarting(systems[i].fileName)

    -- If it's started, we use it
    if (resState == "started") then
        BankingSystem = systems[i].variable
        Functions.debug.internal("^2Using " .. systems[i].fileName .. " as banking system^7")

        break
    end
end