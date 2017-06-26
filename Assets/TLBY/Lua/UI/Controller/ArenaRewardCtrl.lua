---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/1
-- desc： 
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

local function CreateArenaRewardCtrl()
	local self = CreateCtrlBase()
	self.rankData = {}
	local dropItems = {}
	local itemTemplate

	local closeAndBack = function()
		self.close()
		ArenaManager.RequestOverSingleFight()		
	end

	local closeTime = 9
	local closeTimer = nil
	local stopCloseTimer = function()
		if closeTimer then
			Timer.Remove(closeTimer)
		end
		closeTimer = nil
	end
	local startCloseTimer = function()
		stopCloseTimer()
		closeTimer = Timer.Repeat(1, function()
			closeTime = closeTime - 1
			self.view.textAutomaticallyexits:GetComponent('TextMeshProUGUI').text = closeTime .. '秒后自动退出竞技场'
			self.view.textAutomaticallyexitf:GetComponent('TextMeshProUGUI').text = closeTime .. '秒后自动退出竞技场'
			if closeTime <= 0 then
				closeAndBack()
			end
		end)
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

	self.onLoad = function(data)
		itemTemplate = self.view.rewardItem
		itemTemplate:SetActive(false)

        ClickEventListener.Get(self.view.bg).onClick = closeAndBack
        ClickEventListener.Get(self.view.close).onClick = closeAndBack

		if data.success then
			self.view.failedui:SetActive(false)
			self.view.succui:SetActive(true)
			self.view.bg:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/ArenaReward/bg_victory')
			self.view.textranking:GetComponent('TextMeshProUGUI').text = '排名：' .. data.rank_up
		else
			self.view.failedui:SetActive(true)
			self.view.succui:SetActive(false)
			self.view.bg:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/ArenaReward/bg_failed')
			self.view.textranking:GetComponent('TextMeshProUGUI').text = '排名未变'
		end
		if data.upgrade then
			print("是否晋级：".. tostring(data.upgrade))
		end
	    local rewards = {}
	    if data.rewards then
	    	for k, v in pairs(data.rewards) do --{id=1001,count=1},
	    		rewards[v.id] = v.count
	    	end
	    end
	    if rewards then
        	local drops = {}
        	for k, v in pairs(rewards)do
        		table.insert(drops, {itemID = k, num = v})
        	end
        	updateDropUI(drops)
        else 
        	print("no rewards")
        end

        closeTime = 9
        startCloseTimer()
	end

	self.onUnload = function()
		stopCloseTimer()
	end

	return self
end

return CreateArenaRewardCtrl()