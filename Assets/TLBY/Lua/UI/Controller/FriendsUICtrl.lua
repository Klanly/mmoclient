---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
require "UI/ChatManager"
local MainLandUICtrl = UIManager.GetCtrl(ViewAssets.MainLandUI)

function CreateFriendsUICtrl()
    local self = CreateCtrlBase()
	
	local currentTabIndex = 1
	local contractGroup = ""
	local selectContractID = -1
	local contractList = nil
	local contractDataList = nil
    local group = {"friends","blacklist","enemys","applicants"}
    
    self.VocationCH = {'剑','拳','巫','箭'}
    
    local subPages = {
        ViewAssets.FriendsAddUI,
        ViewAssets.FriendsApproveUI,
		ViewAssets.PlayerTalkUI,
		ViewAssets.SystemMsgUI,
        ViewAssets.ContractSelectNoteUI,
    }
    
	self.OpenSubView = function(title,view,...)
        for i=1,#subPages do
            if view ~= subPages[i] then
                UIManager.UnloadView(subPages[i])
            end
        end

        self.view.subPageTitle:GetComponent("TextMeshProUGUI").text = title
        local ctrl = UIManager.GetCtrl(view)
        if ctrl.isLoaded then
            ctrl.onLoad(...)
        else
            UIManager.PushView(view,nil,...)
        end
	end
	
	local BindData = function(item,key)
        if contractDataList and contractDataList[key+1] then
            item:SetActive(true)
        else
            item:SetActive(false)
            return
        end
        local data = contractDataList[key+1]
        local name = item.transform:FindChild('name'):GetComponent("TextMeshProUGUI")
        local recentMsg = item.transform:FindChild('recentMsg'):GetComponent("TextMeshProUGUI")
        local redDot = item.transform:FindChild('redDot').gameObject
        local level = item.transform:FindChild('level'):GetComponent("TextMeshProUGUI")
        local vocation = item.transform:FindChild('vocation'):GetComponent("TextMeshProUGUI")
        local icon = item.transform:FindChild('icon'):GetComponent('Image')
        local btnMore = item.transform:FindChild('btnMore').gameObject
        local selected = item.transform:FindChild('selected').gameObject
        redDot:SetActive(ChatManager.UnreadMsgExsit(data.actor_id))
        self.AddClick(btnMore, function() ContactManager.QuestPlayerInfo(data.actor_id,btnMore.transform.position) end )
        self.AddClick(item.transform:FindChild("bg").gameObject ,function() redDot:SetActive(false) self.SelectContract(key+1) end)
        selected:SetActive(data.actor_id == selectContractID)
        LuaUIUtil.SetPicGray(icon,data.offlinetime and data.offlinetime > 0)
        if data.actor_id == "-1" then
            level.text = ""
            name.text = "系统消息"
            vocation.text = ""
            icon.overrideSprite = nil
            recentMsg.text = ""
            btnMore:SetActive(false)
        else
            level.text = data.level
            name.text = data.actor_name
            vocation.text = self.VocationCH[data.vocation]
            icon.overrideSprite = LuaUIUtil.GetHeroIcon(data.vocation,data.sex)
            recentMsg.text = data.data
            btnMore:SetActive(true)
        end

	end
	
	self.onLoad = function()           
        self.view.contractScrollView:GetComponent('UIMultiScroller'):Init(self.view.contractItem,535,100,0,7,1)
		self.AddClick(self.view.btnClose,self.close)
		self.AddClick(self.view.btnFriendAdd,function() self.OpenSubView('好友添加',ViewAssets.FriendsAddUI) UIManager.PushView(ViewAssets.ContractSelectNoteUI,nil,'好友搜索只能搜索当前在线的玩家') end)
		self.AddClick(self.view.btnFriendApply,self.OpenApplyPage)
        self.AddClick(self.view.btnMail,self.ShowMailUI)
		for i=1,2 do
			self.AddClick(self.view['tab'..i],function() self.OnTabClick(i) end)
		end
        
		self.OnTabClick(1)
        self.RefreshApplyRedDot()
        ChatManager.RefreshUnreadMailRedDot()
	end

	self.onUnload = function()
        for i=1,#subPages do
            UIManager.UnloadView(subPages[i])
        end
        local teamUI = UIManager.GetCtrl(ViewAssets.TeamUI)
        if teamUI.isLoaded then
            teamUI.OnTeamInfoChange() -- 显示teamUI中的模型
        end
	end
    
    self.ShowMailUI = function()
        self.close()
        UIManager.GetCtrl(ViewAssets.MailUI).OpenUI()
    end
        
    self.RefreshRecent = function()
        if currentTabIndex == 1 and self.isLoaded then
            contractDataList = ChatManager.GetRecentList()
			self.view.contractScrollView:GetComponent('UIMultiScroller'):UpdateData(#contractDataList,BindData)
        end
    end
    
    self.RefreshApplyRedDot = function()
        if not self.isLoaded then return end
        
        local num = 0
        for _,v in pairs(ContactManager.GetContactList('applicants')) do
            num = num + 1
        end
        self.view.applyCountText:GetComponent("TextMeshProUGUI").text = num
        self.view.applyRedDot:SetActive(num > 0)
    end
	
	self.OnTabClick = function(index)
		currentTabIndex = index
        selectContractID = -1
		self.view.toggleLightText:GetComponent("TextMeshProUGUI").text = self.view['tabText'..index]:GetComponent("TextMeshProUGUI").text
		self.view.toggleLight.transform.position = self.view['tab'..index].transform.position
		for i=1,3 do
			self.view[group[i]..'Group']:SetActive(currentTabIndex == 2)
		end

		if currentTabIndex == 1 then
            self.RefreshRecent()
			self.OpenSubView('',ViewAssets.ContractSelectNoteUI,"选择左侧好友进行聊天")
		elseif currentTabIndex == 2 then
			self.ContractGroupClick(1)
		end

	end
    
    local RefreshContractList = function()
        contractDataList = {}
        for _,v in pairs(ContactManager.GetContactList(contractGroup)) do
            table.insert(contractDataList,v)
        end
        self.view.contractScrollView:GetComponent('UIMultiScroller'):UpdateData(#contractDataList,BindData)   
    end
    
	self.ContractGroupClick = function(index)
		contractGroup = group[index]
        selectContractID = -1
        for i=1,3 do
			if group[i] ~= contractGroup then
				self.AddClick(self.view[group[i]..'Bg'],function() self.ContractGroupClick(i) end)
            else
                self.AddClick(self.view[group[i]..'Bg'],nil)
			end
		end
        
		local parentSib = self.view[contractGroup..'Group'].transform:GetSiblingIndex()
		local currentSib = self.view.contractScrollView.transform:GetSiblingIndex()
		if parentSib < currentSib then
			parentSib = parentSib + 1
		end
		self.view.contractScrollView.transform:SetSiblingIndex(parentSib)
        RefreshContractList()
        self.OpenSubView('',ViewAssets.ContractSelectNoteUI,"选择左侧好友进行聊天")
	end
    
    self.GroupUpdate = function(i)
        if not self.isLoaded then return end
        if contractGroup == group[i] and currentTabIndex == 2 then
            contractDataList = {}
            local index = 0
            for _,v in pairs(ContactManager.GetContactList(contractGroup)) do
                table.insert(contractDataList,v)
                if v.actor_id == selectContractID then
                    index = #contractDataList
                end
            end
            if 0 == index then
                selectContractID = -1
                self.OpenSubView('',ViewAssets.ContractSelectNoteUI,"选择左侧好友进行聊天")
                self.view.contractScrollView:GetComponent('UIMultiScroller'):UpdateData(#contractDataList,BindData) 
            else
                self.SelectContract(index)
            end
        end
    end
	
	self.SelectContract = function(key)
        local data = ContactManager.InList('friends',contractDataList[key].actor_id) or contractDataList[key]
        selectContractID = data.actor_id
        if data.actor_id == '-1' then
            self.OpenSubView('系统消息',ViewAssets.SystemMsgUI)
        else
            self.OpenSubView(data.actor_name,ViewAssets.PlayerTalkUI,data)
        end
        if currentTabIndex == 1 then
            self.RefreshRecent()
		elseif currentTabIndex == 2 then
            RefreshContractList()
		end
	end
    
    self.SendPrivateMsg = function(data)
        if MyHeroManager.heroData.actor_id == data.actor_id then
            return
        end
        ChatManager.AddRecent(data.actor_id)
        ChatManager.AddActorInfo(data)
        currentTabIndex = 1
        selectContractID = data.actor_id
        self.OpenSubView(data.actor_name,ViewAssets.PlayerTalkUI,data)
        self.RefreshRecent()
	end
	
    self.OpenApplyPage = function()
        if table.isEmptyOrNil(ContactManager.GetContactList('applicants')) then
            self.OpenSubView('好友申请',ViewAssets.ContractSelectNoteUI,"还没有任何好友申请哦，多去公会和世界频道聊聊天吧。")
        else               
            self.OpenSubView('好友申请',ViewAssets.FriendsApproveUI)
        end
    end
    
	return self
end

return CreateFriendsUICtrl()