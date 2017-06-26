-- require "UI/UIManager"
-- require "Network/MessageManager"
-- require "Logic/EntityManager"
-- require "Common/basic/functions"

require "Model/Schemes"
require "Common/basic/LuaObject"
require "UI/LuaUIUtil"
GRunOnClient = true
require "Common/basic/functions"

local function _list_table(tb, table_list, level)
	local ret = ""
	local indent = string.rep(" ", level*4)
	
	
	for k, v in pairs(tb) do
		local quo = type(k) == "string" and "\"" or ""
		ret = ret .. indent .. "[" .. quo .. tostring(k) .. quo .. "] = "
		
		if type(v) == "table" then
			local t_name = table_list[v]
			if t_name then
				ret = ret .. tostring(v) .. " -- > [\"" .. t_name .. "\"]\n"
			else
				table_list[v] = tostring(k)
				ret = ret .. "{\n"
				ret = ret .. _list_table(v, table_list, level+1)
				ret = ret .. indent .. "},\n"
			end
		elseif type(v) == "string" then
			ret = ret .. "\"" .. tostring(v) .. "\",\n"
		else
			ret = ret .. tostring(v) .. ",\n"
		end
	end
	
	local mt = getmetatable(tb)
	if mt then
		ret = ret .. "\n"
		local t_name = table_list[mt]
		ret = ret .. indent .. "<metatable> = "
		
		if t_name then
			ret = ret .. tostring(mt) .. " -- > [\"" .. t_name .. "\"]\n"
		else
			ret = ret .. "{\n"
			ret = ret .. _list_table(mt, table_list, level+1)
			ret = ret .. indent .. "}\n"
		end
		
	end
	
	return ret
end

local function table_tostring(tb)
	if type(tb) ~= "table" then
		error("Sorry, it's not table, it is " .. type(tb) .. ".")
	end
	
	local ret = " return {\n"
	local table_list = {}
	table_list[tb] = "root table"
	ret = ret .. _list_table(tb, table_list, 1)
	ret = ret .. "}"
	return ret
end


GameObject = UnityEngine.GameObject;

local function CreateEditor()
	local self = CreateObject()
	local soundTable = require "Logic/Scheme/common_sound_resource"
	local artResTable = require "Logic/Scheme/common_art_resource"

    
	self.GetModelPath = function(id)
        return artResTable.Model[id].Prefab
	end
    
    self.GetClothes = function(id)
        local vocation = math.ceil((id-10000)/2)
        local vocationSuit = 'MaleSuit'
        if id-10000-(vocation-1)*2 == 2 then
            vocationSuit = 'FemaleSuit'
        end
        local systemLoginCreate = require "Logic/Scheme/system_login_create"
        local dressTable = GetConfig('growing_fashion').Fashion
        local head = systemLoginCreate.RoleModel[vocation][vocationSuit][1]
        local body = systemLoginCreate.RoleModel[vocation][vocationSuit][2]
        local weapon = systemLoginCreate.RoleModel[vocation][vocationSuit][3]
        if weapon then
            return dressTable[head].Prefab,dressTable[body].Prefab
        else
            return dressTable[head].Prefab,dressTable[body].Prefab,dressTable[weapon].Prefab
        end
    end
	
	self.GetConfigTable = function(id ,clipName, effectType)
		local tb = {}
		local confingTable = GetConfig("MotionEffects")
		if confingTable[id] and  confingTable[id][clipName] and confingTable[id][clipName][effectType] then 
			tb = confingTable[id][clipName][effectType]
		end
		return tb
	end
    
    self.AddParam = function()
        local confingTable = GetConfig("MotionEffects")
        for k,v in pairs(confingTable) do
            for key,value in pairs(v) do
                if value.bulletEffects then
                    for a,b in pairs(value.bulletEffects) do
                        if a==0 then
                            value.bulletEffects[#value.bulletEffects + 1] = value.bulletEffects[a]
                            value.bulletEffects[a] = nil 
                        end
                    end
                end
                if value.hitEffects then
                    for a,b in pairs(value.hitEffects) do
                        if a==0 then
                            value.hitEffects[#value.hitEffects + 1] = value.hitEffects[a]
                            value.hitEffects[a] = nil 
                        end
                    end
                end
                if value.shakecam then
                    for a,b in pairs(value.shakecam) do
                        value.shakecam[#value.shakecam + 1] = value.shakecam[a]
                        value.shakecam[a] = nil 
                    end
                end

                if value.hitEffects then
                    for a,b in pairs(value.hitEffects) do
                        b.duration = 2
                        b.detach = false
                        if b.node == nil then
                            b.node = ''
                        end
                    end
                end
                if value.otherData then
                   value.otherData.modelID = k
                   value.otherData.clipName = key
                end
            end
        end
        local file = io.open("./Assets/TLBY/Lua/Logic/Scheme/MotionEffects1.lua", "w")
		assert(file)
		file:write(table_tostring(confingTable))
		file:close()
    end
	
	
	local confingTable = GetConfig("MotionEffects")
	self.StartWriteLuaTable = function(id ,clipName,effectType)
		if confingTable[id] == nil then
			confingTable[id] = {}
			
		else
			if confingTable[id][clipName] == nil then
				confingTable[id][clipName] = {}
			else
				confingTable[id][clipName][effectType] = {}
			end
		end
	end
	
	self.WriteLuaTable = function(id ,clipName ,effectType,index ,key ,value)
		if confingTable[id][clipName][effectType] then
			if confingTable[id][clipName][effectType][index] == nil then
				confingTable[id][clipName][effectType][index] ={}
			end
			confingTable[id][clipName][effectType][index][key] = value
		end
	end
    self.StartWriteLuaTable2 = function(id ,clipName)
		if not confingTable[id] then
			confingTable[id] = {}
        end
		if not confingTable[id][clipName] then
            confingTable[id][clipName] = {}
        end
	end
    self.WriteLuaTable2 = function(id ,clipName ,effectType,key ,value)
        if not confingTable[id][clipName][effectType] then
            confingTable[id][clipName][effectType] = {}
        end
		if confingTable[id][clipName][effectType] then
			confingTable[id][clipName][effectType][key] = value
            table.print(confingTable[id][clipName])
		end
	end
    
	self.WriteLuaFile = function()
		local file = io.open("./Assets/TLBY/Lua/Logic/Scheme/MotionEffects.lua", "w")
		assert(file)
		file:write(table_tostring(confingTable))
		file:close()
	end
	
	self.reload = function( moduleName )
		package.loaded[moduleName] = nil
		require(moduleName)
	end
	
	self.Log = function(tb)
		print(table_tostring(tb))
	end
	
	return self
end

Editor = Editor or CreateEditor()

