require "UI/Controller/LuaCtrlBase"

local function CreateMallUICtrl()
	local self = CreateCtrlBase()
    
    self.resourceBar = {}
    
    local selectedTab = 0
    local selectedSubTab = 1
    local selectedItem = 0
    
    local selectedNum = 1
    local maxCount = 99
    local minCount = 1

    local repeatTimer = nil
    local preOpenItemId = nil
    local config = GetConfig('system_store')
    local itemTable = GetConfig('common_item').Item
    local systemTable = GetConfig('common_system_list').system
    
    local itemDataList = {}
    local subTabItems = {}
    local sellInfo = {}
    
    local sortLabel = {
        [1] = 5,
        [2] = 4,
        [3] = 3,
        [4] = 2,
        [5] = 1,
        [6] = 6,
    }
    
    local moneyToTab = {
        [1002] = 1,
        [1006] = 2,
    }
    
    local otherStoreData = {
        {['des'] = 1135043,['UI'] = 1500,},--杂货铺
        {['des'] = 1135044,['UI'] = 1502,},--黑市
        {['des'] = 1135045,['money'] = 1007,['UI'] = 1271,},--副本商店
        {['des'] = 1135046,['money'] = 1011,['UI'] = 1391,},--帮会商店
        {['des'] = 1135047,['money'] = 1005,['UI'] = 1352,},--竞技场商店
        {['des'] = 1135048,['money'] = 1013,['UI'] = 1551,},--功勋商店
    }
    local tabData = 
    {
        [1] = {['page'] = 'MallPage',['money'] = 1002},
        [2] = {['page'] = 'MallPage',['money'] = 1006},
        [3] = {['page'] = 'ChargePage',},
        [4] = {['page'] = 'OtherStorePage'},
    }
    -- local subTabDes = {}
    -- local InsertTable = function(tb,element)
        -- for i=1,#subTabDes do
            -- if subTabDes[i] == element then
                -- return i
            -- end
            -- if subTabDes[i]
        -- end
        -- table.insert(tb,element)
        -- return #subTabDes
    -- end
    
    local textTable = GetConfig("common_char_chinese").UIText
    local GetText = function(id)
        return textTable[id].NR
    end
    
    local LeftNum = function(data)
        if data.TotalbuyNum <=0 and data.BuyNum <=0 then
            return nil
        elseif data.TotalbuyNum > 0 and data.BuyNum <= 0 then
            return data.TotalbuyNum - (sellInfo.total_item_buy_num[data.ID] or 0)
        elseif data.TotalbuyNum <= 0 and data.BuyNum > 0 then
            return data.BuyNum - (sellInfo.ingot_item_buy_num[data.ID] or 0)
        elseif data.TotalbuyNum > 0 and data.BuyNum > 0 then
            local totalLeft = data.TotalbuyNum - (sellInfo.total_item_buy_num[data.ID] or 0)
            local selfLeft = data.BuyNum - (sellInfo.ingot_item_buy_num[data.ID] or 0)
            return math.min(selfLeft,totalLeft)
        end
    end
    
    local OccupationSuit = function(data)
        if data.UseCareer[1] == -1 then
            return true
        end
        for i=1,#data.UseCareer do
            if MyHeroManager.heroData.vocation == data.UseCareer[i] then
                return true
            end
        end
        return false
    end
    
    local TimeToString = function(second)
        if second < 24*60*60 then
            return string.format('%d小时%d分',math.floor(second/60/60),math.ceil(second/60)%60)
        else
            return string.format('%d天%d小时',math.floor(second/60/60/24),math.ceil(second/60/60)%24)
        end
    end
    
    local InActivity = function(data)
        if data.BeginTime == '' then
            return false
        end
        local beginTime = string.split(data.BeginTime,'-')
        local overTime = string.split(data.OverTime,'-')
        local beginSecond = os.time{year=beginTime[1], month=beginTime[2], day=beginTime[3], hour=beginTime[4]}
        local overSecond = os.time{year=overTime[1], month=overTime[2], day=overTime[3], hour=overTime[4]}
        local currentSecond = networkMgr:GetConnection().ServerSecondTimestamp
        return currentSecond > beginSecond and currentSecond < overSecond
    end
    
    local LeftTimeStr = function(data)
        if data.BeginTime == '' then
            return ''
        end
        local beginTime = string.split(data.BeginTime,'-')
        local overTime = string.split(data.OverTime,'-')
        local beginSecond = os.time{year=beginTime[1], month=beginTime[2], day=beginTime[3], hour=beginTime[4]}
        local overSecond = os.time{year=overTime[1], month=overTime[2], day=overTime[3], hour=overTime[4]}
        local currentSecond = networkMgr:GetConnection().ServerSecondTimestamp
        if currentSecond < beginSecond then
            if data.OffSell == 1 then
                return TimeToString(beginSecond - currentSecond)..'后开始'
            else
                return ''
            end
        end
        if currentSecond > overSecond then
            if data.OffSell == 1 then
                return '已下架'
            else
                return ''
            end
        end
        return TimeToString(overSecond - currentSecond)
    
    end
    
    local ShowInUI = function(data)
        if data.LevelMin > MyHeroManager.heroData.level then
            return false
        end
        if data.LevelMax < MyHeroManager.heroData.level then
            return false
        end
        if not OccupationSuit(data) then
            return false
        end
        if data.BeginTime == '' or data.OffSell ~= 1 then
            return true
        end 
        local beginTime = string.split(data.BeginTime,'-')
        local overTime = string.split(data.OverTime,'-')
        local beginSecond = os.time{year=beginTime[1], month=beginTime[2], day=beginTime[3]}
        local overSecond = os.time{year=overTime[1], month=overTime[2], day=overTime[3]}
        local currentSecond = networkMgr:GetConnection().ServerSecondTimestamp
        return math.ceil(currentSecond/60/60/24) >= math.ceil(beginSecond/60/60/24) and math.ceil(currentSecond/60/60/24) <= math.ceil(overSecond/60/60/24)
    end
    
    local FreshItemDataList = function()
        itemDataList = {} --itemDataList 按tabType大小排序
        for k,v in pairs(config.mall) do
            local tab = moneyToTab[v.Money]
            if ShowInUI(v) then
                if itemDataList[tab] == nil then
                    itemDataList[tab] = {}
                end
                if ShowInUI(v) then
                    local index = 1
                    for i=1,#itemDataList[tab] do
                        if itemDataList[tab][i][1].Type == v.Type then
                            break
                        end
                        index = index+1
                    end
                    if itemDataList[tab][index] == nil then
                        itemDataList[tab][index] = {}
                    end
                    table.insert(itemDataList[tab][index],v)
                end
            end
        end
        for k,v in pairs(itemDataList) do
            table.sort(v,function(a,b) return a[1].Type < b[1].Type end)
        end
    end
    
	self.onLoad = function(data)
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.num,self.ShowKeyboardUI)
        self.AddClick(self.view.btnAdd,function() if(selectedNum < maxCount) then selectedNum = selectedNum + 1 self.FreshBuyInfo() end  end)
        self.AddClick(self.view.btnMinus,function() if(selectedNum > minCount) then selectedNum = selectedNum - 1 self.FreshBuyInfo() end  end)
        
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.mallItem,450,150,0,7,2)
        self.view.otherStoreScrollView:GetComponent('UIMultiScroller'):Init(self.view.OtherStoreItem,1576,218,0,6,1)
        self.view.subTabItem:SetActive(false)
        self.view.mallItem:SetActive(false)
        self.view.OtherStoreItem:SetActive(false)

        for i=1,#tabData do
            self.AddClick(self.view['tab'..i],function() if selectedTab == i then return end selectedSubTab = 1 self.TabClick(i) end)
        end
        
        selectedSubTab = 1
        self.TabClick(1)

        if preOpenItemId then
            self.OpenPageWithItem()
        end
        
        if repeatTimer == nil then
            repeatTimer = Timer.Repeat(30, function() self.TabClick(selectedTab) end)
        end
	end
    
    self.onUnload = function()
        for i=1,#subTabItems do
            GameObject.Destroy(subTabItems[i])
        end
        subTabItems = {}
        --MessageRPCManager.RemoveUser(self, 'IngotShopBuyRet')
        MessageRPCManager.RemoveUser(self, 'GetIngotShopInfoRet')
        Timer.Remove(repeatTimer)
        repeatTimer = nil
	end
        
    self.TabClick = function(i)
        selectedTab = i
        self.view['tab'..i]:GetComponent('Toggle').isOn = true
        self.view.MallPage:SetActive(false)
        self.view.OtherStorePage:SetActive(false)
        self.view.ChargePage:SetActive(false)
        self.view[tabData[i].page]:SetActive(true)
        
        if self.view.MallPage.activeSelf then
            self.MallPageUpdate(selectedTab)
        end
        
        if self.view.OtherStorePage.activeSelf then
            self.OtherStorePageUpdate()
        end
    end
    
    self.OtherStorePageUpdate = function()
        self.view.otherStoreScrollView:GetComponent('UIMultiScroller'):UpdateData(#otherStoreData,self.UpdateStoreItem)
    end
    
    self.UpdateStoreItem = function(item,index)
        local data = otherStoreData[index+1]
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = systemTable[data.UI].name
        item.transform:Find('des'):GetComponent('TextMeshProUGUI').text = GetText(data.des)
        item.transform:Find('cost').gameObject:SetActive(data.money ~= nil)
        if data.money then
            item.transform:Find('cost'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.money)..':'..BagManager.GetItemNumberById(data.money)
        end
        self.AddClick(item.transform:Find('button').gameObject,function() self.close() UISwitchManager.OpenSceneObjectUI(data.UI) end)
    end
    
    self.OpenPageWithItem = function()
        for k,v in pairs(itemDataList) do
            for key,value in pairs(v) do
                for i=1,#value do
                    if value[i].Item == preOpenItemId then
                        selectedSubTab = key
                        selectedItem = value[i].ID
                        self.TabClick(k)
                    end
                end
            end
        end
    end
    
    self.FreshBuyInfo = function()
        local data = config.mall[selectedItem]
        self.view.costItemIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.Money)      
        self.view.num:GetComponent('TextMeshProUGUI').text = selectedNum
        local inDiscount = data.DiscountTime < 100 and InActivity(data)
        local discount = 1
        if inDiscount then
            discount = data.DiscountTime / 100
        end
        local cost = selectedNum * math.ceil(itemTable[data.Item][LuaUIUtil.priceType[data.Money]] * discount)
        self.view.costNum:GetComponent('TextMeshProUGUI').text = cost
        if BagManager.CheckItemIsEnough({{data.Money,cost}},true) then
            self.view.costNum:GetComponent('TextMeshProUGUI').color = Color.white
        else
            self.view.costNum:GetComponent('TextMeshProUGUI').color = Color.red
        end
        
    end
    
    self.ShowKeyboardUI = function()
        local data = {}
        data.maxCount = maxCount
        data.inputCount = selectedNum
        data.callbackHandler = function(key)  selectedNum = key self.FreshBuyInfo() end
        UIManager.PushView(ViewAssets.KeyBoardUI,nil,data)
    end
    
    self.OpenUI = function(itemID)
        MessageRPCManager.AddUser(self, 'GetIngotShopInfoRet')
        local data = {}
        data.func_name = 'on_get_ingot_shop_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
        
        preOpenItemId = itemID
    end
    
    self.GetIngotShopInfoRet = function(data)
        sellInfo = data
        if self.isLoaded then
            self.TabClick(selectedTab)
        else
            UIManager.PushView(ViewAssets.MallUI)
        end
        
    end
    
    -- self.IngotShopBuyRet = function(data)
        -- local data = {}
        -- data.func_name = 'on_get_ingot_shop_info'
        -- MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
    -- end

    self.MallPageUpdate = function(tab)
        FreshItemDataList()
    
        for i=1,#itemDataList[tab] do
            if subTabItems[i] == nil then
                subTabItems[i] = GameObject.Instantiate(self.view.subTabItem)
                subTabItems[i].transform:SetParent(self.view.subTabs.transform,false)
            end
            subTabItems[i].transform:Find('text'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(config.type[itemDataList[tab][i][1].Type],'Name')
            self.AddClick(subTabItems[i].transform:Find('bg').gameObject, function() if selectedSubTab == i then return end self.FreshSubPage(i) end)
            subTabItems[i]:SetActive(true)
        end
        for i=#itemDataList[tab]+1,#subTabItems do
            subTabItems[i]:SetActive(false)
        end
        
        self.FreshSubPage(selectedSubTab)
    end
    
    self.FreshSubPage = function(subTab)
        selectedSubTab = subTab
        subTabItems[selectedSubTab].transform:Find('bg'):GetComponent('Toggle').isOn = true
        table.sort(itemDataList[selectedTab][selectedSubTab],function(a,b) if a.Laber == b.Laber then return a.Order < b.Order end return sortLabel[a.Laber] < sortLabel[b.Laber]  end)
        
        local exsit = false
        for i=1,#itemDataList[selectedTab][selectedSubTab] do-- 重置selectedItem
            if itemDataList[selectedTab][selectedSubTab][i].ID == selectedItem then
                exsit = true
                break
            end
        end
        if not exsit then
            selectedItem = itemDataList[selectedTab][selectedSubTab][1].ID
        end
        self.UpdateItemDetail(selectedItem)
    end
    
    self.UpdateItem = function(item,index)
        local data = itemDataList[selectedTab][selectedSubTab][index+1]
        local selected = data.ID == selectedItem
        item.transform:Find('bg').gameObject:SetActive(not selected)
        item.transform:Find('select').gameObject:SetActive(selected)
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.Item)
        item.transform:Find('costIcon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.Money)
        item.transform:Find('pre'):GetComponent('TextMeshProUGUI').text = math.ceil(itemTable[data.Item][LuaUIUtil.priceType[data.Money]])
        local discount = data.DiscountTime < 100 and (InActivity(data) or data.OffSell == 1)
        item.transform:Find('pre/discount').gameObject:SetActive(discount)
        item.transform:Find('pre/after').gameObject:SetActive(discount)
        item.transform:Find('pre/after'):GetComponent('TextMeshProUGUI').text = math.ceil(itemTable[data.Item][LuaUIUtil.priceType[data.Money]] * data.DiscountTime / 100)
        item.transform:Find('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.Item)
        item.transform:Find('quality'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(data.Item)
        item.transform:Find('pre'):GetComponent('TextMeshProUGUI').text = math.ceil(itemTable[data.Item][LuaUIUtil.priceType[data.Money]])
        if data.Laber == 5 then -- 限时秒杀
            item.transform:Find('left'):GetComponent('TextMeshProUGUI').text = '全服剩余 '..(data.TotalbuyNum - (sellInfo.total_item_buy_num[data.ID] or 0))
        elseif data.Laber == 4 then -- 团购
            item.transform:Find('left'):GetComponent('TextMeshProUGUI').text = '剩余数量 '..(data.BuyNum - (sellInfo.ingot_item_buy_num[data.ID] or 0))
        elseif data.BuyNum >0 then
            item.transform:Find('left'):GetComponent('TextMeshProUGUI').text = '限购 '..data.BuyNum - (sellInfo.ingot_item_buy_num[data.ID] or 0)
        else
            item.transform:Find('left'):GetComponent('TextMeshProUGUI').text = ''
        end
        
        item.transform:Find('time'):GetComponent('TextMeshProUGUI').text = LeftTimeStr(data)
        for i=1,5 do
            item.transform:Find('label'..i).gameObject:SetActive(data.Laber == i)
        end
        self.AddClick(item.transform:Find('bg').gameObject, function() selectedNum = 1 self.UpdateItemDetail(data.ID) end)
    end
    
    self.UpdateItemDetail = function(ID)
        selectedItem = ID
        local data = config.mall[selectedItem]
        local itemData = itemTable[data.Item]
        self.view.itemName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetItemName(data.Item)
        self.view.des:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(itemData,'Description')
        
        if data.Laber == 5 then -- 限时秒杀
            self.view.extra1:SetActive(data.BuyNum > 0)
            self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('活动限购：%d/%d',(sellInfo.ingot_item_buy_num[data.ID] or 0),data.BuyNum)
            self.view.extra2:SetActive(data.TotalbuyNum > 0)
            self.view.extra2:GetComponent('TextMeshProUGUI').text = string.format('全服限购：%d个',data.TotalbuyNum)
            local inActivity = InActivity(data)
            self.view.extra3:SetActive(inActivity)
            if inActivity then
                self.view.extra3:GetComponent('TextMeshProUGUI').text = '活动剩余时间：'..LeftTimeStr(data)
            end
        elseif data.Laber == 4 then -- 团购
            self.view.extra1:SetActive(data.BuyNum > 0)
            self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('活动限购：%d/%d',(sellInfo.ingot_item_buy_num[data.ID] or 0),data.BuyNum)
            self.view.extra2:SetActive(true)
            self.view.extra2:GetComponent('TextMeshProUGUI').text = string.format('全服已购：%d个',sellInfo.group_buy_num[data.ID] or 0)
            local inActivity = InActivity(data)
            self.view.extra3:SetActive(inActivity)
            if inActivity then
                self.view.extra3:GetComponent('TextMeshProUGUI').text = '活动剩余时间：'..LeftTimeStr(data)
            end
            local des = string.format('\n\n当成功购买该商品，之后每有%d个玩家购买该商品，则自己可以领取一个[%s]',data.RewardInterval,LuaUIUtil.GetItemName(data.RewardID))
            self.view.des:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(itemData,'Description')..des
        else
            self.view.extra1:SetActive(data.BuyNum > 0)
            self.view.extra2:SetActive(false)          
            self.view.extra3:SetActive(false)
            if data.BuyType == 1 then
                self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('本日限购：%d/%d',(sellInfo.ingot_item_buy_num[data.ID] or 0),data.BuyNum)
            elseif data.BuyType == 2 then
                self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('本周限购：%d/%d',(sellInfo.ingot_item_buy_num[data.ID] or 0),data.BuyNum)
            elseif data.BuyType == 3 then
                self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('限购：%d个',data.BuyNum)
            elseif data.BuyType == 4 then
                self.view.extra1:GetComponent('TextMeshProUGUI').text = string.format('活动限购：%d/%d',(sellInfo.ingot_item_buy_num[data.ID] or 0),data.BuyNum)
                local inActivity = InActivity(data)
                self.view.extra2:SetActive(inActivity)
                if inActivity then
                    self.view.extra2:GetComponent('TextMeshProUGUI').text = '活动剩余时间：'..LeftTimeStr(data)
                end
            end

        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#itemDataList[selectedTab][selectedSubTab],self.UpdateItem)
        
        self.view.limitDes:GetComponent('TextMeshProUGUI').text = string.format('等级达到%d可购买\n当前等级：%d',data.BuyLevel,MyHeroManager.heroData.level)
        self.view.limitDes:SetActive(data.BuyLevel > MyHeroManager.heroData.level)
        self.view.btnBuy:SetActive(data.BuyLevel <= MyHeroManager.heroData.level)
        if not InActivity(data) and data.OffSell == 1 then 
            self.view.btnBuy:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
            self.AddClick(self.view.btnBuy,nil)
        else
            self.view.btnBuy:GetComponent('Image').material = nil
            self.AddClick(self.view.btnBuy,self.BuyClick)
        end
        local left = LeftNum(data)
        maxCount = math.min(left or 99 , 99)
        selectedNum = math.min(selectedNum,maxCount)
        
        self.FreshBuyInfo()
    end

    local BuyClickHandle = function()
        local data = {}
        data.func_name = 'on_ingot_shop_buy'
        data.shop_item_id = selectedItem
        data.count = selectedNum
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.BuyClick = function()
        local item = config.mall[selectedItem]
        local left = LeftNum(item)
        if left and left < selectedNum then
            UIManager.ShowNotice('超出限购数量')
            return
        end

        local moneys = {}
        local itemData = itemTable[item.Item]
        table.insert(moneys,{item.Money,math.ceil(itemData[LuaUIUtil.priceType[item.Money]]*item.DiscountTime/100)*selectedNum})
        if BagManager.CheckItemIsEnough(moneys) == false then
            return
        end
        BagManager.CheckBindCoinIsEnough(moneys,BuyClickHandle)
    end

	return self
end

return CreateMallUICtrl()
