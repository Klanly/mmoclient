require "UI/Controller/LuaCtrlBase"

local function CreateCreateRoleUICtrl()
	local self = CreateCtrlBase()
	
    local currentVocaiton = 1
    local currentSex = 1
    local currentCountry = 1
    local constant = require "Common/constant"
    local loginConfig = require 'Logic/Scheme/system_login_create'
	local OnCreateActorClick = function()
		local data = {}
		
		local name = string.trim(self.view.InputField:GetComponent("TMP_InputField").text)
		if string.utf8len(name) <= constant.PLAYER_NAME_MIN_LENTH or string.utf8len(name) >= constant.PLAYER_NAME_MAX_LENTH then
			UIManager.ShowNotice(string.format("名字长度必须大于%d字符或小于%d字符",constant.PLAYER_NAME_MIN_LENTH,constant.PLAYER_NAME_MAX_LENTH))
			return
		end
		local v = currentVocaiton
		local c = currentCountry
		if c == 3 then  --随机
			c = 'random'
		end
		
		local s = currentSex
		local data = {
			actor_name = name,
			vocation = v,
			country = c,
			sex = s,
		}		
		MessageManager.RequestLua(constant.CS_MESSAGE_LOGIN_CREATE_ACTOR, data)
	end
	
	local OnRandomNameClick = function()	
		local vocationGender = currentSex 
		
		local length = #systemLoginCreate.FristName
		local ran = math.random(1, length)
		local firstName = systemLoginCreate.FristName[ran].FirstName
		local secondName
		
		if vocationGender == 1 then		--男性		
			length = #systemLoginCreate.RandManName
			ran = math.random(1, length)
			secondName = systemLoginCreate.RandManName[ran].ManName			
		else   --女性		
			length = #systemLoginCreate.RandWomanName
			ran = math.random(1, length)
			secondName = systemLoginCreate.RandWomanName[ran].WomanName		
		end
		
		local name = firstName .. secondName
		local inpuetFieldValue = self.view.InputField:GetComponent("TMP_InputField")
		inpuetFieldValue.text = name
	end
	
	local OnCreateRole = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end	
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LOGIN)
	end
    
	local onBackClick = function()
		if #self.data.actor_list <= 0 then
            SceneManager.EnterScene('ReLogin', function() UIManager.PushView(ViewAssets.LoginPanelUI) end)  
			return
		end
		UIManager.LoadView(ViewAssets.SelectRoleUI,nil,self.data)		
	end

	local OnVactionChanged = function(vocation)
        currentVocaiton = vocation
        for i=1,4 do
            local toggle = self.view['toggle'..i].transform
            toggle:FindChild('normal').gameObject:SetActive(currentVocaiton ~= i)
            toggle:FindChild('light').gameObject:SetActive(currentVocaiton == i)
        end
        
		local modelData = systemLoginCreate.RoleModel[currentVocaiton]
		if modelData then		
			self.view.vocationDes:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(modelData,'Description')
		end
		
		self.CreateModel(currentVocaiton, currentSex)
	end

	local OnCountryChanged = function(country)
        if currentCountry == country and country == 3 then --删除打勾
            currentCountry = math.random(1,2)
            self.view['btnCountry'..currentCountry]:GetComponent('Toggle').isOn = true
        else
            currentCountry = country
        end

		local campData = systemLoginCreate.Camp[currentCountry]
		if campData then
			self.view.countryDes:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(campData,'Description')
			self.view.countryName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(campData,'Name')
		end
	end
	
	local OnSexChanged = function(sex)
        currentSex = sex		
		self.CreateModel(currentVocaiton, currentSex)
	end
    
    local showTimer = nil
    local inShow = false
    local index = 1
    local clipNames = {}
    self.ShowAction = function(event)
        if self.model and not event.dragging and not inShow then
            if clipNames[index] == nil then
                index = 1
            end
            local anim = self.model:GetComponent('PuppetBehavior')
            self.RemoveTimer()
            showTimer = Timer.Delay(anim:PlayAnimation(clipNames[index]),self.ResetModelAnimation)
            inShow = true
            index = index + 1            
        end
    end
    
    self.ResetModelAnimation = function()
        if self.model then
            local anim = self.model:GetComponent('PuppetBehavior')
            anim:PlayAnimation('NormalStandby')
            self.RemoveTimer()
            showTimer = Timer.Delay(15,function()self.ShowAction({}) end)
        end
        inShow = false
    end
    
    self.RemoveTimer = function()
        if showTimer then Timer.Remove(showTimer) showTimer = nil end
    end
	
	self.CreateModel = function(vocation, sex,head,body,weapon)
 		self.DeleteModel(self.model)

		local resConfig = require "Logic/Scheme/common_art_resource"
		local vocationSeg = 'MaleSuit'
        if sex == 2 then
			vocationSeg = 'FemaleSuit'
		end
		currentSex = sex
		local suits = systemLoginCreate.RoleModel[vocation][vocationSeg]
        if not head then head = suits[1] end
        if not body then body  = suits[2] end
        if not weapon then weapon = suits[3] end
        local AddEffectEvent = function(behavior)
            local vocationSeg = 'MaleAction'
            if currentSex == 1 then
                vocationSeg = 'MaleAction'
            elseif currentSex == 2 then
                vocationSeg = 'FemaleAction'
            end
            local clipNameStr = systemLoginCreate.RoleModel[currentVocaiton][vocationSeg]
            clipNames = string.split(clipNameStr,'|')
            local confingTable = GetConfig("MotionEffects")
            local modelID = LuaUIUtil.GetHeroModelID(vocation,sex)
            for _,clipName in pairs(clipNames) do
                if confingTable[modelID] and confingTable[modelID][clipName]and confingTable[modelID][clipName].motionEffects then
                    for _,v in pairs(confingTable[modelID][clipName].motionEffects) do   
                        behavior:AddEffectEvent(v.clipName, v.delayTime, v.effectPath, v.nodePath, v.detach, v.duration,
                            v.delayDestroyTime or 0, Vector3.New(v.positionX, v.positionY, v.positionZ),
                            Vector3.New(v.rotationX, v.rotationY, v.rotationZ),
                            Vector3.New(v.scaleX, v.scaleY, v.scaleZ))
                    end
                end
            end
        end
 	    self.behavior = EntityBehaviorManager.CreateHero(vocation,sex,0,0,1,Vector3.New(-26.4, 29.94, -12),2.65,AddEffectEvent,head,body,weapon)
        self.model = self.behavior.gameObject
        -- local NavMeshAgent = self.model:GetComponent('NavMeshAgent')
        -- if NavMeshAgent then
        --     NavMeshAgent.enable = false
        -- end

        local rotationModel = self.model:GetComponent('RotationModel')
        if not rotationModel then        
            self.model:AddComponent(typeof(RotationModel))
        end
        local rotate = self.model.transform.localEulerAngles
        self.model.transform.localEulerAngles = rotate
        

    
        index = 1
        self.RemoveTimer()
        showTimer = Timer.Delay(1,function()self.ShowAction({}) end)
 	end

 	self.DeleteModel = function()
 		if self.model then
            self.model:GetComponent('PuppetBehavior'):RemoveAllEffectGameObject()
 			EntityBehaviorManager.Destroy(0)
 			self.model = nil
 		end
        self.RemoveTimer()
        inShow = false
 	end


	-- 当view被加载时事件
	self.onLoad = function(data)
		self.data = data
        
        for i=1,3 do
            self.AddClick(self.view['toggle'..i].transform:FindChild('normal').gameObject,function() OnVactionChanged(i) end)
        end
        self.AddClick(self.view.toggle4.transform:FindChild('normal').gameObject, function() UIManager.ShowNotice('该职业暂未开放') end)
        self.AddClick(self.view.btnMale,function() OnSexChanged(1) end)
        self.AddClick(self.view.btnFemale,function() OnSexChanged(2) end)
        self.AddClick(self.view.btnCountry1,function() OnCountryChanged(1) end)
        self.AddClick(self.view.btnCountry2,function() OnCountryChanged(2) end)
        self.AddClick(self.view.randomCountry,function() OnCountryChanged(3) end)

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LOGIN_CREATE_ACTOR, OnCreateRole)
		ClickEventListener.Get(self.view.randomName).onClick = OnRandomNameClick
		ClickEventListener.Get(self.view.btnEnter).onClick = OnCreateActorClick
        ClickEventListener.Get(self.view.btnBack).onClick = onBackClick
        DragEventListener.Get(self.view.btnShowAction).onDrag = nil
        self.AddClick(self.view.btnShowAction,self.ShowAction)
		OnCountryChanged(3)
        OnVactionChanged(1)
        OnSexChanged(1)
        OnRandomNameClick()
	end
	
	-- 当view被卸载时事件
	self.onUnload = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LOGIN_CREATE_ACTOR, OnCreateRole)
		self.DeleteModel()
        
	end

	return self
end

return CreateCreateRoleUICtrl()
