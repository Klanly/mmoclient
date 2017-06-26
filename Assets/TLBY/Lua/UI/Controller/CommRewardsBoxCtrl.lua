--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/13
-- Time: 20:58
--

require "UI/Controller/LuaCtrlBase"

local function CreateCommRewardsBoxCtrl()
    local self = CreateCtrlBase()
	local itemPrefab


    local function Close()
        UIManager.UnloadView(ViewAssets.CommRewardsBox)
    end
	
	local OnOk = function()
	
		Close()
	end

    self.onLoad = function()

		ClickEventListener.Get(self.view.btnclose).onClick = Close
		ClickEventListener.Get(self.view.btnok).onClick = OnOk
    end
	
	local ShowScroll = function(itemPrefab, data)
		local itemData = {}
		local itemsCount = 1
		for k, v in pairs(data) do
		
			table.insert(itemData, {pos = itemsCount, count = v, id = k, unlock = 0, sell = false, select = false})
			itemsCount = itemsCount + 1
		end
		itemsCount = itemsCount - 1
		
		local itemWidth = 145
        local itemHeight = 145
        local itemPadding = 10
        local maxPerline = 1
		local viewCount = itemsCount / maxPerline
		
        local function itemUpdate(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(itemData[index + 1])
        end
		
		local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        if scv then
            scv:Init(itemPrefab, itemWidth, itemHeight, itemPadding, viewCount, maxPerline)
            scv:UpdateData(itemsCount, itemUpdate)
        end
	end
	
	local ShowItems = function(data)
		if itemPrefab == nil then
			ResourceManager.CreateUI("Common/ItemUI",
				function(prefab)
					itemPrefab = prefab
					itemPrefab.transform:SetParent(nil,false)
					ShowScroll(itemPrefab, data)
				end)
		else
			ShowScroll(itemPrefab, data)
		end
	end

	--okHandler 确定回调
    self.Show = function(data)
		
		self.title = data.title
		self.items = data.items
		
		local text = self.view.textdesc:GetComponent('TextMeshProUGUI')
		text.text = data.title
		
		ShowItems(self.items)
    end

    return self
end

return CreateCommRewardsBoxCtrl()


