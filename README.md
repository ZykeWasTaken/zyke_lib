[![ko-fi banner2](https://github.com/user-attachments/assets/42eff455-5757-4888-ad88-d61893edcc33)](https://ko-fi.com/zykeresources)

# [> Download](https://github.com/ZykeWasTaken/zyke_lib/releases/latest)

# What Is This?

Our library acts as a bridge for dependencies, such as frameworks, progressbars, dispatch systems, inventories etc. Our resources call functions within the library, which then calls the automatically selected dependency to streamline the entire process. Despite it's name, it is not the same as other libraries such as ox_lib.

There are a few similar resources from other creators, but unfortunately no centralized solution that everyone can use exists. This is because these libraries are usually constructed differently, consume and return different information etc.

All of our resources are built on top of this library, and is a requirement to use if you wish to run any of them.

## Important

Downloading an experimental & non-release version is **not recommended unless you know what you are doing**. We constantly update this repository to make the development of Zyke Resources' scripts easier, and we don't always test all functionality on different servers using different frameworks. **[Head over to the release page for a stable release.](https://github.com/ZykeWasTaken/zyke_lib/releases/latest)**

## Modified Servers

Please be aware that heavily modified servers may cause our library to struggle without any adapting. Everything framework-dependant in our resources can be modified in our library, or in the unlocked files of the resource. If you are unsure if our resources will work for you, feel free to create a ticket in our Discord and we will assist you swiftly.

## Links

-   [Documentation](https://docs.zykeresources.com/free-resources/zyke-lib)
-   [Discord Community](https://discord.zykeresources.com/)
-   [Store](https://store.zykeresources.com/)

## Inventory Support

-   **BIG NOTE:** There may be changes for specific resources, view each resources' dependencies carefully
-   Regular ESX inventories (requires metadata)
  	- Please see the big note.
-   Regular QBCore inventories
  	- Variations like ps or ak47 may be incompatible. Please consult us in our [Discord](https://discord.zykeresources.com) before purchase if you are unsure.
-   Full support for ox_inventory
-   Full support for qs-inventory
-   Full support for TGIANN-inventory (> v2.0.51)
-   Full support for codem-inventory (> v2.0.51)
-   Full QBCore support for core_inventory (> v2.0.50)

## Target Support

-   ox_target
-   qb-target
-   We are now using a most-fitting approach for our releases, which means some features may require a target system if it fits the best

## Dependencies

-   [ox_lib (Progressbar & Skillcheck)](https://github.com/overextended/ox_lib)

## Adding Compatibility

All interactions with outside dependencies, such as frameworks, progressbars and inventories can modified, and most of it in here.

We use a modular approach, allowing you to add new compatibility, or custom behaviour, for specific functions.

Below you will find all the files connected to a dependency.

### Inventory

Some inventories offer a lot of backwards-compatible functionality and you may not need to edit all of the files.

-   `systems/inventory.lua`
-   `formatting/formatItem/shared.lua`
-   `functions/addItem/server.lua`
-   `functions/canCarryItem/server.lua`
-   `functions/getInventorySlot/server.lua`
-   `functions/getPlyerItems/client.lua`
-   `functions/getPlyerItems/server.lua`
-   `functions/hasItem/server.lua`
-   `functions/registerUsableItem/server.lua`
-   `functions/removeFromSlot/server.lua`
-   `functions/setItemMetadata/server.lua`
-   `functions/stash/client.lua`
-   `functions/stash/server.lua`
-   `internals/events/client.lua`

### Fuel

-   `systems/fuel.lua`
-   `functions/getFuel/client.lua`
-   `functions/setFuel/client.lua`

### Target

-   `systems/target.lua`
-   `functions/target/client.lua`

### Death/Ambulance

-   `systems/death.lua`
-   `functions/isPlayerDead/client.lua`

### Framework

To add in a completely new framework, you would need to modify pretty much all files.

### Gang

Currently unused

## Loader

This is an experimental approach to simplify the setup process for all of our products. Utilizing this loader, it is ensured that **all** dependenciesa are properly loaded before we allow the scripts to be started. This is essentially expanding on the default "dependency" fxmanifest.lua section that often fails due to timing issues in certain cases. This loader may be niche, but there are a lot of servers that will benefit from a simplified setup when installing our resources.

Instead of specifying inside of client_scripts {...} and so on, we specify the path inside of loader {...}, where it automatically fetches the context or allows you to prefix with context:path.

Unfortunately it seems that wildcards (using stars to start entire folders) are not suitible to be used at the moment.

This is most likely going to be expanded on and simplified in the future, but is a working proof of concept that will be implemented into all of our resources to make installations easier.

**Example from zyke_vending:**

```lua
shared_scripts {
	-- We import our imports.lua file from zyke_lib, which will ensure our entire resource along with it's dependencies
	"@zyke_lib/imports.lua",
}

files {
	-- Not related to the loader, but we specify our translations here too
	"locales/*.lua",

	-- Specify our client-sided files so they can be found, required by Cfx
	"shared/*.lua",
	"client/*.lua",
}

-- Specify all of the files loading & their order
loader {
	"shared/config.lua",

	"client/main.lua",
	"client/debug.lua",

	"server/main.lua",
	"server/validate_items.lua"

	-- This is not used in this particular resource, but we can specifically ensure context by doing this:
	-- "shared:main.lua"
	-- "server:main.lua"
	-- "client:main.lua"
}

-- Specify all the dependencies we will be waiting for
dependencies {
	"zyke_lib"
}
```

## Credits

-   Credits to the [Overextended team](https://github.com/overextended/ox_lib) for the module structure of importing and executing functions.
-   Credits to all of the [contributors](https://github.com/ZykeWasTaken/zyke_lib/graphs/contributors) making pull requests & our amazing community that share snippets in our Discord for me to add here.
