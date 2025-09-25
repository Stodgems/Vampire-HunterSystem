AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vampire Balance Crystal"
ENT.Author = "Charlie"
ENT.Category = "Hybrid System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_lab/crystal.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
        
        
        self:SetColor(Color(200, 0, 0))
        self:SetMaterial("models/debug/debugwhite")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsHybrid(activator) then
        local balanceShift = math.random(-15, -10) 
        ShiftHybridBalance(activator, balanceShift, 0)
        
        local bloodGain = math.random(20, 35)
        AddBloodToHybrid(activator, bloodGain)
        
        activator:ChatPrint("The vampire crystal awakens your bloodthirst!")
        activator:ChatPrint("Gained " .. bloodGain .. " blood. Balance shifted toward vampire.")
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2)
            util.Effect("cball_explode", effectData)
            self:EmitSound("ambient/levels/citadel/strange_talk9.wav", 70, 120)
            
            
            activator:SetHealth(math.min(activator:GetMaxHealth(), activator:Health() + 25))
        end
        
        
        if not self.usesLeft then
            self.usesLeft = math.random(3, 5)
        end
        
        self.usesLeft = self.usesLeft - 1
        if self.usesLeft <= 0 then
            activator:ChatPrint("The crystal crumbles, its power spent...")
            timer.Simple(2, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
        end
    else
        activator:ChatPrint("The vampire crystal pulses with dark energy, but you cannot harness its power.")
    end
end

function ENT:Think()
    if CLIENT then
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 20)
            dlight.r = 200
            dlight.g = 0
            dlight.b = 0
            dlight.brightness = math.sin(CurTime() * 2) * 0.4 + 1.0
            dlight.decay = 1000
            dlight.size = 100
            dlight.dietime = CurTime() + 1
        end
        
        if math.random(1, 25) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-15, 15), math.random(-15, 15), math.random(10, 40)))
            effectData:SetMagnitude(1)
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
        render.DrawSprite(pos + Vector(0, 0, 20), 40, 40, Color(200, 0, 0, 100))
        render.DrawSprite(pos + Vector(0, 0, 20), 60, 60, Color(255, 0, 0, 50))
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 60), ang, 0.1)
            draw.DrawText("Vampire Crystal", "DermaDefault", 0, 0, Color(200, 0, 0), TEXT_ALIGN_CENTER)
            draw.DrawText("Embrace the Darkness", "DermaDefault", 0, 15, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

scripted_ents.Register(ENT, "ent_hybrid_vampire_crystal")
