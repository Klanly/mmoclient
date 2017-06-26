---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/7
-- desc： 任务
---------------------------------------------------
local itemTable = require "Logic/Scheme/common_item"
local const = require "Common/constant"
local log = require "basic/log"

require "UI/Controller/LuaCtrlBase"
local function CreateRewardItem(temp, data)
	local self = CreateScrollviewItem(temp)

	self.imgItem = self.transform:FindChild('imgItem')
	local item = itemTable.Item[data.itemID]
	if item then
		self.imgItem:GetComponent('Image').sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s", item.Icon))
	else
		error("not find item id="..data.itemID)
	end
	self.num = self.transform:FindChild('imgNum/txtNum')
	local numtext = data.num
	if data.num >= 1000 then
		numtext = string.format("%2dk", data.num/1000)
	end
	self.num:GetComponent('TextMeshProUGUI').text = numtext
	ClickEventListener.Get(self.imgItem.gameObject).onClick = function()
		BagManager.ShowItemTips({item_data={id=data.itemID}},true)
	end
	return self
end

local function CreateTaskSectionItem(temp, data)
	local self = CreateScrollviewItem(temp)
	local taskUIctrl = UIManager.GetCtrl(ViewAssets.TaskUI)
	local OnClick = function()
		taskUIctrl.SelectTaskItem(self.data)
	end
	
	local Update = function(data)
		self.data = data
		self.subSectionName.text = self.data.getBriefTaskName()
	end
	
	local init = function()
		local bg = self.transform:FindChild('bg').gameObject
		ClickEventListener.Get(bg).onClick = OnClick
		self.subSectionIndex = self.transform:FindChild('subSectionIndex'):GetComponent('TextMeshProUGUI')
		self.subSectionName = self.transform:FindChild('subSectionName'):GetComponent('TextMeshProUGUI')
		Update(data)
	end
	init()
	return self
end

-- 章item 通常以该章第1节为data
local function CreateTaskChapterItem(temp, data)
	local self = CreateScrollviewItem(temp)
	self.data = data
	self.sectionItemTemplate = self.transform:FindChild('subSectionList/subSectionTemplate').gameObject
	self.isExpand = true
	self.isFinish = false
	local taskUIctrl = UIManager.GetCtrl(ViewAssets.TaskUI)
	local defaultHeight = self.gameObject:GetComponent('LayoutElement').preferredHeight 
	local sectionHeight = 66 + 5
	local sectionItems = {}

	local initSectionItem = function()
		if #sectionItems == 0 then	
			if self.data.taskSort == const.TASK_SORT.main then
				local taskDatas = TaskManager.GetDoingAndDoneTaskData()
				table.sort(taskDatas, function(a, b)
					return a.id < b.id
				end)
				for _, v in ipairs(taskDatas) do		
					if v.chapter == self.data.chapter then
						local item = CreateTaskSectionItem(self.sectionItemTemplate, v)
						table.insert(sectionItems, item)
					end
				end
			else
				local item = CreateTaskSectionItem(self.sectionItemTemplate, self.data)
				table.insert(sectionItems, item)
			end
		end
		self.expand()
	end

	self.expand = function()
		if self.isExpand then
			self.gameObject:GetComponent('LayoutElement').preferredHeight = defaultHeight
			for _, item in ipairs(sectionItems) do
				item.gameObject:SetActive(false)
			end
		else
			self.gameObject:GetComponent('LayoutElement').preferredHeight = defaultHeight + sectionHeight * #sectionItems
			for _, item in ipairs(sectionItems) do
				item.gameObject:SetActive(true)
			end
		end
		self.isExpand = not self.isExpand
	end
	
	local OnClick = function()
		self.expand()
	end
	self.Update = function(d)
		self.data = d

		self.isFinish = false
		if self.data.taskSort == const.TASK_SORT.main then
			-- self.chapterIndexTxt.text = "第" .. self.data.chapter .. "章"
			self.chapterNameTxt.text = "<size=27>" .. "第" .. self.data.chapter .. "章" .. "</size>      <size=35>".. self.data.chapterName .. "</size>"
			if TaskManager.IsChapterDone(self.data.chapter) then
				self.isFinish = true
			end
		else
			-- self.chapterIndexTxt.text = "" --"第" .. self.data.chapter .. "章"
			self.chapterNameTxt.text = "<size=35>".. self.data.cfg.TaskTitle1 .. "</size>"
			if self.data.state >= const.TASK_STATE.done then
				self.isFinish = true
			end
		end
		self.finishImg:SetActive(self.isFinish)
		if self.isFinish and taskUIctrl.hideFinished then
			self.gameObject:SetActive(false)
		else
			self.gameObject:SetActive(true)
		end
	end

	local init = function()
		local bg = self.transform:FindChild('chapterGroup/bg').gameObject
		ClickEventListener.Get(bg).onClick = OnClick
	    self.finishImg = self.transform:FindChild('chapterGroup/imgFinished').gameObject
	    self.chapterIndexTxt = self.transform:FindChild('chapterGroup/txtSectionIndex'):GetComponent('TextMeshProUGUI')
	    self.chapterNameTxt = self.transform:FindChild('chapterGroup/txtSectionName'):GetComponent('TextMeshProUGUI')
		self.Update(self.data)

		initSectionItem()
	end
	
	init()
	return self
end

local function CreateTaskUICtrl()
	local self = CreateCtrlBase()
	self.hideFinished = false
	self.selectData = nil
	local chapterItems = {}

	local closeClick = function()
		self.close()
	end
	
	local okClick = function()
	end

	local clearItems = function()	
        for k, v in pairs(chapterItems) do
        	DestroyScrollviewItem(v.gameObject)
        end
        chapterItems = {}
    end
    local addChapterItem = function(taskData)
		local item = CreateTaskChapterItem(self.view.taskItemTemplate, taskData)
		table.insert(chapterItems, item)
	end

	local InitTaskList = function()
		clearItems()
		local lastChapter = nil
		local taskDatas = TaskManager.GetDoingAndDoneTaskData()
		table.sort(taskDatas, function(a, b)
			return a.id < b.id
		end)
		for _, v in ipairs(taskDatas) do
			if v.chapter ~= lastChapter or v.chapter == nil then
				addChapterItem(v)
				lastChapter = v.chapter
			end
		end
	end

	local taskRewardItems = {}
	local clearRewardItems = function()
		for _, rewardItem in ipairs(taskRewardItems) do
			DestroyScrollviewItem(rewardItem.gameObject)
		end
		taskRewardItems = {}	
	end
	self.SelectTaskItem = function(taskData)
		self.selectData = taskData
		if taskData == nil then
			self.view.txtSectionName:GetComponent('TextMeshProUGUI').text = ""
			self.view.txtTaskDesc:GetComponent('TextMeshProUGUI').text = ""
			self.view.txtTargetDesc:GetComponent('TextMeshProUGUI').text = ""
			clearRewardItems()
		else
			self.view.txtSectionName:GetComponent('TextMeshProUGUI').text = taskData.sectionName
			self.view.txtTaskDesc:GetComponent('TextMeshProUGUI').text = taskData.detailDesc
			self.view.txtTargetDesc:GetComponent('TextMeshProUGUI').text = taskData.targetDesc
			clearRewardItems()
			local rewards = taskData.getRewards()
			for id, num in pairs(rewards) do
				local item = CreateRewardItem(self.view.rewardItemTemplate, {itemID = id, num = num})
				table.insert(taskRewardItems, item)
			end			
		end
	end
	self.OnTaskDataUpdate = function(data_or_id, type)
		for i = #chapterItems, 1, -1 do
			local item = chapterItems[i]
			if item.data.taskSort == const.TASK_SORT.main then
				item.Update(item.data)
			else
				if item.data.state == const.TASK_STATE.unknown then
					DestroyScrollviewItem(item.gameObject)
					table.remove(chapterItems, i)
				else
					item.Update(item.data)
				end
			end
        end
	end

	local onHideFinishClick = function ()
		self.hideFinished = not self.hideFinished
		self.view.imgCheckHide:SetActive(self.hideFinished)
		self.OnTaskDataUpdate()
	end
	
	local onAbortClick = function()
		if not self.selectData then
			log('task', '没有选择任务')
			return
		end
		if self.selectData.taskSort == const.TASK_SORT.main then
			UIManager.ShowNotice('主线任务不可以放弃!')
			return
		end
		if self.selectData.state == const.TASK_STATE.doing or self.selectData.state == const.TASK_STATE.submit then
			TaskManager.GiveUpTask(self.selectData)
			self.close()
		else
			UIManager.ShowNotice('当前任务状态无法放弃')
		end
	end
	
	local onEnterClick = function()
		if not self.selectData then
			log('task', '没有选择任务')
			return
		end
		self.selectData.Excute()
		self.close()
	end
	self.onLoad = function()	
        ClickEventListener.Get(self.view.close).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.close, nil, nil)

        ClickEventListener.Get(self.view.btnAbort).onClick = onAbortClick
        UIUtil.AddButtonEffect(self.view.btnAbort, nil, nil)
        
        ClickEventListener.Get(self.view.btnEnter).onClick = onEnterClick
        UIUtil.AddButtonEffect(self.view.btnEnter, nil, nil)

        InitTaskList()
        ClickEventListener.Get(self.view.imgHideFinTask).onClick = onHideFinishClick
		self.view.imgCheckHide:SetActive(self.hideFinished)  
		TaskManager.AddListener(self.OnTaskDataUpdate)     
		self.SelectTaskItem(nil) 
	end
	
	self.onUnload = function()
		TaskManager.RemoveListener(self.OnTaskDataUpdate)
		clearItems()
		clearRewardItems()
	end

	return self
end

return CreateTaskUICtrl()