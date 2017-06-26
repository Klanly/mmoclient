---------------------------------------------------
-- auth： songhua
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreateTeamDungeonUICtrl()
    local self = CreateCtrlBase()
    
    self.resourceBar = {1003}
    
    local teamDungeons = (require'Logic/Scheme/challenge_team_dungeon').TeamDungeons
    local dungeonCost = (require'Logic/Scheme/challenge_team_dungeon').Cost
    local dropListData = {}
    local currentClass = 1
    local selectDiff = 1
    local config = {}
    local bestInfo = {}
    local leftTimeInfo = {}
    local requestId

    local ReuqestRankListUI = function(id)
        requestId = id
        local data = {}
        data.dungeon_id = id
        data.dungeon_type = "team_dungeon"        
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_DUNGEON_HEGEMON,data)
    end
    
    local ShowRankListUI = function(data)
        if data.result == 0 then
            UIManager.PushView(ViewAssets.TeamRankListUI,nil,requestId,data.dungeon_hegemon)
        end
    end
    
    local BindDungeonData = function(item,index)
        local data = config[index + 1][1]
        item.transform:Find('select').gameObject:SetActive(currentClass == index + 1)
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.ChapterName
        local level = MyHeroManager.heroData.level
        local bg = item.transform:Find('bg').gameObject
        if data.Level > level then
            item.transform:Find('levelLimit'):GetComponent('TextMeshProUGUI').text = data.Level..'级解锁'
            bg:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
        else
            item.transform:Find('levelLimit'):GetComponent('TextMeshProUGUI').text = ''
            bg:GetComponent('Image').material = nil
        end
        self.AddClick(bg,function() self.SelectDungeon(index + 1) end)
    end
    
    local BindDiffData = function(item,index)
        local data = config[currentClass][index+1]
        local scale = Vector3.one
        if selectDiff == index + 1 then scale = Vector3.New(1.2,1.3,1) end
        item.transform:Find('bg').localScale = scale
        local level = MyHeroManager.heroData.level
        local bg = item.transform:Find('bg').gameObject
        if data.Level > level then 
            item.transform:Find('text'):GetComponent('TextMeshProUGUI').text = data.Level..'级解锁'
            bg:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
        else
            item.transform:Find('text'):GetComponent('TextMeshProUGUI').text = data.DifName
            bg:GetComponent('Image').material = nil
        end
        self.AddClick(bg,function() self.SelectDiff(index + 1) end)
    end
    
    local BindDropItem = function(item,index)
        local data = dropListData[index + 1]
        item.transform:Find('icon'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(data.id)
        --item.transform:Find('itemName'):GetComponent('TextMeshProUGUI').text = data.des
        item.transform:Find('quality'):GetComponent('Image').overrideSprite = LuaUIUtil.GetItemQuality(data.id)
        ClickEventListener.Get(item.transform:Find('icon').gameObject).onClick = function()
            BagManager.ShowItemTips({item_data={id=data.id}},true)
        end
    end
    
    self.SelectDungeon = function(class)
        currentClass = class
        self.view.dungeonList:GetComponent('UIMultiScroller'):UpdateData(#config,BindDungeonData)
        local target = -1
        if TeamManager.InTeam() then
            target = TeamManager.GetTeamInfo().target
        end
        local level = MyHeroManager.heroData.level
        for i=1,#config[currentClass] do
            if target == config[currentClass][i].ID then
                selectDiff = i
                break
            end
            if config[currentClass][i].Level <= level then
                selectDiff = i
            end
        end
        self.view.diffList:GetComponent('ScrollRect').content:GetComponent('RectTransform').anchoredPosition = Vector2.New(-180*(selectDiff-2),0)
        self.SelectDiff(selectDiff)
    end
    
    self.SelectDiff = function(diff)
        selectDiff = diff
        self.view.diffList:GetComponent('UIMultiScroller'):UpdateData(#(config[currentClass]),BindDiffData)

        local data = config[currentClass][selectDiff]
        self.AddClick(self.view.btnEnter,function() TeamManager.EnterDungeonRequest(data.ID) end)

        self.view.dungonDes:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(data,'ChapterDes')
        dropListData = {}
        local i = 1
        while(data['Reward'..i] ~= nil and #data['Reward'..i] == 2) do
            table.insert(dropListData,{des='必掉',id = data['Reward'..i][1]})
            i = i + 1
        end
        i = 1
        while(data['ProDrop'..i] ~= nil and #data['ProDrop'..i] == 1) do
            table.insert(dropListData,{des='概率',id = data['ProDrop'..i][1]})
            i = i + 1
        end
        self.view.dropItemList:GetComponent('UIMultiScroller'):UpdateData(#dropListData, BindDropItem)
        

        local configTable = config[currentClass][selectDiff]
        local data = bestInfo[configTable.ID]
        local leftTime = leftTimeInfo[configTable.Chapter] or 0
        local exsit = data and data.captain and true
        self.view.bestPlayer:GetComponent('TextMeshProUGUI').text = (exsit and data.captain.actor_name ) or '暂无'
        self.view.leftTime:GetComponent('TextMeshProUGUI').text = string.format('次数：%d/%d',leftTime,dungeonCost[configTable.Chapter].Num)

        self.view.icon:SetActive(exsit)
        if exsit then
            self.view.icon:GetComponent('Image').sprite = LuaUIUtil.GetHeroIcon(data.captain.vocation,data.captain.sex)
            self.AddClick(self.view.icon,function() ReuqestRankListUI(configTable.ID) end)
            self.AddClick(self.view.bestPlayer,function() ReuqestRankListUI(configTable.ID) end)
        else
            self.AddClick(self.view.icon,function() UIManager.ShowNotice('暂无霸主') end)
            self.AddClick(self.view.bestPlayer,function() UIManager.ShowNotice('暂无霸主') end)
        end
    end
    
    self.OpenUI = function()
        local data = {}
        data.dungeon_type = "team_dungeon"
        data.chapter_ids =  {"team_dungeon"}
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_DUNGEON_HEGEMON,data)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, self.ShowUI)
        local data = {}
        data.func_name = "on_get_team_dungeon_info"
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GAME_RPC, data) 
        MessageRPCManager.AddUser(self, 'GetTeamDungeonInfoRet')
    end
    
    self.ShowUI = function(data)
        bestInfo = data.name_table
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, self.ShowUI)
    end
    
    self.GetTeamDungeonInfoRet = function(data)
        leftTimeInfo = data.team_dungeon_times
        if self.isLoaded then
        else
            UIManager.PushView(ViewAssets.TeamDungeonUI)
        end
    end

    self.onLoad = function()
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.btnTeam,self.FindTeamClick)
        self.AddClick(self.view.btnTeamMember,self.TeamUIClick)
        
        self.view.dropItem:SetActive(false)
        self.view.diffItem:SetActive(false)
        self.view.dungeonTypeItem:SetActive(false)

        
        config = {}
        for _,v in pairs(teamDungeons) do
            if config[v.Chapter] == nil then config[v.Chapter] = {} end
            table.insert(config[v.Chapter],v)
        end
        table.sort(config,function(a,b) return a[1].Chapter < b[1].Chapter end)
        local level = MyHeroManager.heroData.level
        local target = -1
        if TeamManager.InTeam() then
            target = TeamManager.GetTeamInfo().target
        end
        currentClass = 1
        local cacheLevel = 0
        for i=1,#config do
            table.sort(config[i],function(a,b) return a.ID < b.ID end)        
            for j=1,#config[i] do
                if target == config[i][j].ID then
                    currentClass = i
                    cacheLevel = 1000
                end
                if config[i][j].Level <=level and cacheLevel < config[i][j].Level then
                    currentClass = i
                    cacheLevel = config[i][j].Level
                end
            end
        end

        self.view.dungeonList:GetComponent('UIMultiScroller'):Init(self.view.dungeonTypeItem,170,170,0,5,1)
        self.view.diffList:GetComponent('UIMultiScroller'):Init(self.view.diffItem,180,180,0,5,1)
        self.view.dropItemList:GetComponent('UIMultiScroller'):Init(self.view.dropItem,150,150,0,9,1)

        --self.view.dungeonList:GetComponent('UIMultiScroller'):UpdateData(#config,BindDungeonData)
        self.view.dungeonList:GetComponent('ScrollRect').content:GetComponent('RectTransform').anchoredPosition = Vector2.New(0,170*(currentClass-2))
        
        self.view.btnTeam:SetActive(not TeamManager.InTeam())
        self.view.btnTeamMember:SetActive(TeamManager.InTeam())
        self.SelectDungeon(currentClass)
        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON , ShowRankListUI)
    end
	
	self.onUnload = function()
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, ShowRankListUI)
	end
    
    self.FindTeamClick = function()
        UIManager.PushView(ViewAssets.TeamApplyUI,nil,config[currentClass][selectDiff].ID)
    end
    self.TeamUIClick = function()
        UIManager.PushView(ViewAssets.TeamUI)
    end
    
	return self
end

return CreateTeamDungeonUICtrl()