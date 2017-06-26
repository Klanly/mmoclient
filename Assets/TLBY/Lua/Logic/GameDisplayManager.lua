---------------------------------------------------
-- auth： panyinglong
-- date： 2017/2/21
-- desc： 游戏显示相关的管理
---------------------------------------------------

require "Common/basic/LuaObject"


local function CreateGameDisplayManager()
	local self = CreateObject()

	local displayerNumTimer = nil
	local puppetList = {}

	-- 是否是可设置单位
	local isAlivePuppet = function(v)
		return v and 
				(
					v.entityType == EntityType.Hero or 
					v.entityType == EntityType.Dummy --or 
					-- v.entityType == EntityType.Monster or 
					-- v.entityType == EntityType.NPC or 
					-- v.entityType == EntityType.Pet or 
					-- v.entityType == EntityType.WildPet
				) and not v:IsDied() and not v:IsDestroy()
	end

	-- 是否是必定显示的单位
	local isAllwaysDisplay = function(v)
		return isAlivePuppet(v) and 
				(
					v.entityType == EntityType.Hero or
					(v.entityType == EntityType.Dummy and PKManager.getPkData(uid) and PKManager.getPkData(uid).pkColor == PKColor.Darkgreen) or
					-- (v.entityType == EntityType.Monster and (v.data.Type == 5 or v.data.Type == 7)) or -- 世界boss/阵营boss
					TargetManager.GetTarget() == v
				)
	end

	-- 更新宠物的显示，与主人同步
	local updatePetDisplay = function()
		for k, v in ipairs(puppetList) do	
			if v.entityType == EntityType.Pet and isAlivePuppet(v) and isAlivePuppet(v.owner) then
				if v:GetBodyActive() ~= v.owner:GetBodyActive() then
					v:SetBodyActive(v.owner:GetBodyActive())
				end
			end
		end
	end

	-- 刷新单位列表，以hero为中心，由近及远
	local updatePuppetList = function()
		local hero = SceneManager.GetEntityManager().hero
		puppetList = SceneManager.GetEntityManager().QueryPuppetsAsArray(function(v)
			if isAlivePuppet(v) and not isAllwaysDisplay(v) then
				return true
			end
			return false
		end)
		table.sort(puppetList, function(a, b)
			return Vector3.Distance2D(a:GetPosition(), hero:GetPosition()) < Vector3.Distance2D(b:GetPosition(), hero:GetPosition())
		end)
	end
	
	--是否显示当前顺序的单位或则单位特效
	local IsPupOrPupEffDisplay = function(index)
		local isPupDisplay = true
		local isPupEffDisplay = true
	
		if index <= GlobalManager.MaxDisplayCount then
			isPupDisplay = true
		elseif index > GlobalManager.MaxDisplayCount then
			isPupDisplay = false
		end
		
		if GlobalManager.maxEffectDisplayCount >= GlobalManager.MaxDisplayCount then
			--以角色数量设置为准
			isPupEffDisplay = isPupDisplay
		else
			if index <= GlobalManager.maxEffectDisplayCount then
				isPupEffDisplay = true
			elseif index > GlobalManager.maxEffectDisplayCount then
				isPupEffDisplay = false
			end
		end
		
		return isPupDisplay, isPupEffDisplay
	end

	-- 执行单位显示更新操作
	local currentTime = 0
	local normalTime = GetConfig("common_parameter_formula").Parameter[11].Parameter
	local hookTime = GetConfig("common_parameter_formula").Parameter[12].Parameter
	local updatePuppetDisplay = function()
		currentTime = currentTime + 1
		if GlobalManager.isHook then
			if currentTime < hookTime then
				return
			end
		else
			if currentTime < normalTime then
				return
			end
		end
		currentTime = 0
		if not isAlivePuppet(SceneManager.GetEntityManager().hero) then
			return
		end
		updatePuppetList()
		for i = 1, #puppetList do
			local isPupDisplay, isPupEffDisplay = IsPupOrPupEffDisplay(i)
			if isPupDisplay then
				if not puppetList[i]:GetBodyActive() then
					puppetList[i]:SetBodyActive(true)
				end
			else
				if puppetList[i]:GetBodyActive() then
					puppetList[i]:SetBodyActive(false)
				end
			end
			
			if isPupEffDisplay then
				puppetList[i]:SetPlayEffect(true)
			else
				puppetList[i]:SetPlayEffect(false)
			end
		end
		updatePetDisplay()
	end

	local initDisplayNum = function()
		if displayerNumTimer == nil then
			displayerNumTimer = Timer.RepeatForever(1, updatePuppetDisplay)
		end
	end
	local Init = function()
		initDisplayNum()
	end
	Init()
end

GameDisplayManager = GameDisplayManager or CreateGameDisplayManager()