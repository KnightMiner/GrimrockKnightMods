-- Add hook before flooring to modify damage
if KnightMods:_isIntrusiveHookEnabled("modifyAttackStats") then
  function Champion:getDamageWithAttack(weapon, attack)
    -- check skill level requirement
    if attack.skill and attack.requiredLevel and self:getSkillLevel(attack.skill) < attack.requiredLevel then
      return nil
    end

    local power = attack:getAttackPower()

    -- dual wield penalty
    if weapon and self:isDualWielding() then
      if self:hasTrait("rogue_dual_wield") then
        power = power * 0.75
      else
        power = power * 0.6
      end
    end

    -- light/heavy weapon skill bonus
    if weapon and attack:getAttackType() == "melee" then
      if weapon:hasTrait("light_weapon") then
        power = power * (1 + self:getSkillLevel("light_weapons") * 0.2)
      elseif weapon:hasTrait("heavy_weapon") then
        power = power * (1 + self:getSkillLevel("heavy_weapons") * 0.2)
      end
    end

    -- throwing/missile weapon skill bonus
    if weapon and attack:getAttackType() == "throw" then
      power = power * (1 + self:getSkillLevel("throwing") * 0.2)
    end
    if weapon and attack:getAttackType() == "missile" then
      power = power * (1 + self:getSkillLevel("missile_weapons") * 0.2)
    end

    -- str/dex stat modifier
    local mod = 0
    local baseStat = attack:getBaseDamageStat()
    if baseStat then
      mod = math.floor(self:getCurrentStat(baseStat) - 10)
    end

    -- ammo bonus for missile weapons
    if attack:getAttackType() == "missile" then
      local slot = iff(self:getItem(ItemSlot.Weapon) == weapon, ItemSlot.Weapon, ItemSlot.OffHand)
      local ammo = self:getOtherHandItem(slot)
      if ammo and attack:checkAmmo(self, slot) then
        local ammoItem = ammo.go.ammoitem
        if ammoItem then
          --print("ammo bonus: ", ammoItem:getAttackPower() or 0)
          mod = mod + (ammoItem:getAttackPower() or 0)
        end
      end
    end

    -- aggressive trait
    local aggressive = self:hasTrait("aggressive")
    if aggressive then mod = mod + 4 end

    -- conditions
    if self:hasCondition("starving") then power = power / 2 end

    -- hook to modify stats before floor
    power, mod = KnightMods.modifyAttackStats(self, weapon, attack, power, mod)

    -- floor and return
    power = math.max(math.floor(power), 0)
    return power,mod
  end
end

-- allow modifying spell cooldown
if KnightMods:_isIntrusiveHookEnabled("modifySpells") then
  function Champion:castSpell(gesture)
    -- can't cast spell with wounded head
    if self:hasCondition("head_wound") then
      self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
      return false
    end

    -- find spell
    local spell = Spell.getSpellByGesture(gesture)
    if not spell then
      self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
      soundSystem:playSound2D("spell_fizzle")
      self:spendEnergy(math.random(5,13))
      --self:clearRunes()
      return false
    end

    -- check skill level
    if not config.unlimitedSpells then
      -- check skill requirements
      if spell.requirements and not Skill.checkRequirements(self, spell.requirements) then
        self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
        soundSystem:playSound2D("spell_fizzle")
        self:spendEnergy(math.random(5,13))
        self:clearRunes()
        return false
      end
    end

    -- spend energy
    if not config.unlimitedSpells then
      local cost = KnightMods.modifySpellManaCost(self, spell, spell.manaCost)
      --if self:getTalent("archmage") then cost = math.floor(cost / 2) end
      if self:getEnergy() < cost then
        self:showAttackResult("Out of energy", GuiItem.SpellNoEnergy)
        soundSystem:playSound2D("spell_out_of_energy")
        return
      end
      self:spendEnergy(cost)
    end

    if party:callHook("onCastSpell", objectToProxy(self), spell.name) == false then
      return false
    end

    messageSystem:sendMessageNEW("onChampionCastSpell", self, spell)

    self:clearRunes()

    local skill = 0
    if spell.skill then skill = self:getSkillLevel(spell.skill) end
    --if config.unlimitedSpells then skill = math.max(skill, 3) end
    local pos = party.go:getWorldPositionFast()
    local x,y = party.go.map:worldToMap(pos)
    Spell.castSpell(spell, self, x, y, party.go.facing, party.go.elevation, skill)

    -- DIFFERENCE: uses normal cooldown logic
    local cooldown = KnightMods.modifySpellCooldown(self, spell, 5)
    self.cooldownTimer[1] = cooldown
    self.cooldownTimer[2] = cooldown

    -- strenous activity consumes food
    self:consumeFood(math.random(4,9))

    -- learn new spell?
    if not spell.hidden and not self:hasTrait(spell.name) then
      self:addTrait(spell.name)
      gui:hudPrint(self.name.." learned a new spell!")
      soundSystem:playSound2D("discover_spell")
    end

    party.go.statistics:increaseStat("spells_cast", 1)

    return true
  end

  function CastSpellComponent:start(champion, slot)
    local name = self.spell
    if not name then console:warn("unknown wand spell"); return end

    -- find spell
    local spell = Spell.getSpell(name)
    if not spell then
      console:warn("Unknown spell: "..name)
      return
    end

    if self.charges == 0 then return end

    -- use wand's power as spell skill
    local skill = (self.power or 0)
    local pos = party.go:getWorldPositionFast()
    local x,y = party.go.map:worldToMap(pos)
    Spell.castSpell(spell, champion, x, y, party.go.facing, party.go.elevation, skill)

    local cooldown = KnightMods.modifySpellCooldown(champion, spell, self.cooldown or 0)
    champion.cooldownTimer[1] = champion.cooldownTimer[1] + cooldown
    champion.cooldownTimer[2] = champion.cooldownTimer[2] + cooldown

    -- consume charges
    if self.charges then
      self.charges = self.charges - 1
      if self.charges < 1 then
        self:deplete()
      end
    end

    -- strenous activity consumes food
    champion:consumeFood(math.random(1,5))
  end
end


-- makes meteor storm work with fire orb, and fixes wrong level for meteor hammer
if KnightMods:_isIntrusiveHookEnabled("fixMeteorStorm") then
  function Spell_meteorStorm(casterOrdinal, spreadX, spreadY, skill)
    if party:isUnderwater() then return end

    local meteorCount = 5

    local spell = spawn(party.go.map, "fireball_medium", party.go.x, party.go.y, party.go.facing, party.go.elevation)
    local caster = party:getChampionByOrdinal(casterOrdinal)
    local pos = Spell.getCasterPositionInWorld(caster)
    skill = skill or caster:getSkillLevel("fire_magic")

    -- offset position
    local rdx,rdy = getDxDy((party.go.facing+1)%4)
    pos.x = pos.x - rdx * spreadX
    pos.y = pos.y + spreadY
    pos.z = pos.z + rdy * spreadX

    spell:setWorldPosition(pos)
    spell.projectile:setAttackPower(15 * (1 + skill*0.2))
    spell.projectile:setIgnoreEntity(party.go)
    spell.projectile:setCastByChampion(casterOrdinal)
  end

  function BuiltInSpell.meteorStorm(caster, x, y, direction, elevation, skill)
    local meteorCount = 5

    for i=1,meteorCount do
      local spreadX = math.random() * 0.5 * iff((i % 2) == 0, 1, -1)
      local spreadY = -(i / meteorCount - 0.5)
      messageSystem:delayedFunctionCall("Spell_meteorStorm", (i-1) * 0.15, caster.ordinal, spreadX, spreadY, skill)
    end

    party:endCondition("invisibility")
  end
end

-- boost darkbolt damage based on concentration skill
if KnightMods:_isIntrusiveHookEnabled("darkboltDamage") then
  function BuiltInSpell.darkbolt(caster, x, y, direction, elevation, skill)
    --soundSystem:playSound2D("generic_spell")
    local spell = spawn(party.go.map, "dark_bolt", x, y, direction, elevation)
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    spell.projectile:setAttackPower(10 * (1 + skill*0.2))
    spell.projectile:setIgnoreEntity(party.go)
    spell.projectile:setCastByChampion(caster.ordinal)
    party:endCondition("invisibility")
  end
end

--[[
  Make protection and dodge work on ranged attacks
]]
if KnightMods:_isIntrusiveHookEnabled("modifyProjectileDamage") then
  function ItemComponent:projectileHitEntity(target)
    -- compute damage
    local dmg = self.projectileDamage or math.random(1,3)
    local damageType = self.projectileDamageType or "physical"
    local pierce = self.projectilePierce or 0
    local accuracy = self.projectileAccuracy or 0
    local critChance = self.projectileCritChance or 5

    --print(dmg, accuracy, critChance)

    local thrownByChampion
    if self.thrownByChampion then
      thrownByChampion = party:getChampionByOrdinal(self.thrownByChampion)
    end

    -- crits & fumbles
    local crit = false
    if math.random() < critChance/100 then
      -- crit
      --print("crit!")
      dmg = dmg * 2
      crit = true
    elseif math.random() < 0.1 then
      -- fumble
      --print("fumble!")
      dmg = math.floor(dmg / 2)
    end

    if target.monster then
      local heading = nil
      dmg, heading = KnightMods.modifyProjectileDamage(self, target, dmg, target.monster)

      -- if damage is canceled (parity)
      if dmg == false then
        target:showDamageText("miss", Color.Grey)
        if thrownByChampion then
          thrownByChampion.luck = math.min(thrownByChampion.luck + 3, 15)
        end
        self.go:playSound("impact_blunt")
        return "miss"
      end

      -- evasion
      local target = target.monster
      if not target:hasCondition("sleep") and not target:hasCondition("frozen") then
        local tohit = 60 + accuracy - (target.evasion or 0)
        if thrownByChampion then tohit = tohit + thrownByChampion.luck end
        --print("tohit = "..tohit)
        tohit = math.clamp(tohit, 5, 95)
        if math.random() > tohit / 100 or target.evasion >= 1000 then
          target:showDamageText("miss", Color.Grey)
          if thrownByChampion then
            thrownByChampion.luck = math.min(thrownByChampion.luck + 3, 15)
          end
          self.go:playSound("impact_blunt")
          return "miss"
        end

        if thrownByChampion then thrownByChampion.luck = 0 end
      end

      -- damage reduction
      local protection = math.max(target:getProtection() - pierce, 0)
      if protection > 0 then dmg = computeDamageReduction(dmg, protection) end

      -- hit monster
      local side = "front_left" -- TODO: compute side
      local impactPos = target:findImpactPosition(self.go:getWorldPosition())
      local damageFlags = DamageFlags.Impact
      if crit and not heading then heading = "Critical" end
      if self.thrownByChampion then damageFlags = damageFlags + bit.lshift(DamageFlags.Champion1, self.thrownByChampion-1) end

      if target:callHook("onProjectileHit", objectToProxy(self), dmg, damageType) == false then return end

      target:damage(dmg, side, damageFlags, damageType, impactPos, heading)

      self:callHook("onThrowAttackHitMonster", objectToProxy(target))

      -- stick projectile into monster
      if target:isAlive() then
        local sharp = self:getItemFlag(ItemFlag.SharpProjectile)
        local fragile = self:getItemFlag(ItemFlag.FragileProjectile)

        if self.projectileDamage and sharp and not fragile then
          self.go.map:removeEntity(self.go)
          if self.convertToItemOnImpact then self.convertItem = true end
          target:addItem(self)
        end
      end

      if not target:isAlive() and self:hasTrait("leg_armor") then
        steamContext:unlockAchievement("full_monty")
      end
    elseif target.obstacle then
      dmg = KnightMods.modifyProjectileDamage(self, target, dmg)
      -- hit obstacle
      if dmg ~= false then
        target:sendMessage("onDamage", dmg)
        target.obstacle:playHitEffects()
      end
    elseif target.party then
      -- hit party
      local origTarget = target
      local target = party:getAttackTarget((self.go.facing+2) % 4, math.random(0,1))
      if target then
        dmg = KnightMods.modifyProjectileDamage(self, origTarget, dmg, target)

        -- if damage is canceled (evasion) skip
        if dmg == false then
          soundSystem:playSound2D("impact_blunt")
          return
        end

        if party:isHookRegistered("onProjectileHit") then
          if party:callHook("onProjectileHit", objectToProxy(target), objectToProxy(self), dmg, damageType) == false then
            return
          end
        end

        soundSystem:playSound2D("projectile_hit_party")
        party:wakeUp(true)
        target:damage(dmg, damageType)

        -- HACK: hard code medusa arrow, 20% chance to petrify
        if self.go.arch.name == "petrifying_arrow" then
          local petrified = math.random() < 0.2
          if petrified and target:isAlive() and not target:hasCondition("petrified") then
            target:setCondition("petrified")
          end
        end

        if target:isAlive() then target:playDamageSound() end
      end
    end
  end
end
