Ext.Require("Shared/_Init.lua")
Ext.Require("Server/_Init.lua")

local opts = {
	Server = true,
	Client = false,
	WriteableOnServer = true,
	WriteableOnClient = false,
	Persistent = true,
	SyncToClient = false,
	SyncOnWrite = false,
	DontCache = false
}

Ext.Vars.RegisterModVariable(ModuleUUID, "GoonProtection_On", opts)
Ext.Vars.RegisterModVariable(ModuleUUID, "GoonProtection_Off", opts)
