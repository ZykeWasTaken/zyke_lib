Functions = {}
Tools = {}
Translations = {}

function Fetch()
    return Functions, Tools, Translations
end

exports("Fetch", Fetch)

Z, Tools, TranslationsHandler = exports["zyke_lib"]:Fetch()