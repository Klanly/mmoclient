--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/6
--

require "UI/Controller/LuaCtrlBase"

local function CreateCommTextTipUICtrl()
    local self = CreateCtrlBase()
	local timeinfo
	
	local OnClick = function()
	
		self.Close()
	end
	
    function self.onLoad()
	
		local view = self.view
		ClickEventListener.Get(view.Bottom).onClick = OnClick
    end
	
	function self.Close()
		if (timeinfo) then
		
			Timer.Remove(timeinfo)
			timeinfo = nil
		end
		
        UIManager.UnloadView(ViewAssets.CommTextTipUI)
    end
	
	function self.SetPosition(pos)
	
		self.view.Top.transform.position = pos
	end

	function self.SetData(data)
	
		local text = self.view.Content:GetComponent("Text")
		local image = self.view.Bg:GetComponent("Image")
		
		text.text = data
		
        local width = 200
		local height = 100
		local maxWidth = 300
        if text.preferredWidth + 45 > width then width = text.preferredWidth + 45 end
		if width > maxWidth then width = maxWidth end
		if text.preferredHeight + 45 > height then height = text.preferredHeight + 45 end
		
        self.view.Content:GetComponent('RectTransform').sizeDelta = Vector2.New(width - 45, height)
		self.view.Bg:GetComponent('RectTransform').sizeDelta = Vector2.New(width, height)
		
		if timeinfo then
            Timer.Remove(timeinfo)
        end
        timeinfo = Timer.Delay(5, self.Close)
	end

    return self
end

return CreateCommTextTipUICtrl()



