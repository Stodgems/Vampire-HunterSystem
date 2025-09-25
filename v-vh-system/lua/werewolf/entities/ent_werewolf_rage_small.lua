ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Werewolf Rage (Small)"
ENT.Category = "Werewolf"

ENT.Spawnable = true
ENT.AdminOnly = true

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
        
        
        self:SetColor(Color(255, 165, 0))
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
    
    if IsWerewolf(activator) then
        local rageAmount = math.random(5, 10)
        AddRage(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage from the small orb!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(1)
            effectData:SetScale(1)
            util.Effect("cball_explode", effectData)
            
            self:EmitSound("ambient/energy/weld" .. math.random(1, 2) .. ".wav", 50, 150)
        end
        
        self:Remove()
    elseif IsHybrid(activator) then
        
        local rageAmount = math.random(3, 6)
        AddRageToHybrid(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage, your werewolf nature stirs!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            util.Effect("cball_explode", effectData)
            self:EmitSound("ambient/energy/weld1.wav", 50, 130)
        end
        
        self:Remove()
    else
        activator:ChatPrint("The rage orb pulses with primal energy, but you cannot harness it.")
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 255
            dlight.g = 165
            dlight.b = 0
            dlight.brightness = math.sin(CurTime() * 4) * 0.3 + 0.8
            dlight.decay = 1000
            dlight.size = 60
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
        render.DrawSprite(pos, 20, 20, Color(255, 165, 0, 80))
    end
end