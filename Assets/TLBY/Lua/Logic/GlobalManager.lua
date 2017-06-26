---------------------------------------------------
-- auth： yanwei
-- date： 全局管理
---------------------------------------------------
require "Common/basic/LuaObject"

local key_MaxUnitDisplay = "key_MaxUnitDisplay"
local key_MaxEffectDisplay = 'key_MaxEffectDisplay'


local function CreateGlobalManager()
    local self = CreateObject()
    self.isHook = false --是否挂机
    self.HookRadius = GetConfig("common_parameter_formula").Parameter[9].Parameter

	self.lowestShowCount = 0
	self.lowShowCount = GetConfig("common_parameter_formula").Parameter[25].Parameter
	self.mediumShowCount = GetConfig("common_parameter_formula").Parameter[26].Parameter
	self.mostShowCount = 999999
	self.MaxDisplayCount = self.mostShowCount
	self.AutoSwitchDurg = false
	self.AutoHealthSupple = false    --自动补充体力丹药
	self.AutoMagicSupple = false     --自动补充法力丹药
	self.AutoPetHealthSupple = false     --宠物自动补充丹药
	self.HealthSuppleThreshold = 0
	self.MagicSuppleThreshold = 0
	self.PetHealthSuppleThreshold = 0
	self.HealthSuppleDurgID = -1  --体力丹药
	self.MagicSuppleDurgID = -1   --法力丹药
	self.PetHealthSuppleDurgID = -1   --宠物体力丹药
	self.maxEffectDisplayCount = self.mostShowCount

	local updateMaxDisplayCount = function(level)
		if level == 1 then
			self.MaxDisplayCount = self.lowestShowCount
		elseif level == 2 then
			self.MaxDisplayCount = self.lowShowCount
		elseif level == 3 then
			self.MaxDisplayCount = self.mediumShowCount
		elseif level == 4 then
			self.MaxDisplayCount = self.mostShowCount
		end
	end
	
	self.GetClientConfigRet = function(data)
		for key, value in pairs(data.client_config) do
		   self[key]= value
		end
	end

	-- 最大同屏人数 分Lowest = 1, Low = 2, Medium = 3, Most = 4级 level = [1,2,3,4]
	self.SetMaxDisplayLevel = function(level)
		if level ~= 1 and level ~= 2 and level ~= 3 and level ~= 4 then
			error('level 只能是等于[1,2,3,4]')
			return
		end
		UnityEngine.PlayerPrefs.SetInt(key_MaxUnitDisplay, level)
		updateMaxDisplayCount(level)
	end
	self.GetMaxDisplayLevel = function()
		if not UnityEngine.PlayerPrefs.HasKey(key_MaxUnitDisplay) then
			self.SetMaxDisplayLevel(4)
			return 4
		end
		return UnityEngine.PlayerPrefs.GetInt(key_MaxUnitDisplay)
	end
	
	--------------------同屏特效
	local updateMaxEffectDisplayCount = function(level)
		if level == 1 then
			self.maxEffectDisplayCount = self.lowestShowCount
		elseif level == 2 then
			self.maxEffectDisplayCount = self.lowShowCount
		elseif level == 3 then
			self.maxEffectDisplayCount = self.mediumShowCount
		elseif level == 4 then
			self.maxEffectDisplayCount = self.mostShowCount
		end
	end
	
	-- 最大同屏特效 分Lowest = 1, Low = 2, Medium = 3, Most = 4级 level = [1,2,3,4]
	self.SetMaxEffectDisplayLevel = function(level)
		if level ~= 1 and level ~= 2 and level ~= 3 and level ~= 4 then
			error('level 只能是等于[1,2,3,4]')
			return
		end
		UnityEngine.PlayerPrefs.SetInt(key_MaxEffectDisplay, level)
		updateMaxEffectDisplayCount(level)
	end
	
	self.GetMaxEffectDisplayLevel = function()
		if not UnityEngine.PlayerPrefs.HasKey(key_MaxEffectDisplay) then
			self.SetMaxEffectDisplayLevel(4)
			return 4
		end
		return UnityEngine.PlayerPrefs.GetInt(key_MaxEffectDisplay)
	end
	---------------------

	local Init = function()
		local level = self.GetMaxDisplayLevel()
		updateMaxDisplayCount(level)
		level = self.GetMaxEffectDisplayLevel()
		updateMaxEffectDisplayCount(level)

		MessageRPCManager.AddUser(self, 'GetClientConfigRet')					 --获取客户端配置
	end
	Init()
    return self
end

GlobalManager = GlobalManager or CreateGlobalManager()

