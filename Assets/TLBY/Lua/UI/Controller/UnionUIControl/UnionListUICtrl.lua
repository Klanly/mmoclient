--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/3/1
--
require "UI/Controller/LuaCtrlBase"
--帮会列表
local function CreateUnionListUICtrl()
    local self = CreateCtrlBase()
	local view
	local startIndex = 1		--显示其实成员序列
	local endIndex = 20			--显示最后成员序列
	local selectItemIndex = 0 	--当前选中的item
	local resultMemberList = {} --申请帮会列表
	local rankDatas
	local unionNoticeText
	local enemyUnionNameText
	self.scrollview = nil
	
	local OnClose = function()
		UIManager.UnloadView(ViewAssets.UnionListUI)
	end
	
	local OnCallUnionOwner = function()	--联系帮主
		local union = rankDatas[selectItemIndex]
		if union == nil then
			UIManager.ShowNotice('当前无选中帮会')
			return
		end
		
		local data = {}
		data.actor_id = union.chief_id		--帮主id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_QUERY_PLAYER, data)
		
		--UIManager.GetCtrl(ViewAssets.FriendsUI).SendPrivateMsg(data)
	end
	
	local OnCreateUnion = function()	--创建帮会
		UIManager.LoadView(ViewAssets.FactionCreateUI)
	end
	
	local RequestFactionList = function()  --请求帮会列表
		local data = {}   
		data.func_name = 'on_get_faction_list'
		data.start_index = startIndex --开始索引
		data.end_index = endIndex --结束索引
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	-------------------------帮会成员数据设置
	local OnItemUpdate = function(go, index) --跟新帮会成员数据
		local dataIndex = index + 1
		local unionMemberUICtrl = go:GetComponent('LuaBehaviour').luaTable
		local myData = rankDatas[dataIndex]
		
		unionMemberUICtrl.unionlevelText.text = myData.faction_level	--帮会等级
		unionMemberUICtrl.unionnameText.text =  myData.faction_name		--帮会名称
		unionMemberUICtrl.unionidText.text = myData.visual_id			--帮会ID
		unionMemberUICtrl.unionnumText.text = myData.members_num		--成员人数
		unionMemberUICtrl.unionownerText.text = myData.chief_name		--帮主
		
		unionMemberUICtrl.memberIndex = dataIndex
		unionMemberUICtrl.SelectAction = self.SelectAction
		
		local isResult = resultMemberList[myData.faction_id]
		if isResult == 0 then
			unionMemberUICtrl.hasrequested:SetActive(true)		--已申请标志
		end
		
		if myData.on_top == 0 then
			unionMemberUICtrl.topflag:SetActive(false)			--置顶标志
			unionMemberUICtrl.bgredbox:SetActive(false)
		else
			unionMemberUICtrl.topflag:SetActive(true)
			unionMemberUICtrl.bgredbox:SetActive(true)
		end
		
		if math.fmod(dataIndex, 2) == 0 then
			unionMemberUICtrl.bgwhitearticle:SetActive(true)
			unionMemberUICtrl.bgblackarticle:SetActive(false)
		else
			unionMemberUICtrl.bgwhitearticle:SetActive(false)
			unionMemberUICtrl.bgblackarticle:SetActive(true)			
		end
		
		if selectItemIndex == dataIndex then
			unionMemberUICtrl.bgselectarticle:SetActive(true)
		else
			unionMemberUICtrl.bgselectarticle:SetActive(false)
		end
	end
	
	self.SelectAction = function(itemIndex)
		selectItemIndex = itemIndex
		if rankDatas[itemIndex] == nil then		--该帮会不存在
			return
		end
		
		local declaration =  rankDatas[itemIndex].declaration
		local strlen = string.len(declaration)
		if strlen == 0 then
			declaration = commonCharChinese.UIText[1135010].NR
		end
		unionNoticeText.text = declaration --帮会宣言
		
		local enemyFactionName = rankDatas[itemIndex].enemy_faction_name
		strlen = string.len(enemyFactionName)
		if strlen == 0 then
			enemyFactionName = commonCharChinese.UIText[1135011].NR
		end
		enemyUnionNameText.text = enemyFactionNamee --敌对帮会名称
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
	end
	-------------------------------------------------
	
	self.GetFactionListRet = function(data) --获取帮会列表的服务器反馈
		rankDatas = data.info_list
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
		self.SelectAction(startIndex)
	end
	
	local OnFastJoinUnion = function()				--一键申请帮会
		local data = {}
		data.func_name = 'on_one_key_apply_join_faction'
		data.faction_id_list = {}
		
		local memberNum = #rankDatas
		if memberNum > 10 then		--一键申请最多可以申请10个
			memberNum = 10
		end
		
		if memberNum == 0 then
			UIManager.ShowNotice('当前无申请帮会')
			return
		end
		
		for i = 1, memberNum do
			table.insert(data.faction_id_list, rankDatas[i].faction_id)
		end
		
		--faction_id_list: table, 帮会id列表，key为连续的数字，value为faction_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.OneKeyApplyJoinFactionRet = function(data) --一键申请帮会反馈
		if data.result == 0 then
			UIManager.ShowNotice('已向帮会发送申请，请等待审核')
			for k, v in pairs(data.result_list) do
				resultMemberList[k] = v
			end
			self.scrollview:UpdateData(#rankDatas, OnItemUpdate)  --跟新下数据
		end
	end
	
	local OnSearch = function()						--搜索帮会
		local unionName = view.SearchInput:GetComponent('TMP_InputField').text
		local unNameLen = string.len(unionName)
		if unNameLen <= 0 then
			UIManager.ShowNotice('搜索关键字不能为空')
			return
		end
		
		local data = {}
		data.func_name = 'on_search_faction'
		data.search_str = unionName
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.SearchFactionRet = function(data) 	--搜索帮会反馈
		rankDatas = data.info_list
		local listNum = #rankDatas
		if listNum < 1 then
			local unionName = view.SearchInput:GetComponent('TMP_InputField').text
			UIManager.ShowNotice('未搜索到关键字或则ID为"' .. unionName .. '"的帮会，请确认后重新搜索')
		end
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
	end
	
	local OnJoinUnion = function() --申请加入帮会
		local union = rankDatas[selectItemIndex]
		if union == nil then
			UIManager.ShowNotice('当前无选中帮会')
			return
		end
		
		local data = {}
		data.func_name = 'on_apply_join_faction'
		data.faction_id = union.faction_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.ApplyJoinFactionRet = function(data)	--申请加入帮会反馈
		if data.result == 0 then
			UIManager.ShowNotice('已向该帮会发送申请，请等待审核')
			resultMemberList[data.faction_id] = 0
			self.scrollview:UpdateData(#rankDatas, OnItemUpdate)  --跟新下数据
		end
	end
	
	local PlayerInfoRet = function(data)		--服务器返回该角色信息
		if data.result ~= 0 then
		
			return
		end
		
		local resData = {}
		local playerInfo = data.player_info
		resData.actor_id = playerInfo.actor_id
		resData.actor_name = playerInfo.actor_name
		resData.vocation = playerInfo.vocation
		resData.sex = playerInfo.sex
		
		ContactManager.PushView(ViewAssets.FriendsUI,
            function(ctrl) 
                ctrl.SendPrivateMsg(resData) 
             end
        )	--联系帮主

		OnClose()
	end
	
    self.onLoad = function()
		view = self.view
		ClickEventListener.Get(view.btnClose).onClick = OnClose
		ClickEventListener.Get(view.calluniononwerbtn).onClick = OnCallUnionOwner
		ClickEventListener.Get(view.createunionbtn).onClick = OnCreateUnion
		ClickEventListener.Get(view.btnkeyapplication).onClick = OnFastJoinUnion
		ClickEventListener.Get(view.signupbtn).onClick = OnJoinUnion
		ClickEventListener.Get(view.btnsearch).onClick = OnSearch
		MessageRPCManager.AddUser(self, 'GetFactionListRet')
		MessageRPCManager.AddUser(self, 'SearchFactionRet')
		MessageRPCManager.AddUser(self, 'ApplyJoinFactionRet')
		MessageRPCManager.AddUser(self, 'OneKeyApplyJoinFactionRet')
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_QUERY_PLAYER, PlayerInfoRet)
		
		self.scrollview = view.UnionListScrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(view.rankitem, 1281, 68, 5, 15, 1)
		RequestFactionList()
		
		enemyUnionNameText = view.enemyunion:GetComponent('TextMeshProUGUI')
		unionNoticeText = view.unionnotice:GetComponent('TextMeshProUGUI')
	end

    self.onUnload = function()
		self.scrollview = nil
		MessageRPCManager.RemoveUser(self, 'GetFactionListRet')
		MessageRPCManager.RemoveUser(self, 'SearchFactionRet')
		MessageRPCManager.RemoveUser(self, 'ApplyJoinFactionRet')
		MessageRPCManager.RemoveUser(self, 'OneKeyApplyJoinFactionRet')
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_QUERY_PLAYER, PlayerInfoRet)
	end

    return self
end

return CreateUnionListUICtrl()