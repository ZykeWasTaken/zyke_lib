fx_version "cerulean"
game "gta5"
lua54 "yes"
author "realzyke"
version "1.0.8"

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
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
}

files {
    "javascript/index.html",
    "javascript/*.js",
}

dependencies {
    "ox_lib",
    "PolyZone",
}
