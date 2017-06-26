require "UI/Controller/LuaCtrlBase"

local function CreateFactionUICtrl()
	local self = CreateCtrlBase()
    
    local CloseSubPage = function()
        UIManager.UnloadView(ViewAssets.FactionMembersUI)
        UIManager.UnloadView(ViewAssets.UnionInformationsUI)
        UIManager.UnloadView(ViewAssets.FactionApplyUI)
    end
    
    local OnInfoClick = function()
        CloseSubPage()
		UIManager.PushView(ViewAssets.UnionInformationsUI)
    end
    
    local OnMemerbsClick = function()
        if not FactionManager.InFaction() then
            self.view.tabInfo:GetComponent('Toggle').isOn = true
            UIManager.PushView(ViewAssets.FactionCreateUI)
            UIManager.ShowNotice('尚未加入任何帮会')
            return
        end
        CloseSubPage()
        UIManager.GetCtrl(ViewAssets.FactionMembersUI).OpenUI()
    end
    
    local OnWelfareClick = function()
    
    end
    
    local OnActivityClick = function()
    
    end
    
	self.onLoad = function(data)
        self.AddClick(self.view.tabInfo, OnInfoClick)
        self.AddClick(self.view.tabMembers,OnMemerbsClick)
        self.AddClick(self.view.tabWelfare, OnWelfareClick)
        self.AddClick(self.view.tabActivity, OnActivityClick)
        self.AddClick(self.view.btnClose, self.close)
        
        self.view.tabInfo:GetComponent('Toggle').isOn = true
        OnInfoClick()
	end
    
    self.onUnload = function()
        CloseSubPage()
	end

	return self
end

return CreateFactionUICtrl()
