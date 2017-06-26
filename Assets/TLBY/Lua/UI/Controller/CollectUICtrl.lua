---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/8
-- desc： 显示拾取
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local collectAnimation = 'spell_loop'

local function CreateCollectUICtrl()
	local self = CreateCtrlBase()
	local timer = nil
	self.totalTime = 0
	self.currentTime = 0
	local interval = 0.02

	self.onCollectOver = nil
		
	local cancelClick = function()
		self.close()
	end

	local stopTimer = function()
		if timer then
			Timer.Remove(timer)
		end
		timer = nil

		local hero = SceneManager.GetEntityManager().hero
		if hero then
			hero.behavior:StopBehavior(collectAnimation)
		end
		
	end
	local startTimer = function()
		stopTimer()
		local hero = SceneManager.GetEntityManager().hero
		if hero then
			hero:StopMove()
			hero.behavior:UpdateBehavior(collectAnimation)
		end

		self.view.bgblue:GetComponent("Image").fillAmount = 0
		timer = Timer.Repeat(interval, function()
			self.currentTime = self.currentTime - interval
			self.view.bgblue:GetComponent("Image").fillAmount = 1 - self.currentTime/self.totalTime
			if self.currentTime <= 0 then
				if self.onCollectOver then
					self.onCollectOver()
					self.onCollectOver = nil
				end
				self.close()
			end
		end)
	end
	
	self.onLoad = function(collecttime, callback)
		self.totalTime = collecttime or self.totalTime
		self.currentTime = self.totalTime
		startTimer() 
        ClickEventListener.Get(self.view.mask).onClick = cancelClick

		self.onCollectOver = callback
	end
	
	self.onUnload = function()
		stopTimer()
		self.onCollectOver = nil
	end

	return self
end

return CreateCollectUICtrl()