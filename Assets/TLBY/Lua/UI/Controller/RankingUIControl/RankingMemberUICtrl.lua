----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateRankingMemberUICtrl()
	local self = CreateViewBase()
	self.memberIndex = 0
	self.SelectAction = nil
	local itemDatas
	local itemsText = {}
	
	local OnSelect = function()
		if self.SelectAction then
			if itemDatas then
				self.SelectAction(itemDatas, self.bgrank1.transform.position)
			end
		end
	end

	local ShowItem = function()
		if itemDatas == nil then
			return
		end
		
		for i = 1, 3 do
			self['rank'..i]:SetActive(false)
			self['bgrank'..i]:SetActive(false)
		end
		self.rankindex:SetActive(false)
		
		for i = 1, 2 do
			self['bginterval'..i]:SetActive(false)
			self['campIcon' .. i]:SetActive(false)
		end
		
		local rankIndex = itemDatas.rank			--排名
		if rankIndex and rankIndex >= 1 then
			if rankIndex < 4 then
				self['rank'..rankIndex]:SetActive(true)
				self['bgrank'..rankIndex]:SetActive(true)
			else
				self.rankindex:SetActive(true)
				self.rankindex:GetComponent('TextMeshProUGUI').text = rankIndex
				self['bginterval'..((rankIndex % 2) + 1)]:SetActive(true)
			end
		end
		
		if itemDatas.cameIndex and	itemDatas.cameIndex >= 1 then			--阵营
			self['campIcon' .. itemDatas.cameIndex]:SetActive(true)
		end
		
		for i = 1, 4 do
			if itemDatas['item'..i] then
				itemsText[i].text = itemDatas['item'..i]
			else
				itemsText[i].text = ''
			end
		end
	end

	self.SetData = function(data)
		if data == nil then
			return
		end
		
		itemDatas = data
		ShowItem()
	end

	self.Awake = function()
		self.item1 = self.transform:FindChild("item1").gameObject
		self.item3 = self.transform:FindChild("item3").gameObject
		self.item4 = self.transform:FindChild("item4").gameObject
		self.item2 = self.transform:FindChild("item2").gameObject        
		self.rankindex = self.transform:FindChild("rankindex").gameObject
		self.campIcon1 = self.transform:FindChild("campIcon1").gameObject
		self.campIcon2 = self.transform:FindChild("campIcon2").gameObject
		
		local viewName
		for i = 1, 3 do
			viewName = 'rank'..i
			self[viewName] = self.transform:FindChild(viewName).gameObject
			
			viewName = 'bgrank'..i
			self[viewName] = self.transform:FindChild(viewName).gameObject
			ClickEventListener.Get(self[viewName]).onClick = OnSelect
		end
		
		for i = 1, 2 do
			viewName = 'bginterval'..i
			self[viewName] = self.transform:FindChild(viewName).gameObject
			ClickEventListener.Get(self[viewName]).onClick = OnSelect
		end
		
		for i = 1, 4 do
			itemsText[i] = self['item'..i]:GetComponent('TextMeshProUGUI')
		end
	end
	
	return self
end

return CreateRankingMemberUICtrl()
