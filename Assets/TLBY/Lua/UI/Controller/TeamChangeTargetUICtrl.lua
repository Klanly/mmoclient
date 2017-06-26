---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamChangeTargetUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
    local tabs = {}
    local subBtns = {}
    local config = {}
    local currentTarget = 'free'
    local currentMinLevel = 1
    local max_level = GetConfig('challenge_team_dungeon').Parameter[6].Value[1]
    local currentMaxLevel = max_level
    local currentTab = 0
    local configTable = GetConfig('challenge_team_dungeon').Object
    local teamDungeons = GetConfig('challenge_team_dungeon').TeamDungeons
    
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
        if teamDungeons[id] == nil then
            currentTarget = 'free'
        else
            currentTarget = id
            local levelLeft = self.view.levelLeftScrollView:GetComponent('UIMultiScroller')
            levelLeft:SetPageIndex(teamDungeons[currentTarget].Level - 1)
            if currentMaxLevel < teamDungeons[currentTarget].Level then
                local levelRight = self.view.levelRightScrollView:GetComponent('UIMultiScroller')
                levelRight:SetPageIndex(teamDungeons[currentTarget].Level - 1)
            end
        end
    end
    
    local RefreshSubBtns = function()
        ClearSubBtns()
        for i=1,#config[currentTab] do
            local clone = GameObject.Instantiate(self.view.subBtn)
            clone:SetActive(true)
            table.insert(subBtns,clone)
            clone.transform:SetParent(self.view.subBtns.transform, false)
            clone.transform:FindChild('text'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(teamDungeons[config[currentTab][i].Parameter],'Name')
            clone:GetComponent('Toggle').isOn = config[currentTab][i].Parameter == currentTarget
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
        
    local UpdateMinLevelItem = function(item,index)
        item.transform:FindChild('des'):GetComponent('TextMeshProUGUI').text = index + 1
    end
    
    local UpdateMaxLevelItem = function(item,index)
        item.transform:FindChild('des'):GetComponent('TextMeshProUGUI').text = index + 1
    end
    
    local MinLevelChange = function(index)
        currentMinLevel = index + 1
    end
    
    local MaxLevelChange = function(index)
        currentMaxLevel = index + 1
    end
    
    self.SetTarget = function()
        if not TeamManager.InTeam() then self.close() return end
        if not TeamManager.IsCaptain() then UIManager.ShowNotice('只有队长才有此权限') return end
        
        self.close()
        local teamInfo = TeamManager.GetTeamInfo()
        
        if currentMaxLevel < currentMinLevel then
            UIManager.ShowNotice('队伍等级下限不能高于等级上限')
            return
        end
        if teamDungeons[currentTarget] then
            for _,v in pairs(teamInfo.members) do
                if v.level < teamDungeons[currentTarget].Level then
                    UIManager.ShowNotice(string.format('挑战改副本需求最低等级为%d,队伍成员%s的等级不满足条件',teamDungeons[currentTarget].Level,v.actor_name))
                    return
                end
            end

            if currentMaxLevel < teamDungeons[currentTarget].Level then
                UIManager.ShowNotice(string.format('挑战改副本需求最低等级为%d,队伍加入限制的最大等级为%d',teamDungeons[currentTarget].Level))
                return
            end
        end

        if currentTarget ~= teamInfo.target then
            local data = {}
            data.func_name = 'on_set_target'
            if currentTarget == 0 then
                data.target = 'free'
            else
                data.target = currentTarget
            end
            if currentMinLevel ~= teamInfo.min_level or currentMaxLevel ~= teamInfo.max_level then
            --local data = {}
            --data.func_name = 'on_set_team_level'
                data.min_level = currentMinLevel
                data.max_level = currentMaxLevel
            --MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
            end
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        elseif currentMinLevel ~= teamInfo.min_level or currentMaxLevel ~= teamInfo.max_level then
            local data = {}
            data.func_name = 'on_set_team_level'
            data.min_level = currentMinLevel
            data.max_level = currentMaxLevel
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)    
        end

    end
    
    self.TabClick = function(class)
        -- if currentTab ~= class and #config[class] == 1 then
            -- QuestTeamList(config[class][1].Parameter)
        -- end
        currentTab = class
        if config[currentTab] then
            local item = tabs[class]
            if #config[currentTab] > 1 then           
                self.view.subBtns:SetActive(not self.view.subBtns.activeSelf)
                if self.view.subBtns.activeSelf then
                    RefreshSubBtns()
                end
            else
                self.view.subBtns:SetActive(false)
                currentTarget = config[currentTab][1].Parameter
            end
            --item.transform:FindChild('arrowUp').gameObject:SetActive(not self.view.subBtns.activeSelf and #config[currentTab] > 1)
            --item.transform:FindChild('arrowDown').gameObject:SetActive(self.view.subBtns.activeSelf and #config[currentTab] > 1)
        end
        RefreshTabScrollView()
    end
    
    self.SubBtnClick = function(data)
        QuestTeamList(data.Parameter)
    end
    
    self.onLoad = function()
        self.view.tab:SetActive(false)
        self.view.subBtn:SetActive(false)
        self.view.subBtns:SetActive(false)
        
        if not TeamManager.InTeam() then self.close() return end
        local teamInfo = TeamManager.GetTeamInfo()
        ClearTabs()
        config = {}
        currentTab = 0
        currentTarget = teamInfo.target
        self.view.subBtns:SetActive(false)
        
        for i=1,#configTable do
            local id = configTable[i].Class
            if config[id] == nil then config[id] = {} end
            table.insert(config[id],configTable[i])
            if configTable[i].Parameter == currentTarget then currentTab = id end
        end

        for k,v in pairs(config) do
            local clone = GameObject.Instantiate(self.view.tab)
            clone:SetActive(true)
            tabs[k] = clone
            clone.transform:SetParent(self.view.tabList.transform, false)
            clone:GetComponent('Toggle').isOn = currentTab == k
            --clone.transform:FindChild('arrowUp').gameObject:SetActive(#config[k]>1)
            --clone.transform:FindChild('arrowDown').gameObject:SetActive(false)
            clone.transform:FindChild('tabText'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(v[1],'Name')
            self.AddClick(clone, function() self.TabClick(k) end)
        end

        local levelLeft = self.view.levelLeftScrollView:GetComponent('UIMultiScroller')
        local levelRight = self.view.levelRightScrollView:GetComponent('UIMultiScroller')
        levelLeft:Init(self.view.levelItem,100,65,0,10,1)
        levelRight:Init(self.view.levelItem,100,65,0,10,1)
        currentMinLevel = teamInfo.min_level
        currentMaxLevel = teamInfo.max_level
        levelLeft:UpdateData(max_level ,UpdateMinLevelItem)
        levelRight:UpdateData(max_level ,UpdateMaxLevelItem)
        levelLeft.onPageChange = MinLevelChange
        levelRight.onPageChange = MaxLevelChange
        levelLeft:SetPageIndex(teamInfo.min_level - 1)
        levelRight:SetPageIndex(teamInfo.max_level - 1)
        
        self.view.levelItem:SetActive(false)
        self.TabClick(currentTab)
        self.AddClick(self.view.btnClose, self.close)
        self.AddClick(self.view.btnDetermine, self.SetTarget)
    end
	
	self.onUnload = function()
        ClearTabs()
        ClearSubBtns()
	end
    
	return self
end

return CreateTeamChangeTargetUICtrl()