---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/2
-- desc： 竞技场排行
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local arenaScheme = GetConfig('challenge_arena')
local constant = require "Common/constant"
local uitext = GetConfig("common_char_chinese").UIText

local function CreateArenaMixMatchCtrl()
	local self = CreateCtrlBase()

	self.currentRankData = nil
	
	-- 当列表更新时回调
	local onItemUpdate = function(go, index)
		local rankText = go.transform:FindChild('rank').gameObject:GetComponent('TextMeshProUGUI')
		local rankImgObj = go.transform:FindChild('rankImg').gameObject
		local rankImg = go.transform:FindChild('rankImg/img').gameObject:GetComponent('Image')
		local name = go.transform:FindChild('name').gameObject:GetComponent('TextMeshProUGUI')
		local party = go.transform:FindChild('party').gameObject:GetComponent('TextMeshProUGUI')
		local family = go.transform:FindChild('family').gameObject:GetComponent('TextMeshProUGUI')
		local power = go.transform:FindChild('power').gameObject:GetComponent('TextMeshProUGUI')
		local score1 = go.transform:FindChild('score1').gameObject:GetComponent('TextMeshProUGUI')
		local score2 = go.transform:FindChild('score2').gameObject:GetComponent('TextMeshProUGUI')

		local rankData = self.currentRankData[index + 1]
		if not rankData then
			return
		end
		if rankData.total_rank <= 3 then
			rankText.gameObject:SetActive(false)
			rankImgObj:SetActive(true)
			rankImg.sprite = ResourceManager.LoadSprite('AutoGenerate/Petappearance/'..rankData.total_rank)
		else
			rankText.gameObject:SetActive(true)
			rankImgObj:SetActive(false)
			rankText.text = rankData.total_rank
		end 

		name.text = rankData.actor_name
		if rankData.union_name == "" then
			party.text = uitext[1101037].NR
		else
			party.text = rankData.union_name
		end

		family.text = LuaUIUtil.getVocationName(rankData.vocation)
		power.text = rankData.qualifying_score + rankData.dogfight_score
        score1.text = rankData.qualifying_score
		score2.text = rankData.dogfight_score
	end

	-- 加载列表
	local loadList = function(data)
		local arrData = {}
		for k, v in pairs(data) do
			table.insert(arrData, v)
		end

		self.currentRankData = arrData
		table.sort(arrData, function(a, b)
			return a.total_rank < b.total_rank
		end)
		self.scrollview:UpdateData(#arrData, onItemUpdate)

		local selfIndex = 0
		for k, v in ipairs(arrData)do
			if MyHeroManager.heroData.entity_id == v.actor_id then
				selfIndex = k
			end
		end
		self.updateSelfRank(selfIndex)
	end

	local closeClick = function()
		self.close()
		UIManager.PushView(ViewAssets.ArenaSelect)
	end

	local refreshTimer = nil
	local resttime = 0
	local stopRefreshTimer = function()
		if refreshTimer then
			Timer.Remove(refreshTimer)
		end
		refreshTimer = nil
	end
	local startRefreshTimer = function(t)
		stopRefreshTimer()
		resttime = t
		refreshTimer = Timer.Repeat(1, function()
			resttime = resttime - 1
			if resttime <= 0 then
				stopRefreshTimer()
				self.view.testRefreshTime:GetComponent('TextMeshProUGUI').text = '排行榜在即将刷新'
			else
				self.view.testRefreshTime:GetComponent('TextMeshProUGUI').text = '榜单刷新时间:' .. TimeToStr(resttime)
			end
		end)
	end

	local requestRankData = function(type, grade_id, rank_start)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_GET_RANK, {
        	type = type,
        	grade_id = grade_id,
        	rank_start = rank_start,
        })
	end
	
	local restFightNum = 0
	local onUpdateArenaInfo = function(data)
		self.arenaData = data or self.arenaData
		self.view.textfctitle:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.property[constant.PROPERTY_NAME_TO_INDEX.spritual]

		local total = arenaScheme.Parameter[19].Value[1]
		local rest = total - self.arenaData.arena_info.dogfight_fight_count + self.arenaData.arena_info.dogfight_buy_count
		self.view.textResidualfrequency:GetComponent('TextMeshProUGUI').text = '今日剩余次数：' .. rest .. '/' .. total
		restFightNum = rest

		local grade = LuaUIUtil.getGradeText(self.arenaData.arena_info.grade_id)
		self.view.texbtnRankingList1:GetComponent('TextMeshProUGUI').text = grade.main
		self.view.texbtnRankingList2:GetComponent('TextMeshProUGUI').text = grade.sub

		self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
		self.view.textEstimatedtime:GetComponent('TextMeshProUGUI').text = '预计时间:' .. TimeToStr(ArenaManager.predictTime or 300)
	end
	
	local OnBuyTimes = function(data)
		if data.result ~= 0 then
			return
		end
		self.arenaData = data
		onUpdateArenaInfo(self.arenaData)
	end
	local onMatchInfoUpdate = function(ty, para)
		if ty == 'start' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "取消匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
		elseif ty == 'tick' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "取消匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = "已用时间:" .. TimeToStr(para)
		elseif ty == 'stop' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "开始匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
		end

		if ty == 'forbid_start' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "禁止匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
		elseif ty == 'forbid_tick' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "禁止匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = "禁赛时间:" .. TimeToStr(para)
		elseif ty == 'forbid_stop' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "开始匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
		end		

		-- 自己已经准备就绪
        if ty == 'fight_ready' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "准备就绪"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
        elseif ty == 'fight_enter' then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "开始匹配"
			self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
        end	
	end

	local StartMatchClick = function()
		if ArenaManager.isOnForbidMixFight then
			return
		end
		if ArenaManager.isReadyMix then
			return
		end

		if ArenaManager.isOnMatching then
			ArenaManager.RequestCancelMatchMixFight()
		else
			if restFightNum <= 0 then
				UIManager.ShowNotice('没有剩余次数了')
				return
			end
			ArenaManager.RequestStartMatchMixFight()
		end
	end
		
	local buyTimeClick = function()	
		local consum = LuaUIUtil.getConsume(self.arenaData.arena_info.dogfight_buy_count, constant.ARENA_TYPE.dogfight)		
		UIManager.ShowDialog("你确定花费<color=red>" .. consum .. "元宝</color>购买1次武林争霸挑战次数？", '确定', '取消',
			function()
				MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_BUY_COUNT, {type = constant.ARENA_TYPE.dogfight})
    		end)
	end

	
	local onOpenShopClick = function()
		UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('arena')
	end

	local HelpClick = function()		
		UIManager.PushView(ViewAssets.TipsUI,nil, 31270017)
	end

	local OnUpdateRankData = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		
		loadList(data.rank_data)

		local lefttime = networkMgr:GetConnection():GetTimespanSeconds(data.next_refresh_rank_time)
		startRefreshTimer(lefttime)
	end
	self.setMatchVisible = function(visible)
		local v = visible or false
		self.view.matchui:SetActive(v)
		local renkUI = self.view.mixUI:GetComponent("RectTransform")
		if v then
			renkUI.sizeDelta = Vector2.New(1300, renkUI.sizeDelta.y)
		else
			renkUI.sizeDelta = Vector2.New(1674, renkUI.sizeDelta.y)
		end
	end
	self.updateSelfRank = function(index)
		local svrect = self.view.rankScrollview:GetComponent("RectTransform")
		if index < 1 then
			self.view.selfRankGroup:SetActive(false)
			svrect.sizeDelta = Vector2.New(svrect.sizeDelta.x, 655)
		else
			self.view.selfRankGroup:SetActive(true)
			svrect.sizeDelta = Vector2.New(svrect.sizeDelta.x, 583)
			onItemUpdate(self.view.selfRankGroup, index - 1)
		end
	end
	self.updateArenaInfo = function()	
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_INFO, {})
	end
	local initUI = function()
		if ArenaManager.isReadyMix then
			self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "准备就绪"
		else
			if ArenaManager.isOnMatching then
				self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "取消匹配"
			else
				self.view.textbtnStartmatching:GetComponent('TextMeshProUGUI').text = "开始匹配"
			end
		end
		self.view.testUsedtime:GetComponent('TextMeshProUGUI').text = ''
	end
	-- mode表示是否显示math面板
	self.onLoad = function(arenaData, showMatch, arenatype)
		self.arenatype = arenatype or self.arenatype
		if showMatch == nil then showMatch = true end
		initUI()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_GET_RANK, OnUpdateRankData)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
		self.scrollview = self.view.rankScrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(self.view.itemTemplate, 1153, 72, 5, 15, 1)
    	self.updateSelfRank(0)

        ClickEventListener.Get(self.view.btnReturn).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnReturn, nil, nil)

        ClickEventListener.Get(self.view.btnStartmatching).onClick = StartMatchClick
        UIUtil.AddButtonEffect(self.view.btnStartmatching, nil, nil)

        ClickEventListener.Get(self.view.btnadd).onClick = buyTimeClick
        UIUtil.AddButtonEffect(self.view.btnadd, nil, nil)

        ClickEventListener.Get(self.view.btnshop).onClick = onOpenShopClick
        UIUtil.AddButtonEffect(self.view.btnshop, nil, nil)

        ClickEventListener.Get(self.view.btnrule).onClick = HelpClick
        UIUtil.AddButtonEffect(self.view.btnrule, nil, nil)
        if showMatch then
        	self.setMatchVisible(true)
        else
        	self.setMatchVisible(false)
        end
		ArenaManager.AddMatchListener(onMatchInfoUpdate)
		requestRankData(self.arenatype, 0, 1)
		if arenaData then
			onUpdateArenaInfo(arenaData)
		else
			self.updateArenaInfo()
		end
	end
	
	self.onUnload = function()
		stopRefreshTimer()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_GET_RANK, OnUpdateRankData)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_BUY_COUNT, OnBuyTimes)
		ArenaManager.RemoveMatchListener(onMatchInfoUpdate)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_INFO, onUpdateArenaInfo)
	end
	
	return self
end

return CreateArenaMixMatchCtrl()