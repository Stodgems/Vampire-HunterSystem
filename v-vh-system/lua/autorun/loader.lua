if V_VH == nil then
	V_VH = {}
end

function V_VHPrint(msg)
	MsgC(Color( 255,255,255 ),"[",Color( 255,10,255 ),"Vampire & Vampire Hunter",Color( 255,255,255 ),"] ",msg,"\n")
end

if SERVER then
	function V_VH.RecursiveServerLoader(path, blacklist)
		local files, folders = file.Find(path.."*","LUA")
		if files then
			for _, v in pairs(files) do
				if string.StartWith(v, "sh_") then
					include(path .. v)
					AddCSLuaFile(path .. v)
				elseif string.StartWith(v, "sv_") then
					include(path .. v)
				elseif string.StartWith(v, "cl_") then
					AddCSLuaFile(path .. v)
				elseif string.StartWith(v, "weapon_") then
					include(path .. v)
					AddCSLuaFile(path .. v)
				elseif string.StartWith(v, "ent_") then
					include(path .. v)
					AddCSLuaFile(path .. v)
				end
			end
		end
		if folders then
			for _, v in pairs(folders) do
				if blacklist and table.HasValue(blacklist, v) then continue end
				V_VHPrint("Loading subfolder: " .. path .. v)
				V_VH.RecursiveServerLoader(path..v.."/")
			end
		end
	end
else
	function V_VH.RecursiveClientLoader(path, blacklist)
		local files, folders = file.Find(path.."*","LUA")
		if files then
			for _, v in pairs(files) do
				if string.StartWith(v, "sh_") or string.StartWith(v, "cl_") then
					include(path .. v)
				elseif string.StartWith(v, "weapon_") then
					include(path .. v)
				elseif string.StartWith(v, "ent_") then
					include(path .. v)
				end
			end
		end
		if folders then
			for _, v in pairs(folders) do
				if blacklist and table.HasValue(blacklist, v) then continue end
				V_VHPrint("Loading subfolder: " .. path .. v)
				V_VH.RecursiveClientLoader(path..v.."/")
			end
		end
	end
end

include("config/sh_global_config.lua")
AddCSLuaFile("config/sh_global_config.lua")


if SERVER then
	V_VH.RecursiveServerLoader("vampire/")
	V_VH.RecursiveServerLoader("vampire/weapons/")
	V_VH.RecursiveServerLoader("vampire/entities/")
    V_VH.RecursiveServerLoader("hunter/")
    V_VH.RecursiveServerLoader("hunter/weapons/")
    V_VH.RecursiveServerLoader("hunter/entities/")
    V_VH.RecursiveServerLoader("werewolf/")
    V_VH.RecursiveServerLoader("werewolf/weapons/")
    V_VH.RecursiveServerLoader("werewolf/entities/")
    V_VH.RecursiveServerLoader("hybrid/")
    V_VH.RecursiveServerLoader("hybrid/weapons/")
    V_VH.RecursiveServerLoader("hybrid/entities/")
    AddCSLuaFile("cl_admin_menu.lua")
    include("sv_admin_menu.lua")
else
    V_VH.RecursiveClientLoader("vampire/")
    V_VH.RecursiveClientLoader("vampire/weapons/")
    V_VH.RecursiveClientLoader("vampire/entities/")
    V_VH.RecursiveClientLoader("hunter/")
    V_VH.RecursiveClientLoader("hunter/weapons/")
    V_VH.RecursiveClientLoader("hunter/entities/")
    V_VH.RecursiveClientLoader("werewolf/")
    V_VH.RecursiveClientLoader("werewolf/weapons/")
    V_VH.RecursiveClientLoader("werewolf/entities/")
    V_VH.RecursiveClientLoader("hybrid/")
    V_VH.RecursiveClientLoader("hybrid/weapons/")
    V_VH.RecursiveClientLoader("hybrid/entities/")
    include("cl_admin_menu.lua")
end
