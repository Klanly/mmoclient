--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/13
--
require "UI/Controller/LuaCtrlBase"

local function CreateTitleDescripCtrl()
    local self = CreateCtrlBase()
	local itemPrefab
	local selectItemIndex = 1
	local itemsData
	local scrollView

	local OnClose = function()			
	
		UIManager.UnloadView(ViewAssets.TitleDescrip)
	end
	
	local OnOk = function()
	
		OnClose()
	end
	
	local UpdateTitleRank = function()   --跟新爵位排行
		local itemsCount = #itemsData
		local itemData = {}
		for i = 1, itemsCount do
		
			local selectFlag = false
			if i == selectItemIndex then
			
				selectFlag = true
			end
			
			table.insert(itemData, {pos = i, select = selectFlag, attr = itemsData[i], SelectRankItemRet = self.OnSelectDescripItem})
		end
		
		local itemWidth = 1476
        local itemHeight = 64
        local itemPadding = 2
        local maxPerline = 1
		local viewCount = itemsCount / maxPerline
		
        local function itemUpdate(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(itemData[index + 1])
        end
		
		if scrollView then
			scrollView:UpdateData(itemsCount, itemUpdate)
		end
		--[[
		local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        if scv then
			if (scv.OnItemUpdate) then
			
				scv:UpdateData(itemsCount, itemUpdate)
			else
			
				scv:Init(itemsCount, itemPrefab, itemWidth, itemHeight, itemPadding, viewCount, maxPerline, itemUpdate)
			end
        end
		]]
	end
	
	self.OnSelectDescripItem = function(index)
	
		selectItemIndex = index
		UpdateTitleRank()
	end

	local ShowScrollView = function(itemPrefab)
		itemsData = pvpCamp.NobleRank
		
		local itemWidth = 1476
        local itemHeight = 64
        local itemPadding = 2
        local maxPerline = 1
		local viewCount = 15
		scrollView = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
		scrollView:Init(itemPrefab, itemWidth, itemHeight, itemPadding, viewCount, maxPerline)
		UpdateTitleRank()
	end
	
    self.onLoad = function()

        ClickEventListener.Get(self.view.btnquit).onClick = OnClose
		ClickEventListener.Get(self.view.btndetermine).onClick = OnOk
		
		if itemPrefab == nil then
			ResourceManager.CreateUI("TitleDescrip/TitleItem", 
				function(prefab)
					itemPrefab = prefab
					itemPrefab.transform:SetParent(nil,false)
					ShowScrollView(itemPrefab)
				end)
		else
			ShowScrollView(itemPrefab)
		end
    end

    self.onUnload = function()

    end

    return self
end

return CreateTitleDescripCtrl()

