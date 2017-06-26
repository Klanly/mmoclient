---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/15
-- desc： 掉落管理
---------------------------------------------------


require "Common/basic/LuaObject"
require "Logic/Entity/View/DropPickedEffect"
local dungeonTable = require "Logic/Scheme/challenge_main_dungeon"
local parameterScheme = require "Logic/Scheme/common_parameter_formula"
local itemtable = require "Logic/Scheme/common_item"
local sceneTable = GetConfig('common_scene')

-- local function CreateDropLocusManager()
-- 	local self = CreateObject()

-- 	local dropsData = {}  --掉落
-- 	local dropsTimeInfo
-- 	local currentDropData  
	
-- 	local GetCurrentDropData = function()
-- 		local dropData
-- 		for k, v in pairs(dropsData) do
			
-- 			dropData = v
-- 			if dropData then
					
-- 				break
-- 			end
-- 		end
			
-- 		return dropData
-- 	end
	
-- 	local CreateDrops= function()

-- 		currentDropData = GetCurrentDropData()
-- 		if not currentDropData then
			
-- 			return
-- 		end
		
-- 		local drop = SceneManager.GetEntityManager().CreateDrop(currentDropData) -- 掉落实体
-- 		DropManager.Add(drop)
-- 		self.Remove(currentDropData)
-- 	end
	
-- 	self.StartDropsLocus = function()
	
-- 		if dropsTimeInfo then
		
-- 			Timer.Remove(dropsTimeInfo)
-- 		end
-- 		dropsTimeInfo = Timer.Repeat(0.2, CreateDrops)
-- 	end
	
-- 	self.Add = function(data)
	
-- 		dropsData[data.entity_id] = data
-- 	end
	
-- 	self.Remove = function(data)
	
-- 		dropsData[data.entity_id] = nil
-- 	end
	
-- 	return self
-- end


local function CreateDropManager()
	local self = CreateObject()

	local timer = nil

	local drops = nil

	local updateDrops = function()
		drops = nil
		drops = SceneManager.GetEntityManager().QueryPuppetsAsArray(function(v)
			if v.entityType == EntityType.Drop then
				return true
			end
		end)
	end

	local requestPick = function(drop, picker, mode)
		if not drop.canPick then
			return
		end
		local data = {}
		data.func_name = 'on_pick_drop'
		data.drop_entity_id = drop.uid
		data.mode = mode
		MessageManager.RequestLua(SceneManager.GetRPCMSGCode(), data)
		drop.canPick = false
	end
	local stopTimer = function()
		if timer then
			Timer.Remove(timer)
		end
		timer = nil
	end
	local startTimer = function()
		stopTimer()

		local canAutoPick = function()
			local auto = sceneTable.Totalparameter[SceneManager.currentSceneType].Pickup
			if auto == 1 then
				return true
			else
				return false
			end
		end
		
		-- 是否满足拾取条件, 包括手动和自动
		local canPick = function(drop, uid, now)
			if not drop.canPick then
				return false
			end
			if drop.data.is_team then
				return true
			else 
				if drop.data.owner_id == uid then
					return true
				else
					if now > drop.protectTime then
						return true
					end
				end
			end
			return false
		end

		local tick = function()
			local hero = SceneManager.GetEntityManager().hero
			if not hero or hero:IsDestroy() or hero:IsDied() then
		    	return
		    end
		    updateDrops()
		    local now = networkMgr:GetConnection().ServerSecondTimestamp
		    for i = 1, #drops do
		    	local drop = drops[i]
		    	if now > drop.disappearTime then
		    		SceneManager.GetEntityManager().DestroyPuppet(drop.uid)
		    	else
		    		if canPick(drop, hero.uid, now) then
		    			if now > drop.autoPickTime and canAutoPick() then
		    				requestPick(drop, hero, 'auto')
		    			elseif Vector3.InDistance(hero:GetPosition(), drop:GetPosition(), drop.pickDistance) then
			    			requestPick(drop, hero, 'manual')
			    		end
			    	end
			    end
		    end
		end

		timer = Timer.Repeat(0.2, tick)
	end

	self.PickDropRet = function(data)
		-- table.print(data, '----- .... ----')
		local dropUID = data.drop_entity_id
		local dummyUID = data.actor_id
		local dropPos = Vector3.New(data.position.x/100, data.position.y/100, data.position.z/100)
		if dummyUID then
			local dummy = SceneManager.GetEntityManager().GetPuppet(dummyUID)
			if dummy then
		        local startPos = dummy:GetPosition()
		        ResourceManager.CreateEffect('Common/eff_common@pickup', 1.5, function(go) 
		            go.transform.position = dropPos
		            Util.Beizer3(go, 
		                1.5,
		                dropPos, 
		                Vector3.New(startPos.x - 1.5, startPos.y + 0.5, startPos.z + 1.5),
		                Vector3.New(startPos.x + 1.5, startPos.y + 1, startPos.z - 1.5),
		                Vector3.New(startPos.x, startPos.y + 1.5, startPos.z),
		                dummy.behavior.transform
		                )
		        end)
			end
		end
		-- data.position：table，掉落物位置
	end

    self.ManualRollItem = function(data)
        UIManager.ShowGetDropItemUI(data.drop_data)
    end
    
	local init = function()
		startTimer()
		MessageRPCManager.AddUser(self, 'PickDropRet')
        MessageRPCManager.AddUser(self, 'ManualRollItem') 
	end

	init()
	return self
end

DropManager = DropManager or CreateDropManager()