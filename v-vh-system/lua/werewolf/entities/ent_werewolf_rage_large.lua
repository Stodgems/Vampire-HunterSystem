ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Werewolf Rage (Large)"
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
        
        
        self:SetColor(Color(255, 69, 0))
        self:SetMaterial("models/debug/debugwhite")
        
        
        self:SetModelScale(1.6, 0)
        
        
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
        local rageAmount = math.random(30, 45)
        AddRage(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage from the large orb! Your fury knows no bounds!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(3)
            effectData:SetScale(3)
            effectData:SetRadius(100)
            util.Effect("Explosion", effectData)
            
            
            self:EmitSound("ambient/energy/weld" .. math.random(1, 2) .. ".wav", 80, 130)
            self:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 70, 100)
            self:EmitSound("ambient/creatures/town_child_scream1.wav", 60, 80)
            
            
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) < 200 then
                    ply:ConCommand("shake 5 3 1")
                end
            end
        end
        
        self:Remove()
    elseif IsHybrid(activator) then
        
        local rageAmount = math.random(20, 30)
        AddRageToHybrid(activator, rageAmount)
        activator:ChatPrint("You absorbed " .. rageAmount .. " rage! Your werewolf nature roars with power!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2.5)
            effectData:SetScale(2.5)
            util.Effect("Explosion", effectData)
            self:EmitSound("ambient/energy/weld1.wav", 80, 110)
            self:EmitSound("ambient/creatures/town_child_scream1.wav", 50, 90)
        end
        
        self:Remove()
    else
        activator:ChatPrint("The massive rage orb radiates overwhelming primal fury. You dare not touch it.")
        
        if SERVER then
            
            activator:SetRunSpeed(activator:GetRunSpeed() * 0.8)
            activator:ChatPrint("The overwhelming rage makes you feel sluggish with fear!")
            
            timer.Simple(10, function()
                if IsValid(activator) then
                    activator:SetRunSpeed(250) 
                end
            end)
        end
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 255
            dlight.g = 69
            dlight.b = 0
            dlight.brightness = math.sin(CurTime() * 6) * 0.6 + 1.8
            dlight.decay = 1000
            dlight.size = 120
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 8) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(10, 35)))
            effectData:SetMagnitude(2)
            effectData:SetScale(0.5)
            util.Effect("balloon_pop", effectData)
        end
        
        
        if math.random(1, 30) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetNormal(VectorRand())
            effectData:SetMagnitude(1)
            util.Effect("cball_bounce", effectData)
        end
    end
    
    if SERVER then
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            local upForce = Vector(0, 0, 200)
            phys:AddVelocity(upForce * FrameTime())
        end
    end
    
    self:NextThink(CurTime())
    return true
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        
        local pos = self:GetPos()
        local time = CurTime()
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        
        
        render.DrawSprite(pos, 40, 40, Color(255, 69, 0, 120))
        
        
        local ringSize = 70 + math.sin(time * 4) * 15
        render.DrawSprite(pos, ringSize, ringSize, Color(255, 140, 0, 60))
        
        
        render.DrawSprite(pos, 100, 100, Color(255, 165, 0, 30))
        
        
        if math.random(1, 5) == 1 then
            local sparkPos = pos + VectorRand() * 30
            render.DrawSprite(sparkPos, 5, 5, Color(255, 255, 255, 200))
        end
    end
end