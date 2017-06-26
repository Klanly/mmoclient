---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/Controller/FriendsUICtrl"

function CreateFriendsApproveUICtrl()
    local self = CreateCtrlBase()
    local applyDataList = nil
    
    local BindData = function(item,key)
        if applyDataList and applyDataList[key+1] then
            item:SetActive(true)
        else
            item:SetActive(false)
            return
        end
        local data = applyDataList[key+1]
        local icon = item.transform:FindChild('icon'):GetComponent("Image")
        local name = item.transform:FindChild('name'):GetComponent("TextMeshProUGUI")
        local add = item.transform:FindChild('add').gameObject
        local des = item.transform:FindChild('des'):GetComponent("TextMeshProUGUI")
        name.text = data.actor_name
        des.text = 'ID '..data.actor_id
        item.transform:FindChild('level'):GetComponent("TextMeshProUGUI").text = data.level
        item.transform:FindChild('vocation'):GetComponent("TextMeshProUGUI").text = UIManager.GetCtrl(ViewAssets.FriendsUI).VocationCH[data.vocation]
        item.transform:FindChild('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
        self.AddClick(add,function() self.SendApproveMSG(data.actor_id) end)        
    end
    
    local UpdateList  = function()
        applyDataList = {}
        for _,v in pairs(ContactManager.GetContactList('applicants')) do
            table.insert(applyDataList,v)
        end
        self.view.scrollview:GetComponent('UIMultiScroller'):UpdateData(#applyDataList,BindData)    
    end
    
	self.onLoad = function()
        self.view.item:SetActive(false)
        self.view.scrollview:GetComponent('UIMultiScroller'):Init(self.view.item,780,130,0,6,1)
        UpdateList()
        self.AddClick(self.view.btnApprove,self.ApproveAll)
        self.AddClick(self.view.btnRefuse,self.RefuseAll)
	end
	
	self.onUnload = function()
        self.view.scrollview:GetComponent('UIMultiScroller'):UpdateData(0,BindData)
	end
    
	self.ApproveAll = function()
        local data = {}
        data.actor_ids = {}
        for _,v in pairs(applyDataList) do
            table.insert(data.actor_ids,v.actor_id)
        end
        data.accept = true
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_ACCEPT , data)   
    end
    
    self.RefuseAll = function()
        local data = {}
        data.actor_ids = {}
        for _,v in pairs(applyDataList) do
            table.insert(data.actor_ids,v.actor_id)
        end
        data.accept = false
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_ACCEPT , data)
    end
    
    self.SendApproveMSG = function(id)
        local data = {}
        data.actor_ids = {}
        table.insert(data.actor_ids,id)
        data.accept = true
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_ACCEPT , data) 
    end
    
    self.HandleFriendListMSG = function(data)
        if self.view == nil then return end
        local applicants = ContactManager.GetContactList('applicants')
        if applicants ~= nil then
            if table.isEmptyOrNil(applicants) then
                UIManager.GetCtrl(ViewAssets.FriendsUI).OpenSubView('好友申请',ViewAssets.ContractSelectNoteUI,"还没有任何好友申请哦，多去公会和世界频道聊聊天吧。")
            else
                UpdateList(applicants)
            end
        end
    end
    
	return self
end

return CreateFriendsApproveUICtrl()