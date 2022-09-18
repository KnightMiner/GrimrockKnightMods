-- Contains new set bonuses
KnightMods:_addModule("set_bonuses", "1.0")

--[[
  Adds set bonuses to all sets with unique pieces
]]

-- helper to add a set bonus
local function updateSetInfo(args)
  local piece = dungeon.archs[args.name]
  if piece then
    local itemComp = findArchComponentByClass(piece, "Item")
    if itemComp then
      if args.set then itemComp.armorSet = set end
      -- icons
      if args.replaceIcon then
        itemComp.gfxIndex = KnightMods.itemIcons[args.name]
      end
      itemComp.gfxIndexArmorSet = KnightMods.itemIcons[args.name .. "_set"]
       -- sheet 2 or 3 will be used if the icon is too large
      itemComp.gfxAtlas = KnightMods.itemIconAtlas
      -- total number in set
      if args.total then
        itemComp.armorSetPieces = args.total
      end
      if args.gameEffect then
        itemComp.gameEffect = args.gameEffect
      end
    end
    if args.setBonus then
      local equipComp = findArchComponentByClass(piece, "EquipmentItem")
      if equipComp then
        equipComp.onRecomputeStats = args.setBonus
      end
    end
  end
end

-- Adds a game effect description to an item
local function addGameEffect(itemName, effect)
  local item = dungeon.archs[itemName]
  if item then
    local itemComp = findArchComponentByClass(item, "Item")
    if itemComp then
      itemComp.gameEffect = effect
    end
  end
end

local function moreSetBonusesInit()
  local isGuardians = KnightMods:isModLoaded("The Guardians")

    -- full mirror set: +10 resist all, +25 energy
    updateSetInfo{name = "mirror_tagelmust"}
    updateSetInfo{name = "mirror_cuisse"}
    updateSetInfo{name = "mirror_greaves"}
    updateSetInfo{name = "mirror_gauntlets"}
  if isGuardians then
    updateSetInfo{name = "mirror_chestplate"}
  else
    updateSetInfo{
      name = "mirror_chestplate",
      gameEffect = "Set Bonus: 80% Spell Energy Cost",
    }
  end

    -- full rogue set +10 evasion
    updateSetInfo{name = "rogue_hood"}
    updateSetInfo{name = "rogue_pants"}
    updateSetInfo{name = "rogue_boots"}
    updateSetInfo{name = "rogue_gloves"}
  if isGuardians then
    updateSetInfo{name = "rogue_vest"}
  else
    updateSetInfo{
      name = "rogue_vest",
      gameEffect = "Set Bonus: +10 Evasion",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("rogue") then
          champion:addStatModifier("evasion", 10)
        end
      end,
    }
  end

    -- embalmers set - +50 health
    updateSetInfo{name = "embalmers_headpiece", set = "embalmers"}
    updateSetInfo{name = "embalmers_pants",     set = "embalmers"}
    updateSetInfo{name = "embalmers_boots",     set = "embalmers"}
  if isGuardians then
    updateSetInfo{name = "embalmers_robe"}
  else
    updateSetInfo{
      name = "embalmers_robe",
      set = "embalmers",
      total = 4,
      gameEffect = "Set Bonus: +50 Health",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("embalmers") then
          champion:addStatModifier("max_health", 50)
        end
      end,
    }
  end

    -- makeshift - +25 energy
    updateSetInfo{name = "makeshift_buckler", set = "makeshift"}
    updateSetInfo{name = "makeshift_mask"}
    updateSetInfo{name = "makeshift_legplates"}
  if isGuardians then
    updateSetInfo{name = "makeshift_chestplate"}
  else
    updateSetInfo{
      name = "makeshift_chestplate",
      gameEffect = "Set Bonus: +20% Spell Damage",
    }
  end

    -- reed - +5 dex
    updateSetInfo{name = "reed_legmail"}
    updateSetInfo{name = "reed_helmet"}
    updateSetInfo{name = "reed_sabaton"}
    updateSetInfo{name = "reed_gauntlets"}
  if isGuardians then
    updateSetInfo{name = "reed_cuirass"}
  else
    updateSetInfo{
      name = "reed_cuirass",
      gameEffect = "Set Bonus: +5 Dexterity",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("reed") then
          champion:addStatModifier("dexterity", 5)
        end
      end,
    }
  end

    -- lurker set: +10 evasion (that is, 1.5x evasion)
    updateSetInfo{name = "lurker_pants", replaceIcon = true}
    updateSetInfo{name = "lurker_hood",  replaceIcon = true}
    updateSetInfo{name = "lurker_boots", replaceIcon = true}
  if isGuardians then
    updateSetInfo{name = "lurker_vest"}
  else
    updateSetInfo{
      name = "lurker_vest",
      replaceIcon = true,
      gameEffect = "Set Bonus: +10 Evasion",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("lurker") then
          champion:addStatModifier("evasion", 10)
        end
      end,
    }
  end

    -- chitin set: 15% faster cooldowns (like insectoids)
    updateSetInfo{name = "chitin_cuisse",  replaceIcon = true}
    updateSetInfo{name = "chitin_greaves", replaceIcon = true}
    updateSetInfo{name = "chitin_mask",    replaceIcon = true}
  if isGuardians then
    updateSetInfo{name = "chitin_mail", replaceIcon = true}
  else
    updateSetInfo{
      name = "chitin_mail",
      replaceIcon = true,
      gameEffect = "Set Bonus: +15% Faster Cooldowns",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("chitin") then
          champion:addStatModifier("cooldown_rate", 15)
        end
      end,
    }
  end

    -- valor set: +5 strength
    updateSetInfo{name = "greaves_valor",   replaceIcon = true}
    updateSetInfo{name = "gauntlets_valor", replaceIcon = true}
    updateSetInfo{name = "helmet_valor",    replaceIcon = true}
    updateSetInfo{name = "cuisse_valor",    replaceIcon = true}
    updateSetInfo{name = "shield_valor",    replaceIcon = true}
  if isGuardians then
    updateSetInfo{name = "cuirass_valor", replaceIcon = true}
  else
    updateSetInfo{
      name = "cuirass_valor",
      replaceIcon = true,
      total = 6,
      gameEffect = "Set Bonus: +5 Strength",
      setBonus = function(self, champion)
        if champion:isArmorSetEquipped("valor") then
          champion:addStatModifier("strength", 5)
        end
      end,
    }
  end

    -- add set bonus descriptions to base armors
  if not isGuardians then
    addGameEffect("crystal_cuirass", "Set Bonus: +75 Health")
    addGameEffect("meteor_cuirass", "Set Bonus: Immune to Fire")
    addGameEffect("archmage_mantle", "Set Bonus: +50 Energy")
  end
end

-- Implement makeshift set bonus
local oldCastSpell = Spell.castSpell
function Spell.castSpell(spell, caster, x, y, direction, elevation, skill)
  if KnightMods:isEnabledInMod("set_bonuses_whitelist", true) and caster:isArmorSetEquipped("makeshift") then
    skill = skill + 1
  end
  oldCastSpell(spell, caster, x, y, direction, elevation, skill)
end

-- implement makeshift set bonus
KnightMods:enableIntrusiveHook("modifySpell")
local oldManaCost = KnightMods.modifySpellManaCost
function KnightMods.modifySpellManaCost(caster, spell, cost)
  local cost = oldManaCost(caster, spell, cost)
  if KnightMods:isEnabledInMod("set_bonuses_whitelist", true) and caster:isArmorSetEquipped("mirror") then
    cost = cost * 0.8
  end
  return cost
end

-- Load in the traits on load file and new game
local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
  oldDungeonLoadInitFile(self)
  if KnightMods:isEnabledInMod("set_bonuses_whitelist", true) then
    moreSetBonusesInit()
  end
end

-- called on game load to update save data
local oldUpdateSaveData = KnightMods.updateSaveData
function KnightMods.updateSaveData(oldVersion, newVersion)
  oldUpdateSaveData(oldVersion, newVersion)

  if KnightMods:isEnabledInMod("set_bonuses_whitelist", true)
      and oldVersion < (KnightMods:isModLoaded("The Guardians") and 2 or 1) then
    -- mirror set
    KnightMods.redefineName("mirror_tagelmust")
    KnightMods.redefineName("mirror_cuisse")
    KnightMods.redefineName("mirror_greaves")
    KnightMods.redefineName("mirror_gauntlets")
    KnightMods.redefineName("mirror_chestplate")

    -- rogue set
    KnightMods.redefineName("rogue_hood")
    KnightMods.redefineName("rogue_pants")
    KnightMods.redefineName("rogue_boots")
    KnightMods.redefineName("rogue_gloves")
    KnightMods.redefineName("rogue_vest")

    -- embalmers set
    KnightMods.redefineName("embalmers_headpiece")
    KnightMods.redefineName("embalmers_pants")
    KnightMods.redefineName("embalmers_boots")
    KnightMods.redefineName("embalmers_robe")

      -- makeshift set
    KnightMods.redefineName("makeshift_buckler")
    KnightMods.redefineName("makeshift_mask")
    KnightMods.redefineName("makeshift_legplates")
    KnightMods.redefineName("makeshift_chestplate")

    -- reed set
    KnightMods.redefineName("reed_legmail")
    KnightMods.redefineName("reed_helmet")
    KnightMods.redefineName("reed_sabaton")
    KnightMods.redefineName("reed_gauntlets")
    KnightMods.redefineName("reed_cuirass")

    -- lurker set
    KnightMods.redefineName("lurker_pants")
    KnightMods.redefineName("lurker_hood")
    KnightMods.redefineName("lurker_boots")
    KnightMods.redefineName("lurker_vest")

    -- reed set
    KnightMods.redefineName("chitin_cuisse")
    KnightMods.redefineName("chitin_greaves")
    KnightMods.redefineName("chitin_mask")
    KnightMods.redefineName("chitin_mail")

      -- reed set
    KnightMods.redefineName("greaves_valor")
    KnightMods.redefineName("gauntlets_valor")
    KnightMods.redefineName("helmet_valor")
    KnightMods.redefineName("cuisse_valor")
    KnightMods.redefineName("shield_valor")
    KnightMods.redefineName("cuirass_valor")

    -- game effects
    KnightMods.redefineName("crystal_cuirass")
    KnightMods.redefineName("meteor_cuirass")
    KnightMods.redefineName("archmage_mantle")
  end
end
