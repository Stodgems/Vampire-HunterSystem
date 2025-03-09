-- Initialize the Hunter System addon
AddCSLuaFile("sh_hunter_config.lua")
AddCSLuaFile("sh_hunter_utils.lua")
AddCSLuaFile("sv_hunter_commands.lua")
AddCSLuaFile("weapons/weapon_hunter.lua")
AddCSLuaFile("entities/ent_hunter_supply.lua")
AddCSLuaFile("entities/ent_garlic_serum.lua")
AddCSLuaFile("entities/ent_hunter_experience_small.lua")
AddCSLuaFile("entities/ent_hunter_experience_medium.lua")
AddCSLuaFile("entities/ent_hunter_experience_large.lua")
AddCSLuaFile("cl_hunter_hud.lua")

include("sh_hunter_config.lua")
include("sh_hunter_utils.lua")
include("sv_hunter_commands.lua")

if CLIENT then
    include("cl_hunter_hud.lua")
end

if SERVER then
    util.AddNetworkString("UpdateHunterHUD")
    util.AddNetworkString("SyncHunterData")
    util.AddNetworkString("NewHunterTierMessage")
end

print("Hunter System addon initialized.")
