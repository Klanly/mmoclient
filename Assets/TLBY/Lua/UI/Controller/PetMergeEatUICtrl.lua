---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

function CreatePetMergeEatUICtrl()
    local self = CreateCtrlBase()
    local petDataList = {}
    local eatReasonList = {}
    local mergeReasonList = {}
    local petUI = nil
    local mainPetModel = nil
    local vicePetModel = nil
    local vicePetData = nil
    local eatPage = false
    local petConfig = require "Logic/Scheme/growing_pet"
    local mainPetToggle = nil
    local vicePetToggle = nil
    
    local attributeMergeTable = {     
        {["cn"] = "物攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_attack_quality,["local"] = "PhyAttQuality"},
        {["cn"] = "法攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_attack_quality,["local"] = "MagAttQuality"},
        {["cn"] = "物防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_defence_quality,["local"] = "PhyDefQuality"},
        {["cn"] = "法防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_defence_quality,["local"] = "MagDefQuality"},
        {["cn"] = "初始物攻",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_attack,["formular"] = 6},  
        {["cn"] = "初始法攻",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_attack,["formular"] = 6},
        {["cn"] = "初始物防",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_defence,["formular"] = 7}, 
        {["cn"] = "初始法防",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_defence,["formular"] = 7},
    }
    
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
    
    local SuitForEat = function(data)
        local mainData = petUI.selectPetData
        if mainData == data then
            return ''
        end
        if OnFight(data) then
            return '出战中' 
        end
        if data.pet_star >= 100 then 
            return '星级过高' 
        end
    
        local devour = petConfig.Devour
        local currentData = devour[1]
        local rate = mainData.quality[CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality] / petConfig.Attribute[mainData.pet_id].HpQuality
        for i = 1,#devour do
            if(rate < devour[i].StarLv/100) then
                break
            end      
            currentData = devour[i]       
        end
        if data.pet_star < currentData.NeedStarLv then
            return '星级不足'
        end
        if data.pet_level < currentData.NeedLv then
            return '等级不足'
        end
    end
    
    local FormatNeedPetStr = function()
        if not eatPage then return '' end
        if vicePetData ~= nil then return '' end
        local mainData = petUI.selectPetData
        if not mainData then return '' end
        local devour = petConfig.Devour
        local rate = mainData.quality[CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality] / petConfig.Attribute[mainData.pet_id].HpQuality
        local currentData = devour[1]
        for i = 1,#devour do
            if(rate < devour[i].StarLv/100) then
                break
            end      
            currentData = devour[i]       
        end
        return string.format('%d星%d级以上副宠',currentData.NeedStarLv,currentData.NeedLv)
    end
           
    local SuitForMerge = function(data)
        local main = petUI.selectPetData
        if data == main then
            return ''
        end
        if OnFight(data) then
            return '出战中' 
        end
        if data.pet_star >= 100 then
            return '星级过高' 
        end
        if data.pet_id ~=  main.pet_id then
            return '不同宠物类型'
        end

        for i=1,#attributeMergeTable do
            if attributeMergeTable[i].tb == 'quality' then
                local attributeId = attributeMergeTable[i].value
                if main.base[attributeId] < data.base[attributeId] or main.quality[attributeId] < data.quality[attributeId] then
                    return nil
                end
            end
        end
        return '属性低于主宠'
    end
    
    local UpdateAttributeItem = function(item,key)
        local index = key + 1
        local data = petUI.selectPetData
        local attributeName = item.transform:Find("name").gameObject:GetComponent("TextMeshProUGUI")
        local sliderObj = item.transform:Find("slider").gameObject
        local slider = item.transform:Find("slider/sliderImg").gameObject:GetComponent("Image")
        local sliderValue = item.transform:Find("slider/sliderValue").gameObject:GetComponent("TextMeshProUGUI")
        local number = item.transform:Find("value").gameObject:GetComponent("TextMeshProUGUI")
        attributeName.text = attributeTable[index].cn
        local value = data[attributeTable[index].tb][attributeTable[index].value] or 0       
        local full = petConfig.Attribute[data.pet_id][attributeTable[index]["local"]]    
        sliderObj:SetActive(full ~= nil)
        number.gameObject:SetActive(full == nil)
        if full ~= nil then
            sliderValue.text = value.."/"..full
            slider.fillAmount = value/full
        else
            number.text = value
        end
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

        local onFightFlag = item.transform:Find("onFight").gameObject
        onFightFlag:SetActive(OnFight(data))
        local name = item.transform:Find("name").gameObject:GetComponent("TextMeshProUGUI")
        name.text = LuaUIUtil.GetPetName(data.pet_id)
        local starLv = item.transform:Find("star").gameObject:GetComponent("TextMeshProUGUI")
        starLv.text = data.pet_star
        local petLv = item.transform:Find("level").gameObject:GetComponent("TextMeshProUGUI")
        petLv.text = data.pet_level..'级'
        local icon = item.transform:Find("mask/icon"):GetComponent("Image")
        icon.overrideSprite = LuaUIUtil.GetPetIcon(data.pet_id)
        
        local dark = item.transform:Find("dark").gameObject
        dark:SetActive((eatPage and eatReasonList[data.entity_id])~=nil or (not eatPage and mergeReasonList[data.entity_id]~=nil) or data == vicePetData or data == petUI.selectPetData) 
        item.transform:Find('dark/reasonBg').gameObject:SetActive(eatReasonList[data.entity_id] ~= '' or mergeReasonList[data.entity_id] ~= '')
        item.transform:Find('dark/textReason'):GetComponent('TextMeshProUGUI').text = (eatPage and eatReasonList[data.entity_id]) or mergeReasonList[data.entity_id]
        local mainPet = item.transform:Find("mainPet").gameObject
        local vicePet = item.transform:Find("vicePet").gameObject
        mainPet:SetActive(data == petUI.selectPetData)
        vicePet:SetActive(data == vicePetData)
        local bg = item.transform:Find("bg").gameObject
        item.transform:Find("light"):GetComponent('Image').color = Color.New(1,1,1,0)
        self.AddClick(bg, function() self.UpdateSelectPetInfo(data) end)
        bg:GetComponent('Image').raycastTarget = not dark.activeSelf   
    end
    
    local SortPetData = function(a,b)
        local aFightValue = 0
        local bFightValue = 0
        if a.fight_index and a.fight_index > 0  then aFightValue = 1 end
        if b.fight_index and b.fight_index > 0 then bFightValue = 1 end
        if aFightValue ~= bFightValue then return aFightValue > bFightValue end
        return a.pet_score > b.pet_score
    end
    
    local RefreshPetDataList = function()
        petDataList = {}
        mergeReasonList = {}
        eatReasonList = {}
        for i=1,#MyHeroManager.heroData.pet_list do
            local data = MyHeroManager.heroData.pet_list[i]
            if petUI.selectPetData and petUI.selectPetData.entity_id == data.entity_id then petUI.selectPetData = data end
            if vicePetData and vicePetData.entity_id == data.entity_id then vicePetData = data end
            table.insert(petDataList,MyHeroManager.heroData.pet_list[i])
            if not eatPage and vicePetToggle.isOn then mergeReasonList[data.entity_id] = SuitForMerge(data) end
            if eatPage and vicePetToggle.isOn then eatReasonList[data.entity_id] = SuitForEat(data) end
		end
        if eatPage and vicePetToggle.isOn then
			for i=1,#MyHeroManager.heroData.ban_fight_pet_list do
                local data = MyHeroManager.heroData.ban_fight_pet_list[i]
                if vicePetData and vicePetData.entity_id == data.entity_id then vicePetData = data end
				table.insert(petDataList,data)
                data.banFight = true
                eatReasonList[data.entity_id] = SuitForEat(data)  
			end
		end
        table.sort(petDataList,SortPetData)
        if petUI.selectPetData == nil then
            petUI.selectPetData = petDataList[1]
        end
    end
    
    local RefreshScrollView = function()
        petUI.UpdatePetList(#petDataList,UpdatePetItem)
        --petUI.view.scrollView:GetComponent("ScrollRect").vertical = #petDataList > 6
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
    
    local RefreshMainInfo = function() 
        local data = petUI.selectPetData
        self.view.mainPetStar:GetComponent("TextMeshProUGUI").text = data.pet_star.."星   "..(data.pet_level or 1).."级"
        self.view.textMainName:GetComponent("TextMeshProUGUI").text = LuaUIUtil.GetTextByID(petConfig.Attribute[data.pet_id],'Name')
        self.view.vicePart:SetActive(vicePetData ~= nil)
        self.view.viceNeedStr:GetComponent('TextMeshProUGUI').text = FormatNeedPetStr()
        self.view.btnAdd:SetActive(vicePetData == nil)
        if vicePetData then    
            self.view.vicePetStar:GetComponent("TextMeshProUGUI").text = vicePetData.pet_star.."星   "..(vicePetData.pet_level or 1).."级"
            self.view.textViceName:GetComponent("TextMeshProUGUI").text = LuaUIUtil.GetTextByID(petConfig.Attribute[vicePetData.pet_id],'Name')
        end
        self.ShowPetModel()
        local ctrl = UIManager.GetCtrl(ViewAssets.PetMergeEatAttributeUI)
        if ctrl.isLoaded then
            ctrl.Refresh(eatPage,vicePetData)
        end        
    end 
    
	self.onLoad = function(eat)
        eatPage = eat
        self.view.eatPart:SetActive(eat)
        self.view.mergePart:SetActive(not eat)
        vicePetData = nil
        mainPetToggle = self.view.btnMainPet:GetComponent('Toggle')
        vicePetToggle = self.view.btnVicePet:GetComponent('Toggle')
        mainPetToggle.isOn = true
        self.AddClick(self.view.btnVicePet, self.SelectVice)
        self.AddClick(self.view.btnMainPet, self.SelectMain)
        self.AddClick(self.view.btnAttribute, self.ShowAttribute)
        self.AddClick(self.view.btnMerge, self.SendMSGClick)
        self.AddClick(self.view.btnEat, self.SendMSGClick)
        if eatPage then
            UIManager.AddHelpTip(self, 1220)
        else
            UIManager.AddHelpTip(self, 1230)
        end
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        
        RefreshPetDataList()
        self.UpdateSelectPetInfo(petUI.selectPetData)
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_DEVOUR, self.HandleMSG)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PET_MERGE , self.HandleMSG)
	end
    
	self.onUnload = function()
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_PET_DEVOUR, self.HandleMSG)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_PET_MERGE, self.HandleMSG)
        
        UIManager.UnloadView(ViewAssets.PetMergeEatAttributeUI)
        self.HideModel()
	end
    
    self.SendMSGClick = function()
        local mainData = petUI.selectPetData
        if not vicePetData then
            UIManager.ShowNotice('请选择副宠')
            return
        end
        if not eatPage then
            if OnDefend(vicePetData.entity_id) then
                UIManager.ShowDialog("该宠物已经在竞技场出战，是否确定融合？",'确定','取消',self.SendMSG)
                return
            end
            if vicePetData.pet_star > mainData.pet_star then
                UIManager.ShowDialog("副宠星级高于主宠星级，是否确定融合？",'确定','取消',self.SendMSG)
                return
            end     
        else
            if OnDefend(vicePetData.entity_id) then
                UIManager.ShowDialog("该宠物已经在竞技场出战，是否确定吞噬？",'确定','取消',self.SendMSG)
                return
            end
            if vicePetData.pet_star > mainData.pet_star then
                UIManager.ShowDialog("副宠星级高于主宠星级，是否确定吞噬？",'确定','取消',self.SendMSG)
                return
            end
    
            local devour = petConfig.Devour
            local currentData = devour[1]
            local rate = mainData.quality[CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality] / petConfig.Attribute[mainData.pet_id].HpQuality
            for i = 1,#devour do
                if(rate < devour[i].StarLv/100) then
                    break
                end      
                currentData = devour[i]       
            end
            if vicePetData.pet_star - currentData.NeedStarLv > 20 then
                UIManager.ShowDialog("副宠物星级过高，确定要吞噬吗？",'确定','取消',self.SendMSG)
                return
            end
        end
        self.SendMSG()
    end
    
    local preData = nil
    self.SendMSG = function()
		local data = {}
        preData = petUI.selectPetData
		data.main_index = preData.index
        data.main_uid = preData.entity_id
		data.assist_index = vicePetData.index
        data.assist_uid = vicePetData.entity_id
        if not eatPage then
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PET_MERGE, data)        
        else
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PET_DEVOUR, data)
        end
	end
    
    self.HandleMSG = function(data)
        if data.result == 0 then 
            self.DelectPetInDataList(data)
            RefreshScrollView()
            RefreshMainInfo()
            self.ShowPetImprovePanel()
        end
    end
    
    self.ShowPetImprovePanel = function()
        for k,v in pairs(MyHeroManager.heroData.pet_list) do
            if v.entity_id == preData.entity_id then
                UIManager.PushView(ViewAssets.PetImproveUI,nil,preData,v)
                return
            end
        end
    end
    
    self.DelectPetInDataList = function(data)     --保持宠物列表的顺序 
        if data.result == 0 then
            self.UpdateGlobalData(data)
            
            for i=#petDataList,1,-1 do
                local delected = true
                if petDataList[i].banFight then
                    for k,v in pairs(MyHeroManager.heroData.ban_fight_pet_list) do
                        if v.entity_id == petDataList[i].entity_id then
                            delected = false
                            petDataList[i] = v
                            petDataList[i].index = k
                            break
                        end
                    end  
                else
                    for k,v in pairs(MyHeroManager.heroData.pet_list) do
                        if v.entity_id == petDataList[i].entity_id then
                            delected = false
                            petDataList[i] = v
                            petDataList[i].index = k
                            break
                        end
                    end
                end
                if delected then
                    table.remove(petDataList, i)
                end             
            end

            for i=1,#petDataList do
                if petDataList[i].entity_id == preData.entity_id then
                    petUI.selectPetData = petDataList[i]
                    break
                end          
            end
            vicePetData = nil
        end
    end
    
    self.UpdateGlobalData = function(data)
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
        local CreatePet = function(id,appearance,pos,func)
             LuaUIUtil.GetPetModel(id,appearance,function(obj)
				local model = obj
				model.transform:SetParent(pos,false)
                model.transform.localPosition = Vector3.New(0,0,0)
                model.transform.localEulerAngles = Vector3.New(0,-35,0)
				func(obj)
			end)
			
            -- local navMeshAgent = model:GetComponent("NavMeshAgent")
            -- if navMeshAgent then
            --     navMeshAgent.enabled = false
            -- end
            
            return model
        end
        self.HideModel()
        CreatePet(petUI.selectPetData.pet_id,petUI.selectPetData.pet_appearance,self.view.mainPetModel.transform,function(obj)
		   mainPetModel = obj
		end)
        if vicePetData then  CreatePet(vicePetData.pet_id,vicePetData.pet_appearance,self.view.vicePetModel.transform,function(obj)
			vicePetModel = obj
		end) end
    end
    
    self.HideModel = function()
        local HandleModel = function(model)
            if model then
                -- local navMeshAgent = model:GetComponent("NavMeshAgent")
                -- if navMeshAgent then
                --     navMeshAgent.enabled = true
                -- end
                RecycleObject(model)
            end
        end
        HandleModel(mainPetModel)
        HandleModel(vicePetModel)
        mainPetModel = nil
        vicePetModel = nil
    end
    
    self.ShowAttribute = function()
        local ctrl = UIManager.GetCtrl(ViewAssets.PetMergeEatAttributeUI)
        if ctrl.isLoaded then
            UIManager.UnloadView(ViewAssets.PetMergeEatAttributeUI)
        else
            UIManager.PushView(ViewAssets.PetMergeEatAttributeUI,nil,eatPage,vicePetData)
        end
    end
    
    self.SelectVice = function()
        vicePetToggle.isOn = true
        RefreshPetDataList()
        RefreshScrollView()
    end
    
    self.SelectMain = function()
        mainPetToggle.isOn = true
        RefreshPetDataList()
        RefreshScrollView()
    end

    self.UpdateSelectPetInfo = function(data)
        if mainPetToggle.isOn then 
            petUI.selectPetData = data
            vicePetData = nil
        else
            if data.banFight ~= true then
                if #MyHeroManager.heroData.pet_list < 3 then
                    UIManager.ShowDialog(
                    "宠物总数不可以少于2个，无法选择宠物。是去商城购买宠物？",
                    '确定','取消',
                    function() UIManager.UnloadView(ViewAssets.PetUI) UIManager.GetCtrl(ViewAssets.MallUI).OpenUI() end)
                    return
                end
            end
            vicePetData = data
        end
        RefreshPetDataList()
        RefreshScrollView()   
        RefreshMainInfo()
    end


    return self
end

return CreatePetMergeEatUICtrl()