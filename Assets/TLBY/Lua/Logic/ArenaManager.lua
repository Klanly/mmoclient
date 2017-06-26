---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/6
-- desc： 竞技场管理
---------------------------------------------------
require "Common/basic/LuaObject"
local constant = require "Common/constant"

local ArenaConfig = GetConfig('challenge_arena')
local ArtConfig = GetConfig('common_art_resource')
local SceneConfig = GetConfig("common_scene")
local uitext = GetConfig("common_char_chinese").UIText
ArenaType = {
	None = 0,
	Single = 1,
	Mix = 2,	
}
-- occupy=true 是否有人占领成功,已经开始积分,只有为true时，下面２个字段才有意义
-- 		occupy_actor_id = 占领者id
-- 		occupy_actor_name = 占领者名字
-- plunder = true 是否有人抢夺，只有为true时，下面４个字段才有意义
-- 		plunder_actor_id = 抢夺者id
-- 		plunder_actor_name = 抢夺者名字
-- 		plunder_progress = 抢夺进度（时间，单位秒）
-- 		plunder_state = 抢夺状态 0表示暂停1表示开始
local function CreateScoreArea(data)
	local self = CreateObject()
	self.data = data
	self.gameObject = GameObject.New()
	self.transform = self.gameObject.transform

	local processBar = nil
	local blueObj = nil
	local redObj = nil

	self.isLoading = false
	local initResource = function()
		self.isLoading = true
		if IsNil(blueObj) then
			 ResourceManager.CreateEffect("Common/eff_common@FB_JJCduoqi_B",function(obj)
				blueObj = obj
				blueObj.transform:SetParent(self.transform)
				blueObj:SetActive(false)
				blueObj.transform.localPosition = Vector3.zero
				if self.isLoaded() then 
					self.isLoading = false
					self.onLoaded() 
				end
			end)
		end
		if IsNil(redObj) then
			 ResourceManager.CreateEffect("Common/eff_common@FB_JJCduoqi_R",function(obj)
				redObj = obj
				redObj.transform:SetParent(self.transform)
				redObj:SetActive(true)
				redObj.transform.localPosition = Vector3.zero
				if self.isLoaded() then 
					self.isLoading = false
					self.onLoaded() 
				end
			end)
		end
		
		local posdata = ArenaConfig.S2[80126]
		local pos = Vector3.New(posdata.PosX, posdata.PosY, posdata.PosZ)
		self.transform.position = pos

		UIManager.PushView(ViewAssets.RichProcessBarUI, function(ctrl)
			processBar = ctrl
			processBar.SetFollowTarget(self.transform, 0, 30)
			-- processBar.hide()
			processBar.UpdateFg('red')
			processBar.UpdateBg('red')
			processBar.UpdateText('')
			if self.isLoaded() then 
				self.isLoading = false
				self.onLoaded() 
			end
		end)
	end

	------ timer ---------
	local clock = os.clock()
	local deltaTime = function()
		local dt = os.clock() - clock
		clock = os.clock()
		return dt
	end

	local cur = 0
	local total = ArenaConfig.Parameter[28].Value[1]
	local tick = 0.1
	local plunderTimer = nil
	local onPlunder = function()
		cur = cur + deltaTime()
		if cur > total then
			cur = total
		end
		processBar.UpdateValue(cur/total)
	end
	local removePlunderTimer = function()
		-- print('removePlunderTimer ')
		if plunderTimer then
			Timer.Remove(plunderTimer)
		end
		plunderTimer = nil
		if processBar then
			processBar.UpdateValue(0)
			processBar.hide()
		end
	end
	local startPlunderTimer = function()
		-- print('startPlunderTimer ')
		removePlunderTimer()

		clock = os.clock()
		if self.data.occupy and self.data.plunder and self.data.occupy_actor_id == self.data.plunder_actor_id then -- 抢夺和占领为同一个人
			processBar.UpdateValue(1)
			processBar.UpdateText(self.data.occupy_actor_name .. '的占领点')
			if self.data.plunder_actor_id == MyHeroManager.heroData.entity_id then -- 自己抢自己
				processBar.UpdateBg('blue')
				processBar.UpdateFg('blue')
			else -- 别人抢别人(同一个人)
				processBar.UpdateBg('red')
				processBar.UpdateFg('red')
			end
		else -- 抢夺和占领为不同的人
			cur = self.data.plunder_progress
			if self.data.occupy_actor_id == MyHeroManager.heroData.entity_id then -- 别人抢自己
				processBar.UpdateBg('blue')
				processBar.UpdateFg('red')
			elseif self.data.plunder_actor_id == MyHeroManager.heroData.entity_id then -- 自己抢别人
				processBar.UpdateBg('red')
				processBar.UpdateFg('blue')
			else -- 别人抢别人(不同的人)
				processBar.UpdateBg('red')
				processBar.UpdateFg('red')
			end
			processBar.UpdateText(self.data.plunder_actor_name .. '正在抢夺..')
			plunderTimer = Timer.Repeat(tick, onPlunder)
		end
		processBar.show()
	end
	local stopPlunderTimer = function()
		-- print('stopPlunderTimer ')
		if plunderTimer then
			Timer.Stop(plunderTimer)
		end
	end
	local resumePlunderTimer = function()
		-- print('resumePlunderTimer ')
		if plunderTimer then
			Timer.Resume(plunderTimer)
		end
	end
	--------------------------
	self.isLoaded = function()
		return (processBar and blueObj and redObj)
	end

	self.onLoaded = function()
		self.Update(self.data)
	end

	self.Destroy = function()
		GameObject.Destroy(self.gameObject)
		blueObj = nil
		redObj = nil
		processBar = nil
		UIManager.UnloadView(ViewAssets.RichProcessBarUI)
		removePlunderTimer()
	end

	-- 更新颜色
	local updateColor = function()
		if blueObj== nil or redObj == nil then return end
		if (self.data.occupy and self.data.occupy_actor_id == MyHeroManager.heroData.entity_id) then
			blueObj:SetActive(true)
			redObj:SetActive(false)
		else
			blueObj:SetActive(false)
			redObj:SetActive(true)
		end
	end
	-- 更新进度
	local updatePlunder = function()
		-- print('updatePlunder ')
		if self.data.plunder == true then
			if self.data.plunder_state == 1 then
				startPlunderTimer()
			else
				stopPlunderTimer()
			end
		else
			removePlunderTimer()
		end
	end
	local updateOccupy = function()
		removePlunderTimer()
		if self.data.occupy then
			processBar.UpdateValue(1)
			if self.data.occupy_actor_id == MyHeroManager.heroData.entity_id then
				processBar.UpdateFg('blue')
				processBar.UpdateBg('blue')
			else
				processBar.UpdateFg('red')
				processBar.UpdateBg('red')
			end
			processBar.UpdateText(self.data.occupy_actor_name .. '的占领点')
			processBar.show()
		end
	end

	self.Update = function(data)
		self.data = data
		if not self.isLoaded() then
			return
		end
		updateColor()
		if self.data.plunder == true then 	 -- 当前有人正在抢夺
			updatePlunder()
		elseif self.data.occupy == true then -- 有人已经占领
			updateOccupy()
		end
	end
	initResource()
	return self
end
local function CreateBuffArea(data)
	local self = CreateObject()
	local buffItem = ArenaConfig.BUFF[data.buff]
	if not buffItem then
		error('not found buff id = ' .. data.buff)
		return
	end
	local item = ArtConfig.Model[buffItem.ModelID]
	if not item then
		error('not found buff model id = ' .. buffItem.ModelID)
		return
	end

	ResourceManager.CreateEffect(item.Prefab, function(obj)
		 self.gameObject = obj
		 self.gameObject.transform.position = Vector3.New(data.pos[1]/100, data.pos[2]/100, data.pos[3]/100)
		end)
	self.Destroy = function()
		if not IsNil(self.gameObject) then
			GameObject.Destroy(self.gameObject)
		end
	end
	return self
end
-- 混战赛控制器
local function CreateMixFightController()
	local self = CreateObject()
	local scoreAreaObject = nil
	local buffAreas = {}
		
	local onScoreArea = function(data)
		if not scoreAreaObject then
			scoreAreaObject = CreateScoreArea(data)
		end
	end

	local onOccupyInfo = function(data)
		table.print(data, '---- onOccupyInfo ----')
		if not scoreAreaObject then
			scoreAreaObject = CreateScoreArea(data)
		else
			scoreAreaObject.Update(data)
		end		
	end

	local onBuffListUpdate = function(data)
		if data.result ~= 0 then
			return
		end
		
		-- delete
		local deletes = {}
		for id, _ in pairs(buffAreas) do
			if not data.buffs[id] then -- 
				table.insert(deletes, id)
			end
		end
		for _, id in ipairs(deletes) do
			buffAreas[id].Destroy()
			buffAreas[id] = nil
		end

		-- add
		for id, buf in pairs(data.buffs) do
			if not buffAreas[id] then -- 当前没有这个id, 则新加一个buff
				local bufObj = CreateBuffArea(buf)
				buffAreas[id] = bufObj
			end
		end
	end

	self.Start = function()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_SCORE_AREA, onScoreArea)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_OCCUPY_INFO, onOccupyInfo)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_BUFF_LIST, onBuffListUpdate)
		buffAreas = {}
	end
	
	self.Stop = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_SCORE_AREA, onScoreArea)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_OCCUPY_INFO, onOccupyInfo)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_BUFF_LIST, onBuffListUpdate)
		
		if scoreAreaObject then
			scoreAreaObject.Destroy()
			scoreAreaObject = nil
		end
		for k, v in pairs(buffAreas) do
			v.Destroy()
		end
		buffAreas = {}
	end
	return self
end

local function CreateArenaManager()
	local self = CreateObject()
	self.arenaData = nil
	local matchEvent = CreateEvent()-- 比赛进行时间

	-- event
	local eventKey = 'OnMatchChange'
	self.AddMatchListener = function(func)
		matchEvent.AddListener(eventKey, func)
	end
	self.RemoveMatchListener = function(func)
		matchEvent.RemoveListener(eventKey, func)
	end

	self.isFightOver = false -- 是否正在战斗，结算之前
	local totaltime = 0
	local resttime = 0
	local fightTimer = nil
	local stopFightTimer = function()
		if fightTimer then
			Timer.Remove(fightTimer)
		end
		fightTimer = nil
		self.isFightOver = true
		matchEvent.Brocast(eventKey, 'fight_stop')
	end
	local startFightTimer = function(t)
		stopFightTimer()
		resttime = t
		totaltime = t
		self.isFightOver = false
		matchEvent.Brocast(eventKey, 'fight_start')
		fightTimer = Timer.Repeat(1, function()
			resttime = resttime - 1
			if resttime > 0 then
				matchEvent.Brocast(eventKey, 'fight_tick', resttime, totaltime)
			else
				matchEvent.Brocast(eventKey, 'fight_stop')
				stopFightTimer()
				return
			end
		end)
	end

	local arenaType = ArenaType.None
	self.IsOnFighting = function() -- 是否正在进行战斗
		return SceneManager.currentSceneType == constant.SCENE_TYPE.ARENA and
			(SceneManager.currentFightType == constant.FIGHT_SERVER_TYPE.QUALIFYING_ARENA or 
					SceneManager.currentFightType == constant.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA)
	end
	self.getArenaState = function()
		return arenaType
	end

	--------------------------------- 排位赛 --------------------------------------------
	local OnSingleFight = function(data)
		if data.result ~= 0 then
			return
		end
	end
	local OnStartSingleFight = function(data)
		if data.result ~= 0 then
			return
		end		

		local totalFightTime = ArenaConfig.Parameter[7].Value[1]/1000
		local readyTime = ArenaConfig.Parameter[6].Value[1]/1000
		local countdown = networkMgr:GetConnection():GetTimespanSeconds(data.fight_start_time + totalFightTime)
		startFightTimer(countdown)

		local delay = networkMgr:GetConnection():GetTimespanSeconds(data.fight_start_time)
		UIManager.LoadView(ViewAssets.ArenaTimerUI,nil,math.floor(delay),
			function()
			end,
			function(seconds, smallGo, bigGo)
				local image
				if seconds <= 3 and seconds >= 1 then
					bigGo:SetActive(true)
					smallGo:SetActive(false)
					bigGo:GetComponent('Image').sprite = ResourceManager.LoadSprite('ArenaTimer/n'..seconds)
				else
					bigGo:SetActive(false)
					smallGo:SetActive(true)
					smallGo:GetComponent('TextMeshProUGUI').text = '开战倒计时 <size=80>' .. seconds .. '</size> 秒'
				end
			end)
	end
	local OnQuitSingleFight = function(data)
		if data.result ~= 0 then
			return
		end
		stopFightTimer()
	end
	local OnOverSingleFight = function(data)
		if data.result ~= 0 then
			return
        end
        arenaType = ArenaType.None
		stopFightTimer()
	end

	-- 打完后服务端将主动推这个消息过来
	local OnResultSingleFight = function(data)
		if data.result ~= 0 then
			return
		end
		UIManager.GetCtrl(ViewAssets.MainLandUI).close()
		local delay = GetConfig('challenge_arena').Parameter[27].Value[1]/1000
		Timer.Delay(delay, function()
			UIManager.LoadView(ViewAssets.ArenaReward, nil,data)
		end)		
	end
	self.RequestSingleFight = function(ch_t, ch_op_t, opp_id, opp_rank)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_CHALLENGE, {
			challenge_type = ch_t,
			challenge_opponent_type = ch_op_t,
			opponent_id = opp_id,
			opponent_rank = opp_rank,
		})
	end
	self.RequestQuitSingleFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_QUALIFYING_GIFHT_QUIT, {})
	end
	self.RequestOverSingleFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_QUALIFYING_GIFHT_OVER, {})
	end

	-------------------------------------- 混战 ------------------------------------------- 
	

	self.isOnMatching = false
	self.isReadyMix = false
	self.predictTime = 300
	self.mixFightCtrl = CreateMixFightController()

	-- timer
	local matchTime = 0
	local matchTimer = nil
	local stopMatchTimer = function()
		if matchTimer then
			Timer.Remove(matchTimer)
		end
		matchTime = 0
		matchTimer = nil
		self.isOnMatching = false
		matchEvent.Brocast(eventKey, 'stop')
	end
	local startMatchTimer = function()
		stopMatchTimer()
		matchTimer = Timer.Repeat(1, function()
			matchTime = matchTime + 1
			matchEvent.Brocast(eventKey, 'tick', matchTime)
		end)
		self.isOnMatching = true
		UIManager.PushView(ViewAssets.ArenaMatchingUI)
		matchEvent.Brocast(eventKey, 'start')
	end

	-- 禁赛时间
	self.isOnForbidMixFight = false
	local forbidTimer = nil
	local stopForbidTimer = function()
		if forbidTimer then
			Timer.Remove(forbidTimer)
		end
		forbidTimer = nil
		matchEvent.Brocast(eventKey, 'forbid_stop')
		self.isOnForbidMixFight = false
	end
	local startForbidTimer = function()
		stopForbidTimer()
		forbidTimer = Timer.Repeat(1, function()
			if self.arenaData.arena_info.arena_dogfight_ban_time <= 0 then
				stopForbidTimer()
				return
			end
			self.arenaData.arena_info.arena_dogfight_ban_time = self.arenaData.arena_info.arena_dogfight_ban_time - 1
			matchEvent.Brocast(eventKey, 'forbid_tick', self.arenaData.arena_info.arena_dogfight_ban_time)
		end)
		self.isOnForbidMixFight = true
		UIManager.PushView(ViewAssets.ArenaMatchingUI)
		matchEvent.Brocast(eventKey, 'forbid_start')
	end

	-- 消息反馈
	local onStartMatchMixFight = function(data)
		if data.result ~= 0 then
			return
		end
		self.predictTime = data.predict_dogfight_matching_time
		startMatchTimer()
		self.isReadyMix = false
	end
	-- 匹配结果
	local onResultMatchMixFight = function(data)
		if data.result ~= 0 then
			stopMatchTimer()
			return
		end
	end
	-- 取消匹配
	local onCancelMatchMixFight = function(data)
		if data.result ~= 0 then
			return
		end
		self.isReadyMix = false
		stopMatchTimer()		
	end
	-- 创建场景
	local onCreateMixScene = function(data)
		if data.result ~= 0 then
			return
		end
		
	end
-- 进入场景
	local onEnterMixScene = function(data)
		if data.result ~= 0 then
			return
		end
	end
	-- 开始战斗
	local onStartMixFight = function(data)
		if data.result ~= 0 then
			return
		end
	end
	-- 结算
	local onResultMixFight = function(data)
		self.isReadyMix = false
		UIManager.UnloadView(ViewAssets.ArenaResult)
		UIManager.PushView(ViewAssets.ArenaResult,nil, data)
	end
	local onOverMixFight = function(data)
		self.isReadyMix = false
		if data.result ~= 0 then
			return
		end

		self.mixFightCtrl.Stop()
        arenaType = ArenaType.None

		stopFightTimer()
	end
	local onQuitMixFight = function(data)
		self.isReadyMix = false
		if data.result ~= 0 then
			return
		end

		self.mixFightCtrl.Stop()
        arenaType = ArenaType.None
		stopFightTimer()
	end
	
	self.RequestStartMatchMixFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_MATCHING, {})
	end
	self.RequestCancelMatchMixFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_DOGFIGHT_CANCEL_MATCHING, {})
		stopMatchTimer()
	end
	self.RequestOverMixFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_DOGFIGHT_FIGHT_OVER, {})
	end
	self.RequestQuitMixFight = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_DOGFIGHT_QUIT_FIGHT, {})
	end

	-- 当自己同意进入后反馈
	self.PlayerAgreeArenaReplyRet = function(data)
		stopMatchTimer()
		UIManager.PushView(ViewAssets.ArenaMatchingUI)
		self.isReadyMix = true
		matchEvent.Brocast(eventKey, 'fight_ready')
	end

	self.DogfightArenaStartRet = function(data)
		if data.result ~= 0 then
			return
		end
		self.isReadyMix = false
		stopMatchTimer()

		local delay = networkMgr:GetConnection():GetTimespanSeconds(data.start_fight_time)
		UIManager.LoadView(ViewAssets.ArenaTimerUI,nil,math.floor(delay),
			function()					
			end,
			function(seconds, smallGo, bigGo)
				local image
				if seconds <= 3 and seconds >= 1 then
					bigGo:SetActive(true)
					smallGo:SetActive(false)
					bigGo:GetComponent('Image').sprite = ResourceManager.LoadSprite('ArenaTimer/n'..seconds)
				else
					bigGo:SetActive(false)
					smallGo:SetActive(true)
					smallGo:GetComponent('TextMeshProUGUI').text = '开战倒计时 <size=80>' .. seconds .. '</size> 秒'
				end
			end)
		local totalFightTime = ArenaConfig.Parameter[21].Value[1]/1000
		local readyTime = ArenaConfig.Parameter[20].Value[1]/1000
		local countdown = networkMgr:GetConnection():GetTimespanSeconds(data.start_fight_time + totalFightTime) - readyTime
		startFightTimer(countdown)
		self.mixFightCtrl.Start()
	end
	self.ArenaDogfightRebirth = function(data)
		local delay = networkMgr:GetConnection():GetTimespanSeconds(data.rebirth_time)
		UIManager.LoadView(ViewAssets.ArenaTimerUI,nil,math.floor(delay),
			function()
			end,
			function(seconds, smallGo, bigGo)
				local image
				if seconds <= 3 and seconds >= 1 then
					bigGo:SetActive(true)
					smallGo:SetActive(false)
					bigGo:GetComponent('Image').sprite = ResourceManager.LoadSprite('ArenaTimer/n'..seconds)
				else
					bigGo:SetActive(false)
					smallGo:SetActive(true)
					smallGo:GetComponent('TextMeshProUGUI').text = '复活倒计时 <size=80>' .. seconds .. '</size> 秒'
				end
			end)
	end
	-- 总的ArenaInfo
	local onUpdateArenaInfo = function(data)
		if data.result ~= 0 then
			return
		end	
		self.arenaData = data
		if self.arenaData.arena_info.arena_dogfight_ban_time > 0 then
			startForbidTimer()
		end
	end

	local init = function()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)

		-- single fight
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_CHALLENGE, OnSingleFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_QUALIFYING_FIGHT, OnStartSingleFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_QUALIFYING_GIFHT_OVER, OnOverSingleFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_QUALIFYING_GIFHT_QUIT, OnQuitSingleFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_RESULT, OnResultSingleFight)

		-- mix fight 
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_MATCHING, onStartMatchMixFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_CANCEL_MATCHING, onCancelMatchMixFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_MATCHING_RESULT, onResultMatchMixFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_CREATE_SCENE, onCreateMixScene)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_ENTER_SCENE, onEnterMixScene)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_FIGHT_START, onStartMixFight)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_RESULT, onResultMixFight) 
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_FIGHT_OVER, onOverMixFight) 
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_DOGFIGHT_QUIT_FIGHT, onQuitMixFight)
		MessageRPCManager.AddUser(self,'ArenaRequestAgree')
		MessageRPCManager.AddUser(self,'DogfightMatchingFailBecausePlayerNotEnough')
		MessageRPCManager.AddUser(self,"PlayerDogfigtFightScoreChange")
		MessageRPCManager.AddUser(self,"PlayerAgreeArenaReplyRet")
		MessageRPCManager.AddUser(self, "DogfightArenaStartRet")
		MessageRPCManager.AddUser(self, 'GetArenaDogfightFightScore') 
		MessageRPCManager.AddUser(self, 'ArenaDogfightRebirth') 
	end

	self.ArenaRequestAgree = function(data)
		local delay = networkMgr:GetConnection():GetTimespanSeconds(data.agree_time)
		UIManager.ShowDialog(uitext[1135006].NR, uitext[1135008].NR, uitext[1135007].NR, function()
			Timer.Remove(agree_timer)
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, {func_name='on_arena_agree'})
		end, function()
			Timer.Remove(agree_timer)
			ArenaManager.RequestCancelMatchMixFight()
		end,"cancel",delay)

	end

	self.DogfightMatchingFailBecausePlayerNotEnough = function(data)
		self.isReadyMix = false
		UIManager.UnloadView(ViewAssets.DialogueUI)
		ArenaManager.RequestCancelMatchMixFight()
		UIManager.ShowTopNotice(uitext[1135009].NR)
		Timer.Delay(1, function()
			ArenaManager.RequestStartMatchMixFight()
		end)
	end

	self.PlayerDogfigtFightScoreChange = function(data)
		if data.addon > 0 then
			UIManager.ShowTopNotice(string.format(uitext[1135041].NR,data.addon))
		elseif data.addon < 0 then
			UIManager.ShowTopNotice(string.format(uitext[1135042].NR,math.abs(data.addon)))
		end
	end

	self.GetArenaDogfightFightScore = function(data)
		UIManager.UnloadView(ViewAssets.ArenaResult)
		UIManager.PushView(ViewAssets.ArenaResult,nil, data.score_data)
	end
	self.IsOnMatching = function()
		return self.isOnMatching
	end
	------------------------------------
	-- 进入战斗场景回调
	self.OnEnterFightScene = function()
		self.isReadyMix = false
		matchEvent.Brocast(eventKey, 'fight_enter')
		if SceneManager.currentFightType == constant.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then
			arenaType = ArenaType.Single
			
		elseif SceneManager.currentFightType == constant.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then
			arenaType = ArenaType.Mix
		end
	end
	
	init()
	return self
end

ArenaManager = ArenaManager or CreateArenaManager()