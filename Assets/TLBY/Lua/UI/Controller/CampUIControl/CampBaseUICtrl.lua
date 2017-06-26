--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/9
--
require "UI/Controller/LuaCtrlBase"

local function CreateCampBaseUICtrl()		--阵营基础
    local self = CreateCtrlBase()
    local view = nil
	local slectPageIndex = 0
	local campBaseData  	--阵营基础数据
	local warSoulTotalTime 	--战魂觉醒持续总时间
	local warSoulTimerInfo 	--战魂觉醒定时器
	local warSoulTimeLeft 	--战魂觉醒剩余时间
	local sliderScript
	local btngettherewardsImg	--领取奖励按钮
	local icongettherewardsImg --宝箱
	
	local ShowWarSoulTime = function(value)
	
		if value <= 0 then
			view.TextWarSoulTic:SetActive(false)
			view.eff_UIzhanhun:SetActive(false)
			return
		end
	
		value = math.floor(value)
		local minute = math.floor(value / 60)
		local second = value - minute * 60
		if second < 10 then
		
			second = '0'..second
		end
		
		if minute < 10 then
		
			minute = '0'..minute
		end
		
		view.TextWarSoulTic:GetComponent('TextMeshProUGUI').text = minute..':'..second
	end
	
	local SetWarSooulProgress = function(value)			--战魂觉醒结束时间
	
		if not warSoulTotalTime then
		
			return
		end
		
		if value <= 0 then
		
			value = 0
			
			local image = view.btnWarSoulAwake:GetComponent('Image')
			image.material = nil
			view.textWarSoulAwake:GetComponent('TextMeshProUGUI').text = '战魂觉醒'
			warSoulTimeLeft = 0
		end
		
		view.WarSoulValue:GetComponent('Image').fillAmount =  value / warSoulTotalTime
		if not sliderScript then
		
			sliderScript = view.WarSoulSlider:GetComponent('Slider')
		end
		sliderScript.value = value / warSoulTotalTime
		ShowWarSoulTime(value)
	end
	
	local UpdateWarSooulValue = function()
	
		warSoulTimeLeft = warSoulTimeLeft - 0.02
		if warSoulTimeLeft <= 0 then
		
			warSoulTimeLeft = 0
			if warSoulTimerInfo then 

				Timer.Remove(warSoulTimerInfo)
				warSoulTimerInfo = nil
			end
		end
		
		SetWarSooulProgress(warSoulTimeLeft)
	end
	
	
	local SetCampAttr = function(data)
	
		view.textcampaignfunds2:GetComponent('TextMeshProUGUI').text = data.country_fund  	--阵营资金
		local material = UIGrayMaterial.GetUIGrayMaterial()
		if data.pay_right then
			view.btnsalary:GetComponent("Image").material = nil
		else
			view.btnsalary:GetComponent("Image").material = material
		end

		local titleName = '平民'
		local titleData =  pvpCamp.NobleRank[data.noble_rank]
		if data.noble_rank == -1 then  --平民
		
			titleName = '平民'
		else
			
			titleName = titleData.Name1  --当前爵位
		end
		view.textthecurrenttitle:GetComponent('TextMeshProUGUI').text = '当前爵位：  '..titleName	--当前爵位
		
		local warRamk = data.war_rank --战阶
		local warRamkName = pvpCamp.Rank[warRamk].Name1   --战阶名字
		view.textenchbattleorder:GetComponent('TextMeshProUGUI').text = '当前战阶：  '..warRamkName --战阶
		view.textsix:GetComponent('TextMeshProUGUI').text = '第'..warRamk..'阶' --
		view.textgeneral1:GetComponent('TextMeshProUGUI').text = warRamkName
		
		local addPrestige = pvpCamp.Rank[warRamk].PrestigeAddition * 100
		view.textWarLevelDescrip:GetComponent('TextMeshProUGUI').text = '战阶在每天凌晨五点按照威望值提升。当前击杀威望： +'..addPrestige..'%'		--威望加成描述

		local descrip =  SkillAPI.GetBuffDescription(513, warRamk)
		view.TextWarSoulDescrip:GetComponent('TextMeshProUGUI').text = '觉醒后，' .. descrip
		
		local nextWarRamk = warRamk + 1
		local nextWarRamkTable = pvpCamp.Rank[nextWarRamk]
		if nextWarRamkTable then
		
			local nextWarRamkName = nextWarRamkTable.Name1   --战阶名字
			view.textseven:GetComponent('TextMeshProUGUI').text = '第'..nextWarRamk..'阶' --
			view.textgenera2:GetComponent('TextMeshProUGUI').text = nextWarRamkName		--下一阶name
			
			--当前威望进度
			local process = data.prestige / nextWarRamkTable.RequirePrestige
			view.textLavelBar:GetComponent('TextMeshProUGUI').text = data.prestige..'/'..nextWarRamkTable.RequirePrestige
			view.bgprogressbarred:GetComponent('Image').fillAmount = process
		else
			
			view.textseven:GetComponent('TextMeshProUGUI').text = '---' --
			view.textgenera2:GetComponent('TextMeshProUGUI').text = '---'		--下一阶name
			
			view.textLavelBar:GetComponent('TextMeshProUGUI').text = '100'..'/'..'100'
			view.bgprogressbarred:GetComponent('Image').fillAmount = 1
		end
		
		local countryName = '炎黄联盟'
		if data.country == 1 then		--所在国家
		
			countryName = '九黎联盟'
		elseif data.country == 2 then
		
			countryName = '炎黄联盟'
		end
		view.textChinesealliance:GetComponent('TextMeshProUGUI').text = countryName
		view.textyellowChinesealliance:GetComponent('TextMeshProUGUI').text = countryName
		
		local inputField = view.bgcampmessagebox:GetComponent('TMP_InputField')			--编辑公告
		inputField.text = data.declaration
		view.textcampmessage:GetComponent('TextMeshProUGUI').text = data.declaration		--显示公告
		
		view.textcampaignfunds3:GetComponent('TextMeshProUGUI').text = data.salary --俸禄
		--local image = view.btngettherewards:GetComponent('Image')
		if data.is_get_war_rank_reward then    						--奖励已领取
			btngettherewardsImg.material = UIGrayMaterial.GetUIGrayMaterial()
			view.textgettherewards:GetComponent('TextMeshProUGUI').text = '已领取'
			icongettherewardsImg.material = UIGrayMaterial.GetUIGrayMaterial()
		else
			btngettherewardsImg.material = nil
			icongettherewardsImg.material = nil
			view.textgettherewards:GetComponent('TextMeshProUGUI').text = '领取奖励'
		end
		
		--print('data.is_on_battle_saul = ', tostring(data.is_on_battle_saul))
		image = view.btnWarSoulAwake:GetComponent('Image')
		local battleSaulRemainTime = data.battle_saul_remain_time
		if battleSaulRemainTime > 0 then     --战魂已经觉醒
		
			image.material = UIGrayMaterial.GetUIGrayMaterial()
			view.textWarSoulAwake:GetComponent('TextMeshProUGUI').text = '已觉醒'
			
			if not warSoulTotalTime then
		
				local timeValue = growingSkillScheme.Buff[513].time	--math.floor(tonumber(pvpCamp.Parameter[5].Value))
				warSoulTotalTime = timeValue / 1000
			end
			
			warSoulTimeLeft = battleSaulRemainTime
			view.TextWarSoulTic:SetActive(true)
			view.eff_UIzhanhun:SetActive(true)
			--SetWarSooulProgress(warSoulTimeLeft)
			if not warSoulTimerInfo then
		
				warSoulTimerInfo = Timer.Repeat(0.02, UpdateWarSooulValue)
				view.WarSoulValue:SetActive(true)				--
				view.WarSoulSlider:SetActive(true)	
			end
			--view.WarSoulValue:GetComponent('Image').fillAmount = (warSoulTotalTime - battleSaulRemainTime) / warSoulTotalTime
		end
	end
	
	self.GetCountryBasicRet = function(data)      --服务端返回国家基础信息
	
		--for k, v in pairs(data) do
		
			--print('k = ', k)
		--end
		campBaseData = data
		SetCampAttr(data)
	end
	
	--local OnGetSalary = function()			--领取俸禄
		--UIManager.ShowNotice('功能暂未开放')
		--return
	--end
	
	local OnEditorNotice = function() 		--编辑公告
		if 1 then   --暂时关闭编辑功能
			UIManager.ShowNotice('功能暂未开放')
			return
		end
		
		local text = view.texteditor:GetComponent('TextMeshProUGUI').text
		if text == '编辑' then		--编辑
		
			view.texteditor:GetComponent('TextMeshProUGUI').text = '保存' 		
			view.bgcampmessagebox:SetActive(true)			--编辑公告
			view.textcampmessage:SetActive(false)		--显示公告
		elseif text == '保存' then	--保存
		
			view.texteditor:GetComponent('TextMeshProUGUI').text = '编辑' 		
			view.bgcampmessagebox:SetActive(false)			--编辑公告
			view.textcampmessage:SetActive(true)		--显示公告
			
			--修改公告
			local data = {}
			
			data.content = view.bgcampmessagebox:GetComponent('TMP_InputField').text --需要改变的新内容
			--print('data.content = ', data.content)
			data.func_name = 'on_change_country_declaration'		--改变阵营宣言
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data) 
		else
		
			print('error')
			return
		end
	end
	
	local RequstAwakenWarSoul = function()  --请求战魂觉醒
	
		local data = {}
		data.func_name = 'on_get_battle_saul'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local OnAwakenWarSoul = function()		--战魂觉醒

		local image = view.btnWarSoulAwake:GetComponent('Image')	
		if image.material == UIGrayMaterial.GetUIGrayMaterial() or not campBaseData then		--有材质说明image已经变灰,代表战魂已经觉醒
		
			return
		end
		
		local data = {}
		data.title = '战魂觉醒'
		
		local value = tonumber(pvpCamp.Parameter[4].Value)
		local warRamk = campBaseData.war_rank 		--战阶
		local nextWarRamk = warRamk + 1
		local nextWarRamkTable = pvpCamp.Rank[nextWarRamk]
		value = value * nextWarRamkTable.RequirePrestige / 100
			
		if not warSoulTotalTime then
		
			local timeValue = growingSkillScheme.Buff[513].time	--math.floor(tonumber(pvpCamp.Parameter[5].Value))
			warSoulTotalTime = timeValue / 1000
			--warSoulTotalTime = timeValue / (1000 * 60)
		end
		
		data.content = '觉醒战魂需要消耗威望值，确定消耗'..value..'威望来激活战魂'..(warSoulTotalTime / 60)..'分钟？'
		data.okHandler = RequstAwakenWarSoul
		data.identifier = 'RequstAwakenWarSoul'
		UIManager.PushView(ViewAssets.CommTipBox1,
							function(ctrl)
								ctrl.Show(data)
							end)
	end
	
	local OnShowRewards = function()		--显示当前战阶奖励内容
		if icongettherewardsImg.material == UIGrayMaterial.GetUIGrayMaterial() then
			return
		end
	
		local rewardsData = {}
		if not campBaseData then
		
			return
		end
		
		local warRamkId = campBaseData.war_rank 		--战阶
		local warRamk = pvpCamp.Rank[warRamkId]

		rewardsData.items = {}
		for i = 1, 4 do
		
			local reward = 'Reward'..i
			local warRamkList = warRamk[reward]
			if warRamkList and #warRamkList > 0 then
				rewardsData.items[warRamk[reward][1]] = warRamk[reward][2]
			end
		end
		
		rewardsData.title = '战阶奖励'
		UIManager.PushView(ViewAssets.CommRewardsBox,
			function(ctrl)
				ctrl.Show(rewardsData)
			end)
	end
	
	local OnGetRewards = function()    		--获取奖励
	
		local image = view.btngettherewards:GetComponent('Image')
		if image.material == UIGrayMaterial.GetUIGrayMaterial() then	--有材质说明image已经变灰,代表奖励已经领取
		
			return
		end
		
		local data = {}
		data.func_name = 'on_get_war_rank_reward'

		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.GetWarRankRewardRet = function(data)  --服务端战阶奖励
	
	--[[
		local rewardsData = {}
		rewardsData.items = data.rewards
		rewardsData.title = '领取战阶奖励'
		UIManager.PushView(ViewAssets.CommRewardsBox)
		UIManager.GetCtrl(ViewAssets.CommRewardsBox).Show(rewardsData)
		]]
		local image = view.btngettherewards:GetComponent('Image')  --已领取奖励
		image.material = UIGrayMaterial.GetUIGrayMaterial()
		view.textgettherewards:GetComponent('TextMeshProUGUI').text = '已领取'
		icongettherewardsImg.material = UIGrayMaterial.GetUIGrayMaterial()
	end
	
	self.GetBattleSaulRet = function(data)		--服务端战魂反馈
		if not data.prestige then
			return
		end
	
		local image = view.btnWarSoulAwake:GetComponent('Image')	--战魂已经觉醒
		image.material = UIGrayMaterial.GetUIGrayMaterial()
		view.textWarSoulAwake:GetComponent('TextMeshProUGUI').text = '已觉醒'
		
		if not campBaseData  then
		
			return
		end
		
		local warRamk = campBaseData.war_rank 		--战阶
		local nextWarRamk = warRamk + 1
		local nextWarRamkTable = pvpCamp.Rank[nextWarRamk]
		if nextWarRamkTable then
		
			local process = data.prestige / nextWarRamkTable.RequirePrestige
			view.textLavelBar:GetComponent('TextMeshProUGUI').text = data.prestige..'/'..nextWarRamkTable.RequirePrestige
			view.bgprogressbarred:GetComponent('Image').fillAmount = process
		end
		
		local battleSaulRemainTime = data.battle_saul_remain_time
		if battleSaulRemainTime > 0 then
		
			warSoulTimeLeft = battleSaulRemainTime
			view.TextWarSoulTic:SetActive(true)
			view.eff_UIzhanhun:SetActive(true)
			if not warSoulTimerInfo then
		
				warSoulTimerInfo = Timer.Repeat(0.02, UpdateWarSooulValue)
				view.WarSoulValue:SetActive(true)				--
				view.WarSoulSlider:SetActive(true)				--
			end
		end
	end
	
	self.ChangeCountryDeclarationRet = function(data)	--服务端公告宣言反馈
	
		view.bgcampmessagebox:GetComponent('TMP_InputField').text = data.content		--编辑公告
		view.textcampmessage:GetComponent('TextMeshProUGUI').text = data.content		--显示公告
	end
	
	local OnReceive = function()		--领取俸禄
		local data = {}
		data.func_name = 'on_get_salary'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		return
	end
	
	self.GetSalaryRet = function(data)  --领取俸禄返回
		if data.result == 0 then
			view.textcampaignfunds3:GetComponent('TextMeshProUGUI').text = '0'
		end
	end
	
	self.OnAssignSalary = function()   --发放薪水
		if view.btnsalary:GetComponent("Image").material.name == "Gray" then
			return
		end
	
		local data = {}
		data.func_name = 'on_pay_salary'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.PaySalaryRet = function(data)  --发放薪水返回
		local salary = data.salary
		if salary then
			view.textcampaignfunds3:GetComponent('TextMeshProUGUI').text = salary
		end
		
		local countryFund = data.country_fund
		if countryFund then
			view.textcampaignfunds2:GetComponent('TextMeshProUGUI').text = countryFund
		end
	end

    self.onLoad = function()
        view = self.view
        ClickEventListener.Get(view.btnsalary).onClick = self.OnAssignSalary
		ClickEventListener.Get(view.btneditor).onClick = OnEditorNotice
		ClickEventListener.Get(view.btnWarSoulAwake).onClick = OnAwakenWarSoul
		ClickEventListener.Get(view.icongettherewards).onClick = OnShowRewards
		ClickEventListener.Get(view.btngettherewards).onClick = OnGetRewards
		ClickEventListener.Get(view.btnreceive).onClick = OnReceive
		
		btngettherewardsImg = view.btngettherewards:GetComponent('Image')
		icongettherewardsImg = view.icongettherewards:GetComponent('Image')
		
		view.bgcampmessagebox:SetActive(false)			--编辑公告
		view.textcampmessage:SetActive(true)			--显示公告
		view.WarSoulValue:SetActive(false)				--
		view.WarSoulSlider:SetActive(false)				--
		view.TextWarSoulTic:SetActive(false)
		view.eff_UIzhanhun:SetActive(false)
		
		MessageRPCManager.AddUser(self, 'GetCountryBasicRet')
		local data = {}
		data.func_name = 'on_get_country_basic'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)      --请求获取国家基础信息
		MessageRPCManager.AddUser(self, 'GetBattleSaulRet')						--获取战魂信息
		MessageRPCManager.AddUser(self, 'GetWarRankRewardRet')					--获取战阶奖励
		MessageRPCManager.AddUser(self, 'ChangeCountryDeclarationRet')			--改变阵营宣言
		MessageRPCManager.AddUser(self, 'GetSalaryRet')							--获取薪水
		MessageRPCManager.AddUser(self, 'PaySalaryRet')							--发放薪水
	end

    self.onUnload = function()

		MessageRPCManager.RemoveUser(self, 'GetCountryBasicRet')
		MessageRPCManager.RemoveUser(self, 'GetBattleSaulRet')
		MessageRPCManager.RemoveUser(self, 'ChangeCountryDeclarationRet')
		MessageRPCManager.RemoveUser(self, 'GetWarRankRewardRet')
		MessageRPCManager.RemoveUser(self, 'GetSalaryRet')
		MessageRPCManager.RemoveUser(self, 'PaySalaryRet')
		
		sliderScript = nil
		btngettherewardsImg = nil
		icongettherewardsImg = nil
		
		if warSoulTimerInfo then
		
			Timer.Remove(warSoulTimerInfo)
			warSoulTimerInfo = nil
		end
    end

    return self
end

return CreateCampBaseUICtrl()

