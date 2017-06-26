---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateContractSelectNoteUICtrl()
    local self = CreateCtrlBase()

	self.onLoad = function(text)
        self.view.text:GetComponent("TextMeshProUGUI").text = text
	end
	
	self.onUnload = function()
        
	end
	
	return self
end

return CreateContractSelectNoteUICtrl()