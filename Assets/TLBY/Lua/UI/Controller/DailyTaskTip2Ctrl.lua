---------------------------------------------------
-- auth： 
-- date： 2017/01/23
-- desc： 匹配中
---------------------------------------------------
local config = GetConfig('activity_daily')

local function CreateItemUI(template, data)
	local self = CreateScrollviewItem(template)
	
	self.transform:FindChild('iconWhitering'):GetComponent('Image').overrideSprite = 
		LuaUIUtil.GetItemIcon(data.Item[1])
	self.transform:FindChild('com_frame_blue'):GetComponent('Image').overrideSprite = 
		LuaUIUtil.GetItemQuality(data.Item[1])
	self.transform:FindChild('text_num'):GetComponent('TextMeshProUGUI').text = data.Item[2]
	return self
end

local function InitStaticButton(self)

    UIUtil.AddButtonEffect(self.view.btnclose, nil, nil)
    ClickEventListener.Get(self.view.btnclose).onClick = function()
    	self.close()
    end
    
    local box_data = config.Liveness[self.box_index]
	self.view.textdonatianmessage:GetComponent('TextMeshProUGUI').text = 
        '    总活跃度达到'..box_data.NeedLiveness..'可以开启宝箱，在以下物品随机获得一个，随不随到全看人品哦~'

    ClickEventListener.Get(self.view.btnopen).onClick = function()
        MyHeroManager.RequestOpenBox(self.box_index)
    end

    self.view.template_box:SetActive(false)
    --local items = {}
    for _,v in pairs(config.Chest) do
    	if v.RandID == box_data.PackageID then
    		--table.insert(items, v)
    		local item = CreateItemUI(self.view.template_box, v)
            table.insert(self.list_items, item)
    	end
    end
    
end

local function refreshUI(self)
	local box_data = config.Liveness[self.box_index]
	if self.activity_info.liveness_history < box_data.NeedLiveness then
    	self.view.tip_insufficient:SetActive(false)
    	self.view.tip_lack:SetActive(true)
    	self.view.btnopen:SetActive(false)
    elseif self.activity_info.liveness_current < box_data.ConsumeLiveness then
    	self.view.tip_insufficient:SetActive(true)
    	self.view.tip_lack:SetActive(false)
    	self.view.btnopen:SetActive(false)
    else
    	self.view.tip_insufficient:SetActive(false)
    	self.view.tip_lack:SetActive(false)
    	self.view.btnopen:SetActive(true)
    end
end

local function CreateDailyTaskTip2Ctrl()
	local self = CreateCtrlBase()
	self.active = false
	self.list_items = {}

    local clearDropsItem = function()
        for k, v in ipairs(self.list_items) do           
            DestroyScrollviewItem(v)
        end
        self.list_items = {}
    end

	self.onLoad = function(data)
		self.active = true
		self.box_index = data[1]
		self.activity_info = data[2]
		clearDropsItem()
		InitStaticButton(self)
		refreshUI(self)
	end
	
	self.onUnload = function()
		self.active = false
		-- ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
	end

	self.PassData = function(data)
		if self.active then
			self.activity_info = data.activity_info
	        refreshUI(self)
	    end
	end
	
	return self
end

return CreateDailyTaskTip2Ctrl()