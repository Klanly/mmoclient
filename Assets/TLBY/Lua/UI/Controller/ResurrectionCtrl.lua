---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/1
-- desc： 复活
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
-- local fightBaseTable = GetConfig('common_fight_base')
local constant = require "Common/constant"

local function CreateResurrectionCtrl()
	local self = CreateCtrlBase()
	self.owner = nil
	self.data = nil

	self.enableCache = false
	
	self.homeRevive = 0
    self.immediatelyRevive = 0
    self.pointRevive = 0
    self.autoHomeRevive = 0

	-- 玩家选择的重生类型：1回城复活， 2立即复活, 3复活点复活， 4自动回城复活
    local revive = function(t)
    	self.isLock = false
    	PKManager.requestRebirth(t)
	end

    ----------- timer -----------
    local tick = nil
	local timer = nil
	local stopTimer = function()
		if timer then
			Timer.Remove(timer)
		end
		timer = nil		
	end
	local startTimer = function(start)
		stopTimer()
		local seconds = start
		timer = Timer.Repeat(1, function()
			tick(seconds)
			seconds = seconds + 1
		end)
	end
	tick = function(seconds)
		if self.homeRevive - seconds > 0 then
	        self.view.time1:GetComponent('TextMeshProUGUI').text = '(' .. (self.homeRevive - seconds) .. 'S)'
	    else
	    	self.view.time1:GetComponent('TextMeshProUGUI').text = ''
	    	if self.autoHomeRevive - seconds > 0 then
	    		self.view.time1:GetComponent('TextMeshProUGUI').text = '(' .. (self.autoHomeRevive - seconds) .. 'S)'
	    	else
	    		stopTimer()
	    	end
	    end
		if self.immediatelyRevive - seconds > 0 then
	        self.view.time2:GetComponent('TextMeshProUGUI').text = '(' .. (self.immediatelyRevive - seconds) .. 'S)'
	    else
	    	self.view.time2:GetComponent('TextMeshProUGUI').text = ''
	    end
		if self.pointRevive - seconds > 0 then
	        self.view.time3:GetComponent('TextMeshProUGUI').text = '(' .. (self.pointRevive - seconds) .. 'S)'
	    else
	    	self.view.time3:GetComponent('TextMeshProUGUI').text = ''
	    end

		if seconds == self.homeRevive then
			self.AddClick(self.view.btn1, function() revive(constant.REBIRTH_TYPE.city_active); end)
			self.setButtonEnable(self.view.btn1, true) -- 回城复活
		end
		if seconds == self.immediatelyRevive then
			self.AddClick(self.view.btn2, function() revive(constant.REBIRTH_TYPE.original_place); end)
			self.setButtonEnable(self.view.btn2, true) -- 立即复活
		end
		if seconds == self.pointRevive then 	-- 复活点复活
			self.AddClick(self.view.btn3, function() revive(constant.REBIRTH_TYPE.rebirth_place_active); end)
			self.setButtonEnable(self.view.btn3, true)
		end
	end
	----------------------------
	local updateUI = function()
		-- 复活消耗
        local itemId = self.data.item_id
        local hasCount = BagManager.GetItemNumberById(itemId)
        local itemCount = self.data.item_count or 0
        local text = ''
        if hasCount >= itemCount then
        	text = '<color=white>' .. hasCount .. '/' .. itemCount .. '</color>'
        else
        	text = '<color=red>' .. hasCount .. '/' .. itemCount .. '</color>'
        end
        self.view.textconsumenumber:GetComponent('TextMeshProUGUI').text = text
        self.view.iconAcer:GetComponent('Image').sprite = LuaUIUtil.GetItemIcon(itemId)
	end
	local onItemUpdate = function(t)
		if t == 'bag' then
			updateUI()
		end
	end

	self.onLoad = function(owner, data)
		-- 如果在副本里,并且已经弹出结算页面的话,先将自己隐藏
		if SceneManager.IsOnDungeonScene() then
			local ctrl = UIManager.GetCtrl(ViewAssets.ChallengeOverUI)
			if ctrl.isLoaded then
				self.hide()
			end
		end
		
		self.owner = owner
		self.data = data
    	self.isLock = true
        -- self.AddClick(self.view.btnclose, closeClick)

        self.setButtonEnable(self.view.btn1, false)
        self.AddClick(self.view.btn1, nil)

        self.setButtonEnable(self.view.btn2, false)
        self.AddClick(self.view.btn2, nil)

        self.setButtonEnable(self.view.btn3, false)
        self.AddClick(self.view.btn3, nil)        
     
        self.homeRevive = self.data[constant.REBIRTH_TYPE.city_active] 				-- 回城复活（主动）
        self.immediatelyRevive = self.data[constant.REBIRTH_TYPE.original_place] 	-- 原地复活
        self.pointRevive = self.data[constant.REBIRTH_TYPE.rebirth_place_active] 	-- 复活点复活(主动)
        self.autoHomeRevive = self.data[constant.REBIRTH_TYPE.city_passive] 		-- 回城复活（被动）

    	self.view.time1:GetComponent('TextMeshProUGUI').text = ''
    	self.view.time2:GetComponent('TextMeshProUGUI').text = ''
    	self.view.time3:GetComponent('TextMeshProUGUI').text = ''
        startTimer(0)

        updateUI()
        BagManager.AddBagListener(onItemUpdate)
	end
	
	self.onUnload = function()
		stopTimer()
        BagManager.RemoveBagListener(onItemUpdate)
	end	

	return self
end

return CreateResurrectionCtrl()