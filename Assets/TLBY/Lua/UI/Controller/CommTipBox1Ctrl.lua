--
-- Created by IntelliJ IDEA.
-- User: zz
-- Date: 2016/12/13
-- Time: 20:58
--

require "UI/Controller/LuaCtrlBase"

local commTipBox1Key = 'SaveCommTipBox1Flag'

local function CreateCommTipBox1Ctrl()
    local self = CreateCtrlBase()
	local okHandler
	local identifier
	local saveToggleScript

    local function Close()
        UIManager.UnloadView(ViewAssets.CommTipBox1)
    end
	
	local GetCommTipBox1Key = function()
	
		local loginData = MyHeroManager.heroData
		local actorId = loginData.actor_id
		local saveTipKey = actorId..commTipBox1Key
		if identifier then
		
			saveTipKey = saveTipKey..identifier
		end
		
		return saveTipKey
	end
	
	local OnSaveChanged = function()			--
	
		if saveToggleScript then
		
			local saveTipKey = GetCommTipBox1Key()
			if saveToggleScript.isOn then   --今天不在提示
			
				local nowTime = os.time()
				UnityEngine.PlayerPrefs.SetString(saveTipKey, "1")
				UnityEngine.PlayerPrefs.SetString(saveTipKey..'time', tostring(nowTime))
				
			else

				UnityEngine.PlayerPrefs.SetString(saveTipKey, "0")
			end
		end
	end
	
	local OnOk = function()
	
		if okHandler then
		
			okHandler()
		end
		
		OnSaveChanged()
		Close()
	end
	

    self.onLoad = function()
	
		ClickEventListener.Get(self.view.btnquitdesign).onClick = Close
		ClickEventListener.Get(self.view.BtnOk).onClick = OnOk
		ClickEventListener.Get(self.view.BtnCancel).onClick = Close
		--UIUtil.AddToggleListener(self.view.Save, OnSaveChanged)
		saveToggleScript = self.view.Save:GetComponent('Toggle')
		
		local saveTipKey = GetCommTipBox1Key()
		local saveFlag = UnityEngine.PlayerPrefs.GetString(saveTipKey, "0")
		if saveFlag == '0' then
		
			saveToggleScript.isOn = false
		else

			saveToggleScript.isOn = true
		end
    end
	
	local IsShowTip = function()
	
		local isShow = true
		local saveTipKey = GetCommTipBox1Key()
		local saveFlag = UnityEngine.PlayerPrefs.GetString(saveTipKey, '0')
		local saveTime = UnityEngine.PlayerPrefs.GetString(saveTipKey..'time', '0')
		if (saveFlag == '0' or saveTime == '0') then
		
			return isShow
		end
		
		local saveTimeValue = tonumber(saveTime)
		local nowTimeValue = os.time()
		local temp1 = os.date("*t", saveTimeValue)
		local temp2 = os.date("*t", nowTimeValue)
		if temp1.year == temp2.year and     --一天之内不提示
		   temp1.month == temp2.month and
		   temp1.day == temp2.day then

		   isShow = false
		end
		
		return isShow
	end
	
	--data.okHandler 	确定回调
	--data.title  		标题
	--data.content 		内容
    self.Show = function(data)
		
		okHandler = data.okHandler
		identifier = data.identifier  --标识是唯一的，用来表示当前弹出框的唯一性，用来判断‘今天不再提示’功能对哪个弹出框起作用
		
		--[[
		local saveTipKey = GetCommTipBox1Key()
		local saveFlag = UnityEngine.PlayerPrefs.GetString(saveTipKey, '0')
		local saveTime = UnityEngine.PlayerPrefs.SetString(saveTipKey..'time', '0')
		if saveTime ~= '0' then
		
			
		end
		]]
		if (not IsShowTip()) then  --不再提示弹出框
			
			OnOk()
			return
		end
		
		local title = data.title
		local titleScript = self.view.Title:GetComponent('TextMeshProUGUI')
		if title then
		
			titleScript.text = title
		else
		
			titleScript.text = ''
		end
		
		local content = data.content
		local contentScript = self.view.Content:GetComponent('TextMeshProUGUI')
		if content then
		
			contentScript.text = content
		else
		
			contentScript.text = ''
		end
    end

    return self
end

return CreateCommTipBox1Ctrl()


