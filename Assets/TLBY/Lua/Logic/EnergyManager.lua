---------------------------------------------------
-- auth： panyinglong
-- date： 2016/10/31
-- desc： 体力管理
---------------------------------------------------
require "Common/basic/LuaObject"

local dungeonScheme = require "Logic/Scheme/challenge_main_dungeon"
local formulaScheme = require "Logic/Scheme/common_parameter_formula"
local levelScheme = require "Logic/Scheme/common_levels"

local function CreateEnergyManager()
	local self = CreateObject()

	self.currentEnergy = 0 		-- 当前体力值
	self.NormalConsume = dungeonScheme.Parameter[2].Value[1] 		-- 普通副本的体力消耗
	self.EliteConsume = dungeonScheme.Parameter[3].Value[1] 		-- 精英副本的体力消耗
	self.RecoverSeconds = formulaScheme.Parameter[21].Parameter 	-- 每点体力恢复秒数
	self.BuyCount = 0

	local event = CreateEvent()
	local eventKey = 'OnEnergyValueChange'

	local timer = nil
	local Tick = function()
		if self.currentEnergy < self.GetMaxEnergy() then
			self.currentEnergy = self.currentEnergy + 1
			event.Brocast(eventKey, self.currentEnergy)
		end
	end

	-- 获取最大体力值
	self.GetMaxEnergy = function()
		if SceneManager.GetEntityManager().hero then
			return levelScheme.Level[MyHeroManager.heroData.level].Vit 			-- 最大体力
		end
		return 0
	end

	self.GetPrice = function()
	    local price = 0
	    table.sort( dungeonScheme.PurchasePower, function(a, b) return a.LowerLimit > b.LowerLimit end)

	    for i, v in ipairs(dungeonScheme.PurchasePower) do
	        if self.BuyCount <= v.LowerLimit then
	            price = v.CostIngot
	        end
	    end
	    return price
	end

	self.GetBuyNum = function()
		return dungeonScheme.Parameter[12].Value[1]
	end

	self.SetRecoverTime = function()
		if timer ~= nil then
			timer.forever = false
			Timer.Remove(timer)
			timer = nil
		end
		timer = Timer.RepeatForever(self.RecoverSeconds, function() Tick() end)
	end
	
	local OnUpdateData = function(data)		
		if data.tili then
			self.currentEnergy = data.tili
			event.Brocast(eventKey, self.currentEnergy)
			-- print("update tili:" .. self.currentEnergy)
		end

		if data.tili_buy_times then
			self.BuyCount = data.tili_buy_times 
		end
	end

	local OnLogin = function(data)
		if data.login_data then
			if data.login_data.tili then
				self.currentEnergy = data.login_data.tili
				if timer == nil then
					self.SetRecoverTime()
				end
				event.Brocast(eventKey, self.currentEnergy)
			end
			-- print("login tili:" .. self.currentEnergy)
			if data.login_data.tili_buy_times then
				self.BuyCount = data.login_data.tili_buy_times 
			end
		end
	end

	local OnBuyEnery = function(data)
		if data.result == 0 then
			UIManager.ShowNotice("购买体力成功")
		elseif data.result == CommonDefine.error_item_not_enough then
			UIManager.ShowNotice('元宝不足')
		end
	end

	self.NextBuyInfo = function()
		
	end

	self.GetConsume = function()
		return self.NormalConsume
	end

	self.IsEnoughConsume = function()
		return self.currentEnergy >= self.GetConsume()
	end

	self.Init = function()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, OnLogin)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_TILI_BUY, OnBuyEnery)
	end

	self.AddListener = function(func)
		event.AddListener(eventKey, func)
	end
	self.RemoveListener = function(func)
		event.RemoveListener(eventKey, func)
	end

	self.Init()

	return self
end

EnergyManager = EnergyManager or CreateEnergyManager()