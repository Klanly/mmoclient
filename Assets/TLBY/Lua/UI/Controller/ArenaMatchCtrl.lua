---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/5
-- desc： 匹配
---------------------------------------------------

local constant = require "Common/constant"
local arenaScheme = GetConfig('challenge_arena')

local minNormalIndex = 2 -- 排位赛第 minNormalIndex 到第 maxNormalIndex 个位置
local maxNormalIndex = 4
local upgradeIndex = 1
local upgradeLevel = 10

local function CreateArenaMatchCtrl()
	local self = CreateCtrlBase()
	self.normalPlayers = {}
	self.upgradePlayer = nil

	local closeClick = function()
		self.close()
		UIManager.PushView(ViewAssets.ArenaSelect)
	end

	local restTime = 0
	local nextStartTimer = nil
	local stopTimer = function()
		if nextStartTimer then
			Timer.Remove(nextStartTimer)
		end
		nextStartTimer = nil
		restTime = 0
		self.setButtonEnable(self.view.btnresettime, false)
		self.view.textDekarontime.gameObject:SetActive(false)
	end

	local startTimer = function(seconds)
		self.view.textDekarontime:GetComponent('TextMeshProUGUI').text = ''
		stopTimer()
		restTime = seconds
		self.view.textDekarontime.gameObject:SetActive(true)
		self.setButtonEnable(self.view.btnresettime, true)
		nextStartTimer = Timer.Repeat(1, function()
			restTime = restTime - 1
			local timestr = TimeToStr(restTime)
			self.view.textDekarontime:GetComponent('TextMeshProUGUI').text = timestr .. '<color="white">后可再次挑战</color>'
			if restTime <= 0 then
				stopTimer()
			end

	        local cost = math.floor((restTime + 60)/60) * arenaScheme.Parameter[4].Value[1]
	        self.view.textresttimeCost:GetComponent('TextMeshProUGUI').text = cost
		end)
	end

	local restFightNum = 0
	local onUpdateArenaInfo = function(data)
		self.arenaData = data or self.arenaData
		self.view.textranking:GetComponent('TextMeshProUGUI').text = self.arenaData.arena_info.qualifying_rank
		self.view.textfctitle:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.property[constant.PROPERTY_NAME_TO_INDEX.spritual]

		local total = arenaScheme.Parameter[2].Value[1]
		local rest = total - self.arenaData.arena_info.qualifying_fight_count + self.arenaData.arena_info.qualifying_buy_count
		self.view.textResidualfrequency:GetComponent('TextMeshProUGUI').text = '今日剩余次数：' .. rest .. '/' .. total
		if rest <= 0 then -- 不用
			self.view.textDekarontime.gameObject:SetActive(false)
			stopTimer()
		else
			self.view.textDekarontime.gameObject:SetActive(true)
			startTimer(self.arenaData.arena_info.next_fight_time)
		end
		restFightNum = rest

		local grade = LuaUIUtil.getGradeText(self.arenaData.arena_info.grade_id)
		self.view.texbtnRankingList1:GetComponent('TextMeshProUGUI').text = grade.main
		self.view.texbtnRankingLis2:GetComponent('TextMeshProUGUI').text = grade.sub
	end

	local setteamClick = function()
		UIManager.PushView(ViewAssets.ArenaPetSetting,nil,self.arenaData)
	end

	local onFightClick = function(index)
		if restFightNum <= 0 then
			UIManager.ShowNotice('没有剩余次数了')
			return
		end
		if restTime > 0 then
			TimeToStr(restTime)
			UIManager.ShowNotice(TimeToStr(restTime) .. '后才可以挑战')
			return
		end

		if index >= minNormalIndex and index <= maxNormalIndex then
			local i = index - minNormalIndex + 1
			if self.normalPlayers[i] then
				ArenaManager.RequestSingleFight(
					constant.ARENA_CHALLENGE_TYPE.normal, 
					constant.ARENA_CHALLENGE_OPPONENT_TYPE.player,
					self.normalPlayers[i].actor_id,
					self.normalPlayers[i].rank)
			else
				print('没有该对手')
			end
		else
			if self.arenaData.arena_info.qualifying_rank <= upgradeLevel then
				if self.upgradePlayer then
					local actor_id = nil
					local rank = nil
					if self.upgradePlayer.type == constant.ARENA_CHALLENGE_OPPONENT_TYPE.player then
						actor_id = self.upgradePlayer.opponent_data.actor_id
						rank = self.upgradePlayer.opponent_data.rank
					else
						actor_id = self.upgradePlayer.opponent_data.grade_id
						rank = self.upgradePlayer.opponent_data.rank
					end
					ArenaManager.RequestSingleFight(
						constant.ARENA_CHALLENGE_TYPE.upgrade, 
						self.upgradePlayer.type,
						actor_id,
						rank)
				end
			else
				UIManager.ShowNotice(uiText(1135001))
			end
		end
	end

	local onPlayerDetailClick = function(index)
		-- UIManager.PushView(ViewAssets.RoleUI)
		print('玩家详情')
	end

	local onResetTime = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.arenaData = data
		onUpdateArenaInfo(self.arenaData)
	end
	
	local onResetTimeClick = function()
		if restTime <= 0 then
			return
		end
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_COOLING, {})
	end

	local canRefreshPlayer = true
	local onRefreshPlayerClick = function()
		if not canRefreshPlayer then
			return
		end
		canRefreshPlayer = false
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_REFRESH, {})
		self.setButtonEnable(self.view.btnrefreshplayer, false)
		Timer.Delay(arenaScheme.Parameter[34].Value[1], function()
			if self.isLoaded then
				self.setButtonEnable(self.view.btnrefreshplayer, true)
				canRefreshPlayer = true
			end
		end)
	end

	local onRanklistClick = function()		
		self.close()		
		UIManager.PushView(ViewAssets.ArenaRankList,nil, constant.ARENA_TYPE.qualifying)
	end

	local OnBuyTimes = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.arenaData = data
		onUpdateArenaInfo(self.arenaData)
	end

	local buyTimeClick = function()	
		local consum = LuaUIUtil.getConsume(self.arenaData.arena_info.qualifying_buy_count, constant.ARENA_TYPE.qualifying)
		UIManager.ShowDialog("你确定花费<color=red>" .. consum .. "元宝</color>购买1次武林争霸挑战次数？", '确定', '取消',
			function()
				MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_BUY_COUNT, {type = constant.ARENA_TYPE.qualifying})
    		end)
	end
	
	local clearUI = function()
		for i = 1, 4 do
			self.view['textname' .. i]:GetComponent('TextMeshProUGUI').text = ''
			self.view['level' .. i]:GetComponent('TextMeshProUGUI').text = ''
			self.view['rank' .. i]:GetComponent('TextMeshProUGUI').text = ''
			self.view['sprite' .. i]:GetComponent('TextMeshProUGUI').text = ''
			self.view['head' .. i]:SetActive(false)
		end
	end
	
	local getFightNPCInfo = function(gradeId)
		local info = {}
		local npcCfg = nil
		for k, v in pairs(arenaScheme.GradeKeeper) do
			if v.GradeID == gradeId then
				npcCfg = v
				break
			end
		end
		if not npcCfg then
			error('没有找到守门npc gradeid=' .. gradeId)
		end
		info.name = npcCfg.Name1
		local monsterData = arenaScheme.MonsterSetting[npcCfg.MonsterID]
		if not monsterData then
			error('没有找到守门npc MonsterSetting gradeid=' .. gradeId)
		end
		info.level = monsterData.Level
		return info
	end

	local OnRefreshPlayer = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.normalPlayers = {}
		self.upgradePlayer = nil
		if data.opponent_data then
			if data.opponent_data.normal_opponents then
				for k, v in pairs(data.opponent_data.normal_opponents) do
					-- level = 1,
     --                fight_power = 1175,
     --                spritual = 0,
     --                total_rank = 108,
     --                qualifying_score = 0,
     --                union_name = ,
     --                rank = 194,
     --                actor_id = 58dcf930728b1d742dd6978f,
     --                grade_id = 101,
     --                actor_name = 熊实群,
     --                total_score = 0,
     --                sex = 2,
     --                vocation = 2,
					table.insert(self.normalPlayers, v)
				end
			end
			table.sort(self.normalPlayers, function(a, b)
				return a.rank < b.rank
			end)
			if data.opponent_data.upgrade_opponent then
				self.upgradePlayer = data.opponent_data.upgrade_opponent
			end
		end

		clearUI()
		
		local playerIndex = 1
		for i = 1, 4 do
			if i == upgradeIndex then
				if self.upgradePlayer then
					if self.upgradePlayer.type == constant.ARENA_CHALLENGE_OPPONENT_TYPE.player then --　玩家
						self.view['textname' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = self.upgradePlayer.opponent_data.actor_name
						self.view['level' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "lv:" .. self.upgradePlayer.opponent_data.level
						self.view['rank' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "排名：" .. self.upgradePlayer.opponent_data.rank
						self.view['sprite' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "灵力：" .. self.upgradePlayer.opponent_data.spritual						
					else -- npc
						local gradeId = self.upgradePlayer.opponent_data.grade_id
						local npc = getFightNPCInfo(gradeId)
						self.view['textname' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = npc.name
						self.view['level' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "lv:" .. npc.level
						self.view['rank' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "排名：" .. self.upgradePlayer.opponent_data.rank
						self.view['sprite' .. upgradeIndex]:GetComponent('TextMeshProUGUI').text = "灵力：" .. ''
					end
					self.view['head' .. upgradeIndex]:SetActive(true)
					
					if self.arenaData.arena_info.qualifying_rank <= upgradeLevel then
						self.setButtonEnable(self.view['btnfight' .. i], true)
					else
						self.setButtonEnable(self.view['btnfight' .. i], false)
					end
				else
					self.setButtonEnable(self.view['btnfight' .. upgradeIndex], false)
				end				
			end
			if i >= minNormalIndex and i <= maxNormalIndex then
				if self.normalPlayers[playerIndex] then
					self.setButtonEnable(self.view['btnfight' .. i], true)
					
					self.view['textname' .. i]:GetComponent('TextMeshProUGUI').text = self.normalPlayers[playerIndex].actor_name
					self.view['level' .. i]:GetComponent('TextMeshProUGUI').text = "lv:" .. self.normalPlayers[playerIndex].level
					self.view['rank' .. i]:GetComponent('TextMeshProUGUI').text = "排名：" .. self.normalPlayers[playerIndex].rank
					self.view['sprite' .. i]:GetComponent('TextMeshProUGUI').text = "灵力：" .. self.normalPlayers[playerIndex].spritual
					self.view['head' .. i]:GetComponent('Image').sprite = LuaUIUtil.GetHeroImage(self.normalPlayers[playerIndex].vocation, self.normalPlayers[playerIndex].sex)
					self.view['head' .. i]:SetActive(true)
					playerIndex = playerIndex + 1
				else
					self.setButtonEnable(self.view['btnfight' .. i], false)
				end
			end
		end
	end

	local onHelpClick = function()		
		UIManager.PushView(ViewAssets.TipsUI,nil, 31270016)
	end
	local onOpenShopClick = function()
		UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('arena')
	end
	
	self.updateArenaInfo = function()	
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_INFO, {})
	end
	local OnPetSetting = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.arenaData = data
		onUpdateArenaInfo(self.arenaData)
	end
	self.onLoad = function(arenaData)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_REFRESH, OnRefreshPlayer)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)	
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_COOLING, onResetTime)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_PET_SETTING, OnPetSetting)
		if not arenaData then
			self.updateArenaInfo()
		else
			onUpdateArenaInfo(arenaData)
		end

        ClickEventListener.Get(self.view.btnadd).onClick = buyTimeClick
        UIUtil.AddButtonEffect(self.view.btnadd, nil, nil)

		onRefreshPlayerClick()
		self.setButtonEnable(self.view.btnrefreshplayer, true)
		canRefreshPlayer = true

        ClickEventListener.Get(self.view.btnReturn).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnReturn, nil, nil)

        ClickEventListener.Get(self.view.btnsetteam).onClick = setteamClick
        UIUtil.AddButtonEffect(self.view.btnsetteam, nil, nil)

        ClickEventListener.Get(self.view.btnresettime).onClick = onResetTimeClick
        UIUtil.AddButtonEffect(self.view.btnresettime, nil, nil)        
        
        ClickEventListener.Get(self.view.btnrefreshplayer).onClick = onRefreshPlayerClick
        UIUtil.AddButtonEffect(self.view.btnrefreshplayer, nil, nil)

        ClickEventListener.Get(self.view.btnRankingList).onClick = onRanklistClick
        UIUtil.AddButtonEffect(self.view.btnRankingList, nil, nil)

        ClickEventListener.Get(self.view.btnrule).onClick = onHelpClick
        UIUtil.AddButtonEffect(self.view.btnrule, nil, nil)

        ClickEventListener.Get(self.view.textIntegralshop).onClick = onOpenShopClick
        UIUtil.AddButtonEffect(self.view.textIntegralshop, nil, nil)


        -- self.view.textresettime:GetComponent('TextMeshProUGUI').text = "重置时间"  
        local cost = math.floor((restTime + 60)/60) * arenaScheme.Parameter[4].Value[1]
        self.view.textresttimeCost:GetComponent('TextMeshProUGUI').text = cost

		clearUI()
        for i = 1, 4 do
        	UIUtil.AddButtonEffect(self.view['btnfight' .. i], nil, nil)
        	ClickEventListener.Get(self.view['btnfight' .. i]).onClick = function() 
        		onFightClick(i)
        	end

        	UIUtil.AddButtonEffect(self.view['head' .. i], nil, nil)
        	ClickEventListener.Get(self.view['head' .. i]).onClick = function() 
        		onPlayerDetailClick(i)
        	end
        end
	end
	
	self.onUnload = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_REFRESH, OnRefreshPlayer)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_COOLING, onResetTime)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_PET_SETTING, OnPetSetting)
		stopTimer()
	end
	
	return self
end

return CreateArenaMatchCtrl()