-- huasong--

local function CreateTouchMove()
    local self = CreateObject()
    local wait = 11
    local joystick = nil
    local waitFrame = 10
    local moveToNPC = nil
    local DestinationEffect = require "Logic/Effect/DestinationEffect"
    
    local CBMoveToNPC = function(npc)
        if npc and npc.behavior.InterAct then
            npc.behavior:InterAct()
        end
        moveToNPC = nil
    end
    
    local GetTerrainPos = function(dest)
        local mCamera = UnityEngine.Camera.main
        if not mCamera then
            return Vector3.zero
        end
        
        local ray = mCamera:ScreenPointToRay(dest)
        local hits = UnityEngine.Physics.RaycastAll(ray)
        local puppets = {}
        for i = 0, hits.Length - 1 do
            local pbTf = hits[i].collider.transform.parent   
            if pbTf then
                local pb = pbTf:GetComponent("PuppetBehavior")
                if pb and pb.uid ~= SceneManager.GetEntityManager().hero.data.entity_id then
                    table.insert(puppets,pb.uid)
                end
            end
        end
        if #puppets > 1 then
                UIManager.PushView(ViewAssets.SelectTargetUI,nil,puppets,CBMoveToNPC)
                moveToNPC = nil
                return Vector3.zero
        elseif #puppets == 1 then
                moveToNPC = nil
                local target = SceneManager.GetEntityManager().GetPuppet(puppets[1])
                TargetManager.SetTarget(target)
                if target~= nil and 
				   (target.entityType == EntityType.NPC or
   				    target.entityType ==  EntityType.MonsterCamp) then
                    moveToNPC = target
                    return target.behavior.transform.position
                end
                return Vector3.zero
        end
        for i = 0, hits.Length - 1 do
            if 'TerrainGeometry' == hits[i].collider.gameObject.tag then
                moveToNPC = nil
                return hits[i].point
            end
        end
        return Vector3.zero
    end

    self.Start = function()
        joystick = UIManager.GetCtrl(ViewAssets.MainLandUI).view.Rocker:GetComponent("LuaBehaviour").luaTable
        UpdateBeat:Add(self.Update, self)
    end

    self.OnDestroy = function ()
        UpdateBeat:Remove(self.Update, self)
        effect = nil
    end

    self.Update = function()
        local hero = SceneManager.GetEntityManager().hero
        if not hero then
            return
        end
        if not hero.enabled then
            return
        end
        
        local effectOp = false
        if UnityEngine.Application.isMobilePlatform then
            effectOp = not joystick.drag and UnityEngine.Input.touchCount == 1 and 
            UnityEngine.Input.GetTouch(0).phase ~= TouchPhase.Ended and UnityEngine.Input.GetTouch(0).phase ~= TouchPhase.Canceled and
            not UnityEngine.EventSystems.EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId)
        else 
            effectOp = not joystick.drag and UnityEngine.Input.GetMouseButton(0) and not UnityEngine.EventSystems.EventSystem.current:IsPointerOverGameObject()
        end
        if  effectOp then
            if hero.skillManager:IsLimitPlayerControl() then
                return 
            end
            wait = wait + 1
            if (wait > waitFrame) then
                local TerrainPt = GetTerrainPos(UnityEngine.Input.mousePosition)
                if TerrainPt ~= Vector3.zero and hero:CanMove() then
                    local stopDistance = 0.2
                    if moveToNPC then 
                        DestinationEffect.Moveto(TerrainPt,3,function() CBMoveToNPC(moveToNPC) end)
                    else
                        DestinationEffect.Moveto(TerrainPt,1)
                    end
                    
					wait = 0
                end
            end        
        else
            wait = waitFrame
        end


    end

    return self
end
TouchMove = TouchMove or CreateTouchMove()
return TouchMove
