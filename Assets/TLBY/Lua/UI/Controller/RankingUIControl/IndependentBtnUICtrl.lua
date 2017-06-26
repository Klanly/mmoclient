--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/4/17
--
require "UI/Controller/LuaCtrlBase"


local function CreateIndependentBtnUICtrl()
    local self = CreateCtrlBase()
	local selfData

	local OnClose = function()
		UIManager.UnloadView(ViewAssets.IndependentBtnUI)
	end
	
	local OnCheck = function()
		if selfData == nil then
			return
		end
		
		if selfData.actionFunc then
			selfData.actionFunc(selfData)
		end
		OnClose()
	end
	
    self.onLoad = function(data)
		view = self.view
		selfData = data
		
		if data and	data.pos then
			view.transform.position = data.pos
		end

		ClickEventListener.Get(view.bg).onClick = OnClose
		ClickEventListener.Get(view.btnCheck).onClick = OnCheck
	end

    self.onUnload = function()
		
	end

    return self
end

return CreateIndependentBtnUICtrl()