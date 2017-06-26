---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/22
-- desc： 阵营选择
---------------------------------------------------
require "UI/Controller/LuaCtrlBase"

local function CreatePKUICtrl()
	local self = CreateCtrlBase()

	self.selectMode = ''
	self.pkData = nil

	local closeClick = function()
		self.close()
	end
	
	local okClick = function()
		local hero = SceneManager.GetEntityManager().hero
        if not hero then
			print('not found hero')
			closeClick()
        	return
        end
        if self.selectMode == self.pkData.pkMode then
			closeClick()
        	return
        end
		if self.selectMode == PKMode.Killed then
			UIManager.ShowDialog(
				"开启杀戮模式后，可以攻击除队伍外所有玩家，击杀己方阵营会降低善恶值，确定要开启吗？", 
				'确定', 
				'取消', 
				function()
					PKManager.requestChangePKMode(self.selectMode)
					closeClick()
	    		end)
		else
			PKManager.requestChangePKMode(self.selectMode)
			closeClick()
		end		
	end
	
	local cancelClick = function()
		closeClick()
	end

	local onHelpClick = function()		
		UIManager.PushView(ViewAssets.TipsUI, nil,' 1规则\r\n\r\n 2规则\r\n\r\n 3规则\r\n\r\n 4规则')
	end

	local updateUI = function()
		for i = 1, 4 do
        	self.view['btnmode' .. i]:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/PKUI/btn_classification')
        end

        if self.selectMode == PKMode.Peace then
        	-- do nothing
        elseif self.selectMode == PKMode.Contry then
        	self.view['btnmode1']:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/PKUI/btnclassificationdown')
        	self.view.textdescribe:GetComponent("TextMeshProUGUI").text = tableText(3131001)
        elseif self.selectMode == PKMode.Party then
        	self.view['btnmode2']:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/PKUI/btnclassificationdown')
        	self.view.textdescribe:GetComponent("TextMeshProUGUI").text = tableText(3131003)
        elseif self.selectMode == PKMode.Killed then
        	self.view['btnmode3']:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/PKUI/btnclassificationdown')
        	self.view.textdescribe:GetComponent("TextMeshProUGUI").text = tableText(3131004)
        elseif self.selectMode == PKMode.GoodEvil then
        	self.view['btnmode4']:GetComponent('Image').sprite = ResourceManager.LoadSprite('AutoGenerate/PKUI/btnclassificationdown')
        	self.view.textdescribe:GetComponent("TextMeshProUGUI").text = tableText(3131002)
        end
		self.view.textpknumber:GetComponent("TextMeshProUGUI").text = 'PK值:' .. self.pkData.pkNum .. " 善恶值:" .. self.pkData.friendNum 
	end

	local onSelectClick = function(i)
		if i == 1 then
			self.selectMode = PKMode.Contry
		elseif i == 2 then
			self.selectMode = PKMode.Party
		elseif i == 3 then
			self.selectMode = PKMode.Killed
		elseif i == 4 then
			self.selectMode = PKMode.GoodEvil
		end
		updateUI()
	end

	self.GetPkInfoRet = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end

		if data.actor_id ~= self.pkData.uid then
			return
		end
		self.pkData.update(data)
		updateUI()
	end
	self.onLoad = function()
		local pkdata = PKManager.getHeroPkData()
		self.pkData = pkdata
		self.selectMode = pkdata.pkMode

        ClickEventListener.Get(self.view.btnclose).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnclose, nil, nil)

        ClickEventListener.Get(self.view.btndetermine).onClick = okClick
        UIUtil.AddButtonEffect(self.view.btndetermine, nil, nil)

        ClickEventListener.Get(self.view.btnback).onClick = cancelClick
        UIUtil.AddButtonEffect(self.view.btnback, nil, nil)

        for i = 1, 4 do
	        ClickEventListener.Get(self.view['btnmode' .. i]).onClick = function() 
	        	onSelectClick(i)
	   		end
	        UIUtil.AddButtonEffect(self.view['btnmode' .. i], nil, nil)
        end
        --ClickEventListener.Get(self.view.btnrules).onClick = onHelpClick
        UIUtil.AddButtonEffect(self.view.btnrules, nil, nil)

        updateUI()
		MessageRPCManager.AddUser(self, 'GetPkInfoRet') 
		PKManager.requestGetPKInfo(self.pkData.uid)
	end
	
	self.onUnload = function()
		MessageRPCManager.RemoveUser(self, 'GetPkInfoRet') 
	end
	
	return self
end

return CreatePKUICtrl()