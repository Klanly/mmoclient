

local function CreateLineItem(temp, lineid, linestatus)
	local self = CreateScrollviewItem(temp)

	self.linename = self.transform:FindChild('lineName')
	self.linename:GetComponent('TextMeshProUGUI').text = lineid .. '线'
	ClickEventListener.Get(self.gameObject).onClick = function()
		if SceneManager.IsOnFightServer() then
			UIManager.ShowNotice('只有主城和野外可以切分线.')
			return
		end
		if tostring(SceneLineManager.curLineId) == tostring(lineid) then
			UIManager.ShowNotice('当前已经在该分线了.')
			return
		end
		if linestatus == 1 then
			UIManager.ShowNotice('目标分线已满，无法进入')
			return
		end
		local hero = SceneManager.GetEntityManager().hero
        if hero then
        	hero:StartSwitchLine(lineid)
        end
	end

	if tostring(lineid) == tostring(SceneLineManager.curLineId) then
		self.transform:FindChild('current').gameObject:SetActive(true)
	else
		self.transform:FindChild('current').gameObject:SetActive(false)
	end

	for i = 1, 4 do -- linestatus = 1, 2, 3, 4
		if linestatus == i then
			self.transform:FindChild('state' .. i).gameObject:SetActive(true)
		else
			self.transform:FindChild('state' .. i).gameObject:SetActive(false)
		end
	end

	return self
end

local function CreateSwitchChannelUICtrl()
	local self = CreateCtrlBase()
	local lineItems = {}

    self.layer = LayerGroup.popCanvas
    

    local clearItems = function()	
        for k, v in pairs(lineItems) do
        	DestroyScrollviewItem(v.gameObject)
        end
        lineItems = {}
    end
    local UpdateUI = function(type)
        clearItems()
    	for lineid, linestatus in pairs(SceneLineManager.curLines) do
        	local item = CreateLineItem(self.view.item, lineid, linestatus)
			table.insert(lineItems, item)
        end
    	-- if type == 'all' then
	    -- elseif type == 'current' then
	    	
	    -- end
	end

	self.onLoad = function()
        self.AddClick(self.view.btnClose, self.close)
        self.view.item:SetActive(false)


        SceneLineManager.QuerySceneLines()
        SceneLineManager.AddListener(UpdateUI)
	end
	
	self.onUnload = function()
		clearItems()
        SceneLineManager.RemoveListener(UpdateUI)
	end
	
	return self
end

return CreateSwitchChannelUICtrl()