require "Common/basic/LuaObject"
local const = require "Common/constant"
local CreateDungeonManager = require "Logic/DungeonManager"

local function CreateTeamDungeonManager()
	local self = CreateDungeonManager()
    self.isDungeonFinished = true
    local teamDungeonTable = require'Logic/Scheme/challenge_team_dungeon'
    self.IsOnFighting = function() 
        return (
            SceneManager.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON and
            SceneManager.currentFightType == const.FIGHT_SERVER_TYPE.TEAM_DUNGEON)
    end
	local init = function()
        MessageRPCManager.AddUser(self, 'TeamDungeonEnd')
        MessageRPCManager.AddUser(self, 'UpdateDungeonMark')
	end

    
    self.OnRPCRect = function(data)
        if data.result == 0 and self[data.func_name] then
            self[data.func_name](data)
        end
    end
    
    self.EnterAoiSceneReply = function()
        UIManager.PushView(ViewAssets.MainLandUI)
    end
    
    self.PlayerLeaveTeamDungeonScene  = function(data)
        
    end
    
    self.GetSettingTable = function()
        return teamDungeonTable[teamDungeonTable.TeamDungeons[SceneManager.currentSceneId].SceneSetting]
    end
    
    self.TeamDungeonEnd = function(data)
        local delay = GetConfig('challenge_main_dungeon').Parameter[18].Value[1]/1000
        Timer.Delay(delay, function()
            if SceneManager.IsOnDungeonScene() then
                UIManager.GetCtrl(ViewAssets.MainLandUI).hide()
                UIManager.PushView(ViewAssets.ChallengeOverUI,nil,data)
            end
        end)
        self.isDungeonFinished = true
    end
    self.RequestLeaveDungeon = function()
        local data = {}
        data.func_name = 'on_leave_team_dungeon'
        MessageManager.RequestLua(constant.CD_MESSAGE_LUA_GAME_RPC, data) 
    end
    self.OnEnterFightScene = function()
        self.isDungeonFinished = false
    end
    
    self.UpdateDungeonMark = function(data)
        table.print(data, 'UpdateDungeonMark')
        self.markData = {}
        self.markData.mark = data.mark
        self.markData.start_time = data.start_time
        self.markData.current_wave = data.current_wave
        self.isDungeonFinished = data.over
    end
	init()
	return self
end

TeamDungeonManager = TeamDungeonManager or CreateTeamDungeonManager()