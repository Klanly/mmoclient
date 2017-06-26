--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2017/2/7
--
require "UI/Controller/LuaCtrlBase"

-------------------------共用的数据和函数-----------------
local petDataShared

local GetPetModelRes = function(stage)  --获取宠物模型
	local modelRes
	local modelKey = 'ModelID'	--默认第一种外观
	if stage == 2 or stage == 3 then   --为第二种外观和第三种外观时
		
		modelKey = modelKey .. stage
	end
	local modelId = GrowingPet.Attribute[petDataShared.pet_id][modelKey]
	modelRes = artResourceScheme.Model[modelId].Prefab
	
	return modelRes
end

local GetPetShowStageKey = function(petData, stage, selfFeature)
	local stagekey = 'PetShowStageKey'
	local loginData = MyHeroManager.heroData
	local actorId = loginData.actor_id
	
	stagekey = stagekey .. actorId .. petData.entity_id .. stage .. selfFeature
	return stagekey
end
------------------------------------------------------------------------
--宠物排行start
--------------------------------------------------------------------------
local CreateRankItems = function()
	local self = CreateObject()
	
	self.isExpand = true
    self.toPos = Vector2.zero
    self.duration = 0.2
	self.items = {}

	self.CollapseImmediately = function()
        for k, v in pairs(self.items) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = self.toPos
            v.gameObject:SetActive(false)
        end
        self.isExpand = false
    end
    self.ExpandImmediately = function()
        for k, v in pairs(self.items) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = v.defaultPos
        end
        self.isExpand = true
    end
    self.Collapse = function() 
        for k, v in pairs(self.items) do
            BETween.anchoredPosition(v.gameObject, self.duration, self.toPos).onFinish = function()
                v.gameObject:SetActive(false)
            end
        end
        self.isExpand = false
    end

    self.Expand = function() 
        for k, v in pairs(self.items) do
            v.gameObject:SetActive(true)
            BETween.anchoredPosition(v.gameObject, self.duration, v.defaultPos)
        end
		
        self.isExpand = true
    end

    self.Switch = function()
        if self.isExpand then
            self.Collapse()
        else
            self.Expand()
        end
    end
		
	return self
end

-----------------------------------------------------------------------------------
local CreateStarRank = function(view, ctrl)				--宠物星级排行榜

	local self = CreateObject()
	--local base = self.base()
	
	local Init = function()
	
		view.starrankselectbox:SetActive(false)
	end
	
	self.OnSelected = function(flag)
	
		view.starrankselectbox:SetActive(flag)
	end
	
	Init()
	return self
end

----------------------------------------------------------------------------------

local CreateHonorRank = function(view, ctrl)				--宠物资质排行榜
	local self = CreateRankItems()
	local base = self.base()
	
	local HideAllItemsSelected = function()
	
		for i = 1, 5 do
		
			view['honorItemselct'..i]:SetActive(false)
		end
	end
	
	local OnSelectItem = function(index)
	
		HideAllItemsSelected()
		view['honorItemselct'..index]:SetActive(true)
		ctrl.RequstRankData(index + 1)
	end
	
	local Init = function()
	
		view.honorrankselectbox:SetActive(false)
		for i = 1, 5 do
		
			view['honorItemselct'..i]:SetActive(false)
			ClickEventListener.Get(view['honorItembg'..i]).onClick = function() OnSelectItem(i)  end
		end
		
		self.items = {
			[1] = {
				gameObject = view.honorItem1,
				defaultPos = Vector2.New(136, 306)--view.honorItem1:GetComponent("RectTransform").anchoredPosition,
			},
			[2] = {
				gameObject = view.honorItem2,
				defaultPos = Vector2.New(132, 271) --view.honorItem2:GetComponent("RectTransform").anchoredPosition,
			},
			[3] = {
				gameObject = view.honorItem3,
				defaultPos = Vector2.New(134, 225)--view.honorItem3:GetComponent("RectTransform").anchoredPosition,
			},
			[4] = {
				gameObject = view.honorItem4,
				defaultPos = Vector2.New(134, 187)--view.honorItem4:GetComponent("RectTransform").anchoredPosition,
			},
			[5] = {
				gameObject = view.honorItem5,
				defaultPos = Vector2.New(136, 149)--view.honorItem5:GetComponent("RectTransform").anchoredPosition,
			},
		}
		self.toPos = Vector2.New(136, 386)--view.honorrankmain:GetComponent("RectTransform").anchoredPosition
	end
	
	self.OnSelected = function(flag)
	
		view.honorrankselectbox:SetActive(flag)
	end
	
	self.CollapseImmediately = function()
  
		base.CollapseImmediately()
		HideAllItemsSelected()
		BETween.rotation(view.honoriconuparrow, self.duration, Vector3.New(0, 0, 0)) 
    end
	
    self.ExpandImmediately = function()
	
		base.ExpandImmediately()
		OnSelectItem(1)
		BETween.rotation(view.honoriconuparrow, self.duration, Vector3.New(0, 0, 180))
    end
	
	self.Collapse = function() 

		base.Collapse()
		HideAllItemsSelected()
		BETween.rotation(view.honoriconuparrow, self.duration, Vector3.New(0, 0, 0)) 
    end

    self.Expand = function() 

		base.Expand()
		OnSelectItem(1)
		BETween.rotation(view.honoriconuparrow, self.duration, Vector3.New(0, 0, 180))
    end

	Init()
	return self
end

---------------------------------------------------------------------------------
local CreateLowRank = function(view, ctrl)				--宠物初始排行
	local self =  CreateRankItems()
	local base = self.base()
	local topPos
	local bottomPos
	
	self.SetPara = function(tPos, bPos)
	
		topPos = tPos
		bottomPos = bPos
	end
	
	local HideAllItemsSelected = function()
	
		for i = 1, 5 do
		
			view['lowrankItemselct'..i]:SetActive(false)
		end
	end
	
	self.OnSelected = function(flag)
	
		view.lowrankselectbox:SetActive(flag)
	end
	
	local OnSelectItem = function(index)
	
		for i = 1, 5 do
		
			view['lowrankItemselct'..i]:SetActive(false)
		end
		view['lowrankItemselct'..index]:SetActive(true)
		
		ctrl.RequstRankData(index + 6)
	end
	
	self.MoveTop = function(isPriority)
	
		if isPriority then
			view.LowRank:GetComponent("RectTransform").anchoredPosition = topPos
		else 
			BETween.anchoredPosition(view.LowRank, self.duration, topPos)
		end
	end
	
	self.MoveBottom = function(isPriority)
	
		if isPriority then
			view.LowRank:GetComponent("RectTransform").anchoredPosition = bottomPos
		else
			BETween.anchoredPosition(view.LowRank, self.duration, bottomPos)
		end
	end
	
	self.CollapseImmediately = function()
  
		base.CollapseImmediately()
		HideAllItemsSelected()
		BETween.rotation(view.lowrankicondownarrow, self.duration, Vector3.New(0, 0, 0)) 
    end
	
    self.ExpandImmediately = function()
	
		base.ExpandImmediately()
		--view.lowrankItemselct1:SetActive(true)
		OnSelectItem(1)
		BETween.rotation(view.lowrankicondownarrow, self.duration, Vector3.New(0, 0, 180))
    end
	
	self.Collapse = function() 

		base.Collapse()
		HideAllItemsSelected()
		BETween.rotation(view.lowrankicondownarrow, self.duration, Vector3.New(0, 0, 0)) 
    end

    self.Expand = function() 

		base.Expand()
		--view.lowrankItemselct1:SetActive(true)
		OnSelectItem(1)
		BETween.rotation(view.lowrankicondownarrow, self.duration, Vector3.New(0, 0, 180))
    end
	
	
	local Init = function()
	
		view.lowrankselectbox:SetActive(false)
		view.honorrankselectbox:SetActive(false)
		for i = 1, 5 do
		
			view['lowrankItemselct'..i]:SetActive(false)
			ClickEventListener.Get(view['lowrankItembg'..i]).onClick = function() OnSelectItem(i)  end
		end
		
	
		self.items = {
			[1] = {
				gameObject = view.lowrankItem1,
				defaultPos = Vector2.New(136, 306)--view.lowrankItem1:GetComponent("RectTransform").anchoredPosition,
			},
			[2] = {
				gameObject = view.lowrankItem2,
				defaultPos = Vector2.New(132, 271)--view.lowrankItem2:GetComponent("RectTransform").anchoredPosition,
			},
			[3] = {
				gameObject = view.lowrankItem3,
				defaultPos = Vector2.New(134, 225)--view.lowrankItem3:GetComponent("RectTransform").anchoredPosition,
			},
			[4] = {
				gameObject = view.lowrankItem4,
				defaultPos = Vector2.New(134, 187)--view.lowrankItem4:GetComponent("RectTransform").anchoredPosition,
			},
			[5] = {
				gameObject = view.lowrankItem5,
				defaultPos = Vector2.New(136, 149)--view.lowrankItem5:GetComponent("RectTransform").anchoredPosition,
			},
		}
		
		self.toPos = Vector2.New(136, 386)--view.lowrankmain:GetComponent("RectTransform").anchoredPosition
		local tPos = Vector2.New(607, 319)--view.HonorRank:GetComponent("RectTransform").anchoredPosition
		local bPos = Vector2.New(607.00378417969, -106)--view.LowRank:GetComponent("RectTransform").anchoredPosition
		tPos.y = tPos.y - 80
		self.SetPara(tPos, bPos)
	end
	
	Init()
	return self
end
-------------------------------------------------------------------------------------------------
local CreateRankingListUICtl = function(view, petData)    --宠物排行榜
	local self = CreateObject()
	
	local starRank 	--星级榜
	local honorRank --资质榜
	local lowRank 	--初始榜
	local rankData	--排行榜数据
	local rankType = 1
	local rankkey = {  "pet_score",                         --宠物评分
						"physic_attack_quality",             --物理攻击资质
						"magic_attack_quality",              --魔法攻击资质
						"physic_defence_quality",            --物理防御资质
						"magic_defence_quality",             --魔法防御资质
						"hp_max_quality",                    --最大生命资质
						"base_physic_attack",                --基础物理攻击
						"base_magic_attack",                 --基础魔法攻击
						"base_physic_defence",               --基础物理防御
						"base_magic_defence",                --基础魔法防御
						"base_hp_max",                       --基础最大生命
					}
	local rankBaseTitle = {  '星级值','物攻资质', '法攻资质', '物防资质', '法防资质', '生命资质',
							'物理攻击', '法术攻击', '物理防御', '法术防御', '生命值'  }
	
	self.RequstRankData = function(rType)
	
		local data = {}   
		data.func_name = 'on_get_pet_rank_list'
		data.pet_id = petDataShared.pet_id
		data.pet_uid = petDataShared.entity_id
		data.rank_name = rankkey[rType]
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		view.textattackqualification:GetComponent('TextMeshProUGUI').text = rankBaseTitle[rType]
		rankType = rType
	end
	
	local StarRankSwitch = function()
	
		starRank.OnSelected(true)
		honorRank.OnSelected(false)
		lowRank.OnSelected(false)
		self.RequstRankData(1)
	end
	
	local HonorRankSwitch = function()   --选择资质排行button
	
		if honorRank.isExpand then
		
			lowRank.MoveTop(false)
		else
		
			lowRank.CollapseImmediately()
			lowRank.MoveBottom(true)
		end
	
		honorRank.Switch()
		honorRank.OnSelected(true)
		starRank.OnSelected(false)
		lowRank.OnSelected(false)
	end
	
	local LowRankSwitch = function()	--选择初始排行button
	
		if not lowRank.isExpand and honorRank.isExpand then
		
			honorRank.CollapseImmediately()
			lowRank.MoveTop(true)
		end

		lowRank.Switch()
		lowRank.OnSelected(true)
		honorRank.OnSelected(false)
		starRank.OnSelected(false)
	end
	
	local onItemUpdate = function(go, index)
	
		rankIndex = index + 1
		if rankData and rankIndex > 0 then
		
			local rankItem = rankData[rankIndex]
			for i = 1, 3 do
			
				go.transform:FindChild('@Top'..i).gameObject:SetActive(rankIndex == i)
			end
			local topNum = go.transform:FindChild('@TopNum')
			topNum.gameObject:SetActive(rankIndex > 3)
			
			if rankIndex > 3 then
				
				topNum:GetComponent('TextMeshProUGUI').text = rankIndex
			end

			go.transform:FindChild('@textplayerpet2'):GetComponent('TextMeshProUGUI').text = rankItem.pet_name
			go.transform:FindChild('@textplayername1'):GetComponent('TextMeshProUGUI').text = rankItem.owner_name
			go.transform:FindChild('@text2016'):GetComponent('TextMeshProUGUI').text = rankItem.value
		end
	end
	
	local SetSelfRankItem = function(selfdata)
	
		local selfIndex = selfdata.self_index
		for i = 1, 3 do
		
			view['selfTop'..i]:SetActive(selfIndex == i)
		end
		
		view.selfTopNum:SetActive(true)
		if selfIndex == -1 then
		
			view.selfTopNum:GetComponent('TextMeshProUGUI').text = '未入榜'
		elseif selfIndex > 3 then
		
			view.selfTopNum:GetComponent('TextMeshProUGUI').text = selfIndex
		else
		
			view.selfTopNum:SetActive(false)
		end
		
		view.selftextplayerpet2:GetComponent('TextMeshProUGUI').text = selfdata.pet_name
		view.selftextplayername1:GetComponent('TextMeshProUGUI').text = selfdata.owner_name
		view.selftext2016:GetComponent('TextMeshProUGUI').text = selfdata.value
	end
	
	local Init = function()
	
		starRank = CreateStarRank(view, self)
		honorRank = CreateHonorRank(view, self)
		honorRank.CollapseImmediately()
		
		lowRank = CreateLowRank(view, self)
		lowRank.CollapseImmediately()
		lowRank.MoveTop(true)
		
		starRank.OnSelected(true)
		self.scrollview = view.rankScrollview:GetComponent(typeof(UIMultiScroller))

		ClickEventListener.Get(view.bgstarblackbox1).onClick = StarRankSwitch
		ClickEventListener.Get(view.honorrankbg).onClick = HonorRankSwitch
		ClickEventListener.Get(view.lowrankbg).onClick = LowRankSwitch
		ClickEventListener.Get(view.RankingListiconquit).onClick = self.onUnload
	end
	
	self.GetPetRankListRet = function(data)		--获取排行榜反馈
	
		local rankList = data.rank_list
		local rankName = rankList.rank_name
		if rankName ~= rankkey[rankType] then
		
			return
		end
		rankData = rankList.rank_data
		self.scrollview:UpdateData(#rankData, onItemUpdate)
		
		local selfData = data.self_data
		SetSelfRankItem(selfData)
	end
	
	self.onLoad = function()
	
		StarRankSwitch()
		view.RankingListui:SetActive(true)
		self.scrollview:Init(view.rankitem, 909, 70, 5, 15, 1)
		MessageRPCManager.AddUser(self, 'GetPetRankListRet')	--获取宠物排行榜反馈
	end

	
	self.onUnload = function()
	
		honorRank.CollapseImmediately()
		lowRank.CollapseImmediately()
		lowRank.MoveTop(true)
		MessageRPCManager.RemoveUser(self, 'GetPetRankListRet')
		view.RankingListui:SetActive(false)
	end
	
	Init()
	return self
end


--宠物排行end
---------------------------------------------------------------------------------

------------------------------------------宠物外观 Start


local CreatePetShowConsume = function(view)		--购买宠物外观商店页面
	local self = CreateObject()
	--local petData
	local stage
	local selectIndex =  1
	local DaysSeg = {'Buy7Days', 'Buy30Days', 'PermanentPurchase'}
	local serverDaysSeg = {'7days', '30days', 'permanent'}
	
	local RequestBuyPetAppearance = function()  --购买宠物外观
	
		local data = {}
		data.func_name = 'on_buy_pet_appearance'

		--for k, v in pairs(petData) do
		
			--print('k = ', k)
		--end
		--data.pet_index = petData.mainPetIndex
		data.pet_uid = petDataShared.entity_id
		data.appearance_rank = stage
		data.time_mode = serverDaysSeg[selectIndex]
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local OnOk = function()
	
		RequestBuyPetAppearance()
		self.OnHide()
	end
	
	local ShowConsume = function(index)

		if not stage then
		
			return
		end
		
		local petShowList = GrowingPet.Shape[stage]
		local consumes = petShowList[DaysSeg[index]]
		local itemId = consumes[1]
		local value = consumes[2]
		local iconName = commonItem.Item[itemId].Icon
		local sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s", iconName))
		view.iconAcer:GetComponent('Image').overrideSprite = sprite
		view.dataconsume:GetComponent('TextMeshProUGUI').text = value
	end
	
	local OnSelectDays = function(index)
	
		for i = 1, 3 do
		
			view['imgclickdays'..i]:SetActive(index == i)
		end
		selectIndex = index
		ShowConsume(index)
	end
	
	local Init = function()
	
		for i = 1, 3 do
			ClickEventListener.Get(view['btnbg'..i]).onClick = function() OnSelectDays(i) end
		end
		
		ClickEventListener.Get(view.consumebtnclose).onClick = self.OnHide
		ClickEventListener.Get(view.btncancel).onClick = self.OnHide
		ClickEventListener.Get(view.btnbuy).onClick = OnOk
	
		OnSelectDays(selectIndex)
		self.OnHide()
	end
	
	self.SetPetData = function(data)
	
		--petData = data.petData
		stage = data.stage
		ShowConsume(selectIndex)
	end
	

	self.BuyPetAppearanceRet = function(data)
	
		
	end
	
	
	self.OnShow = function()
	
		view.purchase1:SetActive(true)
		MessageRPCManager.AddUser(self, 'BuyPetAppearanceRet')	--购买宠物外观反馈
	end
	
	self.OnHide = function()
	
		view.purchase1:SetActive(false)
		MessageRPCManager.RemoveUser(self, 'BuyPetAppearanceRet')
		MessageRPCManager.RemoveUser(self, 'PetAppearanceChanged')
	end
	
	Init()
	return self
end

----------------------------------------------------------------------

local CreateActivePetShow = function(view, petData) 		--激活宠物外观页
	local self = CreateObject()
	local duration = 1
	local petShowConsume
	local rankingListUICtl
	local stage = 1
	local isActive = true
	local changeDesKey = 'BaseCondition'
	local stateType = 1  --为1代表是无激活条件，2代表解锁条件，3代表激活条件
	local isExpand = false
	
	local OnLoadPetRank = function()
	
		rankingListUICtl.onLoad()
	end
	
	local OnBuy = function()
	
		local image = view.iconbuy:GetComponent('Image')
		if image.material == UIGrayMaterial.GetUIGrayMaterial() then
		
			return
		end
	
		local data = {}
		data.petData = petDataShared
		data.stage = stage
		petShowConsume.SetPetData(data)
		petShowConsume.OnShow()
	end
	
	local OnActive = function()
	
		local image = view.iconactivation:GetComponent('Image')
		if image.material == UIGrayMaterial.GetUIGrayMaterial() then
		
			return
		end
			
		local data = {}
		data.func_name = 'on_change_pet_appearance'
		--data.pet_index = petData.mainPetIndex
		data.pet_uid = petDataShared.entity_id
		data.appearance_rank = stage
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.PetDataUpdata = function()
	
		
	end
	
	local Init = function()
	
		petShowConsume = CreatePetShowConsume(view)
		rankingListUICtl = CreateRankingListUICtl(view, petDataShared)
		ClickEventListener.Get(view.iconbuy).onClick = OnBuy
		ClickEventListener.Get(view.iconactivation).onClick = OnActive
		ClickEventListener.Get(view.textview).onClick = OnLoadPetRank
		view.eff_UIchongwujinjie_show:SetActive(false)
	end
	
	local SetBuyButton = function(flag)
	
		local image = view.iconbuy:GetComponent('Image')
		if flag then
			image.material = nil
		else
			image.material = UIGrayMaterial.GetUIGrayMaterial()
		end
	end
	
	local SetActiveButton = function(flag)
	
		local image = view.iconactivation:GetComponent('Image')
		if flag then
		
			image.material = nil
		else
		
			image.material = UIGrayMaterial.GetUIGrayMaterial()
		end
	end
	
	local SetCondition = function(condition)
	
		local petShowList = GrowingPet.Shape[stage]
		local unlockLv = petShowList.UnlockLv
		local starRanking = petShowList.StarRanking
		local propertyRanking = petShowList.PropertyRanking
		
		condition.title = '使用条件'
		condition.title1 = '该宠物星级排名前' .. starRanking
		condition.title2 = '该宠物任意一项初始属性或则资质排名前' .. propertyRanking
		condition.title3 = '未购买'
			
		local petScoreRank = petDataShared.pet_score_rank
		if petScoreRank ~= -1 and petScoreRank <= starRanking then
				
			condition.isOk1 = true
			stateType = 3
		end
				
		local highestPropertyRank = petDataShared.highest_property_rank
		if highestPropertyRank ~= -1  and highestPropertyRank <= propertyRanking then
				
			condition.isOk2 = true
			stateType = 3
		end
				
		local lastTime = petDataShared.appearance_expire_time[stage]
				--buy_time
		if lastTime > 0 then
			
			local serverSecondTimestamp = networkMgr:GetConnection().ServerSecondTimestamp
			local diffTime = lastTime - serverSecondTimestamp
			local initDays = diffTime / (60 * 60 * 24)
			local days = math.floor(initDays)
			if days >= 36500 then  --永久
				condition.title3 = '在购买期限内（永久有效）'
				condition.canBuy = false
			else
				condition.title3 = '在购买期限内（时效' .. days .. '天）'
				condition.canBuy = true
			end
			condition.isOk3 = true
			stateType = 3
		end
		
		if stateType ~= 3 then
			condition.canActive = false
		else
			condition.canActive = true
		end
	end
	
	local GetActiveCondition = function(stage, showState)
		local condition = {}
		condition.canActive = false
		condition.canBuy = false
		condition.isOk1 = false
		condition.isOk2 = false
		condition.isOk3 = false
		condition.activeDsc = '(满足一下任何条件即可使用)'
		
		local petShowList = GrowingPet.Shape[stage]
		local unlockLv = petShowList.UnlockLv
		local changeKey = GetPetShowStageKey(petDataShared, stage, changeDesKey)
		local changeFlag = UnityEngine.PlayerPrefs.GetString(changeKey, '0')
		
		if stage == 1 or showState == 1 or changeFlag == '0' then
		
			condition.title1 = ' '
			condition.title2 = ' '
			condition.title3 = ' '
			condition.canActive = false
			condition.canBuy = false
			
			if stage == 1 then
				condition.title = '初始外观'
				condition.activeDsc = '(无使用条件)'
				condition.canActive = true
				condition.title1 = '初始外观默认解锁，且无需使用条件'
				condition.title2 = '初始外观可以永久使用，无需购买'
				stateType = 1
			elseif showState == 1 or changeFlag == '0' then
				condition.title = '解锁条件'
				condition.title2 = unlockLv .. '级解锁（解锁后，需达成使用条件，方可使用）'
				condition.activeDsc = '(达成解锁条件后，会显示使用条件)'
				stateType = 2
			end
			return condition
		end
		
		condition.canBuy = true
		if showState >= 2 then	--达到解锁条件
			SetCondition(condition)
		end

		return condition
	end
	
	local ShowContent = function(data, stage, showState, isActive)   --显示使用页内容
	
		local color1 = Color.New(39 / 255, 9 / 255, 2 / 255)
		local color2 = Color.New(255 / 255, 207 / 255, 79 / 255)

		SetBuyButton(data.canBuy)
		SetActiveButton(data.canActive)
		view.texttitle:GetComponent('TextMeshProUGUI').text = data.title
		view.textAnyactivation:GetComponent('TextMeshProUGUI').text = data.activeDsc
		
		local prtstarText = view.textprtstar:GetComponent('TextMeshProUGUI')
		prtstarText.text = data.title1
		if data.isOk1 then
		
			prtstarText.text = prtstarText.text .. '（已达成）'
			prtstarText.color = color2
		else
		
			prtstarText.color = color1
		end
		
		local petattributeText = view.textPetattribute:GetComponent('TextMeshProUGUI')
		petattributeText.text = data.title2
		if data.isOk2 then
		
			petattributeText.text = petattributeText.text .. '（已达成）'
			petattributeText.color = color2
		else
		
			petattributeText.color = color1
		end
		
		local purchaseText = view.textpurchase:GetComponent('TextMeshProUGUI')
		purchaseText.text = data.title3
		if data.isOk3 then
		
			purchaseText.color = color2
		else
		
			purchaseText.color = color1
		end
	end
	
	local TextFadeIn = function(textObject)
		BETween.alpha(textObject, 1, 0, 1)
	end
	
	local StartFadeIn = function()
	
		local condition = {}
		condition.canActive = true
		condition.canBuy = true
		condition.isOk1 = false
		condition.isOk2 = false
		condition.isOk3 = false
		condition.activeDsc = '(满足一下任何条件即可使用)'
		SetCondition(condition)
		if isActive then		--该外观已经在使用
			condition.canActive = false
		end
		
		ShowContent(condition, stage, showState, isActive)
		TextFadeIn(view.textprtstar)
		TextFadeIn(view.textPetattribute)
		TextFadeIn(view.textpurchase)
	end
	
	local TextFadeOut = function()
		--播放特效
		view.eff_UIchongwujinjie_show:SetActive(false)
		view.eff_UIchongwujinjie_show:SetActive(true)
		BETween.alpha(view.textPetattribute, 0.5, 1, 0)
		Timer.Numberal(0.5, 1, StartFadeIn)
	end
	
	local ChangeDesc = function()
	
		local changeKey = GetPetShowStageKey(petDataShared, stage, changeDesKey)
		local changeFlag = UnityEngine.PlayerPrefs.GetString(changeKey, '0')
		if changeFlag == '0' and stateType == 2 and showState >= 2 then --切换显示内容特效提示
	
			TextFadeOut()
			--
			--ShowContent(condition, stage, showState, data.isActive)
			UnityEngine.PlayerPrefs.SetString(changeKey, '1')
		end
	end
	
	self.SetStage = function(data)
		stateType = 1
		stage = data.stage
		showState =	data.showState
		isActive = data.isActive
		local data = GetActiveCondition(stage, showState)
		if isActive then 		--该外观已经在使用
			data.canActive = false
		end
		
		ShowContent(data, stage, showState, data.isActive)
		local dur = 0.8
		if not	isExpand then
			dur = dur + duration
		end
		Timer.Numberal(dur, 1, ChangeDesc)
		isExpand = true
	end
	
	self.Expand = function()
	
		self.Show()
		BETween.scale(view.bgdoor, duration, Vector3.New(0.2, 1, 0.2), Vector3.New(1, 1, 1))
	end
	
	self.ChangePetAppearanceRet = function(data)
	
	
	end
	
	self.PetDataUpdata = function()
	
		local isActive = false
		if stage == petDataShared.pet_appearance then
		
			isActive = true
		end
		
		local condition = {}
		condition.canActive = true
		condition.canBuy = true
		condition.isOk1 = false
		condition.isOk2 = false
		condition.isOk3 = false
		condition.activeDsc = '(满足一下任何条件即可使用)'
		SetCondition(condition)
		if isActive then
		
			condition.canActive = false
		end
		ShowContent(condition, stage, showState, isActive)
	end
	
	self.Show = function()
	
		view.bgdoor:SetActive(true)
		MessageRPCManager.AddUser(self, 'ChangePetAppearanceRet')
	end
	
	self.Hide = function()
	
		--rankingListUICtl.onUnload()
		view.bgdoor:SetActive(false)
		isExpand = false
	end
	
	Init()
	return self
end

---------------------------------------------------------------------------
local CreatePetShowItem = function(view, data)		--宠物外观item
	local self = CreateObject()
	local showType		--宠物外观类型，共三种，1表示初始外观，2表示高级外观，3表示顶级外观
	local showState = 1 --1表示解锁条件不满足，2表示解锁条件满足, 3表示使用条件满足
	local isActive = false  --false表示未使用，true表示已使用
	local isSelected = false
	--local petData
	local petModel
	------------------石化相关
	local fossilisedEffect
	local fossilisedTimerInfo
	local fossilisedTime = 1000
	local fossilisedKey = 'Fossilised'
	local isFossilised = false
	-----------------------------------------
	self.OnSelectPetShow = nil
	
	local IsPetStageCanUse = function()
		local canUse = false
		local petShowList = GrowingPet.Shape[showType]
		local unlockLv = petShowList.UnlockLv
		if petDataShared.pet_level < unlockLv then  --解锁等级未满足
		
			return false
		end
		
		local starRanking = petShowList.StarRanking
		local propertyRanking = petShowList.PropertyRanking
		local petScoreRank = petDataShared.pet_score_rank
		if petScoreRank ~= -1 and petScoreRank <= starRanking then	
			canUse = true
		end
				
		local highestPropertyRank = petDataShared.highest_property_rank
		if highestPropertyRank ~= -1  and highestPropertyRank <= propertyRanking then
			canUse = true
		end
		
		local lastTime = petDataShared.appearance_expire_time[showType]
		if lastTime > 0 then
			canUse = true
		end
		return canUse
	end
	
	local ShowData = function()
		if petDataShared.pet_appearance == showType then
			view['used' .. showType]:SetActive(true)
			view['usersmall' .. showType]:SetActive(true)
			showState = 3
			isActive = true
		else
			isActive = false
			view['used' .. showType]:SetActive(false)
			view['usersmall' .. showType]:SetActive(false)
			if showType > 1 then
				local petShowList = GrowingPet.Shape[showType]
				local unlockLv = petShowList.UnlockLv
				if petDataShared.pet_level >= unlockLv then
					view['conditiontitle' .. showType]:SetActive(false)
					local canUse = IsPetStageCanUse()
					if canUse then
						showState = 3
					else
						showState = 2
					end
				else
					view['conditiontitle' .. showType]:SetActive(true)
					view['textpetlevel' .. showType]:GetComponent('TextMeshProUGUI').text = unlockLv
					--view['textunlock' .. showType]:GetComponent('TextMeshProUGUI').text = unlockLv..'级解锁'
					showState = 1
				end
			end
		end
	end
	
	local RemoveModel = function()
		if petModel then
			UnityEngine.Object.Destroy(fossilisedEffect)
			fossilisedEffect = nil
			petModel.transform.localScale = Vector3.New(1, 1, 1)
			RecycleObject(petModel)
			petModel = nil
		end
	end
	
	local tick = function()
		if fossilisedEffect then
			fossilisedEffect:OnUpdate(os.time())
		end
	end
	
	local SetPetModelUIGray = function(flag, duration)
		local uiGrayMaterial = UIGrayMaterial.GetUIGrayMaterial()
		local bgpet = view['bgpet' .. showType]:GetComponent('Image')
		local imgclickpet = view['imgclickpet' .. showType]:GetComponent('Image')
		local bgcirculartable = view['bgcirculartable' .. showType]:GetComponent('Image')
		local textappearance3 = view['textappearance' .. 3]:GetComponent('TextMeshProUGUI')
		local bgappearance = view['bgappearance' .. showType]:GetComponent('Image')
		
		if flag then
			bgpet.material = uiGrayMaterial
			imgclickpet.material = uiGrayMaterial
			bgcirculartable.material = uiGrayMaterial
			textappearance3.color = Color.New(25, 25, 25)
			bgappearance.material = uiGrayMaterial
		else
			bgpet.material = nil
			imgclickpet.material = nil
			bgcirculartable.material = nil
			textappearance3.color = Color.New(220, 170, 73)
			bgappearance.material = nil
		end
	end
	
	self.SetFossilised = function(flag)
		--local animation = petModel:GetComponent(typeof(UnityEngine.Animation))
		if flag then
			if not fossilisedEffect then
				fossilisedEffect = petModel:GetComponent('FossilisedEffect')
				if not fossilisedEffect then
			
					fossilisedEffect = petModel:AddComponent(typeof(FossilisedEffect))
				end
			end
			
			fossilisedEffect.FadeTimes = 0
			--if animation then
				--animation:Stop()
			--end
			
			fossilisedEffect:SetEffect()
			isFossilised = true
			if not fossilisedTimerInfo then
				fossilisedTimerInfo = Timer.Repeat(0.01, tick)
			end
		else
			if fossilisedEffect then
				fossilisedEffect.FadeTimes = 3
				fossilisedEffect:RevertEffect()
				isFossilised = false
			end
			--if animation then
				--animation:Play()
			--end
		end
	end
	
	local AddModel = function(petDataShared)
		RemoveModel()
		
		local modelRes = GetPetModelRes(showType)
        ResourceManager.CreateCharacter(modelRes,function(obj) 
			petModel = obj
			petModel.transform:SetParent(view['Model'..showType].transform, false)
		
			if petDataShared.pet_id == 7 then	--腾蛇的坐标位置特殊处理
				petModel.transform.localPosition = Vector3.New(0.03410,-0.998,197.314)
			else
				petModel.transform.localPosition = Vector3.New(0.03410,-0.38,197.314)
			end
			petModel.transform.localEulerAngles = Vector3.New(0,-35,0)
			
			local modelKey = 'ModelID'	--默认第一种外观
			if showType == 2 or showType == 3 then   --为第二种外观和第三种外观时
				modelKey = modelKey .. showType
			end
			
			local modelId = GrowingPet.Attribute[petDataShared.pet_id][modelKey]
			local uiScale = artResourceScheme.Model[modelId].UI_Scale
			petModel.transform.localScale = Vector3.New(uiScale, uiScale, uiScale)
		end)
        -- local navMeshAgent = petModel:GetComponent("NavMeshAgent")
        -- if navMeshAgent then
        --     navMeshAgent.enabled = false
        -- end

	end
	
	self.onLoad = function()
	
		AddModel(petDataShared, 
				function()
					if showType > 1 then
						local stageKey = GetPetShowStageKey(petDataShared, showType, fossilisedKey)
						local saveFlag = UnityEngine.PlayerPrefs.GetString(stageKey, '0')
						if saveFlag == '0' then --模型石化
		
							self.SetFossilised(true)
							SetPetModelUIGray(true)
						end
					end
				end)
	end
	
	self.onUnload = function()
		if showType > 1 then
			view['eff_UIchongwujinjie_unlock02' .. showType]:SetActive(false)
		end
		
		if fossilisedEffect then  --去掉石化
			fossilisedEffect.FadeTimes = 0
			fossilisedEffect:RevertEffect()
			tick()
		end
		
		isFossilised = false
		if animation then
			animation:Play()
		end
		
		Timer.Remove(fossilisedTimerInfo)
		fossilisedTimerInfo = nil
		RemoveModel()
		
		for i = 1, 3 do
			view['Model' .. i]:SetActive(true)
		end
		self.ShowPetInterfaceSmall(false)
		
		if showTimer then
            Timer.Remove(showTimer)
            showTimer = nil
        end
	end
	
	local ModelRotate = function(event)
		if not isSelected then
			self.OnSelectPetShow(showType)
		else
			if petModel and  not isFossilised then
				petModel.transform.localEulerAngles = Vector3.New(0,petModel.transform.localEulerAngles.y - event.delta.x/2,0) 
				local roModel = view['PetappearanceStone'..showType]
				local originAngles = roModel.transform.localEulerAngles
				roModel.transform.localEulerAngles = Vector3.New(originAngles.x,originAngles.y,originAngles.z - event.delta.x/3) 
			end	
		end
	end
	
	local showTimer = nil
	local ModelClick = function(event)
		if not isSelected then
			self.OnSelectPetShow(showType)
			return
		end
		
	    if petModel and not event.dragging and not isFossilised then 
            local anim = Util.GetComponentInChildren(petModel,"Animation")
            local show = anim:GetClip('show')
            if show then
                if showTimer then Timer.Remove(showTimer) end
                showTimer = Timer.Delay(show.length,self.ResetModel)
            end
            anim:Play("show")
        end	
	end
	
	self.ResetModel = function()
        if petModel then
            local anim = Util.GetComponentInChildren(petModel,"Animation")
            anim:Play("NormalStandby")
        end
        showTimer = nil
    end
	
	local Init = function()
		showType = data.sType
		DragEventListener.Get(view['petmodelcontrol' .. showType]).onDrag = ModelRotate
        ClickEventListener.Get(view['petmodelcontrol' .. showType]).onClick = ModelClick
		ClickEventListener.Get(view['bgpet' .. showType]).onClick =	function() if self.OnSelectPetShow then self.OnSelectPetShow(showType) end end
		--petData = petDataShared
		view['imgclickpet' .. showType]:SetActive(false)
		view['used' .. showType]:SetActive(false)
		local conditiontitle = view['conditiontitle' .. showType]
		if conditiontitle then
		
			conditiontitle:SetActive(false)
		end
		
		ShowData()
	end
	
	self.SetSlected = function(flag)
		isSelected = flag
		view['imgclickpet' .. showType]:SetActive(flag)
	end

	--self.SetShowType = function(sType)
	
		--showType = sType
	--end
	
	local HideLight = function(showCollapse)
	
		view['bgorangelight'..showType]:SetActive(false)
		showCollapse()
		
		if showType > 1 then
		if showState == 2 or showState == 3 then  --满足解锁条件或则使用条件
			local stageKey = GetPetShowStageKey(petDataShared, showType, fossilisedKey)
			
				if isFossilised then
					Timer.Delay(0.4, self.PlayUnlockEffect)
					self.SetFossilised(false) --取消模型石化
					SetPetModelUIGray(false)
					UnityEngine.PlayerPrefs.SetString(stageKey, '1') --解除石化标志
				end
			end
		end
	end
	
	local ShowLight = function(showCollapse)
		local light = view['bgorangelight'..showType]
		light:SetActive(true)
		
		local deTime = 0.2
		BETween.alpha(light, deTime, 1)
		Timer.Delay(deTime, HideLight, showCollapse)
	end
	
	self.SetModelScale = function(duration, scale)
	
		BETween.scale(petModel, duration, scale)
	end
	
	self.PetDataUpdata = function()
	
		ShowData()
	end
	
	self.ShowPetInterfaceSmall = function(flag)
		view.petinterfacesmall:SetActive(flag)
		--for i = 1, 3 do
		view['appearance' .. showType]:SetActive(not flag)
		--end
		
		if flag == true then
			if showType > 1 then
				if showState == 1 then  --解锁条件未满足
					view['conditiontitlesmall'..showType]:SetActive(true)
					
					local petShowList = GrowingPet.Shape[showType]
					local unlockLv = petShowList.UnlockLv
					view['textpetlevelsmall' .. showType]:GetComponent('TextMeshProUGUI').text = unlockLv
				else					--满足解锁条件
					view['conditiontitlesmall'..showType]:SetActive(false)
				end
			end
			view['usersmall'..showType]:SetActive(isActive)
			view['Model' .. showType]:SetActive(false)
			petModel.transform:SetParent(view['ModelSmall' .. showType].transform, false)
		end
	end
	
	self.PlayUnlockEffect = function()
		if showType == 1 then
			return
		end
		
		local unlockEffect = view['eff_UIchongwujinjie_unlock02' .. showType]
		unlockEffect:SetActive(false)
		unlockEffect:SetActive(true)
	end
	
	self.OnClick = function(action, isPlayAnim, showCollapse)
	
		if isPlayAnim == false then
		
			--Timer.Delay(0.4, ShowLight, showCollapse)
			ShowLight(showCollapse)   --第一次点击宠物页面
		else
			if showType > 1 then
				if showState == 2 or showState == 3 then --满足解锁条件或则使用条件
			
					local stageKey = GetPetShowStageKey(petDataShared, showType, fossilisedKey)
					if isFossilised then
						self.PlayUnlockEffect()
						self.SetFossilised(false) --取消模型石化
						SetPetModelUIGray(false)
						UnityEngine.PlayerPrefs.SetString(stageKey, '1') --解除石化标志
					end
				end
			end
		end
	
		self.SetSlected(true)
		if action then
			
			local data = {}
			data.stage = showType
			data.showState = showState
			data.isActive = isActive
			action(data)
		end
	end
	
	Init()
	return self
end

-------------------------------------------------------------------------------

local CreatePetShow = function(view, petData)			--宠物外观管理
	local self = CreateObject()
	local petShowAnimation
	local isPlayAnim = false     --
	local activePetShow
	local petShowItems = {}
	
	local PlayPetShowCollapse = function()		--
	
		if isPlayAnim then
		
			return
		end
		
		local duration = 0.4
		--for i = 1, 3 do
			--petShowItems[i].SetModelScale(duration, Vector3.New(0.74, 1.4, 1))
		--end
		
		petShowAnimation:Play('A_eff_UI@chongwuye_02_0')
		--延时执行
		Timer.Delay(duration, activePetShow.Expand)
		for i = 1, 3 do
			Timer.Delay(duration, petShowItems[i].ShowPetInterfaceSmall, true)
		end
		isPlayAnim = true
	end
	
	local PlayPetShowExpand = function()		--展开
	
		petShowAnimation:Play('A_eff_UI@chongwuye_01_0')
	end
	
	local OnSelectPetShow = function(index)
	
		petShowItems[index].OnClick(activePetShow.SetStage, isPlayAnim, PlayPetShowCollapse) --显示激活页内容
		for i = 1, 3 do
			petShowItems[i].SetSlected(i == index)
		end
		--PlayPetShowCollapse()
	end
	
	local Init = function()
	
		--ClickEventListener.Get(view.bgpet1).onClick = OnSelectPetShow
		petShowAnimation = view.petinitialanimation:GetComponent(typeof(UnityEngine.Animation))
		activePetShow = CreateActivePetShow(view, petDataShared)
		
		for i = 1, 3 do
		
			local data = {}
			data.petData = petDataShared
			data.sType = i
			petShowItems[i] = CreatePetShowItem(view, data)
			--petShowItems[i].SetShowType(i)
			--ClickEventListener.Get(view['bgpet' .. i]).onClick =	function() OnSelectPetShow(i) end
			petShowItems[i].OnSelectPetShow = OnSelectPetShow
		end
	end
	
	self.PetDataUpdata = function()
	
		activePetShow.PetDataUpdata()
		for i = 1, 3 do
		
			petShowItems[i].PetDataUpdata()
		end
	end
	
	self.PetAppearanceChanged = function(data)
	
		--for k, v in pairs(data.changed_pet) do
		
			--if petDataShared.entity_id == k then
			
				--petShowItems[v]
			--end
		--end
	end

	self.onLoad = function()
	
		MessageRPCManager.AddUser(self, 'PetAppearanceChanged')
		for i = 1, 3 do
		
			petShowItems[i].onLoad()
		end
    end

    self.onUnload = function()

		MessageRPCManager.RemoveUser(self, 'ChangePetAppearanceRet')
		activePetShow.Hide()
		for i = 1, 3 do
		
			petShowItems[i].onUnload()
		end
		isPlayAnim = false
    end
	
	Init()
	return self
end

------------------------------------------宠物外观  End


------------------------------------------------------------------------------

local function CreatePetappearanceUICtrl()--管理宠物外观和排行榜
    local self = CreateCtrlBase()
	local oldPetAppearance
--	local pageName = {'RankingListUICtl' = 1}
--	local pageList = {}
	--local rankingListUICtl     	--排行榜
	local petShowUICtrl 		--宠物外观
	local petData				--宠物数据

	local OnClose = function()
	
		UIManager.UnloadView(ViewAssets.PetappearanceUI)
		UIManager.PushView(ViewAssets.PetUI)
	end
	
	local OnUpdateData = function(data)          --跟新服务端updata数据
	
		local petList = data.pet_list
		if (petList) then

			for k, v in pairs(petList) do
			
				if petDataShared.entity_id == v.entity_id then
				
					petDataShared = v
					break
				end
			end
		end
		
		local normalPetAppearance = petDataShared.pet_appearance
		local pet = SceneManager.GetEntityManager().GetPuppet(petDataShared.entity_id)
		if pet and oldPetAppearance ~= normalPetAppearance then  --更换宠物模型
		
			local modelRes = GetPetModelRes(normalPetAppearance)
			local behavior = pet.behavior
			local petData = GrowingPet.Attribute[petDataShared.pet_id]
			local item = behavior:GetModelData(petData.ModelID)
			local ownerScale = behavior:GetObjectSettingScale()
			local scale = ownerScale * item.Scale * petData.Scale
			pet:ChangeModel(modelRes, scale)
		end
		
		petShowUICtrl.PetDataUpdata()
		oldPetAppearance = normalPetAppearance
	end
	
    self.onLoad = function(data, mainPetIndex)
	
		local view = self.view
		ClickEventListener.Get(view.iconquit).onClick = OnClose
		petData = data
		petData.mainPetIndex = mainPetIndex
		petDataShared = data
		oldPetAppearance = petDataShared.pet_appearance
		--[[
		for k, v in pairs(petData) do
			print('k = ', k)
			print('v = ', v)
			if k == 'appearance_expire_time' then
				for k1, v1 in pairs(v) do
					print('k1 = ', k1)
					print('v1 = ', v1)
				end
			end
		end
		]]
		petShowUICtrl = CreatePetShow(view, petDataShared)
		petShowUICtrl.onLoad()
		
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
    end

    self.onUnload = function()

		petShowUICtrl.onUnload()
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
    end

    return self
end

return CreatePetappearanceUICtrl()


--------------------------------------------------------------------------------

