---------------------------------------------------
-- auth： zhangzeng
-- date： 2016/9/19
-- desc： 宝印UI
---------------------------------------------------
require "UI/View/LuaViewBase"

local function CreateStampUI()
	local self = CreateViewBase()
    
	function self.Awake()
	
		local transform = self.transform
		self.catchPetSwitch = transform:FindChild("CatchPetSwitch").gameObject
		self.catchPetControl = transform:FindChild("CatchPetControl").gameObject
		self.rateProcess = transform:FindChild("RateProcess/Handle").gameObject
		
	end
	
	function self.SetRateProcess(rate)
	
		if (not self.rateProcess) then
			
			return
			
		end
		
		local p = rate * 2 - 0.01 * math.pow(rate, 2)
		local  rateProcess = self.rateProcess:GetComponent('RateProcess')
		rateProcess:SetProcess(p)
	
	end
       
	return self
end

StampUI = StampUI or CreateStampUI()