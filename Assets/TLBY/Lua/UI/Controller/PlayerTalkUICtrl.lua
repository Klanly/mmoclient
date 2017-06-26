---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/ChatManager"

function CreatePlayerTalkUICtrl()
    local self = CreateCtrlBase()
	local id
    local selfId
    local playerData
	local takItemList = {}
    local show = false
    
    local BindData = function(item,data)
        local icon = item.transform:FindChild('mask/icon'):GetComponent("Image")
        local text = item.transform:FindChild('text'):GetComponent("TextMeshProUGUI")
        local textBg = item.transform:FindChild('textBg'):GetComponent("RectTransform")
        text.text = data.data
        icon.overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
        local width = text.preferredWidth + 40
        if width > 640 then width = 640 end
        local hight = text.preferredHeight + 30
        textBg.sizeDelta = Vector2.New(width,hight)
        if data.actor_id ~= selfId then
            local name = item.transform:FindChild('name'):GetComponent("TextMeshProUGUI")
            name.text = data.actor_name
        else
            text:GetComponent('RectTransform').anchoredPosition = Vector2.New(466 + 600 - width,-64)
        end
        item:GetComponent('LayoutElement').preferredHeight = text.preferredHeight + 90
    end
        
    local DestroyList = function()
        for i=1,#takItemList do
            GameObject.Destroy(takItemList[i])
        end
		takItemList = {}
    end
    
	self.onLoad = function(data)
        show = true
        
        id = data.actor_id
        playerData = data
        
        self.view.selfTalk:SetActive(false)
        self.view.otherTalk:SetActive(false)
        self.view.dateItem:SetActive(false)
        
        selfId = MyHeroManager.heroData.actor_id
        self.view.friendValue:GetComponent("TextMeshProUGUI").text = '好友度 '..(data.friend_value or 1)
        self.view.title:GetComponent("TextMeshProUGUI").text = LuaUIUtil.GetTitleByFriendValue(data.friend_value or 1)
        
        self.AddClick(self.view.btnSend,self.SendClick)
        
        self.RefreshTalkList()
	end
	
	self.onUnload = function()
        show = false
        DestroyList()
	end
    
    self.SendClick = function()
        if MyHeroManager.heroData.actor_id == id then
            return
        end
        local talk = self.view.inputField:GetComponent('TMP_InputField').text
        if talk == "" then return end
        local data = {}     
        data.actor_id = id
        data.data = talk        
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_CHAT , data)
		self.view.inputField:GetComponent('TMP_InputField').text = ""
        
        ChatManager.AddActorInfo(playerData)
    end
    
    self.RefreshTalkList = function()
        if not show then return end
        
        DestroyList()
		local talkList = ChatManager.GetMsgList(id)
        local showTime = math.ceil(networkMgr:GetConnection().ServerSecondTimestamp/1800)
        for i=1,#talkList do 
            local dateItem = nil
            local point = talkList[i].msg_time
            local sameDay = os.date("%x", talkList[i].msg_time) == os.date('%x', networkMgr:GetConnection().ServerSecondTimestamp)
            local showDate = (i==1 and not sameDay) or (i~=1 and os.date("%x", point) ~= os.date("%x",talkList[i-1].msg_time))
            if showDate then
                dateItem = GameObject.Instantiate(self.view.dateItem)
                dateItem.transform:FindChild('date'):GetComponent("TextMeshProUGUI").text = string.format('%4d-%2d-%2d',os.date("%Y",point),os.date("%m",point),os.date("%d",point))
            elseif sameDay and showTime ~= math.ceil(point/1800) then
                showTime = math.ceil(point/1800)
                dateItem = GameObject.Instantiate(self.view.dateItem)
                dateItem.transform:FindChild('date'):GetComponent("TextMeshProUGUI").text = string.format('%02d:%02d:%02d',os.date("%H",point),os.date("%M",point),os.date("%S",point))
            end 
            
            local clone = nil
            if talkList[i].actor_id == selfId then
                clone = GameObject.Instantiate(self.view.selfTalk)
                clone:SetActive(true)
                BindData(clone,talkList[i])
            elseif talkList[i].actor_id == id then
                clone = GameObject.Instantiate(self.view.otherTalk)
                clone:SetActive(true)
                BindData(clone,talkList[i])
            end

            if clone ~= nil then
                if dateItem ~= nil then
                    dateItem.transform:SetParent(self.view.talkList.transform,false)
                    table.insert(takItemList,dateItem)
                    dateItem:SetActive(true)
                end
                clone.transform:SetParent(self.view.talkList.transform,false)
                table.insert(takItemList,clone)
            end
        end
        local hight = 0     
        for _,v in pairs(takItemList) do
            hight = hight + v:GetComponent('LayoutElement').preferredHeight
        end
        local layOutGroup = self.view.talkList:GetComponent('VerticalLayoutGroup')
        self.view.talkList:GetComponent('RectTransform').sizeDelta = Vector2.New(0,hight)
        self.view.scrollview:GetComponent('ScrollRect').verticalNormalizedPosition = 0
    end
    
	return self
end

return CreatePlayerTalkUICtrl()