ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Moon Essence"
ENT.Category = "Werewolf"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_junk/PopCan01a.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        
        
        self:SetColor(Color(173, 216, 230))
        self:SetMaterial("models/debug/debugwhite")
        
        
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        
        
        timer.Simple(300, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
    
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 173
            dlight.g = 216  
            dlight.b = 230
            dlight.brightness = 1
            dlight.decay = 1000
            dlight.size = 100
            dlight.dietime = CurTime() + 1
        end
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 173
            dlight.g = 216
            dlight.b = 230
            dlight.brightness = math.sin(CurTime() * 3) * 0.5 + 1.5
            dlight.decay = 1000
            dlight.size = 100
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 10) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(10, 30)))
            effectData:SetMagnitude(1)
            effectData:SetScale(0.5)
            util.Effect("balloon_pop", effectData)
        end
    end
    
    if SERVER then
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            local upForce = Vector(0, 0, 100)
            phys:AddVelocity(upForce * FrameTime())
            
            
            local pos = self:GetPos()
            local sine = math.sin(CurTime() * 2) * 10
            self:SetPos(Vector(pos.x, pos.y, pos.z + sine * FrameTime()))
        end
    end
    
    self:NextThink(CurTime())
    return true
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsWerewolf(activator) then
        local amount = math.random(2, 5)
        AddMoonEssence(activator, amount)
        activator:ChatPrint("You have collected " .. amount .. " moon essence!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(1)
            effectData:SetScale(2)
            effectData:SetRadius(50)
            util.Effect("cball_explode", effectData)
            
            self:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav", 50, 150)
        end
        
        self:Remove()
    else
        activator:ChatPrint("Only werewolves can absorb moon essence.")
    end
end

function ENT:OnTakeDamage(dmgInfo)
    
    return
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        
        local pos = self:GetPos()
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos, 30, 30, Color(173, 216, 230, 100))
    end
end