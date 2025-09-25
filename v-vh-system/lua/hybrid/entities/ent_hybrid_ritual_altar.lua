AddCSLuaFile()

ENT = {}
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Hybrid Ritual Altar"
ENT.Author = "Charlie"
ENT.Category = "Hybrid System"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_c17/concrete_barrier001a.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
        
        
        self:SetColor(Color(128, 0, 128))
        self:SetMaterial("models/props_combine/metal_combinebridge001")
        
        self.ritualCooldowns = {}
        self.activeRituals = {}
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if not IsHybrid(activator) then
        activator:ChatPrint("The ancient altar hums with dual energies, but only hybrids can perform its rituals.")
        return
    end
    
    local steamID = activator:SteamID()
    if self.ritualCooldowns[steamID] and self.ritualCooldowns[steamID] > CurTime() then
        local timeLeft = math.ceil(self.ritualCooldowns[steamID] - CurTime())
        activator:ChatPrint("You must wait " .. timeLeft .. " seconds before performing another ritual.")
        return
    end
    
    
    self:ShowRitualMenu(activator)
end

function ENT:ShowRitualMenu(player)
    if CLIENT then return end
    
    net.Start("HybridRitualMenu")
    net.WriteEntity(self)
    net.Send(player)
end

function ENT:PerformRitual(player, ritualType)
    if not IsValid(player) or not IsHybrid(player) then return end
    
    local steamID = player:SteamID()
    local hybridData = GetHybridData(player)
    if not hybridData then return end
    
    local success = false
    local message = ""
    local cost = 0
    
    if ritualType == "balance_vampire" then
        cost = 50
        if hybridData.dualEssence >= cost then
            success = true
            hybridData.dualEssence = hybridData.dualEssence - cost
            ShiftHybridBalance(player, -25, 0) 
            AddBloodToHybrid(player, 40)
            message = "The ritual of vampiric dominance is complete! Your vampiric nature strengthens."
        else
            message = "You need " .. cost .. " dual essence to perform this ritual."
        end
        
    elseif ritualType == "balance_werewolf" then
        cost = 50
        if hybridData.dualEssence >= cost then
            success = true
            hybridData.dualEssence = hybridData.dualEssence - cost
            ShiftHybridBalance(player, 25, 0) 
            AddRageToHybrid(player, 35)
            message = "The ritual of lupine ascendance is complete! Your werewolf nature dominates."
        else
            message = "You need " .. cost .. " dual essence to perform this ritual."
        end
        
    elseif ritualType == "perfect_balance" then
        cost = 100
        if hybridData.dualEssence >= cost then
            success = true
            hybridData.dualEssence = hybridData.dualEssence - cost
            SetHybridBalance(player, 0) 
            AddBloodToHybrid(player, 25)
            AddRageToHybrid(player, 25)
            message = "The ritual of perfect equilibrium harmonizes your dual nature!"
        else
            message = "You need " .. cost .. " dual essence to perform this ritual."
        end
        
    elseif ritualType == "essence_conversion" then
        cost = 25
        if hybridData.dualEssence >= cost then
            success = true
            hybridData.dualEssence = hybridData.dualEssence - cost
            AddBloodToHybrid(player, 60)
            AddRageToHybrid(player, 60)
            message = "Your dual essence transforms into pure blood and rage!"
        else
            message = "You need " .. cost .. " dual essence to perform this ritual."
        end
    end
    
    player:ChatPrint(message)
    
    if success then
        self.ritualCooldowns[steamID] = CurTime() + 300 
        
        
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetMagnitude(3)
        util.Effect("cball_explode", effectData)
        
        self:EmitSound("ambient/levels/citadel/citadel_hub_ambience1.wav", 80, 100)
        
        
        for i = 1, 8 do
            local angle = (i - 1) * (360 / 8)
            local pos = self:GetPos() + Vector(math.cos(math.rad(angle)) * 60, math.sin(math.rad(angle)) * 60, 30)
            
            local effectData2 = EffectData()
            effectData2:SetOrigin(pos)
            effectData2:SetMagnitude(1)
            util.Effect("balloon_pop", effectData2)
        end
        
        SyncHybridData(player)
    end
end

function ENT:Think()
    if CLIENT then
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 40)
            dlight.r = 128 + math.sin(CurTime() * 2) * 50
            dlight.g = 0
            dlight.b = 128 + math.cos(CurTime() * 1.5) * 50
            dlight.brightness = 1.5
            dlight.decay = 1000
            dlight.size = 150
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 15) == 1 then
            local angle = math.random(0, 360)
            local radius = math.random(40, 80)
            local pos = self:GetPos() + Vector(
                math.cos(math.rad(angle)) * radius,
                math.sin(math.rad(angle)) * radius,
                math.random(20, 60)
            )
            
            local effectData = EffectData()
            effectData:SetOrigin(pos)
            effectData:SetMagnitude(0.5)
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
        render.DrawSprite(pos + Vector(0, 0, 40), 80, 80, Color(128, 0, 128, 100))
        render.DrawSprite(pos + Vector(0, 0, 40), 120, 120, Color(200, 100, 200, 50))
        
        
        for i = 1, 3 do
            local radius = i * 25
            for j = 0, 7 do
                local angle = j * 45 + (CurTime() * 20 * i)
                local circlePos = pos + Vector(
                    math.cos(math.rad(angle)) * radius,
                    math.sin(math.rad(angle)) * radius,
                    5
                )
                render.DrawSprite(circlePos, 8, 8, Color(128, 0, 128, 150))
            end
        end
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 80), ang, 0.15)
            draw.DrawText("Ritual Altar", "DermaLarge", 0, 0, Color(128, 0, 128), TEXT_ALIGN_CENTER)
            draw.DrawText("Channel Dual Energies", "DermaDefault", 0, 25, Color(200, 100, 200), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end


if SERVER then
    util.AddNetworkString("HybridRitualMenu")
    util.AddNetworkString("HybridRitualPerform")
    
    net.Receive("HybridRitualPerform", function(len, ply)
        local altar = net.ReadEntity()
        local ritualType = net.ReadString()
        
        if IsValid(altar) and altar:GetClass() == "ent_hybrid_ritual_altar" then
            altar:PerformRitual(ply, ritualType)
        end
    end)
end

scripted_ents.Register(ENT, "ent_hybrid_ritual_altar")
