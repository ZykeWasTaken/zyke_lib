function Functions.CopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Functions.CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Functions.Debug(msg, enabled, invoker)
    invoker = invoker or GetInvokingResource() or "zyke_lib"

    enabled = enabled or Config.Debug

    if (enabled == true) then
        print(("^4[Debug - %s]: ^7" .. msg):format(invoker))
    end
end

function Functions.CountTable(tbl)
    if (not tbl) then Functions.Debug(GetInvokingResource() .. " tried to count a nil table", Config.Debug) return 0 end
    local count = 0

    for k, v in pairs(tbl) do
        count = count + 1
    end

    return count
end

---@param tbl table -- Needs to be an array
---@param desiredString string
---@return boolean, number | nil
function Functions.Contains(tbl, desiredString)
    if (not tbl) then error("Attempt to scan non-existens table") end

    for idx, string in pairs(tbl) do
        if (desiredString == string) then
            return true, idx
        end
    end

    return false, nil
end

---@param tbl table
---@param predicate function
---@return any, number | string | nil
function Functions.Find(tbl, predicate)
    if (not tbl) or (type(tbl) ~= "table") then error("Attempt to scan non-existent table") end

    for key, value in pairs(tbl) do
        if (predicate(value)) then
            return value, key
        end
    end

    return nil, nil
end

function Functions.GetItem(item)
    if (Framework == "QBCore") then
        return QBCore.Shared.Items[item]
    elseif (Framework == "ESX") then
        return ESX.Items[item]
    end
end

function Functions.GetFramework()
    while (Framework == nil or Framework == "") do Wait(10) end
    return Framework
end

function Functions.GetWeaponType()
    return Config.WeaponType
end

function Functions.GetTarget()
    return Config.Target
end

function Functions.GetBlipColors()
    return Config.BlipColors
end

function Functions.GetConfig()
    return Config
end

---@param name string -- Name of job
function Functions.GetJobDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = Functions.GetJobData(name)
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatJobDetails(details)
    elseif (Framework == "ESX") then
        local details = Functions.GetJobData(name)
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatJobDetails(details)
    end
end

---@param name string -- Name of gang
function Functions.GetGangDetails(name)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        local details = QBCore.Shared.Gangs[name]
        if (not details) then return nil end

        details.name = name -- Name is not included, so we'll add it in

        return Functions.FormatGangDetails(details)
    elseif (Framework == "ESX") then
        if (Config.GangScript == "zyke_gangphone") then
            local details = Functions.GetGangData(name)
            if (not details) then return nil end

            details.name = name -- Name is not included, so we'll add it in

            return Functions.FormatGangDetails(details)
        end
    end
end

---@param identifier string
---@return table | nil
function Functions.GetGangData(identifier)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        return QBCore.Shared.Gangs[identifier]
    elseif (Framework == "ESX") then
        if (Config.GangScript == "zyke_gangphone") then
            return exports["zyke_gangphone"]:GetGang(identifier)
        end
    end

    return nil
end

-- Only tested for QB (Not active in any releases yet)
---@param name string -- Job/gang name
---@param rankType string -- "job" / "gang"
---@return table | nil -- name = true, as some servers support multiple bosses, nil if no job/gang is found
function Functions.GetBossRanks(name, rankType)
    if (Framework == "QBCore") then
        if (rankType == "job") then
            local sortedList = {}
            local job = QBCore.Shared.Jobs[name]
            if (not job) then return nil end

            for _, details in pairs(job.grades) do
                if (details.isboss == true) then
                    sortedList[details.name] = true
                end
            end

            return sortedList
        elseif (rankType == "gang") then
            local sortedList = {}
            local gang = QBCore.Shared.Gangs?[name]
            if (not gang) then return nil end

            for _, details in pairs(gang.grades) do
                if (details.isboss == true) then
                    sortedList[details.name] = true
                end
            end

            return sortedList
        end
    elseif (Framework == "ESX") then
        if (rankType == "job") then
            local job = Functions.GetJobData(name)
            if (not job) then return nil end

            local highestGrade = 1
            local highestKey = nil
            for key, value in pairs(job.grades) do
                local grade = tonumber(key) or 0

                if (grade > highestGrade) then
                    highestGrade = grade
                    highestKey = key
                end
            end

            return {
                [job.grades[highestKey].name] = true
            }
        elseif (rankType == "gang") then
            if (Config.GangScript == "zyke_gangphone") then
                local gang = Functions.GetGangData(name)
                if (not gang or not gang.ranks) then return {} end

                return {
                    [gang.ranks[1].name] = true
                }
            end

            return nil
        end
    end

    return nil
end

function Functions.GetRandomDictionaryKey(tbl)
    local keys = {}

    for key, _ in pairs(tbl) do
        keys[#keys+1] = key
    end

    return keys[math.random(1, #keys)]
end

---@param tbl table
---@return boolean
function Functions.IsArray(tbl)
    if (next(tbl) == nil) then
        return false
    end

    for key in pairs(tbl) do
        if (type(key) ~= "number") then
            return false
        end
    end

    return true
end

function Functions.HasLoadedFramework()
    if (Framework == "QBCore") then
        return QBCore ~= nil
    elseif (Framework == "ESX") then
        return ESX ~= nil
    end
end

---@param playerId number
function Functions.GetLicense(playerId)
    return Player(playerId).state["zyke_lib:license"]
end

---@param job string
---@return table | nil
function Functions.GetJobData(job)
    while (Framework == nil) do Wait(100) end

    if (Framework == "QBCore") then
        return QBCore.Shared.Jobs[job]
    elseif (Framework == "ESX") then
        local isServer = IsDuplicityVersion()
        return (isServer and ESX.GetJobs()[job] or Functions.Callback("zyke_lib:ESX:FetchJobs", false, {name = job}))
    end

    return nil
end

---@param weaponHash number
---@return string, string
function Functions.GetWeaponName(weaponHash)
    local weapons = {
        [-1075685676] = "WEAPON_PISTOL_MK2",
        [126349499] = "WEAPON_SNOWBALL",
        [-270015777] = "WEAPON_ASSAULTSMG",
        [615608432] = "WEAPON_MOLOTOV",
        [2024373456] = "WEAPON_SMG_MK2",
        [-1810795771] = "WEAPON_POOLCUE",
        [-1813897027] = "WEAPON_GRENADE",
        [-598887786] = "WEAPON_MARKSMANPISTOL",
        [-1654528753] = "WEAPON_BULLPUPSHOTGUN",
        [-72657034] = "GADGET_PARACHUTE",
        [-102323637] = "WEAPON_BOTTLE",
        [2144741730] = "WEAPON_COMBATMG",
        [-1121678507] = "WEAPON_MINISMG",
        [-1652067232] = "WEAPON_SWEEPERSHOTGUN",
        [961495388] = "WEAPON_ASSAULTRIFLE_MK2",
        [-86904375] = "WEAPON_CARBINERIFLE_MK2",
        [-1786099057] = "WEAPON_BAT",
        [177293209] = "WEAPON_HEAVYSNIPER_MK2",
        [600439132] = "WEAPON_BALL",
        [1432025498] = "WEAPON_PUMPSHOTGUN_MK2",
        [-1951375401] = "WEAPON_FLASHLIGHT",
        [171789620] = "WEAPON_COMBATPDW",
        [1593441988] = "WEAPON_COMBATPISTOL",
        [-2009644972] = "WEAPON_SNSPISTOL_MK2",
        [2138347493] = "WEAPON_FIREWORK",
        [1649403952] = "WEAPON_COMPACTRIFLE",
        [-619010992] = "WEAPON_MACHINEPISTOL",
        [-952879014] = "WEAPON_MARKSMANRIFLE",
        [317205821] = "WEAPON_AUTOSHOTGUN",
        [-1420407917] = "WEAPON_PROXMINE",
        [-1045183535] = "WEAPON_REVOLVER",
        [94989220] = "WEAPON_COMBATSHOTGUN",
        [-1658906650] = "WEAPON_MILITARYRIFLE",
        [1198256469] = "WEAPON_RAYCARBINE",
        [2132975508] = "WEAPON_BULLPUPRIFLE",
        [1627465347] = "WEAPON_GUSENBERG",
        [984333226] = "WEAPON_HEAVYSHOTGUN",
        [1233104067] = "WEAPON_FLARE",
        [-1716189206] = "WEAPON_KNIFE",
        [940833800] = "WEAPON_STONE_HATCHET",
        [1305664598] = "WEAPON_GRENADELAUNCHER_SMOKE",
        [727643628] = "WEAPON_CERAMICPISTOL",
        [-1074790547] = "WEAPON_ASSAULTRIFLE",
        [-1169823560] = "WEAPON_PIPEBOMB",
        [324215364] = "WEAPON_MICROSMG",
        [-1834847097] = "WEAPON_DAGGER",
        [-1466123874] = "WEAPON_MUSKET",
        [-1238556825] = "WEAPON_RAYMINIGUN",
        [-1063057011] = "WEAPON_SPECIALCARBINE",
        [1470379660] = "WEAPON_GADGETPISTOL",
        [584646201] = "WEAPON_APPISTOL",
        [-494615257] = "WEAPON_ASSAULTSHOTGUN",
        [-771403250] = "WEAPON_HEAVYPISTOL",
        [1672152130] = "WEAPON_HOMINGLAUNCHER",
        [338557568] = "WEAPON_PIPEWRENCH",
        [1785463520] = "WEAPON_MARKSMANRIFLE_MK2",
        [-1355376991] = "WEAPON_RAYPISTOL",
        [101631238] = "WEAPON_FIREEXTINGUISHER",
        [1119849093] = "WEAPON_MINIGUN",
        [883325847] = "WEAPON_PETROLCAN",
        [-102973651] = "WEAPON_HATCHET",
        [-275439685] = "WEAPON_DBSHOTGUN",
        [-1746263880] = "WEAPON_DOUBLEACTION",
        [-879347409] = "WEAPON_REVOLVER_MK2",
        [125959754] = "WEAPON_COMPACTLAUNCHER",
        [911657153] = "WEAPON_STUNGUN",
        [-2066285827] = "WEAPON_BULLPUPRIFLE_MK2",
        [-538741184] = "WEAPON_SWITCHBLADE",
        [100416529] = "WEAPON_SNIPERRIFLE",
        [-656458692] = "WEAPON_KNUCKLE",
        [-1768145561] = "WEAPON_SPECIALCARBINE_MK2",
        [1737195953] = "WEAPON_NIGHTSTICK",
        [2017895192] = "WEAPON_SAWNOFFSHOTGUN",
        [-2067956739] = "WEAPON_CROWBAR",
        [-1312131151] = "WEAPON_RPG",
        [-1568386805] = "WEAPON_GRENADELAUNCHER",
        [205991906] = "WEAPON_HEAVYSNIPER",
        [1834241177] = "WEAPON_RAILGUN",
        [-1716589765] = "WEAPON_PISTOL50",
        [736523883] = "WEAPON_SMG",
        [1317494643] = "WEAPON_HAMMER",
        [453432689] = "WEAPON_PISTOL",
        [1141786504] = "WEAPON_GOLFCLUB",
        [-1076751822] = "WEAPON_SNSPISTOL",
        [-2084633992] = "WEAPON_CARBINERIFLE",
        [487013001] = "WEAPON_PUMPSHOTGUN",
        [-1168940174] = "WEAPON_HAZARDCAN",
        [-38085395] = "WEAPON_DIGISCANNER",
        [-1853920116] = "WEAPON_NAVYREVOLVER",
        [-37975472] = "WEAPON_SMOKEGRENADE",
        [-1600701090] = "WEAPON_BZGAS",
        [-1357824103] = "WEAPON_ADVANCEDRIFLE",
        [-581044007] = "WEAPON_MACHETE",
        [741814745] = "WEAPON_STICKYBOMB",
        [-608341376] = "WEAPON_COMBATMG_MK2",
        [137902532] = "WEAPON_VINTAGEPISTOL",
        [-1660422300] = "WEAPON_MG",
        [1198879012] = "WEAPON_FLAREGUN"
    }

    local raw = weapons[weaponHash]
    if (not raw) then return "NOT FOUND", "RAW NOT FOUND" end

    local formatted = raw:gsub("WEAPON_", "")
    formatted = formatted:gsub("_", " ")

    formatted = formatted:gsub("(%w+)", function(firstWord)
        return firstWord:lower():gsub("^%l", string.upper)
    end)

    return formatted, raw
end

---@param tbl table -- array
---@return table -- array
function Functions.EnsureUniqueEntries(tbl)
    local seen = {}
    local uniqueEntries = {}

    for _, value in pairs(tbl) do
        if not (seen[value]) then
            table.insert(uniqueEntries, value)
            seen[value] = true
        end
    end

    return uniqueEntries
end

---@class DetailedVehicle
---@field pos vector3
---@field netId number
---@field plate string
---@field vehicleType string
---@field model string
---@field handler number

---@class GetVehicleOptionsDetails
---@field includeStates boolean -- Includes all of the required states, note that you can not name the state keys as any of the default detail properties

---@class GetVehicleOptions
---@field maxDistance number | false | nil @Use number, if false (or -1) it will go as far as you can render, nil will default to 350.0
---@field pos vector3 | vector4 | table -- Position to check distance with, if not provided it will use your player position if client
---@field states table -- States to filter by, example: {locked = true, engine = true}, note that you can also set the value to "none" to solely filter based on the state existing
---@field detailed GetVehicleOptionsDetails | boolean @Will give you class DetailedVehicle when set to true, if set to a table it will act as a boolean, but also allows you to add more details

-- TODO: Make sure you're fetching from the correct routing session
-- Note that you can only use limited options when only using the client, such as states not always being synced the same (but usually is), getting routing buckets, etc
---@param serverFetch boolean? @Used client-side to allow for server-sided vehicle fetch, allows reach beyond your render
---@param options? GetVehicleOptions
---@return table<number, number> | table<number, DetailedVehicle> @Returns a table with vehicle handlers, or detailed vehicles if detailed is truthy
function Functions.GetVehicles(serverFetch, options)
    local isServer = IsDuplicityVersion()
    serverFetch = isServer or serverFetch == true

    if (not isServer and serverFetch) then
        return Functions.Callback("zyke_lib:GetVehicles", false, options) -- Will callback and run the same complete function on the server side
    end

    local vehicles
    if (serverFetch) then
        vehicles = GetAllVehicles()
    else
        vehicles = GetGamePool("CVehicle")
    end

    ---@diagnostic disable-next-line: return-type-mismatch @GetAllVehicles() always returns a table, not an integer as far as my testing went
    if (not options) then return vehicles end

    local formatted = {}

    -- Verifying maxDistance
    local maxDistance = options.maxDistance
    if (maxDistance == false) then
        maxDistance = -1
    elseif (maxDistance == nil) then
        maxDistance = 350.0
    end

    -- Verifying positions
    local pos = options.pos
    if (not pos) then
        if (not isServer) then pos = GetEntityCoords(PlayerPedId()) end
    end

    -- Make sure you have a position to check distance with if you are utilizing maxDistance
    if (maxDistance and maxDistance > 0 and not pos) then
        error("Trying to utilize maxDistance without providing a position to check distance with")
    end

    -- Verifying states
    local filterByStates = type(options.states) == "table"

    ---@diagnostic disable-next-line: param-type-mismatch @GetAllVehicles() always returns a table, not an integer as far as my testing went
    for _, veh in pairs(vehicles) do
        -- Check if it's within reach
        if (maxDistance ~= nil) then
            if (maxDistance ~= -1) then
                local dst = #(pos - GetEntityCoords(veh))
                if (dst > maxDistance) then goto continue end
            end
        end

        -- Check if it's within the required states
        if (filterByStates) then
            for state, requiredValue in pairs(options.states) do
                local entityStateValue = Entity(veh)?.state?[state]

                if (requiredValue == "none") then
                    if (entityStateValue == nil) then goto continue end
                else
                    if (requiredValue ~= entityStateValue) then goto continue end
                end
            end
        end

        local vehicleDetails
        if (options.detailed) then
            vehicleDetails = {
                pos = GetEntityCoords(veh),
                netId = NetworkGetNetworkIdFromEntity(veh),
                plate = GetVehicleNumberPlateText(veh),
                vehicleType = GetVehicleType(veh),
                model = GetEntityModel(veh),
                handler = veh,
            }

            if (type(options.detailed) == "table") then
                if (options.detailed.includeStates) then
                    for state in pairs(options.states) do
                        vehicleDetails[state] = Entity(veh)?.state?[state]
                    end
                end
            end

            table.insert(formatted, vehicleDetails)
        else
            vehicleDetails = veh
        end

        ::continue::
    end

    return formatted
end