---------------------------------------------------
-- auth： panyinglong
-- date： 2016/9/20
-- desc： 主线副本管理
---------------------------------------------------
require "Common/basic/LuaObject"
require "Network/MessageManager"
require "Common/combat/Trigger/TriggersManager"
require "Logic/SceneManager"
require "Logic/Dungeon/Chapter"
require "Logic/Dungeon/Dungeon"
require "Logic/Dungeon/ChapterReward"
local CreateDungeonManager = require "Logic/DungeonManager"
local const = require "Common/constant"
local log = require "basic/log"

local function CreateMainDungeonManager()
	local self = CreateDungeonManager()
	self.isDungeonFinished = true
	self.currentDungeonId = nil

	-- self.lastNormalDungeonID = 1 -- 最后一次通关的关卡
	self.DungeonScheme = challengeMainDungeonScheme
	self.dungeons = {
		lastDungeonID = 1,
		dayCount = 0,-- 普通副本每日剩余次数
		totalDayCount = self.DungeonScheme.Parameter[1].Value[1],
		chapters = {},
	}

	local event = CreateEvent()
	local eventKey = 'OnDungeonValueChange'
	self.AddListener = function(func)
		event.AddListener(eventKey, func)
	end
	self.RemoveListener = function(func)
		event.RemoveListener(eventKey, func)
	end

	local updateDungeonData = function(...)
		local chapters = {...}
		if #chapters == 0 then
			return 
		end
		-- 普通副本
		self.dungeons.chapters = {}
		for i = 1, #chapters do
			self.dungeons.chapters[chapters[i]] = CreateChapter(chapters[i])
		end
	end

	local OnStartDungeon = function(data)
		log('maindungeon', 'recv start dungeon')
	end
	-- 进入战斗场景回调
	self.OnEnterFightScene = function(dungeonId)
		self.isDungeonFinished = false
		self.currentDungeonId = dungeonId
	end

	local OnEndDungeon = function(data)
		log('maindungeon', 'OnEndDungeon')			
		local delay = GetConfig('challenge_main_dungeon').Parameter[18].Value[1]/1000
		Timer.Delay(delay, function()
			if SceneManager.IsOnDungeonScene() then
            	UIManager.GetCtrl(ViewAssets.MainLandUI).hide()
				UIManager.PushView(ViewAssets.ChallengeOverUI,nil,data)
			end
		end)	
		self.isDungeonFinished = true	
		-- self.currentDungeonId = nil
	end

	local OnQuitDungeon = function(data)	
		log('maindungeon', 'OnQuitDungeon')
		self.currentDungeonId = nil
	end

	local OnSweepDungeon = function(data)
		log('maindungeon', 'OnSweepDungeon')
		UIManager.PushView(ViewAssets.Sweep,nil, data.rewards, 'AutoGenerate/Sweep/sweep', "恭喜你获得以下奖励", true, "确定")
	end

	local OnChapterReward = function(data)
		log('maindungeon', 'OnChapterReward')
		UIManager.PushView(ViewAssets.Sweep,nil, data.reward, 'AutoGenerate/Sweep/rewards', "恭喜你获得以下奖励", true, "确定")
	end

	-- 正在打副本
	self.IsOnDungeoning = function()
		return (
			SceneManager.currentSceneType == const.SCENE_TYPE.DUNGEON and
			SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON)
	end

	self.GetDungeon = function(id)
		for chapterid, chapterData in ipairs(self.dungeons.chapters) do
			local dungeon = chapterData.getDungeon(id)
			if dungeon then
				return dungeon
			end
		end	
		return nil
	end

	self.GetDayRestCount = function()
		return self.dungeons.dayCount;
	end

	self.RequstStartDungeon = function(dungeon)
		log('maindungeon', 'request start dungeon id=' .. dungeon.ID)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_START_DUNGEON, { dungeon_id = dungeon.ID })
	end

	self.RequstQuitDungeon = function()
		if not self.currentDungeonId then
			error('current dungeon id = nil')
		end
		log('maindungeon', 'request quit dungeon id=' .. self.currentDungeonId)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_QUIT_DUNGEON, { dungeon_id = self.currentDungeonId })	
	end

	self.RequstEndDungeon = function()
		if not self.currentDungeonId then
			error('current dungeon id = nil')
		end
		local data = {}
        data.func_name = 'on_leave_main_dungeon'
        MessageManager.RequestLua(constant.CD_MESSAGE_LUA_GAME_RPC, data) 
		log('maindungeon', 'request end dungeon id=' .. self.currentDungeonId)
	end

	self.RequestSweepDungeon = function(dungeon_id)
		if dungeon_id then
			log('maindungeon', 'request sweep dungeon id=' .. dungeon_id)
			MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_DUNGEON_SWEEP, {dungeon_id = dungeon_id})	
		end
	end

	self.RequestChapterReward = function(chapter, rank)
		log('maindungeon', 'request chapter reward chapter=' .. chapter .. ', rank=' .. rank)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CHAPTER_REWARD, {chapter = chapter, rank = rank})			
	end

	local updateBestTime = function(data)
		for id, besttime in pairs(data) do
			local dungeon = self.GetDungeon(id)
			if dungeon then
				dungeon.UpdateBestGrade(besttime)
			end
		end

		for chapterid, chapterData in pairs(self.dungeons.chapters) do
			chapterData.updateSNum()
		end	
	end

	-- 章节奖励的状态
	local updateChapterReward = function(data)
		for chapter, chapterData in pairs(self.dungeons.chapters) do
			if data[chapter] then
				chapterData.udpateRewardState(data[chapter])
			end
		end
		event.Brocast(eventKey, 'ChapterReward')
	end

	local updateLockDungeon = function()
		local chapters = self.dungeons.chapters
		for _, chapter in pairs(chapters) do
			for id, dungeon in pairs(chapter.dungeons) do
				if dungeon.bestGrade == DungeonGrade.Locked then
					if dungeon.ID == self.dungeons.lastDungeonID then
						dungeon.bestGrade = DungeonGrade.NotPass
					elseif dungeon.ID < self.dungeons.lastDungeonID then
						dungeon.bestGrade = DungeonGrade.C					
					end
				end
			end
		end
	end

	local OnLoginData = function(data)
		updateDungeonData(1,2,3,4,5)
		if data.login_data then
			if data.login_data.dungeon_unlock then
				self.dungeons.lastDungeonID = data.login_data.dungeon_unlock
				updateLockDungeon()
			end
			if data.login_data.daily_normal_times then
				self.dungeons.dayCount = data.login_data.daily_normal_times
			end

			if data.login_data.normal_best_time then				
				updateBestTime(data.login_data.normal_best_time)
			end

			if data.login_data.chapter_reward then
				updateChapterReward(data.login_data.chapter_reward)
			end
			event.Brocast(eventKey, 'ChapterInfo')
		end
	end

	local OnUpdateData = function(data)
		if data.dungeon_unlock then
			self.dungeons.lastDungeonID = data.dungeon_unlock
			updateLockDungeon()
		end
		if data.daily_normal_times then
			self.dungeons.dayCount = data.daily_normal_times
		end

		if data.normal_best_time then
			updateBestTime(data.normal_best_time)
		end

		if data.chapter_reward then
			updateChapterReward(data.chapter_reward)
		end
		event.Brocast(eventKey, 'ChapterInfo')
	end

	self.PlayerLeaveMainDungeonScene = function(data)
		log('maindungeon', 'PlayerLeaveMainDungeonScene')
		self.currentDungeonId = nil		
	end


	self.UpdateDungeonMark = function(data)
        self.markData = {}
		self.markData.mark = data.mark
		self.markData.start_time = data.start_time
		self.markData.current_wave = data.current_wave
		self.isDungeonFinished = data.over
	end
	local Init = function()

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_START_DUNGEON, OnStartDungeon)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_END_DUNGEON, OnEndDungeon)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_QUIT_DUNGEON, OnQuitDungeon)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, OnLoginData)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_DUNGEON_SWEEP, OnSweepDungeon)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_CHAPTER_REWARD, OnChapterReward)
		MessageRPCManager.AddUser(self, 'UpdateDungeonMark')


	end

	-----------------------------------------------------------------
	

	Init()
	return self
end

MainDungeonManager = MainDungeonManager or CreateMainDungeonManager()