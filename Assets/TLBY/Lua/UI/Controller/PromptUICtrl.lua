--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/11 0011
-- Time: 19:56
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "Common/basic/Timer"

local function CreatePromptUICtrl()
	local self = CreateCtrlBase()
    local timeinfo = nil
    self.layer = LayerGroup.popCanvas

    -- local function OnBgClick()
    --     Close()
    -- end

	self.onLoad = function()
        self.Msg = self.view.Msg:GetComponent("TextMeshProUGUI")
		-- ClickEventListener.Get(self.view.Bg).onClick = OnBgClick
	end
    
    local clearTimer = function()
        if timeinfo then
            Timer.Remove(timeinfo)
        end
        timeinfo = nil        
    end
    self.onUnload = function()
        clearTimer()
    end

	self.UpdateMsg = function(data)
        self.Msg.text = data
        local width = 534
        if self.Msg.preferredWidth + 45 > width then width = self.Msg.preferredWidth + 45 end
        self.view.Bg:GetComponent('RectTransform').sizeDelta = Vector2.New(width, 52)
        clearTimer()
        timeinfo = Timer.Delay(2, function()
            self.close()
        end)
    end

	return self
end

return CreatePromptUICtrl()

