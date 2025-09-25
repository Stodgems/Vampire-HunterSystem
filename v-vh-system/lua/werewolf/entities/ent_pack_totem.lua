ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Pack Totem"
ENT.Category = "Werewolf"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_c17/oildrum001.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false) 
        end
        
        
        self:SetColor(Color(139, 69, 19))
        self:SetMaterial("models/props_wasteland/wood_fence01a")
        
        
        self.TotemPack = "Pack of the Wild" 
        self.TotemRadius = 300 
        
        
        timer.Create("PackTotem_" .. self:EntIndex(), 1, 0, function()
            if IsValid(self) then
                self:ApplyPackBenefits()
            else
                timer.Remove("PackTotem_" .. self:EntIndex())
            end
        end)
    end
end

function ENT:SetTotemPack(packName)
    if SERVER then
        self.TotemPack = packName
        
        
        local packColors = {
            ["Pack of the Wild"] = Color(139, 69, 19), 
            ["Pack of the Moon"] = Color(173, 216, 230), 
            ["Pack of the Hunt"] = Color(34, 139, 34), 
            ["Pack of Shadows"] = Color(64, 64, 64) 
        }
        
        if packColors[packName] then
            self:SetColor(packColors[packName])
        end
    end
end

function ENT:ApplyPackBenefits()
    if not SERVER then return end
    
    local pos = self:GetPos()
    
    for _, ply in ipairs(player.GetAll()) do
        if IsWerewolf(ply) and ply.werewolfPack == self.TotemPack then
            local distance = ply:GetPos():Distance(pos)
            
            if distance <= self.TotemRadius then
                
                local werewolf = werewolves[ply:SteamID()]
                if werewolf then
                    
                    if werewolf.rage > 0 then
                        werewolf.rage = math.min(100, werewolf.rage + 1) 
                    end
                    
                    
                    if ply:Health() < ply:GetMaxHealth() then
                        ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + 2))
                    end
                    
                    
                    if math.random(1, 10) == 1 then
                        ply:ChatPrint("You feel the power of the " .. self.TotemPack .. " totem!")
                    end
                end
            end
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if IsWerewolf(activator) then
        activator:ChatPrint("This totem belongs to the " .. self.TotemPack)
        activator:ChatPrint("Pack members within " .. self.TotemRadius .. " units gain benefits:")
        activator:ChatPrint("- Slow rage regeneration")
        activator:ChatPrint("- Health regeneration")
        
        if activator.werewolfPack == self.TotemPack then
            activator:ChatPrint("You are a member of this pack!")
        else
            activator:ChatPrint("You are not a member of this pack.")
        end
    else
        activator:ChatPrint("This ancient totem radiates with mystical energy...")
    end
end

function ENT:Think()
    if CLIENT then
        
        if math.random(1, 20) == 1 then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos() + Vector(0, 0, 50))
            effectData:SetMagnitude(1)
            effectData:SetScale(1)
            util.Effect("balloon_pop", effectData)
        end
        
        
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos() + Vector(0, 0, 25)
            
            
            local packColors = {
                ["Pack of the Wild"] = {r = 139, g = 69, b = 19},
                ["Pack of the Moon"] = {r = 173, g = 216, b = 230},
                ["Pack of the Hunt"] = {r = 34, g = 139, b = 34},
                ["Pack of Shadows"] = {r = 64, g = 64, b = 64}
            }
            
            local color = packColors[self.TotemPack] or {r = 139, g = 69, b = 19}
            dlight.r = color.r
            dlight.g = color.g
            dlight.b = color.b
            dlight.brightness = math.sin(CurTime() * 2) * 0.5 + 1
            dlight.decay = 1000
            dlight.size = 150
            dlight.dietime = CurTime() + 1
        end
    end
    
    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    if SERVER then
        timer.Remove("PackTotem_" .. self:EntIndex())
    end
end

function ENT:OnTakeDamage(dmgInfo)
    if SERVER then
        
        self:SetHealth(self:Health() - dmgInfo:GetDamage())
        
        if self:Health() <= 0 then
            
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetMagnitude(2)
            effectData:SetScale(3)
            util.Effect("Explosion", effectData)
            
            self:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 100)
            
            
            for _, ply in ipairs(player.GetAll()) do
                if IsWerewolf(ply) and ply.werewolfPack == self.TotemPack then
                    ply:ChatPrint("Your pack's totem has been destroyed!")
                end
            end
            
            self:Remove()
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        
        local pos = self:GetPos()
        local packColors = {
            ["Pack of the Wild"] = Color(139, 69, 19, 50),
            ["Pack of the Moon"] = Color(173, 216, 230, 50),
            ["Pack of the Hunt"] = Color(34, 139, 34, 50),
            ["Pack of Shadows"] = Color(64, 64, 64, 50)
        }
        
        local color = packColors[self.TotemPack] or Color(139, 69, 19, 50)
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos + Vector(0, 0, 25), 60, 60, color)
        
        
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos + Vector(0, 0, 60), ang, 0.1)
            draw.DrawText(self.TotemPack or "Pack Totem", "DermaLarge", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end