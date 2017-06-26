---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateEquipGemHandleUICtrl()
    local self = CreateCtrlBase()
    
    local itemTable = require "Logic/Scheme/common_item"
    local gemTable = require "Logic/Scheme/equipment_jewel"
    local const = require "Common/constant"
        
    local currentTabIndex = 1
    local initPolish = true
    local polishIndex = 0
    local composeIndexs = {}
    local itemList = {}
    local tweens = {}
    local timer = nil
    local timer1 = nil
    local timer2 = nil
    
    local Close = function()
        UIManager.UnloadView(ViewAssets.EquipGemHandleUI)
    end
    
    local GetIdByIndex = function(index)
        local ids = BagManager.GetItemIdsByType(const.TYPE_GEM)
        local count = index
        for i=1,#ids do
            count = count - BagManager.GetItemNumberById(ids[i])
            if count < 0 then
                return ids[i]
            end
        end
    end
    
    local UpdateItem = function(obj,index)
        local icon = obj.transform:FindChild('icon'):GetComponent('Image')
        local bg = obj.transform:FindChild('selectPos')
        local num = obj.transform:FindChild('num'):GetComponent('TextMeshProUGUI')
        local dark = obj.transform:FindChild('dark').gameObject
        local quality = obj.transform:FindChild('quality'):GetComponent('Image')
        
        if index+1 > #itemList then 
            obj:SetActive(false)
            return 
        else
            obj:SetActive(true)
        end
        local id  = itemList[index+1].id

        quality.overrideSprite = LuaUIUtil.GetItemQuality(id)
        num.text = itemList[index+1].count
        local use = false
        for i=0,#composeIndexs do
            if composeIndexs[i] == index+1 then
                use = true
            end
        end
        if index == 0 and initPolish and currentTabIndex == 2 then
            self.view.select.transform:SetParent(bg,false)
            initPolish = false
        end
        dark:SetActive(currentTabIndex == 1 and use)
        icon.overrideSprite = LuaUIUtil.GetItemIcon(id)
        if currentTabIndex == 1 then
            self.AddClick(icon.gameObject,function() self.ClickGemItem(index+1,bg) end)          
        elseif currentTabIndex == 2 then
            self.AddClick(icon.gameObject,function() self.view.select.transform:SetParent(bg,false) self.RefreshPolishPage(index + 1) end)
        end
    end
    
    local RefreshGemDataList = function()
        itemList = {}
        for k,v in pairs(BagManager.items) do    
            if v ~= nil  and itemTable.Item[v.id].Type == const.TYPE_GEM then
                local itemdata = {pos = k,id = v.id,count = v.count}
                table.insert(itemList,itemdata)
            end
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#itemList,UpdateItem)      
    end
    
    local RefreshComposeDataList = function()
        itemList = {}
        for k,v in pairs(BagManager.items) do    
            if v ~= nil  and itemTable.Item[v.id].Type == const.TYPE_GEM then
                local itemdata = {pos = k,id = v.id,count = v.count,cost = 3}
                table.insert(itemList,itemdata)
            elseif v~= nil then
                for _,syn in pairs(itemTable.Synthesis) do
                    if syn.ID == v.id then
                        local itemdata = {pos = k,id = v.id,count = v.count,cost = syn.number,complex = syn.complex}
                        table.insert(itemList,itemdata)
                    end
                end 
            end
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#itemList,UpdateItem)
    end
    
    local ShowComposePage = function()
        currentTabIndex = 1
        UIManager.AddHelpTip(self, 1171)
        self.ResetComposeEffect()
        self.view.tabLight.transform.position = self.view.tab1.transform.position
        self.view.bgpaginright1:SetActive(true)
        self.view.bgpaginright2:SetActive(false)
        self.AddClick(self.view.btnCompose,self.SendCompose)
        self.view.select:SetActive(false)
        self.view.selectEffect:SetActive(false)
        RefreshComposeDataList()
        composeIndexs = {}
        self.RefreshComposePage()
    end
    
    local ShowPolishPage = function()
        currentTabIndex = 2
        self.ResetPolishEffect()
        self.view.tabLight.transform.position = self.view.tab2.transform.position
        self.view.bgpaginright1:SetActive(false)
        self.view.bgpaginright2:SetActive(true)
        self.AddClick(self.view.btnPolish,self.SendPolish)
        self.view.select:SetActive(true)
        initPolish = true
        RefreshGemDataList()
        self.RefreshPolishPage(1) 
    end
    
    local cacheParent = nil
    self.onLoad = function(tab)
        cacheParent = self.view.select.transform.parent
        self.view.item:SetActive(true)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.item,133,133,0,7,4)
        self.view.item:SetActive(false)
        if tab == 2 then
            ShowPolishPage()
        else
            ShowComposePage()
        end    
        self.AddClick(self.view.tab1,function() if currentTabIndex ~= 1 then ShowComposePage() end end)
        self.AddClick(self.view.tab2,function() if currentTabIndex ~= 2 then ShowPolishPage() end end)
        self.AddClick(self.view.btnClose,Close)
        
        for i=1,4 do
            self.AddClick(self.view['addIcon'..i],function() self.ClickAddedGem(i,self.view['addIcon'..i].transform.position) end)
        end
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_CARVE, self.PolishEffectPlay)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GEM_COMBINE, self.ComposeEffectPlay)
        --self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-200)
    end
    
    self.onUnload = function()
        self.view.select.transform:SetParent(cacheParent,false)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GEM_CARVE, self.PolishEffectPlay)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GEM_COMBINE, self.ComposeEffectPlay)
        for i=1,4 do
            if not IsNil(tweens[i]) then
                tweens[i]:Clear()
            end
        end
        tweens = {}
        if timer then Timer.Remove(timer) timer = nil end
    end
    
    self.Reload = function()
        if not self.isLoaded then return end

        if self.view.bgpaginright2.activeSelf then
            RefreshGemDataList()
            self.RefreshPolishPage(polishIndex)
        elseif self.view.bgpaginright1.activeSelf then
            RefreshComposeDataList()
            self.RefreshComposePage()
        end  
    end
    
    self.PolishEffectPlay = function(data)
        if data.result == 0 then
            self.view.effectPolish:SetActive(true)
            if timer2 then Timer.Remove(timer2) timer2 = nil end
            timer2 = Timer.Delay(0.5,function() self.view.effectSuccess:SetActive(true) end)
        end
    end
    
    self.ResetPolishEffect = function()
        self.view.effectPolish:SetActive(false)
        self.view.effectSuccess:SetActive(false)
        if timer2 then Timer.Remove(timer2) timer2 = nil end
    end

    self.ComposeEffectPlay = function(data)
        if data.result ~=0 then return end
        
        self.view.composeEffect:SetActive(true)
        self.view.centerIcon:SetActive(false)
        self.view.centerIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.new_gem_id)
        for i=1,4 do
            if not IsNil(tweens[i]) then
                tweens[i]:Clear()
            end
            self.view['animIcon'..i]:GetComponent('Image').overrideSprite = self.view['addIcon'..i]:GetComponent('Image').overrideSprite
            self.view['animIcon'..i]:GetComponent('RectTransform').anchoredPosition = self.view['add'..i]:GetComponent('RectTransform').anchoredPosition
            tweens[i] = BETween.anchoredPosition(self.view['animIcon'..i],1.6,self.view['add'..i]:GetComponent('RectTransform').anchoredPosition,self.view.centerIcon:GetComponent('RectTransform').anchoredPosition)
            self.view['animIcon'..i]:SetActive(self.view['addIcon'..i].activeSelf)
        end
        if timer then Timer.Remove(timer) timer = nil end
        timer = Timer.Delay(2,self.ShowComposeItem,self)
    end
    
    self.ShowComposeItem = function()
        timer = nil
        self.view.centerIcon:SetActive(true)
        for i=1,4 do
            self.view['animIcon'..i]:SetActive(false)
        end
        self.view.centerIcon:SetActive(true)
        if timer1 then Timer.Remove(timer1) timer1 = nil end
        timer1 = Timer.Delay(1,self.ResetComposeEffect,self)
    end
    
    self.ResetComposeEffect = function()
        timer1 = nil
        if timer then Timer.Remove(timer) timer = nil end
        if timer1 then Timer.Remove(timer1) timer1 = nil end
        self.view.composeEffect:SetActive(false)
    end
    
    self.ClickGemItem = function(index,bg)
        local id = itemList[index].id
        self.view.select:SetActive(true) 
        self.view.selectEffect:SetActive(false) 
        self.view.select.transform:SetParent(bg,false) 
        UIManager.PushView(ViewAssets.EquipGemTipUI,nil,id,'放入', function() self.AddGem(index) end,nil,nil,bg.position)        
    end 
    
    self.AddGem = function(index)
        if #composeIndexs <4 then
            table.insert(composeIndexs,index)
            UIManager.UnloadView(ViewAssets.EquipGemTipUI)
            self.view.select:SetActive(false)
            self.RefreshComposePage()
        end
    end
    
    self.ClickAddedGem = function(index,pos)
        self.view.select:SetActive(false) 
        self.view.selectEffect:SetActive(true) 
        self.view.selectEffect.transform.position = self.view['add'..index].transform.position
        UIManager.PushView(ViewAssets.EquipGemTipUI,nil,itemList[composeIndexs[index]].id,'取出',function() self.DelectGem(index) end,nil,nil,pos) 
    end  
        
    self.DelectGem = function(index)
        table.remove(composeIndexs,index)
        UIManager.UnloadView(ViewAssets.EquipGemTipUI)
        self.view.selectEffect:SetActive(false)
        self.RefreshComposePage()
    end
    
    self.RefreshComposePage = function()
        for i=#composeIndexs,1,-1 do
            if #itemList < composeIndexs[i] then
               table.remove(composeIndexs,i)               
            end            
        end
        for i=1,4 do
            self.view['addIcon'..i]:SetActive(i<=#composeIndexs)
            if i<=#composeIndexs then
                self.view['addIcon'..i]:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(itemList[composeIndexs[i]].id)
                local cost = itemList[composeIndexs[i]].cost
                if #composeIndexs > 1 then cost = 1 end
                self.view['addNum'..i]:GetComponent('TextMeshProUGUI').text = LuaUIUtil.FormatCostOwnText(cost,itemList[composeIndexs[i]].count)
            end
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.item,133,133,0,7,4)
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#itemList,UpdateItem)
        --self.view.note1:GetComponent('TextMeshProUGUI').text = 11111
    end
    
    self.RefreshPolishPage = function(index)
        polishIndex = index
        if #itemList == 0 then
            Close()
            UIManager.ShowNotice('暂无宝石')
            return
        elseif #itemList < polishIndex then
            polishIndex = #itemList
        end
        local id = itemList[polishIndex].id
        local config = itemTable.Item[id]
        local para1 = string.split(config.Para1,'|')
        local costData = gemTable.GemLevel[tonumber(para1[2])]
        self.view.mainIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(id)
        self.view.mainQuality:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(id)
        self.view.mainName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(id)
        self.view.mainNum:GetComponent('TextMeshProUGUI').text = LuaUIUtil.FormatCostOwnText(1,itemList[polishIndex].count)
        self.view.materialIcon1:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(costData.cost1[1])
        self.view.materialIcon2:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(costData.Specialcost[1])
        self.view.materialNum1:GetComponent('TextMeshProUGUI').text = LuaUIUtil.FormatCostOwnText(costData.cost1[2],BagManager.GetItemNumberById(costData.cost1[1]))
        self.view.materialQuality1:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(costData.cost1[1])
        self.view.materialQuality2:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(costData.Specialcost[1])
        self.view.materialNum2:GetComponent('TextMeshProUGUI').text = LuaUIUtil.FormatCostOwnText(costData.Specialcost[2],BagManager.GetItemNumberById(costData.Specialcost[1]))
        self.view.materialName1:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(costData.cost1[1])
        self.view.materialName2:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(costData.Specialcost[1])
    end

    local SendPolishHandle = function()
        local id = itemList[polishIndex].id
        local config = itemTable.Item[id]
        local para1 = string.split(config.Para1,'|')
        local costData = gemTable.GemLevel[tonumber(para1[2])]
        local data = {}
        data.gem_pos = itemList[polishIndex].pos
        if self.view.useSpecial:GetComponent('Toggle').isOn  then
            data.item_id = costData.Specialcost[1]
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_CARVE, data)
    end
    
    self.SendPolish = function()
        self.ResetPolishEffect()
        local id = itemList[polishIndex].id
        local config = itemTable.Item[id]
        local para1 = string.split(config.Para1,'|')
        local costData = gemTable.GemLevel[tonumber(para1[2])]
        local cost_items = {}
        table.insert(cost_items,{costData.cost1[1],costData.cost1[2]})
        table.insert(cost_items,{costData.cost2[1],costData.cost2[2]})
        if self.view.useSpecial:GetComponent('Toggle').isOn  then
            table.insert(cost_items,{costData.Specialcost[1],costData.Specialcost[2]})
        end
        if BagManager.CheckItemIsEnough(cost_items) == false then
            return
        end
        BagManager.CheckBindCoinIsEnough(cost_items,SendPolishHandle)
    end
    
    self.SendCompose = function()
        self.ResetComposeEffect()
        for i=1,#composeIndexs do
            local id = itemList[composeIndexs[i]].id
            if itemTable.Item[id].Type ~= const.TYPE_GEM then
                UIManager.ShowNotice('非宝石合成暂未开放')
                return
            end
        end
        
        local data = {}
        if #composeIndexs == 1 then
            if itemList[composeIndexs[1]].count < itemList[composeIndexs[1]].cost then
                UIManager.ShowNotice('合成需要材料数量为'..itemList[composeIndexs[1]].cost)
                return
            end
            data.item_pos1 = itemList[composeIndexs[1]].pos
            data.item_pos2 = itemList[composeIndexs[1]].pos
            data.item_pos3 = itemList[composeIndexs[1]].pos
        elseif #composeIndexs == 3 then    
            local config = itemTable.Item[itemList[composeIndexs[1]].id]
            local para1 = string.split(config.Para1,'|')
            local level1 = tonumber(para1[2])
            config = itemTable.Item[itemList[composeIndexs[2]].id]
            para1 = string.split(config.Para1,'|')
            local level2 = tonumber(para1[2])        
            config = itemTable.Item[itemList[composeIndexs[3]].id]
            para1 = string.split(config.Para1,'|')
            local level3 = tonumber(para1[2])
            if level1 ~= level2 or level2 ~=level3 then
                UIManager.ShowNotice('合成需要等级相同的宝石')
                return
            end
            
            data.item_pos1 = itemList[composeIndexs[1]].pos
            data.item_pos2 = itemList[composeIndexs[2]].pos
            data.item_pos3 = itemList[composeIndexs[3]].pos
        else
            UIManager.ShowNotice('合成宝石需要材料数量为3')
            return
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GEM_COMBINE, data)
    end
     
    return self
end

return CreateEquipGemHandleUICtrl()