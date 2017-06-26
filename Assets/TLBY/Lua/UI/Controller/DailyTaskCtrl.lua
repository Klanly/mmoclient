---------------------------------------------------
-- auth： 
-- date： 2017/01/23
-- desc： 匹配中
---------------------------------------------------
local config = GetConfig('activity_daily')
local scene_config = GetConfig('common_scene')
local const = require "Common/constant"

local function GetWDay()
    local tab = os.date("*t", time)
    local wday = tab.wday - 1
    if wday == 0 then
        wday = 7
    end
    return wday
end

local function IsTimeAvaible(time_str)
    if time_str == '0' or time_str =='' then
        return true
    end
    local tab = os.date("*t", time)
    local now_time = tab.hour * 60 + tab.min
    local start_time = 0
    local end_time = 1440
    for a, b, c, d in string.gmatch(time_str, '(%d+):(%d+)-(%d+):(%d+)') do
        start_time = tonumber(a) * 60 + tonumber(b)
        end_time = tonumber(c) * 60 + tonumber(d)
    end
    if now_time > start_time and now_time < end_time then
        return true
    else
        return false
    end
end

local wday = GetWDay()

local function GetMonsterSetting(boss)
    local scene_sheme, chapter_name = nil
    if boss.ScenceType == const.SCENE_TYPE.WILD or boss.ScenceType == const.SCENE_TYPE.CITY then
        scene_sheme = GetConfig('common_scene')
        chapter_name = scene_sheme.MainScene[boss.ScenceID].SceneSetting
    elseif boss.ScenceType == const.SCENE_TYPE.ARENA then
        scene_sheme = GetConfig('challenge_arena')
        chapter_name = scene_sheme.ArenaScene[boss.ScenceID].SceneSetting
    elseif boss.ScenceType == const.SCENE_TYPE.DUNGEON then
        scene_sheme = GetConfig('challenge_main_dungeon')
        chapter_name = scene_sheme.NormalTranscript[boss.ScenceID].SceneSetting
    elseif boss.ScenceType == const.SCENE_TYPE.TEAM_DUNGEON then
        scene_sheme = GetConfig('challenge_team_dungeon')
        chapter_name = scene_sheme.TeamDungeons[boss.ScenceID].SceneSetting
    end
    if scene_sheme then
        return scene_sheme[chapter_name][boss.ElementID]
    end
end

local function LoadHuntData()
    local data = { {}, {}}
    local tmp = config.Hunting
    for _, one_boss in pairs(tmp) do
        local unit = GetMonsterSetting(one_boss)
        if unit then
            local MonsterID = unit.MonsterID
            one_boss.monster_type = scene_config.MonsterSetting[MonsterID].Type
            one_boss.level = scene_config.MonsterSetting[MonsterID].Level
            one_boss.name = unit.Name1
            if one_boss.monster_type == const.MONSTER_TYPE.WORLD_BOSS then
                table.insert(data[1], one_boss)
            elseif one_boss.monster_type == const.MONSTER_TYPE.WILD_ELITE_BOSS then
                table.insert(data[2], one_boss)
            end
        end
    end
    return data
end

local function CreateHuntDetailItemUI(template, data)
    local self = CreateScrollviewItem(template)
    
    self.transform:FindChild('iconWhitering'):GetComponent('Image').overrideSprite = 
        LuaUIUtil.GetItemIcon(data)
    self.transform:FindChild('com_frame_blue'):GetComponent('Image').overrideSprite = 
        LuaUIUtil.GetItemQuality(data)
    ClickEventListener.Get(self.transform:FindChild('iconWhitering').gameObject).onClick = function()
		BagManager.ShowItemTips({item_data={id=data}},true)
	end
    return self
end

local function clearHuntDetailItem(self)
    for k, v in ipairs(self.hunt_detail_items) do           
        DestroyScrollviewItem(v)
    end
    self.hunt_detail_items = {}
end

local function ShowHuntDetail(self, index)
    local data = self.hunt_data[self.page_no][index+1]
    clearHuntDetailItem(self)

    self.view.template_hunt_detail_item:SetActive(false)
    if data ~= nil then 
        self.view.txt_task_name:GetComponent('TextMeshProUGUI').text = data.name
        self.view.text_descrip:GetComponent('TextMeshProUGUI').text = data.Details
        self.view.text_descrip2:GetComponent('TextMeshProUGUI').text = data.Feature
        for _,v in pairs(data.iconID) do
            local tmp = CreateHuntDetailItemUI(self.view.template_hunt_detail_item, v)
            table.insert(self.hunt_detail_items, tmp)
        end
    end

end

local function LoadHuntPage(self, page_no)
    --[[if self.page_no ~= nil and self.page_no == page_no then
        return 
    end]]
    self.page_no = page_no
    self.selected_index = 0
    --print('LoadHuntPage:', page_no, ' num', #self.hunt_data[page_no])
    self.view.contractScrollView:GetComponent('UIMultiScroller'):UpdateData(#self.hunt_data[page_no], self.onHuntItemUpdate)
    
end

local function InitHuntPage(self)   
    self.view.contractScrollView:GetComponent('UIMultiScroller'):Init(self.view.template_hunt, 1000, 190, 0, 5, 1)
    self.view.template_hunt:SetActive(false)
    LoadHuntPage(self, 1)
end

local function IsDateAvaible(data)
    if data.Date[1] == -1 then
        return true
    else
        local in_flag = false
        for _,v in pairs(data.Date) do
            if v == wday then
                in_flag = true
            end
        end
        return in_flag
    end
end

local function IsActivityJoinable(data)
    if data.TimesLower > MyHeroManager.heroData.level then
        return false, 1
    else
        if not IsDateAvaible(data) then
            return false, 2
        else
            if (not IsTimeAvaible(data.DateInterval1)) or (not IsTimeAvaible(data.DateInterval1)) then
                return false, 3
            else
                if data.ActiveNum ~= 0 then
                    local count = data.excute_count or 0
                    if count >= data.ActiveNum then
                        return false, 4
                    end
                end
                return true
            end
        end
    end
end

local function CreateActivityItemUI(template, data)
    local self = CreateScrollviewItem(template)
    self.transform:FindChild('text_task_name'):GetComponent('TextMeshProUGUI').text = data.Name
    local count = data.excute_count or 0
    if data.ActiveNum == 0 then
        self.transform:FindChild('text_task_time'):GetComponent('TextMeshProUGUI').text = '产出: '..data.Main
        self.transform:FindChild('text_task_huoyue').gameObject:SetActive(false)
    else
        self.transform:FindChild('text_task_time'):GetComponent('TextMeshProUGUI').text = 
            '次数 '..count..'/'..data.ActiveNum
        if count >= data.ActiveNum then
            self.transform:FindChild('bgcomplete').gameObject:SetActive(true)
        else
            self.transform:FindChild('bgcomplete').gameObject:SetActive(false)
        end
        self.transform:FindChild('text_task_huoyue').gameObject:SetActive(true)
        self.transform:FindChild('text_task_huoyue'):GetComponent('TextMeshProUGUI').text = '产出: '..data.Main
    end
    


    --[[if data.ActiveNum ~= -1 then
        self.transform:FindChild('text_task_huoyue'):GetComponent('TextMeshProUGUI').text = 
            '活跃度 '..(count*data.ActiveReward)..'/'..(data.ActiveNum*data.ActiveReward)
    else
        self.transform:FindChild('text_task_huoyue').gameObject:SetActive(false)
    end]]

    
    local res, code = IsActivityJoinable(data)
    if res then
        self.transform:FindChild('btn_join').gameObject:SetActive(true)
        self.transform:FindChild('bgblacktimebox').gameObject:SetActive(false)
        self.transform:FindChild('cover_image').gameObject:SetActive(false)
    else
        self.transform:FindChild('btn_join').gameObject:SetActive(false)
        if code == 4 then
            self.transform:FindChild('bgblacktimebox').gameObject:SetActive(false)
        else
            self.transform:FindChild('bgblacktimebox').gameObject:SetActive(true)
        end
        self.transform:FindChild('cover_image').gameObject:SetActive(true)
        if code == 3 then
            self.transform:FindChild('bgblacktimebox'):FindChild('text_join_time'):GetComponent('TextMeshProUGUI').text = data.DateInterval1
        elseif code == 2 then
            self.transform:FindChild('bgblacktimebox'):FindChild('text_join_time'):GetComponent('TextMeshProUGUI').text = '非本日开启'
        else
            self.transform:FindChild('bgblacktimebox'):FindChild('text_join_time'):GetComponent('TextMeshProUGUI').text 
                = data.TimesLower..'级开启'
        end


    end

    if data.ActivityType == 2 then
        self.transform:FindChild('bg_type_week').gameObject:SetActive(true)
    end

    if data.ActivityType == 3 then
        self.transform:FindChild('bg_type_timelimit').gameObject:SetActive(true)
    end

    if data.ActivityType == 4 then
        self.transform:FindChild('btn_join').gameObject:SetActive(false)
        self.transform:FindChild('bgblacktimebox').gameObject:SetActive(false)
    end

    ClickEventListener.Get(self.transform:FindChild('bgstripes1').gameObject).onClick = function()
        UIManager.PushView(ViewAssets.DailyTaskTip1,nil, data)
    end

    UIUtil.AddButtonEffect(self.transform:FindChild('btn_join').gameObject, nil, nil)
    ClickEventListener.Get(self.transform:FindChild('btn_join').gameObject).onClick = function()
        if data.OperationType == 1 then
            UIManager.GetCtrl(ViewAssets.DailyTask).close()
            UIManager.PushView(ViewAssets.ArenaSelect)
        elseif data.OperationType == 2 then
            local oper_code = data['OperationParameter'.. MyHeroManager.heroData.country]

            if oper_code ~= '0' and oper_code ~= '' then
                local tmp = string.split(oper_code,'|')
                if tmp[1] and tmp[2] and tmp[3] then
                    UIManager.GetCtrl(ViewAssets.DailyTask).close()
                    SceneManager.GetEntityManager().hero:moveToUnit(tonumber(tmp[3]),tonumber(tmp[2]),tonumber(tmp[1]), 1, 
                        function(npc)
                            npc.behavior:InterAct()
                        end)
                end
            end
        elseif data.OperationType == 3 then
            local control = UIManager.GetCtrl(ViewAssets.DailyTask)
            control.view.DailyPart:SetActive(false)
            control.view.HuntPart:SetActive(true) 
            UIManager.UnloadView(ViewAssets.WelfareUI)
            LoadHuntPage(control, 2)
            control.view.btn_boss:GetComponent('Toggle').isOn = true
        end
    end
    
    
    return self
end

local function LoadStaticActivityData()
    local tmp = config.Activity
    local data = {}
    for _,v in pairs(tmp) do
        table.insert(data, v)
    end
    return data
end

local function InitStaticButton(control)
	ClickEventListener.Get(control.view.btndaily).onClick = function()
    	control.view.DailyPart:SetActive(true)
    	control.view.HuntPart:SetActive(false)
        UIManager.UnloadView(ViewAssets.WelfareUI)        
    end

	ClickEventListener.Get(control.view.btnhunting).onClick = function()
    	control.view.DailyPart:SetActive(false)
    	control.view.HuntPart:SetActive(true) 
        UIManager.UnloadView(ViewAssets.WelfareUI)
    end
    
    ClickEventListener.Get(control.view.btnWelfare).onClick = function()
    	control.view.DailyPart:SetActive(false)
    	control.view.HuntPart:SetActive(false) 
        UIManager.PushView(ViewAssets.WelfareUI)
    end

    UIUtil.AddButtonEffect(control.view.btn_canledar, nil, nil)
    ClickEventListener.Get(control.view.btn_canledar).onClick = function()
    	UIManager.PushView(ViewAssets.DailyTaskCan)
    end

    UIUtil.AddButtonEffect(control.view.btnClose, nil, nil)
    ClickEventListener.Get(control.view.btnClose).onClick = function()
    	control.close()
    end

    ClickEventListener.Get(control.view.btn_world_boss).onClick = function()
        LoadHuntPage(control, 1)
    end

    ClickEventListener.Get(control.view.btn_boss).onClick = function()
        LoadHuntPage(control, 2)
    end
    
    for i,v in ipairs(config.Liveness) do
        ClickEventListener.Get(control.view['icontreasurechest'..i]).onClick = function()
            UIManager.PushView(ViewAssets.DailyTaskTip2,nil, {i, control.activity_info})
        end
        control.view['textten'..i]:GetComponent('TextMeshProUGUI').text = v.ConsumeLiveness
    end
end

local function refreshBoxes(self)
    if self.view == nil then
        return 
    end
    for i,v in ipairs(config.Liveness) do
        if self.activity_info.liveness_current >= v.ConsumeLiveness and 
            self.activity_info.liveness_history >= v.NeedLiveness then
            self.view['icontreasurechest'..i]:GetComponent('Image').material = nil
        else
            self.view['icontreasurechest'..i]:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
        end
    end

    self.view.textactivenumber:GetComponent('TextMeshProUGUI').text = 
        self.activity_info.liveness_current ..'/'.. self.activity_info.liveness_history

    for i,v in pairs(self.activity_info.activity_counts) do
        for _,act in pairs(self.activity_data) do
            if i == act.ID then
                act.excute_count = v
            end
        end
    end
    self.refreshUI()
end

local function CreateDailyTaskCtrl()
	local self = CreateCtrlBase()
    self.hunt_items = {}
    self.activity_items = {}
    self.hunt_detail_items = {}


    self.onHuntItemUpdate = function(template, index)
        local data = self.hunt_data[self.page_no][index+1]
        template.transform:FindChild('txt_boss_name'):GetComponent('TextMeshProUGUI').text = data.name
        template.transform:FindChild('txt_pos'):GetComponent('TextMeshProUGUI').text = '刷新位置：'..data.Position
        template.transform:FindChild('text_refresh'):GetComponent('TextMeshProUGUI').text = '刷新间隔：'..data.Time
        template.transform:FindChild('textnumber'):GetComponent('TextMeshProUGUI').text = 'LV.'..data.level
        
        ClickEventListener.Get(template.transform:FindChild('bgbossmessagebox1').gameObject).onClick = function()
            self.selected_index = index
            ShowHuntDetail(self, index)
        end
        
        UIUtil.AddButtonEffect(template.transform:FindChild('btn_goto').gameObject, nil, nil)
        ClickEventListener.Get(template.transform:FindChild('btn_goto').gameObject).onClick = function()
            UIManager.GetCtrl(ViewAssets.DailyTask).close()
            SceneManager.GetEntityManager().hero:moveToUnit(data.ElementID,data.ScenceType,data.ScenceID)
        end

        if data.monster_type == const.MONSTER_TYPE.WILD_ELITE_BOSS then
            template.transform:FindChild('text_refresh').gameObject:SetActive(true)
            template.transform:FindChild('bgrefreshed').gameObject:SetActive(false)
            template.transform:FindChild('btn_goto').gameObject:SetActive(false)
        else
            template.transform:FindChild('text_refresh').gameObject:SetActive(false)
            template.transform:FindChild('bgrefreshed').gameObject:SetActive(true)
            template.transform:FindChild('btn_goto').gameObject:SetActive(true)
        end
        if self.selected_index == index then
            template.transform:FindChild('bgbossmessagebox1'):GetComponent('Toggle').isOn = true
            ShowHuntDetail(self, index)
        else
            template.transform:FindChild('bgbossmessagebox1'):GetComponent('Toggle').isOn = false
        end
    end

    local clearDropsItem = function()
        for k, v in ipairs(self.activity_items) do           
            DestroyScrollviewItem(v)
        end
        self.activity_items = {}
    end

    self.deleteNotTodayActivity = function()
        local tmp = {}
        for i,v in pairs(self.activity_data) do
            local res, code = IsActivityJoinable(v)
            if not res and code == 2 then
            else
                table.insert(tmp, v)
            end
        end
        self.activity_data = tmp
    end

    self.sortAcivityData = function()
        self.deleteNotTodayActivity()
        table.sort(self.activity_data, 
            function(a,b) 

                local join1 = IsActivityJoinable(a) 
                local join2 = IsActivityJoinable(b)

                local flag
                -- 第一优先级
                if join1 ~= join2 then
                    if join1 then
                        flag = true
                    else
                        flag = false
                    end
                else
                    if a.ActivityType ~= b.ActivityType then
                        local tmp = {2,3,1,4}
                        flag = tmp[a.ActivityType] < tmp[b.ActivityType]
                    else
                        flag = a.Order < b.Order
                    end
                end

                return flag
            end )
    end



    self.refreshUI = function()
        clearDropsItem()

        self.sortAcivityData()

        self.view.template_daily:SetActive(false)
        for _, v in pairs(self.activity_data) do
            local item = CreateActivityItemUI(self.view.template_daily, v)
            table.insert(self.activity_items, item)
        end
    end

	self.onLoad = function(data)
		InitStaticButton(self)

        MyHeroManager.RequestActivityInfo()

        self.activity_data = LoadStaticActivityData()
        self.hunt_data = LoadHuntData()
        InitHuntPage(self)
        self.refreshUI()

        self.view.DailyPart:SetActive(true)
        self.view.HuntPart:SetActive(false) 
        self.view.btndaily:GetComponent('Toggle').isOn = true
	end
	
	self.onUnload = function()
		-- ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
        UIManager.UnloadView(ViewAssets.WelfareUI)
	end

    self.PassData = function(data)
        self.activity_info = data.activity_info
        refreshBoxes(self)
    end
	
	return self
end

return CreateDailyTaskCtrl()