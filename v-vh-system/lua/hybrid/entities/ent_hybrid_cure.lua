AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Hybrid Cure"
ENT.Author = "Charlie"
ENT.Category = "Hybrid System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_lab/beakers.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
        
        
        self:SetColor(Color(220, 220, 255))
        self:SetMaterial("models/props_combine/health_charger_glass")
        
        self.cureCharges = math.random(1, 3) 
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if not IsHybrid(activator) then
        activator:ChatPrint("This cure is specifically designed for hybrids. You have no need for it.")
        return
    end
    
    if self.cureCharges <= 0 then
        activator:ChatPrint("The cure has been depleted. Find another source.")
        return
    end
    
    
    activator:ChatPrint("WARNING: Using this cure will permanently remove your hybrid nature!")
    activator:ChatPrint("You will lose all vampire and werewolf abilities and return to human.")
    activator:ChatPrint("Type 'yes' in chat within 30 seconds to confirm the cure.")
    
    
    if not self.confirmations then
        self.confirmations = {}
    end
    
    self.confirmations[activator:SteamID()] = {
        time = CurTime() + 30,
        player = activator
    }
end

function ENT:ConfirmCure(player)
    if not IsValid(player) or not IsHybrid(player) then return end
    
    local steamID = player:SteamID()
    if not self.confirmations or not self.confirmations[steamID] then return end
    
    if self.confirmations[steamID].time < CurTime() then
        player:ChatPrint("The confirmation has expired. Try using the cure again.")
        self.confirmations[steamID] = nil
        return
    end
    
    if self.cureCharges <= 0 then
        player:ChatPrint("The cure has been depleted since your confirmation.")
        return
    end
    
    
    self:CureHybrid(player)
    self.confirmations[steamID] = nil
    self.cureCharges = self.cureCharges - 1
    
    if self.cureCharges <= 0 then
        timer.Simple(3, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function ENT:CureHybrid(player)
    if not IsValid(player) or not IsHybrid(player) then return end
    
    
    RemoveHybrid(player)
    
    
    if player.HybridForm then
        EndHybridTransformation(player)
    end
    
    
    player:SetHealth(100)
    player:SetMaxHealth(100)
    player:SetRunSpeed(200)
    player:SetWalkSpeed(100)
    player:SetJumpPower(200)
    
    
    player:SetColor(Color(255, 255, 255, 255))
    player:SetMaterial("")
    
    
    player:ChatPrint("=====================================")
    player:ChatPrint("The hybrid cure courses through your veins...")
    player:ChatPrint("Your dual nature unravels and fades away.")
    player:ChatPrint("You are now human once more.")
    player:ChatPrint("=====================================")
    
    if SERVER then
        
        local effectData = EffectData()
        effectData:SetOrigin(player:GetPos())
        effectData:SetMagnitude(4)
        util.Effect("cball_explode", effectData)
        
        
        for i = 1, 12 do
            local angle = i * 30
            local pos = player:GetPos() + Vector(
                math.cos(math.rad(angle)) * 40,
                math.sin(math.rad(angle)) * 40,
                math.random(20, 80)
            )
            
            local effectData2 = EffectData()
            effectData2:SetOrigin(pos)
            effectData2:SetMagnitude(1)
            util.Effect("balloon_pop", effectData2)
        end
        
        self:EmitSound("ambient/levels/labs/teleport_mechanism_windup2.wav", 90, 100)
        
        
        print("[Hybrid System] " .. player:Name() .. " (" .. player:SteamID() .. ") has been cured of hybrid status")
    end
end

function ENT:Think()
    
    if self.confirmations then
        for steamID, data in pairs(self.confirmations) do
            if data.time < CurTime() then
                if IsValid(data.player) then
                    data.player:ChatPrint("Cure confirmation expired.")
                end
                self.confirmations[steamID] = nil
            end
        end
    end
    
    if CLIENT then
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 15)
            dlight.r = 220
            dlight.g = 220
            dlight.b = 255
            dlight.brightness = math.sin(CurTime() * 1.5) * 0.3 + 1.0
            dlight.decay = 1000
            dlight.size = 80
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 20) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-10, 10), math.random(-10, 10), math.random(10, 30)))
            effectData:SetMagnitude(0.3)
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
        render.DrawSprite(pos + Vector(0, 0, 15), 30, 30, Color(220, 220, 255, 120))
        render.DrawSprite(pos + Vector(0, 0, 15), 50, 50, Color(255, 255, 255, 80))
        
        
        for i = 1, 3 do
            local time = CurTime() + i
            local height = math.sin(time * 2) * 10 + 30 + (i * 15)
            local crossPos = pos + Vector(0, 0, height)
            
            render.DrawSprite(crossPos, 12, 12, Color(255, 255, 255, 200 - i * 50))
        end
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 60), ang, 0.1)
            draw.DrawText("Hybrid Cure", "DermaDefault", 0, 0, Color(220, 220, 255), TEXT_ALIGN_CENTER)
            draw.DrawText("Return to Humanity", "DermaDefault", 0, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            if self.cureCharges then
                draw.DrawText("Charges: " .. self.cureCharges, "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()
    end
end


if SERVER then
    hook.Add("PlayerSay", "HybridCureConfirmation", function(ply, text, team)
        if string.lower(text) == "yes" then
            
            for _, ent in pairs(ents.FindByClass("ent_hybrid_cure")) do
                if IsValid(ent) and ent.confirmations and ent.confirmations[ply:SteamID()] then
                    ent:ConfirmCure(ply)
                    return ""  
                end
            end
        end
    end)
end

scripted_ents.Register(ENT, "ent_hybrid_cure")
