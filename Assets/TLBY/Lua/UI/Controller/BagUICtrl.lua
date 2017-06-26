--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/9 0009
-- Time: 16:56
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
require "math"
require "UI/TextAnchor"

local itemtable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local parameter_formula_table = require "Logic/Scheme/common_parameter_formula"
local localization = require "Common/basic/Localization"

local function CreateBagUICtrl()
    local self = CreateCtrlBase()
    
    self.resourceBar = {}
    local currentMaxBagItemCount = 40
    local items = {}
    local scrollTimer = nil
    local itemPrefab = nil

    local function CloseTips()
        BagManager.CloseItemTips()
    end

    local function OnRecycleBtnClick()
        if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
        CloseTips()
        BagManager.sellFlag = true
        BagManager.sellItems = {}
        self.UpdateBagItems()
    end

    local function OnRecycleOkBtnClick()
        local sellItems = {}
		local count = 1
		for k,v in pairs(BagManager.sellItems) do
			if v then
				table.insert(sellItems,v)
				count = count + 1
			end
		end
		if count > 1 then
			MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ITEM_SELL, {item_pos_list=sellItems})
		end

		BagManager.sellItems = {}
		self.UpdateBagItems();
    end

    local function OnRecycleCancelBtnClick()
        BagManager.sellFlag = false
        self.UpdateBagItems()
    end

    local function OnSortBtnClick()
        if BagManager.lock == true then
            UIManager.ShowNotice(texttable.UIText[1101056].NR)
            return
        end
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_BAG_ARRANGE, {})
	end

    local function OnStoreBtnClick()
        UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
            ctrl.UpdateMsg(texttable.UIText[1101040].NR)
        end)
    end

    local function OnScrollViewViewportClick()
        CloseTips()
    end

    self.onLoad = function()
        self.view.scrollViewContent = self.view.ScrollView.transform:FindChild("Viewport/Content")
		self.view.scrollViewViewport = self.view.ScrollView.transform:FindChild("Viewport").gameObject

        self.textStoreBtn = self.view.textwarehouse:GetComponent("TextMeshProUGUI")
        self.textStoreBtn.text = texttable.UIText[1101024].NR
        --回收
        self.textRecycleBtn = self.view.textrecycl:GetComponent("TextMeshProUGUI")
        self.textRecycleBtn.text = texttable.UIText[1101023].NR
        --回收确认
        self.textSellOKBtn = self.view.textdetermine:GetComponent("TextMeshProUGUI")
        self.textSellOKBtn.text = texttable.UIText[1101006].NR
        --回收取消
        self.textSellCancelBtn = self.view.textcancel:GetComponent("TextMeshProUGUI")
        self.textSellCancelBtn.text = texttable.UIText[1101007].NR
        --回收金钱
        self.textSellMoney = self.view.textsellobtain:GetComponent("TextMeshProUGUI")
        self.scrollViewContentTransform = self.view.scrollViewContent:GetComponent("RectTransform")

        ClickEventListener.Get(self.view.btnrecycl).onClick = OnRecycleBtnClick
        ClickEventListener.Get(self.view.btndetermine).onClick = OnRecycleOkBtnClick
        ClickEventListener.Get(self.view.btncancel).onClick = OnRecycleCancelBtnClick
        ClickEventListener.Get(self.view.btndeal).onClick = OnSortBtnClick
        ClickEventListener.Get(self.view.btnwarehouse).onClick = OnStoreBtnClick
        ClickEventListener.Get(self.view.scrollViewViewport).onClick = OnScrollViewViewportClick

        local maxBagItemCount = parameter_formula_table.Parameter[17].Parameter
        currentMaxBagItemCount = BagManager.max_unlock_cell + 30
        if currentMaxBagItemCount > maxBagItemCount then
            currentMaxBagItemCount = maxBagItemCount
        end
        if itemPrefab == nil then
            ResourceManager.CreateUI("PlayerUI/BagItemUI",function(obj)
				itemPrefab = obj
				if itemPrefab and itemPrefab.transform.parent then
					itemPrefab.transform:SetParent(nil,false)
					itemPrefab:SetActive(false)
                end
				local data = {}
				local selectFlag = false
				local sellFlag = false
				local count = 0
				local id = 0
				for i = 1,currentMaxBagItemCount,1 do
					if i == BagManager.selectPos then
						selectFlag = true
					else
						selectFlag = false
					end
					sellFlag = false
					if BagManager.sellFlag then
						for sk,sv in pairs(BagManager.sellItems) do
							if sv == i then
								sellFlag = true
							end
						end
					end
					count = 0
					id = 0
					local itemdata = BagManager.items[i]
					if itemdata ~= nil then
						count = itemdata.count
						id = itemdata.id
					end
					table.insert(data,{pos=i,count = count,id = id,unlock = BagManager.max_unlock_cell,sell = sellFlag,select = selectFlag})
				end
				local itemWidth = 148
				local itemHeight = 145
				local itemPadding = 10
				local viewCount = 6
				local maxPerline = 4
				local itemUpdate = function(itemGo,index)
					itemGo:GetComponent("LuaBehaviour").luaTable.SetData(data[index + 1])
				end
				local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
				if scv then
					scv:Init(itemPrefab,itemWidth,itemHeight,itemPadding,viewCount,maxPerline)
					scv:UpdateData(currentMaxBagItemCount,itemUpdate)
				end	
			end)
            
        end
        
    end

    self.onActive = function()
        self.RequestAllBagItems()
    end

    self.RequestAllBagItems = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_BAG_GET_ALL, nil)
	end

    self.UpdateBagItems = function()
        if itemPrefab == nil then
            return
        end
        if BagManager.sellFlag then
            self.view.sell:SetActive(true)
            self.view.playerresourcesui:SetActive(false)
            --所有卖出价格
			local totalPrice = 0
			for spk,spv in pairs(BagManager.sellItems) do
				if spv and BagManager.items[spv] then
					local itemconfig = itemtable.Item[BagManager.items[spv].id]
					if itemconfig and itemconfig.CanRecycle > 0 then
						totalPrice = totalPrice + BagManager.items[spv].count * itemconfig.Price
					end
				end
			end
			self.textSellMoney.text = string.format(texttable.UIText[1101008].NR,totalPrice)
        else
            self.view.sell:SetActive(false)
            self.view.playerresourcesui:SetActive(true)
        end

        local maxBagItemCount = parameter_formula_table.Parameter[17].Parameter
        currentMaxBagItemCount = BagManager.max_unlock_cell + 30
        if currentMaxBagItemCount > maxBagItemCount then
            currentMaxBagItemCount = maxBagItemCount
        end
        local data = {}
        local selectFlag = false
        local sellFlag = false
        local count = 0
        local id = 0
        for i = 1,currentMaxBagItemCount,1 do
            if i == BagManager.selectPos then
                selectFlag = true
            else
                selectFlag = false
            end
            sellFlag = false
            if BagManager.sellFlag then
                for sk,sv in pairs(BagManager.sellItems) do
                    if sv == i then
                        sellFlag = true
                    end
                end
            end
            count = 0
            id = 0
            local itemdata = BagManager.items[i]
            if itemdata ~= nil then
                count = itemdata.count
                id = itemdata.id
            end
            table.insert(data,{pos=i,count = count,id = id,unlock = BagManager.max_unlock_cell,sell = sellFlag,select = selectFlag})
        end

        local itemUpdate = function(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(data[index + 1])
        end
        local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        if scv then
            scv:UpdateData(currentMaxBagItemCount,itemUpdate)
        end

    end

    --出售状态时点击物品调用
	self.OnSellBagItem = function(data)
		if not BagManager.sellItems[data.pos] then
			BagManager.sellItems[data.pos] = data.pos
		else
			BagManager.sellItems[data.pos] = nil
		end

		self.UpdateBagItems()
	end

    self.OnUnlock = function(data)
		CloseTips()
		--初始解锁个数
		local itemunlocknumber = parameter_formula_table.Parameter[16].Parameter
		--已经解锁个数
		local unlocknumber = BagManager.max_unlock_cell - itemunlocknumber
		if unlocknumber < 0 then
			unlocknumber = 0
		end
		unlocknumber = unlocknumber + 1
		local totalcost = 0
		local unlockcount = 0
		local itemconfig = nil
        local cost = {}
		for i = unlocknumber,data.pos - itemunlocknumber,1 do
			local unlockconfig = itemtable.BackpackDeblocking[i]
			if unlockconfig then
                local cnt = math.floor(#unlockconfig.Resoure/2)
                for j = 1,cnt,1 do
                    if cost[unlockconfig.Resoure[j*2-1]] == nil then
                        cost[unlockconfig.Resoure[j*2-1]] = unlockconfig.Resoure[j*2]
                    else
                        cost[unlockconfig.Resoure[j*2-1]] = cost[unlockconfig.Resoure[j*2-1]] + unlockconfig.Resoure[j*2]
                    end
                end
				unlockcount = unlockcount + 1
			end
		end
        local resource_str = ""
        local _cnt = 0
        for itemid,itemcount in pairs(cost) do
            itemconfig = itemtable.Item[itemid]
            if itemconfig ~= nil then
                if _cnt > 0 then
                    resource_str = resource_str..texttable.UIText[1101072].NR
                end
                resource_str = resource_str..string.format(texttable.UIText[1101073].NR,itemcount,localization.GetItemName(itemid))
                _cnt = _cnt + 1
            end
        end

        UIManager.ShowDialog(string.format(texttable.UIText[1101022].NR,unlockcount,resource_str),texttable.UIText[1101006].NR,texttable.UIText[1101007].NR,function()
            if BagManager.CheckItemIsEnoughEx(cost,false) == false then
                return
            end
--            BagManager.CheckBindCoinIsEnoughEx(cost,function()
--                MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_UNLOCK_CELL, {cell_pos=data.pos})
--            end)
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_UNLOCK_CELL, {cell_pos=data.pos})
        end,nil)
	end

    local function MoveContentPosition(step)
        self.scrollViewContentTransform.anchoredPosition3D = Vector3.New(self.scrollViewContentTransform.anchoredPosition3D.x,self.scrollViewContentTransform.anchoredPosition3D.y + step,self.scrollViewContentTransform.anchoredPosition3D.z)
    end


    --设置背包滚动视图位置
    self.SetContentPosition = function(pos)
        local lastpos = math.floor(self.scrollViewContentTransform.anchoredPosition3D.y / 145)*5
        if pos > lastpos and pos <= lastpos + 25 then
            return
        end

        local pos = math.floor((pos - 1)/5)*145
        local cpos = self.scrollViewContentTransform.anchoredPosition3D.y
        local step = (pos - cpos)/5
        --移动太小了，不动？
        if step < 2 and step > -2 then
            return
        end
        if scrollTimer then
            Timer.Remove(scrollTimer)
        end
        scrollTimer = Timer.Numberal(0.1,5,MoveContentPosition,step)
    end

    self.onUnload = function()
        if itemPrefab ~= nil then
            RecycleObject(itemPrefab)
            itemPrefab = nil
        end

        for k, v in pairs(items) do
            RecycleObject(v.obj)
        end
        items = {}
        if scrollTimer then
            Timer.Remove(scrollTimer)
        end
        scrollTimer = nil
        BagManager.sellFlag = false
        BagManager.selectPos = 0
    end

    return self
end

return CreateBagUICtrl()

