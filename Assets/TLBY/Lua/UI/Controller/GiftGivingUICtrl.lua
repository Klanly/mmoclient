---------------------------------------------------
-- auth： tml
-- date： 15/02/2017
-- desc： 赠送
---------------------------------------------------

local uitext = GetConfig("common_char_chinese").UIText
local constant = require "Common/constant"

local function CreateGiftGivingUICtrl()
	local self = CreateCtrlBase()
	local actor_id = nil
	local itemPrefab = nil

	local onCloseBtnClick = function()
		self.close()
	end

	local _UpdateScrollView = function(update)
		local ids = BagManager.GetItemIdsByType(constant.TYPE_FRIEND_VALUE)
		local item_num = #ids
		local data = {}
		local count = 0
		local id = 0
		for i = 1,#ids,1 do
			table.insert(data,{actor_id=actor_id,count = BagManager.GetItemNumberById(ids[i]),id = ids[i]})
		end
		local itemWidth = 835
		local itemHeight = 120
		local itemPadding = 10
		local viewCount = 5
		local maxPerline = 1
		local itemUpdate = function(itemGo,index)
			itemGo:GetComponent("LuaBehaviour").luaTable.SetData(data[index + 1])
		end
		local scv = self.view.ScrollView:GetComponent(typeof(UIMultiScroller))
		if scv then
			if update == false then
				scv:Init(itemPrefab,itemWidth,itemHeight,itemPadding,viewCount,maxPerline)
			end
			scv:UpdateData(item_num,itemUpdate)
		end
	end

	local UpdateScrollView = function(update)
        if itemPrefab == nil then
            itemPrefab = ResourceManager.CreateUI("AutoGenerate/GiftGiving/GiftGivingItemUI",function(obj)
				itemPrefab = obj
				if itemPrefab and itemPrefab.transform.parent then
					itemPrefab.transform:SetParent(nil,false)
					itemPrefab:SetActive(false)
				end
				_UpdateScrollView(update)
			end)
		else
			_UpdateScrollView(update)
		end
	end

	self.onLoad = function(pid,actor_name)
		actor_id = pid
		self.titleLabel = self.view.com_text_s1:GetComponent("TextMeshProUGUI")
		self.titleLabel.text = uitext[1101063].NR
		self.msgText = self.view.com_text_s3:GetComponent("TextMeshProUGUI")
		self.msgText.text = string.format(uitext[1101065].NR,actor_name)

		ClickEventListener.Get(self.view.com_btnclose2).onClick = onCloseBtnClick

		UIUtil.SetFullFromParentEdge(self.view.transform)
        self.view.transform.anchorMin = Vector2.New(0,0)
        self.view.transform.anchorMax = Vector2.New(1,1)

		UpdateScrollView(false)
	end

	self.UpdateData = function()
		UpdateScrollView(true)
	end
	
	self.onUnload = function()
		if itemPrefab ~= nil then
            RecycleObject(itemPrefab)
            itemPrefab = nil
        end
	end
	
	return self
end

return CreateGiftGivingUICtrl()