--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/3/1
--
require "UI/Controller/LuaCtrlBase"

local function CreateUnionInformationsUICtrl()	--帮会信息
    local self = CreateCtrlBase()
	local view
	local noticeField
	local unionNameField

	local OnClose = function()
		UIManager.UnloadView(ViewAssets.UnionInformationsUI)
	end
	
	local RequestUnionInfo = function()			--请求帮会信息
		local data = {}
		data.func_name = 'on_get_basic_faction_info'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end

	
	self.GetBasicFactionInfoRet = function(data) 	--获取帮会信息反馈
		local info = data.faction_info
		if not info then
			return
		end
		
		unionNameField.text = info.faction_name  --帮会名称
		view.unionowner:GetComponent('TextMeshProUGUI').text = info.chief_name  --帮主
		view.unionlevel:GetComponent('TextMeshProUGUI').text = info.faction_level --帮会等级
		view.unionid:GetComponent('TextMeshProUGUI').text = info.visual_id --帮会ID
		view.unionum:GetComponent('TextMeshProUGUI').text = info.members_num --帮会成员数
		view.faction_fund:GetComponent('TextMeshProUGUI').text = info.faction_fund --帮会资金
		
		local ischief = false
		local loginData = MyHeroManager.heroData
		if loginData.entity_id == info.chief_id then  	--我是帮主
			ischief = true
		else   											--我不是帮主
			ischief = false
		end
		
		view.setenemyunion:SetActive(ischief)
		view.editnotice:SetActive(ischief)
		view.editunionname:SetActive(ischief)
		
		local declaration =  info.declaration
		local strlen = string.len(declaration)
		if strlen == 0 then
			declaration = commonCharChinese.UIText[1135010].NR
		end
		--view.unionnotice:GetComponent('TextMeshProUGUI').text = declaration --帮会通知
		noticeField.text = declaration --帮会通知
		
		local enemyFactionName = info.enemy_faction_name
		strlen = string.len(enemyFactionName)
		if strlen == 0 then
			enemyFactionName = commonCharChinese.UIText[1135011].NR
		end
		view.enemyunion:GetComponent('TextMeshProUGUI').text = enemyFactionName --敌对帮会
        FactionManager.UpdateFactionTopTime(data.faction_info.on_top_expire_time)
	end
	
	local OnConveyFortifiedPoint = function()		--传送据点
		UIManager.ShowNotice('该功能暂未开放')
	end
	
	local OnBuildUnion = function()					--建设帮会
		UIManager.ShowNotice('该功能暂未开放')
	end
	
	local OnInFief = function()						--进入封地
		UIManager.ShowNotice('该功能暂未开放')
	end
	
	local OnSetEnemyUnion = function()   			--设置敌对帮会
		UIManager.PushView(ViewAssets.UnionAntagonizeSettingUI)
	end
	
	self.SetDeclarationRet = function(data)			--修改公告服务器反馈
        FactionManager.UpdateFactionTopTime(data.faction_info.on_top_expire_time)
	end
	
	self.ChangeFactionNameRet = function(data)		--修改帮会名称服务器反馈
	
	end
	
	local OnEditNotice = function()					--编辑公告
		if noticeField.readOnly == false then		--修改公告
			local data = {}
			data.func_name = 'on_set_declaration'
			data.new_declaration = noticeField.text
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		end
	
		noticeField.readOnly = (noticeField.readOnly ~= true)
	end
	
	local OnEditUnionName = function()				--编辑帮会名称
		if unionNameField.readOnly == false then
			local data = {}
			data.func_name = 'on_change_faction_name'
			data.faction_name = unionNameField.text
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		end
	
		unionNameField.readOnly = (unionNameField.readOnly ~= true)
	end
		
    self.onLoad = function()
		view = self.view
		ClickEventListener.Get(view.btnClose).onClick = OnClose
		ClickEventListener.Get(view.conveyfortifiedpointbtn).onClick = OnConveyFortifiedPoint
		ClickEventListener.Get(view.buildunionbtn).onClick = OnBuildUnion
		ClickEventListener.Get(view.infiefbtn).onClick = OnInFief
		ClickEventListener.Get(view.setenemyunion).onClick = OnSetEnemyUnion
		ClickEventListener.Get(view.editnotice).onClick = OnEditNotice
		ClickEventListener.Get(view.editunionname).onClick = OnEditUnionName
		RequestUnionInfo()
		MessageRPCManager.AddUser(self, 'GetBasicFactionInfoRet')
		MessageRPCManager.AddUser(self, 'SetDeclarationRet')
		MessageRPCManager.AddUser(self, 'ChangeFactionNameRet')
		
		noticeField = view.noticeInput:GetComponent('TMPro.TMP_InputField')
		noticeField.readOnly = true
		unionNameField = view.unionnameInput:GetComponent('TMPro.TMP_InputField')
		unionNameField.readOnly = true
    end

    self.onUnload = function()
		MessageRPCManager.RemoveUser(self, 'GetBasicFactionInfoRet')
		MessageRPCManager.RemoveUser(self, 'SetDeclarationRet')
		MessageRPCManager.RemoveUser(self, 'ChangeFactionNameRet')
    end

    return self
end

return CreateUnionInformationsUICtrl()