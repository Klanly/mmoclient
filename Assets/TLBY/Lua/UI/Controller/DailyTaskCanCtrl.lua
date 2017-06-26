---------------------------------------------------
-- auth： 
-- date： 2017/01/23
-- desc： 匹配中
---------------------------------------------------

local config = GetConfig('activity_daily')

local function GetWDay()
	local tab = os.date("*t", time)
	local wday = tab.wday - 1
	if wday == 0 then
		wday = 7
	end
	return wday
end

local wday = GetWDay()

local function CreatePlayerItemUI(template, data)
	local self = CreateScrollviewItem(template)


	self.transform:FindChild('text_title'):GetComponent('TextMeshProUGUI').text = data.ActivityName
	if data.Time1 == '0' then
		data.Time1 = ''
	end
	if data.Time2 == '0' then
		data.Time2 = ''
	end
	self.transform:FindChild('text_time1'):GetComponent('TextMeshProUGUI').text = data.Time1
	self.transform:FindChild('text_time2'):GetComponent('TextMeshProUGUI').text = data.Time2

	if data.Date == wday then
		self.transform:FindChild('choicetestbackground3').gameObject:SetActive(true)
	end
	return self
end

local function InitStaticButton(control)

    UIUtil.AddButtonEffect(control.view.btnClose, nil, nil)
    ClickEventListener.Get(control.view.btnClose).onClick = function()
    	control.close()
    end
end

local function DealData()
	local data = {}

	for i = 1, 7 do 
		data[i] = {}
	end

	local tmp = config.Calendar
	for _, one_day in pairs(tmp) do
		table.insert(data[one_day.Date], one_day)
	end

	return data
end

local function CreateDailyTaskCanCtrl()
	local self = CreateCtrlBase()
	self.dataItems = {}

	local clearDropsItem = function()
		for k, v in ipairs(self.dataItems) do			
			DestroyScrollviewItem(v)
		end
		self.dataItems = {}
	end

	self.onLoad = function(data)
		InitStaticButton(self)

		clearDropsItem()

		local data = DealData()

		for day = 1, 7 do
			self.view['template'..day]:SetActive(false)
			
			for i = 1, #data[day] do
				local item = CreatePlayerItemUI(self.view['template'..day], data[day][i])
				table.insert(self.dataItems, item)
			end	
		end

		self.view['List'..wday]:GetComponent('Toggle').isOn = true

	end
	
	self.onUnload = function()
		-- ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
	end
	
	return self
end

return CreateDailyTaskCanCtrl()