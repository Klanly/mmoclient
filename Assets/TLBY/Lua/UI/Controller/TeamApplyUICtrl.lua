---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamApplyUICtrl()
    local self = CreateCtrlBase()
    
    local tabs = {}
    local subBtns = {}
    local config = {}
    local applyTeamIDs = {}
    local currentTarget = 'free'
    local teamListData = {}
    local currentTab = 0
    local configTable = (require'Logic/Scheme/challenge_team_dungeon').Object
    local teamDungeons = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    
    local ClearTabs = function()
        for i=#tabs,1,-1 do
            GameObject.Destroy(tabs[i])
            table.remove(tabs,i)
        end
    end
    
    local ClearSubBtns = function()
        for i=#subBtns,1,-1 do
            GameObject.Destroy(subBtns[i])
            table.remove(subBtns,i)
        end
    end
    
    local QuestTeamList = function(id)
        local data = {}
        if teamDungeons[id] == nil then
            currentTarget = 'free'
        else
            currentTarget = id
        end
        data.target = currentTarget
        data.func_name = 'on_get_team_list'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    local RefreshSubBtns = function()
        ClearSubBtns()
        for i=1,#config[currentTab] do
            local clone = GameObject.Instantiate(self.view.subBtn)
            clone:SetActive(true)
            table.insert(subBtns,clone)
            clone.transform:SetParent(self.view.subBtns.transform, false)
            clone.transform:FindChild('text'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(teamDungeons[config[currentTab][i].Parameter],'Name')
            clone:GetComponent('Toggle').isOn = currentTarget == config[currentTab][i].Parameter
            self.AddClick(clone, function() self.SubBtnClick(config[currentTab][i]) end)
        end
        self.view.subBtns.transform:SetSiblingIndex(#tabs + 1)
        self.view.subBtns.transform:SetSiblingIndex(currentTab + 1)
        local layoutElement = self.view.subBtns:GetComponent('LayoutElement')
        layoutElement.preferredHeight = self.view.subBtn:GetComponent('LayoutElement').preferredHeight * #config[currentTab] + 26
    end
    
    local RefreshTabScrollView = function()
        local hight = #tabs * self.view.tab:GetComponent('LayoutElement').preferredHeight
        if self.view.subBtns.activeSelf then
            hight = hight + self.view.subBtns:GetComponent('LayoutElement').preferredHeight
        end
        self.view.tabList:GetComponent('RectTransform').sizeDelta = Vector2.New(0,hight)
    end
    
    local UpdateTeamItem = function(item,index)
        item.transform:FindChild('bgWhite').gameObject:SetActive(index%2 == 1)
        item.transform:FindChild('bgYellow').gameObject:SetActive(index%2 == 0)
        local data = teamListData[index + 1]
        item.transform:FindChild('process'):GetComponent('Image').fillAmount = data.member_num / 4
        item.transform:FindChild('level'):GetComponent('TextMeshProUGUI').text = data.captain_info.level
        item.transform:FindChild('icon'):GetComponent('Image').sprite = LuaUIUtil.GetHeroIcon(data.captain_info.vocation,data.captain_info.sex)
        item.transform:FindChild('memberCount'):GetComponent('TextMeshProUGUI').text = data.member_num.."/4"
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text =  data.captain_info.actor_name
        item.transform:FindChild('target'):GetComponent('TextMeshProUGUI').text = TeamManager.GetTargetName(data.target)
        local btnApply = item.transform:FindChild('btnApply').gameObject
        
        local HasApply = function()
            self.AddClick(btnApply,nil)
            item.transform:FindChild('btnApply').gameObject:SetActive(false)
            item.transform:FindChild('hasApply').gameObject:SetActive(true)
        end

        if applyTeamIDs[data.team_id] then
            HasApply()
        else
            self.AddClick(btnApply,function() HasApply() self.JoinTeam(data.team_id) end)
            item.transform:FindChild('btnApply').gameObject:SetActive(true)
            item.transform:FindChild('hasApply').gameObject:SetActive(false)
        end
        
    end
    
    self.JoinTeam = function(id)
        if TeamManager.InTeam() then UIManager.ShowNotice('您已有队伍，无法申请') return end
        local data = {}
        data.func_name = 'on_apply_team'
        data.apply_team_id = id
        applyTeamIDs[id] = true
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.GetTeamListRet = function(data)
        teamListData = data.team_list
        for i = #teamListData,1,-1 do
            if teamListData[i].min_level > MyHeroManager.heroData.level and teamListData[i].max_level < MyHeroManager.heroData.level then
                table.remove(teamListData,i)
            end
        end
        table.sort(teamListData,function(a,b) 
                if a.target == b.target then return false end
                if a.target == 'free' then return true end
                if b.target == 'free' then return false end
            end)
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#teamListData, UpdateTeamItem)
        self.view.noTeam:SetActive(#teamListData == 0)
    end
    
    self.TabClick = function(index)
        if currentTab ~= index and #config[index] == 1 then
            QuestTeamList(config[index][1].Parameter)
        end
        currentTab = index
        if #config[currentTab] > 1 then           
            self.view.subBtns:SetActive(not self.view.subBtns.activeSelf)
            if self.view.subBtns.activeSelf then
                RefreshSubBtns()
            end
        else
            self.view.subBtns:SetActive(false)
        end
        RefreshTabScrollView()
    end
    
    self.SubBtnClick = function(data)
        QuestTeamList(data.Parameter)
    end
    
    self.onLoad = function(target)
        ClearTabs()
        config = {}
        currentTab = 1
        currentTarget = target
        self.view.subBtns:SetActive(false)
        self.view.subBtn:SetActive(false)
        self.view.tab:SetActive(false)
        applyTeamIDs = {}
        for i=1,#configTable do
            local id = configTable[i].Class
            if config[id] == nil then config[id] = {} end
            table.insert(config[id],configTable[i])
            if configTable[i].Parameter == target then currentTab = id end
        end
        
        for k,v in pairs(config) do
            local clone = GameObject.Instantiate(self.view.tab)
            clone:SetActive(true)
            table.insert(tabs,clone)
            clone.transform:SetParent(self.view.tabList.transform, false)
            clone:GetComponent('Toggle').isOn = currentTab == k
            clone.transform:FindChild('tabText'):GetComponent('TextMeshProUGUI').text = v[1].Name1
            clone.transform:FindChild('arrow').gameObject:SetActive(#v > 1)
            self.AddClick(clone, function() self.TabClick(k) end)
        end
        
        self.TabClick(currentTab)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.teamItem,1386,160,0,7,1)
        self.view.teamItem:SetActive(false)
        QuestTeamList(target or 0)
        self.AddClick(self.view.btnCreate, self.CreateTeam)
        self.AddClick(self.view.btnClose, self.close)
        self.AddClick(self.view.btnAutoApply, self.AutoApply)
        MessageRPCManager.AddUser(self, 'GetTeamListRet')
    end
    
    self.AutoApply = function()
        for i=1,#teamListData do
            self.JoinTeam(teamListData[i].team_id)
        end
        -- local data = {}
        -- data.func_name = 'on_auto_apply_team'
        -- data.target = currentTarget
        -- MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.CreateTeam = function()
        local data = {}
        data.func_name = 'on_make_team'
        if teamDungeons[currentTarget] == nil then
             data.target = 'free'
        else
            data.target = currentTarget
        end
        data.auto_join = true
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
	
	self.onUnload = function()
        ClearTabs()
        ClearSubBtns()
        MessageRPCManager.RemoveUser(self, 'GetTeamListRet')
	end
    
	return self
end

return CreateTeamApplyUICtrl()