--[[
Features:
* thunderstruck trait: halves all cooldowns
* perspicacious trait: doubles skill points per level
* unresurrectable trait: makes potions of resurrection grant XP instead of resurrecting

When starting a party with only one member, champion gains the unresurrectable trait
If the solo member is named Toorum, champion gains thunderstruck and the PlayingAsToorum flag is set
]]

KnightMods:_addModule("toorum", "1.0")
local function toorumInit()
	defineTrait{
		name = "km_thunderstruck",
		uiName = "Thunderstruck",
		priority = 30,
		icon = KnightMods.skillIcons.thunderstruck,
		iconAtlas = KnightMods.skillIconAtlas,
		description = "Halves all attack cooldowns"
	}
	defineTrait{
		name = "km_perspicacious",
		uiName = "Perspicacious",
		priority = 30,
		icon = KnightMods.skillIcons.perspicacious,
		iconAtlas = KnightMods.skillIconAtlas,
		description = "Gains +1 skill point every other level"
	}
	defineTrait{
		name = "km_unresurrectable",
		uiName = "Unresurrectable",
		priority = 30,
		icon = KnightMods.skillIcons.unresurrectable,
		iconAtlas = KnightMods.skillIconAtlas,
		description = "Potions of resurrection can be used at any time to restore health, energy, and remove some status effects"
	}
	defineTrait{
		name = "km_skill_crystals",
		uiName = "Sklll Crystals",
		priority = 30,
		icon = KnightMods.skillIcons.skill_crystals,
		iconAtlas = KnightMods.skillIconAtlas,
		description = "Using a healing crystal grants +1 skill point"
	}
	defineTrait{
		name = "km_death_cheat",
		uiName = "Death Cheat",
		priority = 30,
		icon = KnightMods.skillIcons.skill_crystals,
		iconAtlas = KnightMods.skillIconAtlas,
		description = "Champion can use healing crystal shards to cheat death"
	}
	defineTrait{
		name = "km_toorum_stats",
		uiName = "Toorum Stats",
		icon = 0,
		description = "Adds stat boosts for Toorum",
		hidden = true,
		onRecomputeStats = function(champion, level)
			-- Toorum has 11 skill extra skill points, let the player assign the others
			if level > 0 then
				champion:addStatModifier("strength",	3)
				champion:addStatModifier("dexterity", 3)
				champion:addStatModifier("vitality",	3)
				champion:addStatModifier("willpower", 2)
			end
		end,
	}
	defineTrait{
		name = "km_medusa_curse",
		uiName = "Medusa Curse",
		icon = 0,
		description = "Make medusa apply cursed instead of petrified",
		hidden = true,
	}

	-- resurrection potions are useless in a party of 1, so allow using to heal anytime
	if KnightMods:isEnabledInMod("potion_resurrection", false) then
		local potion = dungeon.archs["potion_resurrection"]
		if potion then
			local usableComp = findArchComponentByClass(potion, "UsableItem")
			if usableComp then
				usableComp.onUseItem = function(self, champion)
					-- can't be used on alive champion unless they have the trait
					if champion:isAlive() and not champion:hasTrait("km_unresurrectable") then return false end

					playSound("heal_party")
					-- dead champions get these cleared automatically
					if champion:isAlive() then
						champion:removeCondition("bear_form")
						champion:removeCondition("poison")
						champion:removeCondition("diseased")
						champion:removeCondition("paralyzed")
						champion:removeCondition("slow")
						champion:removeCondition("haste")
						champion:removeCondition("rage")
						champion:removeCondition("invisibility")
						champion:removeCondition("cursed")
						champion:removeCondition("blind")
						champion:removeCondition("protective_shield")
						champion:removeCondition("petrified")
					end
					champion:setBaseStat("health", champion:getCurrentStat("max_health"))
					champion:setBaseStat("energy", champion:getCurrentStat("max_energy"))
					champion:playHealingIndicator()
				end
				redefineObject(potion)
			end
		end
	end

  -- implement medusa curse, prevent petrify for single party
	if KnightMods:isEnabledInMod("potion_resurrection", false) then
	  local medusa = dungeon.archs["medusa"]
	  if medusa and medusa.components then
	    for i = 1, #medusa.components do
	      if medusa.components[i].class == "MonsterAttack" and medusa.components[i].name == "basicAttack" then
	        medusa.components[i].onAttack = function(self)
	  				self.go.eyeFlashParticle:restart()

	  				if party.elevation == self.go.elevation then
	  					local dx,dy = getForward(self.go.facing)
	  					if (party.x == self.go.x + dx and party.y == self.go.y + dy) or
	  						(party.x == self.go.x + dx*2 and party.y == self.go.y + dy*2) then
	  						party.party:shakeCamera(0.3, 0.3)
	  						-- choose random target
	  						for i=1,40 do
	  							local champion = party.party:getChampion(math.random(1,4))
	  							if champion:isAlive() and not champion:hasCondition("petrified") then
	  								local chance = 70 - champion:getCurrentStat("willpower")*2
	  								if math.random(1,100) < chance then
	                    -- switch petrified for curse in SP
	                    if champion:hasTrait("km_medusa_curse") then
	  										champion:setCondition("cursed", true)
												champion:setCondition("slow", true)
	                    else
	  										champion:setCondition("petrified", true)
	                    end
	  								end
	  								return false
	  							end
	  						end
	  					end
	  				end

	  				return false
	  			end
	        redefineObject(medusa)
	        break
	      end
	    end
	  end
	end
end

-- Thunderstruck implementation - halves cooldowns
local oldChampionUpdate = Champion.update
function Champion:update()
	oldChampionUpdate(self)
	if self:hasTrait("km_thunderstruck") then
		for i=1,2 do
			if self.cooldownTimer[i] > 0 then
				local dt = Time.deltaTime * (self:getCurrentStat("cooldown_rate") / 100)
				-- TODO: make slow and haste conditions change champion's cooldown rate
				if self:hasCondition("slow") then dt = dt * 0.5 end
				if self:hasCondition("haste") then dt = dt * 2 end
				self.cooldownTimer[i] = math.max(self.cooldownTimer[i] - dt, 0)
			end
		end
	end
end

-- Perspicacious implementation - doubles SP on levelup
local oldChampionLevelUp = Champion.levelUp
function Champion:levelUp()
	oldChampionLevelUp(self)
	-- bonus skill point every other level
	if self:hasTrait("km_perspicacious") and self.level % 2 == 0 then
		self:addSkillPoints(1)
	end
end

-- Skill crystal implementation
local oldCrystalClick = CrystalComponent.onClick
function CrystalComponent:onClick()
	-- TODO: mark crystal as used so it works outside of single use crystals
	-- should just be able to add a new field, told it should serialize automatically
	if self.enabled and config.singleUseCrystals then
		for i=1,4 do
			local champ = party:getChampionByOrdinal(i)
			if champ:getEnabled() and champ:hasTrait("km_skill_crystals") then
				champ:addSkillPoints(1)
			end
		end
	end
	return oldCrystalClick(self)
end

-- prevent dying if holding a healing crystal
local function cheatDeath(champion, item, slot, container)
  -- shrink stack
  if item.count > 1 then
    item.count = item.count - 1
  else
    container:removeItemFromSlot(slot)
  end
  party:heal()
	gui:hudPrint(string.format("%s cheated death using a healing crystal shard!", champion.name))
end

local oldChampionDie = Champion.die
function Champion:die()
  if not self:hasCondition("petrified") and self:hasTrait("km_death_cheat") then
    for slot, it in self:carriedItems() do
      if it.go.arch.name == "crystal_shard_healing" then
        cheatDeath(self, it, slot, self)
        return
      end
      if it.go.containeritem then
        for ctSlot, ctIt in it.go.containeritem:contents() do
          if ctIt.go.arch.name == "crystal_shard_healing" then
            cheatDeath(self, ctIt, ctSlot, it.go.containeritem)
            return
          end
        end
      end
    end
  end
  oldChampionDie(self)
end

-- Load in the traits on load file and new game
local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
	oldDungeonLoadInitFile(self)

	-- some dungeons add their own toorum mode
	if KnightMods:isEnabledInMod("toorum_global_blacklist", false) then
		toorumInit()
	end
end

-- add trait to partys with a single Toorum champion
local oldNewGame = GameMode.newGame
function GameMode:newGame()
	oldNewGame(self)

	-- some dungeons add their own toorum mode
	if not KnightMods:isEnabledInMod("toorum_global_blacklist", false) then return end

	-- champ 1 is force enabled, so only need to check 2 to 4
	local solo = true
	for i = 2,4 do
		if _G.party:getChampion(i):getEnabled() then
			solo = false
			break
		end
	end
	if solo then
		local champ = _G.party:getChampion(1)
    -- double movement speed
		_G.party:setPartyFlag(PartyFlag.PlayingAsToorum, true)

		local traits = KnightMods:getConfig("toorum_starting_traits", {})
		for i = 1, #traits do
			champ:addTrait(traits[i])
		end
		-- start with +1 skill point to assign as you wish
		-- classic toorum gave it to armor
		champ:addSkillPoints(1)
	end
end
