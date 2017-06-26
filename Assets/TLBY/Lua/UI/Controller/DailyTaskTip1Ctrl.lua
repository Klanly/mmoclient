---------------------------------------------------
-- auth： 
-- date： 2017/01/23
-- desc： 匹配中
---------------------------------------------------

local function CreateItemUI(template, data)
	local self = CreateScrollviewItem(template)
	
	self.transform:FindChild('iconWhitering'):GetComponent('Image').overrideSprite = 
		LuaUIUtil.GetItemIcon(data)
	self.transform:FindChild('com_frame_blue'):GetComponent('Image').overrideSprite = 
		LuaUIUtil.GetItemQuality(data)
	ClickEventListener.Get(self.transform:FindChild('iconWhitering').gameObject).onClick = function()
		BagManager.ShowItemTips({item_data={id=data}},true)
	end
	return self
end

local function InitStaticButton(control)

    UIUtil.AddButtonEffect(control.view.btnClose, nil, nil)
    ClickEventListener.Get(control.view.btnClose).onClick = function()
    	control.close()
    end
end

local function freshUI(self, data)

	local time = ''
	if data.Date[1] ~= -1 then
		time = '周'
		local first = true
		local tmp = {'一','二','三','四','五','六','日'}
		for _,v in pairs(data.Date) do
            if not first then
            	time = time .. '、' 
            end
            first = false
            time = time .. tmp[v]
        end
    end
    time = time .. data.DateInterval1
    if data.DateInterval2 ~= '0' and data.DateInterval2 ~= '' then
    	time = time .. '、' .. data.DateInterval2
    end
	self.view.text_acti_time:GetComponent('TextMeshProUGUI').text = time ..'开启'
	self.view.text_acti_type:GetComponent('TextMeshProUGUI').text = data.PartakeNumMS
	self.view.text_acti_limit:GetComponent('TextMeshProUGUI').text = tostring(data.TimesLower)
	self.view.text_acti_desc:GetComponent('TextMeshProUGUI').text = data.Description
	self.view.textCampagainst:GetComponent('TextMeshProUGUI').text = data.Name

	if data.TimesUpperLimit == -1 then
        self.view.text_acti_cishu:GetComponent('TextMeshProUGUI').text = ''
    else
    	local count = data.excute_count or 0
        self.view.text_acti_cishu:GetComponent('TextMeshProUGUI').text = count..'/'..data.TimesUpperLimit
    end
end

local function CreateDailyTaskTip1Ctrl()
	local self = CreateCtrlBase()
	self.list_items = {}

    local clearDropsItem = function()
        for k, v in ipairs(self.list_items) do           
            DestroyScrollviewItem(v)
        end
        self.list_items = {}
    end

	self.onLoad = function(data)
		clearDropsItem()

		InitStaticButton(self)
		freshUI(self, data)

		self.view.template_item:SetActive(false)

	    for _,v in pairs(data.icon) do
	    	if v == 0 then break end
    		local item = CreateItemUI(self.view.template_item, v)
            table.insert(self.list_items, item)
	    end
	end
	
	self.onUnload = function()
		-- ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
	end
	
	return self
end

return CreateDailyTaskTip1Ctrl()