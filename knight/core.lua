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
  -- dual wield traits
  firearm_dual_wield     =  8,
  throwing_dual_wield    =  9,
  heavy_dual_wield       = 10,
  stronger_dual_wielding = 11,
  -- throwing_mastery uses vanilla icon

  -- magic trait bonuses use spell icons

  -- misc traits
  set_master = 12,
  archmage   = 13,
  satiated   = 15,
  gardener   = 18,

  -- classes
  ranger = 16,

  -- racial traits
  baker            = 14,
  refined_palette  = 15,
  pirate_training  = 22,
  knowledge_keeper = 23,
  rock_skin        = 17,

  -- toorum mode
  thunderstruck   = 27,
  perspicacious   = 26,
  unresurrectable = 24,
  skill_crystals  = 25,

  -- spells
  windforce       = 0,
  poison_storm    = 1,
  magma_strike    = 2,
  leechburst      = 3,
  blizzard_spikes = 4,
}
KnightMods.spellIconAtlas = KnightMods.resources .. "spells.dds"
KnightMods.spellIcons = {
  windforce       = 0,
  poison_storm    = 1,
  magma_strike    = 2,
  leechburst      = 3,
  blizzard_spikes = 4,
}
KnightMods.itemIconAtlas = KnightMods.resources .. "items.dds"
KnightMods.itemIcons = {
  -- mirror set
  mirror_tagelmust_set  = 20,
  mirror_chestplate_set = 18,
  mirror_cuisse_set     = 19,
  mirror_greaves_set    = 21,
  mirror_gauntlets_set  = 22,

  -- rogue set
  rogue_hood_set   = 15,
  rogue_vest_set   = 14,
  rogue_pants_set  = 13,
  rogue_boots_set  = 17,
  rogue_gloves_set = 16,

  -- embalmers set
  embalmers_headpiece_set = 3,
  embalmers_robe_set      = 0,
  embalmers_pants_set     = 1,
  embalmers_boots_set     = 2,

  -- makeshift set
  makeshift_mask_set       = 5,
  makeshift_chestplate_set = 4,
  makeshift_legplates_set  = 6,
  makeshift_buckler_set    = 7,

  -- reed set
  reed_helmet_set    = 10,
  reed_cuirass_set   =  8,
  reed_legmail_set   =  9,
  reed_sabaton_set   = 11,
  reed_gauntlets_set = 12,

  -- have to override the default icons for classic sets as they are on sheet 1
  -- lurker set
  lurker_hood  = 41,
  lurker_vest  = 40,
  lurker_pants = 39,
  lurker_boots = 42,
  lurker_hood_set  = 28,
  lurker_vest_set  = 27,
  lurker_pants_set = 26,
  lurker_boots_set = 29,

  -- chitin set
  chitin_mask    = 45,
  chitin_mail    = 43,
  chitin_cuisse  = 44,
  chitin_greaves = 46,
  chitin_mask_set    = 32,
  chitin_mail_set    = 30,
  chitin_cuisse_set  = 31,
  chitin_greaves_set = 33,

  -- valor set
  helmet_valor    = 49,
  cuirass_valor   = 47,
  cuisse_valor    = 48,
  greaves_valor   = 50,
  gauntlets_valor = 51,
  shield_valor    = 24,
  helmet_valor_set    = 36,
  cuirass_valor_set   = 34,
  cuisse_valor_set    = 35,
  greaves_valor_set   = 37,
  gauntlets_valor_set = 38,
  shield_valor_set    = 25,
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
    return list == nil or KnightMods.listContains(list, name)
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
