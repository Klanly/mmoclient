---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

function CreatePetDetailUICtrl()
    local self = CreateCtrlBase()
    local petDataList = {}
    local petUI = nil
    local petModel = nil
    local petBase = nil
    local petConfig = require "Logic/Scheme/growing_pet"
    local levelExp = require 'Logic/Scheme/common_levels'

    local OnFight = function(data)
        return data.fight_index and data.fight_index > 0
    end
    
    local OnDefend = function(id)
        for k,v in pairs(MyHeroManager.heroData.defend_pet) do
            if v == id then
                return true
            end
        end
        return false
    end
    
    local ScoreRankHigh = function(data)
        local num = 0
        for k,v in pairs(MyHeroManager.heroData.pet_list) do
            if v ~= data and v.pet_score >= data.pet_score then
                num = num + 1
                if num >= 2 then
                    return false
                end
            end
        end
        return true
    end
    
    local OnFightPetNum = function()
        local num = 0
        for k,v in pairs(MyHeroManager.heroData.pet_list) do
            if v.fight_index and v.fight_index > 0 then
                num = num + 1
            end
        end       
        return num
    end
    
    local UpdatePetItem = function(item,index) 
        local key = index + 1
        if petDataList[key] == nil then 
            item:SetActive(false) 
            return 
        else 
            item:SetActive(true) 
        end
        local data = petDataList[key]

        local onFightFlag = item.transform:FindChild("onFight").gameObject
        onFightFlag:SetActive(OnFight(data))
        local name = item.transform:FindChild("name").gameObject:GetComponent("TextMeshProUGUI")
        name.text = LuaUIUtil.GetPetName(data.pet_id)
        local starLv = item.transform:FindChild("star").gameObject:GetComponent("TextMeshProUGUI")
        starLv.text = data.pet_star
        local petLv = item.transform:FindChild("level").gameObject:GetComponent("TextMeshProUGUI")
        petLv.text = data.pet_level..'级'
        local icon = item.transform:FindChild("mask/icon"):GetComponent("Image")
        icon.overrideSprite = LuaUIUtil.GetPetIcon(data.pet_id)
        local bg = item.transform:Find("bg").gameObject
        bg:GetComponent('Toggle').isOn = data == petUI.selectPetData
        item.transform:Find("light"):GetComponent('Image').color = Color.New(1,1,1,1)
        item.transform:FindChild("dark").gameObject:SetActive(false)
        local mainPet = item.transform:FindChild("mainPet").gameObject
        local vicePet = item.transform:FindChild("vicePet").gameObject
        mainPet:SetActive(false)
        vicePet:SetActive(false)
        self.AddClick(bg, function() self.UpdateSelectPetInfo(data) end)
    end
    
    local SortPetData = function(a,b)
        local aFightValue = 0
        local bFightValue = 0
        if a.fight_index and a.fight_index > 0  then aFightValue = 1 end
        if b.fight_index and b.fight_index > 0 then bFightValue = 1 end
        if aFightValue ~= bFightValue then return aFightValue > bFightValue end
        return a.pet_score > b.pet_score
    end
    
    local RefreshPetList = function()
        petDataList = {}
        local preEntityID = 0
        if petUI.selectPetData then preEntityID = petUI.selectPetData.entity_id petUI.selectPetData = nil end
        for i=1,#MyHeroManager.heroData.pet_list do
            local data = MyHeroManager.heroData.pet_list[i]
            data.index = i
            if preEntityID == data.entity_id then petUI.selectPetData = data end
            table.insert(petDataList,data)
		end
        table.sort(petDataList,SortPetData)
        if petUI.selectPetData == nil then
            petUI.selectPetData = petDataList[1]
        end
        petUI.UpdatePetList(#petDataList,UpdatePetItem)
    end
    
	self.onLoad = function()
        self.AddClick(self.view.btnAttribute, self.ShowAttribute)
        self.AddClick(self.view.btnFight, self.ChangeFightStatus )
        self.AddClick(self.view.btnRest, self.ChangeFightStatus )
        self.AddClick(self.view.btnFree, self.FreePet)
        self.AddClick(self.view.btnRename, self.Rename)
        self.AddClick(self.view.btnAddExp, self.AddExp)
        self.AddClick(self.view.btnAppearance, self.PetShow)
        self.AddClick(self.view.petScrollRect, self.ModelClick)
        DragEventListener.Get(self.view.petScrollRect).onDrag = self.ModelRotate
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        petBase = self.view.petmodel.transform:Find('@petBase')
        RefreshPetList()
        self.UpdateSelectPetInfo(petUI.selectPetData)
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_ON_REST, self.HandleOnFight)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_ON_FIGHT, self.HandleOnFight)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_FREE, self.HandleFreeMSG)
        MessageRPCManager.AddUser(self, 'PetUseExpPillRet')
	end
    
	self.onUnload = function()
        self.HideModel()
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_ON_REST, self.HandleOnFight)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_ON_FIGHT, self.HandleOnFight)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_FREE, self.HandleFreeMSG)
        MessageRPCManager.RemoveUser(self, 'PetUseExpPillRet')
        UIManager.UnloadView(ViewAssets.PetAttributeUI)
	end
    
    self.Rename = function()
        UIManager.ShowNotice('功能暂未开放')
    end
    
    self.ShowAttribute = function() 
        local ctrl = UIManager.GetCtrl(ViewAssets.PetAttributeUI)
        if ctrl.isLoaded then
            UIManager.UnloadView(ViewAssets.PetAttributeUI)
        else
            UIManager.PushView(ViewAssets.PetAttributeUI)
        end
    end
    
    self.HandleOnFight = function(data)
        self.UpdateGobalData(data)
        RefreshPetList()
        self.UpdateSelectPetInfo(petUI.selectPetData)
    end
    
    self.HandleFreeMSG = function(data)
        if data.result == 0 then 
            UIManager.ShowNotice("宠物放生")
            self.UpdateGobalData(data)
            RefreshPetList()            
            self.UpdateSelectPetInfo(petUI.selectPetData)       
        end
    end
    
    self.PetUseExpPillRet = function(data)
        if data.result == 0 then
            UIManager.ShowNotice('经验丹使用成功')
        end
    end
    
    self.UpdateGobalData = function(data)
        if data.data and data.data.pet_list ~= nil then
            MyHeroManager.heroData.pet_list = data.data.pet_list
			MyHeroManager.heroData.ban_fight_pet_list = data.data.ban_fight_pet_list
        end
        if data.data and data.data.pet_on_fight ~= nil then
            for _,v in pairs(MyHeroManager.heroData.pet_list) do
                if v.entity_id == data.data.pet_on_fight[1] then
                    v.fight_index = 1
                elseif v.entity_id == data.data.pet_on_fight[2] then
                    v.fight_index = 2
                else
                    v.fight_index = -1
                end
            end
        end
    end
    
    self.ShowPetModel = function()
        self.HideModel()
        local data = petUI.selectPetData
         LuaUIUtil.GetPetModel(data.pet_id,data.pet_appearance,function(obj)
			petModel = obj
			petModel.transform:SetParent(self.view.petmodel.transform,false)
			if data.pet_id == 7 then		--腾蛇的位置特殊处理
				petModel.transform.localPosition = Vector3.New(0,-0.646,0)
			else
				petModel.transform.localPosition = Vector3.New(0,0,0)
			end
			
			petModel.transform.localEulerAngles = Vector3.New(0,-35,0)
			petBase.transform.localEulerAngles = Vector3.New(-90,-35,0)
			local modelId = GrowingPet.Attribute[data.pet_id].ModelID
			local uiScale = artResourceScheme.Model[modelId].UI_Scale
			petModel.transform.localScale = Vector3.New(uiScale, uiScale, uiScale)
		end)
        -- local navMeshAgent = petModel:GetComponent("NavMeshAgent")
        -- if navMeshAgent then
        --     navMeshAgent.enabled = false
        -- end
        --petModel.transform:SetParent(modelParent,false)
		
    end
    
    self.HideModel = function()
        if petModel then
            -- local navMeshAgent = petModel:GetComponent("NavMeshAgent")
            -- if navMeshAgent then
            --     navMeshAgent.enabled = true
            -- end
            RecycleObject(petModel)
            petModel = nil
        end
    end
    
    self.UpdateSelectPetInfo = function(petData)
        petUI.selectPetData = petData
        self.ShowPetModel()
        self.view.petName:GetComponent("TMP_InputField").text = LuaUIUtil.GetTextByID(petConfig.Attribute[petUI.selectPetData.pet_id],'Name')
        local onFight = OnFight(petUI.selectPetData)
        self.view.btnFight:SetActive(not onFight)
        self.view.btnRest:SetActive(onFight)
        self.view.expSlider:GetComponent('Slider').value = petUI.selectPetData.pet_exp/levelExp.Level[petUI.selectPetData.pet_level].PetExp
        local ctrl = UIManager.GetCtrl(ViewAssets.PetAttributeUI)
        if ctrl.isLoaded then
            ctrl.Refresh()
        end
    end
    
    self.ChangeFightStatus = function()
        local mainData = petUI.selectPetData
        if OnFight(mainData) then
            local data = {}
            data.pet_index = petUI.selectPetData.index
            data.pet_uid = mainData.entity_id
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PET_ON_REST, data) 
        else
            if OnFightPetNum() >= 2 then
                UIManager.ShowNotice("出战宠物已经达到上限，该宠物无法出战")
                return
            end
            local data = {}
            data.pet_index = petUI.selectPetData.index
            data.pet_uid = mainData.entity_id
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PET_ON_FIGHT, data) 
        end
    end
    
    self.AddExp = function()
        UIManager.PushView(ViewAssets.PetUpgradeUI,nil,petUI.selectPetData.index)
    end
    
    self.PetShow = function()      --显示宠物外观页面
        UIManager.UnloadView(ViewAssets.PetUI)
		local petData = petUI.selectPetData
		UIManager.LoadView(ViewAssets.PetappearanceUI,nil, petData, petData.index)
	end
    
    self.FreePet = function() 
        local mainData = petUI.selectPetData
        if OnFight(mainData) then
            UIManager.ShowNotice("当前宠物出战中，无法放生")
            return
        end
        if mainData.pet_star > 50 then
            UIManager.ShowNotice("宠物星级超过50级，无法放生")
            return
        end 
        if ScoreRankHigh(mainData) then
            UIManager.ShowNotice("当前放生的宠物，评分在您的列表中过高")
            return
        end
        if OnDefend(mainData.entity_id) then
            UIManager.ShowDialog("该宠物已经在竞技场出战，是否确定放生？",'确定','取消',self.SendFreePetMsg)
            return
        end
        UIManager.ShowDialog('放生后宠物无法找回，是否放生？','确定','取消',self.SendFreePetMsg)
    end
    
    self.SendFreePetMsg = function()
        local data = {}
        data.pet_index = petUI.selectPetData.index
        data.pet_uid = petUI.selectPetData.entity_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PET_FREE , data)  
    end
    
    self.ModelRotate = function(event)
        if petModel then
            petModel.transform.localEulerAngles = Vector3.New(0,petModel.transform.localEulerAngles.y - event.delta.x/2,0) 
            petBase.localEulerAngles = Vector3.New(-90,petModel.transform.localEulerAngles.y,0)
        end
    end
    
    local showTimer = nil
    self.ModelClick = function(event)
        if petModel and not event.dragging then 
            local anim = Util.GetComponentInChildren(petModel,"Animation")
            local show = anim:GetClip('show')
            if show then
                if showTimer then Timer.Remove(showTimer) end
                showTimer = Timer.Delay(show.length,self.ResetModel)
            end
            anim:Play("show")
        end
    end
    
    self.ResetModel = function()
        if petModel then
            local anim = Util.GetComponentInChildren(petModel,"Animation")
            anim:Play("NormalStandby")
        end
        showTimer = nil
    end
    
    return self
end

return CreatePetDetailUICtrl()