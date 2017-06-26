
--huasong--
require "Common/basic/LuaObject"

local function CreateJoystick( )
    local self = CreateObject()
    local MainLandUICtrl = UIManager.GetCtrl(ViewAssets.MainLandUI)
    
    self.drag = false
    self.controlDirection = Vector3.zero
    
    local radius = 0
    
    local SetJoyStickAlpha = function(alpha)
        local color = Color.New(1,1,1,alpha)
        self.noob.color = color
        self.bg.color = color
        -- self.doc.color = color
    end
    
    local Reset = function()
        self.drag = false
        self.noobRect.anchoredPosition = self.center
        SetJoyStickAlpha(0.4)
    end
        
    local StopHero = function()
        local hero = SceneManager.GetEntityManager().hero
        if hero == nil then
            return 
        end
        if SceneManager.GetEntityManager().hero:isMoving() then
            SceneManager.GetEntityManager().hero:StopMove()
        end
    end
    
    local MoveHero = function()
		local hero = SceneManager.GetEntityManager().hero
        if hero == nil then
            return 
        end
        if hero and hero.skillManager:IsLimitPlayerControl() then
            return 
        end
        if hero and hero.enabled then
			
			if hero.lowFlyManager then
		
				if hero.lowFlyManager.DragJoystick(self.drag, self.controlDirection) then
				
					return
				end
				
			end
			--if (UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI.DragJoystick(self.drag, self.controlDirection)) then	
				--return
			--end
			
            if self.drag and SceneManager.GetEntityManager().hero:CanMove() then
                SceneManager.GetEntityManager().hero:StopApproachTarget()
                SceneManager.GetEntityManager().hero:MoveDir(self.controlDirection)
                SceneManager.GetEntityManager().hero:OnControl('drag_move')
            else
                StopHero()
            end
        end
    end
    
    local OnDrag = function(event)
        self.drag = true
            local ret
        local position = CameraManager.GetUIPos(self.bg.gameObject.transform,event.position)
        if position.magnitude > radius then
            position = position:Normalize() * radius
        end
        self.noobRect.anchoredPosition = position + self.center 
        self.controlDirection = Vector3.New(-position.y,0,position.x):Normalize()
        SetJoyStickAlpha(1)
    end
    
    local OnEndDrag = function()
        Reset()
        StopHero()
    end
    
    local OnPress = function(event,press)
		local hero = SceneManager.GetEntityManager().hero
		if hero and hero.lowFlyManager then
		
			hero.lowFlyManager.JoystickOnPress(press)
			hero.lowFlyManager.SetChangeDirState(press, self.controlDirection)
		end
		
        if press then
            OnDrag(event)
        end
        
        if not press then
            Reset()
            StopHero()
        end
    end
    
    local keyboardPress = false
    local Update = function()
        if self.drag then
            MoveHero()
        end
        
        if not UnityEngine.Application.isMobilePlatform then
            local wHold = UnityEngine.Input.GetKey('w')
            local aHold = UnityEngine.Input.GetKey('a')
            local sHold = UnityEngine.Input.GetKey('s')
            local dHold = UnityEngine.Input.GetKey('d')
			local wUp = UnityEngine.Input.GetKeyUp('w')
			local aUp = UnityEngine.Input.GetKeyUp('a')
			local sUp = UnityEngine.Input.GetKeyUp('s')
			local dUp = UnityEngine.Input.GetKeyUp('d')
            local hideFightGroup = UnityEngine.Input.GetKeyUp('-')
            local cast1 = UnityEngine.Input.GetKeyUp('[')
            local cast2 = UnityEngine.Input.GetKeyUp(']')
            local cast3 = UnityEngine.Input.GetKeyUp(';')
            local cast4 = UnityEngine.Input.GetKeyUp('\'')
            local cast5 = UnityEngine.Input.GetKeyUp('.')
            local cast6 = UnityEngine.Input.GetKeyUp('/')
            local x=0
            local y=0
			
            if wHold then x = 10 end
            if aHold then y = -10 end
            if sHold then x = -10 end
            if dHold then y = 10 end
            
            if hideFightGroup then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).view.gameObject
                fightGroup:SetActive(not fightGroup.activeSelf)
            end
            
            if cast1 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onSkill1Cast()
            end
            if cast2 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onSkill2Cast()
            end
            if cast3 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onSkill3Cast()
            end
            if cast4 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onSkill4Cast()
            end
            if cast5 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onAttackButtonClick({})
            end
            if cast6 then
                local fightGroup = UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI
                fightGroup.onFlyCast()
            end
            
            if wHold or aHold or sHold or dHold then
                self.drag = true
                self.noobRect.anchoredPosition = Vector2.New(y,x) + self.center 
                self.controlDirection = Vector3.New(-x,0,y):Normalize()
				local hero = SceneManager.GetEntityManager().hero
				if hero and hero.lowFlyManager then
		
					hero.lowFlyManager.JoystickOnPress(true, true)
					hero.lowFlyManager.SetChangeDirState(true, self.controlDirection)
				end
				--UIManager.GetCtrl(ViewAssets.MainLandUI).fightUI.JoystickOnPress(true, true)
            elseif wUp or aUp or sUp or dUp then
				local hero = SceneManager.GetEntityManager().hero
				if hero and hero.lowFlyManager then
					hero.lowFlyManager.SetChangeDirState(false, nil)
				end
                Reset()
                StopHero()
            end
        end
    end
    
    self.center = Vector3.zero
    self.Start = function()
        self.noob = UIManager.GetCtrl(ViewAssets.MainLandUI).view.imgRockerFg:GetComponent("Image")
		self.bg = UIManager.GetCtrl(ViewAssets.MainLandUI).view.imgRockerBg:GetComponent("Image")
		self.noobRect = self.noob.gameObject:GetComponent("RectTransform") 
        self.center = self.noobRect.anchoredPosition
        radius = self.bg.gameObject:GetComponent("RectTransform").sizeDelta.x * 0.5
        DragEventListener.Get(UIManager.GetCtrl(ViewAssets.MainLandUI).view.pressArea).onDrag = OnDrag
        PressEventListener.Get(UIManager.GetCtrl(ViewAssets.MainLandUI).view.pressArea).onPress = OnPress
        Reset()
        UpdateBeat:Add(Update,self)
    end
    
    self.OnDestroy = function()
        UpdateBeat:Remove(Update,self)
    end
    
    

    return self
end
Joystick = Joystick or CreateJoystick()
return Joystick