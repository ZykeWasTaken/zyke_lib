function Functions.LoadModel(model)
    local originalModel = model
    model = joaat(model)

    local doesExist = IsModelValid(model)
    if (not doesExist) then print("^1This model does not exist: " .. originalModel .. " (" .. model .. ")^0") return false end

    RequestModel(model)
    while (not HasModelLoaded(model)) do Wait(1) end

    return true
end

function Functions.LoadAnim(dict)
    local doesExist = DoesAnimDictExist(dict)
    if (not doesExist) then error("This dictionary does not exist " .. tostring(dict)) return false end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end

    return true
end

Functions.LoadDict = Functions.LoadAnim

function Functions.DrawMissionText(text, height, length)
	-- 0.96, 0.5 = bottom centered
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(length ~= nil and length or 0.5, height ~= nil and height or 0.96)
end

function Functions.Draw3DText(coords, text, scale, rgba)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    rgba = rgba or {}

    SetTextScale(scale or 0.3, scale or 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(rgba.r or 255, rgba.g or 255, rgba.b or 255, rgba.a or 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

-- The talk message top left
function Functions.HelpNoti(msg, thisFrame, beep, duration)
    AddTextEntry('helpNotification', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('helpNotification', false)
    else
        if beep == nil then
            beep = true
        end
        BeginTextCommandDisplayHelp('helpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

function Functions.HasItem(item, amount)
    amount = amount or 1

    if (Framework == "QBCore") then
        local formatted = Functions.FormatItems(item, amount)

        if (Inventory == "ox_inventory") then
            for name, _amount in pairs(formatted) do
                local hasItem = QBCore.Functions.HasItem(name, _amount)

                if (hasItem == false) then return false end
            end

            return true
        else
            local hasItem = QBCore.Functions.HasItem(formatted)
            return hasItem
        end
    elseif (Framework == "ESX") then
        local formatted = Functions.FormatItems(item, amount)
        local hasItems = true

        -- Due to recent changes in ESX, it broke the old standard way of checking items in certain scenarios, like using ox_inventory
        -- To fix this, we pasted the old method that works
        local function esxSearchInventory(items, count)
            if type(items) == 'string' then
                items = {items}
            end

            local returnData = {}
            local itemCount = #items

            for i = 1, itemCount do
                local itemName = items[i]
                returnData[itemName] = count and 0

                for _, _item in pairs(Functions.GetPlayerData().inventory) do
                    if _item.name == itemName then
                        if count then
                            returnData[itemName] = returnData[itemName] + _item.count
                        else
                            returnData[itemName] = _item
                        end
                    end
                end
            end

            if next(returnData) then
                return itemCount == 1 and returnData[items[1]] or returnData
            end
        end

        for itemIdx, itemData in pairs(formatted) do
            local hasItem = esxSearchInventory(itemData.name, itemData.count)

            if not hasItem or hasItem == 0 then
                hasItems = false
            end
        end

        return hasItems
    end
end

function Functions.Notify(msg, type, length)
    if (Framework == "QBCore") then
        QBCore.Functions.Notify(msg, type, length)
    elseif (Framework == "ESX") then
        if (type == "primary") then type = "info" end

        ESX.ShowNotification(msg, type, length)
    end
end

function Functions.ProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    local success = false

    if (type(name) == "table") then
        label = name.label
        duration = name.duration
        useWhileDead = name.useWhileDead
        canCancel = name.canCancel
        disableControls = name.disableControls
        animation = name.animation
        prop = name.prop
        propTwo = name.propTwo
        onFinish = name.onFinish
        onCancel = name.onCancel
        name = name.name
    end

    if (Config.Progressbar == "ox_lib") then
        local state = lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            anim = {
                dict = animation?.animDict,
                clip = animation?.anim,
                flag = animation?.flag or 49,
            }
        })

        success = state
        if (state == true) then
            if (onFinish) then
                onFinish()
            end
        else
            if (onCancel) then
                onCancel()
            end
        end
    else
        canCancel = canCancel or false -- QB requires this to have a set value
        disableControls = disableControls or {} -- QB requires this to have a set value

        if (Framework == "QBCore") then
            QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, function()
                success = true
                onFinish()
            end, onCancel)
        elseif (Framework == "ESX") then
            ESX.Progressbar(label, duration, {
                animation = animation and {
                    type = animation?.type,
                    dict = animation?.animDict,
                    lib = animation?.anim,
                },
                FreezePlayer = disableControls and true or false,
                onFinish = function()
                    success = true
                    onFinish()
                end,
                onCancel = onCancel
            })
        end
    end

    return success
end

function Functions.PlayAnim(ped, dict, anim, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ)
    TaskPlayAnim(ped or PlayerPedId(), dict, anim, blendInSpeed or 8.0, blendOutSpeed or 8.0, duration, flag or 0, playbackRate or 1.0, lockX or false, lockY or false, lockZ or false)
end

function Functions.Callback(name, cb, ...)
    local invoker = GetInvokingResource()
    Functions.Debug("Ran callback: " .. name, Config.Debug, invoker)

    local promise = promise.new()
    if (Framework == "QBCore") then
        -- Due to how QBCore is built, you can't run callbacks back to back, you need to have them slightly apart
        Wait(1)

        QBCore.Functions.TriggerCallback(name, function(res)
            if (type(cb) == "table") then
                cb(res)
            end

            promise:resolve(res)
        end, ...)
    elseif (Framework == "ESX") then
        ESX.TriggerServerCallback(name, function(res)
            if (type(cb) == "table") then
                cb(res)
            end

            promise:resolve(res)
        end, ...)
    end

    Citizen.Await(promise)
    if (cb == false) then
        -- local data = promise.value

        -- if (data == nil) then
        --     return promise
        -- else
        --     return data
        -- end

        return promise.value
    end
end

function Functions.GetPlayerData()
    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayerData()
    elseif (Framework == "ESX") then
        return ESX.GetPlayerData()
    end
end

function Functions.GetMoney(moneyType)
    moneyType = moneyType == nil and "cash" or moneyType -- If no moneyType is given, we're using "cash" as default

    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayerData().money[moneyType]
    elseif (Framework == "ESX") then
        moneyType = moneyType == "cash" and "money" or moneyType -- ESX uses "money" instead of "cash", so we're converting it here
        moneyType = moneyType == "dirty_cash" and "black_money" or moneyType -- ESX uses "black_money" instead of "dirty_cash", so we're converting it here

        local accounts = Functions.GetPlayerData().accounts
        for _, account in pairs(accounts) do
            if (account.name == moneyType) then
                return account.money
            end
        end

        return 0
    end
end

function Functions.GetIdentifier()
    if (Framework == "QBCore") then
        return Functions.GetPlayerData().citizenid
    elseif (Framework == "ESX") then
        return Functions.GetPlayerData().identifier
    end
end

function Functions.OpenInventory(type, invId, other)
    type = type or "stash"
    if (Inventory == "ox_inventory") then
        return exports["ox_inventory"]:openInventory(type, invId)
    end

    if (Framework == "QBCore") then
        TriggerServerEvent("inventory:server:OpenInventory", type, invId, {
            maxweight = other?.maxweight or 4000,
            slots = other?.slots or 20,
        })
        TriggerEvent("inventory:client:SetCurrentStash", invId)
    end
end

function Functions.GetJob()
    if (Framework == "QBCore") then
        local details = Functions.GetPlayerData()?.job
        if (not details) then return nil end

        return Functions.FormatJob(details)
    elseif (Framework == "ESX") then
        local details = Functions.GetPlayerData()?.job
        if (not details) then return nil end

        return Functions.FormatJob(details)
    end
end

function Functions.IsJob(job)
    if (type(job) == "string") then
        return Functions.GetJob().name == job
    elseif (type(job) == "table") then
        local plyJobName = Functions.GetJob()?.name
        for _, jobName in pairs(job) do
            local isJob = plyJobName == jobName

            if (isJob) then return true end
        end
    end

    return false
end

function Functions.IsGang(gang)
    if (type(gang) == "string") then
        return Functions.GetGang().name == gang
    elseif (type(gang) == "table") then
        for _, gangName in pairs(gang) do
            local isGang = Functions.GetGang()?.name == gangName

            if (isGang) then return true end
        end
    end

    return false
end

-- Same as above, but for gangs
function Functions.GetGang()
    if (Framework == "QBCore") then
        local details = Functions.GetPlayerData()?.gang
        if (not details) then return nil end

        return Functions.FormatGang(details)
    elseif (Framework == "ESX") then
        if (GangScript == "zyke_gangphone") then
            local details = exports["zyke_gangphone"]:GetPlayerGangDetails()
            if (not details) then return nil end

            return Functions.FormatGang(details)
        end

        return nil -- ESX doesn't have a gang system, so this will always return nil, change this if you're running one
    end
end

---@param disableBundling boolean? -- If set to true, it will not bundle item amounts with the same name (Read the formatting functions for full details)
function Functions.GetPlayerItems(disableBundling)
    if (Framework == "QBCore") then
        local items = Functions.GetPlayerData().items

        return Functions.FormatItemsFetch(items, disableBundling)
    elseif (Framework == "ESX") then
        local items = Functions.GetPlayerData().inventory -- Not tested (Not in use for any active releases yet)

        return Functions.FormatItemsFetch(items, disableBundling)
    end
end

---@param name string
---@param items table? -- Optional way to get your items, pass in a table and save performance from constant fetching
---@param firstOnly boolean? -- Set to true to return the first item found, instead of an array containing all item tables that match the name
---@param disableBundling boolean? -- If set to true, it will not bundle item amounts with the same name (Read the formatting functions for full details)
---@param metadata table
---@return table | nil
function Functions.GetPlayerItemByName(name, items, firstOnly, disableBundling, metadata)
    local playerItems = items or Functions.GetPlayerItems(disableBundling)
    local foundItems = {}

    for _, itemData in pairs(playerItems) do
        if (itemData.name == name) then
            if (metadata and type(metadata) == "table") then -- TODO: Add QB support
                for metaName, metaValue in pairs(metadata) do
                    if (not itemData?.metadata?[metaName] or itemData?.metadata?[metaName] ~= metaValue) then
                        goto endOfLoop
                    end
                end
            end

            if (firstOnly) then return itemData end

            foundItems[#foundItems+1] = itemData
        end

        ::endOfLoop::
    end

    return #foundItems > 0 and foundItems or nil
end

function Functions.GetClosestPlayer()
    if (Framework == "QBCore") then
        return QBCore.Functions.GetClosestPlayer()
    elseif (Framework == "ESX") then
        return ESX.GetClosestPlayer() -- Not tested (Not in use for any active releases yet)
    end
end

-- Simply checks if you are dead
-- You might need to change this if you a custom death script
function Functions.IsPlayerDead()
    local ped = PlayerPedId()
    if (DeathScript == "wasabi_ambulance") then
        return exports["wasabi_ambulance"]:isPlayerDead(GetPlayerServerId(PlayerId()))
    end

    if (Framework == "QBCore") then
        local plyData = Functions.GetPlayerData()

        return plyData.metadata.isdead or plyData.metadata.inlaststand
    elseif (Framework == "ESX") then
        return IsEntityDead(ped)
    end
end

function Functions.GetPlayers()
    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayers()
    elseif (Framework == "ESX") then
        return ESX.Game.GetPlayers()
    end
end

---@param server boolean? @ Whether to fetch the players from the server or not, clients heavily limit how far you can see ~350 units
function Functions.GetPlayersServerId(server)
    local players = nil

    if (server) then
        return Functions.Callback("zyke_lib:GetPlayers", false)
    else
        players = Functions.GetPlayers()
        local serverIds = {}

        for _, player in pairs(players) do
            local serverId = GetPlayerServerId(player)

            table.insert(serverIds, serverId)
        end

        return serverIds
    end
end

--[[
    Max (I think, I only tested one vehicle lol, can probably check using GetNumVehicleMods)
    engine = 3,
    brakes = 2,
    transmission = 2,
    suspension = 3,
    armor = 4,
    turbo = 1,
]]
function Functions.SetVehicleMods(veh, mods)
    if (Framework == "QBCore") then
        QBCore.Functions.SetVehicleProperties(veh, mods)

        -- Extra since depending on your QBCore version, this may not work as they use strings instead of integers, which is incorrect
        if (mods.windowStatus) then
            for windowId, isIntact in pairs(mods.windowStatus) do
                if (not isIntact) then
                    SmashVehicleWindow(veh, tonumber(windowId))
                end
            end
        end
    elseif (Framework == "ESX") then
        ESX.Game.SetVehicleProperties(veh, mods)

        -- Extra since depending on your ESX version, this may not work as they use strings instead of integers, which is incorrect
        if (mods.windowStatus) then
            for windowId, isIntact in pairs(mods.windowStatus) do
                if (not isIntact) then
                    SmashVehicleWindow(veh, tonumber(windowId))
                end
            end
        end
    end
end

local performanceMods = {
    {name = "engine", idx = 11},
    {name = "brakes", idx = 12},
    {name = "gearbox", idx = 13},
    {name = "suspension", idx = 15},
    {name = "armor", idx = 16},
    {name = "turbo", idx = 18, max = 1} -- No way to check turbo
}

function Functions.GetVehicleMods(veh)
    local mods = {}

    if (Framework == "QBCore") then
        mods = QBCore.Functions.GetVehicleProperties(veh)
    elseif (Framework == "ESX") then
        mods = ESX.Game.GetVehicleProperties(veh)
    end

    mods.maxPerformanceMods = {}

    -- Initialize, has to be called in order to fetch/set mods
    SetVehicleModKit(veh, 0)

    for _, mod in pairs(performanceMods) do
        mods.maxPerformanceMods[mod.name] = mod.name == "turbo" and 1 or GetNumVehicleMods(veh, mod.idx)
    end

    return mods
end

--[[
    vehData = {
        pos
        model
        heading
        mods
        plate
        isNetwork
        netMissionEntity
    }
    options = {
        seat = -1, -- -1 = driver, 0 = passenger, 1 = back left, 2 = back right
        engineOn = false, -- Default false, set to true to override
        fuel = 100.0, -- Will default be 100.0, set to any other value to override
        dirtLevel = 0.0, -- Will default be 0.0, set to any other value to override
        owner = false, -- Default false (This is for qb-vehiclekeys), set to true to override
        colors = {1, 1}, -- Primary, secondary
        locked = true, -- Lock all doors
        ownedVehicle = true, -- When setting locked state, and using zyke_garages, set this to true if it is a player owned vehicle
        getNetId = true, -- Gives you a netId (Required to use zyke_garages' lockstate)
    }
]]
function Functions.SpawnVehicle(vehData, options)
    local hasLoaded = Functions.LoadModel(vehData.model)
    local usingZykeGarages = GetResourceState("zyke_garages") == "started"

    if (not hasLoaded) then return nil, {msg = "Could not load model", type = "error"} end

    local veh = CreateVehicle(vehData.model, vehData.pos.x, vehData.pos.y, vehData.pos.z, vehData.pos.h or vehData.pos.w or vehData.heading or 0.0, vehData.isNetwork or true, vehData.netMissionEntity or false)

    -- Used to spawn and hide vehicle and perform necessary actions before displaying it
    -- Such as setting state bags, or applying something else that in some cases might fail (delay/lag, glitches etc)
    -- Instantly applies as going through all other functions most likely will cause delay, resulting in a delayed ghost making the vehicle flicker
    if (options.ghost) then
        SetEntityAlpha(veh, 0, false)
        SetEntityCollision(veh, false, false)
        FreezeEntityPosition(veh, true)
    end

    SetModelAsNoLongerNeeded(vehData.model)

    local netId = (options?.getNetId or usingZykeGarages) and NetworkGetNetworkIdFromEntity(veh)

    if (FuelScript == "LegacyFuel") then
        exports['LegacyFuel']:SetFuel(veh, options and options.fuel or 100.0)
    else
        SetVehicleFuelLevel(veh, options and options.fuel or 100.0)
    end

    SetVehicleDirtLevel(veh, options and options.dirtLevel or 0.0)
    SetVehicleEngineOn(veh, options and options.engineOn or false, true, false)

    if (vehData.mods) then
        Functions.SetVehicleMods(veh, vehData.mods)
    end

    if (options and options.seat) then
        SetPedIntoVehicle(PlayerPedId(), veh, options.seat)
    end

    if (options and options.colors) then
        SetVehicleColours(veh, options.colors[1] or 0, options.colors[2] or 0)
    end

    if (vehData.plate) then
        SetVehicleNumberPlateText(veh, vehData.plate)
    end

    -- For future use
    if (usingZykeGarages) then
        local locked = options?.locked == true
        exports["zyke_garages"]:SetLockState(netId, locked, options?.ownedVehicle)
    else
        if (Functions.GetFramework() == "QBCore") then
            if (options and (options.owner == true)) then
                Functions.SetAsVehicleOwner(GetVehicleNumberPlateText(veh))
            end
        end
    end

    local functions = {}

    functions["removeGhost"] = function()
        SetEntityAlpha(veh, 255, false)
        SetEntityCollision(veh, true, true)
        FreezeEntityPosition(veh, false)
    end

    return veh, netId, functions
end

function Functions.SetAsVehicleOwner(plate)
    if (Functions.GetFramework() == "QBCore") then
        plate = string.gsub(plate, "%s+$", "") -- Triems the strings spaces at the end, which is required for qb-vehiclekeys
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif (Functions.GetFramework() == "ESX") then
        -- No native support for this, add in your own if your server has any
    end
end

-- Saves targets and their type to easily clear them
local targets = {}

---@return string | nil -- id
function Functions.AddTargetEntity(entity, passed)
    local invoker <const> = GetInvokingResource()

    if (Config.Target == "qb-target") then
        exports["qb-target"]:AddTargetEntity(entity, {
            options = passed.options,
            distance = passed.distance or 2.0
        })

        targets[entity] = {type = "entity", invoker = invoker}

        return entity
    elseif (Config.Target == "ox_target") then
        Functions.RemoveTarget(entity) -- You need to remove and re-add the entity if you want to update the options
        exports["ox_target"]:addLocalEntity(entity, passed.options)

        targets[entity] = {type = "entity", invoker = invoker}
        return entity
    else
        Functions.Debug("You are using an unsupported target script, please use either qb-target or ox_target. Alternatively you can add your own target script.", true)
        return nil
    end
end

---@class TargetOptions
---@field num number -- Index in the menu
---@field icon string
---@field label string
---@field action? function -- qb-target uses action
---@field onSelect? function -- ox_target uses onSelect

---@class TargetDetails
---@field name string -- Unique name (id)
---@field pos vector3
---@field length number
---@field width number
---@field minZ number
---@field maxZ number
---@field heading number
---@field debugPoly boolean
---@field options table<TargetOptions>
---@field distance number

---@param passed TargetDetails
---@return string -- id
function Functions.AddTargetBox(passed)
    local invoker <const> = GetInvokingResource()

    if (Config.Target == "qb-target") then
        exports["qb-target"]:AddBoxZone(passed.name, passed.pos, passed.length, passed.width, {
            name = passed.name,
            heading = passed.heading,
            minZ = passed.minZ,
            maxZ = passed.maxZ,
            debugPoly = passed.debugPoly
        }, {
            distance = passed.distance or 1.5,
            options = passed.options
        })

        targets[passed.name] = {type = "zone", invoker = invoker}
        return passed.name
    elseif (Config.Target == "ox_target") then
        local height = (passed.pos.z - passed.minZ) + (passed.maxZ - passed.pos.z)
        local size = vec3(passed.width, passed.length, height)
        local coords = vec3(passed.pos.x, passed.pos.y, (passed.pos.z - (passed.pos.z - passed.minZ)) + (height / 2))
        local id = exports["ox_target"]:addBoxZone({
            coords = coords,
            size = size,
            rotation = passed.heading,
            debug = passed.debugPoly,
            options = passed.options
        })

        targets[id] = {type = "zone", invoker = invoker}
        return id
    else
        error("You are using an unsupported target script, please use either qb-target or ox_target. Alternatively you can add your own target script.")
    end
end

---@param id string | number -- String for zones, number for entity hashes
function Functions.RemoveTarget(id)
    local details = targets[id]

    if (not details) then
        id = tostring(id)
        details = targets[id]
    end

    if (details) then
        if (details.type == "entity") then
            if (Config.Target == "qb-target") then
                exports["qb-target"]:RemoveTargetEntity(id)
            elseif (Config.Target == "ox_target") then
                exports["ox_target"]:removeLocalEntity(id)
            end
        elseif (details.type == "zone") then
            if (Config.Target == "qb-target") then
                exports["qb-target"]:RemoveZone(id)
            elseif (Config.Target == "ox_target") then
                exports["ox_target"]:removeZone(id)
            end
        end

        targets[id] = nil
    end
end

-- Old way (Kept for support)
function Functions.RemoveTargetEntity(entity)
    if (Config.Target == "qb-target") then
        exports["qb-target"]:RemoveTargetEntity(entity)
    elseif (Config.Target == "ox_target") then
        exports["ox_target"]:removeLocalEntity(entity)
    else
        Functions.Debug("You are using an unsupported target script, please use either qb-target or ox_target. Alternatively you can add your own target script.", true)
    end
end

function Functions.GetPlayerDetails(identifier)
    return Functions.Callback("zyke_lib:FetchPlayerDetails", false, {identifier = identifier or Functions.GetIdentifier()})
end

-- If you server already reflects and caches client side based on server side jobs, you could switch this out for a more performant version
function Functions.GetPlayersOnJob(job, onDuty)
    local p = promise.new()
    Functions.Callback("zyke_lib:GetPlayersOnJob", function(res)
        p:resolve(res)
    end, job, onDuty)

    return Citizen.Await(p)
end

-- Text entry is the menu top left
function Functions.RegisterTextEntry(name, msg)
    local prefix = GetInvokingResource() .. ":"

    AddTextEntry(prefix .. name, msg)
end

function Functions.DisplayTextEntry(name, resourceName)
    local prefix = (resourceName or GetInvokingResource()) .. ":" -- When triggering within, GetInvokingResource will not work, pass in resourceName to fix this

    BeginTextCommandDisplayHelp(prefix .. name)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function Functions.HasPermission(perm)
    return Functions.Callback("zyke_lib:HasPermission", false, perm)
end

function Functions.GetPlayersInArea(coords, maxDistance)
    if (Framework == "QBCore") then
        return QBCore.Functions.GetPlayersFromCoords(coords, maxDistance)
    elseif (Framework == "ESX") then
        return ESX.Game.GetPlayersInArea(coords, maxDistance)
    end
end

function Functions.GetVehicleByPlate(plate)
    local vehicles = Functions.GetVehicles()

    for _, vehicle in ipairs(vehicles) do
        if (GetVehicleNumberPlateText(vehicle) == plate) then
            return vehicle
        end
    end

    return nil
end

function Functions.GetClosestVehicle(pos, vehicles)
    pos = pos == nil and GetEntityCoords(PlayerPedId()) or pos -- Use passed in position or the player's position
    vehicles = vehicles == nil and Functions.GetVehicles() or vehicles -- Use passed in vehicles or all vehicles

    local closestEntity = nil
    local closestPos = nil
    for _, entity in pairs(vehicles) do
        local vehPos = GetEntityCoords(entity)
        local dst = #(pos - vehPos)

        if ((closestPos == nil) or (dst < closestPos)) then
            closestEntity = entity
            closestPos = dst
        end
    end

    return closestEntity, closestPos
end

function Functions.FlickerEntity(entity, times)
    for i = 255, 204, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    while times > 0 do
        for alpha = 204, 51, -2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        for alpha = 51, 204, 2 do
            SetEntityAlpha(entity, alpha, false)
            Wait(2)
        end

        times = times - 1
    end

    for i = 204, 0, -2 do
        SetEntityAlpha(entity, i, false)
        Wait(2)
    end

    return true
end

function Functions.Copy(text)
    SendNUIMessage({
        event = "copy",
        text = text,
    })

    return true
end

function Functions.IconForVehicleClass(class, useServer)
    if (class == nil) then return "car" end

    -- Server uses vehicle types and can not find the vehicle classes like the client
    if (useServer) then
        local icons = {
            ["automobile"] = "car",
            ["bike"] = "motorcycle",
            ["boat"] = "sailboat",
            ["heli"] = "helicopter",
            ["plane"] = "plane",
            ["submarine"] = "ferry",
            ["trailer"] = "trailer",
            ["train"] = "train",
        }

        return icons[class] or "car"
    end

    local icons = {
        "car", -- Compacts
        "car", -- Sedans
        "car", -- SUVs
        "car", -- Coupes
        "car", -- Muscle
        "car", -- Sports Classics
        "car", -- Sports
        "car", -- Super
        "motorcycle", -- Motorcycles
        "car", -- Off-road
        "car", -- Industrial
        "car", -- Utility
        "car", -- Vans
        "bicycle", -- Cycles
        "sailboat", -- Boats
        "helicopter", -- Helicopters
        "plane", -- Planes
        "car", -- Service
        "car", -- Emergency
        "car", -- Military
        "car", -- Commercial
        "train", -- Trains
        "car" -- Open Wheel
    }

    return icons[class + 1] or "car"
end

---@class BlipDetails
---@field type string @"coord" | "entity" | "radius"
---@field pos vector3 | table
---@field entity number? @Entity handle
---@field sprite number?
---@field display number?
---@field scale number?
---@field color number?
---@field shortRange boolean?
---@field name string?
---@field alpha number?

local blips = {}
---@param details BlipDetails
function Functions.AddBlip(details)
    local blip

    if (details.type == "coord") then
        blip = AddBlipForCoord(details.pos.x, details.pos.y, details.pos.z)
    elseif (details.type == "entity") then
        blip = AddBlipForEntity(details.entity)
    elseif (details.type == "radius") then
        blip = AddBlipForRadius(details.pos.x, details.pos.y, details.pos.z, details.scale)
    end

    if (not blip) then Functions.Debug("No type was specified in " .. GetInvokingResource(), Config.Debug) return nil end

    local sprite = (details.type == "radius" and 9) or details.sprite or 1

    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, details.display or 6)
    SetBlipScale(blip, details.scale or 0.8)
    SetBlipAsShortRange(blip, details.shortRange or false)
    SetBlipAlpha(blip, details.alpha or 255)

    if (details.color ~= nil and details.color ~= -1) then
        SetBlipColour(blip, details.color)
    end

    if (details.name ~= nil) then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(details.name)
        EndTextCommandSetBlipName(blip)
    end

    local invoker = GetInvokingResource()
    if (blips[invoker] == nil) then blips[invoker] = {} end

    table.insert(blips[invoker], blip)

    return blip
end

function Functions.RemoveBlip(blipId)
    local invoker = GetInvokingResource()
    if (blips[invoker]) then
        for idx, _blipId in pairs(blips[invoker]) do
            if (blipId == _blipId) then
                RemoveBlip(blipId)
                table.remove(blips[invoker], idx)
            end
        end

        if (#blips[invoker] == 0) then
            blips[invoker] = nil
        end
    end
end

-- Clear up blips as they won't be removed when restarting the script that invoked the blip creation function
-- Clear up data we wish to be removed on restarts, prevents us from needing to write this in every resource we use these functions in
-- Note that these are just simple removers, and if there are no additional actions required, you should remove them in the resource they were created from
AddEventHandler("onResourceStop", function(resourceName)
    -- Blips
    if (blips[resourceName] ~= nil) then
        for _, blipId in pairs(blips[resourceName]) do
            RemoveBlip(blipId)
        end

        blips[resourceName] = nil
    end

    -- Target system
    if (Config.Target) then
        for targetId, targetDetails in pairs(targets) do
            local isCorrectScript = resourceName == targetDetails.invoker

            if (isCorrectScript) then
                Functions.RemoveTarget(targetId)
            end
        end
    end
end)

function Functions.CreateUniqueId(length)
    return Functions.Callback("zyke_lib:CreateUniqueId", false, {length = length})
end

-- Only tested for QB (Not active in any releases yet)
---@param name string -- Name of job/gang
---@param rankType string -- "job" / "gang"
---@return boolean
function Functions.IsBoss(name, rankType)
    if (rankType == "job") then
        local job = Functions.GetJob()
        if (not job) then return false end
        if (job.name ~= name) then return false end

        local bossRanks = Functions.GetBossRank(job.name, rankType)
        if (not bossRanks) then return false end

        return bossRanks[job.grade.name] == true
    elseif (rankType == "gang") then
        local gang = Functions.GetGang()
        if (not gang) then return false end
        if (gang.name ~= name) then return false end

        local bossRanks = Functions.GetBossRank(gang.name, rankType)
        if (not bossRanks) then return false end

        return bossRanks[gang.grade.name] == true
    else
        error("This rankType does not exist: " .. tostring(rankType))
    end
end

---@param buttons table
---@return number
function Functions.RegisterInstructions(buttons)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while (not HasScaleformMovieLoaded(scaleform)) do
        Wait(10)
    end

    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    local removedIndexes = 0
    for idx, button in pairs(buttons) do
        local key = Functions.GetKey(button.key)
        if (key) then
            -- Check if that button is pressed, if it is not pressed, go to end of loop
            if (button.activate ~= nil) then
                local keyToPress = Functions.GetKey(button.activate)
                if (keyToPress) then
                    if (not IsDisabledControlPressed(0, keyToPress.keyCode)) then
                        removedIndexes = removedIndexes + 1
                        goto endOfLoop
                    end
                else
                    error("Trying to find key that does not exist" .. button.activate)
                end
            end

            if (button.disable ~= nil) then
                -- Check if that button is pressed, if it is pressed, go to end of loop
                local keyToPress = Functions.GetKey(button.disable)
                if (keyToPress) then
                    if (IsDisabledControlPressed(0, keyToPress.keyCode)) then
                        removedIndexes = removedIndexes + 1
                        goto endOfLoop
                    end
                else
                    error("Trying to find key that does not exist" .. button.disable)
                end
            end

            BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
            ScaleformMovieMethodAddParamInt(idx - 1 - removedIndexes)

            if (type(button.key) == "string") then
                ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, key.keyCode, true))
            elseif (type(button.key) == "table") then
                for _idx = #key, 1, -1 do
                    local keyData = key[_idx]
                    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(2, keyData.keyCode, true))
                end
            end

            BeginTextCommandScaleformString("STRING")
            AddTextComponentSubstringKeyboardDisplay(button.label)
            EndTextCommandScaleformString()
            EndScaleformMovieMethod()

            ::endOfLoop::
        else
            error("Attempted to register an instruction with an invalid key: " .. button.key)
        end
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end

local disabled = {
    --[[
        [id] = {
            state = boolean,
            keys = table<number>
        }
    ]]
}

-- Toggle function to disable keys easily
-- When you set state to false the keys will not apply
---@param id string -- Unique ID to ensure that you do not accidentally re-enable the keys when they should be disabled because of some other process
---@param state boolean -- true to enable, false to disable
---@param keys table<string | number>? -- Keys to disable, set as string to fetch their keyCode, set as number to use the keyCode directly, set to nil to disable all keys
function Functions.DisableKeys(id, state, keys)
    if (not disabled[id]) then disabled[id] = {} end

    disabled[id].state = state

    if (state == false) then return end

    local allKeys = Functions.GetKeys()
    if (keys == nil) then
        local formattedKeys = {}

        for _, keyData in pairs(allKeys) do
            formattedKeys[#formattedKeys+1] = keyData.keyCode
        end

        disabled[id].keys = formattedKeys
    else
        local formattedKeys = {}
        for _, key in pairs(keys) do
            if (type(key) == "string") then
                formattedKeys[#formattedKeys+1] = allKeys[key].keyCode
            else
                formattedKeys[#formattedKeys+1] = key
            end
        end

        disabled[id].keys = formattedKeys
    end

    CreateThread(function()
        while (disabled[id].state == true) do
            for _, keyCode in pairs(disabled[id].keys) do
                DisableControlAction(0, keyCode, true)
            end

            Wait(1)
        end
    end)
end

---@param playerId integer
function Functions.Revive(playerId)
    if (Framework == "QBCore") then
        TriggerEvent("hospital:client:Revive")
    elseif (Framework == "ESX") then
        TriggerEvent("esx_ambulancejob:revive")
    end
end

function Functions.Heal()
    local ply = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(ply)

    SetEntityHealth(ply, maxHealth)
end

---@param pos vector3
function Functions.IsOnGround(pos)
    local ray = StartExpensiveSynchronousShapeTestLosProbe(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, 16, PlayerPedId(), 0)
    local _, _, _, _, result = GetShapeTestResult(ray)

    return result == 1
end

-- Returns all the jobs or gangs in a formatted table
---@class ProfessionDetailsOptions
---@field sortAlphabetically boolean? -- Sorts based on label
---@field suffix string? -- Addition to the label
---@field prefix string? -- Addition to the label

---@param professionType string -- "job" or "gang"
---@param detailed boolean -- If detailed, each job will have a table containing all Functions.GetJobDetails data
---@param options ProfessionDetailsOptions
---@return table
function Functions.GetExistingForProfessionType(professionType, detailed, options)
    -- Initializing certain values to make the code cleaner
    if ((not options) or (type(options) ~= "table")) then
        options = {}
    end

    local suffix = options.suffix or ""
    local prefix = options.prefix or ""

    local formatted = {}

    -- Get the basic profession settings
    if (Framework == "QBCore") then
        if (professionType == "job") then
            local jobs = QBCore.Shared.Jobs

            for jobName, jobSettings in pairs(jobs) do
                table.insert(formatted, {
                    name = jobName,
                    label = prefix .. jobSettings.label .. suffix
                })
            end
        elseif (professionType == "gang") then
            local gangs = QBCore.Shared.Gangs

            for gangName, gangSettings in pairs(gangs) do
                table.insert(formatted, {
                    name = gangName,
                    label = prefix .. gangSettings.label .. suffix
                })
            end
        end
    elseif (Framework == "ESX") then
        if (professionType == "job") then
            local jobs = Functions.Callback("zyke_lib:ESX:FetchJobs", false)

            for jobName, jobSettings in pairs(jobs) do
                table.insert(formatted, {
                    name = jobSettings.name,
                    label = prefix .. jobSettings.label .. suffix,
                })
            end
        elseif (professionType == "gang") then
            -- No native gang support for ESX
            if (GangScript == "zyke_gangphone") then
                local gangs = exports["zyke_gangphone"]:GetGangList()
                for _, gangSettings in pairs(gangs) do
                    table.insert(formatted, {
                        name = gangSettings.id,
                        label = prefix .. gangSettings.name .. suffix,
                    })
                end
            end
        end
    end

    -- Getting job details
    if (detailed) then
        for idx, professionDetails in pairs(formatted) do
            local newDetails = professionType == "gang" and Functions.GetJobDetails(professionDetails.name) or Functions.GetGangDetails(professionDetails.name)
            newDetails.label = prefix .. professionDetails.label .. suffix

            formatted[idx] = newDetails
        end
    end

    -- Additional functionalities such as sorting
    if (options.sortAlphabetically) then
        table.sort(formatted, function(a, b)
            return a.label < b.label
        end)
    end

    -- Adding what type of profession it is at the end, to easily get it in menus etc
    for idx, professionDetails in pairs(formatted) do
        formatted[idx].professionType = professionType
        formatted[idx].value = professionDetails.name -- Some UI components require value instead, so adding that in here too
    end

    return formatted
end

function Functions.GetSessionId()
    return LocalPlayer.state.session or 0
end

---@param id string
---@param key string
---@param description string
---@param onPress function?
---@param onRelease function?
---@param keyType string? @keyboard, mouse_button
function Functions.RegisterKey(id, key, description, onPress, onRelease, keyType)
    local invoker = GetInvokingResource()
    local _, endIdx = invoker:find("zyke_")
    local scriptName = invoker:sub(endIdx + 1)

    RegisterKeyMapping("+" .. id, "(" .. scriptName .. ") " .. description, keyType or "keyboard", key)

    RegisterCommand("+" .. id, function()
        TriggerEvent("zyke_lib:OnKeyPress", id)

        if (onPress) then onPress() end
    end, false)

    RegisterCommand("-" .. id, function()
        TriggerEvent("zyke_lib:OnKeyRelease", id)

        if (onRelease) then onRelease() end
    end, false)
end

-- Fading of vehicles that are queued to be removed
AddStateBagChangeHandler("removing", nil, function(bagName, _, value)
    local entity = GetEntityFromStateBagName(bagName)
    if (entity == 0 or not DoesEntityExist(entity)) then return end

    local isVeh = IsEntityAVehicle(entity)
    if (not isVeh) then return end

    SetEntityCollision(entity, false, true)
    for i = 255, 0, -1 do
        Wait(math.floor(255 / value))

        SetEntityAlpha(entity, i, false)
    end
end)