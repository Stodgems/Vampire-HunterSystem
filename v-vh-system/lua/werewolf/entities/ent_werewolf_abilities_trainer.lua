ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Werewolf Pack Alpha"
ENT.Category = "Werewolf"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/player/skeleton.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
        
        
        self:SetColor(Color(139, 69, 19))
        self:SetMaterial("models/flesh")
    end
    
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 70)
            dlight.r = 139
            dlight.g = 69
            dlight.b = 19
            dlight.brightness = 1
            dlight.decay = 1000
            dlight.size = 200
            dlight.dietime = CurTime() + 1
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsWerewolf(activator) then
        if SERVER then
            
            net.Start("OpenWerewolfPacksMenu")
            net.Send(activator)
            
            activator:ChatPrint("The Pack Alpha acknowledges you, young wolf.")
            activator:ChatPrint("Available commands: !transform, !wpack")
            activator:ChatPrint("Pack commands: Join a pack to unlock special abilities!")
        end
        
        
        if SERVER then
            self:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 75, 60)
            
            
            activator:ChatPrint("Current moon phase: " .. (CurrentMoonPhase or "First Quarter"))
            
            local werewolf = werewolves[activator:SteamID()]
            if werewolf then
                activator:ChatPrint("Your current rage: " .. werewolf.rage .. "/100")
                activator:ChatPrint("Your tier: " .. werewolf.tier)
                
                if activator.werewolfPack then
                    activator:ChatPrint("Your pack: " .. activator.werewolfPack .. " (" .. activator.werewolfPackRank .. ")")
                else
                    activator:ChatPrint("You are a lone wolf. Consider joining a pack!")
                end
            end
        end
    elseif IsHybrid(activator) then
        if SERVER then
            activator:ChatPrint("The Pack Alpha senses your dual nature...")
            activator:ChatPrint("Your werewolf blood grants you partial access to our wisdom.")
            
            local hybrid = hybrids[activator:SteamID()]
            if hybrid then
                local balanceType = GetHybridBalanceType(hybrid.balance)
                activator:ChatPrint("Your balance: " .. hybrid.balance .. " (" .. balanceType .. ")")
                
                if balanceType == "werewolf" then
                    activator:ChatPrint("Your werewolf nature is strong. You may join our packs.")
                    
                    net.Start("OpenWerewolfPacksMenu")
                    net.Send(activator)
                else
                    activator:ChatPrint("Embrace your werewolf nature more to earn our full trust.")
                end
            end
        end
        
        self:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 14) .. ".wav", 60, 80)
    else
        if SERVER then
            activator:ChatPrint("The ancient werewolf regards you with glowing eyes...")
            activator:ChatPrint("'You lack the blood of the wolf, mortal. Begone.'")
            
            
            activator:SetRunSpeed(activator:GetRunSpeed() * 0.7)
            activator:ChatPrint("The Alpha's presence fills you with primal dread!")
            
            timer.Simple(15, function()
                if IsValid(activator) then
                    activator:SetRunSpeed(250)
                end
            end)
        end
        
        self:EmitSound("npc/zombie/zombie_voice_idle1.wav", 100, 40)
    end
end

function ENT:Think()
    if CLIENT then
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 70)
            dlight.r = 139
            dlight.g = 69
            dlight.b = 19
            dlight.brightness = math.sin(CurTime() * 2) * 0.3 + 1.2
            dlight.decay = 1000
            dlight.size = 200
            dlight.dietime = CurTime() + 1
        end
        
        
        if math.random(1, 20) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(math.random(-30, 30), math.random(-30, 30), math.random(20, 80)))
            effectData:SetMagnitude(1)
            effectData:SetScale(0.8)
            util.Effect("balloon_pop", effectData)
        end
    end
    
    if SERVER then
        
        if math.random(1, 600) == 1 then 
            self:EmitSound("ambient/creatures/town_child_scream1.wav", 60, 70)
            
            
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():Distance(self:GetPos()) < 500 and IsWerewolf(ply) then
                    ply:ChatPrint("The Pack Alpha's howl echoes through your soul...")
                end
            end
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        
        local pos = self:GetPos()
        local time = CurTime()
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        
        
        render.DrawSprite(pos + Vector(0, 0, 35), 80, 80, Color(139, 69, 19, 60))
        
        
        local auraSize = 120 + math.sin(time * 1.5) * 20
        render.DrawSprite(pos + Vector(0, 0, 35), auraSize, auraSize, Color(255, 165, 0, 30))
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 90), ang, 0.15)
            draw.DrawText("Pack Alpha", "DermaLarge", 0, 0, Color(139, 69, 19), TEXT_ALIGN_CENTER)
            draw.DrawText("Werewolf Trainer", "DermaDefault", 0, 30, Color(255, 165, 0), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end