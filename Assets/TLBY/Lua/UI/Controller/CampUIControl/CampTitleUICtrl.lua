--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/9
--
require "UI/Controller/LuaCtrlBase"
--爵位捐献

local function CreateCampTitleUICtrl()   
    local self = CreateCtrlBase()
    local view = self.view
	local itemPrefab
	local sliderScript
	local maxMoney = 1000
	local minMoney = 1000
	local currentMoney = 0
	local titleRankData		--爵位排行数据
	local selectItemIndex = 1
	local updateTimerInfo
	local state = 1
	local donationType = 'weekly'
	local isSlideUpdate = true   --
	
	local GetCurrentMoney = function()
	
		--local value = sliderScript.value
		--local money = math.ceil(tonumber(maxMoney * value))   --当前钱

		return currentMoney
	end
	
	local ShowMoney = function()
		view.textnumber:GetComponent('TextMeshProUGUI').text = currentMoney
		view.textnumber:GetComponent('TextMeshProUGUI').text = currentMoney
		view.textRate:GetComponent('TextMeshProUGUI').text = currentMoney..'/'..maxMoney
	end
	
	local AddSliderMoney = function(value)
		currentMoney = currentMoney + value
		if currentMoney < minMoney then
			currentMoney = minMoney
		elseif currentMoney > maxMoney then
			currentMoney = maxMoney
		end
		
		isSlideUpdate = false
	
		local rate = currentMoney / maxMoney
		sliderScript.value = rate

		ShowMoney()
	end
	
	local OnAddMoney = function()			--增加铜钱
	
		local material = view.btnadd:GetComponent('Image').material
		if material == UIGrayMaterial.GetUIGrayMaterial() then
		
			return
		end
		
		state = 2
		AddSliderMoney(minMoney)
	end
	
	local OnSubtractMoney = function()		--减少铜钱
	
		local material = view.btnreduction:GetComponent('Image').material
		if material == UIGrayMaterial.GetUIGrayMaterial() then
		
			return
		end
	
		state = 3
		AddSliderMoney(-minMoney)
	end
	
	local OnDescrip = function()		--爵位说明
	
		UIManager.PushView(ViewAssets.TitleDescrip)
	end
	
	local RequestDonation = function()  --请求爵位捐献
	
		local data = {}
		data.func_name = 'on_donate_goods'
		data.coin_num = GetCurrentMoney()
		
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	local OnDonation = function()   	--爵位捐献
	
		local material = view.btndonation:GetComponent('Image').material
		if material == UIGrayMaterial.GetUIGrayMaterial() then
			UIManager.ShowNotice('单次捐献不少于'.. minMoney ..'铜钱')
			return
		end
	
		local data = {}
		local money = GetCurrentMoney()
		
		data.content = '确定捐献'..money..'铜钱？'
		data.okHandler = RequestDonation
		data.identifier = 'RequestDonation'
		UIManager.PushView(ViewAssets.CommTipBox1,
			function(ctrl)
				ctrl.Show(data)
			end)
	end
	
	local SetScrollView = function(itemPrefab)
		local rankList = titleRankData.rank_list
		local itemsCount = #rankList
		local itemData = {}

		for i = 1, itemsCount do
		
			local selectFlag = false
			--if i == selectItemIndex then
				
				--selectFlag = true
			--end
			
			if titleRankData.type == 'weekly' then
				rankList[i].Gain = pvpCamp.NobleRank2[rankList[i].weekly_noble_rank].Gain
			elseif titleRankData.type == 'total' then
			
				rankList[i].Gain = pvpCamp.NobleRank[rankList[i].noble_rank].Gain
			end
			
			table.insert(itemData, {pos = i, select = selectFlag, rankIndex = i, attr = rankList[i], SelectRankItemRet = self.OnSelectRankItem})
		end
		
		local itemWidth = 145
        local itemHeight = 60
        local itemPadding = 2
        local maxPerline = 1
		local viewCount = 12
		
        local function itemUpdate(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(itemData[index + 1])
        end
		
		local scrollView = view.WeakScrollView
		if titleRankData.type == 'weekly' then
		
			scrollView = view.WeakScrollView
			view.WeakScrollView:SetActive(true)
			view.TotalScrollView:SetActive(false)
		elseif titleRankData.type == 'total' then
		
			scrollView = view.TotalScrollView
			view.WeakScrollView:SetActive(false)
			view.TotalScrollView:SetActive(true)
		end
		
		local scv = scrollView:GetComponent(typeof(UIMultiScroller))
        if scv and itemPrefab then
            scv:Init(itemPrefab, itemWidth, itemHeight, itemPadding, viewCount, maxPerline)
            scv:UpdateData(itemsCount, itemUpdate)
        end	
	end
	

	local UpdateTitleRank = function()   --跟新爵位排行
		if itemPrefab == nil then
			ResourceManager.CreateUI("CampUI/TitleRankItem", 
						function(prefab)
							itemPrefab = prefab
							itemPrefab.transform:SetParent(nil,false)
							SetScrollView(itemPrefab)
						end)
		else
			SetScrollView(itemPrefab)
		end
		
	end
	
	self.OnSelectRankItem = function(index)
	
		selectItemIndex = index
		UpdateTitleRank()
	end
	
	local SetSelfInfo = function(data)		--显示自己的排名信息
	
		local rankName = '未入榜'
		local donationRank = data.donation_rank
		local donation = data.donation
		local nobleRank = data.noble_rank
		local titleData =  pvpCamp.NobleRank[nobleRank]
		local gain
		if donationType == 'weekly' then
		
			donationRank = data.weekly_donation_rank
			donation = data.weekly_donation
			gain = pvpCamp.NobleRank2[data.weekly_noble_rank].Gain
		elseif donationType == 'total' then
		
			donationRank = data.donation_rank
			donation = data.donation
			gain = titleData.Gain
		end
		
		if donationRank ~= -1 and donationRank ~= 0 then
		
			rankName = donationRank
		end
		
		if donationRank <= 3 and donationRank ~= -1 and donationRank ~= 0 then		--前三名
		
			view.Top:SetActive(true)
			view.TopIcon:GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(string.format("AutoGenerate/Petappearance/%s", donationRank))
			view.textrankingnumber1:SetActive(false)
		else
		
			view.Top:SetActive(false)
			view.textrankingnumber1:SetActive(true)
			view.textrankingnumber1:GetComponent('TextMeshProUGUI').text = rankName   --排名
		end
		
		--view.textrankingnumber1:GetComponent('TextMeshProUGUI').text = rankName			--自己当前捐赠排名
		view.textobtainnumber1:GetComponent('TextMeshProUGUI').text = data.donation			--自己当前捐赠额
		
		local titleName = '平民'
		if data.nobleRank == -1 then  --平民
		
			titleName = '平民'
		else
			
			titleName = titleData.Name1  --当前爵位
		end
		view.texttitlename2:GetComponent('TextMeshProUGUI').text = titleName			--当前爵位
		if titleData then
		
			view.textpsychic1:GetComponent('TextMeshProUGUI').text = '+'..gain.."灵力"	--灵力
		end
		if data.actor_name then
		
			view.textplayernamemessage:GetComponent('TextMeshProUGUI').text = data.actor_name --角色名称
		end
		
		if data.next_level_need then
		
			local tipText = view.textobtain:GetComponent('TextMeshProUGUI')
			if donationType == 'weekly' then  	--周榜
			
				if donationRank == 1 then
				
					tipText.text = '您前面没有更高的排名了'
				else
				
					tipText.text = '离上一级排名还需要捐献'..data.next_level_need..'铜钱'
				end
			elseif donationType == 'total' then  --总榜
			
				if nobleRank == 1 then
			
					tipText.text = '您已经是最高爵位了'	
				else
			
					nobleRank  = nobleRank - 1
					local titleData =  pvpCamp.NobleRank[nobleRank]
					titleName = titleData.Name1  --当前爵位
					tipText.text = '升级到'..titleName..'爵位'..'还需要捐献'..data.next_level_need..'铜钱'	
				end
			end
		end
	end
	
	local SetDonationFlag = function(flag)			--设置是否禁用捐献
	
		if flag then
		
			local slider = view.Slider:GetComponent('Slider')
			slider.interactable = true
			view.btnadd:GetComponent('Image').material = nil
			view.btnreduction:GetComponent('Image').material = nil
			view.btndonation:GetComponent('Image').material = nil
			view.btndragsquare:GetComponent('Image').material = nil
			
		else
		
			view.btnadd:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
			view.btnreduction:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
			view.btndonation:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
			view.btndragsquare:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
			
			local slider = view.Slider:GetComponent('Slider')
			slider.interactable = false
		end
	end
	
	
	local RequestGetDonationList = function()    --请求捐献榜
	
		local data = {}
		data.func_name = 'on_get_donation_list'
		data.start_index = 1
		data.end_index = 40
		data.type = donationType

		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		
		--self.OnRPCRequest = function(Net, data)
	end

	local SetNoDonationData = function()
	
		if updateTimerInfo then
			
			Timer.Remove(updateTimerInfo)
			updateTimerInfo = nil
		end
		
		sliderScript.value = 0
		currentMoney = 0
		view.bggreenprogressbar:GetComponent('Image').fillAmount = sliderScript.value
		view.textnumber:GetComponent('TextMeshProUGUI').text = currentMoney
		view.textnumber:GetComponent('TextMeshProUGUI').text = currentMoney
		--view.textobtain:GetComponent('TextMeshProUGUI').text = '捐献铜钱    '..currentMoney..'/'..maxMoney
		view.textRate:GetComponent('TextMeshProUGUI').text = currentMoney..'/'..maxMoney
		--没有任何铜钱，禁用捐献功能
		SetDonationFlag(false)
	end
	
	local OnUpdateData = function(data)
		if not data.coin then
			return
		end
		--local loginData = MyHeroManager.heroData
		minMoney = math.floor(tonumber(pvpCamp.Parameter[7].Value))
		maxMoney = data.coin
		currentMoney = 1000
		AddSliderMoney(0)

		if maxMoney < minMoney then
		
			SetNoDonationData()
		end
	end
	
	local OnWeekTopPage = function()   --周榜页面
	
		donationType = 'weekly'
		view.texttitle:GetComponent('TextMeshProUGUI').text = '总爵位'
		view.textranking:GetComponent('TextMeshProUGUI').text = '周贡献排名'
		RequestGetDonationList()
	end
	
	local OnTotolTopPage = function()  --总榜页面
	
		donationType = 'total'
		view.texttitle:GetComponent('TextMeshProUGUI').text = '总爵位'
		view.textranking:GetComponent('TextMeshProUGUI').text = '爵位排名'
		RequestGetDonationList()
	end
	
	self.DonateGoodsRet = function(data)		--捐献返回
	
		SetSelfInfo(data)
		RequestGetDonationList()
		UIManager.ShowNotice("捐献成功")
	end
	
	self.GetDonationListRet = function(data)  	--获取捐赠排行榜反馈
	
		SetSelfInfo(data)
		
		titleRankData = data
		UpdateTitleRank()  		--跟新爵位排行
	end
	
	local OnValueChanged = function(even)
		local value = even
		local image = view.bggreenprogressbar:GetComponent('Image')
		image.fillAmount = value
		
		if isSlideUpdate then
			local floorMoney = math.ceil(value * maxMoney / minMoney)   --当前钱
			currentMoney = floorMoney * minMoney
			if currentMoney <= 0 and maxMoney >= minMoney then
				currentMoney = minMoney
			elseif currentMoney > maxMoney then
				currentMoney = maxMoney
			end
		
			ShowMoney()
		end
		isSlideUpdate = true
	end
	
    self.onLoad = function()
        view = self.view
		MessageRPCManager.AddUser(self, 'DonateGoodsRet')
		MessageRPCManager.AddUser(self, 'GetDonationListRet')
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		
		UIUtil.AddToggleListener(view.weekPage.gameObject, OnWeekTopPage)
		UIUtil.AddToggleListener(view.totalPage.gameObject, OnTotolTopPage)
		UIUtil.AddSliderListener(view.Slider, OnValueChanged)
		ClickEventListener.Get(view.btnquestion).onClick = OnDescrip
		ClickEventListener.Get(view.btndonation).onClick = OnDonation
		ClickEventListener.Get(view.btnreduction).onClick = OnSubtractMoney
		ClickEventListener.Get(view.btnadd).onClick	= OnAddMoney
		sliderScript = view.Slider:GetComponent('Slider')
		view.WeakScrollView:SetActive(false)
		view.TotalScrollView:SetActive(false)
		
		local loginData = MyHeroManager.heroData
		minMoney = math.floor(tonumber(pvpCamp.Parameter[7].Value))
		maxMoney = loginData.coin
		if maxMoney < minMoney then
		
			SetNoDonationData()
		else
		
			currentMoney = minMoney
			SetDonationFlag(true)
			AddSliderMoney(0)
		end
		
		OnWeekTopPage()
    end

    self.onUnload = function()

		MessageRPCManager.RemoveUser(self, 'DonateGoodsRet')
		MessageRPCManager.RemoveUser(self, 'GetDonationListRet')
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		
		isSlideUpdate = true
    end

    return self
end


return CreateCampTitleUICtrl()

