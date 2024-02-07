local function getSettings(category, settings)
    local catSettings = Config.Minigames[category]

    if (type(settings) == "string" and catSettings.minigames[catSettings.active][settings]) then
        return catSettings.minigames[catSettings.active][settings]
    end

    return settings
end

local minigameFuncs = {}
for category, minigameData in pairs(Config.Minigames) do
    Minigames[category] = function(details)
        local settings = getSettings(category, details)

        return minigameFuncs[minigameData.active](settings)
    end
end

---@param settings ox_lib_skillcheck
---@return boolean
minigameFuncs["ox_lib_skillcheck"] = function(settings)
    local res = lib.skillCheck(settings.difficulty, settings.inputs)

    return res
end

---@param settings ps-ui_thermite
---@return boolean
minigameFuncs["ps-ui_thermite"] = function(settings)
    local res

    exports["ps-ui"]:Thermite(function(success)
        res = success
    end, settings.time, settings.gridSize, settings.incorrectBlocks)

    return res
end