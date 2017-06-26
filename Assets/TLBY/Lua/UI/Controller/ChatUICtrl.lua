---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateChatUICtrl()
    local self = CreateCtrlBase()
    local chatTable = require'Logic/Scheme/system_friends_chat'
    local channelContent = chatTable.ChannelContent
    local channelControl = chatTable.ChannelControl
    local historyMsg = {}
    local channelCD = {false,false,false,false,false,false}
    local timeInfo = {}
    local currentChannel = 0
    local takItemList = {}
    local unreadCount = 0
    local attachInfo = nil
    local ChatAdditionUICtrl = require "UI/Controller/ChatAdditionUICtrl"
    local DestroyList = function()
        for i=1,#takItemList do
            GameObject.Destroy(takItemList[i])
        end
		takItemList = {}
    end
    
    local BindData = function(item,data)
        item:SetActive(true)
        local icon = item.transform:FindChild('mask/icon'):GetComponent("Image")
        local textBg = item.transform:FindChild('textBg'):GetComponent("Image").gameObject
        self.AddClick(icon.gameObject,function() if data.actor_id ~= ChatManager.actorID then ContactManager.QuestPlayerInfo(data.actor_id,icon.transform.position) end end)
        self.AddClick(textBg,function() if data.attach then self.HandleAttach(data.attach) end end)
        local text = item.transform:FindChild("text"):GetComponent("TextMeshProUGUI")
        local textBg = item.transform:FindChild('textBg'):GetComponent("RectTransform")
        local channel = item.transform:FindChild('channel'):GetComponent('TextMeshProUGUI')
        text.text = data.data
        channel.text = string.format('<color=%s>%s</color>',channelControl[data.message_type].Color,ChatManager.typeName[data.message_type])
        local width = text.preferredWidth + 45
        if width > 510 then width = 510 end
        local hight = text.preferredHeight + 25
        if hight < 60 then hight = 60 end
        textBg.sizeDelta = Vector2.New(width,hight)
        local name = item.transform:FindChild('name'):GetComponent("TextMeshProUGUI")
        name.text = data.actor_name
        item:GetComponent('LayoutElement').preferredHeight = hight + 60
        icon.overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
    end
    
    local BindSysData = function(item,data)
        item:SetActive(true)
        local text = item.transform:FindChild('messageText'):GetComponent("TextMeshProUGUI")
        local textBg = item.transform:FindChild('messageBg'):GetComponent("RectTransform")
        self.AddClick(textBg.gameObject,function() if data.attach then self.HandleAttach(data.attach) end end)
        local des = item.transform:FindChild('fight/des'):GetComponent("TextMeshProUGUI")
        des.text = string.format('<color=%s>系统</color>',channelControl[data.message_type].Color)
        text.text = data.data
        item:GetComponent('LayoutElement').preferredHeight = text.preferredHeight + 90
        textBg.sizeDelta = Vector2.New(textBg.sizeDelta.x,text.preferredHeight + 20)
    end
    
    local Update = function()
        if self.view.unreadMessage.activeSelf then
            if self.scrollRect.verticalNormalizedPosition < 0.01 then
                self.view.unreadMessage:SetActive(false)
            end
        end
    end
    
	self.onLoad = function()
        show = true
        self.view.chatItem:SetActive(false)
        self.view.systemMsgItem:SetActive(false)
        self.view.bg:GetComponent('RectTransform').anchoredPosition = Vector2.New(-531,0) 
        self.inputField = self.view.inputField:GetComponent('TMP_InputField')
        self.AddClick(self.view.closeBtn,self.Close)
        self.AddClick(self.view.overlay,self.CloseSubPage)
        self.AddClick(self.view.btnHistory,self.ShowHistory)
        self.AddClick(self.view.btnAddition,self.ShowAddition)
        self.AddClick(self.view.btnSend,self.SendText)
        self.AddClick(self.view.unreadMessage,self.ReadNewMSG)
        self.AddClick(self.view.btnVoice,self.VoiceInput)
        self.AddClick(self.view.btnLocation,self.SendPos)
        self.AddClick(self.view.btnTextInput,self.TextInput)
        self.scrollRect = self.view.scrollview:GetComponent('ScrollRect')
        for i=1,6 do
            -- if i == 1 or i ==3 then
                -- self.AddClick(self.view['tab'..i],nil)
                -- self.view['tab'..i]:GetComponent('Image').overrideSprite = self.view.disableImage:GetComponent('Image').sprite
                -- self.view['tabText'..i]:GetComponent("TextMeshProUGUI").color = Color.New(109/255,87/255,74/255,1)
            -- else
                self.AddClick(self.view['tab'..i],function() self.TabSelect(i) end)
                self.view['tab'..i]:GetComponent('Image').overrideSprite = self.view.enableImage:GetComponent('Image').sprite
                self.view['tabText'..i]:GetComponent("TextMeshProUGUI").color = Color.New(224/255,200/255,184/255,1)
            --end
        end
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_CHAT, self.HandleChat)
        self.TabSelect(6)
        self.view.historyPart:SetActive(false)
        self.view.overlay:SetActive(false)
        self.view.additionPart:SetActive(false)
        UpdateBeat:Add(Update,self)
	end
	
	self.onUnload = function()
        show = false
        UpdateBeat:Remove(Update,self)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_CHAT, self.HandleChat)
	end
    
    self.TabSelect = function(index)
        currentChannel = index
    
        self.view.light:SetActive(true)
        self.view.light.transform.position = self.view['tab'..index].transform.position
        self.view.lightText:GetComponent("TextMeshProUGUI").text = self.view['tabText'..index]:GetComponent("TextMeshProUGUI").text
        self.view.bottom:SetActive(currentChannel ~= 5)
        self.TextInput()
        self.RefreshChatList(currentChannel,true)      
    end
    
    self.VoiceInput = function()
        if channelContent[currentChannel].VoiceChat == 0 then
            UIManager.ShowNotice("当前频道不支持语言输入")
            return
        end        
        
        self.view.textPart:SetActive(false)
        self.view.voicePart:SetActive(true)
    end
    
    self.HandleAttach = function(attach)
        if attach.type then
            if attach.type == "equip" then
                BagManager.ShowItemTips({item_data=attach.data},true)
            elseif attach.type == "item" then
                BagManager.ShowItemTips({item_data=attach.data},true)
            elseif attach.type == "position" and attach.x and attach.z and attach.scene_id then
                local hero = SceneManager.GetEntityManager().hero
                if hero then 
                    SceneManager.GetEntityManager().hero:moveToScene(constant.SCENE_TYPE.CITY,attach.scene_id, function()
                        local hero = SceneManager.GetEntityManager().hero
                        if hero then
                            hero:Moveto(Vector3.New(attach.x/100,attach.y/100,attach.z/100))
                        end
                    end)
                end
            elseif attach.type == "pet" then
            
            elseif attach.type == 'campInvite' then
                local data = {}
                data.func_name = 'on_pre_respond_to_call_together'
                data.caller_id = attach.caller_id
                MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,data)
            end
        end
    end
    
    self.UpdateAttach = function(info)
        local inputStr = self.inputField.text 
        if attachInfo and string.find(inputStr,'['..attachInfo.str..']') then
            self.inputField.text = string.gsub(inputStr,'%['..attachInfo.str..'%]','%['..info.str..'%]')    
        else
            self.inputField.text = inputStr..'['..info.str..']'
        end
        attachInfo = info
    end
    
    self.TextInput = function()
        self.view.voicePart:SetActive(false)
        self.view.textPart:SetActive(true)
    end
    
    self.RefreshChatList = function(tabIndex,showBottom)
        if tabIndex ~= currentChannel or (not show) then return end
        DestroyList()
		local talkList = ChatManager.GetBroadcast(currentChannel)
        for i=1,#talkList do 
            local clone = nil
            if talkList[i].actor_id == "-1" then
                clone = GameObject.Instantiate(self.view.systemMsgItem)
                BindSysData(clone,talkList[i])
            elseif talkList[i].actor_id == ChatManager.actorID then
                clone = GameObject.Instantiate(self.view.chatItem)
                BindData(clone,talkList[i])
            else
                clone = GameObject.Instantiate(self.view.chatItem)
                BindData(clone,talkList[i])
            end
            if clone ~= nil then
                clone.transform:SetParent(self.view.talkList.transform,false)
                table.insert(takItemList,clone)
            end
        end
        local hight = 0     
        for _,v in pairs(takItemList) do
            hight = hight + v:GetComponent('LayoutElement').preferredHeight
        end
        local layOutGroup = self.view.talkList:GetComponent('VerticalLayoutGroup')
        local contentRect = self.view.talkList:GetComponent('RectTransform')
        contentRect.sizeDelta = Vector2.New(0,hight)

        local scrollHight = self.view.scrollview:GetComponent('RectTransform').sizeDelta.y
        local contentBottom = hight - contentRect.anchoredPosition.y
        local newHight = 0
        if takItemList[#takItemList] then
            newHight = takItemList[#takItemList]:GetComponent('LayoutElement').preferredHeight
        end
        if showBottom then
            self.scrollRect.verticalNormalizedPosition = 0
            self.view.unreadMessage:SetActive(false)
            unreadCount = 0
        else
            if contentBottom - newHight < scrollHight + 80 then
                self.scrollRect.verticalNormalizedPosition = 0
                self.view.unreadMessage:SetActive(false)
                unreadCount = 0
            else
                self.view.unreadMessage:SetActive(true)
                unreadCount = unreadCount + 1
                self.view.textunreadmessage:GetComponent("TextMeshProUGUI").text = string.format("%d条消息未读，点击查看",unreadCount)
            end
        end

    end
    
    self.ReadNewMSG = function()
        self.scrollRect.verticalNormalizedPosition = 0
        self.view.unreadMessage:SetActive(false)
        unreadCount = 0
    end
    
    self.Close = function()
        local tween = BETween.anchoredPosition(self.view.bg, 0.2, Vector2.New(-531,0), Vector2.New(-1400,0))
        tween.onFinish = self.close
    end
    
    self.CloseSubPage = function()
        self.view.historyPart:SetActive(false)
        ChatAdditionUICtrl.Close()
        self.view.overlay:SetActive(false)
    end
    
    self.SendText = function()
        if self.inputField.text == '' then return end
        if MyHeroManager.heroData.level < channelContent[currentChannel].OpenLevel then UIManager.ShowNotice(string.format('达到%d级可在该频道发言',channelControl[currentChannel].OpenLevel)) return end
        if string.len(self.inputField.text) > 120 then UIManager.ShowNotice('输入字符超出上限，无法继续输入。') return end
        if channelCD[currentChannel] then UIManager.ShowNotice('发送过于频繁，请稍后再发送') return end
        local consume = channelContent[currentChannel].Consumption
        if #consume > 1 and not LuaUIUtil.CostItem(consume[1],consume[2] or 0,true) then return end    
        if #consume > 1 and ChatManager.ShowChannelCost(currentChannel) then
            UIManager.PushView(ViewAssets.ChatConsumeUI,nil,currentChannel)
            return
        end  
        
        self.SendMsg()
    end
    
    self.SendPos = function()
        local cd = channelContent[currentChannel].ChatInterval
        if cd > 0 then
            channelCD[currentChannel] = true
            timeInfo[currentChannel] = Timer.Delay(cd,
                function() 
                    if timeInfo[currentChannel] then
                        Timer.Remove(timeInfo[currentChannel])
                        timeInfo[currentChannel] = nil 
                    end
                    channelCD[currentChannel] = false 
                end)
        end
        local data = {}
        data.channel = currentChannel
        local p = SceneManager.GetEntityManager().hero.behavior.transform.localPosition
        local tableData = SceneManager.GetCurSceneData()
        data.data = string.format('我在[%s%.2f,%.2f]',LuaUIUtil.GetTextByID(tableData,'Name'),p.x,p.z)
        local attach = {}
        attach.type = "position"
        attach.scene_id = SceneManager.currentSceneId
        attach.x = math.floor(p.x*100)
        attach.y = math.floor(p.y*100)
        attach.z = math.floor(p.z*100)
        data.attach = attach
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CHAT, data) 
    end
    
    self.SendMsg = function()
        local cd = channelContent[currentChannel].ChatInterval
        if cd > 0 then
            channelCD[currentChannel] = true
            timeInfo[currentChannel] = Timer.Delay(cd,
                function() 
                    if timeInfo[currentChannel] then
                        Timer.Remove(timeInfo[currentChannel])
                        timeInfo[currentChannel] = nil 
                    end
                    channelCD[currentChannel] = false 
                end)
        end
        local data = {}
        data.channel = currentChannel
        data.data = self.inputField.text
        if attachInfo and string.find(data.data,'['..attachInfo.str..']') then
            data.attach = attachInfo
        else
            attachInfo = nil
        end
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CHAT, data)
    end
    
    self.ShowHistory = function()
        self.view.historyPart:SetActive(true)
        for i=1,4 do
            local text = self.view['historyText'..i]
            if i > #historyMsg then
                text:GetComponent("TextMeshProUGUI").text = ''
                self.AddClick(text,nil)
            else

                text:GetComponent("TextMeshProUGUI").text = historyMsg[i]
                self.AddClick(text,function() self.HistoryTextClick(historyMsg[i]) end)
            end
        end
        self.view.overlay:SetActive(true)
    end
    
    self.HistoryTextClick = function(text)
        self.inputField.text = text
        self.view.historyPart:SetActive(false)
        self.view.overlay:SetActive(false)
    end
    
    self.ShowAddition = function()
        ChatAdditionUICtrl.Open()
    end
    
    self.HandleChat = function(data)
        if data.result == 0 then
            local removeIndex = 0
            if #historyMsg > 3 then
                removeIndex = 1
            end
            for i=0,#historyMsg do
                if historyMsg[i] == self.inputField.text then
                    removeIndex = i
                    break
                end
            end
            if removeIndex ~= 0 then
                table.remove(historyMsg,removeIndex)
            end
            table.insert(historyMsg,self.inputField.text)
            self.inputField.text = ""
            attachInfo = nil
        else
            UIManager.ShowErrorMessage(data.result)
        end
    end
    
	return self
end

return CreateChatUICtrl()