---------------------------------------------------
-- auth： panyinglong
-- date： 2017/6/7
-- desc： 单位对话组件
---------------------------------------------------

local const = require "Common/constant"
local config = require "Logic/Scheme/common_npc"     
local log = require "basic/log"

function CreateBehaviorTalkComp(owner)
	local self = CreateObject()
	self.owner = owner
	local data = {}
	data.btns = {}
	data.taskDatas = {}
    data.npcuid = self.owner.uid
    data.name = self.owner.name
    data.dialogue = self.owner.name .. ":" .. "hi"

	-- 打开某个UI btn
	local getOpenUIBtn = function(uiid)
	    local btnname = UISwitchManager.GetUIName(uiid)
	    local btn = {}
	    btn.text = btnname
	    btn.event = function()
	        self.closeTalkUI()
	        UISwitchManager.OpenUI(uiid)
	    end
	    return btn
	end
	-- 接取或提交某个任务btn
	local getTaskBtn = function(taskData)
		local btn = {}
		btn.text = taskData.taskName
		btn.event = function() -- 开始任务对话button
			local dia = taskData.getNpcDialogue()
            if dia == nil then
                log('task','NpcDialogue is nil id=' .. taskData.id ..  ' state=' .. taskData.state)
                self.closeTalkUI()
                return
            end
            taskData.onStartTalk() 
            self.openAndStartTalk(dia, taskData.getDialogueBtns(), taskData.onEndTalk)
		end
	    return btn
	end
	-- 请求接取环任务btn
	local getReceiveCycleTaskBtn = function(taskName)
		local btn = {}
		btn.text = taskName
        btn.event = function()
            if not TaskManager.IsCycleTaskCountOK() then
                UIManager.ShowNotice('任务剩余次数不足！')
                return
            end
            if not TaskManager.IsCycleTaskLevelOK() then
                UIManager.ShowNotice('等级不够！')
                return
            end
            if not TaskManager.isCycleTaskMemberOK() then
                UIManager.ShowNotice('只有队长并且队伍成员数量达到' .. TaskManager.cycleTaskMemNum .. '个才能接受任务')
                return
            end
            TaskManager.ReceiveCycleTask()
            self.closeTalkUI()
        end
        return btn
	end
	-- 请求接取阵营任务btn
	local getReceiveCountryTaskBtn = function(taskName)
		local btn = {}
		btn.text = taskName
        btn.event = function()
            TaskManager.ReceiveCountryTask()
            self.closeTalkUI()
        end
        return btn
	end
	-- 获取提交道具btn
	local getCommitPropBtn = function(index, item)
		local btn = {}
		btn.text = item.TaskName1
        btn.event = function()
            local btnRecov = {
            	text = item.TaskName1,
            	event = function()
            		if BagManager.GetItemNumberById(item.Item[1]) >= item.Item[2] then
                    	self.closeTalkUI()
                        UIManager.PushView(ViewAssets.CampItemSubmitUI,nil,index,self.owner.name,self.owner.uid)
                    else
                    	self.openAndStartTalk(item.UncommittedDialogue, {}, self.closeTalkUI)
                    end
               	end
            }
        	self.openAndStartTalk(item.TaskDialogue, {[1] = btnRecov})
        end
        return btn
	end
	-- 获取传送 btn
	local getConvBtn = function()
		local btn = {}
		btn.text = '前往传送'
        btn.event = function()
            UIManager.PushView(ViewAssets.NPCConveyUI,nil,self.owner.configID)
            self.closeTalkUI()
        end
        return btn
	end

	local canAddBtn = function(funcType)
		if funcType == 2 then -- 环任务接收npc
	    	local cycleTaskData = TaskManager.GetActiveTaskDataOfSort(const.TASK_SORT.daily_cycle)
	    	if #cycleTaskData > 0 then -- 当前没有正在进行的环任务
		        return false
		    end
	    elseif funcType == 7 then -- 阵营任务接受npc
	    	local countryTaskData = TaskManager.GetActiveTaskDataOfSort(const.TASK_SORT.country)
	    	if #countryTaskData > 0 then -- 当前没有正在进行的阵营任务
		        return false
		    end
		end
		return true
	end

	-- 插入其他btn
	local insertOtherFuncBtns = function()
	    local scenetype = SceneManager.currentSceneType
	    local sceneid = SceneManager.currentSceneId
	    local npcId = self.owner.data.ID or self.owner.data.ElementID-- 检查当前任务数据
		
	    local taskDatas = TaskManager.GetNpcTaskData(scenetype, sceneid, npcId)
	    data.taskDatas = taskDatas
	    for _, v in ipairs(data.taskDatas) do
            if v.state == const.TASK_STATE.acceptable or v.state == const.TASK_STATE.doing or v.state == const.TASK_STATE.submit then
            	table.insert(data.btns, getTaskBtn(v))
            end
        end
	end
	-- 插入二级btn
	local getChildFuncBtns = function(funcConfig)
		local childBtns = {}
 		if funcConfig.InterfaceID1 and funcConfig.InterfaceID1[1] then
	        table.insert(childBtns, getOpenUIBtn(funcConfig.InterfaceID1[1]))
	    end
	    if canAddBtn(funcConfig.function1) then
		    if funcConfig.function1 == 2 then -- 环任务接收npc
			    table.insert(childBtns, getReceiveCycleTaskBtn(funcConfig.Function1Tips1))
		    elseif funcConfig.function1 == 7 then -- 阵营任务接受npc
			    table.insert(childBtns, getReceiveCountryTaskBtn(funcConfig.Function1Tips1))
	        elseif funcConfig.function1 == 8 then -- 提交道具
			    local sceneid = SceneManager.currentSceneId
			    local npcId = self.owner.data.ID or self.owner.data.ElementID
	            local taskTable = GetConfig('pvp_country_war').CampNpcTask 
	            for k,v in pairs(taskTable) do  
	                if v.ElementID == npcId and v.MapID == sceneid then 
	                	table.insert(childBtns, getCommitPropBtn(k, v))
			        end
			    end
		    elseif funcConfig.function1 == 3 then -- 传送npc
		        table.insert(childBtns, getConvBtn())
		    end
		end
		return childBtns
	end
	-- 获取一级btn
	local getMainFuncBtn = function(otherFuncConfig, childBtns)
		local btn = {}
		btn.text = otherFuncConfig.Function1Tips1
        btn.event = function()
	    	data.btns = {}
			data.dialogue = self.owner.name .. ":" .. otherFuncConfig.Dialogue11
            for _, btn in ipairs(childBtns) do
            	table.insert(data.btns, btn)
            end
            insertOtherFuncBtns()
            self.openTalkUI()
        end
        return btn
	end

	-- 插入一级btn
	local insertMainFuncBtns = function(npcFuncList, defaultDialog)
	    data.btns = {}
		data.dialogue = self.owner.name .. ":" .. defaultDialog
		for i = 1, #npcFuncList do
			local funcConfig = config.NPCfunction[npcFuncList[i]]
			if canAddBtn(funcConfig.function1) then
				local childBtns = getChildFuncBtns(funcConfig)
				if #childBtns == 1 then
					table.insert(data.btns, childBtns[1]) --如果主btn只有一个二级btn的时候，则只添加子btn，不添加主btn
				else
			        table.insert(data.btns, getMainFuncBtn(funcConfig, childBtns)) -- 否则，添加主btn(当用户点击主btn时，展开子btn)
			    end
		    end
	    end
	end
	
	self.OnInterAct = function(npcFuncList, defaultDialog)
		insertMainFuncBtns(npcFuncList, defaultDialog)
		insertOtherFuncBtns()
		self.openTalkUI()
	end

	self.openTalkUI = function()		
		if #data.btns == 1 then
			data.btns[1].event()
		else
		    local ctrl = UIManager.GetCtrl(ViewAssets.NPCTalkUI)
			if ctrl.isLoading then
				error('NPCTalkUI is loading when openTalkUI try load it')
			end
	        if not ctrl.isLoaded then
	        	UIManager.PushView(ViewAssets.NPCTalkUI, nil, data)
	        else
	        	ctrl.reLoad(data)
	        end
	    end
	end

	self.openAndStartTalk = function(dialogue, endBtns, onEndTalk)
		local ctrl = UIManager.GetCtrl(ViewAssets.NPCTalkUI)
		if ctrl.isLoading then
			error('NPCTalkUI is loading when showAndStartTalk try load it')
		end
        if not ctrl.isLoaded then
        	UIManager.PushView(ViewAssets.NPCTalkUI, function(c)
        		c.startTalk(dialogue, endBtns, onEndTalk)
        	end, data)
        else
        	ctrl.startTalk(dialogue, endBtns, onEndTalk)
        end
	end

	self.closeTalkUI = function()
		UIManager.UnloadView(ViewAssets.NPCTalkUI)
	end
	return self
end