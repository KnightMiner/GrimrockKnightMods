-- Increases the number of spells available in the mod
KnightMods:_addModule("more_spells", "1.0")

--[[
  Poison storm - cross between meteor storm and poison bolt
--]]
function KnightMods_Spell_poisonStorm(casterOrdinal, spreadX, spreadY, skill)
  if party:isUnderwater() then return end
  local caster = party:getChampionByOrdinal(casterOrdinal)
  if caster:isEquipped("shaman_staff") then skill = skill + 1 end

  local go = party.go
  local spell = spawn(go.map, "poison_bolt_greater", go.x, go.y, go.facing, go.elevation)
  local pos = Spell.getCasterPositionInWorld(caster)

  -- offset position
  local rdx,rdy = getDxDy((go.facing+1)%4)
  pos.x = pos.x - rdx * spreadX
  pos.y = pos.y + spreadY
  pos.z = pos.z + rdy * spreadX

  spell:setWorldPosition(pos)
  spell.projectile:setAttackPower(13 * (1 + skill*0.2))
  spell.projectile:setIgnoreEntity(go)
  spell.projectile:setCastByChampion(caster.ordinal)
end

function BuiltInSpell.knightPoisonStorm(caster, x, y, direction, elevation, skill)
  local poisonCount = 4

  for i=1,poisonCount do
    local spreadX = math.random() * 0.5 * iff((i % 2) == 0, 1, -1)
    local spreadY = -(i / poisonCount - 0.5)
    messageSystem:delayedFunctionCall("KnightMods_Spell_poisonStorm", (i-1) * 0.15, caster.ordinal, spreadX, spreadY, skill)
  end

  party:endCondition("invisibility")
end

--[[
   Wind strike - causes knockback to enemies
--]]
function BuiltInSpell.knightWindforce(caster, x, y, direction, elevation, skill)
  tx,ty = Spell.getBurstTargetTile(x, y, direction)

  -- if targeting the party, reverse direction
  local dir = party.go.facing
  if tx ~= x or ty ~= y then
    dir = (dir + 2) % 4
  end
  local push = spawn(party.go.map, "km_airburst", tx, ty, dir, party.go.elevation)
  push.tiledamager:setAttackPower(math.random(1,5))
  push.tiledamager:setCastByChampion(caster.ordinal)

  party:endCondition("invisibility")
end

-- called when airburst hits the party
local function pushChampion(self, champ)
  party.party:knockback((self.go.facing + 2) % 4)
  if not party.party:isMoving() then
    for i=3,4 do
      local champion = party.party:getChampion(i)
      if champion:isAlive() then
        champion:damage(math.random(1,5), "physical")
        champion:playDamageSound()
      end
    end
  end
end

-- called when airburst hits a monster
local function pushMonster(self, monster)
  monster:knockback((self.go.facing + 2) % 4)
  local skill = 2
  local casterOrdinal = self:getCastByChampion()
  if casterOrdinal ~= nil then
    local caster = party.party:getChampion(casterOrdinal)
    skill = caster:getSkillLevel("air_magic")
  end
  if math.random(0, 8) < skill then
    monster:setCondition("stunned")
    local cond = monster.go:getComponent("stunned")
    if cond and cond.setCausedByChampion and casterOrdinal then
      cond:setCausedByChampion(casterOrdinal)
    end
  end
end

--[[
  Meteor strike, attacks the 9 tiles around the party
--]]
function BuiltInSpell.knightMagmaStrike(caster, x, y, direction, elevation, skill)
  for dx=-1,1 do
    for dy=-1,1 do
      local fire = spawn(party.go.map, "wall_fire", x+dx, y+dy, 0, party.go.elevation)
      if dx == 0 and dy == 0 then
        fire.tiledamager:disable()
      else
        fire.tiledamager:setAttackPower(5 * (1 + skill*0.2))
        fire.tiledamager:setCastByChampion(caster.ordinal)
      end
    end
  end

  party:endCondition("invisibility")
end

--[[
  Leech, fast poison attack that steals health
--]]
function BuiltInSpell.knightLeech(caster, x, y, direction, elevation, skill)
  if caster:isEquipped("shaman_staff") then skill = skill + 1 end
  x,y = Spell.getBurstTargetTile(x, y, direction)
  local power = 18 * (1 + skill*0.2)
  local spell = spawn(party.go.map, "km_leechburst", x, y, direction, elevation)
  spell.tiledamager:setAttackPower(power)
  spell.tiledamager:setCastByChampion(caster.ordinal)
  --if skill == 1 then spell.tiledamager:setDamageFlags(DamageFlags.NoLingeringEffects) end
  party:endCondition("invisibility")
end

local function leechMonster(self, monster)
  local casterOrdinal = self:getCastByChampion()
  if casterOrdinal ~= nil then
    local caster = party.party:getChampion(casterOrdinal)
    if monster:hasTrait("undead") then
      -- draining undeads is not wise
      monster:showDamageText("Backlash", "FF0000")
      caster:damage(self:getAttackPower()*0.75, "physical")
      return false
    elseif monster:hasTrait("elemental") or monster:hasTrait("construct") then
      -- elementals are constructs are immune to leech
      monster:showDamageText("Immune")
      return false
    else
      caster:regainHealth(self:getAttackPower()*0.75)
    end
  end
end

--[[
  Ice Storm - Triple ice shards
--]]
function KnightMods_Spell_blizzardSpikes(casterOrdinal, skill)
  if party:isUnderwater() then return end
  local caster = party:getChampionByOrdinal(casterOrdinal)

  local go = party.go
  local x,y = Spell.getBurstTargetTile(go.x, go.y, go.facing)
  local spell = spawn(go.map, "km_freezing_ice_shards", x, y, go.facing, go.elevation)
  local pos = Spell.getCasterPositionInWorld(caster)

  spell.tiledamager:setAttackPower(12 * (1 + skill*0.2))
  spell.iceshards:setRange(skill)
  spell.tiledamager:setCastByChampion(casterOrdinal)
end

function BuiltInSpell.knightBlizzardSpikes(caster, x, y, direction, elevation, skill)
  local iceCount = 3

  for i=1,iceCount do
    local spreadX = math.random() * 0.5 * iff((i % 2) == 0, 1, -1)
    local spreadY = -(i / iceCount - 0.5)
    messageSystem:delayedFunctionCall("KnightMods_Spell_blizzardSpikes", (i-1) * 0.5, caster.ordinal, skill)
  end

  party:endCondition("invisibility")
end

--[[
  Defines various non-spell objects
]]
local function defineMisc()
  defineParticleSystem{
    name = "km_leechburst",
    emitters = {
      -- fog
      {
        spawnBurst = true,
        maxParticles = 30,
        emissionRate = 15,
        emissionTime = 0,
        boxMin = {-1.2, -1.25,-1.2},
        boxMax = { 1.2,  0.5, 1.2},
        sprayAngle = {0,360},
        velocity = {0.1,0.7},
        objectSpace = true,
        texture = "assets/textures/particles/smoke_01.tga",
        lifetime = {2,2},
        color0 = {0.29, 0.29, 0.145},
        opacity = 0.8,
        fadeIn = 0.2,
        fadeOut = 1,
        size = {1.4, 1.75},
        gravity = {0,0,0},
        airResistance = 0.1,
        rotationSpeed = 0.1,
        blendMode = "Translucent",
      },
      {
        spawnBurst = true,
        maxParticles = 1,
        boxMin = {0,-0.3,0},
        boxMax = {0,-0.3,0},
        sprayAngle = {0,360},
        velocity = {0.01,0.01},
        objectSpace = true,
        texture = "assets/textures/particles/skull.tga",
        lifetime = {2,2},
        color0 = {0.25, 0.25, 0.05},
        opacity = 0.3,
        fadeIn = 0.5,
        fadeOut = 1,
        size = {2.5, 2.5},
        gravity = {0,0,0},
        airResistance = 0.1,
        rotationSpeed = 0,
        blendMode = "Translucent",
        randomInitialRotation = false,
        depthBias = 1,
      },
    }
  }

  defineObject{
    name = "km_leechburst",
    baseObject = "base_spell",
    components = {
      {
        class = "Particle",
        particleSystem = "km_leechburst",
        offset = vec(0, 1.5, 0),
        destroyObject = true,
      },
      {
        class = "Light",
        offset = vec(0, 1.5, 0),
        color = vec(0.5, 0.5, 0.25),
        brightness = 7,
        range = 5,
        fadeOut = 13,
        disableSelf = true,
      },
      {
        class = "TileDamager",
        attackPower = 20,
        damageType = "poison",
        sound = "poison_cloud",
        screenEffect = "poison_cloud_medium",
        onHitMonster = leechMonster
      },
    },
  }

  defineObject{
    name = "km_airburst",
    baseObject = "base_spell",
    components = {
      {
        class = "Particle",
        particleSystem = "teleport_screen",
        offset = vec(0, 1.3, 0),
        destroyObject = true,
      },
      {
        class = "TileDamager",
        attackPower = 5,
        damageType = "physical",
        sound = "wizard_push",
        screenEffect = "teleport_screen",
        onHitChampion = pushChampion,
        onHitMonster = pushMonster
      },
    },
  }
  -- needed so my lost cities save is not broken
  local mod = modSystem:getCurrentMod()
  if mod and mod.name == "Lost City" then
    defineObject{
      name = "airburst",
      baseObject = "km_airburst"
    }
  end

  defineObject{
    name = "km_freezing_ice_shards",
    baseObject = "base_spell",
    components = {
      {
        class = "Model",
        model = "assets/models/effects/ice_shards.fbx",
      },
      {
        class = "Animation",
        animations = {
          shards = "assets/animations/effects/ice_shards.fbx",
        },
        playOnInit = "shards",
      },
      {
        class = "Particle",
        particleSystem = "ice_shards",
        offset = vec(0, 1, 0),
      },
      {
        class = "Light",
        offset = vec(0, 1.35, 0),
        color = vec(0.25, 0.5, 1),
        brightness = 40,
        range = 4,
        fadeOut = 0.5,
        disableSelf = true,
      },
      {
        class = "TileDamager",
        attackPower = 20,
        damageType = "cold",
        damageFlags = DamageFlags.DamageSourceIceShards,
        sound = "ice_shard",
        cameraShake = true,
        repeatCount = 2,
        repeatDelay = 0.15,
        onHitMonster = function(self, monster)
          -- prevent ice shards from hitting the same monster twice
          self.go.iceshards:grantTemporaryImmunity(monster.go, 0.5)
          -- always level 5, so hardcode the chances
          -- smaller chance as it hits the same monster multiple times in one cast
          if math.random() < 0.2 then
            monster:setCondition("frozen", 7.5)
          end
        end,
        onHitChampion = function(self, champion)
          -- prevent ice shards from hitting the party twice
          self.go.iceshards:grantTemporaryImmunity(party, 0.5)
        end,
      },
      {
        class = "IceShards",
        delay = 0.3,
      },
    },
  }
end

--[[
  Called to add all the spells to the game
--]]
local function defineSpells()
  -- 123
  -- 456
  -- 789
  defineSpell{
    name = "km_poison_storm",
    uiName = "Poison Storm",
    gesture = 78563,
    manaCost = 60,
    onCast = "knightPoisonStorm",
    skill = "earth_magic",
    requirements = { "earth_magic", 4, "concentration", 2 },
    icon = KnightMods.skillIcons.poison_storm,
    iconAtlas = KnightMods.skillIconAtlas,
    spellIcon = KnightMods.spellIcons.poison_storm,
    spellIconAtlas = KnightMods.spellIconAtlas,
    description = "Unleases a devistating storm of venom on your foes.",
  }

  defineSpell{
    name = "km_windforce",
    uiName = "Windforce",
    gesture = 365,
    manaCost = 30,
    onCast = "knightWindforce",
    skill = "air_magic",
    requirements = { "air_magic", 2, "concentration", 1 },
    icon = KnightMods.skillIcons.windforce,
    iconAtlas = KnightMods.skillIconAtlas,
    spellIcon = KnightMods.spellIcons.windforce,
    spellIconAtlas = KnightMods.spellIconAtlas,
    description = "A powerful gust of wind that pushes enemies away.",
  }

  defineSpell{
    name = "km_magma_strike",
    uiName = "Magma Strike",
    gesture = 1478,
    manaCost = 35,
    onCast = "knightMagmaStrike",
    skill = "fire_magic",
    requirements = { "fire_magic", 2, "earth_magic", 1 },
    icon = KnightMods.skillIcons.magma_strike,
    iconAtlas = KnightMods.skillIconAtlas,
    spellIcon = KnightMods.spellIcons.magma_strike,
    spellIconAtlas = KnightMods.spellIconAtlas,
    description = "Strike the ground causing fissures of fire around",
  }

  defineSpell{
    name = "km_leechburst",
    uiName = "Leechburst",
    gesture = 7852,
    manaCost = 45,
    onCast = "knightLeech",
    skill = "earth_magic",
    requirements = { "earth_magic", 3, "fire_magic", 1 },
    icon = KnightMods.skillIcons.leechburst,
    iconAtlas = KnightMods.skillIconAtlas,
    spellIcon = KnightMods.spellIcons.leechburst,
    spellIconAtlas = KnightMods.spellIconAtlas,
    description = "Steal the very life force from a target directly in front of you.",
  }

  defineSpell{
    name = "km_blizzard_spikes",
    uiName = "Blizzard Spikes",
    gesture = 47896,
    manaCost = 60,
    onCast = "knightBlizzardSpikes",
    skill = "water_magic",
    requirements = { "water_magic", 5, "earth_magic", 2 },
    icon = KnightMods.skillIcons.blizzard_spikes,
    iconAtlas = KnightMods.skillIconAtlas,
    spellIcon = KnightMods.spellIcons.blizzard_spikes,
    spellIconAtlas = KnightMods.spellIconAtlas,
    description = "Unleash a multitude of deathly sharp ice spikes, hitting your opponents in a line and possibly freezing them.",
  }
end

-- Load in the spells on load file and new game
local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
  oldDungeonLoadInitFile(self)

  if KnightMods:isEnabledInMod("more_spells_blacklist", false) then
    defineMisc()
    defineSpells()
  end
end
