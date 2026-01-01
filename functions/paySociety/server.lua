---@param name string
---@param amount number
---@return boolean @success
function Functions.paySociety(name, amount)
    if (BankingSystem == "RENEWED_BANKING") then
        return exports['Renewed-Banking']:addAccountMoney(name, amount)
    elseif (BankingSystem == "RX_BANKING") then
        return exports["RxBanking"]:AddSocietyMoney(name, amount, "payment", nil, nil)
    elseif (BankingSystem == "OKOK_BANKING") then
        return exports["okokBanking"]:AddMoney(name, amount)
    elseif (BankingSystem == "BABLO_BANKING") then
        local res = exports["bablo-banking"]:AddSocietyMoney(name, amount)

        return res?.success == true
    end

    if (Framework == "QB") then
        -- An account is created if the target does not already exist
        exports["qb-banking"]:AddMoney(name, amount)

        return true -- Always returns true
    end

    if (Framework == "ESX") then
        local p = promise.new()

        TriggerEvent("esx_addonaccount:getSharedAccount", name, function(account)
            if (account) then
                account.addMoney(amount)
            end

            p:resolve(account ~= nil)
        end)

        return Citizen.Await(p)
    end

    return false
end

return Functions.paySociety