---------------------------------------------------
-- auth： songhua
---------------------------------------------------

require "Common/basic/LuaObject"
CreateTabGroup = function()
    local self = CreateObject()
    local StateChange = nil
    
    self.currentTabIndex = 0
    
    self.Init = function(,OnStateChange)
    
        StateChange = OnStateChange()
    end
    
    self.SelectTab(index)
        if StateChange then
            StateChange(currentTabIndex,false)
        end
        currentTabIndex = index
        if StateChange then
            StateChange(currentTabIndex,true)
        end
    end
    
    
    return self
end