AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Small Hybrid Essence"
ENT.Author = "Charlie"
ENT.Category = "Hybrid System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Items/battery.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        
        
        self:SetColor(Color(128, 0, 128))
        self:SetMaterial("models/debug/debugwhite")
        
        
        self:SetModelScale(0.8, 0)
        
        timer.Simple(300, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsHybrid(activator) then
        local essenceAmount = math.random(2, 5)
        local hybrid = hybrids[activator:SteamID()]
        hybrid.dualEssence = math.min(HybridConfig.Resources.dualEssence.maxAmount, 
                                     hybrid.dualEssence + essenceAmount)
        
        activator:ChatPrint("You absorbed " .. essenceAmount .. " dual essence!")
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            util.Effect("cball_explode", effectData)
            self:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav", 50, 140)
            UpdateHybridHUD(activator)
        end
        
        self:Remove()
    else
        activator:ChatPrint("The dual essence orb radiates alien energy that you cannot comprehend.")
    end
end

function ENT:Think()
    if CLIENT then
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            local time = CurTime()
            local colorShift = math.sin(time * 3) * 0.5 + 0.5
            dlight.r = math.floor(128 + colorShift * 127)
            dlight.g = math.floor(colorShift * 215)
            dlight.b = math.floor(128 * (1 - colorShift))
            dlight.brightness = 0.8
            dlight.decay = 1000
            dlight.size = 50
            dlight.dietime = CurTime() + 1
        end
    end
    
    self:NextThink(CurTime())
    return true
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        local pos = self:GetPos()
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos, 15, 15, Color(128, 0, 128, 80))
        render.DrawSprite(pos + Vector(2, 2, 5), 12, 12, Color(255, 215, 0, 60))
    end
end

scripted_ents.Register(ENT, "ent_hybrid_essence_small")
