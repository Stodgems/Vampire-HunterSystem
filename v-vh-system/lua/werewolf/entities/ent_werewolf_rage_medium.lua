ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Werewolf Rage (Medium)"
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
        
        
        self:SetColor(Color(255, 140, 0))
        self:SetMaterial("models/debug/debugwhite")
        
        
        self:SetModelScale(1.2, 0)
        
        
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
        local rageAmount = math.random(15, 25)
        AddRage(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage from the medium orb!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2)
            effectData:SetScale(2)
            util.Effect("cball_explode", effectData)
            
            
            self:EmitSound("ambient/energy/weld" .. math.random(1, 2) .. ".wav", 60, 140)
            self:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 50, 120)
        end
        
        self:Remove()
    elseif IsHybrid(activator) then
        
        local rageAmount = math.random(8, 15)
        AddRageToHybrid(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage, your werewolf nature grows stronger!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(1.5)
            util.Effect("cball_explode", effectData)
            self:EmitSound("ambient/energy/weld2.wav", 60, 120)
        end
        
        self:Remove()
    else
        activator:ChatPrint("The rage orb thrums with wild energy, but you lack the lycanthropic blood to absorb it.")
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 255
            dlight.g = 140
            dlight.b = 0
            dlight.brightness = math.sin(CurTime() * 5) * 0.4 + 1.2
            dlight.decay = 1000
            dlight.size = 80
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 15) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-15, 15), math.random(-15, 15), math.random(5, 25)))
            effectData:SetMagnitude(1)
            effectData:SetScale(0.3)
            util.Effect("balloon_pop", effectData)
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
        render.DrawSprite(pos, 30, 30, Color(255, 140, 0, 100))
        
        
        render.DrawSprite(pos, 50, 50, Color(255, 165, 0, 40))
    end
end