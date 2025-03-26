-- Initialize the Hunter System addon

AddCSLuaFile("sh_hunter_guilds.lua") -- Ensure this is included first
AddCSLuaFile("sh_hunter_config.lua")
AddCSLuaFile("sh_hunter_utils.lua")
AddCSLuaFile("cl_hunter_guilds.lua") -- Add the Hunter Guilds client logic
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

include("sh_hunter_guilds.lua") -- Ensure this is included first
include("sh_hunter_config.lua")
include("sh_hunter_utils.lua")
include("sv_hunter_commands.lua")
include("sv_hunter_merchant.lua")
include("sv_hunter_guilds.lua") -- Include the Hunter Guilds server logic

if CLIENT then
    include("cl_hunter_hud.lua")
    include("cl_hunter_merchant.lua")
    include("cl_hunter_guilds.lua") -- Include the Hunter Guilds client logic
end

if SERVER then
    util.AddNetworkString("UpdateHunterHUD")
    util.AddNetworkString("SyncHunterData")
    util.AddNetworkString("NewHunterTierMessage")
end

print("Hunter System addon initialized.")
