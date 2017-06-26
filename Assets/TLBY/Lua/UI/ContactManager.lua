local function CreateContactManager()
	local self = CreateObject()
    
    local groupDataList = {}
    local group = {"friends","blacklist","enemys","applicants"}
    local delayOpen = nil
    local viewArg = nil
    local callBack = nil
    
    local playerInfoPos = nil
    local playerInfoId = nil
    local playerFactionData = nil
    
    self.ClearList = function()
        groupDataList = {}
    end
    
    self.AddFriend = function(actor_id)
        if self.InList("enemys",actor_id) then
            UIManager.ShowNotice('无法添加该玩家好友')
            return
        end
        
        local data = {}
        data.actor_id = actor_id
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_APPLY , data) 
    end
    
    self.PushView = function(view,handler,...)
        if table.isEmptyOrNil(groupDataList) then
            delayOpen = view
            viewArg = {...}
            callBack = handler
            local data = {flag = "all"}
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_GET , data) 
            return
        end
        UIManager.PushView(view,handler,...)
    end
    
    self.QuestPlayerInfo = function(id,pos,factionData)
        if id == MyHeroManager.heroData.actor_id then return end
        
        playerInfoId = id
        playerInfoPos = pos
        playerFactionData = factionData
        local data = {actor_id = id}
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_QUERY_PLAYER , data) 
    end
    
    self.InList = function(groupType,id)
        if not groupDataList[groupType] then print(groupType) return false end
        for k,v in pairs(groupDataList[groupType]) do
            if v.actor_id == id then
                return v
            end
        end
        return nil
    end
    
    self.GetContactList = function(groupType)
        return groupDataList[groupType] or {}
    end
    
    self.HandleFriendListMSG = function(data)
        if data.result ~= 0 then
            UIManager.ShowErrorMessage(data.result)
            return
        end
        
        for i=0,#group do
            if data.contracts[group[i]] ~= nil then
                groupDataList[group[i]] = data.contracts[group[i]]
                UIManager.GetCtrl(ViewAssets.FriendsUI).GroupUpdate(i)
            end
        end
        
        if delayOpen ~= nil then
            UIManager.PushView(delayOpen,callBack,unpack(viewArg))
            delayOpen = nil     
        end
        if data.contracts.applicants then
            ChatManager.RefreshApplyRedDot(not table.isEmptyOrNil(data.contracts.applicants))
        end
    end
    
    self.HandleFriendAccept = function(data)
        self.HandleFriendListMSG(data)
        UIManager.GetCtrl(ViewAssets.FriendsApproveUI).HandleFriendListMSG()
    end
    
    self.HandleApplyMSG = function(data)
        if data.result ~= 0 then
            UIManager.ShowErrorMessage(data.result)
            return
        end
        UIManager.ShowNotice('已向该玩家发送好友申请')
    end

    self.HandlePlayerInfo = function(data)
        if not data.player_info then return end
        if playerFactionData and playerFactionData.actor_id == data.player_info.actor_id then
            data.player_info.factionPosition = playerFactionData.position  
            data.player_info.factionMember = true
            self.PushView(ViewAssets.PlayerOpUI,nil,data.player_info,playerInfoPos)
        elseif playerInfoId == data.player_info.actor_id then
            self.PushView(ViewAssets.PlayerOpUI,nil,data.player_info,playerInfoPos)
        end
    end
        
    self.OnAcceptFriendRet = function(data)
        UIManager.ShowTopNotice(string.format("你已经和%s成为好友",data.actor_name))
    end

    self.OnAddBlacklistRet = function(data)
        UIManager.ShowTopNotice(string.format("已经将%s加入黑名单",data.actor_name))
    end

    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_APPLY, self.HandleApplyMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_QUERY_PLAYER, self.HandlePlayerInfo)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_GET , self.HandleFriendListMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_ACCEPT, self.HandleFriendAccept)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_DELETE, self.HandleFriendListMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_ADD, self.HandleFriendListMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_BLACKLIST_DELETE, self.HandleFriendListMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_ADD, self.HandleFriendListMSG)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ENEMY_DELETE, self.HandleFriendListMSG)
    MessageRPCManager.AddUser(self, 'OnAcceptFriendRet')
    MessageRPCManager.AddUser(self, 'OnAddBlacklistRet')

    return self
    
end

ContactManager = ContactManager or CreateContactManager()