---------------------------------------------------
-- auth： zhangzeng
-- date： 2017/1/22
-- desc： 掉落拾取特效
---------------------------------------------------

function CreateDropPickedEffect(data)
	local self = CreateObject()
	local dropEffect
	local effectLocusTimeInfo
	local locusTick = 0
	local locusMaxTick = 1
	local frontMaxTick = 0.5
	local tailMaxTick = 0.5
	local minDistance = 1  --掉落特效出现的最短距离
	local maxDistance = 15 --掉落特效出现的最远距离
	local locuseState = 0  --轨迹分为两段，为1在前半段，为2在后半段
	local startPoint = {}
	local middlePoint = {}
	local endPoint = {}
	local heroPos
	
	local ShowBesselLocuse = function(sPoint, mPoint, ePoint, t)
	
		local baerPos = {}
		
		baerPos.x = ((1 - t) * (1 - t)) * sPoint.x + 2 * t * (1 - t) * mPoint.x + (t * t) * ePoint.x
		baerPos.y = ((1 - t) * (1 - t)) * sPoint.y + 2 * t * (1 - t) * mPoint.y + (t * t) * ePoint.y
		baerPos.z = ((1 - t) * (1 - t)) * sPoint.z + 2 * t * (1 - t) * mPoint.z + (t * t) * ePoint.z

		return baerPos
	end
	
	local CalcuFrontLocuse = function()
	
		--local hero = SceneManager.GetEntityManager().hero		
		--local heroPos = hero:GetPosition()
		--heroPos.y = heroPos.y + 1
		
		startPoint = dropEffect.transform.position 
		local point = Vector2.New()
		point.x = heroPos.x - startPoint.x
		point.y = heroPos.z - startPoint.z

		endPoint.x = startPoint.x + point.x * 0.3
		endPoint.y = heroPos.y + 1
		endPoint.z = startPoint.z + point.y * 0.3
		
		middlePoint.x = (startPoint.x + endPoint.x) / 2
		middlePoint.z = (startPoint.z + endPoint.z) / 2
		middlePoint.y = endPoint.y + 3
	end
	
	local CalcuTailLocuse = function()
	
		--local hero = SceneManager.GetEntityManager().hero
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
		
			return
		end
		
		heroPos = hero:GetPosition()		
		endPoint.x = heroPos.x
		endPoint.y = heroPos.y
		endPoint.z = heroPos.z
		endPoint.y = endPoint.y + 1
		
		startPoint = dropEffect.transform.position
		
		middlePoint.x = (startPoint.x + endPoint.x) / 2
		middlePoint.z = (startPoint.z + endPoint.z) / 2
		middlePoint.y = endPoint.y - 1
	end
	
	local IsCancelLocuse = function()
	
		local ret = false
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
		
			return true
		end
		
		local pos = dropEffect.transform.position                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
		local heroPos = hero:GetPosition()
		heroPos.y = heroPos.y + 1
		local heroLPos = heroPos
		heroLPos.z = heroLPos.z - 0.5
		local heroRPos = heroPos
		heroRPos.z = heroRPos.z + 0.5
		
		local distanceL = Vector3.Distance2D(pos, heroLPos)
		local distanceR = Vector3.Distance2D(pos, heroRPos)
		if distanceL > distanceR then
		
			data.tarPos = heroRPos
		else
		
			data.tarPos = heroLPos
		end
		
		local endDistance = Vector3.Distance2D(pos, data.tarPos)
		if locuseState == 3 and endDistance <= 1 then 	--特效已经飞到英雄身上
		
			return true
		end
		
		if endDistance <= 0.5 then 	--特效已经飞到英雄身上
		
			--self.OnDestroy()
			return true
		end

		return ret
	end
	
	local ShowLocuse = function()
	
		local hero = SceneManager.GetEntityManager().hero
		if IsCancelLocuse() then
		
			self.OnDestroy()
			return
		end
		
		local maxTick = frontMaxTick
		locusTick = locusTick + 0.01
		if locuseState == 0 then
		
			CalcuFrontLocuse()
			locuseState = 1
			locusTick = 0
			maxTick = frontMaxTick
		elseif locuseState == 1 and locusTick > frontMaxTick then
		
			CalcuTailLocuse()
			locuseState = 2
			locusTick = 0
			maxTick = tailMaxTick
		elseif locuseState == 2 then
			
			--CalcuTailLocuse()
			if locusTick > tailMaxTick then
			
				locusTick = tailMaxTick
				locuseState = 3
				--CalcuTailLocuse()
				--return
			end
			maxTick = tailMaxTick
		elseif locuseState == 3 then
		
			CalcuTailLocuse()
			locusTick = maxTick / 2
			maxTick = tailMaxTick
		end
		
		local t = locusTick / maxTick
		dropEffect.transform.position = ShowBesselLocuse(startPoint, middlePoint, endPoint, t)
		
		--[[
		local pos = dropEffect.transform.position                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
		local heroPos = hero:GetPosition()
		heroPos.y = heroPos.y + 1
		local heroLPos = heroPos
		heroLPos.z = heroLPos.z - 0.5
		local heroRPos = heroPos
		heroRPos.z = heroRPos.z + 0.5
		
		local distanceL = Vector3.Distance2D(pos, heroLPos)
		local distanceR = Vector3.Distance2D(pos, heroRPos)
		if distanceL > distanceR then
		
			data.tarPos = heroRPos
		else
		
			data.tarPos = heroLPos
		end
		
		local endDistance = Vector3.Distance2D(pos, data.tarPos)
		if endDistance <= 0.1 then 	--特效已经飞到英雄身上
		
			self.OnDestroy()
			return
		end

		locusTick = locusTick + 0.01
		if locusTick > locusMaxTick then
		
			locusTick = 0
		end
		
		local t = locusTick / locusMaxTick
		local baerPos = {}
		local extrePos = {}
		extrePos.x = (pos.x + data.tarPos.x) / 2
		extrePos.y = data.tarPos.y + 3
		extrePos.z = (pos.z + data.tarPos.z) / 2
		
		baerPos.x = ((1 - t) * (1 - t)) * pos.x + 2 * t * (1 - t) * extrePos.x + (t * t) * data.tarPos.x
		baerPos.y = ((1 - t) * (1 - t)) * pos.y + 2 * t * (1 - t) * extrePos.y + (t * t) * data.tarPos.y
		baerPos.z = ((1 - t) * (1 - t)) * pos.z + 2 * t * (1 - t) * extrePos.z + (t * t) * data.tarPos.z
		dropEffect.transform.position = baerPos
		]]
	end
	
	local UpdataHerPos = function()
	
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
		
			self.OnDestroy()
			return
		end
		
		heroPos = hero:GetPosition()
	end

	local Start = function()
	
		local distance = Vector3.Distance2D(data.pos, data.tarPos)
		if distance < minDistance or distance > maxDistance then  --不在掉落特效出现的距离
		
			return
		end
		print('distance = ', distance)
		
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
		
			return
		end
		
		--locuseState = 1
		 ResourceManager.CreateEffect('Common/eff_common@pickup',function(obj)
			dropEffect = obj
			dropEffect.transform.position = data.pos
		    effectLocusTimeInfo = Timer.Repeat(0.01, ShowLocuse)   
		end)
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		heroPos = hero:GetPosition()
		--updataHeroPosTimeInfo = Timer.Repeat(0.3, UpdataHerPos)	
	end
	
	self.OnDestroy = function()
	
		if dropEffect then
		
			RecycleObject(dropEffect)
			dropEffect = nil
		end
		
		Timer.Remove(effectLocusTimeInfo)
		effectLocusTimeInfo = nil
		Timer.Remove(updataHeroPosTimeInfo)
		updataHeroPosTimeInfo = nil
		locuseState = 0
		locusTick = 0
	end

	Start()
	return self
end
