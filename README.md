# KnightMods

Collection of UMods for Legend of Grimrock 2

## Features

TODO

## How to use

1. First you have to be on the new beta branch. On steam, right click the game > Properties > Betas. Add the code "ggllooeegggg" to unlock the secret "nutcracker" beta
2. Go to "\Documents\Almost Human\legend of grimrock 2". Once the beta is downloaded, you'll see a file named "mods.cfg" and a "Mods" folder
3. Download KnightMods [from Github](https://github.com/KnightMiner/GrimrockKnightMods/archive/refs/heads/main.zip) 
4. Extract the "knight" folder into the Mods folder, so it looks like `/Mods/knight/`
5. Add the following to mods.cfg so it looks like this:

```lua
mods = {
    -- other UMods go here
    
    -- required
    "knight/core.lua",
    "knight/config.lua", -- you can edit this file to configure the mod
    
    -- optional, can comment out to disable a module
    "knight/more_spells.lua",
    "knight/reskilled.lua",
    "knight/tweaks.lua",
    "knight/set_bonuses.lua",
    "knight/toorum.lua",
    
    -- required
    "knight/intrusive_hooks.lua",
    
    -- other UMods can go here
}
```

## Compatability

These mods only work on Legend of Grimrock 2 on the beta branch.

These mods have not been tested with Lost City by Adrageron, and is in progress being tested with The Guardians by Adrageron and Grimrock Unlimited by Scotty.

These mods have not been tested with other UMods or other dungeons, there may be incompatabilities
