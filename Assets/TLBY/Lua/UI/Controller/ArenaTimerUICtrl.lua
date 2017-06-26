---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/1
-- desc： 
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

local function CreateArenaTimerUICtrl()
	local self = CreateCtrlBase()
	self.enableCache = false
	self.seconds = 9
	self.tick = nil

	local onTimesupCb = nil

	local updateUI = function()	
		if not self.tick then
			return
		end	
		self.tick(self.seconds, self.view.number_small, self.view.number_big)
	end

	local timer = nil
	local stopTimer = function()
		if timer then
			Timer.Remove(timer)
		end
		timer = nil
	end
	local startTimer = function()
		stopTimer()
		timer = Timer.Repeat(1, function()
			self.seconds = self.seconds - 1
			updateUI()
			if self.seconds <= 0 then
				stopTimer()
				self.onTimesup()
			end
		end)
	end
	
	self.onTimesup = function()
		self.close()
		if onTimesupCb then
			onTimesupCb()
		end
	end
	self.onLoad = function(seconds, onTimesup, tick)	
		self.seconds = seconds
		self.tick = tick

		if self.seconds < 0 then
			self.seconds = 0
		end
		onTimesupCb = onTimesup
		updateUI()
		startTimer()
	end

	self.onUnload = function()
		stopTimer()
	end

	return self
end

return CreateArenaTimerUICtrl()