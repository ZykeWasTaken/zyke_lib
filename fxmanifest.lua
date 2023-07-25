fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Zyke#0001"

ui_page "javascript/index.html"

files {
    "javascript/*"
}

shared_scripts {
    -- "@es_extended/imports.lua", -- ESX Legacy's import fetch, if you wish to use this instead, but event/export should work fine
    "@ox_lib/init.lua",
    "shared/framework.lua",
    "shared/shared.lua",
    "shared/config.lua"
}

client_scripts {
    "@PolyZone/client.lua",
    "client/functions.lua",
    "client/events.lua",
    "client/main.lua",
    "client/keys.lua",
    "client/tools/functions.lua",

    "client/experimental/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    -- "@mysql-async/lib/MySQL.lua",
    "server/functions.lua",
    "server/events.lua",
    -- "server/tools/functions.lua",

    "server/experimental/*",
}

dependencies {
    "ox_lib",
    "PolyZone",
}