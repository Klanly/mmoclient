--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/5/27
--
require "UI/Controller/LuaCtrlBase"

local string_format = string.format

local CampOfficeChineseName = {'皇帝', '宰相', '大将军', '中书令', '门下令', '尚书令', '偏将', '都统', '提督' }
local officeName = {'emperor', 'primeminister', 'biggeneral', 'zhongshuling',
						'menxialing', 'shangshuling', 'pianjiang', 'dutong', 'tidu'}
						
local CampOfficeDescript = {1135058, 1135060, 1135062, 1135064, 1135066, 1135068, 1135070, 1135072, 1135074}
local CampOfficeAuthority = {'convene', 'opentask', 'openfacility', 'openBOSS', 'officerskill1CD', 'officerskill2', 'adjustablesoldiers', 'discount', 'openportal', 'paysalary'}
local CampOfficeAuthorityChinese= {1135075, 1135077, 1135079, 1135081, 1135083, 1135085, 1135087, 1135089, 1135091, 1135091}
local OfficeFunctionName = {1135076, 1135078, 1135080, 1135082, 1135084, 1135086, 1135088, 1135090, 1135092, 1135092}

--阵营设施界面
local CreateCampOfficeFacilityUI = function(view)
	local self = CreateObject()
	
	self.onLoad = function()
	
	end
	
	self.onUnload = function()

	end
	
	self.SetActive = function(active)
	end
	
	return self
end

---

--官职投票界面
local CreateOfficeVoteUI = function(view)
	local self = CreateObject()
	local candiDate = {}
	local candidateList = {}
	local searchData = {}
	local isSearch = false
	local currentKey = ''
	local isScreenui = false
	local filterCriteria = {}
	local maxOfficeNum = 9
	local isActive = false
	self.selectItemIndex = 1

	self.GetCandidateListRequest = function()
		local data = {} --候选列表请求
		data.func_name = 'on_get_candidate_list'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local onItemUpdate = function(go, index)
		local luaTable = go:GetComponent("LuaBehaviour").luaTable
		local dataIndex = index + 1
		local currentData = candidateList[dataIndex]
		if isSearch then
			currentData = searchData[dataIndex]
		else
			currentData = candidateList[dataIndex]
		end
		
		local offices = currentData.offices
		luaTable.Init()
		luaTable.SetIndex(dataIndex)
		luaTable.SetOwner(self)
		luaTable.name:GetComponent('TextMeshProUGUI').text = currentData.actor_name
		if currentData.war_rank <= 50 then
			luaTable.war:GetComponent('TextMeshProUGUI').text = '战阶：'.. pvpCamp.Rank[currentData.war_rank].Name1   --战阶名字
		end
		
		local tmpInputField = luaTable.notice:GetComponent('TMP_InputField')
		local loginData = MyHeroManager.heroData
		if currentData.actor_id ~= loginData.actor_id then
			luaTable.btnedit:SetActive(false)
			tmpInputField.interactable = false
		else
			luaTable.btnedit:SetActive(true)
			tmpInputField.interactable = true
		end
		
		luaTable.numble:GetComponent('TextMeshProUGUI').text = '竞选编号：' .. currentData.order
		luaTable.textRanking:GetComponent('TextMeshProUGUI').text = dataIndex
		luaTable.SetVote(currentData.vote)
		
		if currentData.declaration then
			luaTable.SetText(currentData.declaration)
		else
			luaTable.SetText('')
		end
		
		local index = 1
		for k, v in pairs(offices) do
			local text = luaTable['officename'..index]
			if text and v then
				text:SetActive(true)
				text:GetComponent('TextMeshProUGUI').text = CampOfficeChineseName[k]
			end
			
			local bg = luaTable['offbg'..index]
			if bg then
				bg:SetActive(true)
			end
			index = index + 1
		end
		
		if dataIndex == self.selectItemIndex then
			luaTable.imgframe:GetComponent('Toggle').isOn = true
		end
	end
	
	self.GetCandidateListRet = function(data)
		candiDate = data
		local candidate_list = data.candidate_list
		if candidate_list == nil then
			return
		end
		--if candidate_list then
			--self.SetActive(false)
			--UIManager.ShowNotice('当前不在官职选举期间')
			--return
		--end
		candidateList = {}
		for k, v in pairs(candidate_list) do
			v.actor_id = k
			table.insert(candidateList, v)
		end
		
		self.SetActive(true)
		self.scrollview:UpdateData(#candidateList, onItemUpdate)
		view.havevoteTimes:GetComponent('TextMeshProUGUI').text = '剩余票数：' .. candiDate.self_vote_num
		
		local desText1 = string_format(commonCharChinese.UIText[1135133].NR, '投票')
		local desText2 = string_format(commonCharChinese.UIText[1135134].NR, '结算', data.time_to_count)
		view.officevotetip:GetComponent('TextMeshProUGUI').text = desText1 .. '	 ' .. desText2
	end
	
	self.VoteForCandidateRet = function(data) --投票返回结果
		candiDate = data
		local candidate_list = data.candidate_list
		if candidate_list == nil then
			return
		end
		
		candidateList = {}
		for k, v in pairs(candidate_list) do
			v.actor_id = k
			table.insert(candidateList, v)
		end
		
		if isSearch then
			self.ShowSearchRet(currentKey)
		else
			self.scrollview:UpdateData(#candidateList, onItemUpdate)
			view.havevoteTimes:GetComponent('TextMeshProUGUI').text = '剩余票数：' .. candiDate.self_vote_num
		end
	end
	
	self.OnVote = function()	--投票
		--if self.selectItemIndex < 1 then
			--UIManager.ShowNotice('当前未选中')
			--return
		--end
		
		local currentData = candidateList[self.selectItemIndex]
		if isSearch then
			currentData = searchData[self.selectItemIndex]
		else
			currentData = candidateList[self.selectItemIndex]
		end
		
		if currentData == nil then
			UIManager.ShowNotice('候选人列表为空')
			return
		end
		
		local data = {}
		data.func_name = 'on_vote_for_candidate'
		data.vote_num = 1
		data.candidate_player_id = currentData.actor_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OnFilter = function()  --筛选
		if isScreenui then
			isScreenui = false
		else
			isScreenui = true
		end
		view.screenui:SetActive(isScreenui)
	end
	
	self.IsMatchFilter = function(offices)
		local ret = false
		for k, v in pairs(filterCriteria) do
			if v then  --需要满足该条件
				for k1, v1 in pairs(offices) do
					if k1 == k and v1 then
						return true
					end
				end
			end
		end
		return ret
	end
	
	self.ModifyParticipateDeclarationRet = function(data)    --修改公告反馈
		candiDate = data
		local candidate_list = data.candidate_list
		if candidate_list == nil then
			return
		end
		
		candidateList = {}
		for k, v in pairs(candidate_list) do
			v.actor_id = k
			table.insert(candidateList, v)
		end
		
		if isSearch then
			self.ShowSearchRet(currentKey)
		else
			self.scrollview:UpdateData(#candidateList, onItemUpdate)
		end
	end
	
	self.ShowSearchRet = function(key) --显示搜索结果
		if key == '' then
			isSearch = false
			self.scrollview:UpdateData(#candidateList, onItemUpdate)
			return
		end
		
		searchData = {}
		for k, v in pairs(candidateList) do
			local ret = string.match(v.actor_name, key)
			local orderRet = string.match(v.order, key)
			if (key == ret or key == orderRet) and self.IsMatchFilter(v.offices) then
				table.insert(searchData, v)
			end
		end
		
		--if searchData[self.selectItemIndex] ~= candidateList[self.selectItemIndex].v then
			--self.selectItemIndex = -1
		--end
		self.scrollview:UpdateData(#searchData, onItemUpdate)
	end
	
	self.OnSearch = function()	--搜索
		currentKey = view.bginput:GetComponent('TMP_InputField').text
		isSearch = true
		self.ShowSearchRet(currentKey)
	end
	
	self.SelectOffice = function(index)
		local isOn = view['btnCheckmark'..index]:GetComponent('Toggle').isOn
		filterCriteria[index] = isOn
	end
	
	self.OnTip = function(position)
		UIManager.PushView(ViewAssets.CommTextTipUI,
			function(ctrl)
				local pos = position
				pos.y = pos.y - 0.2
				pos.x = pos.x - 1.8
				ctrl.SetData(commonCharChinese.UIText[1135130].NR)
				ctrl.SetPosition(pos)
			end
		)
	end
	
	self.onLoad = function()
		self.scrollview = view.voticescrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(view.officeitem, 1686, 200, 5, 15, 1)
		--MessageRPCManager.AddUser(self, 'GetCandidateListRet')
		MessageRPCManager.AddUser(self, 'VoteForCandidateRet')
		MessageRPCManager.AddUser(self, 'ModifyParticipateDeclarationRet')
		
		for i = 1, 9 do
			ClickEventListener.Get(view['btnCheckmark'..i]).onClick = function() self.SelectOffice(i)  end
		end
		
		ClickEventListener.Get(view.btnvote).onClick = self.OnVote  	--投票
		ClickEventListener.Get(view.btnfilter).onClick = self.OnFilter  --筛选
		ClickEventListener.Get(view.btnsearch).onClick = self.OnSearch  --搜索
		ClickEventListener.Get(view.havevoteTimes).onClick = function() self.OnTip(view.havevoteTimes.transform.position) end --选票提示
		self.selectItemIndex = 1
	end
	
	self.onUnload = function()
		--MessageRPCManager.RemoveUser(self, 'GetCandidateListRet')
		MessageRPCManager.RemoveUser(self, 'VoteForCandidateRet')
		MessageRPCManager.RemoveUser(self, 'ModifyParticipateDeclarationRet')
		candiDate = {}
		candidateList = {}
	end
	
	local onItemUpdate = function(go, index)
		
	end
	
	self.SetActive = function(active)
		if isActive == active then
			return
		end
	
		isActive = active
		view.Officeui2:SetActive(active)
		if active then
			isSearch = false
			isScreenui = false
			view.bginput:GetComponent('TMP_InputField').text = ''
			view.screenui:SetActive(isScreenui)
			filterCriteria = {}
			
			for i = 1, maxOfficeNum do
				view['btnCheckmark'..i]:GetComponent('Toggle').isOn = true
				filterCriteria[i] = true
			end
		end
	end
	
	return self
end

--官职提名条件
local CreateCampOfficeConditionUI = function(view)
	local self = CreateObject()
	local conditionsMaxNum = 4
	local conditionsName = {'本周活跃排名', '战力排名', '善恶值排名', '上次大攻防排名'}
	local conditionsKeys = {'liveness', 'fight', 'kindness', 'exploit'}
	
	self.onLoad = function()
		ClickEventListener.Get(view.electionconditionsok).onClick = function() self.SetActive(false)  end
		ClickEventListener.Get(view.electionconditionsspace).onClick = function() self.SetActive(false) end
	end
	
	self.onUnload = function()

	end
	
	self.ShowContent = function(index)
		local election = pvpCamp.ElectionQualification[index]
		local num = 0
		for i = 1, conditionsMaxNum do
			if election[conditionsKeys[i]] ~= -1 then
				num = num + 1
				view['conditions'..num]:GetComponent('TextMeshProUGUI').text = conditionsName[i]..'前'.. election[conditionsKeys[i]] ..'名'
			end
		end
		
		for i = num + 1, conditionsMaxNum do
			view['conditions'..i]:SetActive(false)
		end
	end
	
	self.SetActive = function(active)
		view.electionconditions:SetActive(active)
	end
	
	return self
end

--官职提名界面
local CreateOfficeNominationUI = function(view)
	local self = CreateObject()
	local officeMaxNum = 9
	local selectIndex = 0
	local nomData  --选举数据
	local campOfficeConditionUI
	local authorityList = {}
	self.scrollview = nil
	
	self.GetElectionBasicInfoRet = function(data)
		local candidateNumber = data.candidate_number
		local choosedOffice = data.choosed_office
		nomData = data
		
		self.ClearUIShow()
		
		if choosedOffice then
			for k, v in pairs(choosedOffice) do
				view['label'..k]:SetActive(true)
			end
		end
		
		for i = 1, officeMaxNum do
			local numble =  candidateNumber[i]
			if numble then
				view['enrollment' .. i]:GetComponent('TextMeshProUGUI').text = '报名人数：' .. numble
			end
		end
		
		if 0 < selectIndex and selectIndex <= officeMaxNum then
			self.OnSelect(selectIndex)
		end
	
		view.officevotetimetip:SetActive(true)
		if data.time_to_vote then
			local desText1 = string_format(commonCharChinese.UIText[1135133].NR, '提名')
			local desText2 = string_format(commonCharChinese.UIText[1135134].NR, '投票', data.time_to_vote)
			view.officevotetimetip:GetComponent('TextMeshProUGUI').text = desText1 .. '	  ' .. desText2
		end
	end
	
	
	local ShowTip = function(position, index)
		UIManager.PushView(ViewAssets.CommTextTipUI,
			function(ctrl)
				local pos = position
				pos.y = pos.y - 0.2
				pos.x = pos.x - 1.8
				ctrl.SetData(commonCharChinese.UIText[OfficeFunctionName[index]].NR)
				ctrl.SetPosition(pos)
			end)
	end
	
	local onItemUpdate = function(go, index)
		local luaTable = go:GetComponent("LuaBehaviour").luaTable
		local dataIndex = index + 1
		if luaTable == nil then
			return
		end
		
		luaTable.text2.transform.localPosition = Vector3.New(308, -55, 0)
		luaTable.text2:GetComponent('TextMeshProUGUI').text = commonCharChinese.UIText[CampOfficeAuthorityChinese[authorityList[dataIndex]]].NR  
		luaTable.HideCDTime()
		luaTable.btnelection1:SetActive(false)
		ClickEventListener.Get(luaTable.text2).onClick = function() ShowTip(luaTable.text2.transform.position, authorityList[dataIndex])  end
	end
	
	self.ClearUIShow = function()
		for i = 1, officeMaxNum do
			view['label' .. i]:SetActive(false)
			view['enrollment' .. i]:GetComponent('TextMeshProUGUI').text = ''
			view['textplayname'..i]:GetComponent('TextMeshProUGUI').text = ''
		end
	end
	
	self.ParticipateInElectionRet = function(data)
		if data.result ~= 0 then
			return
		end
		
		self.GetElectionBasicInfoRet(data)
	end
	
	self.ElectionRequst = function(id)
		local data = {} --参与选举
		data.func_name = 'on_participate_in_election'
		data.office_id = id

		local text = view.electiontext:GetComponent('TextMeshProUGUI').text
		if text == '取消' then
			data.is_cancel = true
		end
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OnSelect = function(index)
		if not nomData then
			return
		end
		
		view.selectofficename:GetComponent('TextMeshProUGUI').text = CampOfficeChineseName[index]
		view.selctofficedes:GetComponent('TextMeshProUGUI').text = commonCharChinese.UIText[CampOfficeDescript[index]].NR
		selectIndex = index
		--local ret = nomData.optional_office[selectIndex]
		--view.electionbtn:SetActive(ret)
		
		view.electiontext:GetComponent('TextMeshProUGUI').text = '参选'
		if nomData.choosed_office then
			if nomData.choosed_office[selectIndex] then
				view.electiontext:GetComponent('TextMeshProUGUI').text = '取消'
			end
		end
		
		local authorityNum = 0
		authorityList = {}
		local governmentPost = pvpCamp.GovernmentPost
		for k, v in pairs(CampOfficeAuthority) do
			if governmentPost[index][v] ~= 0 then
				authorityNum = authorityNum + 1
				table.insert(authorityList, k)
			end
		end
		self.scrollview:UpdateData(authorityNum, onItemUpdate)
		
		if ret then
			view.electionbtncondition:SetActive(false)
		else
			view.electionbtncondition:SetActive(true)
		end
	end
	
	self.onLoad = function()
		campOfficeConditionUI = CreateCampOfficeConditionUI(view)
		campOfficeConditionUI.onLoad()
	
		--MessageRPCManager.AddUser(self, 'GetElectionBasicInfoRet')
		MessageRPCManager.AddUser(self, 'ParticipateInElectionRet')
		self.scrollview = view.functionscrollview:GetComponent(typeof(UIMultiScroller))
	end
	
	self.onUnload = function()
		campOfficeConditionUI.onUnload()
		selectIndex = 0
		--MessageRPCManager.RemoveUser(self, 'GetElectionBasicInfoRet')
		MessageRPCManager.RemoveUser(self, 'ParticipateInElectionRet')
	end
	
	self.OnElectionbtncondition = function(index)
		campOfficeConditionUI.SetActive(true)
		campOfficeConditionUI.ShowContent(index)
	end
	
	self.SetActive = function(active)
		view.Officeui:SetActive(active)
		campOfficeConditionUI.SetActive(false)
		
		if active then
			--self.ClearUIShow()
			view.electionbtn:SetActive(true)
			view.electionbtncondition:SetActive(true)
			view.textper_office_btn:SetActive(false)
			
			--for i = 1, 4 do
				--view['btnelection'..i]:SetActive(false)
			--end
			
			for i = 1, officeMaxNum do
				--view['label' .. i]:SetActive(false)
				--view['enrollment' .. i]:GetComponent('TextMeshProUGUI').text = ''
				--view['textplayname'..i]:GetComponent('TextMeshProUGUI').text = ''
				ClickEventListener.Get(view[officeName[i]]).onClick = function() self.OnSelect(i) end
			end
			ClickEventListener.Get(view.electionbtn).onClick = function() self.ElectionRequst(selectIndex)  end
			ClickEventListener.Get(view.electionbtncondition).onClick = function() self.OnElectionbtncondition(selectIndex)  end
			self.OnSelect(1)
		end
	end
	
	return self
end

--官职选举管理界面
local CreateCampOfficeElectionManagerUI = function(view)
	local self = CreateObject()
	local officeNominationUI
	local officeVoteUI
	
	self.onLoad = function()
		officeNominationUI = CreateOfficeNominationUI(view)
		officeNominationUI.onLoad()
		officeVoteUI = CreateOfficeVoteUI(view)
		officeVoteUI.onLoad()
		MessageRPCManager.AddUser(self, 'GetElectionBasicInfoRet')
		MessageRPCManager.AddUser(self, 'GetCandidateListRet')
		MessageRPCManager.AddUser(self, 'ElectionTimeTable')
	end
	
	self.onUnload = function()
		officeNominationUI.onUnload()
		officeVoteUI.onUnload()
		MessageRPCManager.RemoveUser(self, 'GetElectionBasicInfoRet')
		MessageRPCManager.RemoveUser(self, 'GetCandidateListRet')
		MessageRPCManager.RemoveUser(self, 'ElectionTimeTable')
	end
	
	self.GetElectionBasicInfoRet = function(data)
		--if data.result ~= 0 then
			--UIManager.ShowNotice('不在选举期间')
			--return
		--end
		
		officeNominationUI.GetElectionBasicInfoRet(data)
		officeNominationUI.SetActive(true)
	end
	
	self.GetCandidateListRet = function(data)  --获取候选人信息
		--if data.result ~= 0 then
			--UIManager.ShowNotice('不在选举期间')
			--return
		--end
		officeVoteUI.GetCandidateListRet(data)
		officeVoteUI.SetActive(true)
	end
	
	self.ElectionTimeTable = function(data)	--选举各阶段距离时间
		local tipText
		if data.time_to_nomination then --距离提名时间
			tipText = '距离提名时间还有' .. data.time_to_nomination
		elseif data.time_to_vote then   --距离投票时间
			tipText = '距离投票时间还有' .. data.time_to_vote
		elseif data.time_to_count then	--距离结算时间
			tipText = '距离结算时间还有' .. data.time_to_count
		end
		view.noticetext:GetComponent('TextMeshProUGUI').text = tipText
		view.noticetext:SetActive(true)
	end
	
	self.SetActive = function(active)
		if not active then
			officeNominationUI.SetActive(active)
			officeVoteUI.SetActive(active)
			view.noticetext:SetActive(active)
		else

			local data = {} --获取基本选举信息
			data.func_name = 'on_get_election_basic_info'
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		end
	end
	
	return self
end

--往届官职界面
local CreatePreCampOfficeUI = function(view)
	local self = CreateObject()
	local preOfficeData
	local historyOfficers = {}
	local curretIndex = -1
	local maxIndex = 0
	
	local onItemUpdate = function(go, index)
		local luaTable = go:GetComponent("LuaBehaviour").luaTable
		local dataIndex = index + 1
		local currentData = historyOfficers[dataIndex]
		
		luaTable.Init()
		currentData.index = curretIndex
		luaTable.SetData(currentData)
		luaTable.textname:GetComponent('TextMeshProUGUI').text = currentData.actor_name
		luaTable.textoffice:GetComponent('TextMeshProUGUI').text = currentData.office_id .. '.' .. CampOfficeChineseName[currentData.office_id]
		luaTable.texttickets:GetComponent('TextMeshProUGUI').text = '当选票数：' .. currentData.vote
		
		local like = currentData.like
		if like == nil then
			like  = 0
		end
		
		luaTable.textlike:GetComponent('TextMeshProUGUI').text = '点赞数：' .. like
	end
	
	self.GetHistoryOfficersRet = function(data)
		if data.result and data.result ~= 0 then
			return
		end
	
		if data.index <= 0 then
			UIManager.ShowNotice('没有历史官员记录')
			self.SetActive(false)
			return
		end
		
		self.SetActive(true)
		preOfficeData = data
		historyOfficers = {}
		for k, v in pairs(data.history_officers) do
			v.actor_id = k
			table.insert(historyOfficers, v)
		end
		table.sort(historyOfficers, function(a, b) return a.office_id < b.office_id end )
		
		curretIndex = data.index
		maxIndex = data.max_index
		if maxIndex == nil then
			maxIndex = data.index
		end
		
		if #historyOfficers <= 0 then
			view.preofficeTip:SetActive(true)
			view.preofficeTip:GetComponent('TextMeshProUGUI').text = '本届选举没有当选官员'
		else
			view.preofficeTip:SetActive(false)
		end
		
		view.texttitle:GetComponent('TextMeshProUGUI').text = '第'..curretIndex..'届当选官员'
		self.scrollview:UpdateData(#historyOfficers, onItemUpdate)
	end
	
	self.GiveLikeToHistoryOfficerRet = function(data) --点赞反馈
		if data.max_index == nil then
			data.max_index = maxIndex
		end
		
		self.GetHistoryOfficersRet(data)
	end

	self.onLoad = function()
		self.scrollview = view.preofficescrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(view.officerrankitem, 1353, 70, 5, 15, 1)
		ClickEventListener.Get(view.btnFront).onClick = self.OnPre
		ClickEventListener.Get(view.btnafter).onClick = self.OnNext
		MessageRPCManager.AddUser(self, 'GetHistoryOfficersRet')
		MessageRPCManager.AddUser(self, 'GiveLikeToHistoryOfficerRet')
	end
	
	self.onUnload = function()
		MessageRPCManager.RemoveUser(self, 'GetHistoryOfficersRet')
		MessageRPCManager.RemoveUser(self, 'GiveLikeToHistoryOfficerRet')
		historyOfficers = {}
		curretIndex = -1
		preOfficeData = nil
	end
	
	self.OnNext = function()
		if curretIndex >= maxIndex then
			UIManager.ShowNotice('没有下一届官员记录')
			return
		end
	
		local data = {}
		data.func_name = 'on_get_history_officers'
		data.index = curretIndex + 1
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OnPre = function()
		if curretIndex <= 1 then
			UIManager.ShowNotice('没有上一届官员记录')
			return
		end
	
		local data = {}
		data.func_name = 'on_get_history_officers'
		data.index = curretIndex - 1
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.SetActive = function(active)
		view.previousui:SetActive(active)
		if active then
			ClickEventListener.Get(view.space).onClick = function()
				view.previousui:SetActive(false)
			end
		else
			historyOfficers = {}
			curretIndex = -1
			preOfficeData = nil
		end
	end
	
	return self
end

--当前官职界面
local CreateCampOfficerUI = function(view)
	local self = CreateObject()
	local preCampOfficeUI
	local officeMaxNum = 9
	local officersData
	local cdList = {}
	local currentOfficers = {}
	local preSelectIndex = 0
	local authorityList = {}
	local requestList = {[1] = 'OnCountryPlayerCallTogether', [5] = 'OnOfficeTotalSkillRequest', [6] = 'OnOfficeHaloSkillRequest', [8] = 'OnCountryShopDiscountRequest',[10] = 'OnPaySalary'}
	self.scrollview = nil
	
	self.ClearUIShow = function()
		for i = 1, officeMaxNum do
			view['label' .. i]:SetActive(false)
			view['enrollment' .. i]:GetComponent('TextMeshProUGUI').text = ''
			view['textplayname'..i]:GetComponent('TextMeshProUGUI').text = ''
		end
	end
	
	self.OnCountryShopDiscountRequest = function(makeSure) --阵营商店打折
		local data = {}
		data.func_name = 'on_country_shop_discount'
		if makeSure then
			data.make_sure = makeSure
		end
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.CountryShopDiscountRet = function(data)    --阵营商店打折反馈
		if data.result == constant.need_make_sure_cover_discount then  --显示打折确认框
			local title = string_format(commonCharChinese.UIText[1135128].NR, CampOfficeChineseName[data.office_id], data.actor_name)
			UIManager.ShowDialog(title, '确定', '取消',
				function()
					self.OnCountryShopDiscountRequest(true)
				end)
		end
	end
	
	self.OnOfficeTotalSkillRequest = function() --官职技能-全体buff
		local data = {}
		data.func_name = 'on_office_total_skill'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OnOfficeHaloSkillRequest = function() --官职技能-光环
		local data = {}
		data.func_name = 'on_office_halo_skill'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OnPaySalary = function() --支付薪水
		--local data = {}
		--data.func_name = 'on_pay_salary'
		--MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		UIManager.UnloadView(ViewAssets.CampOfficeUI)
		UIManager.PushView(ViewAssets.CampBaseUI)
	end
	
	self.OnCountryPlayerCallTogether = function() --阵营招募
		local data = {}
		data.func_name = 'on_country_player_call_together'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end

	self.OnNpcTransport = function() --客户端发起NPC传送请求
		local data = {}
		data.func_name = 'on_npc_transport'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local ShowTip = function(position, index)
		UIManager.PushView(ViewAssets.CommTextTipUI,
			function(ctrl)
				local pos = position
				pos.y = pos.y - 0.2
				pos.x = pos.x - 1.8
				ctrl.SetData(commonCharChinese.UIText[OfficeFunctionName[index]].NR)
				ctrl.SetPosition(pos)
			end)
	end
	
	local onItemUpdate = function(go, index)
		local luaTable = go:GetComponent("LuaBehaviour").luaTable
		local dataIndex = index + 1
		if luaTable == nil then
			return
		end
		
		local curOfficer = currentOfficers[preSelectIndex]
		local loginData = MyHeroManager.heroData
		if curOfficer and curOfficer.actor_id == loginData.actor_id  then
			local dataTable = cdList[authorityList[dataIndex]]
			if dataTable then
				local cdTime = dataTable[2]
				local skillName = dataTable[1]
				if cdTime then
					luaTable.SetCDTime(cdTime)
				end
			
				if skillName then
					luaTable.SetSkillName(skillName)
				end
			else
				luaTable.HideCDTime()
			end
			
			luaTable.text2.transform.localPosition = Vector3.New(170, -55, 0)
		else
			luaTable.btnelection1:SetActive(false)
			luaTable.cdtime:SetActive(false)
			luaTable.btnreset:SetActive(false)
			luaTable.text2.transform.localPosition = Vector3.New(308, -55, 0)
		end
		
		ClickEventListener.Get(luaTable.btnelection1).onClick =function() self[requestList[authorityList[dataIndex]]](false) end
		luaTable.text2:GetComponent('TextMeshProUGUI').text = commonCharChinese.UIText[CampOfficeAuthorityChinese[authorityList[dataIndex]]].NR
		ClickEventListener.Get(luaTable.text2).onClick = function() ShowTip(luaTable.text2.transform.position, authorityList[dataIndex])  end
	end
	
	self.OnSelectOffice = function(index)
		--if (not refresh) and preSelectIndex == index then
			--return
		--end
		preSelectIndex = index
		view[officeName[index]]:GetComponent('Toggle').isOn = true
		view.selectofficename:GetComponent('TextMeshProUGUI').text = CampOfficeChineseName[index]
		view.selctofficedes:GetComponent('TextMeshProUGUI').text = commonCharChinese.UIText[CampOfficeDescript[index]].NR
		
		local authorityNum = 0
		authorityList = {}
		local governmentPost = pvpCamp.GovernmentPost
		for k, v in pairs(CampOfficeAuthority) do
			if governmentPost[index][v] ~= 0 then
				authorityNum = authorityNum + 1
				table.insert(authorityList, k)
			end
		end
		self.scrollview:UpdateData(authorityNum, onItemUpdate)
	end
	
	self.OnGetHistoryOfficersRequest = function()
		local data = {}
		data.func_name = 'on_get_history_officers'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.CountryPlayerCallTogetherRet = function()		--阵营招募反馈
	
	end

	self.onLoad = function()
		preCampOfficeUI = CreatePreCampOfficeUI(view)
		preCampOfficeUI.onLoad()
		
		for i = 1, officeMaxNum do
			view['label' .. i]:SetActive(false)
			view['enrollment' .. i]:GetComponent('TextMeshProUGUI').text = ''
			view['textplayname'..i]:GetComponent('TextMeshProUGUI').text = ''
		end
		
		self.scrollview = view.functionscrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(view.functionitem, 746, 80, 10, 15, 1)
				
		MessageRPCManager.AddUser(self, 'GetCurrentOfficersRet')
		MessageRPCManager.AddUser(self, 'CountryPlayerCallTogetherRet')
		MessageRPCManager.AddUser(self, 'CountryShopDiscountRet')
		ClickEventListener.Get(view.textper_office_btn).onClick = self.OnGetHistoryOfficersRequest
	end
	
	self.GetCurrentOfficersRet = function(data)	--获取当前官员
		local officers = data.current_officers
		if officers == nil then
			return
		end

		currentOfficers = {}
		for k, v in pairs(officers) do
			view['textplayname' .. v.office_id]:GetComponent('TextMeshProUGUI').text = v.actor_name
			v.actor_id = k
			table.insert(currentOfficers, v.office_id, v)
		end
		
		officersData = data
		local cd_list = officersData.cd_list
		if cd_list then
			cdList = {}
			for k, v in pairs(cd_list) do
				local id = constant.OFFICE_SKILL_NAME_TO_ID[k]
				local cdTable = {}
				cdTable[1] = k
				cdTable[2] = v
				table.insert(cdList, id, cdTable)
			end
		end
		self.OnSelectOffice(preSelectIndex)
	end
	
	self.onUnload = function()
		MessageRPCManager.RemoveUser(self, 'GetCurrentOfficersRet')
		MessageRPCManager.RemoveUser(self, 'CountryPlayerCallTogetherRet')
		MessageRPCManager.RemoveUser(self, 'CountryShopDiscountRet')
		preCampOfficeUI.onUnload()
		preSelectIndex = 1
	end
	
	self.SetActive = function(active)
		view.Officeui:SetActive(active)
		
		if active then
			self.ClearUIShow()
			
			authorityList = {}
			currentOfficers = {}
			local data = {}
			data.func_name = 'on_get_current_officers'
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			
			view.textper_office_btn:SetActive(true)
			view.electionbtn:SetActive(false)
			view.electionbtncondition:SetActive(false)
			
			for i = 1, officeMaxNum do
				ClickEventListener.Get(view[officeName[i]]).onClick = function() self.OnSelectOffice(i) end
			end
			view.officevotetimetip:SetActive(false)
			preSelectIndex = 1
		else
			preSelectIndex = 1
		end
	end
	
	return self
end


--官职界面控制
local function CreateCampOfficeUICtrl()
    local self = CreateCtrlBase()
	local maxIndex = 2
	local slectPageIndex = 0
	local campOfficeUI = {}
	
	self.OnPage = function(index)
		if slectPageIndex == index then
			return
		end
		
		self.view['toggle'..index]:GetComponent('Toggle').isOn = true
		if campOfficeUI[slectPageIndex] then
			campOfficeUI[slectPageIndex].SetActive(false)
		end
		self.view.previousui:SetActive(false)
		campOfficeUI[index].SetActive(true)
		slectPageIndex = index
	end

    self.onLoad = function()
		local view = self.view
		campOfficeUI[1] = CreateCampOfficerUI(view)
		campOfficeUI[2] = CreateCampOfficeElectionManagerUI(view)
		campOfficeUI[3] = CreateCampOfficeFacilityUI(view)

		for i = 1, maxIndex do
			ClickEventListener.Get(view['toggle'..i]).onClick = function() self.OnPage(i)			end
			campOfficeUI[i].onLoad()
		end
        self.OnPage(1)
    end

    self.onUnload = function()
		for i = 1, maxIndex do
			campOfficeUI[i].onUnload()
			campOfficeUI[i].SetActive(false)
			campOfficeUI[i] = nil
		end
		self.view.previousui:SetActive(false)
		slectPageIndex = 0
    end

    return self
end

return CreateCampOfficeUICtrl()

