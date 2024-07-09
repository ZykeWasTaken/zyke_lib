Functions = {}

HoldingKeys = {}
AddEventHandler("zyke_lib:OnKeyPress", function(id)
    HoldingKeys[id] = true
end)

AddEventHandler("zyke_lib:OnKeyRelease", function(id)
    HoldingKeys[id] = nil
end)

Tools = {}
Translations = {}
Minigames = {}

function Fetch()
    return Functions, Tools, Translations, Minigames
end

exports("Fetch", Fetch)

Z, Tools, TranslationsHandler, Minigames = exports["zyke_lib"]:Fetch()