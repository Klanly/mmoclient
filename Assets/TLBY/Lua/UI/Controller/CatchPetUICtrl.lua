-----------------------------------------------------
-- auth： zhangzeng
-- date： 2016/10/11
-- desc： 宝印UI控制
-----------------------------------------------------
require "UI/Controller/LuaCtrlBase"

function CreateCatchPetUICtrl()

    local self = CreateCtrlBase()
	local controlData = {}
	local addition_rate_total
	local currentRateAdd
	local radioEffStart = 0
	local radioEffTimerInfo
	self.layer = LayerGroup.base
	
	local cirqueParticleSystem
	local cirqueParticleSystem2
	local starParticleSystem
	local textMany
	local haveTime = 5
	local view
    
	function self.onLoad()
		view = self.view
		ClickEventListener.Get(view.bgdisc).onClick = self.OnBgaperture
		cirqueParticleSystem = view.cirque01:GetComponent('ParticleSystem')
		cirqueParticleSystem2 = view.cirque02:GetComponent('ParticleSystem')
		starParticleSystem = view.star01:GetComponent('ParticleSystem')
		controlData.catchPetControlRadio = 1.3;
		textMany = view.textmany:GetComponent('TextMeshProUGUI')
		haveTime = 5
		textMany.text = '剩余次数：' .. haveTime
				
		--时间进度条参数
		controlData.totoalTime = 18
		controlData.calTime = 0
		controlData.texttimeprogressbarText = view.textcountdown:GetComponent('TextMeshProUGUI')
		controlData.texttimeprogressbarText.text = '倒计时:' .. controlData.totoalTime .. 's'

		--概率进度条参数
		controlData.successprogressbarImage = view.bgblueprogressbar:GetComponent('Image')
		controlData.successprogressbarImage.fillAmount = 0
		controlData.textsuccessprogressbarText = view.textcatchrate:GetComponent('TextMeshProUGUI')
		controlData.textsuccessprogressbarText.text = 0
	end
	
	local SetButtonAction = function(flag)
	
		local view = self.view
		local button = view.bgaperture:GetComponent('Button')
		button.enabled = flag
	end
	
	function self.OnPause()
		if (controlData.timeProcessTimeInfo) then
			Timer.Remove(controlData.timeProcessTimeInfo)
		end
		
		view.eff_UIzhuachong_cirque:SetActive(false)
		view.eff_UIzhuachong_star:SetActive(false)
	end

	-- 当view被卸载时事件
	function self.onUnload()
		if (controlData.timeProcessTimeInfo) then
			Timer.Remove(controlData.timeProcessTimeInfo)
		end
		
		view.eff_UIzhuachong_cirque:SetActive(false)
		view.eff_UIzhuachong_star:SetActive(false)
	end
	
	function self.OnCapturepet() --开始抓宠
	
		local view = self.view
		if (not view) then
		
			return
		end
		
		controlData.timeProcessTimeInfo = Timer.Repeat(0.1, self.SetTimeProcess) --时间进度条
		self.SetRippleCapEff(true)
	end
	
	local function ShowRateAdd()
	
		self.view.successrate:SetActive(true)
		self.view.textsuccessadd:SetActive(true)
		
		local text = controlData.textsuccessaddText
		if (text) then
		
			local rateAddText
			if (currentRateAdd > 0) then
			
				rateAddText = '+' .. currentRateAdd
			else
			
				rateAddText = currentRateAdd
			end
			
			text.text = rateAddText .. "%"
		end
		
		if (controlData.HideRateAddTimeInfo) then
		
			Timer.Remove(controlData.HideRateAddTimeInfo)
		end
		controlData.HideRateAddTimeInfo = Timer.Numberal(2, 1, self.HideRateAddition)
	end
	
	local function OnAddEffFinishAction()                 --特效结束处理
	
		if (radioEffTimerInfo) then
		
			Timer.Remove(radioEffTimerInfo)
			radioEffTimerInfo = nil
			radioEffStart = 0
		end
	
		if (growObject) then
		
			--ArrestPet.Destroy(growObject)
			growObject:SetActive(false)
			
			ShowRateAdd()
		end
	end
	--[[
	local function ShowAddRadioEff(pos, extrePos, toPos)           --处理特效轨迹
	
		if (growObject) then
		
			extrePos.x = (pos.x + toPos.x) * 0.5
			extrePos.y = pos.y - 20
			extrePos.z = pos.z
		
			local t = radioEffStart * 2
			local baerPos = Vector3.New(0, 0, pos.z)
			baerPos.x = ((1 - t) * (1 - t)) * pos.x + 2 * t * (1 - t) * extrePos.x + (t * t) * toPos.x
			baerPos.y = ((1 - t) * (1 - t)) * pos.y + 2 * t * (1 - t) * extrePos.y + (t * t) * toPos.y

			growObject.transform.position =  baerPos
		end
	
		radioEffStart = radioEffStart + 0.01
		if (radioEffStart >= 0.5) then
		
			OnAddEffFinishAction()
		end
		
	end
	]]
	function self.AddRadioEffStart()                --开始处理特效
	--[[
		growObject:SetActive(true)
		
		local pos = growObjectStartPos
		local toPos = self.view.successrate.transform.position
		local extrePos = Vector3.New(0, 0, pos.z)
		
		if (controlData.HideRateAddTimeInfo) then
		
			Timer.Remove(controlData.HideRateAddTimeInfo)
		end
		
		self.view.successrate:SetActive(false)
		self.view.textsuccessadd:SetActive(false)
		
		radioEffStart = 0
		if (radioEffTimerInfo) then
		
			Timer.Remove(radioEffTimerInfo)
			radioEffTimerInfo = nil
		end
		radioEffTimerInfo = Timer.Repeat(0.01, ShowAddRadioEff, pos, extrePos, toPos) --时间进度条
	]]
	end
	
	function self.SetRippleCapEff(flag)      --缩放的
		local view = self.view
		
		if flag then
			view.eff_UIzhuachong_cirque:SetActive(flag)
			cirqueParticleSystem:Play()
			view.eff_UIzhuachong_star:SetActive(false)
			cirqueParticleSystem2:Play()
		else
			cirqueParticleSystem:Pause()
			cirqueParticleSystem2:Pause()
			view.eff_UIzhuachong_star:SetActive(true)
		end
		
		--[[
		if (capRippleEff) then
			
			capRippleEff:Clear()
			capRippleEff = nil
		end
		
		if (flag) then
		
			local capturepetaperture = view.Capturepetaperture                 
			capturepetaperture:SetActive(true)
			capRippleEff = BETween.scale(capturepetaperture, 0.5, Vector3.one, Vector3.New(0.1, 0.1, 0.1))
			BETween.SetLoopStylee(capRippleEff, 3)
			SetButtonAction(true)
		end
		]]
	end

	function self.OnBgaperture()             --向服务端发送点击圆盘的区域
		local view = self.view
		if cirqueParticleSystem.isPaused then
			return
		end
		
		haveTime = haveTime - 1
		textMany.text = '剩余次数：' .. haveTime
		self.SetRippleCapEff(false)

		local diffTime = controlData.catchPetControlRadio - cirqueParticleSystem.time
		if diffTime < 0.01 then
			diffTime = 0.01
		end
		ArrestPetInstance.GetCapturePetRes(diffTime, controlData.catchPetControlRadio)
	end
	
	function self.SetRateProcess(rate)   -- 设置宠物总的抓取概率
		rate = rate * 100
		local p = rate * 2 - 0.01 * math.pow(rate, 2)
		local image = controlData.successprogressbarImage
		if (image) then
			image.fillAmount = p / 100
		end
		
		local text = controlData.textsuccessprogressbarText
		if (text) then
			text.text = '成功率:' .. math.floor(p) .. "%"
		end
	end
	
	function self.SetTimeProcess()     --时间进度条
		controlData.calTime = controlData.calTime + 0.1
		local text = controlData.texttimeprogressbarText
		if (text) then
			text.text = '倒计时:' .. (controlData.totoalTime - math.floor(controlData.calTime)) .. 's'
		end
		
		local image = controlData.timeprogressbarImage
        if (image) then
  
            image.fillAmount = controlData.calTime / controlData.totoalTime;
        end

        if (controlData.calTime >= controlData.totoalTime) then
   
            Timer.Remove(controlData.timeProcessTimeInfo)
        end
	end
	
	function self.SetRateAddition(rateAdd)       --一次抓宠的增加值
	
		currentRateAdd = rateAdd
	end
	
	function self.HideRateAddition(rateAdd)     --隐藏抓宠成功率字体显示
	
		if (not self.view) then
		
			return
		end
		
		self.view.successrate:SetActive(false)
		self.view.textsuccessadd:SetActive(false)
	end
	
	function self.DestoyArrestPet()
	
		ArrestPetInstance.Destroy()
	
	end
	
    return self
	
end

return CreateCatchPetUICtrl()