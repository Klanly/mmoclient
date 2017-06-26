---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateProcessBarUICtrl()
    local self = CreateCtrlBase()
    
    self.layer = LayerGroup.popCanvas
    
	self.onLoad = function()
        self.slider = self.view.slider:GetComponent('Slider')
	end
	
	self.onUnload = function()
        
	end
    
    self.UpdateValue = function(value)
        local hero = SceneManager.GetEntityManager().hero
        if not hero then
            return
        end
        self.slider.value = value
        hero:OnControl('charge')
    end
    
    self.UpdateText = function(text)
        self.view.des:GetComponent('TextMeshProUGUI').text = text
    end
	
	return self
end

return CreateProcessBarUICtrl()