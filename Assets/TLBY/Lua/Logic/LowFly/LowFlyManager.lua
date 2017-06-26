---------------------------------------------------
-- auth： zhangzeng
-- date： 2016/12/29
-- desc： 轻功管理
---------------------------------------------------
local confingTable = GetConfig("MotionEffects")

local DummyLocusState = {
	
	NotYet = 1,
	JumpStart = 2,
	JumpTurn  = 3,
	JumpEnd	= 4,
	HitCollider = 5,
	QuitFlyFall = 6,			--退出轻功，掉落时
	Climb = 7,                  --爬墙
}

CreateLowFlyManager = function(owner, scene)
	local self = CreateSceneObject(scene)
	local dummyLocusTick = 0
	local dummyNoPowLocusTick = 0
	local phase = 0
	local climbWallTick = 0
	local climbWallTimerInfo
	
	self.dummyLocusState = DummyLocusState.NotYet
	local dummyLocusTimerInfo
	local noPowLocusTimerInfo
	local preState = DummyLocusState.NotYet
	local preAnim
	local preMoveSpeed = 5.5
	local consFlyPowTimeInfo
	local consFlyPowDiff = 0.1
	local growFlyPowTimeInfo
	local growFlyPowDiff = 0.1
	local currentCD = 0
	local cdTimeinfo
	local isPressJoystick = false
	local dragDirection
	
	local cameParaA = commonFightBase.Parameter[54].Value /100
	local cameParaB = commonFightBase.Parameter[55].Value /100
	local cameParaM = commonFightBase.Parameter[56].Value / 1000
	local cameParaN = commonFightBase.Parameter[57].Value / 1000
	
	local dummyBehavior
	-- local navMeshAgent
	local cameraController
	local characterController
	--轻功值
	local flyPower = 1000
	local flyMaxPower = 1000 --轻功值上限
	--段间转向
	local isIntervalChangDir = false
	local isLowFly = false
	local isCancelAutoCombat = false
	
	local IsHero = function()
		local ret = true
		if owner == SceneManager.GetEntityManager().hero then
			ret = true
		else
			ret = false
		end
		
		return ret
	end
	
	local GetDummyEffects = function(dummy)
		local effects = nil
		if not dummy then
			return nil
		end
		
		local sex = dummy.data.sex
		local vocation = dummy.data.vocation
		local modelId = LuaUIUtil.GetHeroModelID(vocation, sex)
		if confingTable[modelId] == nil then return nil end
		
		return confingTable[modelId]
	end
	
	local GetFogEffectName = function(dummy)
		if not dummy then
			return nil
		end
		
		local vocation = dummy.data.vocation
		return 'eff_hero@0'.. vocation .. 'jump_wind2'
	end
	
	local GetRibbonEffectName = function(dummy)
		if not dummy then
			return nil
		end
		
		local vocation = dummy.data.vocation
		return 'eff_hero@0'.. vocation .. 'jump_line'
	end
	
	local SetLowFlyEffecActive = function(flag)
		if not owner or not owner.behavior then
			return
		end
	
		local ribbonEffectName = GetRibbonEffectName(owner)
		local sexFactor = owner.data.sex
		local factorPath = 'Body/male_clothes_01/'
		if sexFactor == 1 then
			factorPath = 'Body/male_clothes_01/'
		else
			factorPath = 'Body/female_clothes_01/'
		end
		local mainPath = factorPath .. 'Bip001/Bip001 Pelvis/Bip001 Spine/Bip001 Spine1/Bip001 Neck/'
		local leftPath = 'Bip001 L Clavicle/Bip001 L UpperArm/Bip001 L Forearm/Bip001 L Hand/'
		local effectLeftTransform = owner.behavior.transform:FindChild(mainPath .. leftPath .. ribbonEffectName)
		if effectLeftTransform then
			effectLeftTransform.gameObject:SetActive(flag)
		end
		
		local rightPath = 'Bip001 R Clavicle/Bip001 R UpperArm/Bip001 R Forearm/Bip001 R Hand/'
		local effectRightTransform = owner.behavior.transform:FindChild(mainPath .. rightPath .. ribbonEffectName)
		if effectRightTransform then
			effectRightTransform.gameObject:SetActive(flag)
		end
		
		if owner.data.vocation == 3 then --巫师特殊处理
			if sexFactor == 1 then
				mainPath = 'Body/male_clothes_01/Bip001/Bip001 Prop1/'
			else
				mainPath = 'Body/female_clothes_01/Bip001/Bip001 Prop1/'
			end
			
			local effectTransform = owner.behavior.transform:FindChild(mainPath .. ribbonEffectName)
			if effectTransform then
				effectTransform.gameObject:SetActive(flag)
			end
		end
		
		local fogEffectName = GetFogEffectName(owner)
		local fogTransform = owner.behavior.transform:FindChild('Body/middle/' .. fogEffectName)
		if fogTransform then
			fogTransform.gameObject:SetActive(flag)
		end
	end
	
	local FlyButtonGray = function(flag)
		if flag then
			isLowFly = false
		else
			isLowFly = true
		end
		UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI.FlyButtonGray(flag)
	end
	
	local SetAutoCombat = function(flag)
		if GlobalManager.isHook ~= flag then
			isCancelAutoCombat = not flag
			local hookCombat = require "Logic/OnHookCombat"
            hookCombat.SetHook(flag)
		end
	end
	
	self.StartLowFly = function(data)     --轻功启动向服务端发通知
		if IsHero() then
			SetAutoCombat(false)
			if not data then
				data = {}
			end
		
			data.func_name = 'on_fly_start'
			MessageManager.RequestLua(SceneManager.GetRPCMSGCode(), data)
		end
	end
	
	self.EndLowFly = function(data)		  --轻功结束向服务端发通知
		if IsHero() then
			if not data then
				data = {}
			end
		end
		
		data.func_name = 'on_fly_end'
		MessageManager.RequestLua(SceneManager.GetRPCMSGCode(), data)
	end
		
	local SetLowFlyData = function(data)
		if data.dir then
			eulerAngles = data.dir
		end
		--if data.isChangeDir then
			--isChangeDir = data.isChangeDir
		--end
		isChangeDir = true
		if data.phase then
			phase = data.phase
		end

		if data.do_func then
			if data.para then
				self[data.do_func](data.para[1], data.para[2])
			else
				self[data.do_func]()
			end
		end
	end
		
	local timeDelay
	self.OnFlyStart = function(data)
		if IsHero() then  --角色id为英雄
			return
		end

		if data.uid and data.uid == owner.uid then
			if timeDelay then
				Timer.Remove(timeDelay)
				timeDelay = nil
			end
			timeDelay = Timer.Delay(0, SetLowFlyData, data)
		end
	end
	
	self.OnFlyEnd = function(data)
		if not self.IsShowLocus() then
			SetLowFlyEffecActive(false)
		end
	end
	
	self.Init = function()
		local dummy = owner
		local dummyObject = owner.behavior
		dummyBehavior = dummyObject.transform:GetComponent("DummyBehavior")
		-- navMeshAgent = dummyObject.transform:GetComponent("NavMeshAgent")
		cameraController = CameraManager.CameraController
		characterController = dummyObject.transform:GetComponent("CharacterController")
		MessageRPCManager.AddUser(self, 'OnFlyStart')
		MessageRPCManager.AddUser(self, 'OnFlyEnd')
	end

	function self.IsShowLocus()
		local ret = false
		if (dummyLocusTimerInfo or noPowLocusTimerInfo) then
			ret = true 
		end
        owner:SetFly(ret)
		return ret
	end

	-------------------------------------------计算轻功转向 Start
	local calAngleTimerInfo
	local calAngleTick = 0
	local initEulerAngles = Vector3.New(0, 0, 0)
	local eulerAngles = Vector3.New(0, 0, 0)
	local CalcuLowFlyEulerAngles = function()
	
		local dummy = owner
		local dummyObject = dummy.behavior
		if not dummyObject or not dragDirection then
			return
		end
		
		local angle =  math.deg(math.atan2(dragDirection.x, dragDirection.z))
		if -180 <= angle and angle < 0 then
			--因为angle的范围是从-180到180;initEulerAngles.y范围从0到360
			angle = angle + 360
		end
		
		initEulerAngles = dummyObject.transform.eulerAngles
		if isIntervalChangDir == true then

			eulerAngles.x = initEulerAngles.x
			eulerAngles.y = angle
			eulerAngles.z = initEulerAngles.z
			isIntervalChangDir = false
			return
		end

		calAngleTick = calAngleTick + 0.01
		
		local totolDiff = 0
		local addDif = 0
		local baseValue = commonFightBase.Parameter[44].Value
		
		addDif = baseValue / 100
		totolDiff = angle - initEulerAngles.y
		if totolDiff > 180 then
			 angle = 360 - angle
			 totolDiff = angle - initEulerAngles.y
		elseif totolDiff < -180 then
			angle = 360 + angle
			totolDiff = angle - initEulerAngles.y
		end
		
		if totolDiff < 0 then
			if addDif > -totolDiff then
			
				addDif = totolDiff
			else
				addDif = -addDif
			end
		else
			if addDif > totolDiff then
				addDif = totolDiff
			end
		end
		eulerAngles.x = initEulerAngles.x
		eulerAngles.y = initEulerAngles.y + addDif
		eulerAngles.z = initEulerAngles.z
	end
	
	local isChangeDir = false
	local GetLowFlyEulerAngles = function()
		local angles 
		local dummy = owner
		local dummyObject = dummy.behavior
		if not isChangeDir then
			angles = dummyObject.transform.eulerAngles
		else
			angles = eulerAngles
		end
		
		if not IsHero() then
			angles = dummyObject.transform.eulerAngles
		end
		return angles
	end
	
	self.SetChangeDirState = function(state, dragDir)
		dragDirection = dragDir
		isChangeDir = state
		if state then
			if dragDir then
				isChangeDir = true
				calAngleTick = 0
				if not calAngleTimerInfo then
					calAngleTimerInfo = Timer.Repeat(0.01, CalcuLowFlyEulerAngles)
				end
			end
		else
			if calAngleTimerInfo then
				Timer.Remove(calAngleTimerInfo)
				calAngleTimerInfo = nil
				calAngleTick = 0
				dragDirection = nil
			end
		end
	end
	---------------------------------------计算轻功转向 End
	
	function self.DragJoystick(drag, controlDirection)
		local ret = self.IsShowLocus()
		if (drag) then
			dragDirection = controlDirection
		end
		
		local skill = owner.skillManager.skills[SlotIndex.Slot_Skill5]
        if skill then
			if (skill.cur_skill_stage == SkillStage.SKILL_CAST_START or
				skill.cur_skill_stage == SkillStage.SKILL_CAST_CHANNEL) then    --技能前摇和施法
			
				ret = true
			end
		end
		return ret
	end
	
	local function ShowNoPowFallLocus(fromPos, index)    --退出轻功时，自由掉落
		dummyNoPowLocusTick = dummyNoPowLocusTick + 0.01

		local dummy = owner
		if (dummy) then
			local t = dummyNoPowLocusTick
			local pos = Vector3.New(0, 0, 0)
			local dummyObject = dummy.behavior
			local eulerAngles = GetLowFlyEulerAngles()
			dummyObject.transform.eulerAngles = eulerAngles
			
			local dirQ = eulerAngles.y * math.pi / 180
			local upV = 0--commonFightBase.FlySkill[index].speed1 / 100	-- 向上初始速度
			local xozStartV = preMoveSpeed								--水平速度
			local g = commonFightBase.Parameter[35].Value / 100     	--重力加速度
			local dirPos = Vector3.New(0, 0, 0)   					  --实际移动的距离
			local s
			
			s = xozStartV * t
			pos.x = fromPos.x + s * math.sin(dirQ)
			pos.z = fromPos.z + s * math.cos(dirQ)
			pos.y = fromPos.y + upV * t - g * t * t / 2
			
			dirPos.x = xozStartV * math.sin(dirQ) * 0.01
			dirPos.z = xozStartV * math.cos(dirQ) * 0.01
			dirPos.y = (upV - g * t) * 0.01

			local distance = 20
			local isNavMesh = false
			local ret = false
			local hits = UnityEngine.Physics.RaycastAll(dummyObject.transform.position + dummyObject.transform.forward * 0.1, Vector3.New(0, -1, 0) * distance)
			for i = 0, hits.Length - 1 do
			
				local tag = hits[i].collider.gameObject.tag
				if (tag == "TerrainGeometry") then
						
					ret = true
					break
				end
			end
			
			isNavMesh = true
			if (not ret) then
				
				isNavMesh = false
			end
			
			if (not isNavMesh) then
			
				dirPos.x = 0
				dirPos.z = 0
				
				pos.x = dummyObject.transform.position.x
				pos.z = dummyObject.transform.position.z
			end
			
			--local groundHit = dummyBehavior:GetCollider()     --Collider Wall
			if (dummyBehavior and dummyBehavior:GetCollider().transform) then
				dirPos.x = 0
				dirPos.z = 0
				
				if (self.dummyLocusState ~= DummyLocusState.Climb) then
				
					preAnim = dummyObject:GetCurrentAnim()
					dummyObject:UpdateBehavior("climb")
					preState = self.dummyLocusState
					self.dummyLocusState = DummyLocusState.Climb
					
				end
				
				pos.x = dummyObject.transform.position.x
				pos.z = dummyObject.transform.position.z
			else 

				if (self.dummyLocusState == DummyLocusState.Climb) then
				
					self.dummyLocusState = preState
					dummyObject:UpdateBehavior(preAnim)
				end
			end
			
			dummyObject.transform:Translate(dirPos, UnityEngine.Space.World)   --按世界坐标移动
		end
	end
	
	local function EndNoPowFall()
	
		if (noPowLocusTimerInfo) then
		
			Timer.Remove(noPowLocusTimerInfo)
			dummyNoPowLocusTick = 0
		end
	end
	
	local function StartNoPowFall()
	
		local dummy = owner
		local dummyObject = dummy.behavior
		if (not dummy) then
		
			return
		end
		
		if (phase <= 1) then  --当前不是在空中
		
			return
		end
		
		if (not dummyLocusTimerInfo) then
		
			return
		end
		
		Timer.Remove(dummyLocusTimerInfo)
		
		EndNoPowFall()
		dummyNoPowLocusTick = 0
		self.dummyLocusState = DummyLocusState.QuitFlyFall
		noPowLocusTimerInfo = Timer.Repeat(0.01, ShowNoPowFallLocus, dummyObject.transform.position, phase - 1)
		dummyObject:UpdateBehavior("glide")
	end

	local function GetDummyFlyPower()	
		return flyPower
	end
	
	local ShowFlyPow = function()
	
		local maxFlyPower = commonFightBase.Parameter[31].Value
		local fillAmount = flyPower / maxFlyPower
		
		local mainLandUI = UIManager.GetCtrl(ViewAssets.MainLandUI)
		if mainLandUI and mainLandUI.isLoaded and mainLandUI.fightUI then
			mainLandUI.fightUI.ShowFlyPow(fillAmount)
		end
	end
	
	local function CDUpdate()
	
		currentCD = currentCD - 0.01
		if (currentCD <= 0) then
		
			currentCD = 0
			if (cdTimeinfo) then
			
				Timer.Remove(cdTimeinfo)
				cdTimeinfo = nil
			end
		end
	end
	
	local function EndGrowFlyPow()
	
		if (growFlyPowTimeInfo) then
		
			Timer.Remove(growFlyPowTimeInfo)
			growFlyPowTimeInfo = nil
		end
	end
	
	local function GrowFlyPow()
	
		local dummy = owner
		local growFlyPow = growFlyPowDiff * commonFightBase.Parameter[33].Value
		
		flyPower = flyPower + growFlyPow
		if (flyPower >= flyMaxPower) then
			flyPower = flyMaxPower
			EndGrowFlyPow()
		end
		
		ShowFlyPow()
	end
	
	
	local function StartGrowFlyPow()    
		EndGrowFlyPow()
		growFlyPowTimeInfo = Timer.Repeat(growFlyPowDiff, GrowFlyPow)
	end
	
	local function EndConsumeFlyPow()
	
		if (consFlyPowTimeInfo) then
		
			Timer.Remove(consFlyPowTimeInfo)
			consFlyPowTimeInfo = nil
		end
	end
	
	local function ConsumeFlyPow()
		local dummy = owner
		if not dummy then
			return
		end
		
		local dummyObject = dummy.behavior
		if not dummyObject then
			return
		end
		
		local consFlyPow = 0.1 * commonFightBase.Parameter[32].Value
		
		flyPower = flyPower - consFlyPow
		if (flyPower <= 0) then	--轻功耗尽，退出轻功
		
			if (preMoveSpeed ~= 0) then
			
				StartNoPowFall()
			end
			flyPower = 0
			phase = 0         --重置轻功阶段
			
			if (cdTimeinfo) then	--去掉轻功阶段cd
				currentCD = 0
				Timer.Remove(cdTimeinfo)
				cdTimeinfo = nil
			end
			
			dummyObject:SetRunAnimation("run")   			--相应得行走动作
			FlyButtonGray(true)
			
			StartGrowFlyPow()  --开始增长轻功
			EndConsumeFlyPow()
		end
		
		ShowFlyPow()
	end
	
	local function StartConsumeFlyPow()
		EndConsumeFlyPow()
		consFlyPowTimeInfo = Timer.Repeat(consFlyPowDiff, ConsumeFlyPow)
	end

	self.OnDestroy = function()
		EndGrowFlyPow()
		EndConsumeFlyPow()
		
		if (dummyLocusTimerInfo) then
			
			Timer.Remove(dummyLocusTimerInfo)
			dummyLocusTimerInfo = nil
			dummyLocusTick= 0
		end
			
		if (noPowLocusTimerInfo) then
			
			dummyNoPowLocusTick = 0
			Timer.Remove(noPowLocusTimerInfo)
			noPowLocusTimerInfo = nil
		end
	end
	
	self.CanceLocus = function()
		local dummy = owner
		if (not dummy) then
		
			return
		end
		
		local dummyObject = dummy.behavior
		if (dummyLocusTimerInfo or noPowLocusTimerInfo) then
		
			if (dummyLocusTimerInfo) then
			
				Timer.Remove(dummyLocusTimerInfo)
				dummyLocusTimerInfo = nil
				dummyLocusTick= 0
			end
			
			if (noPowLocusTimerInfo) then
			
				dummyNoPowLocusTick = 0
				Timer.Remove(noPowLocusTimerInfo)
				noPowLocusTimerInfo = nil
			end
			
			if IsHero() and isCancelAutoCombat then --重新自动战斗
				SetAutoCombat(true)
			end
					
			preState = self.dummyLocusState
			self.dummyLocusState = DummyLocusState.NotYet
			dummyObject:UpdateBehavior("fall")
			return
		end
	end
	
	local function ShowFlyLocus(fromPos, index)
	
		dummyLocusTick = dummyLocusTick + 0.01

		local dummy = owner
		local dummyObject = dummy.behavior
		if (dummy and  dummyObject) then
		
			local t = dummyLocusTick
			local pos = Vector3.New(0, 0, 0)
			local eulerAngles = GetLowFlyEulerAngles()--heroObject.transform.eulerAngles
			dummyObject:SetRotation(Quaternion.Euler(eulerAngles.x, eulerAngles.y, eulerAngles.z))
			dummyObject.transform.eulerAngles = eulerAngles
			local dirQ = eulerAngles.y * math.pi / 180
			local upV = commonFightBase.FlySkill[index].speed1 / 100	-- 向上初始速度
			local xozStartV = (commonFightBase.FlySkill[index].speed2 - 200) / 100	--水平速度
			local xozMinV = (commonFightBase.FlySkill[index].speed3 - 200) / 100	--水平最小速度
			local xozG = commonFightBase.FlySkill[index].speed4 / 100	--水平反向加速度
			local g = commonFightBase.FlySkill[index].Gspeed / 100     --重力加速度
			local xozV =  xozStartV -  xozG * t						  --水平实际速度
			local dirPos = Vector3.New(0, 0, 0)   					  --实际移动的距离
			local s

			if (xozV >= xozMinV) then
			
				s = xozStartV * t - xozG * t * t / 2
				
				dirPos.x = (xozStartV - xozG * t) * math.sin(dirQ) * 0.01
				dirPos.z = (xozStartV - xozG * t) * math.cos(dirQ) * 0.01
				dirPos.y = (upV - g * t) * 0.01
			else
			
				local turnT = (xozStartV - xozMinV) / xozG
				s = xozStartV * turnT - xozG * turnT * turnT / 2 + xozMinV * (t - turnT)
				
				dirPos.x = xozMinV * math.sin(dirQ) * 0.01
				dirPos.z = xozMinV * math.cos(dirQ) * 0.01
				dirPos.y = (upV - g * t) * 0.01
			end
			
			pos.x = fromPos.x + s * math.sin(dirQ)
			pos.z = fromPos.z + s * math.cos(dirQ)
			pos.y = fromPos.y + upV * t - g * t * t / 2
			
			local distance = 20
			local isNavMesh = false
			local ret = false
			local hits = UnityEngine.Physics.RaycastAll(dummyObject.transform.position + dummyObject.transform.forward * 0.1, Vector3.New(0, -1, 0) * distance)
			for i = 0, hits.Length - 1 do
			
				local tag = hits[i].collider.gameObject.tag
				if (tag == "TerrainGeometry") then
						
					ret = true
					break
				end
			end
			
			isNavMesh = true
			if (not ret) then
				
				isNavMesh = false
			end
			
			if (not isNavMesh) then
			
				dirPos.x = 0
				dirPos.z = 0
				
				pos.x = dummyObject.transform.position.x
				pos.z = dummyObject.transform.position.z
			end
			
			if dummyBehavior and dummyBehavior:GetCollider().transform then
				dirPos.x = 0
				dirPos.z = 0
				
				if (self.dummyLocusState ~= DummyLocusState.Climb) then
				
					--preAnim = dummyObject:GetCurrentAnim()
					--dummyObject:UpdateBehavior("climb")
					--preState = self.dummyLocusState
					--self.dummyLocusState = DummyLocusState.Climb
					
				end
				
				pos.x = dummyObject.transform.position.x
				pos.z = dummyObject.transform.position.z
			else

				if (self.dummyLocusState == DummyLocusState.Climb) then
				
					self.dummyLocusState = preState
					dummyObject:UpdateBehavior(preAnim)
				end
			end
            
			if (self.dummyLocusState == DummyLocusState.JumpStart and (dummyObject.behaviorLength <= dummyLocusTick)) then
			
				dummyObject:UpdateBehavior("glide")
			end
			
			local trunT = upV / g
			if (dummyLocusTick >= trunT and (self.dummyLocusState == DummyLocusState.JumpStart)) then
			
				preState = self.dummyLocusState
				self.dummyLocusState = DummyLocusState.JumpTurn
				
				if (dummyObject.behaviorLength <= dummyLocusTick) then
				
					dummyObject:UpdateBehavior("glide")
				end
			end
			
			if ((self.dummyLocusState == DummyLocusState.JumpTurn) and  (dummyObject.behaviorLength <= dummyLocusTick)) then
			
				local currentAnim = dummyObject:GetCurrentAnim()
				if (currentAnim ~= "glide") then
				
					dummyObject:UpdateBehavior("glide")
				end
			end
			
			dummyObject.transform:Translate(dirPos, UnityEngine.Space.World)   --按世界坐标移动
		end
	end
	
	local function StopBolted()
	
		local dummy = owner
		if not dummy:IsDied() then
		
			dummy.behavior:UpdateBehavior("NormalStandby")
		end
	end

	local ShowCastCameraEffect = function()
	
		local timerInfo
		local tick = 0
		local maxEffectPara = 2.2
		local blurryTime = commonFightBase.Parameter[60].Value / 1000   --轻功镜头模糊度回归时间
		
		local ShowCameraEffect = function()
		
			local dummy = owner
			if not dummy then
		
				if timerInfo then
				
					Timer.Remove(timerInfo)
					timerInfo = nil
				end
				return
			end
		
			tick = tick + 0.01
			local attenValue = 0
			local dummyObject = dummy.behavior
			if not dummyObject then
			
				if timerInfo then
				
					Timer.Remove(timerInfo)
					timerInfo = nil
				end
				return
			end
			
			if tick <= cameParaM then
			
				attenValue = 0
				
			elseif tick > cameParaM and  tick <= cameParaM + blurryTime then
			
				attenValue = maxEffectPara * (tick - cameParaM) / blurryTime
			elseif tick > cameParaM + blurryTime then
			
				if timerInfo then
				
					Timer.Remove(timerInfo)
					timerInfo = nil
				end

				dummyObject:CastCameraEffect('MotionBlurEffect', 0)
				return
			end
			
			dummyObject:CastCameraEffect('MotionBlurEffect', maxEffectPara - attenValue)
		end
		timerInfo = Timer.Repeat(0.01, ShowCameraEffect)
	end
	
	function self.ShowPhase(index)
		local dummy = owner
		local dummyObject = dummy.behavior
		if not dummyObject then
			return
		end
		
		local dummyPos = dummyObject.transform.position
		if (index > 1) then    --轨迹
			dummy.commandManager.Clear()
			dummy:StopMoveImmediately()  --stopmove要放在navMeshAgent失败前。
			-- if (navMeshAgent) then
			
			-- 	navMeshAgent.enabled = false
			-- end
			
			dummyLocusTick = 0
			
			if (dummyLocusTimerInfo) then
		
				Timer.Remove(dummyLocusTimerInfo)
				dummyLocusTimerInfo = nil
			end
			
			preState = self.dummyLocusState
			self.dummyLocusState = DummyLocusState.JumpStart
			dummyLocusTimerInfo = Timer.Repeat(0.01, ShowFlyLocus, dummyPos, index - 1) --时间进度条
			dummyObject:UpdateBehavior("jump" .. (index - 1))
			--owner.enabled = false
			
			if IsHero() then
				local eulerAngles = dummyObject.transform.eulerAngles			---轻功相机镜头
				cameraController:SetLowFlyPara(cameParaA, cameParaB, cameParaM, cameParaN, eulerAngles)
				ShowCastCameraEffect()
			end
		elseif (index == 1) then   --狂奔
			dummyObject:SetRunAnimation("sprint")
		end
	end
	
	function self.ColliderHit(hit)
		if hit and hit.gameObject then
			local object = hit.gameObject
			if (object.layer == math.pow(2, 15)) then    --碰到墙壁不进行处理
				return
			end
			
			if (object.layer == math.pow(2, 11)) then --碰到触发器，不进行处理
				return
			end
		end
		
		--if (self.dummyLocusState == DummyLocusState.JumpStart) then
		
			--return
		--end
		
		local dummy = owner
		if IsHero() then
			-- if (navMeshAgent) then
			-- 	navMeshAgent.enabled = true
			-- end
			
			if self.IsShowLocus() then
				dummy:SetPosition(dummy:GetPosition())
			end
		end
		
		--if self.IsShowLocus() then
			--local fogEffectName = GetFogEffectName(owner)
			--SetEffectActive(owner, fogEffectName, false)

			--SetEffectActive(owner, ribbonEffectName, false)
		--end
		if not isLowFly then
			SetLowFlyEffecActive(false)
		end
		
		self.CanceLocus()

        if not dummy or not dummy.behavior then return end
		local dummyObject = dummy.behavior
	
		if (cdTimeinfo) then
			currentCD = 0
			Timer.Remove(cdTimeinfo)
			cdTimeinfo = nil
		end
		
		if (phase > 1) then
			
			phase = 1
		end
		--owner.enabled = true
		if IsHero() then
			--dummyObject:RemoveEffect('Hero_eff_hero@01jump_wind3')  --消除剑客延时特效,特殊处理
			dummyObject:RemoveCameraEffect('MotionBlurEffect')
			cameraController.target_ = dummyObject.transform
			cameraController:SetSmoothSpeed(0.15)
		end
	end
	
	function self.JoystickOnDrag(event)
		return self.IsShowLocus()
	end
	
	self.OnFall = function()                  --飘落
		local ret = self.IsShowLocus()
		if (ret) then
		
			return
		end

		local data = {}
		data.do_func = 'OnFall'
		data.uid = owner.uid
		data.dir = Vector3.New(math.ceil(tonumber(eulerAngles.x)), math.ceil(tonumber(eulerAngles.y)), math.ceil(tonumber(eulerAngles.z)))
		self.StartLowFly(data)       			--发送执行OnFall
		
		local dummy = owner
		local dummyObject = dummy.behavior
		phase = 5
		self.ShowPhase(phase)
	end
	
	self.onFlyCast = function()
		if not owner:IsDied() then
			local dummyObject = owner.behavior
			if (phase == 5) then
				return
			end

			if (currentCD > 0) then
				return
			end

			if (GetDummyFlyPower() <= 0) then
				return
			end

			--if (phase == 0) then
				--if (not navMeshAgent.enabled) then   --当前角色不在地面，不能进行冲刺
				--phase = 1
				--return
				--end
			--end
			if dragDirection and isChangeDir and calAngleTimerInfo then
				CalcuLowFlyEulerAngles()
			end
				
			if IsHero() then
				local data = {}
				data.do_func = 'onFlyCast'
				data.uid = owner.uid
				data.phase = phase
				data.isChangeDir = true
				data.dir = Vector3.New(math.ceil(tonumber(eulerAngles.x)), math.ceil(tonumber(eulerAngles.y)), math.ceil(tonumber(eulerAngles.z)))
				self.StartLowFly(data)
			end
			
			SetLowFlyEffecActive(true)
	
			phase = phase + 1
			if (phase > 1) then
			
				if (phase == 2) then
					dragDirection = nil
				end
			
				if (dragDirection) then
					isIntervalChangDir = true
				end
			
				currentCD = commonFightBase.FlySkill[phase - 1].CD / 1000
				if (cdTimeinfo) then
					Timer.Remove(cdTimeinfo)
				end
				
				cdTimeinfo = Timer.Repeat(0.01, CDUpdate)
			--elseif (phase == 1) then
				
				--StartConsumeFlyPow()
				--EndGrowFlyPow(0)
			end
			
			StartConsumeFlyPow()
			EndGrowFlyPow(0)
			self.ShowPhase(phase)
		end
	end
	
	self.OnTeleport = function(skillId) 		--瞬移
		if not owner then
			return
		end
		
		owner:CastSkillToSky(skillId)
	end

	self.SetTeleport = function()     --瞬移
		local dummyObject = owner.behavior
		if (phase ~= 0) then
				
			StartGrowFlyPow()
			EndConsumeFlyPow()
				
			phase = 0         --重置轻功阶段
			dummyObject:SetRunAnimation("run")   			--相应得行走动作
			FlyButtonGray(true)			--按钮无效
			self.dummyLocusState = DummyLocusState.NotYet
		end
	end

	function self.JoystickOnPress(isPress, trigger)      --按或则松开虚拟摇杆
		if (trigger or isPress ~= isPressJoystick ) then --切换摇杆状态，trigger为true，就忽略idao状态是否不一样
			if (isPress) then     --按住摇杆
				--if (phase == 0) then
				
					FlyButtonGray(false)
					ShowFlyPow()
				--end
			else	 --松开摇杆
				local dummy = owner
				local dummyObject = dummy.behavior
				
				if (phase == 1) then
				
					dummyObject:UpdateBehavior("sprintend")
				end
				
				StartGrowFlyPow()
				EndConsumeFlyPow()
				
				if (cdTimeinfo) then	--去掉轻功阶段cd
					currentCD = 0
					Timer.Remove(cdTimeinfo)
					cdTimeinfo = nil
				end
						
				StartNoPowFall()
				--phase = 0         --重置轻功阶段
				dummyObject:SetRunAnimation("run")   			--相应得行走动作
				FlyButtonGray(true)			--按钮无效
			end
		end
		
		isPressJoystick = isPress
		return self.IsShowLocus()
	end
	
	self.Init()
	return self
end