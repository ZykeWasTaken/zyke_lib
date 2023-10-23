fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Zyke#0001"
version "1.0.6"

ui_page "javascript/index.html"

shared_scripts {
    -- "@es_extended/imports.lua", -- ESX Legacy's import fetch, if you wish to use this instead, but event/export should work fine
    "imports.lua",
    "@ox_lib/init.lua",

    "shared/**/*",
    "shared/experimental/*",
}

client_scripts {
    "@PolyZone/client.lua",
    "client/**/*",
    "client/experimental/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
    "server/experimental/*",
}

dependencies {
    "ox_lib",
    "PolyZone",
}
