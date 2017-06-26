---------------------------------------------------
-- auth： 张增
-- date： 2016/9/20
-- desc： 抓宠
---------------------------------------------------
require "Common/basic/LuaObject"
require "UI/Controller/CatchPetUICtrl"
require "Common/constant"

ArrestPetState =
{
	Idle = 1,                  	--什么事都没做
	Ready = 2,				  	--准备抓宠
	Request = 3,				--(向服务器)请求抓宠
	ArrestIn = 4,			  	--抓宠中
	Cooling  = 5,				--冷却中
}

local CreateArrestPetModel = function()
	local self = {}
	local model = nil
	
	self.CreateModel = function(prefab, pos, func)
		if model == nil then
			ResourceManager.CreateEffect(prefab, function(object)
				model = object
				model.transform.position = pos
				func(model)
			end)
		end
	end
	
	self.SetLineRenderPosition = function(lineRenderer, index, pos)
		UnityEngine.LineRenderer.SetPosition(lineRenderer, index, pos)
	end

	self.Destroy = function(arrestPetObject)
		if arrestPetObject then
			ResourceManager.RecycleObject(arrestPetObject)
		end
	end
	
	return self
end


local CreateCatchPetCDCtrl = function()
	local self = CreateObject()
	local catchPetCDTimeInfo
	local catchPetTimeStamp
	local catchDiffTime = 0
	self.callback = nil

	local ShowCatchPetCDTick = function()
	
		local ret = true
		if self.callback then
		
			ret = self.callback(catchDiffTime)
		end
		
		if not ret then
		
			self.StopCatchPetCDTimer()
		end
		catchDiffTime = catchDiffTime + 0.01
	end
	
	self.StopCatchPetCDTimer = function()
	
		if catchPetCDTimeInfo then
		
			Timer.Remove(catchPetCDTimeInfo)
			catchPetCDTimeInfo = nil
		end
		catchPetTimeStamp = 0
	end
	
	self.StartCatchPetCDTimer = function(timeStamp)
	
		if not timeStamp or timeStamp <= 0 then
		
			return
		end
		
		local diffTime = 0 - networkMgr:GetConnection():GetSecondTimestamp()
		catchPetTimeStamp = timeStamp + math.ceil(diffTime)
		catchDiffTime = os.time() - catchPetTimeStamp

		if catchPetCDTimeInfo then
		
			Timer.Remove(catchPetCDTimeInfo)
		end
		catchPetCDTimeInfo = Timer.Repeat(0.01, ShowCatchPetCDTick)
	end
	
	return self
end

function CreateArrestPet()

	local self = CreateObject()
	local WildPet
	local hero
	local percentageValues = 0
	local currentState = ArrestPetState.Idle  --休闲状态
	local btPositoin
	local arrestPetEff
	local stampPos
	local stampObject
	local arrestEffectObject
	local arrestClickEffectObject
	local hero2wildPet
	local param_k = 0.1
	local start_time
	local addition_rate_total = 0
	local currentRadius = 0
	local maxRadius = 0
	local seal_ratio = 55
	local pursueTimer
	local playEffTimer
	local isCancelAutoCombat = false
	local arrestPetModel 	--宝印模型
	
	local SetAutoCombat = function(flag)
		if GlobalManager.isHook ~= flag then
			isCancelAutoCombat = not flag
			local hookCombat = require "Logic/OnHookCombat"
            hookCombat.SetHook(flag)
		end
	end
	
	function self.Init()
	
		self.catchPetCDCtrl = self.catchPetCDCtrl or CreateCatchPetCDCtrl()
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_START_CAPTURE_PET  , self.StartCapturePet)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_CAPTURE_RET, self.ProcessCapturePetRes)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PREPARE_CAPTURE_PET, self.PrepareCapturePetRes) --服务器反馈抓宠准备
	end
	
	self.PrepareCapturePetRes = function(data) --服务器反馈抓宠准备
		if data.result ~= 0 then
			return
		end
		
		currentState = ArrestPetState.Ready  --准备抓宠
		
		local hero = SceneManager.GetEntityManager().hero
		local wildPetTransform = WildPet.behavior.transform
		local heroTransform = hero.behavior.transform
		heroTransform:LookAt(wildPetTransform)   --英雄朝向需要抓的宠物
		WildPet.enabled = false
		
		UIManager.LoadView(ViewAssets.CatchPetUI)
		SetAutoCombat(false)
		
		local WildPetPosition = wildPetTransform.position
		local heroPositon = heroTransform.position
		
		hero:StopMoveImmediately()
		
		--if (Vector3.Magnitude(WildPetPosition - heroPositon) > 6) then 
			-- 英雄离宠物距离太远，往宠物方向移动
		
			--hero:Moveto(WildPetPosition)
			--pursueTimer = Timer.Repeat(0.1, self.ArrestPetReady, hero, WildPet)
			--return
		--end
		
		--self.ArrestPetReady(hero, WildPet)
		hero:Moveto(WildPetPosition)
		if (pursueTimer) then
		
			Timer.Remove(pursueTimer)
		end
		pursueTimer = Timer.Repeat(0.1, self.ArrestPetReady, hero, WildPet)
	end
	
	local function calc_rate(seal_ratio, radius, max_radius)  --计算概率
		local wildPetId = WildPet.data.WildPetId
		local base_rate = GrowingPet["Attribute"][wildPetId].SuccessRate + seal_ratio / 10
        local param_e = commonParameterFormula.Parameter[14].Parameter
		local total_rate = base_rate - param_e
		
        total_rate = math.floor(total_rate)
        total_rate = math.max(0, total_rate)

        radius = radius / max_radius * 100
        max_radius = 100

        local time_rate = math.min(param_e, base_rate)
        local delta_time = os.time() - start_time
		
        time_rate = time_rate * delta_time / 20
        time_rate = math.floor(time_rate)
		
        total_rate = total_rate + time_rate + math.max(addition_rate_total, 0)
		
		local formula_str = commonParameterFormula.Formula[2].Formula      --随机数的策划表公式
		local formula_str =  "return function (r, x) return "..formula_str.." end"
		local formula_addtition_func = loadstring(formula_str)()
        local addition_rate = math.floor(formula_addtition_func(max_radius, radius) * param_k * 100)

		UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRateProcess(total_rate / 100)
		
        return total_rate, addition_rate
	end
	
	local function OnCatchPet(state)
	
		--if (state == 1) then --成功
		

		--elseif (state == 2) then  --失败
		
			--self.SwitchSceneUI(ViewAssets.MainLandUI)
		--end
		
		UIManager.UnloadView(ViewAssets.CatchPetUI)
		UIManager.LoadView(ViewAssets.MainLandUI)
		currentState = ArrestPetState.Idle
		--self.SwitchSceneUI(ViewAssets.MainLandUI)
		self.Destroy()
	end

	local function OnFinishAction()
	
		local wildPetTransform = WildPet.behavior.transform
		local WildPetPosition = wildPetTransform.position
		local boxCollider = wildPetTransform:FindChild('Body'):GetComponent('BoxCollider')
		
		WildPetPosition.y = WildPetPosition.y + boxCollider.size.y / 2
		
		local wildtoStampHalf = (stampPos + WildPetPosition) * 0.5
		arrestPetModel.CreateModel("Common/eff_common@hunting_loop01", wildtoStampHalf,function(obj)
			arrestEffectObject = obj
			for i = 2, 6 do
				local lineRenderer = arrestEffectObject.transform:FindChild("0/line0" .. i):GetComponent("LineRenderer")
				arrestPetModel.SetLineRenderPosition(lineRenderer, 0, stampPos)
				arrestPetModel.SetLineRenderPosition(lineRenderer, 1, WildPetPosition)
			end
		end)
		
		--请求开始抓宠
		UIManager.GetCtrl(ViewAssets.CatchPetUI).OnCapturepet()
		
		local capturePetData = {} 
		capturePetData.pet_id = WildPet.data.WildPetId
		capturePetData.pet_uid = WildPet.uid
		capturePetData.pet_level = 1 			--宠物等级都为一级
		
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_START_CAPTURE_PET, capturePetData)
		currentState = ArrestPetState.Request  	--请求抓宠
	end

	function self.Start()
	
		if (not (currentState == ArrestPetState.Idle)) then   --当前不是休闲状态
		
			return
		end
		
		WildPet = TargetManager.GetCurrentTarget()
		if ((not WildPet) or (WildPet.entityType ~= EntityType.WildPet))  then-- 不是宠物
		
			return
		end
		
		local capturePetData = {}		--请求准备抓宠           
		capturePetData.pet_id = WildPet.data.WildPetId
		capturePetData.pet_uid = WildPet.uid
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PREPARE_CAPTURE_PET, capturePetData)
	end
	
	function self.ArrestPetReady(hero, wildPet)
		if not wildPet or not wildPet.behavior then
			self.SwitchSceneUI(ViewAssets.MainLandUI)
			self.Destroy()
			return
		end
		
		local wildPetTransform = wildPet.behavior.transform
		local heroTransform = hero.behavior.transform
		local WildPetPosition = wildPetTransform.position
		local heroPositon = heroTransform.position
		
		if (not hero) then
		
			return
		end
	
		if ((not WildPet) or (WildPet.entityType ~= EntityType.WildPet))  then-- 不是宠物
		
			return
		end
		
		if (Vector3.Magnitude(WildPetPosition - heroPositon) > 6) then 
			-- 英雄离宠物距离太远，往宠物方向移动
		
			return
		else
		
			hero:StopMoveImmediately()
			
			if (pursueTimer) then
		
				Timer.Remove(pursueTimer)
			end
		end
	
		if arrestPetModel == nil then
			arrestPetModel = CreateArrestPetModel()
		end
		
		arrestPetModel.CreateModel("Common/baoyin02@skin", Vector3.New(0, 0, 0),
									function(object)
										stampObject = object
										local toPosition = heroPositon 
										toPosition.y = toPosition.y + 3
										stampPos = toPosition 			   --暂定宝印的初始位置
		
										heroPositon = heroTransform.position   --恢复英雄的位置
										WildPetPosition = wildPetTransform.position-- 恢复宠物的位置
		
										local fromPosition = heroPositon
										fromPosition.y = fromPosition.y + 1

										local duration = 1
										if (btPositoin) then
		
											btPositoin:Clear()
										end
										btPositoin = BETween.position(stampObject, duration, fromPosition, toPosition)
										btPositoin.onFinish = OnFinishAction
									end)
									
		addition_rate_total = 0
		currentRadius = 0
		maxRadius = 0
		
		currentState = ArrestPetState.Ready  --准备抓宠
		start_time = os.time()
		calc_rate(seal_ratio, 0, 0)
	end
	
	
	
	function self.StartCapturePet(data)
	
		if (not (data.result == 0)) then
		
			ShowImgUI.ShowImage(false)
			self.SwitchSceneUI(ViewAssets.MainLandUI)
			self.Destroy()
			
			return
		end
		
		seal_ratio = data.info.seal_ratio 			--宝印抓宠概率
		UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRateProcess(data.rate / 100)
		--canCapturePet = true
		currentState = ArrestPetState.ArrestIn  --抓宠中
		if self.catchPetCDCtrl then
		
			self.catchPetCDCtrl.StartCatchPetCDTimer(data.info.last_capture_time)
		end
		
		if (self.timerInfo) then
			
			Timer.Remove(self.timerInfo)
		end
		self.timerInfo = Timer.Repeat(0.01, calc_rate, seal_ratio, currentRadius, maxRadius)
	end
	
	function self.GetCapturePetRes(radius, maxRadius)
	
		if (not(currentState == ArrestPetState.ArrestIn)) then --没有在抓宠状态
		
			return
		end
		
		local capPetData = {}
		if (not WildPet)then
		
			ShowTextUI.SetText("当前不能抓宠，请先点击抓宠按钮！")
			return
		end
		
		arrestPetModel = CreateArrestPetModel()
		
		capPetData.pet_id = WildPet.data.WildPetId;
		capPetData.radius = radius;
		capPetData.max_radius = maxRadius;
		
		currentRadius = radius
		maxRadius = maxRadius
		
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CAPTURE_RET, capPetData)
	end
	
	function self.ProcessCapturePetRes(data)
	
		local captureResult = data.capture_result
		
		if (not (data.result == 0)) then
		
			if (currentState ~= ArrestPetState.Idle) then
			
				UIManager.UnloadView(ViewAssets.CatchPetUI)
				self.SwitchSceneUI(ViewAssets.MainLandUI)
				currentState = ArrestPetState.Idle
				self.Destroy()
			end
			
			return
		end
		
		--capture_result: int, 0：成功，1：失败，可以继续，2：捕获次数用尽，3：时间用尽
		if (captureResult == 2 or captureResult == 3) then
		
			currentState = ArrestPetState.Idle
			
			local param = {}
			param.msg = "抓宠失败"
			param.okHandler = OnCatchPet
			param.okData = 2
			param.needHideClose = true
			--param.cancelHandler
			--param.cancelData
		
			UIManager.PushView(ViewAssets.ConfirmUI,function(ctrl) ctrl.Show(param) end)
			UIManager.GetCtrl(ViewAssets.CatchPetUI).OnPause()
			if (pursueTimer) then
		
				Timer.Remove(pursueTimer)
			end
			
			if (self.timerInfo) then
			
				Timer.Remove(self.timerInfo)
			end
			
			return
		elseif (captureResult == 1) then
		
			UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRateAddition(data.rate_addition)
			addition_rate_total = addition_rate_total + data.rate_addition
			
			self.StartPlayEff()    	--冷却时间
			UIManager.GetCtrl(ViewAssets.CatchPetUI).AddRadioEffStart()
		end
		
		if (captureResult == 0) then
			--self.DestroyWildPet()
			
			local petList = data.pet_info
			local onFightIndex = petList.on_fight_index
			if (onFightIndex) then
				-- self.CreatePet(petList, onFightIndex, onFightIndex)
				--ShowImgUI.ShowImage(true)
			else
			
				--ShowImgUI.ShowImage(true)
			end
			
			currentState = ArrestPetState.Idle
			
			local param = {}
			param.msg = "抓宠成功"
			param.okHandler = OnCatchPet
			param.okData = 1
			param.needHideClose = true
			param.icon = LuaUIUtil.GetPetIcon(petList.pet_id)
			--param.cancelHandler
			--param.cancelData
			UIManager.PushView(ViewAssets.ConfirmUI,
								function(op) 
									ctrl = op
									ctrl.Show(param)
								end)
			UIManager.GetCtrl(ViewAssets.CatchPetUI).OnPause()
			if (pursueTimer) then
		
				Timer.Remove(pursueTimer)
			end
			
			if (self.timerInfo) then
			
				Timer.Remove(self.timerInfo)
			end
		
			--self.Destroy()
		end
		
		UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRateProcess(data.rate / 100)
	end
	
	function self.CancelCapture()   --取消抓宠

		if ((currentState == ArrestPetState.ArrestIn) or (currentState == ArrestPetState.Ready) or (currentState == ArrestPetState.Request)) then
	
			MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CANCEL_CAPTURE)
			MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_CANCEL_CAPTURE, self.ProcessCancelCapture)
			--local top = UIManager.Top(Layer.base)
			--if top then
				--self.SwitchSceneUI(ViewAssets.MainLandUI)
				--self.Destroy()
			--end
		end
		currentState = ArrestPetState.Idle
	end
	
	function self.ProcessCancelCapture(data)
	
		if (not(data.result == 0)) then
			return
		end
		
		self.SwitchSceneUI(ViewAssets.MainLandUI)
		self.Destroy()
	end
	
	function self.CreatePet(petData, index, dir)
	
		-- hero.CreatePet(petData, index, dir)
	end
	
	function self.DestroyWildPet()
	
		if (WildPet) then
		
			WildPet.hp = 0
			SceneManager.GetEntityManager().DestroyPuppet(WildPet.uid)
			WildPet = nil
			
			-- UIManager.GetCtrl(ViewAssets.MainLandUI).petGroupUI.ShowEffect(false)
		end
	end
	
	function self.SwitchSceneUI(name)
	
		if (self.timerInfo) then
			
			Timer.Remove(self.timerInfo)
		end
		
		UIManager.LoadView(name)
		currentState = ArrestPetState.Idle
	end
	
	function self.StartPlayEff()
		if (not WildPet or not WildPet.behavior) then	--取消抓宠
			self.SwitchSceneUI(ViewAssets.MainLandUI)
			self.Destroy()
			return
		end
		
		if (playEffTimer) then
		
			Timer.Remove(playEffTimer)
		end
		
		currentState = ArrestPetState.Cooling
		UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRippleCapEff(false)
		playEffTimer = Timer.Numberal(0.5, 1, self.EndPlayEff)
		
		if (arrestClickEffectObject) then
			arrestPetModel.Destroy(arrestClickEffectObject)
			--ArrestPet.Destroy(arrestClickEffectObject)
			arrestClickEffectObject = nil
		end
		
		local wildPetTransform = WildPet.behavior.transform
		local WildPetPosition = wildPetTransform.position
		local boxCollider = wildPetTransform:FindChild('Body'):GetComponent('BoxCollider')
		
		WildPetPosition.y = WildPetPosition.y + boxCollider.size.y / 2
		
		local wildtoStampHalf = (stampPos + WildPetPosition) * 0.5
		arrestPetModel.CreateModel("Common/eff_common@hunting_click", wildtoStampHalf,
							function(obj) 
								arrestClickEffectObject = obj
								for i = 2, 3 do
									local lineRenderer = arrestClickEffectObject.transform:FindChild("0/line0" .. i):GetComponent("LineRenderer")
									arrestPetModel.SetLineRenderPosition(lineRenderer, 0, stampPos)
									arrestPetModel.SetLineRenderPosition(lineRenderer, 1, WildPetPosition)
								end
							end
							)
	end
	
	function self.EndPlayEff()
	
		if (playEffTimer) then
		
			Timer.Remove(playEffTimer)
		end
		
		if (currentState == ArrestPetState.Cooling) then
		
			currentState = ArrestPetState.ArrestIn
		end
		
		if (arrestClickEffectObject) then
			arrestPetModel.Destroy(arrestClickEffectObject)
			--ArrestPet.Destroy(arrestClickEffectObject)
			arrestClickEffectObject = nil
		end
		
		if (currentState ~= ArrestPetState.Idle) then
		
			UIManager.GetCtrl(ViewAssets.CatchPetUI).SetRippleCapEff(true)
		end
	end
	
	function self.Destroy()
		--if (WildPet) then
		
			--WildPet.stateManager:GotoState(StateType.ePatrol)
		--end
		if (self.timerInfo) then
			
			Timer.Remove(self.timerInfo)
		end
		
		if (btPositoin) then
		
			btPositoin:Clear()
		end
		
		if (pursueTimer) then
		
			Timer.Remove(pursueTimer)
		end
		
		if (playEffTimer) then
		
			Timer.Remove(playEffTimer)
		end
		
		if (stampObject) then
			arrestPetModel.Destroy(stampObject)
			--ArrestPet.Destroy(stampObject)
			stampObject = nil
		end
		
		if (arrestEffectObject) then
			arrestPetModel.Destroy(arrestEffectObject)
			--ArrestPet.Destroy(arrestEffectObject)
			arrestEffectObject = nil
		end
		
		--ArrestPet.Destroy(arrestPetObject)
		--arrestPetObject = nil
		currentState = ArrestPetState.Idle
		if isCancelAutoCombat then
			SetAutoCombat(true)
		end
		arrestPetModel = nil
	end
	
	self.Init()
	
	return self
end

ArrestPetInstance = ArrestPetInstance or CreateArrestPet()