---------------------------------------------------
-- auth： panyinglong
-- date： 2016/11/1
-- desc： 霸主榜
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local dungeonScheme = require "Logic/Scheme/challenge_main_dungeon"

local boxImgs = {
	[1] = 'AutoGenerate/Overlordlist/treasurechestfirst',
	[2] = 'AutoGenerate/Overlordlist/treasurechestsecond',
	[3] = 'AutoGenerate/Overlordlist/treasurechestthird',
	[4] = 'AutoGenerate/Overlordlist/treasurechestfourth',
	[5] = 'AutoGenerate/Overlordlist/treasurechestfifth',
};
local flagImgs = {
	[1] = 'AutoGenerate/Overlordlist/imgpennantsfirts1',
	[2] = 'AutoGenerate/Overlordlist/imgpennantsfirts',
	[3] = 'AutoGenerate/Overlordlist/imgpennantsthird',
};
local getScore = function(index)
	local paraTable = dungeonScheme.Parameter
	if index == 1 then
		return paraTable[7].Value[2]
	elseif index == 2 then
		return paraTable[8].Value[2]
	elseif index == 3 then
		return paraTable[9].Value[2]
	elseif index == 4 then
		return paraTable[10].Value[2]
	elseif index == 5 then
		return paraTable[11].Value[2]
	end
	return 0
end
local getRewards = function()
	local paras = dungeonScheme.Parameter[4].Value
	local rewards = {}
	for i = 1, #paras, 2 do
		rewards[paras[i]] = paras[i + 1]
	end
	return rewards
end
local getResttime = function()
	local day = dungeonScheme.Parameter[15].Value[1]
	local hour = dungeonScheme.Parameter[16].Value[1]
	local min = dungeonScheme.Parameter[16].Value[2]
	return Util.GetSecondSpan(day, hour, min)
end

local function CreateLordItemUI(template, data, i)
	local self = CreateScrollviewItem(template)
	local index = i
	self.transform:FindChild('txtlevel'):GetComponent('TextMeshProUGUI').text = '通关等级：'.. (data.level or '') .. '级'
	self.transform:FindChild('txttime'):GetComponent('TextMeshProUGUI').text = '通关时间：' .. TimeToStr(data.time)
	self.transform:FindChild('txtscore'):GetComponent('TextMeshProUGUI').text = getScore(i)

	self.flagImg = self.transform:FindChild('imgFlag').gameObject
	self.flagTxt = self.transform:FindChild('txtFlag').gameObject
	if index <= 3 then 
		self.flagImg:SetActive(true)
		self.flagImg:GetComponent('Image').sprite = ResourceManager.LoadSprite(flagImgs[index])
		self.flagTxt:GetComponent('TextMeshProUGUI').text = ""
	else
		self.transform:FindChild('txtFlag'):GetComponent('TextMeshProUGUI').text = index
		self.flagImg:SetActive(false)
	end
	self.transform:FindChild('txtlordName'):GetComponent('TextMeshProUGUI').text = data.actor_name

	local imgbox = self.transform:FindChild('imgbox').gameObject
	if index == 1 then
		imgbox:SetActive(true)
		imgbox:GetComponent('Image').sprite = ResourceManager.LoadSprite(boxImgs[index])
	else
		imgbox:SetActive(false)
	end

    ClickEventListener.Get(imgbox).onClick = function()
		UIManager.PushView(ViewAssets.Sweep,nil, getRewards(), 'AutoGenerate/Sweep/lordrewards', "霸主可以获得以下奖励", true, "确定")    	
    end 

	return self
end

local function CreateOverlordlistCtrl()
	local self = CreateCtrlBase()
	self.dungeon = nil

	local lordItems = {}

	local closeClick = function()
		self.close()
	end
	local clearItems = function()
		for k, v in pairs(lordItems) do			
			DestroyScrollviewItem(v)
		end
		dropItems = {}
	end

	local timer = nil
	local stopTimer = function()
		if timer then
			Timer.Remove(timer)
			timer = nil
		end
	end
	local startTimer = function()
		if timer == nil then
			timer = Timer.Repeat(1, function()
				if self.rest > 0 then
					self.rest = self.rest - 1
					local t = timeFromSeconds(self.rest)
					self.restTimeTxt.text = "霸主榜重置：" .. t.d .. "天" .. 
						string.format("%02d", t.h) .. "时" .. 
						string.format("%02d", t.m) .. "分" .. 
						string.format("%02d", t.s) .. "秒"

				else
					stopTimer()
					self.restTimeTxt.text = "霸主榜即将重置..."
				end
			end)
		end
	end

	local OnDungeonHegemon = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
		else
			if data.dungeon_hegemon then
				self.view.txtresettime:GetComponent('TextMeshProUGUI').text = ''
				self.rest = getResttime()
				startTimer()

		        for i = 1, 5 do
		        	if data.dungeon_hegemon[i] then
			        	local item = CreateLordItemUI(self.template, data.dungeon_hegemon[i], i)
			        	table.insert(lordItems, item)
			        end
		        end
		    end
		end
	end
	self.onLoad = function(data)	
		self.dungeon = data
		self.template = self.view.itemTemplate
		self.template:SetActive(false)

		self.restTimeTxt = self.view.txtresettime:GetComponent('TextMeshProUGUI')

		self.view.titleoverlord:GetComponent('TextMeshProUGUI').text = '霸主榜'
		self.view.textchapter:GetComponent('TextMeshProUGUI').text = '第' .. self.dungeon.Chapter ..'章第' ..self.dungeon.index.. '节'
		self.view.txtresettime:GetComponent('TextMeshProUGUI').text = ''

        ClickEventListener.Get(self.view.btnok).onClick = closeClick
        ClickEventListener.Get(self.view.btnclose).onClick = closeClick

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, OnDungeonHegemon)
		self.RequestHegemon(self.dungeon.ID)
	end
	self.RequestHegemon = function(dungeon_id)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_DUNGEON_HEGEMON, {dungeon_id = dungeon_id})			
	end
	
	self.onUnload = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, OnDungeonHegemon)
		clearItems()
		stopTimer()
	end
	
	self.onActive = function()
	end

	self.onDeactive = function()
	end

	return self
end

return CreateOverlordlistCtrl()