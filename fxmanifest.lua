fx_version "cerulean"
game "gta5"
lua54 "yes"
author "realzyke"
version "1.0.13"

ui_page "javascript/index.html"

shared_scripts {
    -- "@es_extended/imports.lua", -- ESX Legacy's import fetch, if you wish to use this instead, but event/export should work fine
    "imports.lua",
    "@ox_lib/init.lua",

    "shared/config.lua",
    "shared/shared.lua",
    "shared/auto_fetchers/framework.lua",
    "shared/auto_fetchers/targeting.lua",
    "shared/auto_fetchers/gang.lua",
    "shared/auto_fetchers/death.lua",
    "shared/auto_fetchers/fuel.lua",
    "shared/locales.lua",
    "shared/formatting.lua",

    "shared/experimental/*", -- Dev & personal stuff
}

client_scripts {
    "@PolyZone/client.lua",
    "client/**/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/webhooks.lua",

    "server/main.lua",
    "server/functions.lua",
    "server/events.lua",
    "server/callbacks.lua",

    "server/experimental/*", -- Dev & personal stuff
}

files {
    "javascript/index.html",
    "javascript/*.js",
}

dependencies {
    "ox_lib",
    "PolyZone",
}
