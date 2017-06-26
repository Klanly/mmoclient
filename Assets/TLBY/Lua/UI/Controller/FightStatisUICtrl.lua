---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/22
-- desc： 
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreatePlayerItemUI(template, data)
	local self = CreateScrollviewItem(template)

	self.transform:FindChild('iconplayer1'):GetComponent('Image').sprite = 
		ResourceManager.LoadSprite('HeroIcon/vocation'..data.vocation)
	self.transform:FindChild('textplayername'):GetComponent('TextMeshProUGUI').text = data.name
	self.transform:FindChild('textkillnumber'):GetComponent('TextMeshProUGUI').text = data.kill_player
	self.transform:FindChild('textdiednumber'):GetComponent('TextMeshProUGUI').text = data.die
	self.transform:FindChild('textinputnumber'):GetComponent('TextMeshProUGUI').text = data.damage
	self.transform:FindChild('texttreatmentnumber'):GetComponent('TextMeshProUGUI').text = data.treat
	self.transform:FindChild('textBearingdamagenumber'):GetComponent('TextMeshProUGUI').text = data.inhury
	self.transform:FindChild('textkillmonsternumber'):GetComponent('TextMeshProUGUI').text = data.kill_monster
	
	if data.name ~= SceneManager.GetEntityManager().hero.name then
		self.transform:FindChild('bgbrightbox'):GetComponent('Image').color = Color.New(0.8, 0.8, 0.8)
	end
	return self
end

local function InitStaticButton(controller)
	UIUtil.AddButtonEffect(controller.view.btnquit, nil, nil)
	ClickEventListener.Get(controller.view.btnquit).onClick = function()
    	controller.close()
    end

    UIUtil.AddButtonEffect(controller.view.btnResetdata, nil, nil)
    ClickEventListener.Get(controller.view.btnResetdata).onClick = function()
    	MyHeroManager.ResetFightDataStatistics()
    end

    UIUtil.AddButtonEffect(controller.view.btnrefresh, nil, nil)
    ClickEventListener.Get(controller.view.btnrefresh).onClick = function()
    	MyHeroManager.RequestFightDataStatistics()
    end

    UIUtil.AddButtonEffect(controller.view.textKillmonster, nil, nil)
    ClickEventListener.Get(controller.view.textKillmonster).onClick = function()
    	controller.Sort('kill_monster')
    end

    UIUtil.AddButtonEffect(controller.view.textkill, nil, nil)
    ClickEventListener.Get(controller.view.textkill).onClick = function()
    	controller.Sort('kill_player')
    end

    UIUtil.AddButtonEffect(controller.view.textdied, nil, nil)
    ClickEventListener.Get(controller.view.textdied).onClick = function()
    	controller.Sort('die')
    end

    UIUtil.AddButtonEffect(controller.view.textinput, nil, nil)
    ClickEventListener.Get(controller.view.textinput).onClick = function()
    	controller.Sort('damage')
    end

    UIUtil.AddButtonEffect(controller.view.texttreatment, nil, nil)
    ClickEventListener.Get(controller.view.texttreatment).onClick = function()
    	controller.Sort('treat')
    end

    UIUtil.AddButtonEffect(controller.view.textBearingdamage, nil, nil)
    ClickEventListener.Get(controller.view.textBearingdamage).onClick = function()
    	controller.Sort('inhury')
    end

    controller.view.bgPopupwindow:SetActive(false)
    
    UIUtil.AddButtonEffect(controller.view.btnrelease, nil, nil)
    ClickEventListener.Get(controller.view.btnrelease).onClick = function()
    	controller.view.bgPopupwindow:SetActive(not controller.view.bgPopupwindow.activeSelf)
    end

    UIUtil.AddButtonEffect(controller.view.btnnear, nil, nil)
    ClickEventListener.Get(controller.view.btnnear).onClick = function()
    	controller.SendMsg(4)
    	controller.view.bgPopupwindow:SetActive(false)
    end

    UIUtil.AddButtonEffect(controller.view.btnteam, nil, nil)
    ClickEventListener.Get(controller.view.btnteam).onClick = function()
    	controller.SendMsg(3)
    	controller.view.bgPopupwindow:SetActive(false)
    end

    UIUtil.AddButtonEffect(controller.view.btnhang, nil, nil)
    ClickEventListener.Get(controller.view.btnhang).onClick = function()
    	controller.SendMsg(1)
    	controller.view.bgPopupwindow:SetActive(false)
    end
end

local function CreateFightStatisUICtrl()
	local self = CreateCtrlBase()

	self.dataList = {}
	self.dataItems = {}

	local closeClick = function()
		self.close()
	end
	
	local cancelClick = function()
	end

	local clearDropsItem = function()
		for k, v in ipairs(self.dataItems) do			
			DestroyScrollviewItem(v)
		end
		self.dataItems = {}
	end

	self.onLoad = function(data)

		InitStaticButton(self)

		MyHeroManager.RequestFightDataStatistics()
	end
	
	self.onUnload = function()
		
	end

	self.getTime = function()
		if self.fight_data.start_time ~= nil then
			local time =  0 - networkMgr:GetConnection():GetTimespanSeconds(self.fight_data.start_time)
			local time_str = string.format("%02d:%02d:%02d", math.floor(time/3600), math.floor(time/60), time%60)
			return time_str
		else
			return ''
		end
	end


	self.getTime2 = function()
		local time =  0 - networkMgr:GetConnection():GetTimespanSeconds(self.fight_data.start_time)
		local time_str 
		if math.floor(time/3600) > 0 then
			time_str = string.format("%02d小时%02d分%02d秒", math.floor(time/3600), math.floor(time/60), time%60)
		else
			time_str = string.format("%02d分%02d秒", math.floor(time/60), time%60)
		end
		return time_str
	end

	self.refreshUI = function()
		clearDropsItem()

		if self.fight_data.statistics ~= nil then
			local tmp = {}
			for _,v in pairs(self.fight_data.statistics) do
				table.insert(tmp, 
				{
					name = v.actor_name,
					kill_player = tostring(v.kill_player or 0),
					kill_monster = tostring(v.kill_monster or 0),
					die = tostring(v.die or 0),
					damage = tostring(v.damage or 0),
					inhury = tostring(v.inhury or 0),
					treat = tostring(v.treat or 0),
					vocation = v.vocation or 1
				})
			end

			for i = 1, #tmp do
				local item = CreatePlayerItemUI(self.view.itemtemplate, tmp[i])
				table.insert(self.dataItems, item)
			end	
		end

		self.view.texttime:GetComponent('TextMeshProUGUI').text = self.getTime()

		if TeamManager.IsCaptain() then
			self.setButtonEnable(self.view.btnResetdata, true)
		else
			self.setButtonEnable(self.view.btnResetdata, false)
		end
	end

	self.PassData = function(data)
		self.fight_data = data
		self.Sort('damage')
	end

	local chin_name = {
		kill_player = '击杀',
		kill_monster = '杀怪',
		die = '死亡',
		damage = '输出',
		inhury = '承受伤害',
		treat = '治疗',
	}

	self.SendMsg = function(channel)
		if self.sort_name == nil then
			return 
		end
		local tableData = SceneManager.GetCurSceneData()
		local msg = self.getTime2() .. ', 在' ..LuaUIUtil.GetTextByID(tableData,'Name').. '中'..chin_name[self.sort_name]..'排行\n'
		local index = 1
		local total = 0
		for _,v in pairs(self.fight_data.statistics) do
			total = total + ( v[self.sort_name] or 0 )
		end
		for _,v in pairs(self.fight_data.statistics) do
			local percent = 0
			if total ~= 0 then
				percent = (v[self.sort_name] or 0) / total * 100
			end
			msg = msg .. string.format('%d %s %.0f(%.0f%%)\n', index, (v.actor_name or ''), (v[self.sort_name] or 0), percent)
			index = index + 1
		end
		ChatManager.SendMsg(msg, channel)
	end

	self.Sort = function(key)
		if self.sort_name then
			self.view['bgchoicebox'..self.sort_name]:SetActive(false)
			self.view['iconuparrow'..self.sort_name]:SetActive(false)
		end
		self.view['bgchoicebox'..key]:SetActive(true)
		self.view['iconuparrow'..key]:SetActive(true)
		self.sort_name = key

		if self.fight_data.statistics then
    		local tmp = {}
    		for i, v in pairs(self.fight_data.statistics) do
    			table.insert(tmp, v)
    		end
    		table.sort(tmp, function(a,b) return (a[key] or 0) > (b[key] or 0) end )
    		self.fight_data.statistics = tmp
    	end

    	self.refreshUI()
	end
	
	return self
end

return CreateFightStatisUICtrl()