---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/Controller/FriendsUICtrl"

function CreateFriendsAddUICtrl()
    local self = CreateCtrlBase()
    local resultDataList = nil
    local timeInfo = nil
    local allowSearch = true
    local chatTable = require'Logic/Scheme/system_friends_chat'
    
    local BindData = function(item,key)
        if resultDataList and resultDataList[key+1] then
            item:SetActive(true)
        else
            item:SetActive(false)
            return
        end
        local data = resultDataList[key+1]
        local icon = item.transform:FindChild('icon'):GetComponent("Image")
        local name = item.transform:FindChild('name'):GetComponent("TextMeshProUGUI")
        local add = item.transform:FindChild('add').gameObject
        local des = item.transform:FindChild('des'):GetComponent("TextMeshProUGUI")
        name.text = data.actor_name
        des.text = 'ID '..data.actor_id
        item.transform:FindChild('level'):GetComponent("TextMeshProUGUI").text = data.level
        item.transform:FindChild('vocation'):GetComponent("TextMeshProUGUI").text = UIManager.GetCtrl(ViewAssets.FriendsUI).VocationCH[data.vocation]
        item.transform:FindChild('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
        self.AddClick(add,function() ContactManager.AddFriend(data.actor_id) end)
    end
    
	self.onLoad = function()
        self.view.item:SetActive(false)
        self.view.scrollview:GetComponent('UIMultiScroller'):Init(self.view.item,740,130,0,6,1)
        self.AddClick(self.view.btnSearch, self.SendSearchMSG)
        self.view.noResultNote:SetActive(false)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_SEARCH , self.HandleSearchMSG)
	end
	
	self.onUnload = function()
        self.view.scrollview:GetComponent('UIMultiScroller'):UpdateData(0,BindData)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_FRIEND_SEARCH , self.HandleSearchMSG)
	end
    
    self.SendSearchMSG = function()
        UIManager.UnloadView(ViewAssets.ContractSelectNoteUI)
        if not allowSearch then
            UIManager.ShowNotice('搜索过于频繁，请稍后再搜索')
            return 
        end
        
        local searchString = self.view.inputField:GetComponent('TMP_InputField').text
        if utf8.len(searchString) < 2 then 
            UIManager.ShowNotice('输入文字信息不足，请输入2个以上汉字')
            return 
        end
        
        allowSearch = false
        if timeInfo then
            Timer.Remove(timeinfo)
        end
        timeInfo = Timer.Delay(chatTable.Parameter[6].Value,function() timeInfo = nil allowSearch = true end)
        
        local data = {}
        data.search_string = searchString
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_FRIEND_SEARCH , data) 
    end
    
    self.HandleSearchMSG = function(data)
        if data.result ~= 0 then
            UIManager.ShowErrorMessage(data.result)
            return
        end
        if table.isEmptyOrNil(data.search_results) then
            self.view.noResultNote:SetActive(true)
            self.view.noneResultText:GetComponent("TextMeshProUGUI").text = string.format('未搜索到关键字或ID为<color=red>“%s”</color>的玩家，请确认后重新搜索。',self.view.inputField:GetComponent('TMP_InputField').text)
            self.view.scrollview:GetComponent('UIMultiScroller'):UpdateData(0,BindData)
            return
        end
        self.view.noResultNote:SetActive(false)
        resultDataList = {}
        for _,v in pairs(data.search_results) do
            table.insert(resultDataList,v)
        end
        self.view.scrollview:GetComponent('UIMultiScroller'):UpdateData(#resultDataList,BindData)
    end
	
	return self
end

return CreateFriendsAddUICtrl()