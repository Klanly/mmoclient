-----------------------------------------------------
-- auth： zhangzeng
-- date： 2016/9/19
-- desc： 宝印UI控制
-----------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "Logic/Effect/ArrestPet"

function CreateStampUICtrl()

    local self = CreateCtrlBase()
    
	function self.onActive()
	
		
	
	end
	
	local function OnCatchPetSwitch()
	
		ArrestPetInstance.Start()
	
	end
	
	local function OnCatchPetControl()
	
		
	
	end
	
	function self.onLoad()
	
		self.AddClick(self.view.catchPetSwitch, OnCatchPetSwitch)
		self.AddClick(self.view.catchPetControl, OnCatchPetControl)
		
	end

	-- 当view被卸载时事件
	function self.onUnload()
	
		self.RemoveClick(self.view.catchPetSwitch)
		self.RemoveClick(self.view.catchPetControl)
		
	end
	
	
	function self.DestoyArrestPet()
	
		ArrestPetInstance.Destroy()
	
	end
  
    return self
	
end

return CreateStampUICtrl()