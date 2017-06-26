require "UI/Controller/LuaCtrlBase"

local function CreateCampBattleUICtrl()
    local self = CreateCtrlBase()
	local battleRecord = nil
    local taskTable = GetConfig('pvp_country_war').Task
    local taskRefreshTable = GetConfig('pvp_country_war').TaskRefresh
    local campTime = GetConfig('pvp_country_war').Parameter[5].Value
    local textTable = GetConfig('common_char_chinese').UIText
    
    local taskGoalParam = {1,1,nil,nil,nil,nil,nil}
    
    local BindData = function(item,index)
        local data = battleRecord[index+1]
        item.transform:Find('textLog'):GetComponent('TextMeshProUGUI').text = string.format(textTable[data.text_id].NR,unpack(data.param))
    end
    
    self.OpenUI = function()

    end
    local countDown = nil
    self.GetCountryWarBasicInfoRet = function(data)
        battleRecord = data.basic_info.battle_record
        self.view.myScore:GetComponent('TextMeshProUGUI').text = '我的战功：'..data.self_war_score
        self.view.textScore1:GetComponent('TextMeshProUGUI').text = data.basic_info.country_total_score[1]
        self.view.textScore2:GetComponent('TextMeshProUGUI').text = data.basic_info.country_total_score[2]
        if battleRecord then
            self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#battleRecord,BindData)
        else
            self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(0,BindData)
        end
        local process = 0.5
        if data.basic_info.country_total_score[1] + data.basic_info.country_total_score[2] ~= 0 then
            process = data.basic_info.country_total_score[1]/(data.basic_info.country_total_score[1] + data.basic_info.country_total_score[2])
        end
        self.view.textHit1:GetComponent('TextMeshProUGUI').text = string.format('%.2f%%',process*100)
        self.view.textHit2:GetComponent('TextMeshProUGUI').text = string.format('%.2f%%',(1-process)*100)    
        self.view.process:GetComponent('RectTransform').sizeDelta = Vector2.New((1-process)*1076,108)
        self.view.leftTime:GetComponent('TextMeshProUGUI').text = '不在活动时间内'
        if MyHeroManager.campScore then
            Timer.Remove(countDown)
            
            countDown = Timer.Repeat(1,function()
                local serverTime = networkMgr:GetConnection().ServerSecondTimestamp
                local temp = os.date("*t", serverTime)
                local clockTime = temp.hour*3600+temp.min *60+temp.sec
                local endTime = campTime[4]*60 + campTime[3]*3600
                local leftTime = endTime - clockTime 
                self.view.leftTime:GetComponent('TextMeshProUGUI').text = string.format('大攻防活动剩余时间：%02d:%02d:%02d',math.floor(leftTime/3600),math.floor(leftTime/60)%60,leftTime%60)
            end)
        end
        
    end
    
    self.GetCountryWarInfoRet  = function(data)
        if not data.country_war_task then
            return
        end
        for i=1,3 do
            local taskData = data.country_war_task[i]
            if taskData then                
                local taskInfo = taskTable[taskData.id]
                self.view['btnRefresh'..i]:SetActive(taskData.status == constant.COUNTRY_WAR_TASK_STATUS.doing)
                self.view['chest'..i]:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite("AutoGenerate/CampBattleUI/chest"..math.ceil(taskInfo.Star/2))
                local color = 'green'
                if taskData.status == constant.COUNTRY_WAR_TASK_STATUS.doing then
                    color = 'red'
                end
                self.view['texttask'..i]:GetComponent('TextMeshProUGUI').text = string.format('%s<color=%s>(%d/%d)',taskInfo.description,color,taskData.param,taskGoalParam[taskInfo.LogicID] or taskInfo.para1) 
                for j=1,5 do
                    self.view['imgstar'..i].transform:Find('imgstar'..j).gameObject:SetActive(j<taskInfo.Star+1)
                end
                if taskData.status == constant.COUNTRY_WAR_TASK_STATUS.reward then
                    self.view['chest'..i]:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
                elseif taskData.status == constant.COUNTRY_WAR_TASK_STATUS.doing then
                    self.view['chest'..i]:GetComponent('Image').material = nil
                else
                    self.view['chest'..i]:GetComponent('Image').material = nil
                    self.AddClick(self.view['chest'..i],function() 
                        local data = {}
                        data.func_name = 'get_country_war_task_reward'
                        data.task_num = i
                        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
                    end)
                end
            end
            self.AddClick(self.view['btnRefresh'..i],function()
                local cost = LuaUIUtil.GetFloorTableItem(taskRefreshTable,'Number',data.country_war_task_refresh_count[i]).Cost
                local str = '该任务本次刷新免费，是否刷新？'
                if not table.isEmptyOrNil(cost) then
                    str = string.format('刷新该任务，需消耗%d%s，是否刷新？',cost[2],LuaUIUtil.GetItemName(cost[1]))
                end
                UIManager.ShowDialog(str, '确定', '取消',function()                   
                    local data = {}
                    data.func_name = 'refresh_country_war_task'
                    data.task_num = i
                    MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
                end,nil) 
            end)
        end
    end
    
    self.onLoad = function()
        self.AddClick(self.view.myScore,function() UIManager.GetCtrl(ViewAssets.CampBattleScoreUI).OpenUI() end)
        self.AddClick(self.view.scrollView,function() UIManager.PushView(ViewAssets.CampBattleStatusUI,nil,battleRecord) end)

        self.view.logItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.logItem,1053.51,42,0,2,1)
        MessageRPCManager.AddUser(self, 'GetCountryWarBasicInfoRet')
        MessageRPCManager.AddUser(self, 'GetCountryWarInfoRet')
        
        local data = {}
        data.func_name = 'on_get_country_war_basic_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        local data = {}
        data.func_name = 'get_country_war_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        
    end

    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'GetCountryWarBasicInfoRet')
        MessageRPCManager.RemoveUser(self, 'GetCountryWarInfoRet')
        if countDown then
            Timer.Remove(countDown)
        end
    end

    return self
end

return CreateCampBattleUICtrl()

