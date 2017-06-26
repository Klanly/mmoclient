---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/ContactManager"

local constant = require "Common/constant"
local uitext = GetConfig("common_char_chinese").UIText

function CreatePlayerOpUICtrl()
    local self = CreateCtrlBase()
    local playerData = nil
    
	self.onLoad = function(data,position)
        playerData = data
		self.AddClick(self.view.bg, self.close)
        
        if position then
            self.view.position.transform.position = position
            local anchoredPosition3D = self.view.position:GetComponent('RectTransform').anchoredPosition3D
            local x = anchoredPosition3D.x
            local y = anchoredPosition3D.y
            if x > 500 then x = 500 end
            if x < -1024 then x = -1024 end
            if y > 497 then y = 497 end
            if y < -80 then y = -80 end
            self.view.position:GetComponent('RectTransform').anchoredPosition3D = Vector3.New(x,y,0)
        else
            self.view.position:GetComponent('RectTransform').anchoredPosition3D = Vector3.zero
        end
        
        
        self.view.name:GetComponent("TextMeshProUGUI").text = 'Lv.'..data.level..' '..data.actor_name
        if data.team_members_number and data.team_members_number > 0 then
            self.view.textRanks:GetComponent("TextMeshProUGUI").text = string.format('队伍:%d/4',data.team_members_number)
        else
            self.view.textRanks:GetComponent("TextMeshProUGUI").text = '队伍:-/-'
        end
        self.view.icon:GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
        
        local isFriend =  ContactManager.InList('friends',playerData.actor_id) ~= nil
        local inBlackList = ContactManager.InList('blacklist' ,playerData.actor_id) ~= nil
        local isEnemy = ContactManager.InList('enemys' ,playerData.actor_id) ~= nil
        local heroSelf = playerData.actor_id == MyHeroManager.heroData.actor_id

        self.view.removeFriend:SetActive(isFriend and not heroSelf)  
        self.view.addFriend:SetActive(not isFriend and not heroSelf)
        self.view.addBlackList:SetActive(not inBlackList and not heroSelf)
        self.view.removeBlackList:SetActive(inBlackList and not heroSelf)
        self.view.addEnemy:SetActive(not isEnemy and not heroSelf)
        self.view.factionInvite:SetActive(FactionManager.InFaction() and not heroSelf)
        self.view.removeEnemy:SetActive(isEnemy and not heroSelf)
        self.view.teamApply:SetActive(data.team_members_number ~= 0 and (not TeamManager.InTeam()) and not heroSelf)
        self.view.teamInvite:SetActive((data.team_members_number == 0) and not heroSelf)
        self.view.giftGiving:SetActive(isFriend and not heroSelf)
        self.view.factionPosition:SetActive(data.factionMember and not heroSelf)
        self.view.kickFaction:SetActive(data.factionMember and data.factionPosition == constant.FACTION_POSITION_NAME_TO_INDEX.crew and not heroSelf)
        self.view.transferChief:SetActive(data.factionMember and FactionManager.GetSelfPosition() == constant.FACTION_POSITION_NAME_TO_INDEX.chief and not heroSelf)
        self.AddClick(self.view.btnCheck,self.Check)
        self.AddClick(self.view.btnTeamInvite,self.TeamInvite)
        self.AddClick(self.view.btnTeamApply,self.TeamApply)
        self.AddClick(self.view.btnAddFriend,self.AddFriend)
        self.AddClick(self.view.btnRemoveFriend,self.RemoveFriend)
        self.AddClick(self.view.btnFactionInvite,self.FactionInvite)
        self.AddClick(self.view.btnAddBlackList,self.AddBlackList)
        self.AddClick(self.view.btnRemoveBlackList,self.RemoveBlackList)
        self.AddClick(self.view.btnAddEnemy,self.AddEnemy)
        self.AddClick(self.view.btnRemoveEnemy,self.RemoveEnemy)
        self.AddClick(self.view.btnFactionPosition,self.FactionPosition)
        self.AddClick(self.view.btnKickFaction,self.KickFaction)
        self.AddClick(self.view.btnGiftGiving,self.GiftGiving)
        self.AddClick(self.view.btnTransferChief,self.TransferChief)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_DELETE, self.HandleFriendListMSG)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_ADD, self.HandleFriendListMSG)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_DELETE, self.HandleFriendListMSG)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_ADD, self.HandleFriendListMSG)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_DELETE, self.HandleFriendListMSG)
	end
	
	self.onUnload = function()
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_DELETE, self.HandleFriendListMSG)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_ADD, self.HandleFriendListMSG)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_DELETE, self.HandleFriendListMSG)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_ADD, self.HandleFriendListMSG)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_DELETE, self.HandleFriendListMSG)
	end
	
    self.Check = function()

    end
    
    self.TeamInvite = function()
        local data = {}
        data.func_name = 'on_team_invite_player'
        data.invite_player_id = playerData.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 

        self.close()
    end
    
    self.TeamApply = function()
        local data = {}
        data.func_name = 'on_apply_team'
        data.apply_team_id = playerData.team_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
        self.close()
    end
    
    self.AddFriend = function()
        ContactManager.AddFriend(playerData.actor_id)
        self.close()
    end
    
    self.RemoveFriend = function()
        local tb = require "Logic/Scheme/system_friends_chat"
        if playerData.friend_value and playerData.friend_value >= tb.Friendly[1].Friendly then
            local title = LuaUIUtil.GetTitleByFriendValue(playerData.friend_value)
            UIManager.ShowDialog(string.format("好友与您是%s的好友，您确认删除吗？",title),'确定','取消',self.SendMSG)
        else
            self.SendMSG() 
        end
    end
    
    self.SendMSG = function()           
        local data = {}
        data.actor_id = playerData.actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_DELETE , data) 
    end
    
    self.FactionInvite = function()
        local data = {}
        data.func_name = 'on_invite_faction_member'
        data.member_id = playerData.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        self.close()
    end
    
    self.AddBlackList = function()
        local data = {}
        data.actor_id = playerData.actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_BLACKLIST_ADD , data)       
    end
    
    self.RemoveBlackList = function()
        local data = {}
        data.actor_id = playerData.actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_BLACKLIST_DELETE , data) 
    end
    
    self.AddEnemy = function()
        local data = {}
        data.actor_id = playerData.actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ENEMY_ADD , data)     
    end
    
    self.RemoveEnemy = function()
        local data = {}
        data.actor_id = playerData.actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ENEMY_DELETE , data)   
    end
    
    self.HandleFriendListMSG = function(data)
        self.close()
    end

    self.GiftGiving = function()
        local num = BagManager.GetItemNumberByType(constant.TYPE_FRIEND_VALUE)
        if num <= 0 then
            UIManager.ShowNotice(uitext[1101068].NR)
            return
        end
        UIManager.PushView(ViewAssets.GiftGivingUI,nil,playerData.actor_id,playerData.actor_name)
        self.close()
    end
    
    self.TransferChief = function()
        local data = {}
        data.func_name = 'on_transfer_chief'
        data.member_id = playerData.actor_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        self.close()
    end
    
    self.FactionPosition = function()
        if FactionManager.GetSelfPosition() >= playerData.factionPosition then
            UIManager.ShowNotice('权限不足')
            return
        end      
       UIManager.PushView(ViewAssets.FactionPositionUI,nil,playerData.factionPosition,playerData.actor_id)
       self.close()
    end
    
    self.KickFaction = function()
        if not FactionManager.SelfAuthority('Kick',true) then return end
        local Confirm = function()
        local data = {}
            data.func_name = 'on_kick_faction_member'
            data.member_id = playerData.actor_id
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
            self.close()
        end
        UIManager.ShowDialog('是否将该会员逐出帮会', '确定', '取消', Confirm, nil)
    end
    
	return self
end

return CreatePlayerOpUICtrl()