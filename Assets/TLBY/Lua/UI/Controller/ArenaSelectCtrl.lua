---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/1
-- desc： 竞技场入口
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local arenaScheme = GetConfig('challenge_arena')

local function CreateArenaSelectCtrl()
	local self = CreateCtrlBase()
	self.tabData = {}
	self.arenaData = nil

	self.openWildWar = true -- 是否可以混战

	local closeClick = function()
		self.close()
	end
	
	local okRankCombatClick = function()
		print("武林争霸")
		if not self.arenaData then
			print('正在等待服务器返回消息...')
			return
		end
		UIManager.LoadView(ViewAssets.ArenaMatch,nil,self.arenaData)
	end

	local okWildCombatClick = function()
		print("群雄逐鹿")
		if not self.arenaData then
			print('正在等待服务器返回消息...')
			return
		end
		UIManager.LoadView(ViewAssets.ArenaMixMatch,nil, ArenaManager.arenaData, true, constant.ARENA_TYPE.dogfight)
	end
	
	local onAddRankRestyime = function()	
		local consum = LuaUIUtil.getConsume(self.arenaData.arena_info.qualifying_buy_count, constant.ARENA_TYPE.qualifying)
		UIManager.ShowDialog("你确定花费<color=red>" .. consum .. "元宝</color>购买1次武林争霸挑战次数？", '确定', '取消',
			function()
				MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_BUY_COUNT, {type = constant.ARENA_TYPE.qualifying})
    		end)
	end
	local onAddMixRestyime = function()
		local consum = LuaUIUtil.getConsume(self.arenaData.arena_info.dogfight_buy_count, constant.ARENA_TYPE.dogfight)
		UIManager.ShowDialog("你确定花费<color=red>" .. consum .. "元宝</color>购买1次群雄逐鹿挑战次数？", '确定', '取消',
			function()
				MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_BUY_COUNT, {type = constant.ARENA_TYPE.dogfight})
    		end)
	end
	
	local OnBuyTimes = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.arenaData = data
		self.updateUI()
	end

	local onOpenScoreList = function()
		print("积分排行")
		UIManager.LoadView(ViewAssets.ArenaMixMatch, nil, ArenaManager.arenaData, false, constant.ARENA_TYPE.dogfight)
	end

	local onPanelChange = function(index, isactive)
		index = index + 1 -- C#从0开始
		local tab = self.tabData[index]
		if not tab then
			return
		end
		if tab.panel then
			tab.panel:SetActive(isactive)
		end
	end
	
	local initTabControl = function()
		local tabctl = self.view.gameObject:GetComponent('TabControl')
		tabctl:Clear()
		tabctl.OnPanelChanged = onPanelChange
		for i = 1, 6 do
			local t = {
				tab = self.view['btnpage' .. i], 
				panel = self.view['pagepanel' .. i]
			}
			table.insert(self.tabData, t)
			tabctl:AddTabPanel(t.tab)
		end
		tabctl:SetActivePanel(0)
	end

	local onUpdateArenaInfo = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end	
		self.arenaData = data
		self.updateUI()
	end
	self.updateUI = function()		
		local total = arenaScheme.Parameter[2].Value[1]
		local rest = total - self.arenaData.arena_info.qualifying_fight_count + self.arenaData.arena_info.qualifying_buy_count
		self.view.textbattlefrequency:GetComponent('TextMeshProUGUI').text = '今日剩余：' .. rest .. '/' .. total
		
		local function isOpenDofightToday()
			local w = os.date("%w",os.time()) 			-- [0 ~ 6 星期天~星期六]
			local options = arenaScheme.Parameter[22].Value 	-- [1 ~ 7 星期天~星期六]
			for _, v in pairs(options) do
				if (w + 1) == v then
					return true
				end
			end
			return false
		end
		local function getOpenDayStr()
			local s = ''
			local options = arenaScheme.Parameter[22].Value 	-- [1 ~ 7 星期天~星期六]
			for _, v in pairs(options) do
				if v == 1 then
					s = s .. '周日 '
				elseif v == 2 then
					s = s .. '周一 '
				elseif v == 3 then
					s = s .. '周二 '
				elseif v == 4 then
					s = s .. '周三 '
				elseif v == 5 then
					s = s .. '周四 '
				elseif v == 6 then
					s = s .. '周五 '
				elseif v == 7 then
					s = s .. '周六 '
				end
			end
			s = s .. '开放'
			return s
		end
		local function getOpenTimeStr()
			local start1 = string.format("%02d:%02d", arenaScheme.Parameter[1].Value[1], arenaScheme.Parameter[1].Value[2]) 
			local end1 = string.format("%02d:%02d", arenaScheme.Parameter[23].Value[1], arenaScheme.Parameter[23].Value[2]) 
			local start2 = string.format("%02d:%02d", arenaScheme.Parameter[24].Value[1], arenaScheme.Parameter[24].Value[2]) 
			local end2 = string.format("%02d:%02d", arenaScheme.Parameter[33].Value[1], arenaScheme.Parameter[33].Value[2]) 
			local s = '开放时间:' .. start1 .. " - " .. end1 .. "; " .. start2 .. " - " .. end2
			return s
		end
		if isOpenDofightToday() then
			total = arenaScheme.Parameter[19].Value[1]
			rest = total - self.arenaData.arena_info.dogfight_fight_count + self.arenaData.arena_info.dogfight_buy_count
			self.view.textbattlecondition:GetComponent('TextMeshProUGUI').text = '今日剩余：' .. rest .. '/' .. total
			self.view.textopentime:GetComponent('TextMeshProUGUI').text = getOpenTimeStr()
		else
			self.view.textbattlecondition:GetComponent('TextMeshProUGUI').text = getOpenDayStr()
			self.view.textopentime:GetComponent('TextMeshProUGUI').text = ''
		end
	end
	self.onLoad = function()
		initTabControl()

        ClickEventListener.Get(self.view.btnClose).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnClose, nil, nil)

        ClickEventListener.Get(self.view.btnRankingbattle).onClick = okRankCombatClick
        UIUtil.AddButtonEffect(self.view.btnRankingbattle, 'AutoGenerate/ArenaSelect/btnRankingbattledown', nil)

        ClickEventListener.Get(self.view.btnadd1).onClick = onAddRankRestyime
        UIUtil.AddButtonEffect(self.view.btnadd1, nil, nil)

		
        ClickEventListener.Get(self.view.btncommon1_1).onClick = onOpenScoreList
        UIUtil.AddButtonEffect(self.view.btncommon1_1, nil, nil)

        if self.openWildWar then
	    	self.setButtonEnable(self.view.btnwildwar, true)
	        ClickEventListener.Get(self.view.btnwildwar).onClick = okWildCombatClick
	        UIUtil.AddButtonEffect(self.view.btnwildwar, 'AutoGenerate/ArenaSelect/btnwildwardown', nil)
	        
		    ClickEventListener.Get(self.view.btnadd2).onClick = onAddMixRestyime
		    UIUtil.AddButtonEffect(self.view.btnadd2, nil, nil)
	    else
	    	self.setButtonEnable(self.view.btnwildwar, false)
	    	self.setButtonEnable(self.view.btnadd2, false)
	    end

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_INFO, {})
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)

		self.view.textbattlefrequency:GetComponent('TextMeshProUGUI').text = ''
		self.view.textbattlecondition:GetComponent('TextMeshProUGUI').text = ''
	end
	
	self.onUnload = function()
		self.tabData = {}
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)
	end
	
	return self
end

return CreateArenaSelectCtrl()