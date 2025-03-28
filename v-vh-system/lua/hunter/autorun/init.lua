-- Initialize the Hunter System addon

AddCSLuaFile("sh_hunter_guilds.lua")
AddCSLuaFile("sh_hunter_config.lua")
AddCSLuaFile("sh_hunter_utils.lua")
AddCSLuaFile("cl_hunter_guilds.lua")
AddCSLuaFile("sv_hunter_commands.lua")
AddCSLuaFile("weapons/weapon_stake.lua")
AddCSLuaFile("weapons/weapon_hunter_sword.lua")
AddCSLuaFile("entities/ent_hunter_supply.lua")
AddCSLuaFile("entities/ent_garlic_serum.lua")
AddCSLuaFile("entities/ent_hunter_experience_small.lua")
AddCSLuaFile("entities/ent_hunter_experience_medium.lua")
AddCSLuaFile("entities/ent_hunter_experience_large.lua")
AddCSLuaFile("entities/ent_hunter_merchant.lua")
AddCSLuaFile("cl_hunter_hud.lua")
AddCSLuaFile("cl_hunter_merchant.lua")

include("sh_hunter_guilds.lua")
include("sh_hunter_config.lua")
include("sh_hunter_utils.lua")
include("sv_hunter_commands.lua")
include("sv_hunter_merchant.lua")
include("sv_hunter_guilds.lua")

if CLIENT then
    include("cl_hunter_hud.lua")
    include("cl_hunter_merchant.lua")
    include("cl_hunter_guilds.lua")
end

if SERVER then
    util.AddNetworkString("UpdateHunterHUD")
    util.AddNetworkString("SyncHunterData")
    util.AddNetworkString("NewHunterTierMessage")
end

print("Hunter System addon initialized.")
