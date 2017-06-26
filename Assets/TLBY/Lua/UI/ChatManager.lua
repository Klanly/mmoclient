require 'UI/DiskData'

local function CreateChatManager()
	local self = CreateObject()
	local unreadActorList = nil
    local recentList = nil
    local actorInfo = nil
	local msgList = nil
    local channelCost = nil
    local quickMsg = nil
    self.actorID = nil
    local chatList = {}
	local chatTable = GetConfig('system_friends_chat')
    local pvpCamp = GetConfig('pvp_country')
    local uiText = GetConfig('common_char_chinese').UIText
    local channelControl = chatTable.ChannelControl
    local chatParam = chatTable.Parameter
    local chatChannel = {'UnionChat','Loudspeaker','TeamChat','NearbyChat','SystemMessage','FactionChat','MainMessage'}
    self.typeName = {'公告','战斗','系统','系统','阵营','帮会','队伍','附近','喇叭'}
    self.application = false
    self.unreadMessage = false
    
    local Save = function(friendMsg)
        for k,v in pairs(friendMsg) do
            msgList[k] = msgList[k] or {}
            for i=1,#v do              
                if #msgList[k] > 99 then
                    table.remove(msgList[k],1)
                end
                table.insert(msgList[k],v[i])
                actorInfo[v[i].actor_id] = v[i]                
            end
            
            local exsit = false
            for i=1,#unreadActorList do
                if unreadActorList[i] == k then
                    exsit = true
                    break
                end
            end
            if not exsit then
                table.insert(unreadActorList,k)
            end
            
            self.AddRecent(k)
		end
        for k,v in pairs(actorInfo) do
            local safe = false
            for i=1,#recentList do
                if recentList[i] == k then
                    safe = true
                end
            end
            if not safe then
                actorInfo[k] = nil
            end
        end
        self.SaveMsg()
        self.UpdateRedDot()
    end
    
    self.AddActorInfo = function(data)
        actorInfo[data.actor_id] = data
        self.SaveMsg()
    end
    
    self.AddRecent = function(k)
        if MyHeroManager.heroData.actor_id == k then
            return
        end
        for i=1,#recentList do
            if recentList[i] == k then
                table.remove(recentList,i)
                break
            end
        end
        if #recentList > chatParam[3].Value then
            recentList.remove(recentList,#recentList)
        end
        table.insert(recentList,1,k) 
    end
      
    self.HandleRedDot = function(data)
        self.unreadMessage = data.offline_message or (unreadActorList and #unreadActorList > 0)
        self.application = data.friend_applicants
        self.unreadMail = data.unread_mail
    end
    
    self.RefreshUnreadMailRedDot = function(showRedDot)
        if showRedDot ~= nil then
            self.unreadMail = showRedDot
        end
        local friendsUI = UIManager.GetCtrl(ViewAssets.FriendsUI)
        if friendsUI.isLoaded then
            friendsUI.view.mailRedDot:SetActive(self.unreadMail)
        end
        local MainLandUI = UIManager.GetCtrl(ViewAssets.MainLandUI)
        if MainLandUI.isLoaded then
            MainLandUI.UpdateRedDot()
        end
        local mailUI = UIManager.GetCtrl(ViewAssets.MailUI)
        if mailUI.isLoaded then
            mailUI.view.mailRed:SetActive(self.unreadMail)
        end
    end
    
    self.RefreshApplyRedDot = function(showRedDot)
        if showRedDot ~= nil then
            self.application = showRedDot
        end
        UIManager.GetCtrl(ViewAssets.FriendsUI).RefreshApplyRedDot()
        local MainLandUI = UIManager.GetCtrl(ViewAssets.MainLandUI)
        if MainLandUI.isLoaded then
            MainLandUI.UpdateRedDot()
        end
    end
    
    self.OnLogin = function(data)
        self.actorID = data.login_data.actor_id
        self.LoadMsg()
    end
    
    self.HandleTalkMsg = function(data)
        if data.result ~=0 then
            UIManager.ShowErrorMessage(data.result)
            return
        end
        Save(data.messages.friend_msg)
        UIManager.GetCtrl(ViewAssets.PlayerTalkUI).RefreshTalkList()
        UIManager.GetCtrl(ViewAssets.FriendsUI).RefreshRecent()
        local hero = SceneManager.GetEntityManager().hero
        for k,v in pairs(data.messages.friend_msg) do
            for i=1,#v do
                if v[i].actor_id == self.actorID  and hero and hero.behavior and hero.behavior.chatBar then
                    hero.behavior.chatBar.PushChat(v[i].data)
                else
                    local speaker = SceneManager.GetEntityManager().GetPuppet(v[i].actor_id)
                    if speaker and speaker.behavior.chatBar then
                        speaker.behavior.chatBar.PushChat(v[i].data)
                    end
                end
            end
        end
    end
    
    self.HandleSysMsg = function(data)
        data.actor_id = '-1'
        self.HandleBroadcast(data)
        if data.friend_chat_display == 1 then
            local msg = {}
            msg[data.actor_id] = {data}
            Save(msg)
        end
    end
    
    self.SendMsg = function(text,channel,attach)
        local data = {}
        data.channel = channel
        data.data = text
        if attach then
            data.attach = attach
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CHAT, data) 
    end
    
    self.HandleOfflineMsg = function(data)
        if not table.isEmptyOrNil(data.contracts.offline_messages) and not table.isEmptyOrNil(data.contracts.offline_messages.friend_msg) then
            Save(data.contracts.offline_messages.friend_msg)
        end
    end
    
    self.CallTogetherByOfficer = function(data)
        if data.position_info then
            data.data = string.format(uiText[1135115].NR,LuaUIUtil.GetCampName(data.position_info.country),pvpCamp.ElectionQualification[data.position_info.office_id].office,data.position_info.caller_name)
            data.attach = {}
            data.attach.caller_id = data.position_info.caller_id
            data.attach.type = 'campInvite'
            data.time = networkMgr:GetConnection():GetTimestamp()
            data.message_type = constant.CHAT_MESSAGE_TYPE.ImportantSystemMessage
            self.HandleBroadcast(data)
            
            if data.position_info.caller_id == MyHeroManager.heroData.actor_id then
                UIManager.ShowNotice(uiText[1135117].NR)
            end
        end
    end
    
    self.PreRespondToCallTogetherRet = function(data)
        if data.result == 0 then
            local SendMsg = function()
                local d = {}
                d.func_name = 'on_respond_to_call_together'
                d.caller_id = data.caller_id
                MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,d)
            end
            UIManager.ShowProcessBarByTime(3,'传送中...',SendMsg)
            SceneManager.GetEntityManager().hero.behavior:UpdateBehavior('spell_loop')
        end
    end
    
    self.RespondToCallTogetherRet = function(data)
        SceneManager.GetEntityManager().hero.behavior:StopBehavior('spell_loop')
    end
    
    self.HandleBroadcast = function(data)
        if not data.actor_id then data.actor_id = '-1' end
        if data.props then
            data.data = string.gsub(data.data,'props',LuaUIUtil.GetItemColorName(data.props))
        end
        
        local chatBar = false
        for i=1,#chatChannel do
            if channelControl[data.message_type][chatChannel[i]] == 1 then
                chatList[i] = chatList[i] or {}
                if #chatList[i] > 99 then
                    table.remove(chatList[i],1)
                end
                table.insert(chatList[i],data)
                UIManager.GetCtrl(ViewAssets.ChatUI).RefreshChatList(i)
                if i==2 then
                    UIManager.PushView(ViewAssets.SpeakerUI, function(ctrl)
                        ctrl.UpdateData(data)
                    end)
                end
                if i==5 and data.notice then
                    UIManager.PushView(ViewAssets.SpeakerUI, function(ctrl)
                        ctrl.UpdateData(data)
                    end)
                end
                if i == 7 then
                    local mainMessage = chatList[i]
                    local chats = {}
                    for j=3,1,-1 do
                        if j <= #mainMessage then
                            local showData = mainMessage[#mainMessage + 1 - j]
                            local name = ''
                            if showData.actor_name then
                                name = showData.actor_name.."："
                            end
                            --str = str..string.format('<font="SIMLI SDF"><color=%s>【%s】</color></font><color=#FF919AFF>%s</color>%s\n',channelControl[showData.message_type].Color,self.typeName[showData.message_type],name,showData.data)
                            local chat = {}
                            chat.channel = string.format('<color=%s>%s</color>',channelControl[showData.message_type].Color,self.typeName[showData.message_type])
                            chat.chat = string.format('            <color=#FF919AFF>%s</color>%s',name,showData.data)
                            table.insert(chats,chat)               
                        end
                    end
                    UIManager.GetCtrl(ViewAssets.MainLandUI).RefreshChatText(chats)
                end
                if i==1 or i==4 or i==3 or i==6 then
                    chatBar = true
                end
            end
        end
        local hero = SceneManager.GetEntityManager().hero
        if hero and data.actor_id == hero.uid and hero.behavior and hero.behavior.chatBar then
            hero.behavior.chatBar.PushChat(data.data)
        elseif chatBar then
            local speaker = SceneManager.GetEntityManager().GetPuppet(data.actor_id)
            if speaker and speaker.behavior and speaker.behavior.chatBar then
                speaker.behavior.chatBar.PushChat(data.data)
            end
        end
    end
    
    self.GetBroadcast = function(channel)
        return chatList[channel] or {}
    end
    
	self.GetMsgList = function(id)
        self.RemoveUnreadID(id)
        return msgList[id] or {}
	end
    
    self.GetRecentList = function()
        local recent = {}
        for i=1,#recentList do
            table.insert(recent,actorInfo[recentList[i]])
        end
        return recent
    end
    
    self.GetQuickMsg = function()
        return quickMsg or {}
    end
    
    self.SaveQuickMsg = function(msgs)
        quickMsg = msgs
        self.SaveMsg ()
    end
    
    self.UnreadMsgExsit = function(id)
        for i=1,#unreadActorList do
			if unreadActorList[i] == id then
                return true
            end
		end
        return false
	end
	
	self.LoadMsg = function()
		local chatInfo = ReadActorFile('ChatInfo',self.actorID)
        chatInfo = chatInfo or {}
        msgList = chatInfo.msgList or {}
        unreadActorList = chatInfo.unreadActorList or {}
        recentList = chatInfo.recentList or {}
        actorInfo = chatInfo.actorInfo or {}
        channelCost = chatInfo.channelCost or {}
        quickMsg = chatInfo.quickMsg or {}
	end
	
	self.SaveMsg = function()
        local chatInfo = {}
        chatInfo.msgList = msgList
        chatInfo.unreadActorList = unreadActorList
        chatInfo.recentList = recentList
        chatInfo.actorInfo = actorInfo
        chatInfo.channelCost = channelCost
        chatInfo.quickMsg = quickMsg
		WriteActorFile('ChatInfo',self.actorID,chatInfo)
	end
	
    self.ShowChannelCost = function(channel)
        return channelCost[channel] ~= os.date("%x", networkMgr:GetConnection().ServerSecondTimestamp)
    end
    
    self.SaveChannelCost = function(channel)
        channelCost[channel] = os.date("%x", networkMgr:GetConnection().ServerSecondTimestamp)
        self.SaveMsg()
    end
    
	self.RemoveUnreadID = function(id)
		local index = 0
		for i=1,#unreadActorList do
			if unreadActorList[i] == id then
				index = i
				break
			end
		end
        if index ~= 0 then
            table.remove(unreadActorList,index)
            self.SaveMsg()
            self.UpdateRedDot()
        end
	end
    
    self.UpdateRedDot = function()
        self.unreadMessage = #unreadActorList > 0
        UIManager.GetCtrl(ViewAssets.MainLandUI).UpdateRedDot()
    end
    
    self.AddNewMail = function()
        self.unreadMail = true
        UIManager.GetCtrl(ViewAssets.MainLandUI).UpdateRedDot()
    end
    
    self.Clear = function()
        chatList = {}
    end
    
    MessageRPCManager.AddUser(self, 'AddNewMail')
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, self.OnLogin)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_REDS, self.HandleRedDot)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_CHAT, self.HandleTalkMsg)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_GET, self.HandleOfflineMsg)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_CHAT_BROADCAST, self.HandleBroadcast)
    MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_SYSTEM_MESSAGE, self.HandleSysMsg)
    MessageRPCManager.AddUser(self,'CallTogetherByOfficer')
    MessageRPCManager.AddUser(self,'PreRespondToCallTogetherRet')
    MessageRPCManager.AddUser(self,'RespondToCallTogetherRet ')
    return self
    
end

ChatManager = ChatManager or CreateChatManager()