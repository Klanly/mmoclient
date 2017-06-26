
function CreateNameBar(owner,behavior, offsetX, offsetY, nameColor, delay,scale)-- delay<0 不显示 delay=0 一直显示
    local self = CreateObject()
    local barGameObj = nil
    local loaded = false
    local barLuaTable = nil
    local timerInfo = nil
    local color = nameColor
    local nameScale = scale
    self.delay = delay
    
    local Init = function()
        if self.delay == 0 then
            self.ShowNameBar()
        end
    end
    
    local FormatNameStr = function()
        return string.format('<size=%d%%><color=#f97306>%s</color>\n<color=%s>%s</color>',nameScale or 100,owner.title or '',color,owner.name)
    end
    
    local HideBar = function()
        RecycleObject(barGameObj)
        barGameObj = nil
        timerInfo = nil
        loaded = false 
    end
    
    self.ShowNameBar = function()
        if self.delay < 0 then
            return
        end
        
        local ShowNameBar = function()
            barLuaTable.UpdateBar(behavior, offsetX, offsetY, FormatNameStr())
			if self.delay > 0 then
                if timerInfo then
                    Timer.Remove(timerInfo)
                end
                timerInfo = Timer.Delay(self.delay, HideBar)
            end
            if owner.entityType == EntityType.Dummy or owner.entityType == EntityType.Hero then
                self.UpdateTeamFlag(owner.uid)
            end
        end
        
        if not barGameObj  and not loaded then
            loaded = true
            ResourceManager.CreateUI( "HpBarUI/NameBarUI",0,30,function(obj)
                barGameObj = obj
                if not loaded then self.DestroyBar() return end
                barLuaTable = barGameObj:GetComponent("LuaBehaviour").luaTable
                ShowNameBar()
            end)
        elseif barLuaTable then
            ShowNameBar()
        end

    end
    
    self.UpdateName = function(nameColor)
        if color and nameColor then
            color = nameColor
        end
		
        if barGameObj then
            barLuaTable = barGameObj:GetComponent("LuaBehaviour").luaTable
            barLuaTable.UpdateBar(behavior, offsetX, offsetY, FormatNameStr())
        end
        --self.active = true
    end
    
    self.UpdateFollowingTarget = function()
        if not barGameObj then
            return
        end
        barLuaTable = barGameObj:GetComponent("LuaBehaviour").luaTable
        barLuaTable.UpdateBar(behavior, offsetX, offsetY, FormatNameStr())
    end
    
    self.UpdateTeamFlag = function(actor_id)
        if not barGameObj then return end
        if TeamManager.InTeam(actor_id) then 
            barLuaTable.ShowTeamFlag(TeamManager.IsCaptain(actor_id))
        else
            barLuaTable.HideTeamFlag()
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