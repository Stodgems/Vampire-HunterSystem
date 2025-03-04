-- Vampire Perk Trainer Tool

TOOL.Category = "Vampire System"
TOOL.Name = "Vampire Perk Trainer"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("tool.vampire_perk_trainer.name", "Vampire Perk Trainer")
    language.Add("tool.vampire_perk_trainer.desc", "Spawn a Vampire Perk Trainer")
    language.Add("tool.vampire_perk_trainer.0", "Left-click to spawn a Vampire Perk Trainer. Right-click to save the location.")
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    local pos = trace.HitPos + trace.HitNormal * 16

    local ent = ents.Create("npc_vampire_perk_trainer")
    ent:SetPos(pos)
    ent:Spawn()

    undo.Create("Vampire Perk Trainer")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    local pos = trace.HitPos + trace.HitNormal * 16
    local map = game.GetMap()

    sql.Query("CREATE TABLE IF NOT EXISTS vampire_perk_trainer_locations (map TEXT, pos TEXT)")
    sql.Query(string.format("INSERT INTO vampire_perk_trainer_locations (map, pos) VALUES ('%s', '%s')", map, util.TableToJSON(pos)))

    ply:ChatPrint("Vampire Perk Trainer location saved.")

    return true
end
