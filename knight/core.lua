-- contains more invasive hooks that are likely to conflict with other mods or dungeons
-- also contans various initializations used elsewhere in the mod
-- This scrip needs to load first, others can load in nearly any order

-- Base class
KnightMods = class()

local SAVE_DATA_VERSION = 1

-- Table of versions for each submod
KnightMods.versions = { ['core'] = "1.0" }

-- cna change these constants based on your setup
KnightMods.folder = config.documentsFolder .. "/Mods/knight/"
KnightMods.resources = KnightMods.folder .. "gfx/"
-- icon sheets
KnightMods.skillIconAtlas = KnightMods.resources .. "skills.dds"
KnightMods.skillIcons = {

  -- toorum mode
  thunderstruck   = 27,
  perspicacious   = 26,
  unresurrectable = 24,
  skill_crystals  = 25,
}
KnightMods.spellIconAtlas = KnightMods.resources .. "spells.dds"
KnightMods.spellIcons = {
}
KnightMods.itemIconAtlas = KnightMods.resources .. "items.dds"
KnightMods.itemIcons = {
}

-- gets a config value, or a default if the value is unset
function KnightMods:getConfig(name, default)
  local value = self.config[name]
  if value ~= nil then
    return value
  else
    return default
  end
end

-- checks if the list contains the given value
function KnightMods.listContains(list, value)
  for i = 1, #list do
    if list[i] == value then
      return true
    end
  end
  return false
end

function KnightMods:isModLoaded(name)
  local mod = modSystem:getCurrentMod()
  return not mod or mod.name == name
end

-- checks if the given key is enabled in the current mods
function KnightMods:isEnabledInMod(firstKey, firstWhitelist)
  local mod = modSystem:getCurrentMod()
  if mod then
    local name = mod.name

    -- first choice: key
    local list
    if firstKey then
      list = self.config[firstKey]
      if list ~= nil then
        local contains = KnightMods.listContains(list, name)
        -- whitelist - must be in list
        if firstWhitelist then
          return contains
        -- blacklist - if in the list bad, if not fallback
        elseif contains then
          return false
        end
      end
    end

    -- global whitelist, ensures we do not break a random other mod
    list = self.config["global_mod_whitelist"]
    return list == nil or listContains(list, name)
  end
  return true
end

-- adds a new module into the listing
function KnightMods:_addModule(name, version)
  self.versions[name] = version
end

-- some hooks are intrusive and could more easily break things, allow enabling them conditionally
KnightMods._enableIntrusiveHooks = {}

function KnightMods:enableIntrusiveHook(name)
  self._enableIntrusiveHooks[name] = true
end

function KnightMods:_isIntrusiveHookEnabled(name)
  return self._enableIntrusiveHooks[name] == true
end

-- Allow other modules to more easily modify the damage stats
-- Generally should add to mod, multiply to power
-- requires KnightMods:enableIntrusiveHook("modifyAttackStats")
function KnightMods.modifyAttackStats(champion, weapon, attack, power, mod)
  return power, mod
end

-- Allow other modules to more easily modify the energy cost of a spell
-- requires KnightMods:enableIntrusiveHook("modifySpell")
function KnightMods.modifySpellManaCost(caster, spell, cost)
  return cost
end

-- Allow other modules to more easily modify the cooldown of a spell
-- requires KnightMods:enableIntrusiveHook("modifySpell")
function KnightMods.modifySpellCooldown(caster, spell, cooldown)
  if caster:hasTrait("quick") then
    cooldown = cooldown * 0.85
  end
  if caster:hasTrait("uncanny_speed") then
    cooldown = cooldown * 0.9
  end
  return cooldown
end

-- Function to redefine an object by name
function KnightMods.redefineName(name)
  local arch = dungeon.archs[name]
  if arch then
    redefineObject(arch)
  end
end

local function renameObject(obj, map)
  local renamed = map[obj.name]
  if renamed ~= nil then
    obj.name = renamed
  end
end

-- Function to redefine an object by name
function KnightMods.renameObjects(map)
	-- redefine items in levels
	for i=1,#dungeon.maps do
		local map = dungeon.maps[i]
		for e in map:allEntities() do
      renameObject(e.arch, map)

			-- items inside other items
			if e.containeritem then
				for _,it in e.containeritem:contents() do
          renameObject(it.go.arch, map)
				end
			end

			-- items carried by monsters
			if e.monster then
				for _,it in e.monster:contents() do
          renameObject(it.go.arch, map)
				end
			end
		end
	end

	-- redefine items carried by champions
	if party then
		for i=1,4 do
			local champion = party.champions[i]
			for _,it in champion:carriedItems() do
        renameObject(it.go.arch, map)
				if it.go.containeritem then
					for _,it in it.go.containeritem:contents() do
            renameObject(it.go.arch, map)
					end
				end
			end
		end
	end
end

-- called on game load to update save data
function KnightMods.updateSaveData(oldVersion, newVersion)

end

-- add trait to partys with a single Toorum champion
local oldNewGame = GameMode.newGame
function GameMode:newGame()
	oldNewGame(self)
  -- no need to migrate from the first version
  _G.party.__km_save_data_version = SAVE_DATA_VERSION
end

local oldLoadGame = GameMode.loadGame
function GameMode:loadGame(filename)
  local result = oldLoadGame(self, filename)

  if result then
    -- check our save data key to see if we need save data updates
    local oldVersion = _G.party.__km_save_data_version or 0
    if oldVersion < SAVE_DATA_VERSION then
      systemLog:write(string.format("KnightMods: migrating from save data version %d to %d", oldVersion, SAVE_DATA_VERSION))
      KnightMods.updateSaveData(oldVersion, SAVE_DATA_VERSION)
      _G.party.__km_save_data_version = SAVE_DATA_VERSION
    	systemLog:write(string.format("KnightMods: migration from %d to %d successful", oldVersion, SAVE_DATA_VERSION))
    else
     systemLog:write(string.format("KnightMods: skipping migration, already on save data version %d", SAVE_DATA_VERSION))
    end

  end

  return result
end
