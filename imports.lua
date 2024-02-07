Functions = {}
Tools = {}
Translations = {}
Minigames = {}

function Fetch()
    return Functions, Tools, Translations, Minigames
end

exports("Fetch", Fetch)

Z, Tools, TranslationsHandler, Minigames = exports["zyke_lib"]:Fetch()