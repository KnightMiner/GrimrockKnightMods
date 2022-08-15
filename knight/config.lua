KnightMods.config = {
  -- for general content changes, require one of these mods to be enabled to load any conditional content
  -- for all mod configs, content is always loaded in the vanilla dungeon
  global_mod_whitelist = {"Lost City", "Grimrock Unlimited", "The Guardians"},


  -----------------
  -- Toorum mode --
  -----------------

  -- general blacklist for toorum mode
  toorum_global_blacklist = {},

  -- blacklist for toorum's resurrection potion buff
  toorum_unresurrectable_blacklist = {},
  -- blacklist for toorum's medusa curse disable
  toorum_medusa_blacklist = {},

  -- comment out traits to disable
  toorum_starting_traits = {
    -- grants +3 to most stats, +2 to willpower
    "km_toorum_stats",
    -- double attack speed
		"km_thunderstruck",

    -- grants an extra skill point every other level
    "km_perspicacious",
    -- using a healing crystal for the first time grants +1 skill point
    --"km_skill_crystals",

    -- resurrection potions work when alive to heal and remove most status effects
	  "km_unresurrectable",
    -- healing crystal shards let you cheat death
		"km_death_cheat",
    -- medusa will no longer petrify, curse instead
    "km_medusa_curse",
  },
}
