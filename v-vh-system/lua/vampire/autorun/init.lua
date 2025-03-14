-- Initialize the Vampire System addon
AddCSLuaFile("sh_vampire_config.lua")
AddCSLuaFile("sh_vampire_system.lua")
AddCSLuaFile("sv_vampire_commands.lua")
AddCSLuaFile("sh_vampire_utils.lua")
AddCSLuaFile("weapons/weapon_vampire.lua")
AddCSLuaFile("cl_vampire_hud.lua")
AddCSLuaFile("entities/ent_vampire_blood.lua")
AddCSLuaFile("entities/ent_vampire_blood_small.lua")
AddCSLuaFile("entities/ent_vampire_blood_medium.lua")
AddCSLuaFile("entities/ent_vampire_blood_large.lua")
AddCSLuaFile("entities/ent_vampire_cure.lua")
AddCSLuaFile("libs/imgui.lua")
AddCSLuaFile("cl_vampire_covens.lua")

include("sh_vampire_config.lua")
include("sh_vampire_system.lua")
include("sv_vampire_commands.lua")
include("sh_vampire_utils.lua")
include("sv_vampire_covens.lua")

if CLIENT then
    include("cl_vampire_hud.lua")
    include("cl_vampire_covens.lua")
end

if SERVER then
    util.AddNetworkString("UpdateVampireHUD")
    util.AddNetworkString("SyncVampireData")
    util.AddNetworkString("NewTierMessage")
    util.AddNetworkString("SyncVampireCovens")
end

print("Vampire System addon initialized.")
