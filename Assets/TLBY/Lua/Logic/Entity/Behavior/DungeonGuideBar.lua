
function CreateDungeonGuideBar(owner)-- delay<0 不显示 delay=0 一直显示
    local self = CreateObject()
    local DungeonGuideGameObj = nil
    local behaviour = nil
    self.active = false
    timerInfo = nil
	delay = 3
	
    local Init = function()
         self.DungeonGuideBar()
    end
    
    self.DungeonGuideBar = function()
        if not DungeonGuideGameObj then
            ResourceManager.CreateModel( "Common/DungeonGuide",function(obj) 
				DungeonGuideGameObj = obj
				behaviour = DungeonGuideGameObj:GetComponent("LuaBehaviour").luaTable
               --behaviour.UpdatePos(owner)
				self.active = true
				 if delay > 0 then
					if timerInfo then
						Timer.Remove(timerInfo)
					end
					timerInfo = Timer.Delay(delay,function() behaviour.UpdatePos(owner) end)
				end
			end)  
        end
        
    end
	
    self.Hide = function()
        RecycleObject(DungeonGuideGameObj)
        DungeonGuideGameObj = nil
        timerInfo = nil
    end
    
    self.DestroyBar = function()
        if timerInfo then
            Timer.Remove(timerInfo)
        end
        self.Hide()
    end
    
    Init()

    return self
end