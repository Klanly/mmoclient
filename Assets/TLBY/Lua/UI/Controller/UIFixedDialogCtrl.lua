require "UI/Controller/LuaCtrlBase"

local function CreateUIFixedDialogCtrl()
	local self = CreateCtrlBase()
    self.layer = LayerGroup.pop
    
    
	self.onLoad = function(data)
        self.updateUI(data)
	end

    self.updateUI = function(data)
        self.view.text:GetComponent('TextMeshProUGUI').text = data.text
    end
    
    self.onUnload = function()
        
	end

	return self
end

return CreateUIFixedDialogCtrl()
