require "UI/Controller/LuaCtrlBase"

local function CreateFactionApplyUICtrl()
	local self = CreateCtrlBase()
    
    local applyList = {}
    local selectIndex = -1

    
    local BindData = function(item, index)
        local data = applyList[index + 1]
        local transform = item.transform
        local yellowBg = transform:Find('yellowBg').gameObject
        yellowBg:SetActive(index%2 == 0)
        local whiteBg = transform:Find('whiteBg').gameObject
        whiteBg:SetActive(index%2 == 1)
        transform:Find('vocation'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.getVocationName(data.vocation)
        --transform:Find('position'):GetComponent('TextMeshProUGUI').text = data.position
        transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
        transform:Find('fightValue'):GetComponent('TextMeshProUGUI').text = data.fightValue
        transform:Find('level'):GetComponent('TextMeshProUGUI').text = data.level
        transform:Find('onlineTime'):GetComponent('TextMeshProUGUI').text = data.last_logout_time
        
        self.AddClick(transform:Find('btnComfirm').gameObject, function() self.ConfirmClick(true,data.actor_id) end)
        self.AddClick(transform:Find('btnRefuse').gameObject, function() self.ConfirmClick(false,data.actor_id) end)
        local more = transform:Find('btnMore').gameObject
        self.AddClick(more, function() self.More(index+1) end)
    end
    
    self.OpenUI = function()
        MessageRPCManager.AddUser(self, 'GetFactionApplyListRet')
        local data = {}
        data.func_name = 'on_get_faction_apply_list'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
	self.onLoad = function(list)
        self.view.item:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.item, 2123,95,0,8,1)
        self.AddClick(self.view.btnClear, self.ClearAll )
        self.AddClick(self.view.btnAllComfirm, self.ConfirmAll )
        self.AddClick(self.view.btnBack, self.BackClick )
        self.FreshUI(list)
        MessageRPCManager.AddUser(self, 'ReplyApplyJoinFactionRet')
        MessageRPCManager.AddUser(self, 'OneKeyReplyAllRet')
        
	end
    
    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'GetFactionApplyListRet')
        MessageRPCManager.RemoveUser(self, 'ReplyApplyJoinFactionRet')
        MessageRPCManager.RemoveUser(self, 'OneKeyReplyAllRet')
	end
    
    self.BackClick = function()
        self.close()
        UIManager.GetCtrl(ViewAssets.FactionMembersUI).OpenUI()
    end
    
    self.GetFactionApplyListRet = function(data)
        if data.result ~= 0 then return end
    

        if self.isLoaded then
            self.FreshUI(data.apply_list)
        else
            UIManager.PushView(ViewAssets.FactionApplyUI,nil,data.apply_list)
        end
    end
    
    self.FreshUI = function(list)
        applyList = {}
        for k,v in pairs(list) do
            table.insert(applyList,v)
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#applyList, BindData)
        self.view.empty:SetActive(#applyList == 0)
    end
    
    self.ConfirmClick = function(agree,id)
        local data = {}
        data.func_name = 'on_reply_apply_join_faction'
        data.is_agree = agree
        data.player_id = id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.ConfirmAll = function()
        local data = {}
        data.func_name = 'on_one_key_reply_all'
        data.is_agree = true
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.ClearAll = function()
        local data = {}
        data.func_name = 'on_one_key_reply_all'
        data.is_agree = false
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.ReplyApplyJoinFactionRet = function(data)
        if data.result ~= 0 then return end
        
        self.FreshUI(data.apply_list)
    end
    
    self.OneKeyReplyAllRet = function(data)
        if data.result ~= 0 then return end
        
        self.FreshUI(data.apply_list or {})
    end
    
    self.More = function(index)
        local data = {} 
        data.actor_id = applyList[index].actor_id
        data.actor_name = applyList[index].actor_name
        data.vocation = applyList[index].vocation
        data.sex = applyList[index].sex
        ContactManager.PushView(ViewAssets.FriendsUI,
            function(ctrl) 
                ctrl.SendPrivateMsg(data) 
            end
        )
    end
    
	return self
end

return CreateFactionApplyUICtrl()
