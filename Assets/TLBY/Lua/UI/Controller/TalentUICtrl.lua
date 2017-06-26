---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/22
-- desc： 
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local wait_to_choose = nil

local function InitStaticButton(controller)
	-- 确定激活界面
	controller.view.confirmactivationui:SetActive(false)
	UIUtil.AddButtonEffect(controller.view.btnconfirm_tip, nil, nil)
    ClickEventListener.Get(controller.view.btnconfirm_tip).onClick = function()
    	
    end

    UIUtil.AddButtonEffect(controller.view.btnclose_tip, nil, nil)
    ClickEventListener.Get(controller.view.btnclose_tip).onClick = function()
    	controller.view.confirmactivationui:SetActive(false)
    end

    for i = 1,3 do
    	UIUtil.AddButtonEffect(controller.view["btnactivation"..i], nil, nil)
	    ClickEventListener.Get(controller.view["btnactivation"..i]).onClick = function()
	    	wait_to_choose = i
	    	controller.view.confirmactivationui:SetActive(true)
	    end
    end

    UIUtil.AddButtonEffect(controller.view.btnClose, nil, nil)
    ClickEventListener.Get(controller.view.btnClose).onClick = function()
    	controller.close()
    end
end

local function CreateTalentUICtrl()
	local self = CreateCtrlBase()

	self.onLoad = function(data)

		InitStaticButton(self)

	end
	
	self.onUnload = function()
		
	end

	return self
end

return CreateTalentUICtrl()