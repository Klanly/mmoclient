---------------------------------------------------
-- auth： panyinglong
-- 主页面任务面板
---------------------------------------------------
local const = require "Common/constant"

local IMG_MAIN = 'AutoGenerate/TaskUI/btnmain'
local IMG_BRANCH = 'AutoGenerate/TaskUI/btnbranch'
local IMG_HIDE = 'AutoGenerate/TaskUI/btnhidden'
local IMG_LOOP = 'AutoGenerate/TaskUI/btnloop'
local IMG_COUNTRY = 'AutoGenerate/TaskUI/btncountry'

-- 英雄是否存在并活着
local isHeroDied = function()
    local hero = SceneManager.GetEntityManager().hero
    if not hero or hero:IsDied() or hero:IsDestroy() then
        return true
    end
    return false
end
local showDieNotice = function()
    UIManager.ShowNotice('英雄已经死亡, 无法操作! ')
end

local function createTaskItem(temp, data)
	local self = CreateScrollviewItem(temp)
	self.data = data

	local OnClick = function()
        if isHeroDied() then showDieNotice(); return end
		local hero = SceneManager.GetEntityManager().hero
        if hero and hero.enabled then
			if hero.lowFlyManager.IsShowLocus() then
				UIManager.ShowNotice('当前正在轻功中')
				return
			end
        end
		-- TaskManager.StartTask(self.data)
		self.data.Excute(true)
	end
	self.Update = function(d)
		self.data = d
		local imgres = nil
		if self.data.taskSort == const.TASK_SORT.main then
			imgres = IMG_MAIN
		elseif self.data.taskSort == const.TASK_SORT.branch then
			imgres = IMG_BRANCH
		elseif self.data.taskSort == const.TASK_SORT.vacation or 
			self.data.taskSort == const.TASK_SORT.faction or 
			self.data.taskSort == const.TASK_SORT.daily_cycle then
			imgres = IMG_LOOP
		elseif self.data.taskSort == const.TASK_SORT.secret then
			imgres = IMG_HIDE
		elseif self.data.taskSort == const.TASK_SORT.country then
			imgres = IMG_COUNTRY
		else
			error('没有找到资源类型 id= '.. self.data.id .. ' taskSort=' .. self.data.taskSort)
		end	
		if not imgres then
			error('没有找到资源')
		end
		self.transform:FindChild('imgTaskType'):GetComponent('Image').sprite = ResourceManager.LoadSprite(imgres)		
		self.transform:FindChild('txtTaskName'):GetComponent('TextMeshProUGUI').text = self.data.getBriefTaskName()
		self.transform:FindChild('txtTaskContent'):GetComponent('TextMeshProUGUI').text = self.data.getBriefDesc()
	end

	self.OnFinish = function()
		self.transform:FindChild('completeEffect').gameObject:SetActive(true)
		Timer.Delay(1.2, function()
			if not IsNil(self.gameObject) then
				self.OnDestroy()
			end
		end)
	end
	self.OnDestroy = function()
		DestroyScrollviewItem(self.gameObject)
	end

	local init = function()
		local bg = self.transform:FindChild('bg').gameObject
		ClickEventListener.Get(bg).onClick = OnClick
	    self.transform:FindChild('completeEffect').gameObject:SetActive(false)
	end
	
	init()
	self.Update(data)
	return self
end



function CreateMainUITaskCtrl(view)
    local self = CreateObject()
    self.view = view
    local isShowTaskGroup = false
    local showTaskTime = os.clock()

    local taskItems = {}
    
    self.OnTaskDataUpdate = function(data_or_id, type)
    	if type == 'update' then
    		for k, v in ipairs(data_or_id) do
				local item = self.getTaskItem(v.id)
				if item then
					item.Update(v)
				else
					self.AddTaskItem(v)
				end
			end
    	elseif type == 'submit' then
    		for i = #taskItems, 1, -1 do
    			local item = taskItems[i]
    			if item.data.id == data_or_id then
    				taskItems[i].OnFinish()
    				table.remove(taskItems, i)
    			end
    		end
    	elseif type == 'giveup' then
    		for i = #taskItems, 1, -1 do
    			local item = taskItems[i]
    			if item.data.id == data_or_id then
    				taskItems[i].OnDestroy()
    				table.remove(taskItems, i)
    			end
    		end
    	end
	end

	self.getTaskItem = function(id)
		for k, v in ipairs(taskItems) do
			if v.data.id == id then
				return v
			end
		end
		return nil
	end

	local ontime = nil
	local onTaskBtnClick = function()
        if isHeroDied() then showDieNotice(); return end
		local dt = os.time() - showTaskTime
		if isShowTaskGroup and dt >= 1 then
			UIManager.PushView(ViewAssets.TaskUI)
		end
	end
	local onToggleChanged = function(value)
		if value then
			if not isShowTaskGroup then	
			    isShowTaskGroup = true
			    showTaskTime = os.time()
			end
		else
			isShowTaskGroup = false
		end
	end

    self.onLoad = function()
		self.taskItemTemplate = self.view.taskItemTemplate
		self.taskItemTemplate:SetActive(false)

		TaskManager.AddListener(self.OnTaskDataUpdate)
		self.OnTaskDataUpdate(TaskManager.GetActiveTaskData(), 'update')

		isShowTaskGroup = true
		showTaskTime = os.time()
		UIUtil.AddToggleListener(self.view.toggleTask, onToggleChanged)	
		ClickEventListener.Get(self.view.toggleTask).onClick = onTaskBtnClick
	end

    self.onUnload = function()
        for k, v in pairs(taskItems) do
        	DestroyScrollviewItem(v.gameObject)
        end
        taskItems = {}
		TaskManager.RemoveListener(self.OnTaskDataUpdate)
	end

	local removeItemBySortType = function(taskSort)
		for i = #taskItems, 1, -1 do
			local item = taskItems[i]
			if item.data.taskSort == taskSort then
				taskItems[i].OnDestroy()
				table.remove(taskItems, i)
			end
		end
	end
	self.AddTaskItem = function(data)
		if data.taskSort == const.TASK_SORT.daily_cycle then -- 同一时刻只能有一个环任务, 如果新加的环任务, 则先移除现有的环任务
			removeItemBySortType(const.TASK_SORT.daily_cycle)
		end
		if data.taskSort == const.TASK_SORT.country then -- 同一时刻只能有一个阵营任务
			removeItemBySortType(const.TASK_SORT.country)
		end
		local item = createTaskItem(self.taskItemTemplate, data)
		table.insert(taskItems, item)
		if data.taskSort == const.TASK_SORT.main then
			item.transform:SetAsFirstSibling()
		end
	end
    
    self.onLoad()
    return self
end