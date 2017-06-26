---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

function CreatePetUICtrl()
    local self = CreateCtrlBase()

    local subPage ={
        ViewAssets.PetDetailUI,
        ViewAssets.PetSkillUI,
        ViewAssets.PetMergeEatUI,
    }
    
    local CloseAllSubPage = function()
        for i=1,#subPage do
            UIManager.UnloadView(subPage[i])
        end
    end

    self.selectPetData = nil
    
    local callBack = nil
    
    local UpdateData = function(data)
        if data.pet_list then
            MyHeroManager.heroData.pet_list = data.pet_list
        end
        if data.ban_fight_pet_list then
            MyHeroManager.heroData.ban_fight_pet_list = data.ban_fight_pet_list
        end
        if callBack then
            callBack()
            callBack = nil
        end
    end
    
    self.GetPetList = function(CallBack)
        if not MyHeroManager.heroData.pet_list then
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_SEAL_INFO, {})
            MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_SEAL_INFO, UpdateData)
            callBack = CallBack
        elseif CallBack then
            CallBack()
        end
    end
    
	self.onLoad = function(tabIndex)
        for i=1,5 do
            self.AddClick(self.view['tab'..i], function() self.ShowTab(i) end)
        end
        self.AddClick(self.view.btnClose,self.close)
        self.view.scrollView:GetComponent(typeof(UIMultiScroller)):Init(self.view.petItem, 453, 130, 0, 8, 1)
        self.view.petItem:SetActive(false)
        self.selectPetData = nil

        self.ShowTab(tabIndex or 1)
	end
    
	self.onUnload = function()
        CloseAllSubPage()
	end
    
    self.ShowTab = function(tabIndex)
        CloseAllSubPage()
        self.view['tab'..tabIndex]:GetComponent('Toggle').isOn = true
        if tabIndex == 1 then
            return UIManager.PushView(ViewAssets.PetDetailUI)
        elseif tabIndex == 2 then
            return UIManager.PushView(ViewAssets.PetSkillUI)
        elseif tabIndex == 3 then
            return UIManager.PushView(ViewAssets.PetMergeEatUI)
        elseif tabIndex == 4 then
            return UIManager.PushView(ViewAssets.PetMergeEatUI,nil,true)
        elseif tabIndex == 5 then
            self.close()
            return UIManager.PushView(ViewAssets.WeaponsUI)
        end
    end
    
    self.ShowPetUI = function(tabIndex)
        UIManager.GetCtrl(ViewAssets.PetUI).GetPetList(function() 
            if #MyHeroManager.heroData.pet_list == 0 then UIManager.ShowNotice('暂无宠物') return end 
            UIManager.PushView(ViewAssets.PetUI,nil,tabIndex or 1)
        end)
    end
    
    self.UpdatePetList = function(count,func)
        self.view.scrollView:GetComponent(typeof(UIMultiScroller)):UpdateData(count,func)
    end

    return self
end

return CreatePetUICtrl()