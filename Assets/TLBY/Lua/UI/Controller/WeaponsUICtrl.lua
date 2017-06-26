-----------------------------------------------------
-- auth： zhangzeng
-- date： 2016/10/18
-- desc： 宝印UI
-----------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateWeaponsUICtrl()

    local self = CreateCtrlBase()
	local pageIndex = 1
	local timeInfo
	
	local function OnClose()
		BagManager.CloseItemTips()
		UIManager.UnloadView(ViewAssets.WeaponsUI)
	end
	
	local function SetNeedItems(itemIds, data)

		local view = self.view
		local nameBase = "material"
		for i = 1, 3 do
			ClickEventListener.Remove(view[nameBase .. i])
			view[nameBase .. i]:SetActive(false)
			view["textmaterial" .. i .. "conditions"]:GetComponent("TextMeshProUGUI").text = ""
		end

		local length = #data
		for i = 1, length do
			ClickEventListener.Get(view[nameBase .. i]).onClick = function()
				BagManager.ShowItemTips({item_data={id=itemIds[i]}},true)
			end
			view[nameBase .. i]:SetActive(true)
			local image = view[nameBase .. i]:GetComponent('Image')
			image.overrideSprite = LuaUIUtil.GetItemIcon(itemIds[i])
			view["textmaterial" .. i .. "conditions"]:GetComponent("TextMeshProUGUI").text = data[i]
		end
	end
	
	local function RetBaoYinInfo(data)			--服务器返回宝印属性
	
		local view = self.view
		
		if (pageIndex == 1) then
		
			view.textsuccessratedigital:GetComponent("TextMeshProUGUI").text = data.seal_ratio .. "%"
			view.textLimitPetLeveValue:GetComponent("TextMeshProUGUI").text = data.seal_level_limit
			view.textReikiLimitAddValue:GetComponent("TextMeshProUGUI").text = data.energy_ceiling
			view.textReikiAddSpeeValue:GetComponent("TextMeshProUGUI").text = data.energy_recover_speed .. "/小时"
			--view.textPetExpValue:GetComponent("TextMeshProUGUI").text = data.pet_exp_speed .. "/小时"
			view.textExpericeValue:GetComponent("TextMeshProUGUI").text = data.capture_energy .. '/' .. data.energy_ceiling 
			view.petexperienceprogressbar:GetComponent("Image").fillAmount = data.capture_energy / data.energy_ceiling
			
		elseif (pageIndex == 2) then
		
			view.text1weaponsattributedigital:GetComponent("TextMeshProUGUI").text = data.seal_ratio .. "%"
			view.text1LimitPetLeveValue:GetComponent("TextMeshProUGUI").text = data.seal_level_limit
			view.text1ReikiLimitAddValue:GetComponent("TextMeshProUGUI").text = data.energy_ceiling
			view.text1ReikiAddSpeeValue:GetComponent("TextMeshProUGUI").text = data.energy_recover_speed .. "/小时"
			--view.text1PetExpValue:GetComponent("TextMeshProUGUI").text = data.pet_exp_speed .. "/小时"
			view.textweapons1lv:GetComponent("TextMeshProUGUI").text = data.seal_phase .. "阶" .. data.seal_level .. "段"
			
			local sealPhase = data.seal_phase    --宠物阶段  
			local sealLevel = data.seal_level	 --宠物等级
			local name = sealPhase .. '_' .. sealLevel
			local baoWuUpgrade = GrowingPet["BaoWuUpgrade"]
			local item = baoWuUpgrade[name]
			--item.Prop1			--道具
			local num = {}
			local itemIds = {}
			local j = 1
			local bagProps = BagManager.items
			for k, v in pairs(item.Prop1) do
			
				if (k % 2 == 1) then
				
					local haveNums = 0
					haveNums = BagManager.GetItemNumberById(v)
					num[j] = haveNums .. "/" .. item.Prop1[k + 1]
					itemIds[j] = v
					j = j + 1
				end
			end
			
			SetNeedItems(itemIds, num)
			
			if (sealLevel < 10) then
			
				sealLevel = sealLevel + 1
			else	
				
				if (sealPhase < 3) then
				
					sealPhase = sealPhase + 1
				end
			end
			
			view.textweapons2lv:GetComponent("TextMeshProUGUI").text = sealPhase .. "阶" .. sealLevel .. "段"
			
			name = sealPhase .. '_' .. sealLevel
			item = baoWuUpgrade[name]
			
			view.text2weaponsattributedigital:GetComponent("TextMeshProUGUI").text = item.SuccessRate .. "%"
			view.text2LimitPetLeveValue:GetComponent("TextMeshProUGUI").text = item.SealLv
			view.text2ReikiLimitAddValue:GetComponent("TextMeshProUGUI").text = item.NimbusLimit
			view.text2ReikiAddSpeeValue:GetComponent("TextMeshProUGUI").text = item.NimbusRecoverSpeed .. "/小时"
			--view.text2PetExpValue:GetComponent("TextMeshProUGUI").text = item.PetExp .. "/小时"
		end
	end
	
	local function HideUpgrade()
	
		local view = self.view
		view.advanceduiRet:SetActive(false)
	end
	
	local function RetUpgradeBaoYin(data)      --服务器返回宝印升级
	
		local view = self.view
		if not (data.result == 0) then
			
			--升阶失败
			view.advanceduiRet:SetActive(true)
			view.advanceduiRetFailImag:SetActive(true)
			view.advanceduiRetSuccessImag:SetActive(false)
			
			if (timeInfo) then
			
				Timer.Remove(timeInfo)
			end
			timeInfo = Timer.Numberal(1, 1, HideUpgrade)
			
			return
		end
		
		RetBaoYinInfo(data.info)
		
		--升阶成功
		view.advanceduiRet:SetActive(true)
		view.advanceduiRetFailImag:SetActive(false)
		view.advanceduiRetSuccessImag:SetActive(true)
		
		if (timeInfo) then
			
			Timer.Remove(timeInfo)
		end
		timeInfo = Timer.Numberal(1, 1, HideUpgrade)
	end
	
	local function OnTab1()
	
		local view = self.view
		pageIndex = 1
		view.Weaponsui:SetActive(true)
		view.advancedui:SetActive(false)
		view.btnpagingbtn:SetActive(true)
		view.btnpagingbtn1:SetActive(false)
		
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_SEAL_INFO, {}) --请求宝印信息
	end
	
	local function OnTab2()
	
		local view = self.view
		pageIndex = 2
		view.Weaponsui:SetActive(false)
		view.advancedui:SetActive(true)
		view.btnpagingbtn:SetActive(false)
		view.btnpagingbtn1:SetActive(true)
		
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GET_SEAL_INFO, {})	--请求宝印信息
	end
	
	local function OnAdvance()
	
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_SEAL_UPGRADE, {})	--请求宝印升级
	end
	
	local function OnShowPetUI()
		OnClose()
        UIManager.GetCtrl(ViewAssets.PetUI).ShowPetUI()
	end
    
	function self.onLoad()
	
		local view = self.view
		ClickEventListener.Get(view.btnclose).onClick = OnClose
		ClickEventListener.Get(view.btnadvancedbtn0).onClick = OnTab1
		ClickEventListener.Get(view.textadvancebtn).onClick = OnTab2
		ClickEventListener.Get(view.btnadvancedbg).onClick = OnAdvance
		ClickEventListener.Get(view.textbtnpet).onClick = OnShowPetUI
		
		HideUpgrade()
		
		OnTab1()
		
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_GET_SEAL_INFO, RetBaoYinInfo)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_SEAL_UPGRADE, RetUpgradeBaoYin)		
	end
	
	-- 当view被卸载时事件
	function self.onUnload()
	
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_GET_SEAL_INFO, RetBaoYinInfo)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_SEAL_UPGRADE, RetUpgradeBaoYin)		
	end
	
    return self
end

return CreateWeaponsUICtrl()