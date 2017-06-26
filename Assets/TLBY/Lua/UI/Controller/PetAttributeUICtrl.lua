---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

function CreatePetAttributeUICtrl()
    local self = CreateCtrlBase()
    local petConfig = require "Logic/Scheme/growing_pet"
    self.layer = LayerGroup.popCanvas
    local petUI = nil
    
    local elements = {
        '金','木','水','火','土','风','光','暗',
    }
    
    local attributeTable = {
        {["cn"] = "初始物攻",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_physic_attack,["formular"] = 6},  
        {["cn"] = "物攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_attack_quality,["local"] = "PhyAttQuality",},
        {["cn"] = "初始物防",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_physic_defence,["formular"] = 7},
        {["cn"] = "物防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_defence_quality,["local"] = "PhyDefQuality"},
        {["cn"] = "初始法攻",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_magic_attack,["formular"] = 6},
        {["cn"] = "法攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_attack_quality,["local"] = "MagAttQuality"},
        {["cn"] = "初始法防",["tb"] = "base",["value"] = CommonDefine.BASE_NAME_TO_INDEX.base_magic_defence,["formular"] = 7},
        {["cn"] = "法防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_defence_quality,["local"] = "MagDefQuality"},    
    }
    
    local propertyTable = 
    {
        {["cn"] = "生 命 值",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.hp_max,["formular"] = 5},
        {["cn"] = "战斗力",["tb"] = "fight_power",},  
        {["cn"] = "物理攻击",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_attack,["formular"] = 6},    
        {["cn"] = "法术攻击",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_attack,["formular"] = 6},         
        {["cn"] = "物理防御",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_defence,["formular"] = 7},
        {["cn"] = "法术防御",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_defence,["formular"] = 7},
       
        -- {["cn"] = "命    中",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.hit},
        -- {["cn"] = "闪    避",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.miss},
        -- {["cn"] = "暴    击",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.crit},
        -- {["cn"] = "抗    暴",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.resist_crit},
        -- {["cn"] = "击    破",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.break_up},
        -- {["cn"] = "格    挡",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.block},    
        -- {["cn"] = "穿    刺",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.puncture},
        -- {["cn"] = "守    护",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.guardian},  
    }
    
    local UpdateAttributeItem = function(dataList,item,key)
        local index = key + 1
        local data = petUI.selectPetData
        local attributeName = item.transform:Find("name").gameObject:GetComponent("TextMeshProUGUI")
        local sliderObj = item.transform:Find("slider").gameObject
        local slider = item.transform:Find("slider/sliderImg").gameObject:GetComponent("Image")
        local sliderValue = item.transform:Find("slider/sliderValue").gameObject:GetComponent("TextMeshProUGUI")
        local number = item.transform:Find("value").gameObject:GetComponent("TextMeshProUGUI")
        attributeName.text = dataList[index].cn
        local ddd = dataList[index].value
        local value = data[dataList[index].tb]
        if ddd then
            value = data[dataList[index].tb][ddd]
        end
        local full = petConfig.Attribute[data.pet_id][dataList[index]["local"]]    
        sliderObj:SetActive(full ~= nil)
        number.gameObject:SetActive(full == nil)
        if full ~= nil then
            sliderValue.text = value.."/"..full
            slider.fillAmount = value/full
        else
            number.text = value
        end
    end
    
	self.onLoad = function()
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        self.AddClick(self.view.btnClose,self.close)
        self.view.attributeItem:SetActive(false)
        self.view.attributeScrollView:GetComponent('UIMultiScroller'):Init(self.view.attributeItem,472,47,0,7,2)
        self.view.propertyScrollView:GetComponent('UIMultiScroller'):Init(self.view.attributeItem,472,47,0,4,2)
        self.Refresh()
	end
    
    self.Refresh = function()
        local data = petUI.selectPetData
        local tableData = petConfig.Attribute[data.pet_id]
        self.view.petScore:GetComponent('TextMeshProUGUI').text = data.pet_score
        self.view.rareValue:GetComponent('TextMeshProUGUI').text = tableData.Rarity
        self.view.element:GetComponent('TextMeshProUGUI').text = elements[tableData.ElementTag]
        self.view.petSort:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(tableData,'Name')
        self.view.eatNum:GetComponent('TextMeshProUGUI').text =  data.devour_times or 0
        self.view.mergeNum:GetComponent('TextMeshProUGUI').text =  data.merge_times or 0
        self.view.level:GetComponent('TextMeshProUGUI').text = data.pet_level
        self.view.starNum:GetComponent('TextMeshProUGUI').text = data.pet_star
        self.view.attributeScrollView:GetComponent('UIMultiScroller'):UpdateData(#propertyTable,function(item,key) UpdateAttributeItem(propertyTable,item,key) end)
        self.view.propertyScrollView:GetComponent('UIMultiScroller'):UpdateData(#attributeTable,function(item,key) UpdateAttributeItem(attributeTable,item,key) end)
    end
    
	self.onUnload = function()

	end
    
    return self
end

return CreatePetAttributeUICtrl()