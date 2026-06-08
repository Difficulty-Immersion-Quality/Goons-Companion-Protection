local U      = Ext.Require("Shared/Utility.lua")
local Events = Ext.Require("Shared/Events.lua")

local companionPassives = {
	["91b6b200-7d00-4d62-8dc9-99e8339dfa1a"] = { -- S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a
		passive  = "Goon_Buff_Companion_Temporary_Jaheira",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["0de603c5-42e2-4811-9dad-f652de080eba"] = { -- S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba
		passive  = "Goon_Buff_Companion_Temporary_Minsc",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["ad9af97d-75da-406a-ae13-7071c563f604"] = { -- S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604
		passive  = "Goon_Buff_Companion_Temporary_Gale",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["58a69333-40bf-8358-1d17-fff240d7fb12"] = { -- S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12
		passive  = "Goon_Buff_Companion_Temporary_Laezel",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["c774d764-4a17-48dc-b470-32ace9ce447d"] = { -- S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d
		passive  = "Goon_Buff_Companion_Temporary_Wyll",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["3ed74f06-3c60-42dc-83f6-f034cb47c679"] = { -- S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679
		passive  = "Goon_Buff_Companion_Temporary_ShadowHeart",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["2c76687d-93a2-477b-8b18-8a14b549304c"] = { -- S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c
		passive  = "Goon_Buff_Companion_Temporary_Karlach",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["c7c13742-bacd-460a-8f65-f864fe41f255"] = { -- S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255
		passive  = "Goon_Buff_Companion_Temporary_Astarion",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["25721313-0c15-4935-8176-9f134385451b"] = { -- S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b
		passive  = "Goon_Buff_Companion_Temporary_Minthara",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
	["7628bc0e-52b8-42a7-856a-13a6fd413323"] = { -- S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323
		passive  = "Goon_Buff_Companion_Temporary_Halsin",
		statuses = {
			"GOON_BUFF_COMPANION_TEMPHP_30"
			-- "GOON_BUFF_COMPANION_DAMAGE_REDUCTION_3",
			-- "GOON_BUFF_COMPANION_ADVANTAGE_ALL_SAVING_THROWS"
		},
		boosts = {}
	},
}

local function GetVars(key)
	local vars = Ext.Vars.GetModVariables(ModuleUUID)
	vars[key] = vars[key] or {}
	return vars[key]
end

local function GetState(charID)
	return GetVars("GoonProtection_On"), GetVars("GoonProtection_Off"), companionPassives[charID]
end

local function applyBuffs(charID)
	charID = U.Guid(charID)
	local applied, blocked, config = GetState(charID)
	if applied[charID] or blocked[charID] then return end
	if not config then return end

	if Osi.IsPartyMember(charID, 0) == 0 then
		Osi.AddPassive(charID, config.passive)
		GCPDebug("Applied passive to %s.", U.GetDisplayName(charID))
		for _, status in ipairs(config.statuses) do
			Osi.ApplyStatus(charID, status, -1, 1, charID)
			GCPDebug("Applied status %s to %s.", status, U.GetDisplayName(charID))
		end
		applied[charID] = true
	end
end

local function removeBuffs(charID)
	charID = U.Guid(charID)
	local applied, blocked, config = GetState(charID)

	if not config then
		GCPDebug("No config found for %s.", U.GetDisplayName(charID))
		return
	end

	Osi.RemovePassive(charID, config.passive)
	GCPDebug("Removed passive from %s.", U.GetDisplayName(charID))
	for _, status in ipairs(config.statuses) do
		Osi.RemoveStatus(charID, status)
		GCPDebug("Removed status %s from %s.", status, U.GetDisplayName(charID))
	end

	blocked[charID] = true
	applied[charID] = nil
	GCPDebug("Marked %s as recruited — no future buffs will be applied.", U.GetDisplayName(charID))
end

Events.EnteredCombat.Subscribe(function(p)
	applyBuffs(p.CharacterRaw)
end)

Events.LevelGameplayStarted.Subscribe(function(p)
	if Osi.IsCharacterCreationLevel(p.LevelName) == 1 then
		GCPDebug("Skipping buff application during character creation.")
		return
	end
	for charID in pairs(companionPassives) do
		applyBuffs(charID)
	end
end)

Events.RegisterAsCompanion.Subscribe(function(p)
	removeBuffs(p.CharacterRaw)
end)

Events.UnregisterAsCompanion.Subscribe(function(p)
	local charID     = U.Guid(p.CharacterRaw)
	local applied, blocked = GetState(charID)
	blocked[charID] = nil
	applied[charID] = nil
	GCPDebug("Unregistered %s — now eligible for buffs again.", U.GetDisplayName(charID))
	applyBuffs(charID)
end)
