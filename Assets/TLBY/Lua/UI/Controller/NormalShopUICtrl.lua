require "UI/Controller/LuaCtrlBase"

local function CreateNormalShopUICtrl()
	local self = CreateCtrlBase()
    
    self.resourceBar = {}
    local shopType = 'grocery'
    local selectedSubTab = 1
    local selectedItem = 0
    
    local selectedNum = 1
    local maxCount = 99
    local minCount = 1
    
    local config = (require"Logic/Scheme/system_store")
    local itemTable = (require"Logic/Scheme/common_item").Item
    local uitext = GetConfig('common_char_chinese').UIText
    local postTb = GetConfig('pvp_country').GovernmentPost

    local itemDataList = {}
    local subTabItems = {}
    local buyInfo = {}
    
    local titleTable = 
    {
        ['grocery'] = {'杂货铺',1500},
        ['copy'] = {'副本商店',1271},
        ['arena'] = {'竞技场商店',1352},
        ['confraternity'] = {'帮贡商店',1391},
        ['camp'] = {'功勋商店',1551},
        ['blackmarket'] = {'黑市',1502},
    }
    
    local subTabDes = {}
    local InsertTable = function(tb,element)
        for i=0,#subTabDes do
            if subTabDes[i] == element then
                return i
            end
        end
        table.insert(tb,element)
        return #subTabDes
    end
    
    local ShowInUI = function(data)
        if data.levelmin > MyHeroManager.heroData.level then
            return false
        end
        if data.levelmax < MyHeroManager.heroData.level then
            return false
        end
        return true
    end
    
    local FreshItemDataList = function()
        itemDataList = {}
        subTabDes = {}
        for k,v in pairs(config[shopType]) do
            if ShowInUI(v) then
                local index = InsertTable(subTabDes,v.type)
                if itemDataList[index] == nil then
                    itemDataList[index] = {}
                end
                table.insert(itemDataList[index],v)
            end
        end
        for k,v in pairs(itemDataList) do
            table.sort(v,function(a,b) return a.num<b.num end)
        end
    end
    
    self.OpenUI = function(type)
        if type then shopType = type end
        
        MessageRPCManager.AddUser(self, 'GetNormalShopInfoRet')
        local data = {}
        data.func_name = 'on_get_normal_shop_info'
        data.shop_name = shopType
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        self.resourceBar = {}
        table.insert(self.resourceBar,config[shopType][1].money)
    end
    
    self.GetNormalShopInfoRet = function(data)
        if data.result == 0 then
            buyInfo = data.item_buy_num
            discountInfo = data.discount_info
            UIManager.PushView(ViewAssets.NormalShopUI)
        end
        MessageRPCManager.RemoveUser(self, 'GetNormalShopInfoRet')
    end
    
	self.onLoad = function()
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.mallItem,450,150,0,7,2)
        self.view.subTabItem:SetActive(false)
        self.view.mallItem:SetActive(false)
        self.view.title:GetComponent('TextMeshProUGUI').text = titleTable[shopType][1]
        FreshItemDataList()
        for i=1,#itemDataList do
            if subTabItems[i] == nil then
                subTabItems[i] = GameObject.Instantiate(self.view.subTabItem)
                subTabItems[i].transform:SetParent(self.view.subTabs.transform,false)
                subTabItems[i].transform:Find('text'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(config.type[subTabDes[i]],'Name')
                self.AddClick(subTabItems[i].transform:Find('bg').gameObject, function() if selectedSubTab == i then return end self.FreshSubPage(i) end)
            end
            subTabItems[i]:SetActive(itemDataList[i] ~= nil)
        end
        
        if itemDataList[selectedSubTab] == nil then -- 重置selectedSubTab
            for i=1,3 do
                if itemDataList[i] ~= nil then
                    selectedSubTab = i
                    break
                end
            end
        end

        self.FreshSubPage(1)
        
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.num,self.ShowKeyboardUI)
        self.AddClick(self.view.btnAdd,function() if(selectedNum < maxCount) then selectedNum = selectedNum + 1 self.FreshBuyInfo() end  end)
        self.AddClick(self.view.btnMinus,function() if(selectedNum > minCount) then selectedNum = selectedNum - 1 self.FreshBuyInfo() end  end)
        self.AddClick(self.view.btnBuy,self.BuyClick)
        UIManager.AddHelpTip(self, titleTable[shopType][2])
    
        -- discountInfo = {}
        -- discountInfo.end_time = networkMgr:GetConnection():GetSecondTimestamp() + 1000
        -- discountInfo.office_id = 1
        -- discountInfo.actor_name = 'xx'
        -- discountInfo.discount = 10
        if discountInfo then
            self.view.extra1:SetActive(true)
            self.view.extra2:SetActive(true)
            self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format(uitext[1135109].NR,postTb[discountInfo.office_id].name,discountInfo.actor_name,discountInfo.discount/10)
            
            local TimeUpdate = function() 
                local leftTime = networkMgr:GetConnection():GetTimespanSeconds(discountInfo.end_time)
                if leftTime <0 then leftTime = 0 end
                self.view.extra2:GetComponent('TextMeshProUGUI').text = string.format(uitext[1135110].NR,TimeToStr(leftTime))
            end
            TimeUpdate()
            countDown = Timer.Repeat(1,TimeUpdate)
        else
            self.view.extra1:SetActive(false)
            self.view.extra2:SetActive(false)
        end
	end
    
    self.onUnload = function()
        for i=1,#subTabItems do
            GameObject.Destroy(subTabItems[i])
        end
        subTabItems = {}
        if countDown then
            Timer.Remove(countDown)
            countDown = nil
        end
	end
    
    self.NormalShopBuyRet = function(data)
        if data.result ==0 then
            buyInfo = data.item_buy_num
        end
        self.UpdateItemDetail(selectedItem)
    end
    
    self.FreshBuyInfo = function()
        local data = itemDataList[selectedSubTab][selectedItem]
        self.view.costItemIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.money)      
        self.view.num:GetComponent('TextMeshProUGUI').text = selectedNum
        local discount = data.discount 
        if discountInfo ~= nil then
            discount = math.min(discount,discountInfo.discount)
        end
        local cost = selectedNum * math.ceil(itemTable[data.item][LuaUIUtil.priceType[data.money]] * discount/ 100)
        self.view.costNum:GetComponent('TextMeshProUGUI').text = cost
        if BagManager.CheckItemIsEnough({{data.money,cost}},true) then
            self.view.costNum:GetComponent('TextMeshProUGUI').color = Color.white
        else
            self.view.costNum:GetComponent('TextMeshProUGUI').color = Color.red
        end
        if data.BuyNum > 0 then
            maxCount = data.BuyNum - (buyInfo[data.ID] or 0)
        else
            maxCount = 99
        end
    end
    
    self.ShowKeyboardUI = function()
        local data = {}
        data.maxCount = maxCount
        data.inputCount = selectedNum
        data.callbackHandler = function(key)  selectedNum = key self.FreshBuyInfo() end
        UIManager.PushView(ViewAssets.KeyBoardUI,nil,data)
    end

    self.FreshSubPage = function(subTab)
        selectedSubTab = subTab
        subTabItems[selectedSubTab].transform:Find('bg'):GetComponent('Toggle').isOn = true
        
        self.UpdateItemDetail(1)
    end
    
    self.UpdateItem = function(item,index)
        local data = itemDataList[selectedSubTab][index+1]
        local selected = index+1 == selectedItem
        item.transform:Find('bg').gameObject:SetActive(not selected)
        item.transform:Find('select').gameObject:SetActive(selected)
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.item)
        item.transform:Find('costIcon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.money)
        item.transform:Find('pre'):GetComponent('TextMeshProUGUI').text = math.ceil(itemTable[data.item][LuaUIUtil.priceType[data.money]])
        local discount = data.discount
        if discountInfo ~= nil then
            discount = math.min(discount,discountInfo.discount)
        end
        item.transform:Find('pre/discount').gameObject:SetActive(discount < 100 )
        item.transform:Find('pre/after').gameObject:SetActive(discount < 100 )
        item.transform:Find('pre/after'):GetComponent('TextMeshProUGUI').text = math.ceil(itemTable[data.item][LuaUIUtil.priceType[data.money]] * discount / 100)
        item.transform:Find('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.item)
        item.transform:Find('quality'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(data.item)
        item.transform:Find('pre'):GetComponent('TextMeshProUGUI').text = itemTable[data.item][LuaUIUtil.priceType[data.money]]
        item.transform:Find('left'):GetComponent('TextMeshProUGUI').text = ''
        item.transform:Find('time'):GetComponent('TextMeshProUGUI').text = ''
        for i=1,5 do
            item.transform:Find('label'..i).gameObject:SetActive(false)
        end
        self.AddClick(item.transform:Find('bg').gameObject, function() selectedNum = 1 self.UpdateItemDetail(index + 1) end)
    end
    
    self.UpdateItemDetail = function(ID)
        selectedItem = ID
        local data = itemDataList[selectedSubTab][selectedItem]
        local itemData = itemTable[data.item]
        self.view.itemName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.item)
        self.view.des:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(itemData,'Description')
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#itemDataList[selectedSubTab],self.UpdateItem)
        selectedNum = math.min(selectedNum,maxCount)
        self.FreshBuyInfo()
    end

    local BuyClickHandle = function()
        local selectedData = itemDataList[selectedSubTab][selectedItem]
        local data = {}
        data.func_name = 'on_normal_shop_buy'
        data.shop_name = shopType
        data.count = selectedNum
        data.shop_item_id = selectedData.ID
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
    end

    self.BuyClick = function()
        local moneys = {}
        local selectedData = itemDataList[selectedSubTab][selectedItem]
        local itemData = itemTable[selectedData.item]
        local discount = selectedData.discount
        if discountInfo ~= nil then
            discount = math.min(discount,discountInfo.discount)
        end
        table.insert(moneys,{selectedData.money,math.ceil(itemData[LuaUIUtil.priceType[selectedData.money]]*discount/100)*selectedNum})
        if BagManager.CheckItemIsEnough(moneys) == false then
            return
        end
        BagManager.CheckBindCoinIsEnough(moneys,BuyClickHandle)
    end

	return self
end

return CreateNormalShopUICtrl()
