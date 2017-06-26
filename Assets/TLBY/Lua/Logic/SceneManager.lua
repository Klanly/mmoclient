---------------------------------------------------
-- auth： panyinglong
-- date： 2016/9/20
-- desc： 场景管理
---------------------------------------------------
require "Common/basic/LuaObject"
require "Network/MessageManager"
require "Common/basic/Event"
require "Common/basic/SceneObject"
local log = require "basic/log"
local uitext = GetConfig("common_char_chinese").UIText
local CreateCombatScene = require "Common/CombatScene"

local commonSceneScheme = require"Logic/Scheme/common_scene"
local const = require "Common/constant"

local function CreateSceneManager()
	local self = CreateSceneObject()
	local event = CreateEvent()

	self.switchScenePos = nil -- 用于测试
	self.isTestModel = false -- 是否在测试模式,比如从主界面临时进入场景

	self.isSceneLoading = false -- 场景是正在加载

	self.currentSceneId = 0 -- 注：这个是服务端记录的当前场景, 如果是副本则为副本id,如果是竞技场则为竞技场景id
	self.currentSceneResourceId = nil -- 场景地图id
	self.currentSceneType = nil		-- 场景类型　const.SCENE_TYPE
	self.currentFightSceneId = nil -- 战斗场景id
	self.currentFightType = nil 	-- 战斗服类型　const.FIGHT_SERVER_TYPE
	self.currentResID = nil  --场景资源ID用于分段加载的判断
    self.LightAndShadow = nil
	self.currentAoiSceneId = 0	--当前AOI场景ID

    self.lastFightType = nil
    self.rankNoticeData = nil
	-- 场景容器，包含了Timer，TriggerManager，EntityManager
	self.scene = CreateCombatScene()	

	self.currentScenes = {}
	self.GetRPCMSGCode = function()
		if self.IsOnFightServer() then
			return const.CD_MESSAGE_LUA_GAME_RPC
		else
			return const.CS_MESSAGE_LUA_GAME_RPC
		end
	end
	-- 获取当前服务器的场景id
	self.GetCurServerSceneId = function()
		if self.IsOnFightServer() then
			return self.currentFightSceneId
		else
			return self.currentAoiSceneId
		end		
	end

	self.GetCurSceneData = function()
		if self.currentSceneType == const.SCENE_TYPE.WILD or self.currentSceneType == const.SCENE_TYPE.CITY then
			return GetConfig('common_scene').MainScene[self.currentSceneId]
		elseif self.currentSceneType == const.SCENE_TYPE.ARENA then
			return GetConfig('challenge_arena').ArenaScene[self.currentSceneId]
		elseif self.currentSceneType == const.SCENE_TYPE.DUNGEON then
			return GetConfig('challenge_main_dungeon').NormalTranscript[self.currentSceneId]
		elseif self.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON then
			return GetConfig('challenge_team_dungeon').TeamDungeons[self.currentSceneId]
		elseif self.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON then
			return GetConfig('system_task').MainTaskTranscript[self.currentSceneId]
		elseif self.currentSceneType == const.SCENE_TYPE.FACTION then
			return GetConfig('system_faction').GangMap[self.currentSceneId]
		end
	end
	
	-- 获取当前场景的元素布局表
	self.GetCurSceneLayoutScheme = function()
		local schemes = self.GetCurBigScheme()
		return schemes[self.GetCurSceneData().SceneSetting]
	end
	-- 获取当前场景的地图数据
	self.GetCurSceneMapData = function()
		local curData = SceneManager.GetCurSceneData()
        return GetConfig('common_scene').TotalScene[curData.SceneID]
	end	


	self.GetCurBigScheme = function()
		if self.currentSceneType == const.SCENE_TYPE.WILD or self.currentSceneType == const.SCENE_TYPE.CITY then
			return GetConfig('common_scene')
		elseif self.currentSceneType == const.SCENE_TYPE.ARENA then
			return GetConfig('challenge_arena')
		elseif self.currentSceneType == const.SCENE_TYPE.DUNGEON then
			return GetConfig('challenge_main_dungeon')
		elseif self.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON then	
			return GetConfig('challenge_team_dungeon')
		elseif self.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON then
			return GetConfig('system_task')
		elseif self.currentSceneType == const.SCENE_TYPE.FACTION then
			return GetConfig('system_faction')
		end
	end
	self.IsOnFightServer = function()
		return (self.currentSceneType == const.SCENE_TYPE.ARENA or 
			self.currentSceneType == const.SCENE_TYPE.DUNGEON or 
			self.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON or
			self.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON)
	end
	self.IsOnDungeonScene = function()
		return (self.currentSceneType == const.SCENE_TYPE.DUNGEON or 
			self.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON or
			self.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON)
	end
	self.IsOnCityOrWild = function()
		return (self.currentSceneType == const.SCENE_TYPE.WILD or self.currentSceneType == const.SCENE_TYPE.CITY)
	end
	------------------------------
	self.LoadScene = function(data, OnFinish)
		self.ClearCurrentScene()
		self.isSceneLoading = true
        self.currentResID = data.scene_resource_id 
		local name = commonSceneScheme.TotalScene[self.currentResID].ResourceID
        UIManager.ShowLoadingUI(data.scene_id)
        
		Util.LoadScene(name, function()
			self.isSceneLoading = false
			self.sceneResName = name
			ResourceManager.CreateModel( "LightAndShadow",function(obj)	self.LightAndShadow = obj end) --加载灯光和阴影元素
			if OnFinish then
				OnFinish(name)
			end
			if self.currentSceneType then
				local schemes = self.GetCurBigScheme()
				self.scene:SetScheme(schemes, self.GetCurSceneData().SceneSetting)
   --  			self.scene:GetTriggersManager():OnGameBegin(schemes[self.GetCurSceneData().SceneSetting])
    		end
    		MessageManager.FireCacheMsg() -- 清理掉缓存消息
		end)
	end
	
	self.EnterScene = function(name,OnFinish)
		self.ClearCurrentScene()
		self.isSceneLoading = true
		UIManager.ShowLoadingUI()
		Util.LoadScene(name, function()
			self.isSceneLoading = false
			self.sceneResName = name
			if OnFinish then
				OnFinish()
			end
            MessageManager.FireCacheMsg() -- 清理掉缓存消息
		   end)
	end

	self.AddLoginListener = function(handler)
		event.AddListener('OnLoginEvent', handler)
	end	
	self.RemoveLoginListener = function(handler)
		event.RemoveListener('OnLoginEvent', handler)
	end

	-------------------------------------------------------------
	-- 请求服务器进入场景
	local OnFinishCallBack = nil
	local OnLoadScene = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			Game.SetCanSyncMsg(true) 
			return 
		end
		log('scene', "recive loaded scene id=" .. data.scene_id)
		if OnFinishCallBack then
			OnFinishCallBack()
		end				 
        CameraManager.CameraController.gameObject:SetActive(true)
		OnFinishCallBack = nil
		Game.SetCanSyncMsg(true) 
		UIManager.LoadView(ViewAssets.MainLandUI)
		-- UIManager.LoadCacheViews()
		-- UIManager.ClearCacheViews()
        local data = {}
		data.func_name = 'on_get_client_config'
		MessageManager.RequestLua(const.CS_MESSAGE_LUA_GAME_RPC, data)        --请求客户端存储设置
		if self.currentSceneType == const.SCENE_TYPE.CITY or self.currentSceneType == const.SCENE_TYPE.WILD then
			self.GetEntityManager().CreateSceneNPC(SceneManager.GetCurSceneLayoutScheme())
		end

		-- 从战斗服出来,要重新打开相关的UI
		if self.lastFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then
			UIManager.PushView(ViewAssets.ChallengeUI)
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then
			UIManager.GetCtrl(ViewAssets.TeamDungeonUI).OpenUI()
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then
			local ctrl = UIManager.GetCtrl(ViewAssets.ArenaMatch)
			if not ctrl.isLoaded then
				UIManager.PushView(ViewAssets.ArenaMatch)
			end
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then
			local ctrl = UIManager.GetCtrl(ViewAssets.ArenaMixMatch)
			if not ctrl.isLoaded then
				UIManager.PushView(ViewAssets.ArenaMixMatch, nil, ArenaManager.arenaData, true, const.ARENA_TYPE.dogfight)
			end
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then
		end
		self.lastFightType = nil
        if self.rankNoticeData then
            local param = {}
            if self.rankNoticeData.rank == 1 then
				param.msg = string.format(uitext[1135093].NR,'')
			else
				param.msg = string.format(uitext[1135094].NR,'',self.rankNoticeData.rank)
			end
			param.okHandler = function() UIManager.UnloadView(ViewAssets.ConfirmUI) end
			param.needHideClose = true
			UIManager.PushView(ViewAssets.ConfirmUI,function(ctrl) ctrl.Show(param) end)
        end
        self.rankNoticeData = nil
	end

    self.conveyDelay = false
    self.conveyCallBack = nil
	-- 主城野外(小地图，传送阵)，战斗服务出来
	local OnEnterScene = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			Game.SetCanSyncMsg(true) 
			return
		end
        
        local EnterScene = function()
            self.currentSceneId = data.scene_id
			self.currentAoiSceneId = data.aoi_scene_id
            self.currentSceneResourceId = data.scene_resource_id
            self.currentSceneType = data.scene_type
            self.currentFightSceneId = nil
            self.currentFightType = nil
            log('scene', 'receive enter SceneId= ' .. self.currentSceneId .. ', SceneResourceId = '.. self.currentSceneResourceId .. ", SceneType=" .. self.currentSceneType)
            self.LoadScene(data, function()
                log('scene', "request loaded scene over. ")
                MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LOADED_SCENE, {scene_id = data.scene_id})

            end)
        end

        if  self.conveyDelay then
            self.conveyCallBack = EnterScene
            self.conveyDelay = false
            return
        else
            self.conveyCallBack = nil
            EnterScene()
        end
	end

	self.OnLoadedFactionSceneRet = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			Game.SetCanSyncMsg(true)
			return
		end
		log('scene', "recive loaded scene id=" .. data.scene_id)
		if OnFinishCallBack then
			OnFinishCallBack()
		end
        CameraManager.CameraController.gameObject:SetActive(true)
		OnFinishCallBack = nil
		Game.SetCanSyncMsg(true)
		UIManager.LoadView(ViewAssets.MainLandUI)
		-- UIManager.LoadCacheViews()
		-- UIManager.ClearCacheViews()
        local data = {}
		data.func_name = 'on_get_client_config'
		MessageManager.RequestLua(const.CS_MESSAGE_LUA_GAME_RPC, data)        --请求客户端存储设置
		self.GetEntityManager().CreateSceneNPC(SceneManager.GetCurSceneLayoutScheme())

		-- 从战斗服出来,要重新打开相关的UI
		if self.lastFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then
			UIManager.PushView(ViewAssets.ChallengeUI)
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then
			UIManager.GetCtrl(ViewAssets.TeamDungeonUI).OpenUI()
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then
			local ctrl = UIManager.GetCtrl(ViewAssets.ArenaMatch)
			if not ctrl.isLoaded then
				UIManager.PushView(ViewAssets.ArenaMatch)
			end
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then
			local ctrl = UIManager.GetCtrl(ViewAssets.ArenaMixMatch)
			if not ctrl.isLoaded then
				UIManager.PushView(ViewAssets.ArenaMixMatch, nil, ArenaManager.arenaData, true, const.ARENA_TYPE.dogfight)
			end
		elseif self.lastFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then
		end
		self.lastFightType = nil
	end

	-- 进入帮派领地
	self.OnEnterFactionSceneRet = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			Game.SetCanSyncMsg(true)
			return
		end

        local EnterFactionScene = function()
            self.currentSceneId = data.scene_id
            self.currentSceneResourceId = data.scene_resource_id
            self.currentSceneType = data.scene_type
			self.currentAoiSceneId = data.aoi_scene_id
            self.currentFightSceneId = nil
            self.currentFightType = nil
            log('scene', 'receive enter SceneId= ' .. self.currentSceneId .. ', SceneResourceId = '.. self.currentSceneResourceId .. ", SceneType=" .. self.currentSceneType)
            self.LoadScene(data, function()
                log('scene', "request loaded scene over. ")
                MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, {func_name="on_loaded_faction_scene"})
            end)
        end

        if  self.conveyDelay then
            self.conveyCallBack = EnterFactionScene
            self.conveyDelay = false
            return
        else
            self.conveyCallBack = nil
            EnterFactionScene()
        end
	end
    
    self.GetDungeonHegemon = function(data)
        self.rankNoticeData = data
    end
    
    self.GetTeamDungeonHegemon = function(data)
        self.rankNoticeData = data
    end

	-- 清理当前场景
	self.ClearCurrentScene = function()
		log('scene', "clear scene currentSceneId:" .. (self.currentSceneId or 'nil') .. " currentFightSceneId:" .. (self.currentFightSceneId or 'nil'))
		Game.SetCanSyncMsg(false) 
	    self.scene:Clear()
		UIManager.UnloadAll(true)
		PKManager.Clear()
		self.currentFightSceneId = nil
		self.currentFightType = nil
		self.LightAndShadow = nil
		EntityBehaviorManager.ModelParent = nil
	end
	
	self.RequestEnterScene = function(sceneid, OnFinish)
		log('scene', "request enter scene id=" .. sceneid)
		OnFinishCallBack = OnFinish

		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ENTER_SCENE, {scene_id = sceneid})
		Game.SetCanSyncMsg(false) 
	end

	self.RequestEnterSceneWithMini = function(sceneid, OnFinish)
		log('scene', "request enter scene in mini id=" .. sceneid)
		OnFinishCallBack = OnFinish
		local data = {}
		data.func_name = 'on_mini_map_switch_scene'
		data.scene_id = sceneid
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, data)
		Game.SetCanSyncMsg(false) -- 先暂停向服务器发送同步移动消息 
	end
	----------------------------------
	-- aoi scene
	self.RequestEnterAOIScene = function(sceneid, OnFinish)
		log('scene', "request enter aoi scene id=" .. sceneid)
		OnFinishCallBack = OnFinish
		local data = {}
		data.func_name = 'on_enter_aoi_scene'
        data.aoi_scene_id = sceneid
		MessageManager.RequestLua(MSG.CD_MESSAGE_LUA_GAME_RPC, data)
		Game.SetCanSyncMsg(false) 
	end
	self.EnterAoiSceneReply = function(data)
		log('scene', "reply enter aoi scene")

		if OnFinishCallBack then
			OnFinishCallBack()
		end
		OnFinishCallBack = nil

		Game.SetCanSyncMsg(true) 
	end

	self.FightServerLoadSceneRet = function(data)
		-- UIManager.CacheLoadedViews()
		self.LoadScene(data, function()
			self.currentSceneId = data.scene_id 	-- 主城／野外则为场景id, 副本则为副本id，竞技场则为竞技场id(801/802)
			self.currentSceneResourceId = data.scene_resource_id -- 场景地图id
			self.currentSceneType = data.scene_type -- const.SCENE_TYPE.CITY/wild/arena/

			self.currentFightSceneId = data.aoi_scene_id
			self.currentFightType = data.fight_type -- const.FIGHT_SERVER_TYPE

			log('scene', 'receive enter fight SceneId= ' .. self.currentSceneId .. ', SceneResourceId = '.. self.currentSceneResourceId .. 
				", SceneType=" .. self.currentSceneType .. ', FightSceneId=' .. self.currentFightSceneId .. ', FightType=' .. self.currentFightType)
			self.RequestEnterAOIScene(self.currentFightSceneId)
            

            
			UIManager.LoadView(ViewAssets.MainLandUI)
	    	if self.currentFightType == const.FIGHT_SERVER_TYPE.MAIN_DUNGEON then 			--主线副本
				MainDungeonManager.OnEnterFightScene(self.currentSceneId)
			elseif self.currentFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON then  		--组队副本
				TeamDungeonManager.OnEnterFightScene()
			elseif self.currentFightType == const.FIGHT_SERVER_TYPE.QUALIFYING_ARENA then  	--竞技场排位赛
				ArenaManager.OnEnterFightScene()
			elseif self.currentFightType == const.FIGHT_SERVER_TYPE.DOGFIGHT_ARENA then 	--竞技场混战赛
				ArenaManager.OnEnterFightScene()
			elseif self.currentFightType == const.FIGHT_SERVER_TYPE.TASK_DUNGEON then  		--任务副本
				TaskDungeonManager.OnEnterFightScene(self.currentSceneId)
			end
			self.lastFightType = self.currentFightType
		end)
	end


	local OnLogin = function(data) 
		log('scene', "recive login result=" .. data.result)
		if data.login_data.fight_server_info then -- 服务端正在战斗服, 则登录后直接请求进入战斗服
			print('直接进入战斗服')
			ConnectionManager.ConnetFightServer(data.login_data.fight_server_info)
		else
			self.RequestEnterScene(data.login_data.scene_id, function()
				event.Brocast('OnLoginEvent', data)
			end)
		end
        ChatManager.Clear()
        ContactManager.ClearList()
        TeamManager.Clear()
	end
	
	self.Init = function()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ENTER_SCENE, OnEnterScene) -- 进入场景回调
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOADED_SCENE, OnLoadScene) -- 加载完场景回调
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, OnLogin)	

		MessageRPCManager.AddUser(self, 'EnterAoiSceneReply') 
		MessageRPCManager.AddUser(self, 'FightServerLoadSceneRet')
		MessageRPCManager.AddUser(self,	'OnEnterFactionSceneRet')
		MessageRPCManager.AddUser(self,	'OnLoadedFactionSceneRet')
        MessageRPCManager.AddUser(self,	'GetTeamDungeonHegemon')
		MessageRPCManager.AddUser(self,	'GetDungeonHegemon')
	end

	self.Init()
	return self
end

SceneManager = SceneManager or CreateSceneManager()