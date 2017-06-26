---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateSpeakerUICtrl()
    local self = CreateCtrlBase()
    local timeInfo = nil
    local tween = nil
    
    self.layer = LayerGroup.popCanvas
    
	self.onLoad = function()

	end
    
    self.UpdateData = function(data)
        local label = self.view.text:GetComponent('TextMeshProUGUI')
        label.text = '<color=#FF919AFF>'..(data.actor_name or "系统消息")..'</color>：'..data.data
        self.view.text:GetComponent('RectTransform').anchoredPosition = Vector2.New(10,0)
        
        if not IsNil(tween) then
            tween:Clear()
        end

        if label.preferredWidth > 910 then
            tween = BETween.anchoredPosition(self.view.text,2,Vector2.New(10,0),Vector2.New(910 - label.preferredWidth, 0))
            tween.delay = 2
        end
        
        if timeInfo then
            Timer.Remove(timeInfo)
        end
        timeInfo = Timer.Delay(5,self.Close)
    end
	
	self.onUnload = function()
        
	end
    
    self.Close = function()
        if timeInfo then
            Timer.Remove(timeInfo)
        end
        timeInfo = nil
        UIManager.UnloadView(ViewAssets.SpeakerUI)
    end
	
	return self
end

return CreateSpeakerUICtrl()