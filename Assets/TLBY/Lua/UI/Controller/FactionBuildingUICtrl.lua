require "UI/Controller/LuaCtrlBase"

local function CreateFactionBuildingUICtrl()
	local self = CreateCtrlBase()
    local factionTable = GetConfig('system_faction')
    local buildingID = 0
    local buildingData = nil
    local countDown = nil
    local uiText = GetConfig('common_char_chinese').UIText
    local const = require "Common/constant"
    
    self.OpenUI = function(id)
        buildingID = id
        local data = {}
        data.building_id = id
        data.func_name = 'on_query_faction_building'   
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,data)
        MessageRPCManager.AddUser(self, 'OnQueryFactionBuildingRet')
    end
    
    self.OnQueryFactionBuildingRet = function(data)
        if data.building then
            buildingID = data.building_id
            buildingData = data.building
            if not self.isLoaded then
                UIManager.PushView(ViewAssets.FactionBuildingUI)
            else
                self.FreshData()
            end
        elseif data.result ==  const.error_faction_building_lock then
            local level = 1
            for k,v in pairs(factionTable.Hall) do
                if v.UnlockID[1] == buildingID then
                    level = v.Level
                end
            end
            UIManager.ShowNotice(string.format(uiText[1135137].NR,level,LuaUIUtil.GetTextByID(factionTable.Building[buildingID],'Name')))
        end
    end
    
    self.OnUpgradeFactionBuildingRet = function(data)
        self.OnQueryFactionBuildingRet(data)
    end
    
    self.OnInvestmentFactionBuildingRet = function(data)
        self.OnQueryFactionBuildingRet(data)
    end
    
    local BindData = function(item,index)
        local data = buildingData.ranks[index+1]
        item.transform:Find('rank'):GetComponent('TextMeshProUGUI').text = string.format('第%d名',data.rank)
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
        item.transform:Find('num'):GetComponent('TextMeshProUGUI').text = data.investment
    end
    
    self.FreshData = function()
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#(buildingData.ranks),BindData)
        self.view.bulidingName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(factionTable.Building[buildingID],'Name')
        self.view.index:GetComponent('TextMeshProUGUI').text = buildingData.level
        local currentConfig = factionTable[factionTable.Building[buildingID].Table][buildingData.level]
        self.view.processText:GetComponent('TextMeshProUGUI').text = buildingData.progress..'/'.. currentConfig.Exp
        local progress = buildingData.progress/currentConfig.Exp
        self.view.processBar:GetComponent('Image').fillAmount = progress
        self.view.skill1:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(currentConfig,'Describetion')
        self.view.skill2:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(currentConfig,'UpDescribe')

        local investFundTb = LuaUIUtil.GetFloorTableItem(factionTable.Investment,'TimeLowerLimit',buildingData.investment_count)
        local investCoinTb = LuaUIUtil.GetFloorTableItem(factionTable.Investment,'TimeLowerLimit',buildingData.investment_count)
        
        self.view.des2:GetComponent('TextMeshProUGUI').text = string.format(uiText[1135135].NR,investCoinTb.Exp,investCoinTb.Reward1[2])
        self.view.des1:GetComponent('TextMeshProUGUI').text = uiText[1135136].NR
        
        self.view.fundNum:GetComponent('TextMeshProUGUI').text = investFundTb.Cost2[2]
        self.view.fundIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(investFundTb.Cost2[1])
        self.view.coinNum:GetComponent('TextMeshProUGUI').text = investCoinTb.Cost1[2]
        self.view.coinIcon:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(investFundTb.Cost1[1])
        local showTime = networkMgr:GetConnection():GetTimespanSeconds(buildingData.next_upgrade_time) > 0
        self.view.time:SetActive(showTime)
        self.view.upgrade:SetActive(not showTime and progress >= 1)
        self.view.invest:SetActive(not showTime and progress < 1)

        if countDown then
            Timer.Remove(countDown)
        end
        local timeText = self.view.countDown:GetComponent('TextMeshProUGUI')
        local TimeUpdate = function() 
        local leftTime = networkMgr:GetConnection():GetTimespanSeconds(buildingData.next_upgrade_time)
        if leftTime <0 then leftTime = 0 end
            timeText.text = TimeToStr(leftTime)
        end
        TimeUpdate()
        countDown = Timer.Repeat(1,TimeUpdate)
    end
    
    self.CoinInvest = function()
        local data = {}
        data.building_id = buildingID
        data.func_name = 'on_investment_faction_building'
        data.investment_type = constant.FACTION_BUILDING_INVESTMENT_TYPE.coin
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,data)
    end
    
    self.FundInvest = function()
        local data = {}
        data.building_id = buildingID
        data.func_name = 'on_investment_faction_building'   
        data.investment_type = constant.FACTION_BUILDING_INVESTMENT_TYPE.fund
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,data)
    end
    
    self.Upgrade = function()
        local data = {}
        data.building_id = buildingID
        data.func_name = 'on_upgrade_faction_building'   
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,data)
    end
    
	self.onLoad = function()
        self.AddClick(self.view.btnclose, self.close)
        self.AddClick(self.view.btnCoinInvest, self.CoinInvest)
        self.AddClick(self.view.btnFundInvest, self.FundInvest)
        self.AddClick(self.view.btnUpgrade, self.Upgrade)
        self.view.rankItem:SetActive(false)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.rankItem,75,75,0,10,1)
        self.FreshData()
        
        MessageRPCManager.AddUser(self, 'OnInvestmentFactionBuildingRet')
        MessageRPCManager.AddUser(self, 'OnUpgradeFactionBuildingRet')
	end
    
    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'OnQueryFactionBuildingRet')
        MessageRPCManager.RemoveUser(self, 'OnInvestmentFactionBuildingRet')
        MessageRPCManager.RemoveUser(self, 'OnUpgradeFactionBuildingRet')
        if countDown then
            Timer.Remove(countDown)
            countDown = nil
        end
	end

	return self
end

return CreateFactionBuildingUICtrl()
