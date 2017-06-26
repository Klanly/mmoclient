---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

function CreatePetMergeEatAttributeUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
            
    local petConfig = require "Logic/Scheme/growing_pet" 
    local commonParam = require "Logic/Scheme/common_parameter_formula"
    local CommonDefine = require "Common/constant"
    local petUI = nil
    local viceData = nil
    local attributePreviewDataList = {}
    
    local attributeMergeTable = {     
        {["cn"] = "物攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_attack_quality,["local"] = "PhyAttQuality"},
        {["cn"] = "法攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_attack_quality,["local"] = "MagAttQuality"},
        {["cn"] = "物防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_defence_quality,["local"] = "PhyDefQuality"},
        {["cn"] = "法防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_defence_quality,["local"] = "MagDefQuality"},
        {["cn"] = "初始物攻",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_physic_attack,},  
        {["cn"] = "初始法攻",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_magic_attack,},
        {["cn"] = "初始物防",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_physic_defence,}, 
        {["cn"] = "初始法防",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_magic_defence,},
    }
    
    local attributeEatTable = {
        {["cn"] = "生命资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality,["local"] = "HpQuality"}, 
        {["cn"] = "生 命 值",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.hp_max,["formular"] = 7}, 
    }
    
    local CalPetAttribute = function(id,base,quality,level)
        if id == nil then
            return base
        end
        local formula_str = commonParam.Formula[id].Formula     
        formula_str =  "return function (a, b,c) return "..formula_str.." end"
        return loadstring(formula_str)()(base,level,quality)
    end
    
    local HpQualityChange = function()
        local devour = petConfig.Devour
        local mainDevourData = devour[1]
        local secondDevourData = devour[1]
        local hpGrowTable = petConfig.HpGrow
        local mainHpGrow = hpGrowTable[1]
        local mainData = petUI.selectPetData
        local rate = mainData.quality[CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality] / petConfig.Attribute[mainData.pet_id].HpQuality
        
        for i = 1,#devour do
            if(rate < devour[i].StarLv/100) then
                break
            end      
            mainDevourData = devour[i]       
        end
        for i = 1,#devour do
            if(viceData.pet_star < devour[i].NeedStarLv) then
                break
            end      
            secondDevourData = devour[i]       
        end
        local coefficient = (secondDevourData.Coefficient - mainDevourData.Coefficient)/100
        for i = 1,#hpGrowTable do
            if(rate < hpGrowTable[i].HpLower/100) then
                break
            end      
            mainHpGrow = hpGrowTable[i]       
        end
        return petConfig.Attribute[mainData.pet_id].HpQuality*(mainHpGrow.HpAdvance/10000*0.8*(1+coefficient)/100 + rate) ,petConfig.Attribute[mainData.pet_id].HpQuality*(mainHpGrow.HpAdvance/10000*1.2*(1+coefficient)/100 + rate) 
    end
    
    local BaseHp = function()
        local mainData = petUI.selectPetData
        local currentBase = mainData.base[CommonDefine.PROPERTY_NAME_TO_INDEX.hp_max]
        local full = petConfig.Attribute[mainData.pet_id].Hp
        local nextBase = currentBase + commonParam.Parameter[19].Parameter
        if currentBase + commonParam.Parameter[19].Parameter > full then
            return full,full
        end
        if currentBase + commonParam.Parameter[20].Parameter > full then
            return commonParam.Parameter[19].Parameter + currentBase,full
        end
        return commonParam.Parameter[19].Parameter+ currentBase , commonParam.Parameter[20].Parameter+ currentBase
    end
    
    local ConstructAttributeMergeData = function(index)
        local mainData = petUI.selectPetData
        local data = {}
        data.des = attributeMergeTable[index].cn
        data.mainValue = mainData[attributeMergeTable[index].tb][attributeMergeTable[index].value] or 0
        if viceData then
            data.viceValue = viceData[attributeMergeTable[index].tb][attributeMergeTable[index].value] or 0
            local full = petConfig.Attribute[mainData.pet_id][attributeMergeTable[index]["local"]]
            if full == nil then
                local mainBase = mainData.base[attributeMergeTable[index].value] or 0
                local secondBase = viceData.base[attributeMergeTable[index].value] or 0
                local newValue = secondBase
                if secondBase > mainBase then           
                    newValue = mainBase + (secondBase - mainBase)*(commonParam.Parameter[18].Parameter/100)
                end                
                local improve = math.ceil(secondBase - newValue)
                if improve > 0 then
                    data.improve = improve
                end
            else
                local improve = math.ceil((commonParam.Parameter[18].Parameter/100)*(data.viceValue - data.mainValue))
                if improve > 0 then
                    data.improve = improve
                end
            end
        end
        return data
    end
    
    local ConstructAttributeEatData = function(index)
        local mainData = petUI.selectPetData
        local data = {}
        data.des = attributeEatTable[index].cn
        data.mainValue = mainData[attributeEatTable[index].tb][attributeEatTable[index].value] or 0
        if viceData then     
            data.viceValue = viceData[attributeEatTable[index].tb][attributeEatTable[index].value] or 0
            if index == 1 then
                local a,b = HpQualityChange()
                local currentHpQuality = mainData.quality[CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality]  
                local max = math.ceil(b - currentHpQuality)
                local min = math.ceil(a - currentHpQuality)   
                if max == min then
                    data.improve = min
                else
                    data.improve = min.."-"..max
                end
            elseif index == 2 then
                local a,b = BaseHp()
                local x,y = HpQualityChange()
                local currentHp = mainData.property[CommonDefine.PROPERTY_NAME_TO_INDEX.hp_max]
              
                local max = CalPetAttribute(attributeEatTable[index].formular,b,y,mainData.pet_level) - currentHp         
                local min = CalPetAttribute(attributeEatTable[index].formular,a,x,mainData.pet_level) - currentHp 
                if max == min then
                    data.improve = min
                else
                    data.improve = min.."-"..max
                end
            end
        end
        
        return data
    end
    
    local UpdateAttributePreview = function(item,index)
        local data = attributePreviewDataList[index+1]
        local attributeName = item.transform:FindChild("name"):GetComponent("TextMeshProUGUI")
        local viceAttributeName = item.transform:FindChild("name1"):GetComponent("TextMeshProUGUI")
        local current = item.transform:FindChild("valueMain"):GetComponent("TextMeshProUGUI")
        local viceCurrent = item.transform:FindChild("valueVice"):GetComponent("TextMeshProUGUI")
        local dotVice = item.transform:FindChild("dot1").gameObject
        local improve = item.transform:FindChild("improve"):GetComponent("TextMeshProUGUI")
        attributeName.text = data.des
        current.text = data.mainValue
        viceAttributeName.text = ""
        viceCurrent.text = ""      
        improve.gameObject:SetActive(false)
        dotVice.gameObject:SetActive(data.viceValue~=nil)
        if data.viceValue then
            viceAttributeName.text = data.des
            viceCurrent.text = data.viceValue
            if data.improve then
                improve.text = data.improve
                improve.gameObject:SetActive(true)
            end  
        end
    end
    
	self.onLoad = function(eatPage,vice)
        self.AddClick(self.view.btnClose,self.close)
        self.view.attributeScrollView:GetComponent(typeof(UIMultiScroller)):Init(self.view.attributeItem, 453, 50, 0, 8, 1)
        self.view.attributeItem:SetActive(false)
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        self.Refresh(eatPage,vice)
	end
    
    self.Refresh = function(eatPage,vice)
        viceData = vice
        attributePreviewDataList = {}
        if eatPage ~= true then
            for i=1,#attributeMergeTable do
                local itemData = ConstructAttributeMergeData(i)
                table.insert(attributePreviewDataList,itemData)
            end
        else
            attributePreviewDataList[1] = ConstructAttributeEatData(1)
            attributePreviewDataList[2] = ConstructAttributeEatData(2)
        end
        self.view.attributeScrollView:GetComponent(typeof(UIMultiScroller)):UpdateData(#attributePreviewDataList,UpdateAttributePreview)
    end
    
	self.onUnload = function()

	end
    
    return self
end

return CreatePetMergeEatAttributeUICtrl()