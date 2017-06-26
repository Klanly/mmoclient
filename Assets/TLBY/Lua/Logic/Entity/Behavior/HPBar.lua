--huasong--
function CreateHPBar(owner,behavior, offsetX, offsetY, barType, delay) -- delay<0 不显示 delay=0 一直显示 
	local self = CreateObject()

    local hpGameObj = nil
    local timerInfo = nil
    local barLuaTable = nil
    local loaded = false
    self.delay = delay
    local barTypes = 
    {
        'HpBarUI/SmallHpBarUI',--怪物
        'HpBarUI/SmallHpBarUI',--宠物
        'HpBarUI/NormalHpBarUI',--敌对玩家
        'HpBarUI/NormalHpBarUI',--己方玩家
        'HpBarUI/NormalHpBarUI',--boss
        'HpBarUI/NormalHpBarUI',--自己
    }
    
    local Init = function()
        if self.delay == 0 then
            self.ShowHpBar()
        end
    end
    
    local HideBar = function()
        RecycleObject(hpGameObj)
        hpGameObj = nil
        timerInfo = nil
        loaded = false
    end

    self.UpdateFollowingTarget = function()
        if not hpGameObj then
            return
        end
        local progress = 0
        if owner.hp and owner.hp_max() then progress = owner.hp/owner.hp_max() end
        barLuaTable = hpGameObj:GetComponent("LuaBehaviour").luaTable
        barLuaTable.UpdateBar(behavior, offsetX, offsetY, barType, progress, owner.data.vocation)
    end
    
	self.ShowHpBar = function()
        if self.delay < 0 then
            return
        end
        
        local ShowHpBar = function()
            hpGameObj:SetActive(self.delay >= 0)
            self.UpdateFollowingTarget()
            if self.delay > 0 then
                if timerInfo then
                    Timer.Remove(timerInfo)
                end
                timerInfo = Timer.Delay(self.delay, HideBar)
            end
        end
        
        if not hpGameObj and not loaded then
            loaded = true
            ResourceManager.CreateUI( barTypes[barType],0,30,function(obj)
                hpGameObj = obj
                if not loaded then self.DestroyBar() return end
                ShowHpBar()
			end)
        elseif hpGameObj then
            ShowHpBar()
        end
    end

    self.DestroyBar = function()
        if timerInfo then
            Timer.Remove(timerInfo)
        end
        HideBar()
    end
    
    Init()
    return self
end