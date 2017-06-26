---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/7
-- desc： 扫荡奖励
---------------------------------------------------

require "UI/Controller/LuaCtrlBase"

local itemTable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateDropItemUI(template, data)
	local self = CreateScrollviewItem(template)

	self.equipmentdrop = self.transform:FindChild('@equipmentdrop')
	local item = itemTable.Item[data.itemID]
	if item then
		self.equipmentdrop:GetComponent('Image').sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s", item.Icon))
	else
		print("error!!! not find item id="..data.itemID)
	end
	self.num = self.transform:FindChild('@textequipmentNum')
	local numtext = data.num
	if data.num >= 1000 then
		numtext = string.format("%2dk", data.num/1000)
	end
	self.num:GetComponent('TextMeshProUGUI').text = numtext

	self.name = self.transform:FindChild('@textequipment')
	self.name:GetComponent('TextMeshProUGUI').text = item.Name1 --texttable.TableText[item.Name].NR

	return self
end

local function CreateSweepCtrl()
	local self = CreateCtrlBase()

	local itemTemplate = nil
	local dropItems = {}
	local onOkCb = nil
	local onCloseCb = nil

	local closeClick = function()
		self.close()
		if onCloseCb then
			onCloseCb()
		end
	end
	local okClick = function()
		self.close()
		if onOkCb then
			onOkCb()
		end
	end
	
	
	local clearDropsItem = function()
		for k, v in pairs(dropItems) do			
			DestroyScrollviewItem(v)
		end
		dropItems = {}
	end

	local updateDropUI = function(data)
		clearDropsItem()
		if data then
			for k, v in ipairs(data) do
				local item = CreateDropItemUI(itemTemplate, v)
				table.insert(dropItems, item)
			end
		end
	end

	self.onLoad = function(rewards, titleImg, text, btnEnabled, btnText, onOKCallback, onCloseCallback)	
        ClickEventListener.Get(self.view.btnclose).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnclose, nil, nil)

        itemTemplate = self.view.rewardItem
        itemTemplate:SetActive(false)

        if titleImg then
	    	self.view.imgTitle:GetComponent('Image').sprite = ResourceManager.LoadSprite(titleImg)
	    end

        if text then
	        self.view.textdesc:GetComponent('TextMeshProUGUI').text = text
	    else
	    	self.view.textdesc:GetComponent('TextMeshProUGUI').text = ''
	    end

	    if btnText then
	    	self.view.textok:GetComponent('TextMeshProUGUI').text = btnText
	    end

	    if btnEnabled then
	        ClickEventListener.Get(self.view.btnok).onClick = okClick
	        self.setButtonEnable(self.view.btnok, true)
	    else
	        ClickEventListener.Get(self.view.btnok).onClick = nil
	        self.setButtonEnable(self.view.btnok, false)
	    end

		onOkCb = onOKCallback
		onCloseCb = onCloseCallback

		if rewards then
        	local drops = {}
        	for k, v in pairs(rewards)do
        		table.insert(drops, {itemID = k, num = v})
        	end
        	updateDropUI(drops)
        else 
        	print("no rewards")
        end

        -- 经验和金币
        self.view.textexp:GetComponent('TextMeshProUGUI').text = ''
        self.view.textsilver:GetComponent('TextMeshProUGUI').text = ''
	end
	
	self.onUnload = function()
		onOkCb = nil
		onCloseCb = nil
	end
	
	self.onActive = function()
	end

	self.onDeactive = function()
	end

	return self
end

return CreateSweepCtrl()
