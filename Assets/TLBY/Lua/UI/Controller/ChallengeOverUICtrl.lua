---------------------------------------------------
-- auth： panyinglong
-- date： 2016/10/21
-- desc： 挑战结算
---------------------------------------------------
local itemTable = require "Logic/Scheme/common_item"
local dungeonTable = require "Logic/Scheme/challenge_main_dungeon"
local gradeTable = dungeonTable.TranscriptMark

local SSS_icon = "AutoGenerate/ChallengeOverUI/sss"
local SS_icon = "AutoGenerate/ChallengeOverUI/ss"
local S_icon = "AutoGenerate/ChallengeOverUI/s"
local A_icon = "AutoGenerate/ChallengeOverUI/a"
local B_icon = "AutoGenerate/ChallengeOverUI/b"
local const = require "Common/constant"

local function CreateDropItemUI(template, data)
	local self = CreateScrollviewItem(template)

	self.equipmentdrop = self.transform:FindChild('imgItem')
	self.equipmentNum = self.transform:FindChild('txtNum')
	local item = itemTable.Item[data.itemID]
	if item then
		self.equipmentdrop:GetComponent('Image').sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s", item.Icon))
		
		local numtext = data.num
		if data.num >= 1000 then
			numtext = string.format("%2dk", data.num/1000)
		end
		self.equipmentNum:GetComponent('TextMeshProUGUI').text = numtext
	else
		print("error!!! not find item id="..data.itemID)
	end
	return self
end

local function CreateChallengeOverUICtrl()
	local self = CreateCtrlBase()
	self.data = nil
	local itemTemplate = nil
	local dropItems = {}

	local clearDropsItem = function()
		for k, v in pairs(dropItems) do			
			DestroyScrollviewItem(v)
		end
		dropItems = {}
	end

	local updateDropUI = function(data)
		clearDropsItem()
		if data then
			for k, v in ipairs(data) do
				local item = CreateDropItemUI(itemTemplate, v)
				table.insert(dropItems, item)
			end
		end
	end

	local fillTimer = nil
	local startFill = function(img, amount)
		local cur = 0
		local num = 400
		if fillTimer == nil then
			fillTimer = Timer.Numberal(0.01, num, function()
				cur = cur + amount/num
				img.fillAmount = cur
			end)
		end
	end

	-- local Quit = function()
	-- 	self.close()
	-- 	if SceneManager.currentSceneType == const.SCENE_TYPE.DUNGEON then
 --            MainDungeonManager.RequstEndDungeon()
 --        elseif SceneManager.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON then
 --            TeamDungeonManager.RequestLeaveDungeon()
 --        elseif SceneManager.currentSceneType == const.SCENE_TYPE.TASK_DUNGEON then
 --            TaskDungeonManager.RequestLevelTaskDungeon()
 --        else
 --            error('战斗服类型不对')
 --        end
	-- end

	-- local quitTime = 30
	-- local quitTimer = nil
	-- local removeQuitTimer = function()
	-- 	if quitTimer then
	-- 		Timer.Remove(quitTimer)
	-- 	end
	-- 	self.view.txtCountdown:GetComponent('TextMeshProUGUI').text = ''
	-- 	quitTimer = nil
	-- end
	-- local startQuitTimer = function(t)
	-- 	removeQuitTimer()
	-- 	quitTime = t
	-- 	quitTimer = Timer.Repeat(1, function()
	-- 		if quitTime <= 0 then
	-- 			removeQuitTimer()
	-- 			Quit()
	-- 		else
	-- 			quitTime = quitTime - 1
	-- 			self.view.txtCountdown:GetComponent('TextMeshProUGUI').text = '(' .. quitTime .. 's' .. ')'
	-- 		end
	-- 	end)		
	-- end
	-- local StayClick = function()
 --        self.view.btnStay:SetActive(false)
 --        removeQuitTimer()
 --        self.close()

 --        -- 如果复活页面已经打开的话,显示它
 --        if SceneManager.IsOnDungeonScene() then
	-- 		UIManager.ShowAll()
	-- 	end
 --    end
 --    local QuitClick = function()
	-- 	Quit()
	-- end
	
	local getFillamount = function(markid, lefttime, totaltime)
		local pro = 0
		if markid == 1 then -- sss
			pro = 1
		elseif markid == 2 then -- ss
			pro = 0.75
		elseif markid == 3 then -- s
			pro = 0.5
		elseif markid == 4 then -- a
			pro = 0.25
		elseif markid == 5 then -- b
			pro = 0
		end
		if markid > 1 then
			local min = LuaUIUtil.getMarkData(markid).RestTime * totaltime / 100 -- 该档最低时间
			local max = LuaUIUtil.getMarkData(markid - 1).RestTime * totaltime / 100 -- 该档最高时间
			local dpro = (lefttime - min)/(max - min) * 0.25
			pro = pro + dpro
		end
		return pro
	end

	-- 当加载完时
	-- win：bool，是否成功完成副本
	-- rewards：table
	self.onLoad = function(data)
		self.data = data
    	-- 如果复活页面已经打开的话,隐藏它
        if SceneManager.IsOnDungeonScene() then
			UIManager.HideAll()
		end

        if data.win then
        	self.view.WinGroup:SetActive(true)
        	self.view.FailedGroup:SetActive(false)
        	if data.mark == 1 then -- sss
        		self.view.imgGrade:GetComponent('Image').sprite = ResourceManager.LoadSprite(SSS_icon)
        	elseif data.mark == 2 then 	-- Ss
        		self.view.imgGrade:GetComponent('Image').sprite = ResourceManager.LoadSprite(SS_icon)
        	elseif data.mark == 3 then -- s
        		self.view.imgGrade:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
        	elseif data.mark == 4 then -- a
        		self.view.imgGrade:GetComponent('Image').sprite = ResourceManager.LoadSprite(A_icon)
        	elseif data.mark == 5 then -- b
        		self.view.imgGrade:GetComponent('Image').sprite = ResourceManager.LoadSprite(B_icon)
        	else
        		error('没有对应的mark')
        	end
        	if SceneManager.currentSceneType == const.SCENE_TYPE.DUNGEON or SceneManager.currentSceneType == const.SCENE_TYPE.TEAM_DUNGEON then
	        	self.view.txtMark:GetComponent('TextMeshProUGUI').text = '' --"您的副本评分超越了张三太子、木乃伊等多个玩家"
	        else
	        	self.view.txtMark:GetComponent('TextMeshProUGUI').text = ""
	        end

	        local dungeonData = SceneManager.GetCurSceneData() -- 主线，组队或任务副本

	        local totaltime = dungeonData.Time/1000
	        local costtime = data.cost_time
	        local lefttime = totaltime - costtime
	        if lefttime < 0 then
	        	lefttime = 0
	        end
	        local pro = getFillamount(data.mark, lefttime, totaltime)
	        startFill(self.view.imgProgress:GetComponent('Image'), pro)

	        for i = 1, 5 do 
	        	local m = LuaUIUtil.getMarkData(i)
	        	self.view['txtTime' .. i]:GetComponent('TextMeshProUGUI').text = m.RewardPoints .. '分'
	        	if i == data.mark or i == (data.mark - 1) then
	        		-- self.view['txtTime' .. i]:SetActive(true)
	        		self.view['txtTime' .. i]:SetActive(false)
	        	else
	        		self.view['txtTime' .. i]:SetActive(false)
	        	end
	        end
        else
        	self.view.WinGroup:SetActive(false)
        	self.view.FailedGroup:SetActive(true)
        	self.view.text1:GetComponent('TextMeshProUGUI').text = "强化装备"
        	self.view.text2:GetComponent('TextMeshProUGUI').text = "养成宠物"
        	self.view.text3:GetComponent('TextMeshProUGUI').text = "镶嵌宝石"
        end
        
        itemTemplate = self.view.rewardItem
        itemTemplate:SetActive(false)
        -- self.view.btnStay:SetActive(true)
        -- startQuitTimer(30)

        if data.rewards then
        	local drops = {}
        	for k, v in pairs(data.rewards)do
        		table.insert(drops, {itemID = k, num = v})
        	end
        	updateDropUI(drops)
        end

     --    ClickEventListener.Get(self.view.btnQuit).onClick = QuitClick
     --    UIUtil.AddButtonEffect(self.view.btnQuit, nil, nil)
     --    if data.win then
	    -- 	self.setButtonEnable(self.view.btnStay, true)
	    --     ClickEventListener.Get(self.view.btnStay).onClick = StayClick
	    --     UIUtil.AddButtonEffect(self.view.btnStay, nil, nil)
	    -- else
	    -- 	self.setButtonEnable(self.view.btnStay, false)
	    -- end

		ClickEventListener.Get(self.view.mask).onClick = self.Collapse
		ClickEventListener.Get(self.view.btnResult).onClick = self.Expand
		self.view.btnResult:SetActive(false)
	end

	-- 当销毁(回收)时
	self.onUnload = function()
		if fillTimer then
			Timer.Remove(fillTimer)
			fillTimer = nil
		end
		-- removeQuitTimer()
	end

	self.Collapse = function()
		local duration = 0.2
		local recTransform = self.view.btnResult:GetComponent("RectTransform")    
		local tweenScal = BETween.scale(self.view.mask, duration, Vector3.zero)
		local tweenPos = BETween.anchoredPosition(self.view.mask, duration, recTransform.anchoredPosition)

		Timer.Delay(duration, function()
			if SceneManager.IsOnDungeonScene() then
				UIManager.ShowAll()
			end
			self.view.btnResult:SetActive(true)
		end)
	end
	self.Expand = function()
		local duration = 0.2
		local tweenScal = BETween.scale(self.view.mask, duration, Vector3.New(1, 1, 1))
		local tweenPos = BETween.anchoredPosition(self.view.mask, duration, Vector2.New(0, 0))
		self.view.btnResult:SetActive(false)

		Timer.Delay(duration, function()
			if SceneManager.IsOnDungeonScene() then
				UIManager.HideAll()
				self.show()
			end
		end)
	end
	return self
end

return CreateChallengeOverUICtrl()