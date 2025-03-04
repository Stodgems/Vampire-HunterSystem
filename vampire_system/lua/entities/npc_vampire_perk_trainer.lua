-- Vampire Perk Trainer NPC

AddCSLuaFile()

ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "Vampire Perk Trainer"
ENT.Author = "Your Name"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel("models/props_c17/gravestone002a.mdl")
    --self:SetHullType(HULL_HUMAN)
    --self:SetHullSizeNormal()
    --self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    --self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
    --self:SetUseType(SIMPLE_USE)
    --self:DropToFloor()
end

function ENT:AcceptInput(name, activator, caller)
    if name == "Use" and IsValid(caller) and caller:IsPlayer() then
        net.Start("OpenVampirePerkMenu")
        net.Send(caller)
    end
end
