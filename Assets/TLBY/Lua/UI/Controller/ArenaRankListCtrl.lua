---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/2
-- desc： 竞技场排行
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local arenaScheme = GetConfig('challenge_arena')
local constant = require "Common/constant"
local uitext = GetConfig("common_char_chinese").UIText

local function CreateArenaRankListCtrl()
	local self = CreateCtrlBase()

	self.ranktabData = {}
	self.secondRanktabData = {}
	self.rankTable = {}

	self.secondTabctl = nil
	self.selectMainIndex = 1
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
		local level = go.transform:FindChild('level').gameObject:GetComponent('TextMeshProUGUI')

		local rankData = self.currentRankData[index + 1]
		if not rankData then
			return
		end
		if rankData.rank <= 3 then
			rankText.gameObject:SetActive(false)
			rankImgObj:SetActive(true)
			rankImg.sprite = ResourceManager.LoadSprite('AutoGenerate/Petappearance/'..rankData.rank)
		else
			rankText.gameObject:SetActive(true)
			rankImgObj:SetActive(false)
			rankText.text = rankData.rank
		end 

		name.text = rankData.actor_name
		if rankData.union_name == "" then
			party.text = uitext[1101037].NR
		else
			party.text = rankData.union_name
		end
		family.text = LuaUIUtil.getVocationName(rankData.vocation)
		power.text = rankData.fight_power
		level.text = rankData.level
	end

	-- 加载列表
	local loadList = function(data)
		self.currentRankData = data
		self.scrollview:UpdateData(#data, onItemUpdate)

		local selfIndex = 0
		for k, v in ipairs(data)do
			if MyHeroManager.heroData.entity_id == v.actor_id then
				selfIndex = k
			end
		end
		self.updateSelfRank(selfIndex)
	end

	-- 收集排名的配置信息，如段位
	local initRankConfig = function()
		self.rankTable = {}
		local sortRank = {}
		for k, v in pairs(arenaScheme.QualifyingGrade) do
			table.insert(sortRank, v)
		end
		table.sort(sortRank, function(a, b)
			return a.ID < b.ID
		end)
		for k, v in ipairs(sortRank) do
			local index = math.floor(v.ID/100)
			if not self.rankTable[index] then
				self.rankTable[index] = {
					selectSubIndex = 1, -- 当前选中的子段位
					subItems = {},		-- 子段位
				}
			end
			local subItem = {
				config = v,
				rankData = nil
			}
			table.insert(self.rankTable[index].subItems, subItem)
		end
	end

	local closeClick = function()
		self.close()
		local ctrl = UIManager.GetCtrl(ViewAssets.ArenaMatch)
		UIManager.PushView(ViewAssets.ArenaMatch,nil,ctrl.arenaData)
	end

	local requestRankData = function(type, grade_id, rank_start)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_GET_RANK, {
        	type = type,
        	grade_id = grade_id,
        	rank_start = rank_start,
        })
	end

	-- 当主段位点击事件
	local onMainGradeClick = function(index)
		self.selectMainIndex = index
		local rt = self.rankTable[index]
		for si, subtab in ipairs(self.secondRanktabData) do
			if rt.subItems[si] then
				subtab.tab:SetActive(true)
				subtab.textObj:GetComponent('TextMeshProUGUI').text = rt.subItems[si].config.SubGrade1
			else
				subtab.tab:SetActive(false)
			end
		end
		self.secondTabctl:SetActivePanel(rt.selectSubIndex - 1)
	end

	-- 次段位点击事件
	local onSubGradeClick = function(index)
		local rt = self.rankTable[self.selectMainIndex]
		rt.selectSubIndex = index
		-- print(self.selectMainIndex .. ',' .. rt.selectSubIndex)
		if rt.subItems[rt.selectSubIndex].rankdata then -- 缓存的排名数据
			loadList(rt.subItems[rt.selectSubIndex].rankdata)
		else
			requestRankData(self.arenatype, rt.subItems[rt.selectSubIndex].config.ID, 1)
		end	
	end
	
	-- 初始化tabcontrol
	local initTabControl = function()
		local secondTabctl = self.view.secondRankGroup:GetComponent('TabControl')
		secondTabctl:Clear()
		secondTabctl.OnPanelChanged = function(index, isactive)
			local secondRankData = self.secondRanktabData[index + 1]
			if isactive then
				secondRankData.textObj:GetComponent("TextMeshProUGUI").color = secondRankData.activeColor
				onSubGradeClick(index + 1)
			else
				secondRankData.textObj:GetComponent("TextMeshProUGUI").color = secondRankData.deactiveColor
			end 
		end		
		for i = 1, 7 do
			local t = {
				tab = self.view['btnpaging' .. i], 
				index = i,
				textObj = self.view['textbtnpaging' .. i],
				activeColor = Color.New(0.132, 0.263, 0.061),				
				deactiveColor = Color.New(0.231, 0.149, 0.129),
			}
			self.secondRanktabData[i] = t
			secondTabctl:AddTabPanel(t.tab)
		end
		-- secondTabctl:SetActivePanel(0)
		self.secondTabctl = secondTabctl

		local tabctl = self.view.rankGroup:GetComponent('TabControl')
		tabctl:Clear()
		tabctl.OnPanelChanged = function(index, isactive)
			local rankData = self.ranktabData[index + 1]
			if isactive then
				rankData.textObj.transform.localPosition = Vector3.New(
					rankData.textPos.x,
					-9.2 + 7,
					rankData.textPos.z
				)
				onMainGradeClick(index + 1)
			else
				rankData.textObj.transform.localPosition = rankData.textPos
			end 
		end
		for i = 1, 6 do
			local t = {
				tab = self.view['btntranspaging' .. i], 
				index = i,
				textPos = self.view['textbtntranspaging' .. i].transform.localPosition,
				textObj = self.view['textbtntranspaging' .. i]
			}
			self.ranktabData[i] = t
			tabctl:AddTabPanel(t.tab)
		end
		tabctl:SetActivePanel(0)
	end

	local HelpClick = function()		
		UIManager.PushView(ViewAssets.TipsUI, 31270016)
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
	local OnUpdateRankData = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		local rt = self.rankTable[self.selectMainIndex]
		
		if not rt.subItems[rt.selectSubIndex].rankdata then
			rt.subItems[rt.selectSubIndex].rankdata = {}
		end
		for k, v in pairs(data.rank_data) do
			rt.subItems[rt.selectSubIndex].rankdata[k] = v
		end
		loadList(rt.subItems[rt.selectSubIndex].rankdata)

		local lefttime = networkMgr:GetConnection():GetTimespanSeconds(data.next_refresh_rank_time)
		startRefreshTimer(lefttime)
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
	-- mode表示是否显示math面板
	self.onLoad = function(arenatype)		
		self.arenatype = arenatype or self.arenatype
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_GET_RANK, OnUpdateRankData)

		initRankConfig() -- 初始化段位信息
		initTabControl() -- 初始化tab信息
		self.scrollview = self.view.rankScrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(self.view.itemTemplate, 1153, 72, 5, 15, 1)
    	self.updateSelfRank(0)

        ClickEventListener.Get(self.view.btnReturn).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnReturn, nil, nil)

        ClickEventListener.Get(self.view.btnrule).onClick = HelpClick
        UIUtil.AddButtonEffect(self.view.btnrule, nil, nil)
	end

	self.onUnload = function()
		stopRefreshTimer()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_GET_RANK, OnUpdateRankData)

		self.ranktabData = {}
		self.secondRanktabData = {}
		self.rankTable = {}

		self.secondTabctl = nil
		self.selectMainIndex = 1
	end
	
	return self
end

return CreateArenaRankListCtrl()