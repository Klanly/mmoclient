--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/3/18
--
require "UI/Controller/LuaCtrlBase"

local function CreateMenuCtrl(menu, defaultPos)							--menu
	local self = CreateObject()
	local view = menu
	local duration = 0.2
	self.defaultPos = defaultPos
	
	self.SetAnchoredPosition = function(toPos, isDelay)
		if isDelay then
			BETween.anchoredPosition(view.gameObject, duration, toPos)
		else
			view.gameObject:GetComponent("RectTransform").anchoredPosition = toPos
		end
	end

	self.SetDefaultPos = function(isDelay)
		if isDelay then
			BETween.anchoredPosition(view.gameObject, duration, self.defaultPos)
		else
			view.gameObject:GetComponent("RectTransform").anchoredPosition = self.defaultPos
		end
	end
	return self
end

local function CreateMenuItemUI(itemDatas)				--menuitem
	local self = CreateObject()
	self.isExpand = true
    self.duration = 0.2

	self.CollapseImmediately = function()
        for k, v in pairs(itemDatas) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = v.defaultPos
            v.gameObject:SetActive(false)
        end
        self.isExpand = false
    end
	
    self.ExpandImmediately = function()
        for k, v in pairs(itemDatas) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = v.toPos
			v.gameObject:SetActive(true)
        end
        self.isExpand = true
    end
	
    self.Collapse = function() 
        for k, v in pairs(itemDatas) do
            BETween.anchoredPosition(v.gameObject, self.duration, v.defaultPos).onFinish = function()
                v.gameObject:SetActive(false)
            end
        end
        self.isExpand = false
    end

    self.Expand = function() 
        for k, v in pairs(itemDatas) do
            v.gameObject:SetActive(true)
            BETween.anchoredPosition(v.gameObject, self.duration, v.toPos)
        end
		
        self.isExpand = true
    end

    self.Switch = function(isImmediately)
		if isImmediately then
			if self.isExpand then
				self.ExpandImmediately()
			else
				self.CollapseImmediately()
			end
		else
			if self.isExpand then
				self.Collapse()
			else
				self.Expand()
			end
		end
    end
	
	return self
end

local function CreateRankContentUI(view)		--排行榜内容显示界面
	local self = CreateObject()
	local hideNameToggle
	local selectHideName = false
	local playerRankName = {'total_power', 'fight_power', 'equipment_score', 'level', 'wealth', 'war_rank', 'present_friend_flower_count', 'receive_friend_flower_count'}
	local playerVocation = {nil, 1, 2, 3, 4}
	local petStarName = {'pet_score'}
	local petQualName = {'physic_attack_quality','magic_attack_quality', 'physic_defence_quality', 'magic_defence_quality'}
	local petInitName = {'base_physic_attack', 'base_magic_attack','base_physic_defence', 'base_magic_defence'}
	local rankName = {'total_power', 'faction_fund'}
	local playerItemTitle = {'排名', '玩家名称', '职业', '帮会名称'}
	local petItemTitle = {'排名', '玩家名字', '等级', '宠物类型'}
	local unionItemTitle = {'排名', '帮会名称', '等级', '帮主名字'}
	local playerMenuItemName = {'综合实力', '战斗力', '装备', '等级', '财富', '战阶', '鲜花'}
	local petMenuItemName = {'宠物星级', '宠物资质', '宠物初始资质'}
	local unionMenuItemName = {'综合实力', '帮会财富'}
	local playerVocationTitle = {'全部', '谪仙', '昆仑', '流云'} --, '天弓'
	local flowerTitle = {'送花(历)', '收花(历)'}
	local petStarTitle  = {'全部'}
	local petQualTitle  = {'物攻资质', '法攻资质', '物防资质', '法防资质'}
	local petInitTitle  = {'初始物攻', '初始法攻', '初始物防', '初始法防'}
	local unionTitle = {'全部'}
	local rankingTopType = 1
	local rankingMiddleType = 1
	local rankingSmallType = 1
	local rankingScrolview
	local rankDatas
	
	local SetRankData = function(data)
		local dataNum = #data
		for i = 1, 5 do
			if dataNum >= i then
				view['infotext' .. i]:GetComponent('TextMeshProUGUI').text = data[i]
				view['toggle' .. i]:SetActive(true)
			else
				view['toggle' .. i]:SetActive(false)
			end
		end
	end
	
	local RequestJoinFaction = function(data) --申请加入帮会
		local reqData = {}
		reqData.func_name = 'on_apply_join_faction'
		reqData.faction_id = data.faction_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, reqData)
	end
	
	self.ApplyJoinFactionRet = function(data)	--申请加入帮会反馈
		if data.result == 0 then
			UIManager.ShowNotice('已向该帮会发送申请，请等待审核')
		end
	end
	
	local OnItemSelect = function(itemDatas, pos)  --成员选中处理
		if itemDatas == nil then
			return
		end
		
		if itemDatas.rankingTopType == 1 and itemDatas.actor_id then       	--个人信息
            ContactManager.QuestPlayerInfo(itemDatas.actor_id,pos)
		elseif itemDatas.rankingTopType == 3 then	--帮会信息
			local data = {}
			data.faction_id = itemDatas.faction_id
			data.actionFunc = RequestJoinFaction
			data.pos = pos
			UIManager.PushView(ViewAssets.IndependentBtnUI,nil, data)
		end
	end
	
	local function itemUpdate(itemGo, index)
		local dataIndex = index + 1
		local rankingMemberUICtrl = itemGo:GetComponent('LuaBehaviour').luaTable
		local myData = rankDatas.rank_list[dataIndex]
		if myData == nil then
			return
		end
		
		rankingMemberUICtrl.SelectAction = OnItemSelect
        
		local itemDatas = myData
		itemDatas.rankingTopType = rankingTopType
		itemDatas.rank = dataIndex

		if rankingTopType == 1 then
			if myData.vocation then
				itemDatas.vocation = myData.vocation
				itemDatas.item2 = playerVocationTitle[myData.vocation + 1]
			end
		
			if myData.faction_name then
				itemDatas.item3 = myData.faction_name
			end
			
			itemDatas.cameIndex = myData.country
			itemDatas.item1 = myData.actor_name
			itemDatas.item4 = myData[rankDatas.rank_name]
		elseif rankingTopType == 2 then
			itemDatas.cameIndex = myData.owner_country
			itemDatas.item1 = myData.owner_name
			itemDatas.item2 = myData.pet_level
			itemDatas.item3 = myData.pet_name
			
			itemDatas.item4 = myData[rankDatas.rank_name]
			if rankingMiddleType == 1 then --宠物星级，需要除以100
				itemDatas.item4 = math.floor(itemDatas.item4 / 100)
			end
		elseif rankingTopType == 3 then
			if myData then
				itemDatas.item1 = myData.faction_name
				itemDatas.item2 = myData.faction_level
				itemDatas.item3 = myData.chief_name
				itemDatas.item4 = myData[rankDatas.rank_name]
			end
		end

		rankingMemberUICtrl.SetData(itemDatas)
    end
	
	self.OnItemClick = function(bigType, middleType, smallType)
		rankingTopType = bigType
		rankingMiddleType = middleType
		rankingSmallType = smallType
	
		if rankingTopType == 1 then		--个人信息排行榜
			for i = 1, 4 do
				view['itemtitle' .. i]:GetComponent('TextMeshProUGUI').text = playerItemTitle[i]
			end
			view.itemtitle5:GetComponent('TextMeshProUGUI').text = playerMenuItemName[rankingMiddleType]
			
			if rankingMiddleType == 7 then
				SetRankData(flowerTitle)
			else
				SetRankData(playerVocationTitle)
			end
			
			view.hidename:SetActive(true)
		elseif rankingTopType == 2 then
			if rankingMiddleType == 1 then
				SetRankData(petStarTitle)
			elseif rankingMiddleType == 2 then
				SetRankData(petQualTitle)
			elseif rankingMiddleType == 3 then
				SetRankData(petInitTitle)
			end
			
			for i = 1, 4 do
				view['itemtitle' .. i]:GetComponent('TextMeshProUGUI').text = petItemTitle[i]
			end
			view.itemtitle5:GetComponent('TextMeshProUGUI').text = petMenuItemName[rankingMiddleType]
			view.hidename:SetActive(true)
		elseif rankingTopType == 3 then
			SetRankData(unionTitle)
			for i = 1, 4 do
				view['itemtitle' .. i]:GetComponent('TextMeshProUGUI').text = unionItemTitle[i]
			end
			view.itemtitle5:GetComponent('TextMeshProUGUI').text = unionMenuItemName[rankingMiddleType]
			view.hidename:SetActive(false)
		end
		
		local toggle = view['toggle' .. rankingSmallType]:GetComponent('UnityEngine.UI.Toggle')
		if not toggle.isOn then
			toggle.isOn = true
			toggle.group:NotifyToggleOn(toggle)
		else
			self.OnRankingTypeClick(rankingSmallType, true)
		end
	end
	
	self.OnRankingTypeClick = function(index, flag)   --排行榜小类型
		if flag then
			rankingSmallType = index
			if rankingTopType == 1 then
				local data = {}
				data.func_name = 'on_get_player_rank_list'
				data.start_index = 1
				data.end_index = 100
				if rankingMiddleType == 7 then
					data.rank_name = playerRankName[rankingMiddleType + index - 1]
				else
					data.rank_name = playerRankName[rankingMiddleType]
					data.vocation = playerVocation[index]
				end
				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			elseif rankingTopType == 2 then
				local data = {}
				data.func_name = 'on_get_total_pet_rank_list'
				data.start_index = 1
				data.end_index = 100
				
				if rankingMiddleType == 1 then
					data.rank_name = petStarName[index]
				elseif rankingMiddleType == 2 then
					data.rank_name = petQualName[index]
				elseif rankingMiddleType == 3 then
					data.rank_name = petInitName[index]
				end

				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			elseif rankingTopType == 3 then
				local data = {}
				data.func_name = 'on_get_faction_rank_list'
				data.start_index = 1
				data.end_index = 100
				data.rank_name = rankName[rankingMiddleType]
				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			end
		end
	end
	
	local SetMyRank = function(data)						--设置自己信息
		local selfData = data.self_data
		if not selfData then
			return
		end
		
		view.maybe:SetActive(data.is_hide)
		if rankingTopType == 1 then
			view.item1:GetComponent('TextMeshProUGUI').text = selfData.actor_name
			view.item4:GetComponent('TextMeshProUGUI').text = selfData[data.rank_name]
			view.item3:GetComponent('TextMeshProUGUI').text = selfData.faction_name
			if selfData.vocation then
				view.item2:GetComponent('TextMeshProUGUI').text = playerVocationTitle[selfData.vocation + 1]
			end
		
			if selfData.country == 1 then  		--九黎
				view.campIcon1:SetActive(true)
				view.campIcon2:SetActive(false)
			elseif selfData.country == 2 then 	--炎黄
				view.campIcon1:SetActive(false)
				view.campIcon2:SetActive(true)
			else
				view.campIcon1:SetActive(false)
				view.campIcon2:SetActive(false)
			end
		elseif rankingTopType == 2 then
		
			if selfData.owner_country == 1 then  		--九黎
				view.campIcon1:SetActive(true)
				view.campIcon2:SetActive(false)
			elseif selfData.owner_country == 2 then 	--炎黄
				view.campIcon1:SetActive(false)
				view.campIcon2:SetActive(true)
			else
				view.campIcon1:SetActive(false)
				view.campIcon2:SetActive(false)
			end
		
			view.item1:GetComponent('TextMeshProUGUI').text = selfData.owner_name
			view.item2:GetComponent('TextMeshProUGUI').text = selfData.pet_level
			view.item3:GetComponent('TextMeshProUGUI').text = selfData.pet_name
			
			local score = selfData[data.rank_name]
			if score and rankingMiddleType == 1 then --宠物星级，需要除以100
				score = math.floor(score / 100)
			end
			view.item4:GetComponent('TextMeshProUGUI').text = score

		elseif rankingTopType == 3 then
			view.campIcon1:SetActive(false)
			view.campIcon2:SetActive(false)
			
			view.item1:GetComponent('TextMeshProUGUI').text = selfData.faction_name
			view.item2:GetComponent('TextMeshProUGUI').text = selfData.faction_level
			view.item3:GetComponent('TextMeshProUGUI').text = selfData.chief_name
			view.item4:GetComponent('TextMeshProUGUI').text = selfData[data.rank_name]
		end
		
		local selfIndex = selfData.self_index
		view.imgBeyondlist:SetActive(false)
		view.First:SetActive(false)
		view.second:SetActive(false)
		view.third:SetActive(false)
		view.rankIndex:SetActive(false)
		
		if not selfIndex then
			view.imgBeyondlist:SetActive(true)
		else
			if selfIndex == 1 then
				view.First:SetActive(true)
			elseif selfIndex == 2 then
				view.second:SetActive(true)
			elseif selfIndex == 3 then
				view.third:SetActive(true)
			else
				view.rankIndex:GetComponent('TextMeshProUGUI').text = selfIndex
				view.rankIndex:SetActive(true)
			end
		end
	end
	
	self.GetPlayerRankListRet = function(data)			--获取人物排行榜的服务器反馈
		rankDatas = data
		SetMyRank(data)
		rankingScrolview:UpdateData(#rankDatas.rank_list, itemUpdate)
		selectHideName = data.is_hide
		hideNameToggle.isOn = data.is_hide
		selectHideName = hideNameToggle.isOn
	end
	
	self.GetTotalPetRankListRet = function(data)		--获取宠物总排行榜的服务器反馈
		rankDatas = data
		SetMyRank(data)
		rankingScrolview:UpdateData(#rankDatas.rank_list, itemUpdate)
		selectHideName = data.is_hide
		hideNameToggle.isOn = data.is_hide
	end
	
	self.GetFactionRankListRet = function(data)			--获取帮会排行榜的服务器反馈
		rankDatas = data
		SetMyRank(data)
		rankingScrolview:UpdateData(#rankDatas.rank_list, itemUpdate)
		selectHideName = data.is_hide
		hideNameToggle.isOn = data.is_hide
	end
		
	self.HideMyNameRet = function(data)					--人物榜隐姓埋名的服务器反馈
		view.textnoname:GetComponent('TextMeshProUGUI').text = '[当前已有' .. data.hide_number .. '名玩家隐姓埋名]'
	end
	
	self.GetHideNameNumber = function(data)    			--获取隐姓埋名人数
		--data.hide_number
		--data.rank_name
		--data.class
		--data.vocation
		--if (rankingTopType == 1 and data.class == 'player' and  then
		view.textnoname:GetComponent('TextMeshProUGUI').text = '[当前已有' .. data.hide_number .. '名玩家隐姓埋名]'
		--hide_number：int，当前隐藏人数
		--rank_name：string，排行榜名称
		--class:string, "player"人物榜， "pet"宠物榜
		--vocation:int,职业，为nil时为总榜
	end
	
	self.HideMyPetNameRet = function(data)		--获取隐藏宠物
		view.textnoname:GetComponent('TextMeshProUGUI').text = '[当前已有' .. data.hide_number .. '名玩家隐姓埋名]'
	end
	
	local OnHideName = function(flag)
		if flag ~= selectHideName then
			if rankingTopType == 1 then		--英雄信息隐姓埋名
				local data = {}
				data.func_name = 'on_hide_my_name'
				data.rank_name = rankDatas.rank_name
				data.vocation = rankDatas.vocation
				data.is_hide = flag
				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			elseif rankingTopType == 2 then --宠物隐姓埋名
				local data = {}
				data.func_name = 'on_hide_my_pet_name'
				data.rank_name = rankDatas.rank_name
				data.is_hide = flag
				MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			end
		end
		selectHideName = flag
	end
	
	self.onLoad = function()
		for i  = 1, 5 do
			UIUtil.AddToggleListener(view['toggle'..i].gameObject, function(flag) self.OnRankingTypeClick(i, flag) end)
		end
		UIUtil.AddToggleListener(view.frame1.gameObject, function(flag) OnHideName(flag) end)
		hideNameToggle = view.frame1:GetComponent('UnityEngine.UI.Toggle')
		rankingScrolview =  view.RankListScrollview:GetComponent('UIMultiScroller')
		rankingScrolview:Init(view.rankitem, 1281, 76, 0, 15, 1)
		selectHideName = hideNameToggle.isOn
		
		MessageRPCManager.AddUser(self, 'GetPlayerRankListRet')
		MessageRPCManager.AddUser(self, 'GetTotalPetRankListRet')
		MessageRPCManager.AddUser(self, 'HideMyNameRet')
		MessageRPCManager.AddUser(self, 'GetFactionRankListRet')
		MessageRPCManager.AddUser(self, 'GetHideNameNumber')
		MessageRPCManager.AddUser(self, 'ApplyJoinFactionRet')
		MessageRPCManager.AddUser(self, 'HideMyPetNameRet')
	end

    self.onUnload = function()
		MessageRPCManager.RemoveUser(self, 'GetPlayerRankListRet')
		MessageRPCManager.RemoveUser(self, 'GetTotalPetRankListRet')
		MessageRPCManager.RemoveUser(self, 'HideMyNameRet')
		MessageRPCManager.RemoveUser(self, 'GetFactionRankListRet')
		MessageRPCManager.RemoveUser(self, 'GetHideNameNumber')
		MessageRPCManager.RemoveUser(self, 'ApplyJoinFactionRet')
		MessageRPCManager.RemoveUser(self, 'HideMyPetNameRet')
		
		for i  = 1, 5 do
			UIUtil.RemoveToggleListener(view['toggle'..i].gameObject)
		end
		UIUtil.RemoveToggleListener(view.frame1.gameObject)
		
		rankingTopType = 1					--排行榜大类别
		rankingMiddleType	= 1				--排行榜中类别
		rankingSmallType = 1 				--排行榜小类别
	end
	
	return self
end

local function CreateRankMenuUICtrl(view, rankContent)		--控制排行menu
	local self = CreateObject()
	local menuItems = {}
	local menuItemsDatas = {}
	local menuItemsGroup = {{toggleGroup, toggles}, {toggleGroup, toggles}, {toggleGroup, toggles}}
	local menu = {}
	local menuDatas = {Vector2.New(0, 0), Vector2.New(0, -709), Vector2.New(0, -1078)}
	local menuHeight = 113
	local menuItemHeight = 85
	local gridLayoutGroup
	local rankingTopType = 1				--排行榜大类别
	local rankingMiddleType	= 1				--排行榜中类别
	local rankingSmallType = 1 				--排行榜小类别
	
	local OnMenuClick = function(index, flag)
		if flag then
			rankingTopType = index
			local selectMenu = menuItems[index]
			local defaultPos1 = menu[1].defaultPos
			local defaultPos2 = menu[2].defaultPos
			local defaultPos3 = menu[3].defaultPos
			--local heightDiff =  111
			local cellSize = gridLayoutGroup.cellSize
			if selectMenu.isExpand then
				local toPos2 = Vector2.New(0, 0)
				toPos2.x = defaultPos2.x
				toPos2.y = defaultPos1.y - menuHeight
				local toPos3 = Vector2.New(0, 0)
				toPos3.x = defaultPos3.x
				toPos3.y = toPos2.y - menuHeight
				menu[2].SetAnchoredPosition(toPos2, true)
				menu[3].SetAnchoredPosition(toPos3, true)
				
				local normalSize = Vector2.New(cellSize.x, cellSize.y)
				normalSize.y =  menuHeight * 3
				gridLayoutGroup.cellSize = normalSize
			else
				if index == 1 then

					menu[2].SetDefaultPos(true)
					local toPos3 = Vector2.New(0, 0)
					toPos3.x = defaultPos3.x
					toPos3.y = defaultPos2.y - menuHeight
					menu[3].SetAnchoredPosition(toPos3, true)
					
					local normalSize = Vector2.New(cellSize.x, cellSize.y)
					normalSize.y =  menuHeight * 3 + menuItemHeight * 7
					gridLayoutGroup.cellSize = normalSize
				elseif index == 2 then					
					local toPos2 = Vector2.New(0, 0)
					toPos2.x = defaultPos2.x
					toPos2.y = defaultPos1.y - menuHeight
					menu[2].SetAnchoredPosition(toPos2, false)
					
					local toPos3 = Vector2.New(0, 0)
					toPos3.x = defaultPos3.x
					toPos3.y = toPos2.y  - menuHeight - menuItemHeight * 3
					menu[3].SetAnchoredPosition(toPos3, true)
					
					local normalSize = Vector2.New(cellSize.x, cellSize.y)
					normalSize.y =  menuHeight * 3 + menuItemHeight * 3
					gridLayoutGroup.cellSize = normalSize

				elseif index == 3 then
					local toPos2 = Vector2.New(0, 0)
					toPos2.x = defaultPos2.x
					toPos2.y = defaultPos1.y - menuHeight
					menu[2].SetAnchoredPosition(toPos2, false)
					
					local toPos3 = Vector2.New(0, 0)
					toPos3.x = defaultPos3.x
					toPos3.y = toPos2.y - menuHeight
					menu[3].SetAnchoredPosition(toPos3, false)
					
					local normalSize = Vector2.New(cellSize.x, cellSize.y)
					normalSize.y =  menuHeight * 3 + menuItemHeight * 2
					gridLayoutGroup.cellSize = normalSize
				end
			end
			
			selectMenu.Switch()

			local group = menuItemsGroup[index]
			local toggle = group.toggles[1]
			if not toggle.isOn then
				toggle.isOn = true
				group.toggleGroup:NotifyToggleOn(toggle)
			else
				self['OnMenuItem' .. index .. 'Click'](1, true)
			end
		else
			menuItems[index].CollapseImmediately()
		end
	end

	self.OnMenuItem1Click = function(index, flag)   --个人信息menuitem
		if flag then
			rankingMiddleType = index
			rankingSmallType = 1
			rankContent.OnItemClick(rankingTopType, rankingMiddleType, rankingSmallType)
		end
	end
	
	self.OnMenuItem2Click = function(index, flag)
		if flag then
			rankingMiddleType = index
			rankingSmallType = 1
			rankContent.OnItemClick(rankingTopType, rankingMiddleType, rankingSmallType)
		end
	end
	
	self.OnMenuItem3Click = function(index, flag)
		if flag then
			rankingMiddleType = index
			rankingSmallType = 1
			rankContent.OnItemClick(rankingTopType, rankingMiddleType, rankingSmallType)
		end
	end
	
	local InitMenuItemDatas = function()
		local initY = 0
		--local hight = 90
		local defaultPos = menuItemHeight
		local menuItem1Datas = {}
		for i = 1, 7 do
			local itemData = {}
			itemData.gameObject = view['menu1item' .. i]
			itemData.defaultPos = Vector2.New(0, defaultPos)
			itemData.toPos = Vector2.New(0, initY)
			table.insert(menuItem1Datas, itemData)
			initY = initY - menuItemHeight
		end
		menuItemsDatas[1] = menuItem1Datas
		
		local initY = 0
		local defaultPos = menuItemHeight
		local menuItem2Datas = {}
		for i = 1, 3 do
			local itemData = {}
			itemData.gameObject = view['menu2item' .. i]
			itemData.defaultPos = Vector2.New(0, defaultPos)
			itemData.toPos = Vector2.New(0, initY)
			table.insert(menuItem2Datas, itemData)
			initY = initY - menuItemHeight
		end
		menuItemsDatas[2] = menuItem2Datas

		local initY = 0
		local defaultPos = menuItemHeight
		local menuItem3Datas = {}
		for i = 1, 2 do
			local itemData = {}
			itemData.gameObject = view['menu3item' .. i]
			itemData.defaultPos = Vector2.New(0, defaultPos)
			itemData.toPos = Vector2.New(0, initY)
			table.insert(menuItem3Datas, itemData)
			initY = initY - menuItemHeight
		end
		menuItemsDatas[3] = menuItem3Datas
	end
	
	self.onLoad = function()
		local content = view.LeftMenuScrollview:GetComponent('UnityEngine.UI.ScrollRect').content
		gridLayoutGroup = content:GetComponent('UnityEngine.UI.GridLayoutGroup')
		menuItemsGroup[1].toggles = {}
		for i = 1, 7 do
			menuItemsGroup[1].toggles[i] = view['menu1item' .. i]:GetComponent('UnityEngine.UI.Toggle')
			UIUtil.AddToggleListener(view['menu1item'..i].gameObject, function(flag) self.OnMenuItem1Click(i, flag) end)
		end
		
		menuItemsGroup[2].toggles = {}
		for i = 1, 3 do
			menuItemsGroup[2].toggles[i] = view['menu2item' .. i]:GetComponent('UnityEngine.UI.Toggle')
			UIUtil.AddToggleListener(view['menu2item'..i].gameObject, function(flag) self.OnMenuItem2Click(i, flag) end)
		end
		
		menuItemsGroup[3].toggles = {}
		for i = 1, 2 do
			menuItemsGroup[3].toggles[i] = view['menu3item' .. i]:GetComponent('UnityEngine.UI.Toggle')
			UIUtil.AddToggleListener(view['menu3item'..i].gameObject, function(flag) self.OnMenuItem3Click(i, flag) end)
		end
		
		for i = 1, 3 do
			if not menuItems[i] then
				menuItems[i] = nil
				menu[i] = nil
			end
			
			menuItems[i] = CreateMenuItemUI(menuItemsDatas[i])
			menu[i] = CreateMenuCtrl(view['menu' .. i], menuDatas[i])
			menuItemsGroup[i].toggleGroup = view['menu' .. i .. 'items'].gameObject:GetComponent('UnityEngine.UI.ToggleGroup')
			menuItems[i].CollapseImmediately()
			UIUtil.AddToggleListener(view['menu'..i].gameObject, function(flag) OnMenuClick(i, flag) end)
		end
		
		local defaultPos1 = menu[1].defaultPos
		local defaultPos2 = menu[2].defaultPos
		local defaultPos3 = menu[3].defaultPos
		--local heightDiff =  111
		local toPos2 = {}
		toPos2.x = defaultPos2.x
		toPos2.y = defaultPos1.y - menuHeight
		menu[2].SetAnchoredPosition(toPos2)
		
		local toPos3 = {}
		toPos3.x = defaultPos3.x
		toPos3.y = toPos2.y - menuHeight
		menu[3].SetAnchoredPosition(toPos3)
		local toggle = view.menu1:GetComponent('UnityEngine.UI.Toggle')
		if not toggle.isOn then
			toggle.isOn = true
			toggle.group:NotifyToggleOn(toggle)
		else
			OnMenuClick(1, true)
		end
	end

	self.onUnload = function()
		for i = 1, 7 do
			UIUtil.RemoveToggleListener(view['menu1item'..i].gameObject)
		end

		for i = 1, 2 do
			UIUtil.RemoveToggleListener(view['menu3item'..i].gameObject)
		end
		
		for i = 1, 3 do
			UIUtil.RemoveToggleListener(view['menu2item'..i].gameObject)
			UIUtil.RemoveToggleListener(view['menu'..i].gameObject)
			menuItems[i].ExpandImmediately()
			menuItems[i] = nil
		end
		menu[2].SetDefaultPos()
		menu[3].SetDefaultPos()
		
		rankingTopType = 1					--排行榜大类别
		rankingMiddleType	= 1				--排行榜中类别
		rankingSmallType = 1 				--排行榜小类别
		rankDatas = nil
	end
	
	InitMenuItemDatas()
	return self
end

local function CreateRankingListUICtrl()
    local self = CreateCtrlBase()
	local rankMenu
	local rankContent
	local view
	
	local OnClose = function()
		UIManager.UnloadView(ViewAssets.RankingListUI)
	end
	
	local OnRankPage = function(index)
	end
	
    self.onLoad = function()
		view = self.view
		ClickEventListener.Get(view.btnquit).onClick = OnClose
		for i = 1, 5 do
			UIUtil.AddToggleListener(view['toggle'..i].gameObject, function() OnRankPage(i) end)
		end
		
		if not rankContent then
			rankContent = nil
		end
		rankContent = CreateRankContentUI(view)
		rankContent.onLoad()
		
		if not rankMenu then
			rankMenu = nil
		end
		rankMenu = CreateRankMenuUICtrl(view, rankContent)
		rankMenu.onLoad()
	end

    self.onUnload = function()
		rankContent.onUnload()
		rankMenu.onUnload()
	end

    return self
end

return CreateRankingListUICtrl()