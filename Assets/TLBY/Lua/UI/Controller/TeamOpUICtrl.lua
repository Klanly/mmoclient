---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamOpUICtrl()
    local self = CreateCtrlBase()
    local memberInfo
    
    self.layer = LayerGroup.popCanvas
    
    self.onLoad = function(pos,info)
        memberInfo = info
        self.AddClick(self.view.rect,self.close)
        self.view.bg:GetComponent('RectTransform').anchoredPosition = pos
        local heroSelf = MyHeroManager.heroData.actor_id == memberInfo.actor_id
        local captain = TeamManager.IsCaptain()
        self.view.btnSendMsg:SetActive(not heroSelf)
        self.view.btnCheckInfo:SetActive(not heroSelf)
        self.view.btnAddFriend:SetActive(not heroSelf)
        self.view.btnCaptain:SetActive(not heroSelf and captain)
        self.view.btnKickTeam:SetActive(not heroSelf and captain)
        self.view.btnSummon:SetActive(not heroSelf and captain and memberInfo.team_state ~= 'follow')
        self.view.btnMoveTo:SetActive(false)--not heroSelf and not captain)
        self.view.btnLeaveTeam:SetActive(heroSelf)
        local height = 0
        if heroSelf then
            height = 91 + 35
        elseif captain then
            height = 91*5+35
        else
            height = 91*4+35
        end
        self.view.bg:GetComponent('RectTransform').sizeDelta = Vector2.New(302,height)
        self.AddClick(self.view.btnCaptain,self.ChangeCaptain)
        self.AddClick(self.view.btnCheckInfo,self.CheckInfo)
        self.AddClick(self.view.btnKickTeam,self.Kick)
        self.AddClick(self.view.btnAddFriend,self.AddFriend)
        self.AddClick(self.view.btnSendMsg,self.SendMsg)
        self.AddClick(self.view.btnMoveTo,self.Convey)
        self.AddClick(self.view.btnLeaveTeam,self.LeaveTeam)
        self.AddClick(self.view.btnSummon,self.Summon)
    end
	
	self.onUnload = function()
    
	end
    
    self.Convey = function()
    
    end
    
    self.CheckInfo = function()
        ContactManager.QuestPlayerInfo(memberInfo.actor_id,self.view.btnCheckInfo.transform.position)
        self.close()
    end
    
    self.Summon = function()
        self.close()
        local data = {}
        data.func_name = 'on_summon_single_member'
        data.member_id = memberInfo.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
    end
    
    self.AddFriend = function()
        self.close()
        ContactManager.AddFriend(memberInfo.actor_id)
    end
    
    self.SendMsg =  function()
        self.close()
        ContactManager.PushView(ViewAssets.FriendsUI,
            function(ctrl) 
                ctrl.SendPrivateMsg(memberInfo)
            end
        )
    end
    
    self.LeaveTeam = function()
        self.close()
        TeamManager.SendLeaveTeam()
    end
    
    self.Kick = function()
        self.close()
        local data = {}
        data.func_name = 'on_kick_member'
        data.member_id = memberInfo.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)          
    end
    
    self.ChangeCaptain = function()
        self.close()
        local data = {}
        data.func_name = 'on_change_captain'
        data.new_captain_id = memberInfo.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
	return self
end

return CreateTeamOpUICtrl()