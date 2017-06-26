---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateSystemMsgUICtrl()
    local self = CreateCtrlBase()
    local takItemList = {}
    
    local BindData = function(item,data) 
        local msg = item.transform:FindChild('msgText'):GetComponent("TextMeshProUGUI")
        msg.text = data.data
        local hight = msg.preferredHeight+18
        if hight < 126 then hight = 126 end
        item.transform:FindChild('msgBg'):GetComponent("RectTransform").sizeDelta = Vector2.New(610,hight)
        item:GetComponent('LayoutElement').preferredHeight = hight + 11
    end
    
    local DestroyList = function()
        for i=1,#takItemList do
            GameObject.Destroy(takItemList[i])
        end
		takItemList = {}
    end
    
	self.onLoad = function(position)
        DestroyList()
        local systemMsgList = ChatManager.GetMsgList('-1')
        local showTime = math.ceil(networkMgr:GetConnection().ServerSecondTimestamp/1800)
        
        for i=1,#systemMsgList do
        
            local dateItem = nil
            local point = systemMsgList[i].time
            local sameDay = os.date("%x", systemMsgList[i].time) == os.date('%x', networkMgr:GetConnection().ServerSecondTimestamp)
            local showDate = (i==1 and not sameDay) or (i~=1 and os.date("%x", point) ~= os.date("%x",systemMsgList[i-1].time))
            if showDate then
                dateItem = GameObject.Instantiate(self.view.timeItem)
                dateItem.transform:FindChild('timeText'):GetComponent("TextMeshProUGUI").text = string.format('%4d-%2d-%2d',os.date("%Y",point),os.date("%m",point),os.date("%d",point))
            elseif sameDay and showTime ~= math.ceil(point/1800) then
                showTime = math.ceil(point/1800)
                dateItem = GameObject.Instantiate(self.view.timeItem)
                dateItem.transform:FindChild('timeText'):GetComponent("TextMeshProUGUI").text = string.format('%02d:%02d:%02d',os.date("%H",point),os.date("%M",point),os.date("%S",point))
            end 
            
            local clone = GameObject.Instantiate(self.view.msgItem)
            BindData(clone,systemMsgList[i])

            if clone ~= nil then
                clone:SetActive(true)
                if dateItem ~= nil then
                    dateItem.transform:SetParent(self.view.resultList.transform,false)
                    dateItem:SetActive(true)
                    table.insert(takItemList,dateItem)
                end
                clone.transform:SetParent(self.view.resultList.transform,false)
                table.insert(takItemList,clone)
            end
        end
        self.view.msgItem:SetActive(false)
        self.view.timeItem:SetActive(false)
        -- local hight = 0     
        -- for _,v in pairs(takItemList) do
            -- hight = hight + v:GetComponent('LayoutElement').preferredHeight
        -- end
        --local layOutGroup = self.view.resultList:GetComponent('VerticalLayoutGroup')
        --self.view.resultList:GetComponent('RectTransform').sizeDelta = Vector2.New(0,hight)
        self.view.scrollview:GetComponent('ScrollRect').verticalNormalizedPosition = 0
	end
	
	self.onUnload = function()
        if itemList then itemList.Destroy() end
	end
	
	return self
end

return CreateSystemMsgUICtrl()