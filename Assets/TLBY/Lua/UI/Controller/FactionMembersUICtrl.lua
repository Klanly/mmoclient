require "UI/Controller/LuaCtrlBase"

local function CreateFactionMembersUICtrl()
	local self = CreateCtrlBase()
    self.resourceBar = {}
        
    local factionTopCost = (require "Logic/Scheme/system_faction").Parameter[17].Value
    local members = {}
    local selectIndex = -1

    local BindData = function(item, index, fix)
        local data = members[index + 1]
        local transform = item.transform
        transform:Find('vocation'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.getVocationName(data.vocation)
        transform:Find('position'):GetComponent('TextMeshProUGUI').text = FactionManager.GetPositionName(data.position)
        transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
        transform:Find('fightValue'):GetComponent('TextMeshProUGUI').text = data.fightValue
        transform:Find('level'):GetComponent('TextMeshProUGUI').text = data.level
        local onlineTime = transform:Find('onlineTime'):GetComponent('TextMeshProUGUI')
        if data.last_logout_time == -1 then
            onlineTime.text = '在线'
        else
            local offLineTime = networkMgr:GetConnection().ServerSecondTimestamp - data.last_logout_time
            if offLineTime <60*60 then
                onlineTime.text = string.format('%d分前', offLineTime/60)
            elseif offLineTime < 60*60*24 then
                onlineTime.text = string.format('%d时前', offLineTime/60/60)
            elseif offLineTime < 60*60*24*30 then
                onlineTime.text = string.format('%d天前', offLineTime/60/60/24)
            elseif offLineTime < 60*60*24*365 then
                onlineTime.text = string.format('%d月前', offLineTime/60/60/24/30)
            else
                onlineTime.text = string.format('%d年前', offLineTime/60/60/24/365)
            end
        end
        transform:Find('attribute'):GetComponent('TextMeshProUGUI').text = string.format('%d/%d/%d',0,0,0)
        
        if fix==nil then
            local yellowBg = transform:Find('yellowBg').gameObject
            yellowBg:SetActive(index%2 == 0)
            transform:Find('select').gameObject:SetActive(selectIndex == index+1)
            local whiteBg = transform:Find('whiteBg').gameObject
            whiteBg:SetActive(index%2 == 1)
            self.AddClick(yellowBg, function() self.SelectItem(index + 1,yellowBg.transform.position) end)
            self.AddClick(whiteBg, function() self.SelectItem(index + 1,whiteBg.transform.position) end)
        end

    end
    
    local RefreshTopTime = function()
        local leftTime = FactionManager.GetTopTime() - networkMgr:GetConnection().ServerSecondTimestamp
        if leftTime <= 0 then
            self.view.topTime:GetComponent('TextMeshProUGUI').text = ''
            self.view.timeBg:SetActive(false)
            return
        end
        self.view.timeBg:SetActive(true)
        self.view.topTime:GetComponent('TextMeshProUGUI').text = string.format('置顶时间: %d:%d:%d',math.floor(leftTime/3600),math.floor(leftTime/60)%60,leftTime%60)
    end
    
    self.OpenUI = function()
        MessageRPCManager.AddUser(self, 'GetFactionMembersInfoRet')
        local data = {}
        data.func_name = 'on_get_faction_members_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.GetFactionMembersInfoRet = function(data)
        if data.result ~= 0 then return end

        if self.isLoaded then
            self.FreshUI(data.members)
        else
            UIManager.PushView(ViewAssets.FactionMembersUI,nil,data.members)
        end
    end
    
    local timer = nil
	self.onLoad = function(list)
        self.view.factionItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.factionItem, 2123,95,0,8,1)
        self.AddClick(self.view.btnLeave,self.LeaveFaction)
        self.AddClick(self.view.btnTop,self.TopFaction)
        self.AddClick(self.view.btnMerge,self.MergeFaction)
        self.AddClick(self.view.btnDismiss,self.DismissFaction)
        self.AddClick(self.view.btnApplyList,self.ShowApplyList)
        
        MessageRPCManager.AddUser(self, 'ChangePositionRet')
        MessageRPCManager.AddUser(self, 'KickFactionMemberRet')
        MessageRPCManager.AddUser(self, 'TransferChiefRet')
        self.FreshUI(list)
        RefreshTopTime()
        timer = Timer.Repeat(1, RefreshTopTime)
	end
    
    self.FreshUI = function(list) 
        members = {}
        for k,v in pairs(list) do
            table.insert(members,v)
            if v.actor_id == MyHeroManager.heroData.actor_id then
                FactionManager.UpdateFactionPosition(v.position)
                BindData(self.view.myFactionItem,#members-1,true)
            end
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#members, BindData)
    end
    
    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'GetFactionMembersInfoRet')
        MessageRPCManager.RemoveUser(self, 'ChangePositionRet')   
        MessageRPCManager.RemoveUser(self, 'KickFactionMemberRet')
        MessageRPCManager.RemoveUser(self, 'TransferChiefRet')
        Timer.Remove(timer)
	end
    
    self.ShowApplyList = function()
        if not FactionManager.SelfAuthority('Allaowance',true) then return end
            
        self.close()
        UIManager.GetCtrl(ViewAssets.FactionApplyUI).OpenUI()
    end
    
    self.DismissFaction = function()
        if not FactionManager.SelfAuthority('Dissolve',true) then return end
        local Confirm = function()
            local data = {}
            data.func_name = 'on_dissolve_faction'
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
        UIManager.ShowDialog('你确定要解散帮会吗', '确定', '取消', Confirm, nil)
    end
    
    self.TopFaction = function()
        if not BagManager.CheckItemIsEnough({{constant.RESOURCE_NAME_TO_ID.ingot,factionTopCost}}) then
            return
        end
        local Confirm = function()
            local data = {}
            data.func_name = 'on_buy_faction_on_top'
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
        UIManager.ShowDialog(string.format('置顶帮会需要消耗%d元宝',factionTopCost), '确定', '取消', Confirm, nil)
    end
    
    self.LeaveFaction = function()
        local Confirm = function()
            local data = {}
            data.func_name = 'on_member_leave_faction'
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
        UIManager.ShowDialog('<size=120%>脱离帮派将会清空所有帮贡</size>\n<color=#5B040DFF>(24小时内无法加入其他帮会)', '确定', '取消', Confirm, nil)

    end
    
    self.MergeFaction = function()
        UIManager.ShowNotice('功能未开放')
    end
    
    self.KickFactionMemberRet = function(data)
        if data.result ~= 0 then return end
        
        self.FreshUI(data.members)   
    end
    
    self.ChangePositionRet = function(data)
        if data.result ~= 0 then return end
        
        self.FreshUI(data.members)
    end
    
    self.TransferChiefRet = function(data)
        if data.result ~= 0 then return end
        
        self.FreshUI(data.members)
    end
             
    self.SelectItem = function(index,position)
        selectIndex = index
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#members, BindData)
        ContactManager.QuestPlayerInfo(members[index].actor_id,position,members[index])
    end

	return self
end

return CreateFactionMembersUICtrl()
