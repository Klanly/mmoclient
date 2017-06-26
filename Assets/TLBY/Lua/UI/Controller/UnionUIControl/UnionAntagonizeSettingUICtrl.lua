--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/3/1
--
require "UI/Controller/LuaCtrlBase"
--帮会列表
local function CreateUnionAntagonizeSettingUICtrl()
    local self = CreateCtrlBase()
	local view
	local startIndex = 1	--显示其实成员序列
	local endIndex = 20		--显示最后成员序列
	local rankDatas			--帮会列表信息
	local myUnionInfo       --本帮会信息
	local unionNoticeText
	local enemyUnionNameText
	self.scrollview = nil
	
	local OnClose = function()
		UIManager.UnloadView(ViewAssets.UnionAntagonizeSettingUI)
	end
	
	local RequestFactionList = function()  --请求帮会列表
		local data = {}   
		data.func_name = 'on_get_faction_list'
		data.start_index = startIndex --开始索引
		data.end_index = endIndex --结束索引
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	-------------------------帮会成员数据设置
	local selectItemIndex = 0

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
		
		--unionMemberUICtrl.hasrequested:SetActive(false)				--已申请标志
		
		if myData.on_top == 0 then
			unionMemberUICtrl.topflag:SetActive(false)					--置顶标志
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
		--unionNoticeText.text = rankDatas[itemIndex].declaration --帮会宣言
		--enemyUnionNameText.text = rankDatas[itemIndex].enemy_faction_name --敌对帮会名称
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
	end
	-------------------------------------------------
	
	self.GetFactionListRet = function(data) --获取帮会列表的服务器反馈
		rankDatas = data.info_list
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
		self.SelectAction(startIndex)
	end

	local OnSearch = function()						--搜索帮会
		local unionName = view.SearchInput:GetComponent('TMP_InputField').text
		local unNameLen = string.len(unionName)
		if unNameLen <= 0 then
			return
		end
		
		local data = {}
		data.func_name = 'on_search_faction'
		data.search_str = unionName
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.SearchFactionRet = function(data) 	--搜索帮会反馈
		rankDatas = data.info_list
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
	end
	
	local OnFastSet = function()				--快速设置敌对帮会
		local data = {}
		data.func_name = 'on_set_enemy_faction'
		local dataNum = #rankDatas	--随机选取一个帮会
		if dataNum <= 1 then  		--没有可选敌对帮会
			return
		end
		
		local index = math.random(dataNum)
		while myUnionInfo.faction_id == rankDatas[index].faction_id do--敌对帮会不能为自己帮会
			index = math.random(dataNum)
		end
		data.enemy_faction_id = rankDatas[index].faction_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local OnRequstSetEnemyFaction = function() --请求设置敌对帮会
        local SetEnemyFaction = function()
			local data = {}
			data.func_name = 'on_set_enemy_faction'
			data.enemy_faction_id = rankDatas[selectItemIndex].faction_id
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
		
        UIManager.ShowDialog('你确定将' .. rankDatas[selectItemIndex].faction_name .. '设为敌对帮会吗', '确定', '取消', SetEnemyFaction, nil)
	end
	
	self.SetEnemyFactionRet = function(data)	--设置敌对帮会反馈
		local info = data.faction_info
		local enemyFactionName = myUnionInfo.enemy_faction_name
		local strlen = string.len(enemyFactionName)
		if strlen == 0 then
			enemyFactionName = commonCharChinese.UIText[1135011].NR
		end
		
		view.enemyunion:GetComponent('TextMeshProUGUI').text = enemyFactionName --敌对帮会
		--view.enemyunion:GetComponent('TextMeshProUGUI').text = info.enemy_faction_name --敌对帮会名称
        
        FactionManager.UpdateFactionTopTime(data.faction_info.on_top_expire_time)
	end
	
	local OnRequstRefreshUnions = function()		--请求刷新帮会列表
		local data = {}
		data.func_name = 'on_get_random_faction_list'
		data.list_length = 10
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.GetRandomFactionListRet = function(data)	--刷新帮会列表服务端反馈
		rankDatas = data.info_list
		self.scrollview:UpdateData(#rankDatas, OnItemUpdate)
	end
	
	local RequestMyUnionInfo = function()		--请求自己的帮会信息
		local data = {}
		data.func_name = 'on_get_basic_faction_info'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.GetBasicFactionInfoRet = function(data) --自己的帮会信息反馈
		myUnionInfo = data.faction_info
		view.unionlevel:GetComponent('TextMeshProUGUI').text = myUnionInfo.faction_level	--帮会等级
		view.unionname:GetComponent('TextMeshProUGUI').text =  myUnionInfo.faction_name		--帮会名称
		view.unionid:GetComponent('TextMeshProUGUI').text = myUnionInfo.visual_id			--帮会ID
		view.unionnum:GetComponent('TextMeshProUGUI').text = myUnionInfo.members_num		--成员人数
		view.unionowner:GetComponent('TextMeshProUGUI').text = myUnionInfo.chief_name
		
		local declaration =  myUnionInfo.declaration
		local strlen = string.len(declaration)
		if strlen == 0 then
			declaration = commonCharChinese.UIText[1135010].NR
		end
		view.unionnotice:GetComponent('TextMeshProUGUI').text = declaration --帮会通知
		
		local enemyFactionName = myUnionInfo.enemy_faction_name
		strlen = string.len(enemyFactionName)
		if strlen == 0 then
			enemyFactionName = commonCharChinese.UIText[1135011].NR
		end
		view.enemyunion:GetComponent('TextMeshProUGUI').text = enemyFactionName --敌对帮会
        
        FactionManager.UpdateFactionTopTime(data.faction_info.on_top_expire_time)
	end
	
    self.onLoad = function()
		view = self.view
		ClickEventListener.Get(view.btnClose).onClick = OnClose
		ClickEventListener.Get(view.btnsearch).onClick = OnSearch
		ClickEventListener.Get(view.btnkeyapplication).onClick = OnFastSet
		ClickEventListener.Get(view.setenemybtn).onClick = OnRequstSetEnemyFaction
		ClickEventListener.Get(view.refreshunionlist).onClick = OnRequstRefreshUnions
		MessageRPCManager.AddUser(self, 'GetFactionListRet')
		MessageRPCManager.AddUser(self, 'SearchFactionRet')
		MessageRPCManager.AddUser(self, 'SetEnemyFactionRet')
		MessageRPCManager.AddUser(self, 'GetBasicFactionInfoRet')
		MessageRPCManager.AddUser(self, 'GetRandomFactionListRet')
		
		self.scrollview = view.UnionListScrollview:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(view.rankitem, 1281, 68, 5, 15, 1)
		RequestFactionList()
		RequestMyUnionInfo()
		
		enemyUnionNameText = view.enemyunion:GetComponent('TextMeshProUGUI')
		unionNoticeText = view.unionnotice:GetComponent('TextMeshProUGUI')
	end

    self.onUnload = function()
		self.scrollview = nil
		MessageRPCManager.RemoveUser(self, 'GetFactionListRet')
		MessageRPCManager.RemoveUser(self, 'SearchFactionRet')
		MessageRPCManager.RemoveUser(self, 'SetEnemyFactionRet')
		MessageRPCManager.RemoveUser(self, 'GetBasicFactionInfoRet')
		MessageRPCManager.RemoveUser(self, 'GetRandomFactionListRet')
	end

    return self
end

return CreateUnionAntagonizeSettingUICtrl()