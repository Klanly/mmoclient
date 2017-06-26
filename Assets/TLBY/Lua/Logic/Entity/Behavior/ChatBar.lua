
function CreateChatBar(behavior, offsetX, offsetY)
    local self = CreateObject()
    local barGameObj = nil
    local barLuaTable = nil
    local loaded = false
    local timerInfo = nil
    local talkList = {}

    self.UpdateChat = function()
        if table.isEmptyOrNil(talkList) then
            self.DestroyBar()
            return
        end 
        
        barLuaTable.UpdateBar(behavior, offsetX, offsetY, talkList[1].chat)  
        if timerInfo then 
            Timer.Remove(timerInfo)
        end
        timerInfo = Timer.Delay(talkList[1].delay,self.UpdateChat)
        table.remove(talkList,1)
    end
        
    self.PushChat = function(chat,delay)
        local chatData = {}
        chatData.chat = chat
        chatData.delay = delay or 2
        table.insert(talkList,chatData)

        if not barGameObj and not loaded then
            loaded = true
            ResourceManager.CreateUI( "HpBarUI/ChatBar",function(obj)
                barGameObj = obj
                if not loaded then self.DestroyBar() return end
                barLuaTable = barGameObj:GetComponent("LuaBehaviour").luaTable
                self.UpdateChat()
            end)
        elseif barGameObj and delay == nil then
            self.UpdateChat()
        end
    end
    
    self.UpdateFollowingTarget = function()
        if not barGameObj then
            return
        end
        barLuaTable = barGameObj:GetComponent("LuaBehaviour").luaTable
        barLuaTable.UpdateBar(behavior, offsetX, offsetY)
    end
    
    self.DestroyBar = function()
        if timerInfo then
            Timer.Remove(timerInfo)
        end
        RecycleObject(barGameObj)
        barGameObj = nil
        timerInfo = nil
        loaded = false
        talkList = {}
    end
    
    return self
end
