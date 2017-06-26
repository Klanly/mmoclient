--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/9
--
require "UI/Controller/LuaCtrlBase"

local function CreateCampUICtrl()
    local self = CreateCtrlBase()
	local slectPageIndex = 0
	local maxPageNum = 5
	
	local PageItemsName = {ViewAssets.CampBaseUI,ViewAssets.CampTaskUI,ViewAssets.CampBattleUI,ViewAssets.CampTitleUI,ViewAssets.CampOfficeUI}

	self.OnPage = function(index)			--切页
		if slectPageIndex == index then
			return
		end
		slectPageIndex = index
        self.view['tab'..slectPageIndex]:GetComponent('Toggle').isOn = true
		for i = 1, maxPageNum do
            UIManager.UnloadView(PageItemsName[i])
		end
        UIManager.PushView(PageItemsName[slectPageIndex])
	end
	
	
    self.onLoad = function()
		local view = self.view

		ClickEventListener.Get(view.btnquit).onClick = self.close

		for i = 1, maxPageNum do
			ClickEventListener.Get(view['tab'..i]).onClick = function() self.OnPage(i) end
		end
        self.OnPage(1)
    end

    self.onUnload = function()

		for i=1,maxPageNum do
            UIManager.UnloadView(PageItemsName[i])
        end
		slectPageIndex = 0
    end

    return self
end

return CreateCampUICtrl()

