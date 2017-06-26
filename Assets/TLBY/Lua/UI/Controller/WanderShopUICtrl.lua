---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/RepeatItemList"

local function CreateWanderShopUICtrl()
	local self = CreateCtrlBase()
    self.resourceBar = {}
    
    local config = (require"Logic/Scheme/system_store").wander
    local param = (require"Logic/Scheme/system_store").Parameter
    local itemTable = (require"Logic/Scheme/common_item").Item
    local charTable = (require"Logic/Scheme/common_char_chinese").TableText

    local dataList = nil
    local selectItemIndex = 1
    local selectedNum = 1    
    local serveData = nil
    local expireTime = 0
    

    local UpdateItem = function(item,index)
        local key = index+1
        local soldOut = item.transform:FindChild("soldOut").gameObject
        local name = item.transform:FindChild("name"):GetComponent("TextMeshProUGUI")
        local icon = item.transform:FindChild("icon"):GetComponent("Image")
        local quality = item.transform:FindChild("quality"):GetComponent("Image")
        local costIcon = item.transform:FindChild("costIcon"):GetComponent("Image")
        local pre = item.transform:FindChild("pre"):GetComponent("TextMeshProUGUI")
        local left = item.transform:FindChild("left"):GetComponent("TextMeshProUGUI")
        local after = item.transform:FindChild("pre/after"):GetComponent("TextMeshProUGUI")
        local bg = item.transform:FindChild("bg"):GetComponent("Image")
        local bgProp = item.transform:FindChild('bg_Prop'):GetComponent('Image')
        local discountObj = item.transform:FindChild("pre/discount").gameObject
        item.transform:FindChild("select").gameObject:SetActive(key == selectItemIndex)
        
        ClickEventListener.Get(bg.gameObject).onClick = function() self.ItemClick(key) end
        local itemData = itemTable[dataList[key].item[1]]
        local costMoney = itemData[LuaUIUtil.priceType[dataList[key].money]]
        pre.text = costMoney
        after.text = math.floor(costMoney*dataList[key].discount/100)
        after.gameObject:SetActive(dataList[key].discount < 100)
        discountObj:SetActive(dataList[key].discount < 100)
        costIcon.overrideSprite = LuaUIUtil.GetItemIcon(dataList[key].money)
        name.text = LuaUIUtil.GetItemName(itemData.ID)
        icon.overrideSprite = LuaUIUtil.GetItemIcon(itemData.ID)
        quality.overrideSprite = LuaUIUtil.GetItemQuality(itemData.ID)
        left.text = "剩余："..dataList[key].itemLeft
        soldOut:SetActive(dataList[key].itemLeft <= 0)
        
        if dataList[key].itemLeft <= 0 then
            bg.material = UIGrayMaterial.GetUIGrayMaterial()
            bgProp.material = UIGrayMaterial.GetUIGrayMaterial()
            costIcon.material = UIGrayMaterial.GetUIGrayMaterial()
            quality.material = UIGrayMaterial.GetUIGrayMaterial()
            icon.material = UIGrayMaterial.GetUIGrayMaterial()
        else
            bg.material = nil
            bgProp.material = nil
            costIcon.material = nil
            quality.material = nil
            icon.material = nil
        end
    end
    
    local FreshItemList = function()
        dataList = {}
        for i=1,#serveData do
            local data = config[serveData[i].index]
            if data and MyHeroManager.heroData.level >= data.levelmin and MyHeroManager.heroData.level <= data.levelmax then
                data.tempIndex = serveData[i].index
                data.cell = i
                data.itemLeft = serveData[i].count
                table.insert(dataList,data)
            end
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#dataList,UpdateItem)
    end

    local repeatTimer = nil
    local onWanderHold = function(data)
        if data.result == 0 and #data.wander_list > 0 then
            serveData = data.wander_list
            expireTime = data.expire_time
            self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.item,785,165,0,5,2)
            selectItemIndex = 1 
            if repeatTimer == nil then
                repeatTimer = Timer.Repeat(1, self.FreshTimeInfo)
            end
            self.FreshTimeInfo()
            FreshItemList()
            self.show()
        else
            self.close()
        end
    end
    
	self.onLoad = function()  
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_WANDER_HOLD)
        
        self.view.item:SetActive(false)
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_WANDER_BUY , self.HandlerBuyMsg)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, self.HandlerBuyMsg)   
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_WANDER_DISAPPEAR, self.Close)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_WANDER_HOLD, onWanderHold)
        
        ClickEventListener.Get(self.view.close).onClick = self.close
        ClickEventListener.Get(self.view.buyBtn).onClick = self.BuyClick
        self.hide()
	end

	self.onUnload = function()
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_WANDER_BUY , self.HandlerBuyMsg)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, self.HandlerBuyMsg)  
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_WANDER_DISAPPEAR, self.Close) 
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_WANDER_HOLD, onWanderHold)   

        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_WANDER_FREE)     
        Timer.Remove(repeatTimer)
        repeatTimer = nil        
	end
        
    self.FreshTimeInfo = function()
        local serverTime = networkMgr:GetConnection().ServerSecondTimestamp
        if expireTime > serverTime then
            self.view.buyBtn:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
            self.view.buyBtnText:GetComponent('TextMeshProUGUI').text = string.format('购买(%dS)', expireTime - serverTime)
        else
            self.view.buyBtn:GetComponent('Image').material = nil
            self.view.buyBtnText:GetComponent('TextMeshProUGUI').text = '购买'
        end
        for k,v in pairs(string.split(param[2].value,'|')) do
            local beginTimeTable = string.split(v,':')
            local beginTime = beginTimeTable[1]*360 + beginTimeTable[2]*60
            local endTime = beginTime + param[5].value*60          
            local currentTime = os.date("%H", serverTime)*360+os.date("%M", serverTime)*60+os.date("%S", serverTime)
            if beginTime < currentTime and currentTime < endTime then
                self.view.timeLeft:GetComponent('TextMeshProUGUI').text = string.format('倒计时：%02d:%02d:%02d',math.floor((endTime - currentTime)/3600),math.floor((endTime - currentTime)/60%60),math.ceil((endTime - currentTime)%60))
                return
            end
        end

    end

    local BuyClickHandle = function()
         local selectedData = dataList[selectItemIndex]
        if selectedData.itemLeft <= 0 then
            UIManager.ShowNotice("已售罄")
            return
        end

        local data = {}
        data.cell = selectedData.cell
        data.index = selectedData.tempIndex
        data.count = 1
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_WANDER_BUY,data)
    end
    
    self.BuyClick = function()
        local selectedData = dataList[selectItemIndex]
        if selectedData.itemLeft <= 0 then
            UIManager.ShowNotice("已售罄")
            return
        end
        local moneys = {}
        local itemData = itemTable[selectedData.item[1]]
        table.insert(moneys,{selectedData.money,math.floor(itemData[LuaUIUtil.priceType[selectedData.money]]*selectedData.discount/100)})
        if BagManager.CheckItemIsEnough(moneys) == false then
            return
        end
        BagManager.CheckBindCoinIsEnough(moneys,BuyClickHandle)
    end
    
    self.ItemClick = function(key)
        selectItemIndex = key
        FreshItemList()
    end
    
    self.HandlerBuyMsg = function(data)
        if data.wander_list ~= nil then
            serveData = data.wander_list
            FreshItemList()        
        end
        if data.expire_time then
            expireTime = data.expire_time
            self.FreshTimeInfo()
        end
    end
	return self
end

return CreateWanderShopUICtrl()