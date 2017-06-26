-- huasong --
require "Common/basic/LuaObject"

local function CreateTeamManager()
    local self = CreateObject()
    
    local tableData = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    local costTable = (require'Logic/Scheme/challenge_team_dungeon').Cost
    local const = require "Common/constant"
    local hookCombat = require "Logic/OnHookCombat"
    local uiText = GetConfig('common_char_chinese').UIText
    local teamInfo = nil
    local followTimer = nil
    
    local Create = function()
        MessageRPCManager.AddUser(self, 'MakeTeamRet')
        MessageRPCManager.AddUser(self, 'SetTargetRet')
        MessageRPCManager.AddUser(self, 'GetTeamInfoRet')
        MessageRPCManager.AddUser(self, 'JoinTeamRet')
        MessageRPCManager.AddUser(self, 'MemberJoinTeam')
        MessageRPCManager.AddUser(self, 'ChangeCaptainRet')
        MessageRPCManager.AddUser(self, 'MemberExitTeam')
        MessageRPCManager.AddUser(self, 'SetAutoJoinRet')
        MessageRPCManager.AddUser(self, 'TargetChanged')
        MessageRPCManager.AddUser(self, 'ExitTeamRet')
        MessageRPCManager.AddUser(self, 'PlayerApplyTeam')  
        MessageRPCManager.AddUser(self, 'BeKickedFromTeam')
        MessageRPCManager.AddUser(self, 'BeFollowCaptain')
        MessageRPCManager.AddUser(self, 'BeTeamInvited')
        MessageRPCManager.AddUser(self, 'EnterDungeonMakeSure')
        MessageRPCManager.AddUser(self, 'ApplySetTarget')
        MessageRPCManager.AddUser(self, 'SetTeamLevelRet')
        MessageRPCManager.AddUser(self, 'CancelFollowCaptain')
        MessageRPCManager.AddUser(self, 'TeamMemberReplySetTarget')
        MessageRPCManager.AddUser(self, 'GetPlayerPositionRet')
        MessageRPCManager.AddUser(self, 'TeleportOtherScene')
        MessageRPCManager.AddUser(self, 'EntityInfoChanged')
        MessageRPCManager.AddUser(self, 'MemberStateChange')
        MessageRPCManager.AddUser(self, 'ChangeOnHookRet')
        MessageRPCManager.AddUser(self, 'EnterTeamDungeonRet')
    end
    
    self.Clear = function()
        teamInfo = nil
    end
    
    local OnTeamInfoChange = function(data)
        if data.result ~= nil and data.result ~= 0 then return end
        
        local cacheID = {}
        if teamInfo and teamInfo.members then
            for k,v in pairs(teamInfo.members) do
                cacheID[v.actor_id] = 1
            end
        end
        
        if data.team_info.members then
            for k,v in pairs(data.team_info.members) do
                cacheID[v.actor_id] = 1
            end
            local state = self.GetState(data.team_info.members)
            hookCombat.SetHook(state == 'on_hook')
        else
            hookCombat.SetHook(false)
        end
        teamInfo = data.team_info

        local mainLandUICtrl = UIManager.GetCtrl(ViewAssets.MainLandUI)
        if mainLandUICtrl.isLoaded then
            mainLandUICtrl.mainUITeamCtrl.OnTeamInfoChange()
        end
        local TeamUICtrl = UIManager.GetCtrl(ViewAssets.TeamUI)
        if TeamUICtrl.isLoaded then
            TeamUICtrl.OnTeamInfoChange()
        end
        
        UIManager.UnloadView(ViewAssets.TeamOpUI)
        for k,v in pairs(cacheID) do
            local puppet = SceneManager.GetEntityManager().GetPuppet(k)
            if puppet and puppet.behavior and puppet.behavior.nameBar then
                puppet.behavior.nameBar.UpdateTeamFlag(k)
            end
            if puppet and puppet.behavior and puppet.behavior.hpBar and puppet.uid ~= MyHeroManager.heroData.actor_id then
                if self.InTeam(puppet.uid) then
                    puppet.behavior.hpBar.delay = 0
                    puppet.behavior.hpBar.ShowHpBar()
                else
                    puppet.behavior.hpBar.delay = -1
                    puppet.behavior.hpBar.DestroyBar()
                end
            end
        end
        
        if self.Following() then
            if not followTimer then
                followTimer = Timer.Repeat(1, self.QuestCaptainInfo)
                self.QuestCaptainInfo()
            end
            hookCombat.SetHook(false)
        else
            if followTimer then
                Timer.Remove(followTimer)
                followTimer = nil
                local hero = SceneManager.GetEntityManager().hero
                if hero then hero:StopMove() end
            end
        end
    end
    
    self.QuestCaptainInfo = function()
        local hero = SceneManager.GetEntityManager().hero
        if not hero then return end
        if hero:IsDied() then
            self.CancelFollow()
            return
        end
        local captain_id = self.GetTeamInfo().captain_id
        local puppet = SceneManager.GetEntityManager().GetPuppet(captain_id)
        if puppet then
            if Vector3.Distance2D(puppet:GetPosition(),hero:GetPosition()) > 2 then
                hero:Moveto(puppet:GetPosition(),3)
            end
        else
            local data = {}
            data.func_name = 'on_get_player_position'
            data.player_id = captain_id
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
    end
    
    self.GetPlayerPositionRet = function(data)
        local hero = SceneManager.GetEntityManager().hero
        local sameScene = data.scene_id == SceneManager.currentSceneId
        if sameScene then
            if data.game_line ~= SceneLineManager.curLineId then
                if hero:CheckOperationStatus(constant.HERO_OPERATION_STATUS.None) then
                    hero:StartSwitchLine(data.game_line)
                end
            else
                hero:Moveto(Vector3.New(data.pos[1]/100,data.pos[2]/100,data.pos[3]/100),3)
            end
        elseif hero:CheckOperationStatus(constant.HERO_OPERATION_STATUS.None) then
            hero:Convey(data.scene_id, function()
                SceneManager.GetEntityManager().hero:Moveto(Vector3.New(data.pos[1]/100,data.pos[2]/100,data.pos[3]/100),3)
            end)
        end
    end
    
    self.EnterDungeonRequest = function(id)
        if not TeamManager.InTeam() then UIManager.ShowNotice('必须要组队才能进入该副本') return end
        if not TeamManager.IsCaptain() then UIManager.ShowNotice('只有队长才有权限开启副本。') return end
        local teamInfo = TeamManager.GetTeamInfo()
        local target = teamInfo.target
        if id then target = id end
        if target == 'free' then UIManager.ShowNotice('队伍尚无目标') return end
        
        local data = {}
        data.func_name = 'on_enter_team_dungeon'
        data.new_target = target
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
        
    self.GetTeamInfo = function()
        return teamInfo
    end
    
    self.GetTeamMemberNum = function()
        local num = 0
        local info = self.GetTeamInfo()
        for _,v in pairs(info.members) do
            num = num + 1
        end
        return num
    end
    
    self.GetCaptainName = function()
        local info = self.GetTeamInfo()
        for _,v in pairs(info.members) do
            if v.actor_id == info.captain_id then
                return v.actor_name
            end
        end
    end
    
    self.GetTargetName = function(target)
        local targetID = target
        if not targetID then
            local info = self.GetTeamInfo()
            if info then
                targetID = info.target
            end
        end
        
        if targetID and tableData[targetID] then
            return LuaUIUtil.GetTextByID(tableData[targetID],'Name')
        end
        return '自由组队'
    end
    
    self.IsCaptain = function(actor_id)
        local info = self.GetTeamInfo()
        if not actor_id and info and info.captain_id == MyHeroManager.heroData.actor_id then
            return true
        end
        if actor_id and info and info.captain_id == actor_id then
            return true
        end
        return false
    end
    
    self.InTeam = function(id)
        local info = self.GetTeamInfo()
        if table.isEmptyOrNil(info) then
            return false
        end     
        if id then
            for _,v in pairs(info.members) do
                if v.actor_id == id then
                    return true
                end
            end
            return false
        end
        return true
    end
    
    self.GetState = function(members)
        if members == nil then
            local info = self.GetTeamInfo()        
            if table.isEmptyOrNil(info) then
                return nil
            end
            members = info.members
        end
        for _,v in pairs(members) do
            if v.actor_id == MyHeroManager.heroData.actor_id then
                return v.team_state
            end
        end
    end
    
    self.Following = function()
        return self.GetState() == 'follow'
    end
    
    self.AllFollow = function()
        local info = self.GetTeamInfo()
        for _,v in pairs(info.members) do
            if v.team_state ~= 'follow' and v.actor_id ~= info.captain_id then
                return false
            end
        end
        return true
    end
        
    self.AllFreeMove = function()
        local info = self.GetTeamInfo()
        for _,v in pairs(info.members) do
            if v.team_state == 'follow' and v.actor_id ~= info.captain_id then
                return false
            end
        end
        return true
    end
    
    self.SendLeaveTeam = function()
        local data = {}
        data.func_name = 'on_exit_team'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)   
    end
    
    self.MakeTeamRet = function(data)
        OnTeamInfoChange(data)
        --UIManager.UnloadViewsByLayer(LayerGroup.pop)
        UIManager.PushView(ViewAssets.TeamUI)
    end
    
    self.CancelFollowCaptain = function(data)
        OnTeamInfoChange(data)
    end
    
        
    self.ChangeOnHookRet = function(data)
        OnTeamInfoChange(data)
    end
    
    self.ExitTeamRet = function()
        local data = {}
        data.team_info = {}
        OnTeamInfoChange(data)
    end
    
    self.BeKickedFromTeam = function(data)
        if data.actor_id == MyHeroManager.heroData.actor_id then
            UIManager.ShowTopNotice('您被请离了队伍')
            local data = {}
            data.team_info = {}
            OnTeamInfoChange(data)
        else
            UIManager.ShowTopNotice(data.actor_name..'被请离了队伍')
        end
    end
    
    self.BeFollowCaptain = function(data)
        OnTeamInfoChange(data)
    end
    
    self.SetTargetRet = function(data)
        UIManager.UnloadView(ViewAssets.TeamChangeTargetUI)
        OnTeamInfoChange(data)
        self.ShowErrorMsg(data)
    end
    
    self.SetTeamLevelRet = function(data)
        if data.result == 0 and teamInfo.max_level and teamInfo.min_level then
            teamInfo.max_level = data.max_level
            teamInfo.min_level = data.min_level
            local data = {}
            data.team_info = teamInfo
            OnTeamInfoChange(data)
        end
    end
    
    self.GetTeamInfoRet = function(data)
        OnTeamInfoChange(data)
    end
    
    self.JoinTeamRet = function(data)
        --UIManager.UnloadView(ViewAssets.TeamApplyUI)
        --UIManager.UnloadViewsByLayer(LayerGroup.pop)
        UIManager.PushView(ViewAssets.TeamUI)
        OnTeamInfoChange(data)
    end
    
    self.MemberJoinTeam = function(data)
        UIManager.ShowTopNotice(data.member_name..'加入队伍')
    end
    
    self.ChangeCaptainRet = function(data)
        OnTeamInfoChange(data)
    end
    
    self.MemberExitTeam = function(data)
        for _,v in pairs(teamInfo.members) do
            if v.actor_id == data.member_id then
                UIManager.ShowTopNotice(v.actor_name..'离开队伍')
            end
        end
    end
    
    self.TeleportOtherScene = function(data)
        if data.senen_id then
            SceneManager.GetEntityManager().hero:Convey(data.senen_id)
        end
    end
    
    self.MemberStateChange = function(data)
        OnTeamInfoChange(data)
    end
    
    self.TeamMemberReplySetTarget = function(data)
        if data.sure_sign == -1 then
            UIManager.ShowTopNotice(data.member_name..'拒绝更改队伍目标')
        else
            UIManager.ShowTopNotice(data.member_name..'同意更改队伍目标')
        end
    end

    self.ShowErrorMsg = function(data)
        local tips = {
            [const.error_team_member_not_in_same_game_server] = uiText[1135103].NR, --'%s和队长不在一个分线，队伍开启副本失败。',			
            [const.error_team_member_not_in_same_scene] = uiText[1135095].NR, --'%s和队长不在一个地图，队伍开启副本失败。',			
            [const.error_team_member_level_not_match] = uiText[1135097].NR, --'%s不满足副本等级要求，队伍进入副本失败。',
            [const.error_team_member_tili_not_enough] = uiText[1135096].NR,--'%s体力不足，队伍进入副本失败。',
            [const.error_team_member_already_in_dungeon] = uiText[1135101].NR, --'%s所在位置不能进入副本，队伍进入副本失败。',
            [const.error_team_member_is_dead] = uiText[1135102].NR,--'%s已经死亡，队伍开启副本失败。',
            [const.error_team_member_refuse_set_target] = uiText[1135099].NR,
            [const.error_team_member_refuse_enter_dungeon] = uiText[1135098].NR, 	
        }

        if data.failed_player and tips[data.result] then
            for i=1,#data.failed_player do
                local name = ''
                for _,v in pairs(teamInfo.members) do
                    if v.actor_id == data.failed_player[i] then
                        name = v.actor_name
                    end
                end
                UIManager.ShowTopNotice(string.format(tips[data.result],name))
            end
        end
    end
    
    self.EnterTeamDungeonRet = function(data)
        self.ShowErrorMsg(data)
    end
    
    self.SetAutoJoinRet = function(data)
        OnTeamInfoChange(data)
    end
    
    self.TargetChanged = function(data)
        OnTeamInfoChange(data)
    end
    
    self.EnterDungeonMakeSure = function(data)
        local target = data.new_target
        if not target then
            target = teamInfo.target
        end
        UIManager.PushView(ViewAssets.TeamConfirmUI,nil,target,data.sure_sign,data.enable_reward)
    end
    
    self.ApplySetTarget = function(data)
        local Approve = function(id)
            local data = {}
            data.func_name = 'on_agree_set_target'
            data.sure_sign = id
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
        end
        if not self.IsCaptain() then
            local des = string.format('队长%s将目标调整为%s，请问是否同意。',self.GetCaptainName(),self.GetTargetName(data.target))
            UIManager.ShowDialog(des, '同意', '拒绝', function() Approve(data.sure_sign) end, function() Approve(-1) end,'ok',5)   
        end
    end
    
    self.PlayerApplyTeam = function(data)
        local Approve = function(id)
            local data = {}
			data.func_name = 'on_agree_apply'
            data.new_member_id = id
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
        end
        UIManager.ShowDialog(string.format('%s请求加入你的队伍，请问你是否同意。',data.player_info.actor_name), '同意', '拒绝', function() Approve(data.player_info.actor_id) end,nil,'cancel',20)
    end
    
    self.SummonMembers = function()
        local data = {}
        data.func_name = 'on_summon_member'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.CancelSummon = function()
        local data = {}
        data.func_name = 'on_release_summon'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.CancelFollow = function()
        if not self.Following() then
            return
        end
        local data = {}
        data.func_name = 'on_cancel_follow'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.FollowCaptain = function()
        local data = {}
        data.func_name = 'on_follow_captain'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.BeTeamInvited = function(data)
        local Approve = function(id,agree)
            local data = {}
			data.func_name = 'on_reply_team_invite'
            data.reply_team_id = id
            data.is_agree = agree
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data,not agree) 
        end
        local inviterName = ''
        for _,v in pairs(data.team_info.members) do
            if v.actor_id == data.inviter_id then
                inviterName = v.actor_name
            end
        end
        UIManager.ShowDialog(string.format('%s邀请你加入他的队伍，请问你是否同意。',inviterName), '同意', '拒绝', function() Approve(data.team_info.team_id,true) end ,function() Approve(data.team_info.team_id,false) end,'cancel',20)
    end
    
    self.EntityInfoChanged = function(data)
        if data.entity_id then
            local puppet = SceneManager.GetEntityManager().GetPuppet(data.entity_id)
            if puppet and puppet.data then
                puppet.data.team_id = data.team_id
            end
        end
    end
    
    self.UpdateDungeonMark = function(data)
        self.markData = {}
        self.markData.mark = data.mark
        self.markData.start_time = data.start_time
        self.markData.current_wave = data.current_wave
    end
    Create()
    return self
end

TeamManager = TeamManager or CreateTeamManager()