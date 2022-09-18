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


  ---------------
  -- Reskilled --
  ---------------

  -- list of mods to support
  reskilled_whitelist = {"Lost City", "Grimrock Unlimited", "The Guardians"}, -- TODO: look at skills

  -- list of mods to support firearms dealing extra damage per level
  reskilled_firearms_whitelist = {"Lost City", "Grimrock Unlimited"}, -- TODO: look at skills

  -- If true, allows dual wielding throwing weapons. At 5th level, there is no penalty for dual wielding throwing weapons
  reskilled_replace_double_throw = true,

  -- If true, attacking from the back row is delay until 4th level for accuracy
  reskilled_firearm_one_handed = true,


  ----------
  -- Misc --
  ----------

  -- list of mods to reject for more spells
  more_spells_blacklist = {},

  -- list of mods to accept for set bonuses
  set_bonuses_whitelist = {"Lost City", "Grimrock Unlimited", "The Guardians"},

  -- list of mods to accept for general tweaks that do not have a specific option
  tweaks_whitelist = {"Lost City", "Grimrock Unlimited"},
  -- mod blacklist for making the lightning rod use willpower
  tweaks_lightning_rod_willpower_blacklist = {},
  -- brew bullets blacklist
  tweaks_brew_bullets_blacklist = {},

  -- list of mods to accept for general tweaks that do not have a specific option
  tweaks_fix_fire_orb_whitelist = {"Lost City", "Grimrock Unlimited", "The Guardians"},
}
