fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Zyke#0001"

client_scripts {
    "client/framework.lua",
    "client/functions.lua",
    "client/events.lua",
}

server_scripts {
    "server/framework.lua",
    "server/functions.lua",
    "server/events.lua",
}

shared_scripts {
    -- "@es_extended/imports.lua", -- ESX Legacy's import fetch
    "shared/shared.lua",
    "shared/config.lua"
}