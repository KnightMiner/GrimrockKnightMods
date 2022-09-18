-- Contains improvements to champion skills and traits
KnightMods:_addModule("reskilled", "1.0")

--[[
  Defines all traits for this module
]]
local function defineTraits()
  --[[ Better Dual Wielding ]]--
  defineTrait{
    name = "km_firearm_dual_wield",
    uiName = "Dual Firearms",
    icon = KnightMods.skillIcons.firearm_dual_wield,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "You can attack separately with pellet guns in either hand. Combines with other types of dual wielding.",
    -- hardcoded skill
  }
  defineTrait{
    name = "km_throwing_dual_wield",
    uiName = "Dual Throwing",
    icon = KnightMods.skillIcons.throwing_dual_wield,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "You can use throwing weapons with other types of dual wielding.",
    -- hardcoded skill
  }
  defineTrait{
    name = "km_throwing_mastery",
    uiName = "Throwing Mastery",
    icon = 21,
    description = "Throwing weapons no longer have a damage penalty when dual wielding.",
    -- hardcoded skill
  }
  defineTrait{
    name = "km_heavy_crit",
    uiName = "Heavy Strike",
    icon = KnightMods.skillIcons.heavy_crit,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "Heavy weapons have an extra 10% chance to score a critical hit.",
    onComputeCritChance = function(champion, weapon, attack, attackType, level)
      if level > 0 and attackType == "melee" and weapon:hasTrait("heavy_weapon") then return 10 end
    end
  }
  defineTrait{
    name = "km_heavy_specialist",
    uiName = "Heavy Specialist",
    icon = KnightMods.skillIcons.heavy_specialist,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "Heavy weapon special attacks charge up 25% faster.",
    -- hardcoded skill
  }
  defineTrait{
    name = "km_sniper",
    uiName = "Sniper",
    icon = 17,
    description = "Bows and crossbows deal triple damage against far away targets.",
    -- hardcoded skill
  }

  --[[ Magic novices ]]--
  defineTrait{
  	name = "km_fire_strength",
  	uiName = "Strength of Flame",
  	icon = 60,
  	description = "The strength of the flames grants +2 strength.",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("strength", 2)
  		end
  	end,
  }
  defineTrait{
  	name = "km_air_dexterity",
  	uiName = "Agility of Air",
  	icon = 64,
  	description = "Knowledge of air grants +2 dexterity",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("dexterity", 2)
  		end
  	end,
  }
  defineTrait{
  	name = "km_earth_vitality",
  	uiName = "Life of Earth",
  	icon = 62,
  	description = "Training in the earth grants +2 vitality",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("vitality", 2)
  		end
  	end,
  }
  defineTrait{
  	name = "km_water_willpower",
  	uiName = "Energy of the Waves",
  	icon = 70,
  	description = "Energy of the waves grants +2 willpower",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("willpower", 2)
  		end
  	end,
  }
  -- guardians features
  defineTrait{
    name = "km_fullblood",
    uiName = "Fullblood Alchemist",
    icon = KnightMods.skillIcons.fullblood,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "Blooddrops in your inventory multiply based on steps taken. If you are an alchemist, they multiply faster.",
  }

  -- [[ Class traits ]]--
  -- new knight trait
  defineTrait{
    name = "km_set_master",
    uiName = "Set Mastery",
  	icon = KnightMods.skillIcons.set_master,
    iconAtlas = KnightMods.skillIconAtlas,
    hidden = true,
    description = "Armor sets require 1 fewer pieces for set bonuses",
  }
  -- new wizard trait
  defineTrait{
    name = "km_magic_affinity",
    uiName = "Magic Affinity",
    icon = 0,
    description = "35% chance to not use a magic charge on items.",
    hidden = true,
  }

  --[[ Skill Traits ]]--
  defineTrait{
    name = "km_stealth",
    uiName = "Stealth",
    icon = 104,
    description = "Doubles evasion bonus of equipped cloak. Shields grant +50% evasion.",
  }
  defineTrait{
    name = "km_archmage",
    uiName = "Archmage",
  	icon = KnightMods.skillIcons.archmage,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "Spell energy costs are reduced by 20%",
  }
  defineTrait{
  	name = "km_satiated",
  	uiName = "Satiated",
  	icon = KnightMods.skillIcons.satiated,
    iconAtlas = KnightMods.skillIconAtlas,
  	description = "Food consumption rate is decreased by 15%.",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("food_rate", -15)
  		end
  	end,
  }

  --[[ Character Gen Traits ]]--
  defineTrait{
  	name = "km_baker",
  	uiName = "Baker",
  	icon = KnightMods.skillIcons.baker,
    iconAtlas = KnightMods.skillIconAtlas,
  	charGen = true,
  	description = "You were a baker in your previous life, making you love eating bread.",
  }
  defineTrait{
  	name = "km_knowledge_keeper",
  	uiName = "Knowledge Keeper",
  	icon = KnightMods.skillIcons.knowledge_keeper,
    iconAtlas = KnightMods.skillIconAtlas,
  	charGen = true,
  	requiredRace = "human",
  	description = "Willpower +1 for each scroll carried.",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			-- count skulls
  			local scrolls = 0
  			for i=1,ItemSlot.MaxSlots do
  				local item = champion:getItem(i)
  				if item then
  					if item:hasTrait("spell_scroll") then
  						scrolls = scrolls + 1
  					else
  						local container = item.go.containeritem
  						if container then
  							local capacity = container:getCapacity()
  							for j=1,capacity do
  								local item2 = container:getItem(j)
  								if item2 and item2:hasTrait("spell_scroll") then
  									scrolls = scrolls + 1
  								end
  							end
  						end
  					end
  				end
  			end
  			champion:addStatModifier("willpower", scrolls)
  		end
  	end,
  }

  defineTrait{
  	name = "km_piety",
  	uiName = "Piety",
  	icon = 82,
  	charGen = true,
  	requiredRace = "insectoid",
  	description = "Sometimes seeking the arcane comes at the cost of your own well being. Energy regenerates 50% faster, while health regenerates 25% slower.",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			champion:addStatModifier("health_regeneration_rate", -25)
  			champion:addStatModifier("energy_regeneration_rate", 50)
  		end
  	end,
  }

  defineTrait{
  	name = "km_pirate_training",
  	uiName = "Pirate Training",
  	icon = KnightMods.skillIcons.pirate_training,
    iconAtlas = KnightMods.skillIconAtlas,
  	charGen = true,
  	requiredRace = "ratling",
  	description = "Your years aboard a shipdeck has made you more adept at using various ranged weapons, granting them +15 Accuracy.",
    onComputeAccuracy = function(champion, weapon, attack, attackType, level)
  		if level > 0 and (attackType == "missile" or attackType == "throw" or attackType == "firearm") then return 15 end
  	end,
  }

  defineTrait{
  	name = "km_rock_skin",
  	uiName = "Rock Skin",
  	icon = KnightMods.skillIcons.rock_skin,
    iconAtlas = KnightMods.skillIconAtlas,
  	charGen = true,
  	requiredRace = "minotaur",
  	description = "Grants +1 Protection and 1 Resist all for every two rocks carried.",
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			-- count skulls
  			local rocks = 0
  			for i=1,ItemSlot.MaxSlots do
  				local item = champion:getItem(i)
  				if item then
  					if item.go.name == "rock" then
  						rocks = rocks + item:getStackSize()
  					else
  						local container = item.go.containeritem
  						if container then
  							local capacity = container:getCapacity()
  							for j=1,capacity do
  								local item2 = container:getItem(j)
  								if item2 and item2.go.name == "rock" then
        						rocks = rocks + item2:getStackSize()
  								end
  							end
  						end
  					end
  				end
  			end
        local count = math.floor(rocks / 2)
  			champion:addStatModifier("protection", count)
  			champion:addStatModifier("resist_fire", count)
  			champion:addStatModifier("resist_cold", count)
  			champion:addStatModifier("resist_poison", count)
  			champion:addStatModifier("resist_shock", count)
  		end
  	end,
  }
  defineTrait{
  	name = "km_refined_palate",
  	uiName = "Refined Palate",
  	icon = KnightMods.skillIcons.refined_palette,
    iconAtlas = KnightMods.skillIconAtlas,
  	charGen = true,
  	requiredRace = "ratling",
  	description = "Unlike your fellow Ratlings, you appreciate the unique flavor of the food you eat. Gain +3 health for every unique food eaten.",
  }

  -- TODO: 2 more global traits?
end

--[[
  Adds the traits into the vanilla skills
]]
local function modifySkills()
  -- guardians makes some of its own tweaks, so skip the overlapping tweaks
  local isGuardians = KnightMods:isModLoaded("The Guardians")
  local skill

  -- firearms: now includes dual wielding
  if KnightMods:getConfig("reskilled_firearm_one_handed", true) then
    skill = dungeon.skills["firearms"]
    if skill then
      if KnightMods:isEnabledInMod("reskilled_firearms_whitelist", true) then
        skill.description = "Increases range of firearm attacks by 1 square and damage by 20% for each skill point. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield pellet guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
      elseif isGuardians then
        skill.description = "Increases range of firearm attacks by 1 square and critical chance by 2% for each skill point. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield pellet guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
      else
        skill.description = "Increases range of firearm attacks by 1 square. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield pellet guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
      end
      skill.traits[3] = "km_firearm_dual_wield"
    end
  end

  -- throwing: replaces double throw with dual wielding
  skill = dungeon.skills["throwing"]
  if skill then
    skill.traits[3] = "km_throwing_dual_wield"
    if KnightMods:getConfig("reskilled_replace_double_throw", true) then
      skill.traits[5] = "km_throwing_mastery"
      skill.description = "Increases damage of Throwing Weapons by 20% for each skill point. At 3rd skill level you can dual wield throwing weapons. At 5th skill level throwing weapons no longer have a damage penalty from dual wielding."
    else
      skill.description = "Increases damage of Throwing Weapons by 20% for each skill point. At 3rd skill level you can dual wield throwing weapons with other weapons. At 5th skill level you can throw weapons from both hands with one action."
    end
  end

  -- throwing: replaces double throw with dual wielding
  skill = dungeon.skills["missile_weapons"]
  if skill then
    skill.traits[5] = "km_sniper"
    skill.description = skill.description .. " At 5th level, bows and crossbows deal triple damage to far away targets."
  end

  -- heavy - dual wielding
  skill = dungeon.skills["heavy_weapons"]
  if skill then
    skill.description = "Increases damage of Heavy Weapons by 20% for each skill point. At 3rd skill level, heavy weapons have an extra 10% critical hit chance. At 5th skill level you can wield two-handed weapons in one hand."
    skill.traits[3] = "km_heavy_crit"
  end

  -- accuracy - heavy specialist
  skill = dungeon.skills["accuracy"]
  if skill then
    skill.description = skill.description .. " At 3rd skill level Heavy Weapon special attacks charge 25% faster."
    skill.traits[3] = "km_heavy_specialist"
  end

  -- dodge: +5 evasion per level, new stealth trait
  skill = dungeon.skills["dodge"]
  if skill then
    skill.description = "Increases evasion by 5 for each skill point. At 2nd skill level, doubles the evasion bonus of the equipped cloak and makes shields 50% more effective. At 3rd skill level, the cooldown period for all of your actions is decreased by 10%."
    if isGuardians then
      skill.description = skill.description .. " At 5th skill level, you have a 40% chance of evading elemental damage."
    end
    skill.onRecomputeStats = function(champion, level)
      champion:addStatModifier("evasion", level*5)
    end
    skill.traits[2] = "km_stealth"
  end

  if isGuardians then -- guardians removes food negatives at 2 and increases health regen at 5
    -- guardians removes alchemy bonuses, lets instead make spices more available
    skill = dungeon.skills["alchemy"]
    if skill then
      skill.description = "A higher skill level in alchemy allows you to brew a wider range of potions using a Mortar and Pestle. At 3rd skill level, blooddrops multiply in your inventory."
      skill.traits[3] = "km_fullblood"
    end
  else
    -- athletics - eat less food at lvl 4
    skill = dungeon.skills["athletics"]
    if skill then
      skill.description = skill.description .. " At 4th skill level, food consumption is reduced by 15%."
      skill.traits[4] = "km_satiated"
    end
  end

  -- concentration - archmage
  skill = dungeon.skills["concentration"]
  if skill then
    skill.description = skill.description .. " At 5th level, spell energy cost is reduced by 20%."
    skill.traits[5] = "km_archmage"
  end

  -- elemental magic: +2 stat boosts
  skill = dungeon.skills["fire_magic"]
  if skill then
    skill.description =  "Increases damage of fire spells by 20% for each skill point. At 2nd skill level, you gain Strength +2. At 5th skill level you gain Resist Fire +50."
    skill.traits[2] = "km_fire_strength"
  end
  skill = dungeon.skills["air_magic"]
  if skill then
    skill.description =  "Increases damage of air spells by 20% for each skill point. At 2nd skill level, you gain Dexterity +2. At 5th skill level you gain Resist Shock +50."
    skill.traits[2] = "km_air_dexterity"
  end
  skill = dungeon.skills["earth_magic"]
  if skill then
    skill.description =  "Increases damage of earth spells by 20% for each skill point. At 2nd skill level, you gain Vitality +2. At 5th skill level you gain Resist Poison +50."
    skill.traits[2] = "km_earth_vitality"
  end
  skill = dungeon.skills["water_magic"]
  if skill then
    skill.description =  "Increases damage of water spells by 20% for each skill point. At 2nd skill level, you gain Willpower +2. At 5th skill level you gain Resist Cold +50."
    skill.traits[2] = "km_water_willpower"
  end

  -- rename dual wielding trait
  local trait = dungeon.traits["dual_wield"]
  if trait then
    trait.uiName = "Dual Light"
  end
  trait = dungeon.traits["improved_dual_wield"]
  if trait then
    trait.uiName = "Light Dual Mastery"
  end

  -- make force field concentration 3, its is quite good
  local spell = dungeon.spells["force_field"]
  if spell then
    spell.requirements = { "concentration", 3 }
  end
end

-- defines all classes and class related traits
local function defineClasses()
  -- ranger: dex version of barbarian
  defineCharClass{
  	name = "km_ranger",
  	uiName = "Ranger",
  	optionalTraits = 2,
  }
  defineTrait{
  	name = "km_ranger",
  	uiName = "Ranger",
  	icon = KnightMods.skillIcons.ranger,
    iconAtlas = KnightMods.skillIconAtlas,
  	description = "As a ranger, you specialize in blending in with your surroundings and striking without being seen.",
  	gameEffect = [[
  	- Health 55 (+7 per level), Energy 35 (+4 per level)
  	- Dexterity +1 per level.]],
  	onRecomputeStats = function(champion, level)
  		if level > 0 then
  			level = champion:getLevel()
  			champion:addStatModifier("dexterity", level)
  			champion:addStatModifier("max_health", 60 + (level-1) * 6)
  			champion:addStatModifier("max_energy", 30 + (level-1) * 4)
  		end
  	end,
  }
end

-- Make changes to classes
local function modifyClasses()
  -- knight gains a new ability, add it to description
  -- to be more competitive with barbarian, now +8 health per level and +2 prot
  local trait = dungeon.traits["knight"]
  if trait then
    trait.gameEffect = [[
    - Health 60 (+8 per level), Energy 30 (+3 per level)
    - Protection +2 per level.
    - Armor sets are complete with one fewer piece.
    - Weight of equipped armor is reduced by 50%.
    - Evasion bonus of equipped shields is increased by 50%.]]
    if KnightMods:isModLoaded("The Guardians") then
      trait.gameEffect = trait.gameEffect .. '\n- You are immune to the curse condition.'
    end
    trait.onRecomputeStats = function(champion, level)
      if level > 0 then
        level = champion:getLevel()
        champion:addStatModifier("max_health", 60 + (level-1) * 8)
        champion:addStatModifier("max_energy", 30 + (level-1) * 3)
        champion:addStatModifier("protection", level * 2)
      end
    end
  end
  local charClass = dungeon.charClasses["knight"]
  if charClass then
    charClass.traits = { "armor_expert", "shield_expert", "km_set_master" }
  end

  -- fighter: 1% less cooldown per level, +1 more energy per level
  trait = dungeon.traits["fighter"]
  if trait then
    trait.gameEffect = [[
    - Health 60 (+7 per level), Energy 30 (+4 per level)
    - Cooldown of melee weapons decreases by 1% each level.
    - Special attacks with melee weapons take half the time to build up and cost 25% less energy.
    - Accuracy +1 per level.]]
    trait.onRecomputeStats = function(champion, level)
  		if level > 0 then
  			level = champion:getLevel()
  			champion:addStatModifier("max_health", 60 + (level-1) * 7)
  			champion:addStatModifier("max_energy", 30 + (level-1) * 4)
  		end
  	end
    trait.onComputeAccuracy = function(champion, weapon, attack, attackType, level)
      if level > 0 then return champion:getLevel() end
    end
  end

  -- barbarian is so good, why so much health?
  -- drop to 70 +9 health, effectively 24 less over 14 dumpExpForLevels
  trait = dungeon.traits["barbarian"]
  if trait then
    trait.gameEffect = [[
  	- Health 70 (+9 per level), Energy 30 (+2 per level)
  	- Strength +1 per level.]]
  	trait.onRecomputeStats = function(champion, level)
  		if level > 0 then
  			level = champion:getLevel()
  			champion:addStatModifier("strength", level)
  			champion:addStatModifier("max_health", 75 + (level-1) * 9)
  			champion:addStatModifier("max_energy", 30 + (level-1) * 3)
  		end
  	end
  end

  -- wizard: 35% chance to not use charges
  trait = dungeon.traits["wizard"]
  if trait then
    trait.gameEffect = trait.gameEffect .. '\n- 35% chance to not use a magic charge on items.'
  end
  charClass = dungeon.charClasses["wizard"]
  if charClass then
    charClass.traits = { "hand_caster", "km_magic_affinity" }
  end

  -- alchemist: +1% crit chance per level with guns
  trait = dungeon.traits["alchemist"]
  if trait then
    trait.gameEffect = trait.gameEffect .. '\n- +1% chance per level to score a critical hit with firearms.'
    trait.onComputeCritChance = function(champion, weapon, attack, attackType, level)
  		if level > 0 and attackType == "firearm" then return champion:getLevel() end
  	end
  end

end

--[[
  Dual Wielding hooks
]]

-- logic to patch generic start methods
local function patchStartForDualWielding(original)
  return function(self, champion, slot)
    local cooldownIndex = slot == ItemSlot.Weapon and 2 or 1
    local oldCooldown = champion.cooldownTimer[cooldownIndex]
    -- store before attacking to prevent losing dual wielding status when throwing the last in a stack
    local couldDualWield = champion:isDualWielding()
    original(self, champion, slot)
    -- if dual wielding, restore other hand to its original value
    if couldDualWield then
      champion.cooldownTimer[cooldownIndex] = oldCooldown
      champion.attackResult.side = slot
    end
  end
end
-- currently works with throwing and guns
ThrowAttackComponent.start = patchStartForDualWielding(ThrowAttackComponent.start)
FirearmAttackComponent.start = patchStartForDualWielding(FirearmAttackComponent.start)

local function canDualWield(champion, weapon)
  if weapon:hasTrait("light_weapon") then
    return champion:hasTrait("dual_wield")
  end
  if weapon:hasTrait("throwing_weapon") then
    return champion:hasTrait("km_throwing_dual_wield")
  end
  if weapon:hasTrait("firearm") and weapon.go.firearmattack.ammo == "pellet" then
    return champion:hasTrait("km_firearm_dual_wield")
  end
  return false
end

local disableDualWieldingHack = false

-- allow dual wielding guns and throwing with light weapons
local oldDualWielding = Champion.isDualWielding
function Champion:isDualWielding()
  -- no dual wielding if a hand is injured
  -- since the hand gets no benefits when injured, it seems only fair it gets no debuffs
  if self:hasCondition("right_hand_wound") or self:hasCondition("left_hand_wound") then
    return false
  end

  -- if we have either of our traits, need to override logic
  if self:hasTrait("km_firearm_dual_wield") or self:hasTrait("km_throwing_dual_wield") then
		local weapon1 = self:getItem(ItemSlot.Weapon)
		local weapon2 = self:getItem(ItemSlot.OffHand)
    if weapon1 and weapon2 and canDualWield(self, weapon1) and canDualWield(self, weapon2) then
      -- melee weapon rules: must either have a dagger in one hand, or have the improved light weapon dual wielding
      if weapon1:hasTrait("light_weapon") and weapon2:hasTrait("light_weapon") then
        return self:hasTrait("improved_dual_wield") or weapon1:hasTrait("dagger") or weapon2:hasTrait("dagger")
      end
      -- cannot dual wield throwing with throwing unless replacing the double throw trait
      -- otherwise it messes double throw behavior
      return KnightMods:getConfig("reskilled_replace_double_throw") or not (weapon1:hasTrait("throwing_weapon") and weapon2:hasTrait("throwing_weapon"))
    end
    return false
  end
  -- safety for dungeons that override the logic
  return oldDualWielding(self)
end

-- dual wielding damage boosts
KnightMods:enableIntrusiveHook("modifyAttackStats")
local oldAttackStat = KnightMods.modifyAttackStats
function KnightMods.modifyAttackStats(champion, weapon, attack, power, mod)
  power, mod = oldAttackStat(champion, weapon, attack, power, mod)

  if weapon then
    if weapon and champion:isDualWielding() then
      if champion:hasTrait("km_throwing_mastery") and attack:getAttackType() == "throw" then
        -- undo dual wield penalty
        if champion:hasTrait("rogue_dual_wield") then
          power = power / 0.75
        else
          power = power / 0.6
        end
      end
    end

  	-- firearms: +20% damage per level
  	if weapon and attack:getAttackType() == "firearm" and KnightMods:isEnabledInMod("reskilled_firearms_whitelist", true) then
  		power = power * (1 + champion:getSkillLevel("firearms") * 0.20)
  	end
  end

  return power, mod
end

-- store the projectile origin after throwing
local oldItemComponentThrow = ItemComponent.throw
function ItemComponent:throw(caster, origin, direction, power, gravity, velocityUp)
  oldItemComponentThrow(self, caster, origin, direction, power, gravity, velocityUp)
  self.go.thrownFromX = self.go.x
  self.go.thrownFromY = self.go.y
end

-- Allows modifying the amount of damage done by a projectile before hit
KnightMods:enableIntrusiveHook("modifyProjectileDamage")
local oldModifyProjectileDamage = KnightMods.modifyProjectileDamage
function KnightMods.modifyProjectileDamage(item, target, dmg, crit, directTarget)
  local dmg, msg = oldModifyProjectileDamage(item, target, dmg, crit, directTarget)

  if item.thrownByChampion and item.go.thrownFromX and item.go.thrownFromY then
    -- we want this working on just missile, but that is quite difficult to determine at this point
    -- as a simplification, limit to arrows as you cannot throw those
    local type = item.go.ammoitem and item.go.ammoitem.ammoType
		local champ = party:getChampionByOrdinal(item.thrownByChampion)
    local dist = math.abs(target.x - item.go.thrownFromX) + math.abs(target.y - item.go.thrownFromY)
    if dist > 3 and (type == "arrow" or type == "quarrel") and champ:hasTrait("km_sniper") then
      return dmg * 3, "Sniper"
    end
  end

  return dmg, msg
end

-- finds ammo slot index, returns size and slot if found
local findAmmo = nil
if KnightMods:getConfig("reskilled_firearm_one_handed", true) then
  findAmmo = function(champion, ammoType)
    for i=1,ItemSlot.MaxSlots do
      local ammo = champion:getItem(i)
    	if ammo then ammo = ammo.go.ammoitem end
    	if ammo and ammoType == ammo:getAmmoType() then
    		return i, ammo.go.item.count or 1
    	end
    end
    return nil, 0
  end

  -- have guns pull ammo from anywhere in the inventory
  function FirearmAttackComponent:checkAmmo(champion, slot)
  	if self.clipSize then
  		return self.loadedCount or 0
  	end
    -- search anywhere in inventory for ammo
    local slot, count = findAmmo(champion, self.ammo)
    return count
  end

  function FirearmAttackComponent:consumeAmmo(champion, handSlot, count)
  	count = count or 1

    local slot = findAmmo(champion, self.ammo)
    if not slot then
  		champion:showAttackResult("No ammo")
  		return 0
    end
  	local ammo = champion:getItem(slot)
  	if ammo then ammo = ammo.go.ammoitem end
    -- technically redundant, but safety is good
  	if not ammo or self.ammo ~= ammo:getAmmoType() then
  		champion:showAttackResult("No ammo")
  		return 0
  	end

  	count = math.min(count, ammo.go.item.count)
  	ammo.go.item.count = ammo.go.item.count - count

  	if ammo.go.item.count == 0 then
  		champion:removeItemFromSlot(slot)
  	end

  	return count
  end
end

-- make some guns two handed
local function twoHandedGuns()
  if KnightMods:getConfig("reskilled_firearm_one_handed", true) then
    local item = dungeon.archs["hand_cannon"]
    if item then
      local itemComp = findArchComponentByClass(item, "Item")
      if itemComp then
        itemComp.traits = {"firearm", "two_handed"}
        redefineObject(item)
      end
    end
  end
end

-- hack: no champion parameter to melee attack buildup, so store it from the draw method
local lastChampionIndex = -1
local oldAttackFrameDraw = AttackFrame.drawItemSlot
function AttackFrame:drawItemSlot(x, y, width, height, slot)
  -- store the champion to reduce cooldown time
  lastChampionIndex = self.championIndex
  oldAttackFrameDraw(self, x, y, width, height, slot)
  lastChampionIndex = -1

  -- draw firearm ammo count
  if findAmmo then
    local champion = party.champions[self.championIndex]
    local item = champion:getItem(slot)
    if item then
      local firearmAttack = item.go.firearmattack
      if firearmAttack then
        local slot, count = findAmmo(champion, firearmAttack.ammo)
        gui:drawTextAligned(tostring(count), x + 64, y + 63 + math.floor((height - 75)/2), "right", FontType.PalatinoTiny)
      end
    end
  end
end

-- reduce heavy weapon cooldown time
local oldBuildup = MeleeAttackComponent.getBuildup
function MeleeAttackComponent:getBuildup()
  local buildupTime = oldBuildup(self)
  if lastChampionIndex ~= -1 and party.champions[lastChampionIndex]:hasTrait("km_heavy_specialist") and self.go.item:hasTrait("heavy_weapon") then
    buildupTime = buildupTime * 0.75
  end
  return buildupTime
end

--[[
  Misc trait implementations
]]

-- implement stealth trait
local oldEquipmentRecomputeStats = EquipmentItemComponent.recomputeStats
function EquipmentItemComponent:recomputeStats(champion, slot)
  if not self.enabled then return end
	if self.evasion and self.evasion > 0 and champion:hasTrait("km_stealth") and self:isEquipped(champion, slot) then
    if self.go.item:hasTrait("cloak") then
      champion.stats.evasion.current = champion.stats.evasion.current + self.evasion
    end
    if self.go.item:hasTrait("shield") then
			champion.stats.evasion.current = champion.stats.evasion.current + self.evasion/2
    end
  end
  oldEquipmentRecomputeStats(self, champion, slot)
end

-- Knight bonus - +1 armor piece towards set bonuses
local oldChampionGetArmorSetPiecesEquipped = Champion.getArmorSetPiecesEquipped
function Champion:getArmorSetPiecesEquipped(name)
  local base = oldChampionGetArmorSetPiecesEquipped(self, name)
  if self:hasTrait("km_set_master") then
    return base + 1
  end
  return base
end

-- implement combat caster
KnightMods:enableIntrusiveHook("modifySpell")
local oldManaCost = KnightMods.modifySpellManaCost
function KnightMods.modifySpellManaCost(caster, spell, cost)
  local cost = oldManaCost(caster, spell, cost)
  if caster:hasTrait("km_archmage") then
    cost = cost * 0.8
  end
  return cost
end

-- magic affinity
local oldCastSpellStart = CastSpellComponent.start
function CastSpellComponent:start(champion, slot)
  if champion:hasTrait("km_magic_affinity") then
    if self.charges and self.charges > 0 and Spell.getSpell(self.spell) then
      if math.random() < 0.35 then
        self.charges = self.charges + 1 -- will be subtracted as part of the vanilla logic
      end
    end
  end
  oldCastSpellStart(self, champion, slot)
end

-- increase num foods eaten for ratling refined
local oldOnConsumeFood = UsableItemComponent.onUseItem
function UsableItemComponent:onUseItem(champion)
  local value = self.nutritionValue
  local name = self.go.arch.name
  local success, empty = oldOnConsumeFood(self, champion)
  if success and self.nutritionValue and champion:hasTrait("km_refined_palate") then
    local key = "km_refined_palette" .. champion.ordinal
    if not _G.party[key] then
      _G.party[key] = {}
    end
    local set = _G.party[key]
    if not set[name] then
      set[name] = true
      champion:modifyBaseStat("max_health", 3)
      champion:modifyBaseStat("health", 3)
    	gui:hudPrint(string.format("%s discovered a new food, +3 health!", champion.name))
      soundSystem:playSound2D(champion:getRace().."_happy")
    end
  end
  return success, empty
end

-- ensure refined palette serializes
if PartyComponent._autoSerialize then
  for i = 1, 4 do
    PartyComponent._autoSerialize["km_refined_palette" .. i] = true
  end
else
  local keys = {}
  for i = 1, 4 do
    keys[i] = "km_refined_palette" .. i
  end
  PartyComponent._autoSerialize = Set(keys)
end

-- clone of the vanilla method but with sounds for human and minotaur
local function consumePreferredFood(champion)
  champion.healthiness = champion.healthiness + 1

  -- next level reached?
  local nextLevel
  local step = 3
  local t = step
  for i=1,10 do
    if champion.healthiness == t then
      nextLevel = true
    end
    step = step + 1
    t = t + step
  end

  if nextLevel then
    -- pick random stat to increase
    local stats = { "strength", "dexterity", "vitality", "willpower" }
    champion:upgradeBaseStat(stats[champion:randomNumber() % 4 + 1], 1)
    -- human and minotaur lack happy sounds
    local race = champion:getRace()
    if race == "minotaur" then
      soundSystem:playSound2D("damage_bear")
    elseif race == "human" then
      soundSystem:playSound2D("power_attack_yell_human_"..champion:getSex())
    else
      soundSystem:playSound2D(champion:getRace().."_happy")
    end
  end
end

local oldOnConsumeFood = UsableItemComponent.onUseItem
function UsableItemComponent:onUseItem(champion)
  local name = self.go.arch.name
  local success, empty = oldOnConsumeFood(self, champion)
  if success then
    if champion:hasTrait("km_baker") and (name == "bread" or name == "pitroot_bread") then
      consumePreferredFood(champion)
    end
  end
  return success, empty
end

-- extra herb multiplying
local oldPartyMove = PartyMove.enter
function PartyMove:enter(direction, speed, forcedMovement)
  oldPartyMove(self, direction, speed, forcedMovement)

  -- update herbalism
  local tilesMoved = party.go.statistics:getStat("tiles_moved")
  -- this will double the rate of alchemist, so it happens every 425 step
  -- for non-alchemists, same rate as alchemists but different timing
  if (tilesMoved % 850) == 425 then
  for i=1,4 do
    local ch = party.champions[i]
      if ch:hasTrait("km_fullblood") then
        ch:updateHerbalism2("blooddrop_cap")
      end
    end
  end
end

--[[
  Init
]]
local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
  oldDungeonLoadInitFile(self)

  -- provided as functions for easy disabling
  defineTraits()
  defineClasses()

  -- other tweaks will mess with mods, so skip if not supported
  if not KnightMods:isEnabledInMod("reskilled_whitelist", true) then
    return
  end

  modifySkills()
  modifyClasses()
  twoHandedGuns()
end


-- called on game load to update save data
local oldUpdateSaveData = KnightMods.updateSaveData
function KnightMods.updateSaveData(oldVersion, newVersion)
  if oldVersion < 1 and KnightMods:getConfig("reskilled_firearm_one_handed", true) then
    KnightMods.redefineName("hand_cannon")
  end
  if oldVersion < 2 then
    KnightMods.redefineName("repeater")
    for i=1,4 do
      local ch = party.champions[i]
      ch:removeTrait("km_gardener")
      ch:removeTrait("km_heavy_dual_wield")
      ch:removeTrait("km_stronger_dual_wielding")
      ch:removeTrait("km_quick_shot")
      
      if ch:hasTrait("km_refined_palette") then
        ch:removeTrait("km_refined_palette")
        ch:addTrait("km_refined_palate")
      end

      if KnightMods:isModLoaded("The Guardians") then
        local alchemy = ch:getNaturalSkillLevel("alchemy")
        if alchemy >= 3 then
          ch:addTrait("km_fullblood")
        end
      end
      local heavy = ch:getNaturalSkillLevel("heavy_weapons")
      if heavy >= 3 then
        ch:addTrait("km_heavy_crit")
      end
      local accuracy = ch:getNaturalSkillLevel("accuracy")
      if accuracy >= 3 then
        ch:addTrait("km_heavy_specialist")
      end
      local missile = ch:getNaturalSkillLevel("missile_weapons")
      if missile >= 5 then
        ch:addTrait("km_sniper")
      end
    end
  end
end
