---------------------------------------------------
-- auth： panyinglong
-- date： 2017/01/22
---------------------------------------------------
-- auth： yanwei
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"
local itemTable = require "Logic/Scheme/common_item"

local function CreateSystemSettingCtrl()
    local self = CreateCtrlBase()
    self.hookSmallRadius = GetConfig("common_parameter_formula").Parameter[8].Parameter
	self.hookWideRadius = GetConfig("common_parameter_formula").Parameter[9].Parameter
    local DrugItemList = {} 
	self.SwitchingDrugToggle  = nil
	
	Setting_Type =
    {
        BasicSetting = 1,
        Advancedsetting = 2, 
        AccountSetting = 3, 
        Hooksetting = 4, 
    }
	local currentSet = Setting_Type.BasicSetting
	local SaveClientConfig = function(key,value)
		local data = {}
	    data.func_name = 'on_save_client_config'
	    data.key =  key
		data.value = value
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	

	
	local function keepTwoDecimalPlaces(decimal)  --四舍五入保留两位小数
        decimal = math.floor((decimal * 100)+0.5)*0.01       
        return  decimal 
     end
	
	local function SaveSettingConfig()
		if currentSet == Setting_Type.Hooksetting then
			SaveClientConfig('HealthSuppleThreshold',keepTwoDecimalPlaces(self.HealthSupplyBar.value)*100)
			SaveClientConfig('MagicSuppleThreshold',keepTwoDecimalPlaces(self.MagicSupplyBar.value)*100)
			SaveClientConfig('AutoSwitchDurg',self.SwitchingDrugToggle.isOn)
			SaveClientConfig('AutoHealthSupple',self.HealthSupplyToggle.isOn )
			SaveClientConfig('AutoMagicSupple',self.MagicSupplyToggle.isOn )
			SaveClientConfig('AutoPetHealthSupple',self.PethealthSupplyToggle.isOn )
			SaveClientConfig('PetHealthSuppleThreshold',keepTwoDecimalPlaces(self.PetHealthSupplyBar.value)*100)
		end
	end
	
	 local function Close()
        self.close()
		SaveSettingConfig()
    end
	
	local OnBasicSetChanged = function(check)
		if check == true and currentSet~= Setting_Type.BasicSetting then 
		   SaveSettingConfig()
 		   self.view.BasicSetting:SetActive(true)
		   self.view.OnHookSetting:SetActive(false)
		   self.view.AccountSetting:SetActive(false)
		   self.view.VancedSetting:SetActive(false)
		   self.Scrollbar.value = 1
		   currentSet = Setting_Type.BasicSetting
		end
        
	end
	
	local OnAdvancedsetChanged = function(check)
		if check == true and currentSet~= Setting_Type.Advancedsetting then 
		   SaveSettingConfig()
		   self.view.BasicSetting:SetActive(false)
		   self.view.OnHookSetting:SetActive(false)
		   self.view.AccountSetting:SetActive(false)
		   self.view.VancedSetting:SetActive(true)
		   currentSet = Setting_Type.Advancedsetting
		end
        
	end
	
	local OnAccountSetChanged = function(check)
		  if check == true and currentSet~= Setting_Type.AccountSetting then 
		   SaveSettingConfig()
		   self.view.BasicSetting:SetActive(false)
		   self.view.OnHookSetting:SetActive(false)
		   self.view.AccountSetting:SetActive(true)
		   self.view.VancedSetting:SetActive(false)
		   self.view.textName:GetComponent('TextMeshProUGUI').text = SceneManager.GetEntityManager().hero.name
		   self.view.textLevel:GetComponent('TextMeshProUGUI').text = 'Lv.'..MyHeroManager.heroData.level
		   self.view.textServer:GetComponent('TextMeshProUGUI').text =UnityEngine.PlayerPrefs.GetString("ServerName")
		   currentSet = Setting_Type.AccountSetting
		end
        
	end
	
	local OnHooksetChanged = function(check)
		if check == true and currentSet~= Setting_Type.Hooksetting then 
		   SaveSettingConfig()
		   self.view.BasicSetting:SetActive(false)
		   self.view.OnHookSetting:SetActive(true)
		   self.view.AccountSetting:SetActive(false)
		   self.view.VancedSetting:SetActive(false)
		   self.view.BgDrugsSelect:SetActive(false)
		   local iconDrugs1 = self.view.iconDrugs1:GetComponent("Image")
		   local iconDrugs2 = self.view.iconDrugs2:GetComponent("Image")
		   local iconDrugs3 = self.view.iconDrugs3:GetComponent("Image")
		  for i = 1 ,#DrugItemList do
			GameObject.Destroy(DrugItemList[i])
			DrugItemList[i] = nil
		  end
		  if GlobalManager.HealthSuppleDurgID ~=-1 then
			local item = itemTable.Item[GlobalManager.HealthSuppleDurgID]
			iconDrugs1.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
			local ItemNumber = BagManager.GetItemNumberById(GlobalManager.HealthSuppleDurgID)
			if ItemNumber < 1 then 
				iconDrugs1.material = UIGrayMaterial.GetUIGrayMaterial()
			else
			    iconDrugs1.material =  nil
			end
		  end
		  if GlobalManager.MagicSuppleDurgID ~=-1 then
			local item = itemTable.Item[GlobalManager.MagicSuppleDurgID]
			local ItemNumber = BagManager.GetItemNumberById(GlobalManager.MagicSuppleDurgID)
			iconDrugs2.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
			if ItemNumber < 1 then 
				iconDrugs2.material = UIGrayMaterial.GetUIGrayMaterial()
			else
			   iconDrugs2.material =  nil
			end
		 end
		if GlobalManager.PetHealthSuppleDurgID ~=-1 then
			local item = itemTable.Item[GlobalManager.PetHealthSuppleDurgID]
			iconDrugs3.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
			local ItemNumber = BagManager.GetItemNumberById(GlobalManager.PetHealthSuppleDurgID)
			if ItemNumber < 1 then 
				iconDrugs3.material = UIGrayMaterial.GetUIGrayMaterial()
			else
			    iconDrugs3.material =  nil
			end
		 end
		 self.HealthSupplyBar.value = GlobalManager.HealthSuppleThreshold/100
		 self.MagicSupplyBar.value = GlobalManager.MagicSuppleThreshold/100
		 self.HealthSupplyToggle.isOn = GlobalManager.AutoHealthSupple
		 self.MagicSupplyToggle.isOn = GlobalManager.AutoMagicSupple
		 if self.SwitchingDrugToggle == nil then
		    self.SwitchingDrugToggle = self.view.SwitchingDrug:GetComponent('Toggle') 
		 end
		 if self.PethealthSupplyToggle == nil then
		     self.PethealthSupplyToggle = self.view.PetHealthSupplySetting:GetComponent('Toggle') 
		 end
		 self.PetHealthSupplyBar.value = GlobalManager.PetHealthSuppleThreshold/100
		 self.PethealthSupplyToggle.isOn = GlobalManager.AutoPetHealthSupple
		 self.SwitchingDrugToggle.isOn = GlobalManager.AutoSwitchDurg 
		 currentSet = Setting_Type.Hooksetting
	   end
       
	end
	
	local HealthSupplyChanged = function(value)
		self.TxtHealthSupply.text = "<size=80%>"..tostring(keepTwoDecimalPlaces(value)*100).. "%<size=100%> 时，使用"
	end
	
	local MagicSupplyChanged = function(value)
		self.TxtMagicSupply.text = "<size=80%>"..tostring(keepTwoDecimalPlaces(value)*100).."%<size=100%> 时，使用"
	end
	
	local PetHealthSupplyChanged = function(value)
		self.TxtPetHealthSupply.text = "<size=80%>"..tostring(keepTwoDecimalPlaces(value)*100).."%<size=100%> 时，使用"
	end
	
	local SetTexSettingUnactive = function()
		--self.texLowTogle.enabled = false
		self.view.TexSettingLow:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
		self.view.TexSettingLow.transform:FindChild("imgCheckmark"):GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
		self.view.TexSettingMedium:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
		--self.texMediumTogle.enabled = false
		self.view.TexSettingMedium.transform:FindChild("imgCheckmark"):GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
		self.view.TexSettingFine:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
		--self.texFineTogle.enabled = false
		self.view.TexSettingFine.transform:FindChild("imgCheckmark"):GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
	end
	
	local SetTexSettingActive = function()
		--self.texLowTogle.enabled = true
		--self.texMediumTogle.enabled = true
		--self.texFineTogle.enabled = true
		self.view.TexSettingLow:GetComponent('Image').material = nil
		self.view.TexSettingLow.transform:FindChild("imgCheckmark"):GetComponent('Image').material = nil
		self.view.TexSettingMedium:GetComponent('Image').material = nil
		self.view.TexSettingMedium.transform:FindChild("imgCheckmark"):GetComponent('Image').material = nil
		self.view.TexSettingFine:GetComponent('Image').material = nil
		self.view.TexSettingFine.transform:FindChild("imgCheckmark"):GetComponent('Image').material = nil
	end
	
	local OnSmoothChanged = function()
        UnityEngine.QualitySettings.SetQualityLevel(1,false)
		self.texLowTogle.enabled = true
		self.texMediumTogle.enabled = true
		self.texFineTogle.enabled = true
		self.texLowTogle.isOn = true
	end
	
	local OnBalancedChanged = function()
        UnityEngine.QualitySettings.SetQualityLevel(2,false)
		self.texLowTogle.enabled = true
		self.texMediumTogle.enabled = true
		self.texFineTogle.enabled = true
		self.texMediumTogle.isOn = true
	end
	
	local OnFineChanged = function()
        UnityEngine.QualitySettings.SetQualityLevel(3,false)
		self.texLowTogle.enabled = true
		self.texMediumTogle.enabled = true
		self.texFineTogle.enabled = true
		self.texFineTogle.isOn = true
	end
	
	local OnUseSettingChanged = function()
		SetTexSettingActive()
	end
	
	local MusicSettingChanged = function(value)
		if not value then
		   self.MusicSettingScrBar.value = 0
		   self.MusicSettingImg.sprite =ResourceManager.LoadSprite("AutoGenerate/SystemSet/bgbtnoff")
		else
		   self.MusicSettingScrBar.value = 1
		   self.MusicSettingImg.sprite =ResourceManager.LoadSprite("AutoGenerate/SystemSet/bgbtnon")
		end
        SoundManager.SwitchBgm(value)
	end
	
	local SoundSettingChanged = function(value)
		if not value then
		   self.SoundSettingScrBar.value = 0
		   self.SoundSettingImg.sprite =ResourceManager.LoadSprite("AutoGenerate/SystemSet/bgbtnoff")
		else
		   self.SoundSettingScrBar.value = 1
		   self.SoundSettingImg.sprite = ResourceManager.LoadSprite("AutoGenerate/SystemSet/bgbtnon")
		end
        SoundManager.SwitchAudioEffect(value)
	end
    
    local OnVolumeChanged = function(value)
        SoundManager.SetVolume(value)
    end
	
	local InPlaceHook = function(check)
		if check == true then
        GlobalManager.HookRadius = 0
		end
	end
	
	local SmallRangeHook = function(check)
		if check == true then
        GlobalManager.HookRadius = self.hookSmallRadius
		end
	end
	
	local WideRangeHook = function(check)
		if check == true then
        GlobalManager.HookRadius = self.hookWideRadius
		end
	end
    
    local SwitchAccount = function()
        SceneManager.EnterScene('ReLogin', function() UIManager.PushView(ViewAssets.LoginPanelUI) end)  
    end
    
    local ReselectRole = function()
        local callBack = function()
            local inpuetNameValue = UnityEngine.PlayerPrefs.GetString("UserName")
            local inpuetPwdValue = UnityEngine.PlayerPrefs.GetString("Password")
            local data = {}
            data.user_name = inpuetNameValue
            data.password = inpuetPwdValue 
            data.device_id = Game.deviceId
            MessageManager.RequestLua(constant.CS_MESSAGE_LOGIN_LOGIN, data)
        end
        local ip = AppFacade.Instance.networkManager.MainConnection.IP
		local port = AppFacade.Instance.networkManager.MainConnection.PORT
		-- AppFacade.Instance.networkManager.MainConnection:Close()
		ConnectionManager.ConnectMainServer(ip, port, callBack)
    end
    
    local OnLoginReceive = function(data)
		CameraManager.CameraController.gameObject:SetActive(false)	
        SceneManager.EnterScene('SelectActorScence',function() 
            UIManager.PushView(ViewAssets.SelectRoleUI,nil,data)    
        end) 
    end

	local OnShowLowest = function(check)
		if check == true then
        	GlobalManager.SetMaxDisplayLevel(1)
		end
	end
	local OnShowLow = function(check)
		if check == true then
        	GlobalManager.SetMaxDisplayLevel(2)
		end
	end
	local OnShowMedium = function(check)
		if check == true then
        	GlobalManager.SetMaxDisplayLevel(3)
		end
	end
	local OnShowMost = function(check)
		if check == true then
        	GlobalManager.SetMaxDisplayLevel(4)
		end
	end
	
	local OnShowEffectLowest = function(check)
		if check == true then
			GlobalManager.SetMaxEffectDisplayLevel(1)
		end
	end
	
	local OnShowEffectLow = function(check)
		if check == true then
			GlobalManager.SetMaxEffectDisplayLevel(2)
		end
	end
	
	local OnShowEffectMedium = function(check)
		if check == true then
			GlobalManager.SetMaxEffectDisplayLevel(3)
		end
	end
	
	local OnShowEffectMost = function(check)
		if check == true then
			GlobalManager.SetMaxEffectDisplayLevel(4)
		end
	end
	--[[
	self.BackToBornPointRet = function(data)
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
			return
		end

		local pos = data.pos
		hero:SetPosition(Vector3.New(pos[1] / 100, pos[2] / 100, pos[3] / 100))
		hero:SetNavMesh(false)
		--MessageRPCManager.RemoveUser(self, 'BackToBornPointRet')
	end
	]]
	local ResetHeroPlaceRequest = function()
		local data = {}   
		data.func_name = 'on_back_to_born_point'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		UIManager.HideProcessBar()
	end
	
	local ResetHeroPrecess = function()
		local timeDela = 3
		UIManager.ShowProcessBarByTime(timeDela, '卡住脱离中..')
		Timer.Delay(timeDela, ResetHeroPlaceRequest)
		Close()
	end
	
	local OnResetHeroPlace = function()
		
		UIManager.ShowDialog('执行此操作，将会强制返回当前地图对应复活点，是否确认？', '确定', '取消', ResetHeroPrecess, nil)
	end

    local PurchaseDrugs = function()
		 self.close()
		 local normalShopUI = UIManager.GetCtrl(ViewAssets.NormalShopUI)
         normalShopUI.OpenUI('grocery')
		 normalShopUI.preAssetUI = ViewAssets.SystemSettingUI
	end

	local initUnitNumUI = function()
		local level = GlobalManager.GetMaxDisplayLevel()
		if level == 1 then
			self.view.UnitNumLowest:GetComponent('Toggle').isOn = true
		elseif level == 2 then
			self.view.UnitNumLow:GetComponent('Toggle').isOn = true	
		elseif level == 3 then
			self.view.UnitNumMedium:GetComponent('Toggle').isOn = true
		elseif level == 4 then
			self.view.UnitNumMost:GetComponent('Toggle').isOn = true
		end
	end

	local initDrugItems = function(datas)
		  self.view.DrugItem:SetActive(true)
		  local i = 1
		  for _,id in pairs(datas) do
			local clone = GameObject.Instantiate(self.view.DrugItem)
		    clone:GetComponent("LuaBehaviour").luaTable.SetData(id)
            clone.transform:SetParent(self.view.DrugsSelectContent.transform,false)
			DrugItemList[i] = clone
			i = i+1
		  end
		self.view.DrugItem:SetActive(false)
	end
	
	self.HideDrugItems = function(Itemtpye,sprite)
		if Itemtpye == 'HP' then
		   self.view.iconDrugs1:GetComponent("Image").overrideSprite = sprite
		   self.view.iconDrugs1:GetComponent("Image").material =  nil
		elseif Itemtpye == 'MP' then
		   self.view.iconDrugs2:GetComponent("Image").overrideSprite = sprite
		   self.view.iconDrugs2:GetComponent("Image").material =  nil
		elseif Itemtpye == 'PetHP' then
		   self.view.iconDrugs3:GetComponent("Image").overrideSprite = sprite
		   self.view.iconDrugs3:GetComponent("Image").material =  nil
		end
	    self.view.BgDrugsSelect:SetActive(false)
		for i = 1 ,#DrugItemList do
			GameObject.Destroy(DrugItemList[i])
			DrugItemList[i] = nil
		end
	end
	
	local initHookSetting = function()
		self.AddClick(self.view.PurchaseButton,PurchaseDrugs)
         ClickEventListener.Get(self.view.DrugsSelectBK).onClick = function() self.HideDrugItems() end
		ClickEventListener.Get(self.view.iconDrugs1).onClick = function() 
		   if self.view.BgDrugsSelect.activeSelf == true then self.HideDrugItems() return end
		   self.view.BgDrugsSelect:SetActive(true) 
		   local Herodrugs = BagManager.GetBloodDrugIds()
		   table.sort(Herodrugs,function(a,b) return itemTable.Item[a].LevelLimit < itemTable.Item[b].LevelLimit end)
		   initDrugItems(Herodrugs)
		end
		ClickEventListener.Get(self.view.iconDrugs2).onClick = function() 
		   if self.view.BgDrugsSelect.activeSelf == true then self.HideDrugItems() return end
		   self.view.BgDrugsSelect:SetActive(true) 
		   local Herodrugs = BagManager.GetMagicDrugIds()
		   table.sort(Herodrugs,function(a,b) return itemTable.Item[a].LevelLimit < itemTable.Item[b].LevelLimit end)
		   initDrugItems(Herodrugs)
		end
		
		ClickEventListener.Get(self.view.iconDrugs3).onClick = function() 
		   if self.view.BgDrugsSelect.activeSelf == true then self.HideDrugItems() return end
		   self.view.BgDrugsSelect:SetActive(true) 
		   local Herodrugs = BagManager.GetPetBloodDrugIds()
		   table.sort(Herodrugs,function(a,b) return itemTable.Item[a].LevelLimit < itemTable.Item[b].LevelLimit end)
		   initDrugItems(Herodrugs)
		end
	end
	
    self.onLoad = function()
		self.Scrollbar = self.view.BasicSettingScrollbar:GetComponent('Scrollbar')

		self.HealthSupplyToggle = self.view.HealthSupplySetting:GetComponent('Toggle')
		self.MagicSupplyToggle = self.view.MagicSupplySetting:GetComponent('Toggle')
        self.TxtHealthSupply = self.view.TxtHealthSupply:GetComponent('TextMeshProUGUI')
		self.TxtMagicSupply = self.view.TxtMagicSupply:GetComponent('TextMeshProUGUI')
		self.TxtPetHealthSupply = self.view.TxtPetHealthSupply:GetComponent('TextMeshProUGUI')
        UIUtil.AddToggleListener(self.view.btnBasicset,OnBasicSetChanged)
		UIUtil.AddToggleListener(self.view.btnadvancedset,OnAdvancedsetChanged)
		UIUtil.AddToggleListener(self.view.btnAccountSet,OnAccountSetChanged)
		UIUtil.AddToggleListener(self.view.btnHookset,OnHooksetChanged)
		--ClickEventListener.Get(self.view.btnrule).onClick = OnOk
		ClickEventListener.Get(self.view.btnClose).onClick = Close
		UIUtil.AddScrollBarListener(self.view.HealthSupplyScrBar,HealthSupplyChanged)
		UIUtil.AddScrollBarListener(self.view.MagicSupplyScrBar,MagicSupplyChanged)
		UIUtil.AddScrollBarListener(self.view.PetMagicSupplyScrBar,PetHealthSupplyChanged)
		UIUtil.AddToggleListener(self.view.Smooth,OnSmoothChanged)
		UIUtil.AddToggleListener(self.view.Balanced,OnBalancedChanged)
		UIUtil.AddToggleListener(self.view.Fine,OnFineChanged)
		UIUtil.AddToggleListener(self.view.UseSetting,OnUseSettingChanged)
		UIUtil.AddToggleListener(self.view.SwitchingDrug,SwitchingDrugChanged)
        self.HealthSupplyBar =  self.view.HealthSupplyScrBar:GetComponent('Scrollbar')
		self.PetHealthSupplyBar =  self.view.PetMagicSupplyScrBar:GetComponent('Scrollbar')
		self.MagicSupplyBar =  self.view.MagicSupplyScrBar:GetComponent('Scrollbar')
		self.MusicSettingScrBar = self.view.MusicSetting:GetComponent('Scrollbar')
		self.MusicSettingImg = self.view.MusicSetting:GetComponent('Image')
		MusicSettingChanged(SoundManager.GetBgmOn())
        self.view.btnBasicset:GetComponent('Toggle').isOn = true
		self.SoundSettingScrBar = self.view.SoundSetting:GetComponent('Scrollbar')
		self.SoundSettingImg = self.view.SoundSetting:GetComponent('Image')

		self.UseSettingTogle = self.view.UseSetting:GetComponent('Toggle')
		self.texMediumTogle = self.view.TexSettingMedium:GetComponent('Toggle')
		self.texFineTogle = self.view.TexSettingFine:GetComponent('Toggle')
		self.texLowTogle = self.view.TexSettingLow:GetComponent('Toggle')
        SoundSettingChanged(SoundManager.GetAudioEffectOn())
        
		ClickEventListener.Get(self.view.MusicSetting).onClick = function() MusicSettingChanged(not SoundManager.GetBgmOn()) end
		ClickEventListener.Get(self.view.SoundSetting).onClick = function() SoundSettingChanged(not SoundManager.GetAudioEffectOn()) end
        
        self.view.VolumeSetting:GetComponent('Scrollbar').value = SoundManager.GetVolume()
        UIUtil.AddScrollBarListener(self.view.VolumeSetting,OnVolumeChanged)
        
		UIUtil.AddToggleListener(self.view.InPlace,InPlaceHook)
		UIUtil.AddToggleListener(self.view.SmallRange,SmallRangeHook)
		UIUtil.AddToggleListener(self.view.WideRange,WideRangeHook)
        self.AddClick(self.view.btnReselectrole,ReselectRole)
        self.AddClick(self.view.btnSwitchaccount,SwitchAccount)
		self.AddClick(self.view.btnLinecard, OnResetHeroPlace)
        MessageManager.RegisterMessage(constant.SC_MESSAGE_LOGIN_LOGIN, OnLoginReceive)
		--MessageRPCManager.AddUser(self, 'BackToBornPointRet')
		initHookSetting()
		-- 最大同屏人数
		initUnitNumUI()
        UIUtil.AddToggleListener(self.view.UnitNumLowest, OnShowLowest)
		UIUtil.AddToggleListener(self.view.UnitNumLow, OnShowLow)
		UIUtil.AddToggleListener(self.view.UnitNumMedium, OnShowMedium)
		UIUtil.AddToggleListener(self.view.UnitNumMost, OnShowMost)
		UIUtil.AddToggleListener(self.view.EffectNumLowest, OnShowEffectLowest)
		UIUtil.AddToggleListener(self.view.EffectNumLow, OnShowEffectLow)
		UIUtil.AddToggleListener(self.view.EffectNumMedium, OnShowEffectMedium)
		UIUtil.AddToggleListener(self.view.EffectNumMost, OnShowEffectMost)
		OnBasicSetChanged()
		currentSet= Setting_Type.BasicSetting
    end 
	
    self.onUnload = function()
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LOGIN_LOGIN, OnLoginReceive)
		if self.view.BgDrugsSelect.activeSelf == true then self.HideDrugItems() end
	end
    
	return self
end

return CreateSystemSettingCtrl()
