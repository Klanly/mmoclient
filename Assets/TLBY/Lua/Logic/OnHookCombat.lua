---------------------------------------------------
-- auth： yanwei
-- date： 2017/2/7
-- desc： 挂机
---------------------------------------------------
require "Common/basic/LuaObject"
local const = require "Common/constant"

onHookCombat = function()
	 local self = CreateSceneObject()
	 local UpdateTimer = nil
     local timer = nil
	 local interval = 0.3
	 self.target = nil
	 self.pos = nil
	 self.Starthook = function()
		 GlobalManager.isHook = true
         TeamManager.CancelFollow()
         if not SceneManager.GetEntityManager().hero then return end
		 SceneManager.GetEntityManager().hero.stateManager:StartTick()
		 if SceneManager.IsOnDungeonScene() then
		   SceneManager.GetEntityManager().hero.stateManager:GotoState(StateType.eHookAttack)
		elseif SceneManager.currentSceneType == const.SCENE_TYPE.WILD then
		   SceneManager.GetEntityManager().hero.stateManager:GotoState(StateType.eWildHook)
		   self.pos = SceneManager.GetEntityManager().hero:GetPosition()
		elseif SceneManager.currentSceneType == const.SCENE_TYPE.ARENA then
		   SceneManager.GetEntityManager().hero.stateManager:GotoState(StateType.eArenaHook)
		   self.pos = SceneManager.GetEntityManager().hero:GetPosition()
		 end
    end
	
	 self.CancelHook = function()
		GlobalManager.isHook = false
        if not SceneManager.GetEntityManager().hero then return end
		SceneManager.GetEntityManager().hero.stateManager:StopTick()
		self.target = nil
		SceneManager.GetEntityManager().hero.target = nil
		SceneManager.GetEntityManager().hero.commandManager.Clear()
		SceneManager.GetEntityManager().hero:StopMoveImmediately()
		if UpdateTimer then
			Timer.Remove(UpdateTimer)
			UpdateTimer = nil
		end
    end
	
	 self.ManualCancelHook = function()
		SceneManager.GetEntityManager().hero.stateManager:StopTick()
		self.target = nil
		SceneManager.GetEntityManager().hero.target = nil
		UpdateTimer = Timer.Repeat(0.1, function() 
			if SceneManager.GetEntityManager().hero and SceneManager.GetEntityManager().hero:GetIdleTime() > 3 then
				if GlobalManager.isHook  == true then
				  SceneManager.GetEntityManager().hero.stateManager:StartTick()
				elseif UpdateTimer then
			       Timer.Remove(UpdateTimer)
			       UpdateTimer = nil 
		        end
			end
		end)
	  end
     
     self.SetHook = function(hook)
        if GlobalManager.isHook ~= hook then
            GlobalManager.isHook = hook
            if GlobalManager.isHook == false then
                self.CancelHook()
            else
                self.Starthook()
            end
            local ui = UIManager.GetCtrl(ViewAssets.MainLandUI)
            if ui.isLoaded then
                ui.OnHook()
            end
        end
     end
     
    return self
end

return onHookCombat()