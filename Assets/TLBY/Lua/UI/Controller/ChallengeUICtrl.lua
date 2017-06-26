---------------------------------------------------
-- auth： panyinglong
-- date： 2016/10/21
-- desc： 挑战
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local uitext = GetConfig('common_char_chinese').UIText

local S_icon = "Common/s"
local A_icon = "Common/a"
local B_icon = "Common/b"
local C_icon = "Common/c"
local Box_open = "Common/box_open"
local Box_1_icon = "Common/box1"
local Box_2_icon = "Common/box2"
local Box_3_icon = "Common/box3"

local function CreateChapterItemUI(template, data)
	local self = CreateScrollviewItem(template)

	local sNum = data.getSNum()
	local sTotalNum = data.getTotalSNum()

	self.transform:FindChild('@txtChapterIndex'):GetComponent('TextMeshProUGUI').text = data.rank
	self.transform:FindChild('@txtStarCount'):GetComponent('TextMeshProUGUI').text = sNum .. "/" .. sTotalNum
	self.transform:FindChild('@txtChapterName'):GetComponent('TextMeshProUGUI').text = data.name
	return self
end
local function CreateDungeonItemUI(template, data)
	local self = CreateScrollviewItem(template)
	self.data = data
	self.selectFlag = nil

	local onOpenLordClick = function()
		UIManager.PushView(ViewAssets.Overlordlist,nil,self.data)
	end

	local initUI = function()		
		self.selectFlag = self.transform:FindChild('@imgChapterSelect').gameObject
		local imgSectionBg = self.transform:FindChild("imgSectionBg").gameObject

        ClickEventListener.Get(imgSectionBg).onClick = function()
        	UIManager.GetCtrl(ViewAssets.ChallengeUI).selectDungeon(self)
        end 
		if data.index % 2 == 0 then
			imgSectionBg.transform.localScale = Vector3.New(1, 1, 1)
			self.selectFlag.transform.localScale = Vector3.New(-1, 1, 1)
		else
			imgSectionBg.transform.localScale = Vector3.New(-1, 1, 1)	
			self.selectFlag.transform.localScale = Vector3.New(1, 1, 1)		
		end

		local rating1 = self.transform:FindChild('@sectionContent/@rating1').gameObject
		local rating2 = self.transform:FindChild('@sectionContent/@rating2').gameObject
		local rating3 = self.transform:FindChild('@sectionContent/@rating3').gameObject
        rating1:SetActive(false)
        rating3:SetActive(false)
		rating2:SetActive(true)

    	if data.bestGrade == DungeonGrade.SSS then
    		rating1:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
    		rating2:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
    		rating3:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
	        rating1:SetActive(true)
	        rating3:SetActive(true)
    	elseif data.bestGrade == DungeonGrade.SS then
    		rating1:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
    		rating3:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
	        rating1:SetActive(true)
	        rating3:SetActive(true)
			rating2:SetActive(false)
    	elseif data.bestGrade == DungeonGrade.S then
    		rating2:GetComponent('Image').sprite = ResourceManager.LoadSprite(S_icon)
    	elseif data.bestGrade == DungeonGrade.A then
    		rating2:GetComponent('Image').sprite = ResourceManager.LoadSprite(A_icon)
    	elseif data.bestGrade == DungeonGrade.B then
    		rating2:GetComponent('Image').sprite = ResourceManager.LoadSprite(B_icon)
    	elseif data.bestGrade == DungeonGrade.C then
    		rating2:GetComponent('Image').sprite = ResourceManager.LoadSprite(C_icon)
    	else
			rating2:SetActive(false)
    	end
		self.transform:FindChild('@sectionContent/@txtSectionLevel'):GetComponent('TextMeshProUGUI').text = "推荐等级：" .. data.Level
		self.transform:FindChild('@sectionContent/@txtSectionName'):GetComponent('TextMeshProUGUI').text = data.Name
		self.transform:FindChild('@sectionContent/@overlordname'):GetComponent('TextMeshProUGUI').text = ""

		self.lordImg = self.transform:FindChild('@sectionContent/@bgoverlord').gameObject

        ClickEventListener.Get(self.lordImg).onClick = onOpenLordClick
        UIUtil.AddButtonEffect(self.lordImg, nil, nil)

		self.setSelect(false)
	end
	self.updateLordInfo = function()
		self.transform:FindChild('@sectionContent/@overlordname'):GetComponent('TextMeshProUGUI').text = self.data.LordName		
	end

	self.setSelect = function(b)
		self.selectFlag:SetActive(b)
	end

	initUI()
	return self
end
local function CreateLockItemUI(template, data)
	local self = CreateScrollviewItem(template)
	local lockImg = self.transform:FindChild('lockImg')
	if data.index % 2 == 0 then
		lockImg.transform.localScale = Vector3.New(-1, 1, 1)
	else
		lockImg.transform.localScale = Vector3.New(1, 1, 1)
	end  
	return self
end

local itemTable = require "Logic/Scheme/common_item"
local function CreateDropItemUI(template, data)
	local self = CreateScrollviewItem(template)

	self.isSureText = self.transform:FindChild('@textprobability')
	self.equipmentdrop = self.transform:FindChild('@equipmentdrop')
	if data.isSure == true then
		self.isSureText:GetComponent('TextMeshProUGUI').text = "必掉"
	else
		self.isSureText:GetComponent('TextMeshProUGUI').text = "概率"
	end

	local item = itemTable.Item[data.itemID]
	if item then
		self.equipmentdrop:GetComponent('Image').sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s", item.Icon))
	else
		print("error!!! not find item id="..data.itemID)
	end
	self.transform.localScale = Vector3.New(0.8, 0.8, 0.8)
	ClickEventListener.Get(self.equipmentdrop.gameObject).onClick = function()
		BagManager.ShowItemTips({item_data={id=data.itemID}},true)
	end
	return self
end

local function CreateChapterRewardItemUI(template, data, width)
	local self = CreateScrollviewItem(template)
	self.progressImg = self.transform:FindChild('@Progressrewardarticle').gameObject
	self.boxImg = self.transform:FindChild('@treasurechest').gameObject
	self.heightLightImg = self.transform:FindChild('@treasurechestlight').gameObject
	self.numText = self.transform:FindChild('@textSnumber').gameObject
	self.textCurSnum = self.transform:FindChild('@textCurSnum').gameObject
	self.divideSmall = self.transform:FindChild('imgSmall').gameObject
	self.dividebig = self.transform:FindChild('imgBig').gameObject
	self.divideSmall:SetActive(true)
	self.dividebig:SetActive(true)

	self.numText:GetComponent('TextMeshProUGUI').text = data.SnumText
	local layout = self.gameObject:GetComponent('LayoutElement')
	layout.preferredWidth = width

	local adjustCurPos = function(num)
		if num <= 0 then
			return
		end
		local posX = (num/5) * width - width/2
		local posOld = self.textCurSnum.transform.localPosition
		self.textCurSnum.transform.localPosition = Vector3.New(posX, posOld.y, posOld.z)
		local shwoNum = num
		if data.SIndex == 2 then
			shwoNum = num + 5
		elseif data.SIndex == 3 then
			shwoNum = num + 15
		end
		self.textCurSnum:GetComponent('TextMeshProUGUI').text = shwoNum .. "S"
	end

	local onOpenClick = function()
		if data.RewardState == ChapterRewardState.CanButNotGet then
			MainDungeonManager.RequestChapterReward(data.chapter, data.SIndex)
		elseif data.RewardState == ChapterRewardState.GetOver then 
			UIManager.PushView(ViewAssets.Sweep,nil, data.Rewards,'AutoGenerate/Sweep/rewards', "获得" .. data.Snum .. "个S，可以获得以下奖励", false, "已经领取")
		elseif data.RewardState == ChapterRewardState.CannotGet then
			UIManager.PushView(ViewAssets.Sweep,nil, data.Rewards,'AutoGenerate/Sweep/rewards', "获得" .. data.Snum .. "个S，可以获得以下奖励", false, "不可领取")
		end
	end

	self.updateUI = function()
		-- local boxImg = ''
		if data.SIndex == 1 then
			boxImg = Box_1_icon
			self.dividebig:SetActive(false)
		elseif data.SIndex == 2 then
			boxImg = Box_2_icon
			self.dividebig:SetActive(false)
		elseif data.SIndex == 3 then
			boxImg = Box_3_icon
			self.divideSmall:SetActive(false)
		end
		if data.RewardState == ChapterRewardState.CanButNotGet then
			self.heightLightImg:SetActive(true)
			self.progressImg:GetComponent('Image').fillAmount = 1
			self.boxImg:GetComponent('Image').sprite = ResourceManager.LoadSprite(boxImg)
			-- self.boxImg:GetComponent('Image').color = Color.New(1,0,0)
		elseif data.RewardState == ChapterRewardState.GetOver then
			self.progressImg:GetComponent('Image').fillAmount = 1
			self.heightLightImg:SetActive(false)	
			self.boxImg:GetComponent('Image').sprite = ResourceManager.LoadSprite(Box_open)
		elseif data.RewardState == ChapterRewardState.CannotGet then
			self.heightLightImg:SetActive(false)
			if data.SIndex == 1 then
				self.progressImg:GetComponent('Image').fillAmount = data.currentSnum/5
				adjustCurPos(data.currentSnum)
			elseif data.SIndex == 2 then
				self.progressImg:GetComponent('Image').fillAmount = (data.currentSnum - 5)/5
				adjustCurPos(data.currentSnum - 5)
			elseif data.SIndex == 3 then
				self.progressImg:GetComponent('Image').fillAmount = (data.currentSnum - 5 - 10)/5
				adjustCurPos(data.currentSnum - 5 - 10)
			end
			self.boxImg:GetComponent('Image').sprite = ResourceManager.LoadSprite(boxImg)
			-- self.boxImg:GetComponent('Image').color = Color.New(1,1,0)
		end
	end
	
	local create = function()
		ClickEventListener.Get(self.boxImg).onClick = onOpenClick
    	UIUtil.AddButtonEffect(self.boxImg, nil, nil)
	end

	self.updateUI()
	create()
	return self
end

-- 挑战UI
local function CreateChallengeUICtrl()
	local self = CreateCtrlBase()
	self.lordlist = {}
	---------- 副本列表 ----------
	local chapterTemplate = nil
	local dungeonTemplate = nil
	local lockTemplate = nil
	local chapterRewardTemplate = nil
	local chapterItems = {}
	local selectDungeonItem = nil

	----------- 章节掉落表 -------
	local chapterRewardItems = {}
	local clearChapterRewardItems = function()
		for k, v in ipairs(chapterRewardItems) do			
			DestroyScrollviewItem(v)
		end
		chapterRewardItems = {}		
	end
	local updateChapterRewardUI = function()
		local dungeonWidth = dungeonTemplate:GetComponent('LayoutElement').preferredWidth
		local chapterWidth = chapterTemplate:GetComponent('LayoutElement').preferredWidth

		local chapters = MainDungeonManager.dungeons.chapters
		for chapter, chapterData in ipairs(chapters) do
			local width = (chapterData.dungeonNum * dungeonWidth + chapterWidth)/3
			for i = 1, #chapterData.chapterRewards do
				local rewardData = chapterData.chapterRewards[i]
				local rewardItem = CreateChapterRewardItemUI(chapterRewardTemplate, rewardData, width)
				table.insert(chapterRewardItems, rewardItem)
			end			
		end
	end
	------------------------------

	----------- 副本掉落列表 ---------
	local dropTemplate = nil
	local dropItems = {}
	------------------------------
	local clearDropsItem = function()
		for k, v in ipairs(dropItems) do			
			DestroyScrollviewItem(v)
		end
		dropItems = {}
	end

	local updateDropUI = function()
		clearDropsItem()
		if selectDungeonItem then
			for k, v in ipairs(selectDungeonItem.data.drops) do
				local item = CreateDropItemUI(dropTemplate, v)
				table.insert(dropItems, item)
			end
		end
	end

	local updateMainUI = function()
		if selectDungeonItem then
			self.view.txtDesc:GetComponent('TextMeshProUGUI').text = selectDungeonItem.data.ChapterDes
			self.view.txtSectionTitle:GetComponent('TextMeshProUGUI').text = selectDungeonItem.data.Name
			self.view.sectionName:GetComponent('TextMeshProUGUI').text = "第" .. selectDungeonItem.data.index .. "节"
			
			self.view.txtRemainCount:GetComponent('TextMeshProUGUI').text = MainDungeonManager.dungeons.dayCount.."/"..
			MainDungeonManager.dungeons.totalDayCount
		end
	end
	------------------------------
	local updateChapterUI = function()
		local chapters = MainDungeonManager.dungeons.chapters
		local dungeonItem = nil
		local defaultSelect = nil
		for chapter, chapterData in ipairs(chapters) do
			chapterItems[chapter] = {}
			local chapterItem = CreateChapterItemUI(chapterTemplate, chapterData)
			table.insert(chapterItems[chapter], chapterItem)

			for id, dungeon in ipairs(chapterData.dungeons) do
				if dungeon.bestGrade == DungeonGrade.Locked then
					dungeonItem = CreateLockItemUI(lockTemplate, dungeon)
				else
					dungeonItem = CreateDungeonItemUI(dungeonTemplate, dungeon)
					defaultSelect = dungeonItem
				end
				table.insert(chapterItems[chapter], dungeonItem)
			end
		end

		if defaultSelect and not selectDungeonItem then
			self.selectDungeon(defaultSelect)
		end
	end
	local updateLordInfo = function(lordData)		
		local chapters = MainDungeonManager.dungeons.chapters
		for chapter, chapterData in ipairs(chapters) do
			for _, dungeon in ipairs(chapterData.dungeons) do
				if lordData[dungeon.ID] then
					dungeon.LordName = lordData[dungeon.ID].actor_name
				else
					dungeon.LordName = ''
				end
			end
			for _, dungeonItem in ipairs(chapterItems[chapter]) do
				if dungeonItem.updateLordInfo then
					dungeonItem.updateLordInfo()
				end
			end
		end
	end
	local clearChapterItems = function()	
		for chapter, items in ipairs(chapterItems) do
			for i = 1, #items do
				DestroyScrollviewItem(items[i])
			end
		end
		chapterItems = {}
		selectDungeonItem = nil
	end
	self.selectDungeon = function(select)
		if selectDungeonItem then
			selectDungeonItem.setSelect(false)
		end
		select.setSelect(true)
		selectDungeonItem = select
		updateDropUI()
		updateMainUI()
		-- print("select index:" .. selectDungeonItem.data.index)
	end
	self.selectDungeonById = function(dungeonId)
		for chapter, items in ipairs(chapterItems) do
			for i = 1, #items do
				if items[i].data and items[i].data.ID == dungeonId then
					self.selectDungeon(items[i])
					return
				end
			end
		end
	end
	------------------------------
	local closeClick = function()
		self.close()
	end
	local helpClick = function()
		UIManager.PushView(ViewAssets.TipsUI,nil, '主线副本说明\n1.跟随主线推进可以完成对应的剧情副本。\n2.需要完成对应的剧情副本才可挑战对应的精英副本。\n3.挑战主线副本需要消耗体力。\n4.提升VIP等级可以增加体力购买次数。\n5.每个章节积累一定S级数量后，可以在章节的星级宝箱内获得丰厚的奖励。')
	end
    
	local buyEneryClick = function()
        local price = EnergyManager.GetPrice()
        local num = EnergyManager.GetBuyNum()
        local str = "确定要用".. price .."元宝购买".. num .."体力\n今日已经购买" .. EnergyManager.BuyCount.. "次" 
		UIManager.ShowDialog(str,'确定','取消',function() MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_TILI_BUY, {}) end)
	end
    
	local enterDungeonHandler = function()
		if selectDungeonItem then
			if EnergyManager.IsEnoughConsume() == false then
                buyEneryClick()
				return
			end
			if MainDungeonManager.GetDayRestCount() <= 0 then
				UIManager.ShowNotice("今日次数用完了")
				return
			end
			MainDungeonManager.RequstStartDungeon(selectDungeonItem.data)
			-- self.close()
		end
	end

	local enterClick = function()
		if ArenaManager.IsOnMatching() then
            UIManager.ShowDialog(uitext[1135003].NR, uitext[1135004].NR, uitext[1135005].NR, nil, function()
                ArenaManager.RequestCancelMatchMixFight()
                enterDungeonHandler()
            end)
        else
            enterDungeonHandler()
        end
	end

	local sweepClick = function()
		if selectDungeonItem then
			MainDungeonManager.RequestSweepDungeon(selectDungeonItem.data.ID)
		end
	end
	local initUI = function()
		chapterTemplate = self.view.ChapterItem
		dungeonTemplate = self.view.sectionItem
		dropTemplate = self.view.rewardItemTemplate
		lockTemplate = self.view.sectionLock
		chapterRewardTemplate = self.view.sRewardItem

		chapterTemplate:SetActive(false)
		dungeonTemplate:SetActive(false)
		dropTemplate:SetActive(false)
		lockTemplate:SetActive(false)
		chapterRewardTemplate:SetActive(false)

		self.view.txtDesc:GetComponent('TextMeshProUGUI').text = ""
		self.view.txtSectionTitle:GetComponent('TextMeshProUGUI').text = ''
		self.view.sectionName:GetComponent('TextMeshProUGUI').text = ''
		self.view.texthpdigital:GetComponent('TextMeshProUGUI').text = EnergyManager.currentEnergy
		self.view.txtSweepingEnergy:GetComponent('TextMeshProUGUI').text = EnergyManager.GetConsume()
		self.view.textEnterEnergy:GetComponent('TextMeshProUGUI').text = EnergyManager.GetConsume()	
	end

	local onEnergyInfoUpdate = function()
		self.view.texthpdigital:GetComponent('TextMeshProUGUI').text = EnergyManager.currentEnergy
	end
	local onDungeonInfoUpdate = function(change)
		if change == 'ChapterInfo' then
			self.view.txtRemainCount:GetComponent('TextMeshProUGUI').text = MainDungeonManager.dungeons.dayCount.."/"..
			MainDungeonManager.dungeons.totalDayCount
		elseif change == 'ChapterReward' then
			clearChapterRewardItems()
			updateChapterRewardUI()
		end
	end
	local OnDungeonHegemon = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
		else
			if data.name_table then
				updateLordInfo(data.name_table)
			end
		end
	end
    local TeamDungeonUI = function()
        self.close()
        UIManager.GetCtrl(ViewAssets.TeamDungeonUI).OpenUI()
    end
	self.onLoad = function()
        ClickEventListener.Get(self.view.btnclose).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnclose, nil, nil)
        ClickEventListener.Get(self.view.btnEnter).onClick = enterClick
        UIUtil.AddButtonEffect(self.view.btnEnter, nil, nil)
        ClickEventListener.Get(self.view.btnAddEnergy).onClick = buyEneryClick
        UIUtil.AddButtonEffect(self.view.btnEnter, nil, nil)
        ClickEventListener.Get(self.view.btnSweeping).onClick = sweepClick
        UIUtil.AddButtonEffect(self.view.btnSweeping, nil, nil)
        ClickEventListener.Get(self.view.btnHelp).onClick = helpClick
        UIUtil.AddButtonEffect(self.view.btnHelp, nil, nil)
        self.AddClick(self.view.btnTeam,TeamDungeonUI)
        EnergyManager.AddListener(onEnergyInfoUpdate)
        MainDungeonManager.AddListener(onDungeonInfoUpdate)

        initUI()
		updateChapterUI()
		updateChapterRewardUI()

		local chapterContent = self.view.chaptersSv.transform:FindChild('Viewport/Content')
		local rewardContent = self.view.chapterRewardSv.transform:FindChild('Viewport/Content')
		UIUtil.AddScrollListener(self.view.chaptersSv, function(vec2)
			rewardContent.transform.localPosition = chapterContent.transform.localPosition
		end) 

		-- chapter_id
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, OnDungeonHegemon)
		local chapter_ids = {}
		for chapter, chapterData in ipairs(MainDungeonManager.dungeons.chapters) do
			table.insert(chapter_ids, chapter)
		end
		self.RequestHegemon(chapter_ids)
	end
	self.RequestHegemon = function(chapter_ids)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_DUNGEON_HEGEMON, {chapter_ids = chapter_ids})			
	end

	self.onUnload = function()
		clearChapterItems()
		clearDropsItem()
		clearChapterRewardItems()
		EnergyManager.RemoveListener(onEnergyInfoUpdate)
        MainDungeonManager.RemoveListener(onDungeonInfoUpdate)
        UIUtil.RemoveAllScrollListener(self.view.chaptersSv)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GET_DUNGEON_HEGEMON, OnDungeonHegemon)
	end

	self.onActive = function()	
		onDungeonInfoUpdate()
		onEnergyInfoUpdate()	
	end

	self.onDeactive = function()
	end

	return self
end

return CreateChallengeUICtrl()