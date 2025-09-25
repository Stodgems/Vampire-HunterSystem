AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dual Essence"
ENT.Author = "Charlie"
ENT.Category = "Hybrid System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

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
        
        
        self:SetColor(Color(128, 0, 128))
        self:SetMaterial("models/debug/debugwhite")
        
        
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        
        
        timer.Simple(600, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
    
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 128
            dlight.g = 0  
            dlight.b = 128
            dlight.brightness = 1
            dlight.decay = 1000
            dlight.size = 120
            dlight.dietime = CurTime() + 1
        end
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            
            
            local time = CurTime()
            local colorShift = math.sin(time * 2) * 0.5 + 0.5
            
            dlight.r = math.floor(128 + colorShift * 127) 
            dlight.g = math.floor(colorShift * 215) 
            dlight.b = math.floor(128 * (1 - colorShift)) 
            
            dlight.brightness = math.sin(time * 3) * 0.5 + 1.5
            dlight.decay = 1000
            dlight.size = 120
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 8) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-25, 25), math.random(-25, 25), math.random(15, 40)))
            effectData:SetMagnitude(1)
            effectData:SetScale(0.7)
            util.Effect("balloon_pop", effectData)
        end
    end
    
    if SERVER then
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            local time = CurTime()
            local upForce = Vector(0, 0, 150)
            phys:AddVelocity(upForce * FrameTime())
            
            
            local pos = self:GetPos()
            local sineX = math.sin(time * 1.5) * 8
            local sineZ = math.sin(time * 2.5) * 12
            self:SetPos(Vector(pos.x + sineX * FrameTime(), pos.y, pos.z + sineZ * FrameTime()))
            
            
            local angles = self:GetAngles()
            self:SetAngles(Angle(angles.p, angles.y + 90 * FrameTime(), angles.r + 45 * FrameTime()))
        end
    end
    
    self:NextThink(CurTime())
    return true
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsHybrid(activator) then
        local amount = math.random(3, 8)
        local hybrid = hybrids[activator:SteamID()]
        hybrid.dualEssence = math.min(HybridConfig.Resources.dualEssence.maxAmount, 
                                     hybrid.dualEssence + amount)
        
        activator:ChatPrint("You have absorbed " .. amount .. " dual essence!")
        
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2)
            effectData:SetScale(3)
            effectData:SetRadius(75)
            util.Effect("cball_explode", effectData)
            
            
            self:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav", 60, 120)
            self:EmitSound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav", 60, 80)
            
            UpdateHybridHUD(activator)
            SaveHybridData()
        end
        
        self:Remove()
    else
        activator:ChatPrint("Only hybrids can absorb dual essence. The energy feels alien to you...")
    end
end

function ENT:OnTakeDamage(dmgInfo)
    
    if SERVER then
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetMagnitude(1)
        util.Effect("balloon_pop", effectData)
        
        self:EmitSound("ambient/levels/citadel/strange_talk3.wav", 40, 150)
    end
    return
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        
        local pos = self:GetPos()
        local time = CurTime()
        
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos, 40, 40, Color(128, 0, 128, 120))
        
        
        render.DrawSprite(pos + Vector(5, 5, 10), 35, 35, Color(255, 215, 0, 100))
        
        
        local ringSize = 60 + math.sin(time * 4) * 10
        render.DrawSprite(pos, ringSize, ringSize, Color(128, 0, 128, 50))
        render.DrawSprite(pos, ringSize - 20, ringSize - 20, Color(255, 215, 0, 30))
    end
end

scripted_ents.Register(ENT, "ent_dual_essence")
