fx_version "cerulean"
game "gta5"
lua54 "yes"
version "2.3.4"

shared_script "imports.lua"

ui_page "javascript/index.html"

files {
    "imports.lua",
    "config.lua",
    "formatting/**/shared.lua",
    "functions/**/client.lua",
    "functions/**/shared.lua",
    "translations.lua",
    "systems/*.lua",
    "internals/**/*.lua",
    "loader.lua",

    "javascript/index.html",
    "javascript/*.js",
}

loader {
    "@ox_lib/init.lua", -- Progressbar & skillcheck
    "shared:config.lua",
    "shared:internals/internals.lua",

    "server:@oxmysql/lib/MySQL.lua",
    "functions/callback/server.lua",
    "internals/events/server.lua",
    "internals/items/server.lua",
    "internals/playerIdentifiers/server.lua",
    "internals/states/server.lua",

    "functions/debug/shared.lua",

    "functions/callback/client.lua",
    "functions/debug/shared.lua",
    "internals/copy/client.lua",
    "internals/events/client.lua",
    "internals/items/client.lua",
    "internals/states/client.lua",
}

dependencies {
    "ox_lib", -- Skillcheck
}