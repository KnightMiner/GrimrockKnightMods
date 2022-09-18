-- Misc changes
KnightMods:_addModule("tweaks", "1.0")

KnightMods:enableIntrusiveHook("fixMeteorStorm")
KnightMods:enableIntrusiveHook("darkboltDamage")

-- Make wands work with bonus effects
local oldCastSpell = Spell.castSpell
function Spell.castSpell(spell, caster, x, y, direction, elevation, skill)
  if KnightMods:isEnabledInMod("tweaks_whitelist", true) then
    -- make various wands boost magic
    if skill == "fire_magic" and caster:isEquipped("zhandul_orb") then
      skill = skill + 1
    elseif skill == "water_magic" and caster:isEquipped("nectarbranch_wand") then
      skill = skill + 1
    elseif skill == "air_magic" and caster:isEquipped("stormseed_orb") then
      skill = skill + 1
    elseif skill == "concentration" and caster:isEquipped("spirit_crook") then
      skill = skill + 1
    end
  end
  oldCastSpell(spell, caster, x, y, direction, elevation, skill)
end

-- acolyte staff makes spells cheaper
KnightMods:enableIntrusiveHook("modifySpell")
local oldManaCost = KnightMods.modifySpellManaCost
function KnightMods.modifySpellManaCost(caster, spell, cost)
  local cost = oldManaCost(caster, spell, cost)
  if caster:isEquipped("acolyte_staff") and KnightMods:isEnabledInMod("tweaks_whitelist", true) then
    cost = cost * 0.8
  end
  return cost
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

-- allow evasion and protection to work on projectiles
KnightMods:enableIntrusiveHook("modifyProjectileDamage")
local oldModifyProjectileDamage = KnightMods.modifyProjectileDamage
function KnightMods.modifyProjectileDamage(item, target, dmg, crit, directTarget)
  local dmg, msg = oldModifyProjectileDamage(item, target, dmg, crit, directTarget)
  if target.party then
    -- chance to dodge
    -- assuming accuracy of 35
    local tohit = math.clamp(95 - (directTarget:getEvasion() or 0), 5, 95)
    if math.random() > tohit / 100 then
      return false
    end

    -- choose body part to attack (chest 31%, head 22%, legs 25%, feet 22%)
    local r = math.random(1, 100)
    local bodySlot
    if r <= 31 then
      bodySlot = ItemSlot.Chest
    elseif r <= 31+22 then
      bodySlot = ItemSlot.Head
    elseif r <= 31+22+25 then
      bodySlot = ItemSlot.Legs
    else
      bodySlot = ItemSlot.Feet
    end

    -- damage reduction
    local protection = directTarget:getProtectionForBodyPart(bodySlot)
    if item.projectilePierce then protection = math.max(protection - item.projectilePierce, 0) end
    -- prevent protection from being too good, by only reducing half of prot
    -- since most monsters are probably balanced around 0 prot
    if protection > 0 then dmg = computeDamageReduction(dmg, protection / 2) end
    dmg = math.floor(dmg)
  end

  return dmg, msg
end

-- add special effect descriptions to wands
local function wandDescriptions()
  addGameEffect("zhandul_orb", "Intense Fire (Fire spells deal 20% more damage)")
  addGameEffect("spirit_crook", "Spirit Bridge (Concentration spells are more effective)")
  addGameEffect("nectarbranch_wand", "Riverflow (Water spells deal 20% more damage)")
  addGameEffect("stormseed_orb", "Intense Storm (Air spells deal 20% more damage)")
  addGameEffect("acolyte_staff", "Archmage (Spell energy costs are reduced by 20%)")
end

--[[
  Misc tweaks
]]

-- make sabre a light weapon
local function sabreLightWeapon()
  local item = dungeon.archs["sabre"]
  if item then
    local itemComp = findArchComponentByClass(item, "Item")
    if itemComp then
      itemComp.traits = {"light_weapon", "sword"}
    end
    local meleeComp = findArchComponentByClass(item, "MeleeAttack")
    if meleeComp then
      meleeComp.attackPower = 35
      meleeComp.requirements = { "light_weapons", 4 }
    end
  end
end

-- make hide vest just cloth armor
local function hideVestCloth()
  local item = dungeon.archs["hide_vest"]
  if item then
    local itemComp = findArchComponentByClass(item, "Item")
    if itemComp then
      itemComp.traits = {"chest_armor"}
    end
  end
end

-- make lightning rod a willpower weapon
local function lightningRodWillpower()
  local item = dungeon.archs["lightning_rod"]
  if item then
    local melee = findArchComponentByClass(item, "MeleeAttack")
    if melee then
      melee.baseDamageStat = "willpower"
    end
  end
end

-- make fire orb have an energy cost to fireball
local function fixFireOrb()
  local item = dungeon.archs["zhandul_orb"]
  if item then
    local spell = findArchComponentByClass(item, "CastSpell")
    if spell then
      spell.energyCost = 35
      spell.requirements = { "concentration", 3, "fire_magic", 2 }
    end
  end
end

-- make quarterstaff a dex reack weapon, no others exist
local function quarterstaffDex()
  local item = dungeon.archs["quarterstaff"]
  if item then
    local meleeComp = findArchComponentByClass(item, "MeleeAttack")
    if meleeComp then
      meleeComp.cooldown = 3
      meleeComp.baseDamageStat = "dexterity"
    end
  end
end

-- make smoked fish slightly more worthwhile in lost city, as cooking is a bit of effort
local function lostCitiesBetterSmokedFish()
  local mod = modSystem:getCurrentMod()
  if mod and mod.name == "Lost City" then
    local item = dungeon.archs["smoked_bass"]
    if item then
      local foodComp = findArchComponentByClass(item, "UsableItem")
      if foodComp then
        foodComp.nutritionValue = 375
      end
    end
  end
end

-- Allow throwing bombs in a slingshot as missile weapons
local function missileBombs()
  local bombs = {"fire_bomb", "frost_bomb", "shock_bomb", "poison_bomb"}
  for _, bomb in ipairs(bombs) do
    local bombDef = dungeon.archs[bomb]
    if bombDef then
      bombDef.components[#bombDef.components+1] = {
        class = "AmmoItem",
        name = "ammoitem",
        ammoType = "rock",
      }
    end
  end
end

local function brewBullets()
  defineRecipe{
    potion = "pellet_box",
    level = 3,
    ingredients = 5,
  }
end

-- bit of a mess, want to make bullets craft in a size of 5, or 15 with bomb trait
local oldBrewPotion = CraftPotionComponent.brewPotion
function CraftPotionComponent:brewPotion(champion)
  -- hardcode the recipe, single element making life easier
  if self.recipe ~= 5 then
    oldBrewPotion(self, champion)
    return
  end

  local alchemy = champion:getSkillLevel("alchemy")

  -- verify that champion has enough herbs
  local herbs = CraftPotionComponent.Herbs
  for i=1,#herbs do
    if herbs[5].count < herbs[5].reserved then
      gui:hudPrint(champion.name.." does not have enough herbs to craft this potion.")
      return
    end
  end

  -- get recipe
  local recipe = self:getPotionRecipe(self.recipe)
  if not recipe then
    gui:hudPrint(champion.name.." failed to brew a potion.")
    self.recipe = 0
    champion:showAttackPanel(nil)
    return
  end

  -- check alchemy skill
  if alchemy < (recipe.level or 0) then
    gui:hudPrint(champion.name.." is not skilled enough in Alchemy to brew this potion.")
    return
  end

  -- consume herbs
  local r = self.recipe
  for i=5,0,-1 do
    -- extract herb from recipe
    local h = math.floor(r / 10^i)
    r = r - h * 10^i

    if h ~= 0 then
      self:consumeHerb(champion, CraftPotionComponent.Herbs[h%10].name)
    end
  end

  local potion = recipe.potion

  local count = 1
  if potion == "pellet_box" then
    count = 5
    if champion:hasTrait("bomb_expert") then
      count = 15
    end
  end

  local mouseItem = gui:getMouseItem()
  if mouseItem == nil then
    -- create new potion to mouse hand
    local item = create(potion).item
    item:setStackSize(count)
    gui:setMouseItem(item)
  elseif mouseItem.go.arch.name == potion then
    -- merge new potion to stack in hand
    mouseItem.count = mouseItem.count + count
  else
    -- create new potion on the ground
    local item = spawn(party.go.map, potion, party.go.x, party.go.y, party.go.facing, party.go.elevation).item
    item:setStackSize(count)
  end

  -- gain exp
  -- if champion:getClass() == "alchemist" then
  --   champion:gainExp((recipe.level or 0) * 25)
  -- end

  soundSystem:playSound2D("brew_potion")

  party.go.statistics:increaseStat("potions_mixed", 1)

  self.recipe = 0
  champion:showAttackPanel(nil)
end

-- Load in the traits on load file and new game
local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
  oldDungeonLoadInitFile(self)

  if KnightMods:isEnabledInMod("tweaks_whitelist", true) then
    -- provided as functions for easy disabling
    wandDescriptions()
    sabreLightWeapon()
    hideVestCloth()
    quarterstaffDex()
    lostCitiesBetterSmokedFish()
    missileBombs()
  end
  if KnightMods:isEnabledInMod("tweaks_fix_fire_orb_whitelist", true) then
    fixFireOrb()
  end

  if KnightMods:isEnabledInMod("tweaks_lightning_rod_willpower_blacklist", false) then
    lightningRodWillpower()
  end
  if KnightMods:isEnabledInMod("tweaks_brew_bullets_blacklist", false) then
    brewBullets()
  end
end

-- called on game load to update save data
local oldUpdateSaveData = KnightMods.updateSaveData
function KnightMods.updateSaveData(oldVersion, newVersion)
  oldUpdateSaveData(oldVersion, newVersion)

  if oldVersion < 1 and KnightMods:isEnabledInMod("tweaks_whitelist", true) then
    -- game effects
    KnightMods.redefineName("zhandul_orb")
    KnightMods.redefineName("spirit_crook")
    KnightMods.redefineName("nectarbranch_wand")
    KnightMods.redefineName("stormseed_orb")
    KnightMods.redefineName("acolyte_staff")

    -- small tweaks
    KnightMods.redefineName("sabre")
    KnightMods.redefineName("lightning_rod")
    KnightMods.redefineName("quarterstaff")
    KnightMods.redefineName("hide_vest")

    -- bombs
    KnightMods.redefineName("fire_bomb")
    KnightMods.redefineName("frost_bomb")
    KnightMods.redefineName("shock_bomb")
    KnightMods.redefineName("poison_bomb")

    -- lost cities
    KnightMods.redefineName("smoked_bass")
  end
  if oldVersion == 1 and KnightMods:isModLoaded("The Guardians") then
    KnightMods.redefineName("zhandul_orb")
  end
end
