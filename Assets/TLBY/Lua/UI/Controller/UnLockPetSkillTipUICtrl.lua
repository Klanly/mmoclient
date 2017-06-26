--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/6
-- Time: 20:58
--

require "UI/Controller/LuaCtrlBase"

local function CreateUnLockPetSkillTipUICtrl()
    local self = CreateCtrlBase()
	self.layer = LayerGroup.popCanvas
	local itemPrefab
	
	self.okHandler = nil
	self.index = nil
	self.title = nil
	self.items = nil

    local function Close()
        UIManager.UnloadView(ViewAssets.UnLockPetSkillTipUI)
    end
	
	local OnOk = function()
	
		if (self.okHandler) then
		
			self.okHandler(self.index)
		end
		
		Close()
	end

    self.onLoad = function()

		ClickEventListener.Get(self.view.Close).onClick = Close
		ClickEventListener.Get(self.view.Ok).onClick = OnOk
    end
	
	local ShowScrollContent = function()
		local itemData = {}
        for i=1,#self.items,2 do
		
            local selectFlag = true
            local itemID = self.items[i]
			local count = BagManager.GetItemNumberById(itemID)
            local loginData = MyHeroManager.heroData
            table.insert(itemData, {pos = 1, count = count, id = itemID, unlock = #self.items, sell = false, select = selectFlag, isNeedNum = true,  GetNeedNum = function() return self.items[i+1] end})
		end
		local itemWidth = 145
        local itemHeight = 145
        local itemPadding = 10
		
        local function itemUpdate(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(itemData[index + 1])
        end
		
		local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
        scv:GetComponent('RectTransform').sizeDelta = Vector2.New(itemWidth*#itemData+10*(#itemData-1),itemHeight)
        if scv then
                scv:Init(itemPrefab, itemWidth, itemHeight, itemPadding, #itemData, 1)
				scv:UpdateData(#itemData, itemUpdate)
        end
	end
	
	local ShowItems = function()
	
		if (not itemPrefab) then
		
			ResourceManager.CreateUI("Common/ItemUI", 
				function(ctrl)
					itemPrefab = ctrl
					itemPrefab.transform:SetParent(nil,false)
					ShowScrollContent()
				end
			)
		else
			ShowScrollContent()
		end
	end

	--okHandler 确定回调
    self.Show = function(data)
		
		self.okHandler = data.okHandler
		self.index = data.index
		self.title = data.title
		self.items = data.items
		
		local text = self.view.Title:GetComponent('TextMeshProUGUI')
		text.text = data.title
		
		ShowItems()
    end

    return self
end

return CreateUnLockPetSkillTipUICtrl()


