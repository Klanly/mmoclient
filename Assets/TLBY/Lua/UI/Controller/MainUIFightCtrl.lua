---------------------------------------------------
-- auth： panyinglong
-- 主页面战斗面板
---------------------------------------------------
local const = require "Common/constant"

local FightType = {
	None = 0,
	Dungeon = 1,
	Arena = 2,
}
local function getKillMonsterCount()
	local killedMonster = SceneManager.GetEntityManager().QueryDeadPuppetAsArray(function(v)
		if v.entityType == EntityType.Monster then
			return true
		end
		return false
	end)
	return #killedMonster
end
function CreateMainUIFightCtrl(view)
    local self = CreateObject()
    self.view = view
    self.mgr = nil
    self.fightType = FightType.None

    local stm = networkMgr:GetConnection()
    local rectUI = self.view.dungeonProFg:GetComponent("RectTransform")
    local setProgress = function(pro)
		rectUI.sizeDelta = Vector2.New(pro * 190, rectUI.sizeDelta.y)
	end

	local targetRectUI = self.view.targetPro:GetComponent("RectTransform")
	local setTargetProgress = function(pro)
		targetRectUI.sizeDelta = Vector2.New(pro * 205, targetRectUI.sizeDelta.y)
	end
	local findTarget = function()
		local t = SceneManager.GetEntityManager().QueryPuppet(function(puppet)
			if puppet.entityType == EntityType.NPC and puppet.taskData.taskType == NPCTask.Defend then
				return true
			end
			return false
		end)
		return t
	end

	local show = function()
		self.view.dungeonInfo:SetActive(true)
	end
    local hide = function()
    	self.view.dungeonInfo:SetActive(false)
	end
    
    local init = function()
		self.fightType = FightType.None
		if SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then 			--主线副本
			self.mgr = MainDungeonManager
			self.fightType = FightType.Dungeon
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then  		--组队副本
			self.mgr = TeamDungeonManager
			self.fightType = FightType.Dungeon
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then  		--任务副本
			self.mgr = TaskDungeonManager
			self.fightType = FightType.Dungeon
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then  	--竞技场排位赛
			self.mgr = ArenaManager
			self.fightType = FightType.Arena
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then 	--竞技场混战赛
			self.mgr = ArenaManager
			self.fightType = FightType.Arena
		end
	end

    local dungeonTimer = nil
    local target = nil -- 分线对推保护单位
    self.startDungeon = function()
		self.view.dungeonmark:SetActive(true)
	    self.view.btnQuitFight:SetActive(true)
	    self.view.textKillCount:SetActive(true)

    	local dungeonData = SceneManager.GetCurSceneData()
    	local totalWave = 0
        local totalTime = dungeonData.Time/1000
        if dungeonData.type == 6 then -- 限时击杀
            self.view.textRestWave:SetActive(true)
            local wave = string.split(dungeonData.element2, '|')
            totalWave = #wave
        elseif dungeonData.type == 5 then -- 分线对推
        	self.view.targetObj:SetActive(true)
        	setTargetProgress(1)
        	target = findTarget()
        end
		if not dungeonTimer then
            dungeonTimer = Timer.Repeat(1, function()
            	if not self.mgr.markData then
            		self.view.textResttime:GetComponent("TextMeshProUGUI").text = ''
	            	self.view.textRestWave:GetComponent("TextMeshProUGUI").text = ''
            		return
            	end
            	if not self.mgr.isDungeonFinished then
            		self.view.dungeonmark:GetComponent('Image').sprite = LuaUIUtil.getDungeonMarkById(self.mgr.markData.mark)
		            local currentTime = stm.ServerSecondTimestamp - self.mgr.markData.start_time
		            local leftTime = totalTime - currentTime
		            if leftTime < 0 then
		                leftTime = 0
		                -- hide()
		            end
		            self.view.textResttime:GetComponent("TextMeshProUGUI").text = "剩余时间：" .. TimeToStr(leftTime)
		            self.view.textRestWave:GetComponent("TextMeshProUGUI").text = "剩余波次：" .. (totalWave - self.mgr.markData.current_wave) .. '/' .. totalWave
		            setProgress(leftTime / totalTime)

		            if not target then
		            	target = findTarget()
		            end
		            if target then
		            	setTargetProgress(target.hp/target.base_hp_max())
		            end

		            -- 如果在9秒时,给大倒计时
		            if leftTime == 9 then
		            	UIManager.LoadView(ViewAssets.ArenaTimerUI,nil,math.floor(leftTime),
						function()
						end,
						function(seconds, smallGo, bigGo)
							bigGo:SetActive(false)
							smallGo:SetActive(true)
							smallGo:GetComponent('TextMeshProUGUI').text = '副本结束倒计时 <size=80>' .. seconds .. '</size> 秒'
						end)
		            end
            	end
		        self.view.textKillCount:GetComponent("TextMeshProUGUI").text = "当前击杀:" .. getKillMonsterCount()
            end)
        end
	end
	self.stopDungeon = function()
		if dungeonTimer then
            Timer.Remove(dungeonTimer)
        end
        dungeonTimer = nil
        target = nil
        UIManager.UnloadView(ViewAssets.ArenaTimerUI)
	end
	
    ---- arena ---
    local onMatchInfoUpdate = function(ty, para, para2)
        if ty == 'fight_start' then
        	show()
            self.view.textResttime:GetComponent('TextMeshProUGUI').text = '剩余时间：'
        elseif ty == 'fight_tick' then
        	setProgress(para / para2)
            self.view.textResttime:GetComponent('TextMeshProUGUI').text = '剩余时间：' .. TimeToStr(para)
            -- 如果在9秒时,给大倒计时
            if para == 9 then
            	UIManager.LoadView(ViewAssets.ArenaTimerUI,nil,math.floor(para),
				function()
				end,
				function(seconds, smallGo, bigGo)
					bigGo:SetActive(false)
					smallGo:SetActive(true)
					smallGo:GetComponent('TextMeshProUGUI').text = '战斗结束倒计时 <size=80>' .. seconds .. '</size> 秒'
				end)
            end
        elseif ty == 'fight_stop' then
        	hide()
        end
	end
	self.startArena = function()
	    self.view.btnQuitFight:SetActive(true)
		if SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then
	    	self.view.btnFightStatus:SetActive(true)
		end
		ArenaManager.AddMatchListener(onMatchInfoUpdate)
	end
	self.stopArena = function()
		ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
		UIManager.UnloadView(ViewAssets.ArenaTimerUI)
	end

	local onQuitClick = function()
		if SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then 			--主线副本
			UIManager.ShowDialog('确定要退出主线副本吗', '确定', '取消', MainDungeonManager.RequstQuitDungeon)
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then  		--组队副本
			UIManager.ShowDialog("退出副本会得不到奖励，是否确定？",'确定','取消',TeamDungeonManager.RequestLeaveDungeon)
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then  		--任务副本
			UIManager.ShowDialog('确定要退出任务副本吗', '确定', '取消', TaskDungeonManager.RequestLevelTaskDungeon)
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then  	--竞技场排位赛
			UIManager.ShowDialog('确定要退出排位赛吗', '确定', '取消', ArenaManager.RequestQuitSingleFight)
		elseif SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then 	--竞技场混战赛
			local punish = LuaUIUtil.getQuitFightPunish()
			local str = '强制退出群雄逐鹿，极大影响他人游戏体验。会损失'.. punish.items .. '。并被禁赛' .. punish.time .. '。'
			UIManager.ShowDialog(str, '确定', '取消', ArenaManager.RequestQuitMixFight)
		end
	end
	local onFightStatusClick = function()
		if SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then
			local data = {}
			data.func_name = 'on_get_arena_dogfight_fight_score'
			MessageManager.RequestLua(constant.CD_MESSAGE_LUA_GAME_RPC, data)
		end
	end
    self.onLoad = function()
    	init()
		self.view.textResttime:GetComponent("TextMeshProUGUI").text = ''
		self.view.textRestWave:GetComponent("TextMeshProUGUI").text = ''
		self.view.textKillCount:GetComponent("TextMeshProUGUI").text = ''
		self.view.dungeonmark:SetActive(false)
        self.view.textRestWave:SetActive(false)
        self.view.targetObj:SetActive(false)
    	setProgress(0)
	    self.view.btnFightStatus:SetActive(false)
	    self.view.btnQuitFight:SetActive(false)

        ClickEventListener.Get(self.view.btnFightStatus).onClick = onFightStatusClick
        UIUtil.AddButtonEffect(self.view.btnFightStatus, nil, nil)
        ClickEventListener.Get(self.view.btnQuitFight).onClick = onQuitClick
        UIUtil.AddButtonEffect(self.view.btnQuitFight, nil, nil)

    	if self.fightType == FightType.Dungeon then
    		show()
    		self.startDungeon()
		elseif self.fightType == FightType.Arena then
			show()
			self.startArena()
		else
			hide()
		end
    end
    self.onUnload = function()
        self.stopDungeon()
        self.stopArena()
    end
    self.onLoad()
    return self
end