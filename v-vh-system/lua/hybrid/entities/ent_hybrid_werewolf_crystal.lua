AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Werewolf Balance Crystal"
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
        
        
        self:SetColor(Color(255, 165, 0))
        self:SetMaterial("models/debug/debugwhite")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsHybrid(activator) then
        local balanceShift = math.random(10, 15) 
        ShiftHybridBalance(activator, balanceShift, 0)
        
        local rageGain = math.random(15, 30)
        AddRageToHybrid(activator, rageGain)
        
        activator:ChatPrint("The werewolf crystal stirs your primal fury!")
        activator:ChatPrint("Gained " .. rageGain .. " rage. Balance shifted toward werewolf.")
        
        if SERVER then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2)
            util.Effect("cball_explode", effectData)
            self:EmitSound("ambient/creatures/town_child_scream1.wav", 70, 80)
            
            
            activator:SetRunSpeed(math.min(600, activator:GetRunSpeed() + 50))
            activator:SetWalkSpeed(math.min(300, activator:GetWalkSpeed() + 25))
            
            timer.Simple(30, function()
                if IsValid(activator) then
                    activator:SetRunSpeed(activator:GetRunSpeed() - 50)
                    activator:SetWalkSpeed(activator:GetWalkSpeed() - 25)
                end
            end)
        end
        
        
        if not self.usesLeft then
            self.usesLeft = math.random(3, 5)
        end
        
        self.usesLeft = self.usesLeft - 1
        if self.usesLeft <= 0 then
            activator:ChatPrint("The crystal howls and shatters, its wild energy released...")
            timer.Simple(2, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
        end
    else
        activator:ChatPrint("The werewolf crystal emanates primal energy, but you cannot tap into its power.")
    end
end

function ENT:Think()
    if CLIENT then
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 20)
            dlight.r = 255
            dlight.g = 165
            dlight.b = 0
            dlight.brightness = math.sin(CurTime() * 3) * 0.5 + 1.2
            dlight.decay = 1000
            dlight.size = 120
            dlight.dietime = CurTime() + 1
        end
        
        if math.random(1, 30) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(15, 45)))
            effectData:SetMagnitude(0.8)
            util.Effect("sparks", effectData)
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
        render.DrawSprite(pos + Vector(0, 0, 20), 45, 45, Color(255, 165, 0, 120))
        render.DrawSprite(pos + Vector(0, 0, 20), 65, 65, Color(255, 200, 100, 60))
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 60), ang, 0.1)
            draw.DrawText("Werewolf Crystal", "DermaDefault", 0, 0, Color(255, 165, 0), TEXT_ALIGN_CENTER)
            draw.DrawText("Unleash the Beast", "DermaDefault", 0, 15, Color(255, 200, 100), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

scripted_ents.Register(ENT, "ent_hybrid_werewolf_crystal")
