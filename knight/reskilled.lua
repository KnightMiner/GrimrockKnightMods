-- Contains improvements to champion skills and traits
KnightMods:_addModule("reskilled", "1.0")

-- dungeons that get skill replacements enabled
local SUPPORTED_DUNGEONS = {
  ["Lost City"] = true,
  ["Grimrock Unlimited"] = true,
}

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
    description = "You can attack separately with firearms in either hand. Combines with other types of dual wielding.",
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
    name = "km_heavy_dual_wield",
    uiName = "Dual Heavy",
    icon = KnightMods.skillIcons.heavy_dual_wield,
    iconAtlas = KnightMods.skillIconAtlas,
    description = "You can dual wield a heavy weapon with a non-heavy weapon.",
    -- hardcoded skill
  }
  -- improved throwing dual wielding cancels out the penalty, do not want to deal more damage when dual wielding throwing
  local strongerDescription = "Increases the power of dual wielding attacks by 20%."
  if KnightMods:getConfig("reskilled_delay_reach", false) then
    strongerDescription = strongerDescription .. " Does not affect throwing weapons if you also have improved throwing dual wielding."
  end
  defineTrait{
    name = "km_stronger_dual_wielding",
    uiName = "Stronger Dual Wielding",
    icon = KnightMods.skillIcons.stronger_dual_wielding,
    iconAtlas = KnightMods.skillIconAtlas,
    description = strongerDescription,
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
  defineTrait{
  	name = "km_quick_shot",
  	uiName = "Quick Shot",
  	icon = 17,
  	description = "Cooldown of missile attacks is reduced by 10%.",
  	onComputeCooldown = function(champion, weapon, attack, attackType, level)
  		if level > 0 and attackType == "missile" then return 0.9 end
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
  	name = "km_refined_palette",
  	uiName = "Refined Palette",
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
        skill.description = "Increases range of firearm attacks by 1 square and damage by 25% for each skill point. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
      elseif isGuardians then
        skill.description = "Increases range of firearm attacks by 1 square and critical chance by 2% for each skill point. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
      else
        skill.description = "Increases range of firearm attacks by 1 square. Also decreases the chance of a firearm malfunctioning. At 3rd skill level you can dual wield guns. At 5th skill level you achieve firearm mastery and do not suffer from firearm malfunctions anymore."
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
    skill.traits[5] = "km_quick_shot"
    skill.description = skill.description .. " At 5th level, reduces cooldown for Missile Weapons by 10%."
  end

  -- heavy - dual wielding
  skill = dungeon.skills["heavy_weapons"]
  if skill then
    skill.description = "Increases damage of Heavy Weapons by 20% for each skill point. At 3rd skill level, you can dual wield a heavy weapon with another weapon. At 5th skill level you can wield two-handed weapons in one hand."
    skill.traits[3] = "km_heavy_dual_wield"
  end

  -- accuracy - dual wielding boost
  skill = dungeon.skills["accuracy"]
  if skill then
    skill.description = skill.description .. " At 4th skill level attacks from dual wielding deal 20% more damage."
    skill.traits[4] = "km_stronger_dual_wielding"
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

  -- athletics - eat less food at lvl 4
  if isGuardians then -- guardians removes food negatives at 2 and increases health regen at 5
    -- guardians removes alchemy bonuses, perfect place for this bonus
    skill = dungeon.skills["alchemy"]
    if skill then
      skill.description = "A higher skill level in alchemy allows you to brew a wider range of potions using a Mortar and Pestle. At 3rd skill level, reduces food consumption by 15%. 4th and 5th skill level are required to unlock greater potions and bomb mastery."
      skill.traits[3] = "km_satiated"
    end
  else
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


  -- make force field concentration 4, its is quite good
  local spell = dungeon.spells["force_field"]
  if spell then
    spell.requirements = { "concentration", 4 }
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
  if weapon:hasTrait("heavy_weapon") then
    return champion:hasTrait("km_heavy_dual_wield")
  end
  if weapon:hasTrait("throwing_weapon") then
    return champion:hasTrait("km_throwing_dual_wield")
  end
  if weapon:hasTrait("firearm") then
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
  if self:hasTrait("km_firearm_dual_wield") or self:hasTrait("km_throwing_dual_wield") or self:hasTrait("km_heavy_dual_wield") then
		local weapon1 = self:getItem(ItemSlot.Weapon)
		local weapon2 = self:getItem(ItemSlot.OffHand)
    if weapon1 and weapon2 and canDualWield(self, weapon1) and canDualWield(self, weapon2) then
      -- no heavy + heavy dual wielding. Heavy can only dual wield with a non-heavy weapon
      if weapon1:hasTrait("heavy_weapon") and weapon2:hasTrait("heavy_weapon") then
        return false
      end
      -- melee weapon rules: must either have a dagger in one hand, or have the improved light weapon dual wielding
      if (weapon1:hasTrait("light_weapon") or weapon1:hasTrait("heavy_weapon"))
          and (weapon2:hasTrait("light_weapon") or weapon2:hasTrait("heavy_weapon")) then
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
      -- implementation of stronger dual wield trait
      elseif champion:hasTrait("km_stronger_dual_wielding") then
        power = power * 1.20
      end
    end

  	-- firearms: +30% damage per level
  	if weapon and attack:getAttackType() == "firearm" and KnightMods:isEnabledInMod("reskilled_firearms_whitelist", true) then
  		power = power * (1 + champion:getSkillLevel("firearms") * 0.25)
      -- TODO: boost mod based on another skill, e.g. accuracy?
  	end
  end

  return power, mod
end

-- finds ammo slot index, returns size and slot if found
if KnightMods:getConfig("reskilled_firearm_one_handed", true) then
  local function findAmmo(champion, ammoType)
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

local function makeTwoHanded(name)
  local item = dungeon.archs[name]
  if item then
    local itemComp = findArchComponentByClass(item, "Item")
    if itemComp then
      itemComp.traits = {"firearm", "two_handed"}
      redefineObject(item)
    end
  end
end

-- make some guns two handed
local function twoHandedGuns()
  if KnightMods:getConfig("reskilled_firearm_one_handed", true) then
    makeTwoHanded("repeater")
    makeTwoHanded("hand_cannon")
  end
end

-- called on game load to update save data
local oldUpdateSaveData = KnightMods.updateSaveData
function KnightMods.updateSaveData(oldVersion, newVersion)
  oldUpdateSaveData(oldVersion, newVersion)

  if oldVersion < 1 and KnightMods:getConfig("reskilled_firearm_one_handed", true) then
    KnightMods.redefineName("repeater")
    KnightMods.redefineName("hand_cannon")
  end
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
  if success and self.nutritionValue and champion:hasTrait("km_refined_palette") then
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

local BREADS = {}
for _, name in ipairs({"pitroot_bread", "bread"}) do
  BREADS[name] = true
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
    if champion:hasTrait("km_baker") and BREADS[name] then
      consumePreferredFood(champion)
    end
  end
  return success, empty
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
