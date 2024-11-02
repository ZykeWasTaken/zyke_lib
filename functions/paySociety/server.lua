---@param name string
---@param amount number
---@return boolean @success
function Functions.paySociety(name, amount)
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