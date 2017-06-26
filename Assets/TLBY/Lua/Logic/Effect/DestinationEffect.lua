require "Common/basic/LuaObject"


local CreateDestinationEffect = function()

    self = CreateObject()
    local effect = nil
    
    local SetEffect = function(p)
        local currentPosition = p
        if effect == nil then
            effect = true
            ResourceManager.CreateEffect("yidong/eff_common@yidong",function(obj)
                if effect then
                    effect = obj
                    effect.transform:SetParent(EntityBehaviorManager.ModelParent.transform, false)
                    effect.transform.position = Vector3.New(currentPosition.x, currentPosition.y+0.5, currentPosition.z)
                else
                    effect = obj
                    self.HideEffect()
                end

			end)
        elseif effect ~= true and effect ~=  false then
			effect.transform.position = Vector3.New(currentPosition.x, currentPosition.y+0.5, currentPosition.z)
        elseif effec == false then
            effect = true
		end
    end
    
    self.Moveto = function(p,stopDistance,onArrived)
        local hero = SceneManager.GetEntityManager().hero
        if not hero then
            return
        end
        if not hero.enabled then
            return
        end
        if hero.skillManager:IsLimitPlayerControl() then
            return 
        end
        if hero:CanMove() then
            hero:StopApproachTarget()
            hero:Moveto(p,stopDistance or 1,function() self.HideEffect() if onArrived then onArrived() end end)
            hero:OnControl('move')
            SetEffect(p)
        end
    end
    
    self.HideEffect = function()
        if effect and effect ~= true then
            RecycleObject(effect)
            effect = nil
        elseif effect == true then
            effect = false
        end
    end

    return self
end
DestinationEffect = DestinationEffect or CreateDestinationEffect()
return DestinationEffect