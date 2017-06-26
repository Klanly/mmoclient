---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreatePetImproveUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    
    local listData = nil
    local numberTimer = nil
    local delayTimer = nil
    local attributeTable = {
        {["cn"] = "生 命 值",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.hp_max,["formular"] = 5},
        {["cn"] = "生命资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.hp_max_quality,["local"] = "HpQuality",},         
        {["cn"] = "物理攻击",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_attack,["formular"] = 6},  
        {["cn"] = "物攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_attack_quality,["local"] = "PhyAttQuality",},
        {["cn"] = "物理防御",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.physic_defence,["formular"] = 7},
        {["cn"] = "物防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.physic_defence_quality,["local"] = "PhyDefQuality"},
        {["cn"] = "魔法攻击",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_attack,["formular"] = 6},
        {["cn"] = "法攻资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_attack_quality,["local"] = "MagAttQuality"},
        {["cn"] = "魔法防御",["tb"] = "property",["value"] = CommonDefine.PROPERTY_NAME_TO_INDEX.magic_defence,["formular"] = 7},
        {["cn"] = "法防资质",["tb"] = "quality",["value"] = CommonDefine.QUALITY_NAME_TO_INDEX.magic_defence_quality,["local"] = "MagDefQuality"},    
    }
    
    local UpdateItem = function(item,index)
        local data = listData[index+1]
        item.transform:FindChild('pre'):GetComponent('TextMeshProUGUI').text = data.pre
        local after = math.ceil(data.show)
        if after > data.after then
            after = data.after
        end
        item.transform:FindChild('next'):GetComponent('TextMeshProUGUI').text = after
        item.transform:FindChild('attributeName'):GetComponent('TextMeshProUGUI').text = data.name
    end

    self.onLoad = function(preData,afterData)       
        self.AddClick(self.view.btnClose,self.close)
        local starChange = afterData.pet_star > preData.pet_star
        self.view.starUpgrade:SetActive(starChange)
        self.view.scoreUp:SetActive(not starChange)
        self.view.starEffect:SetActive(false)
        local scrollViewRect = self.view.scrollView:GetComponent('RectTransform')
        if starChange then
            scrollViewRect.anchorPosition = Vector2.New(0,-109.7)
            scrollViewRect.sizeDelta = Vector2.New(560.1,411.6)
            self.view.scoreLowPre:GetComponent('TextMeshProUGUI').text = preData.pet_score
            self.view.scoreLowNext:GetComponent('TextMeshProUGUI').text = afterData.pet_score
            self.view.starNum:GetComponent('TextMeshProUGUI').text = ''
            
            delayTimer = Timer.Delay( 2.5, function()
                self.view.starNum:GetComponent('TextMeshProUGUI').text = afterData.pet_star
                self.view.starEffect:SetActive(true)
            end)
            
        else
            scrollViewRect.anchorPosition = Vector2.New(0,-84.4)
            scrollViewRect.sizeDelta = Vector2.New(560.1,464.8)
            self.view.scoreUpPre:GetComponent('TextMeshProUGUI').text = preData.pet_score
            self.view.scoreUpNext:GetComponent('TextMeshProUGUI').text = afterData.pet_score
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.attributeItem,605,80,0,9,1)
        
        listData = {}
        for i=1,#attributeTable do
            local pre = preData[attributeTable[i].tb][attributeTable[i].value] 
            local after = afterData[attributeTable[i].tb][attributeTable[i].value]
            if after > pre then
                local t = {}
                t.name = attributeTable[i].cn
                t.pre = pre
                t.show = pre
                t.after = after
                table.insert(listData,t)
            end
        end
        
        local count = 0
        local showScore = preData.pet_score
        
        numberTimer = Timer.Numberal(0.05,40,function()
            for i=1,#listData do
                listData[i].show = listData[i].show + (listData[i].after - listData[i].pre)/40
                if listData[i].show > listData[i].after then
                    listData[i].show = listData[i].after
                end
            end
            self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#listData,UpdateItem)
            
            showScore = showScore + (afterData.pet_score - preData.pet_score)/40
            local after = math.floor(showScore)
            if after > afterData.pet_score then
                after = afterData.pet_score
            end
            if starChange then
                self.view.scoreLowNext:GetComponent('TextMeshProUGUI').text = after
            else
                self.view.scoreUpNext:GetComponent('TextMeshProUGUI').text = after
            end
            
            count = count + 1
            if count == 40 then
                numberTimer = nil
            end
		end)
        
        self.view.attributeItem:SetActive(false)
    end
	
	self.onUnload = function()
        if numberTimer then
            Timer.Remove(numberTimer)
            numberTimer = nil
        end
        if delayTimer then
            Timer.Remove(delayTimer)
            delayTimer = nil
        end
	end
    
	return self
end

return CreatePetImproveUICtrl()