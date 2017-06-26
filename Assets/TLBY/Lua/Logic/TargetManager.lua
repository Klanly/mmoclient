-- huasong --
require "Common/basic/LuaObject"
require "Common/basic/Bit"

local function CreateTargetManager()
    local self = CreateObject()
    local currentTarget
    local targetFlag
	
    --self.TargetUnits = {}
	--self.TargetUnitKeys = {}
    self.fightRadius = GetConfig("common_fight_base").Parameter[17].Value
    self.removeRadius = GetConfig("common_fight_base").Parameter[18].Value
    
    local AddTargetFlag = function()
        if currentTarget and currentTarget.behavior then
		    local scale = Vector3.one
            local boxCollider = Util.GetComponentInChildren(currentTarget.behavior.gameObject,'BoxCollider')
            if boxCollider then
                scale = boxCollider.transform.localScale*math.min(boxCollider.size.z,boxCollider.size.x)
            end
            if targetFlag == nil then
                targetFlag = true
                ResourceManager.CreateEffect( "Common/eff_common@suoding",function(obj)              
					if currentTarget  and targetFlag then
                       targetFlag =  obj
					   targetFlag.transform.parent = currentTarget.behavior.transform
                       targetFlag.transform.localPosition = Vector3.zero
					   targetFlag.transform.localScale = scale
                    else
                        targetFlag =  obj
                        self.ClearTarget()
					end

				end)
			elseif targetFlag ~= true and targetFlag ~=  false then
               targetFlag.transform.parent = currentTarget.behavior.transform
               targetFlag.transform.localPosition = Vector3.zero
			   targetFlag.transform.localScale = scale
            elseif targetFlag == false then
                targetFlag = true
			end          
        end
    end
    
    local selectNearbyMonster = function(puppet)
		if puppet.entityType == EntityType.Monster and not puppet:IsDied() and puppet ~= currentTarget then
			puppet.ApproachDistance = Vector3.Distance2D(SceneManager.GetEntityManager().hero:GetPosition(), puppet:GetPosition()) 
			if puppet.ApproachDistance < self.fightRadius   then         
			  return true 
			end        
		end
		return false
	end
    self.CanAttack = function(puppet)
        if not puppet or not puppet.entityType then
            return false
        end

        if puppet.entityType == EntityType.Hero then
            return false
        end
        if puppet.entityType == EntityType.Dummy then
            return self.DummyAttackable(puppet)
        elseif puppet.entityType == EntityType.Pet then
            return self.DummyAttackable(puppet.owner)
        end
        local hero = SceneManager.GetEntityManager().hero
        if not hero or hero:IsDied() or hero:IsDestroy() then
            return false
        end
        return hero:IsEnemy(puppet)
    end

    self.CanHelp = function(puppet)
        if not puppet or not puppet.entityType then
            return false
        end

        if puppet.entityType == EntityType.Dummy then
            return (self.DummyAttackable(puppet) == false)
        elseif puppet.entityType == EntityType.Pet then
            return (self.DummyAttackable(puppet.owner) == false)
        end
        local hero = SceneManager.GetEntityManager().hero
        if not hero or hero:IsDied() or hero:IsDestroy() then
            return false
        end
        return hero:IsAlly(puppet)
    end
    
    self.DummyAttackable = function(dummy)
        if dummy.entityType ~= EntityType.Dummy then
            return false
        end
        if dummy:IsDied() then
            return false
        end
        if ArenaManager.IsOnFighting() then
            return true
        end
        if dummy.level < 30 then
            return false
        end
        if TeamManager.InTeam(dummy.uid) then
            return false
        end
        if dummy.data.country ~= MyHeroManager.heroData.country then
            return true
        end
        
        local pkData = PKManager.getPkData(dummy.uid)
        if pkData and pkData.isAttackHero then return true end
        
        local heroPkData = PKManager.getPkData(MyHeroManager.heroData.entity_id)
        if heroPkData then
            local heroMode = heroPkData.forceMode
            if heroMode == 'manual' then heroMode = heroPkData.pkMode end  
            if heroMode == PKMode.Killed then return true end
            if pkData then
                if heroMode == PKMode.GoodEvil and pkData.pkColor == PKColor.Red then return true end
            end
        end
        return false
    end
    
    local selectCloestPlayer = function(puppet)
		if puppet ~= currentTarget and self.DummyAttackable(puppet) and
        Vector3.InDistance(SceneManager.GetEntityManager().hero:GetPosition(), puppet:GetPosition(), self.fightRadius) then
			return true
		end
		return false
	end
	
    local HookSelectMonster = function(puppet)
		if puppet.entityType == EntityType.Monster and (not puppet:IsDied()) then
			puppet.ApproachDistance = Vector3.Distance2D(SceneManager.GetEntityManager().hero:GetPosition(), puppet:GetPosition()) 
			if puppet.ApproachDistance < GlobalManager.HookRadius then         
			  return true 
			end        
		end
		return false
	end
	
    local GetCloestMonster = function()
        local monsters = SceneManager.GetEntityManager().QueryPuppets(selectNearbyMonster)
		local function DistanceSort(p1,p2)
           return monsters[p1].ApproachDistance < monsters[p2].ApproachDistance
        end
        local key_table = {} 
		for key,_ in pairs(monsters) do  
          table.insert(key_table,key)  
        end 
		table.sort(key_table,DistanceSort)

		return monsters[key_table[1]]
        
    end

    
    local Update = function()
        if currentTarget and SceneManager.GetEntityManager().hero and Vector3.Distance2D(currentTarget:GetPosition(),SceneManager.GetEntityManager().hero:GetPosition()) > self.removeRadius then
            self.ClearTarget()
        end
    end
    
    function self.GetTarget( targetType )
        if not targetType then
            return currentTarget
        end
        
        if currentTarget and bit:_and(currentTarget.entityType, targetType) > 0 then
            --and Vector3.Distance2D(currentTarget:GetPosition(),SceneManager.GetEntityManager().hero:GetPosition()) < self.fightRadius then
			AddTargetFlag()
            return currentTarget
        else 
            return self.UpdateTarget( targetType )
        end
    end
    
    function self.SetTarget( target )
        if target and target ~= SceneManager.GetEntityManager().hero and target.canBeselect then
            currentTarget = target
            AddTargetFlag()
        end
    end
	
	function self.GetCurrentTarget()	
		return currentTarget
	end
    
    function self.UpdateTarget( targetType )
        if not targetType then
            self.SetTarget(GetCloestMonster())
            return currentTarget
        elseif bit:_and(EntityType.Monster, targetType) > 0  then
            self.SetTarget(GetCloestMonster())
            return currentTarget
        else
            self.SetTarget( SceneManager.GetEntityManager().QueryPuppet(selectCloestPlayer) )
            return currentTarget
        end
    end
	

    function self.ClearTarget()
        if targetFlag and targetFlag ~= true then
            RecycleObject(targetFlag)
            targetFlag = nil
        elseif targetFlag == true then
            targetFlag = false
        end
        
        currentTarget = nil
    end
    UpdateBeat:Add(Update,self)
	
	function self.GetCloestMonster()
		return GetCloestMonster()
		end
	
	function self.GetHookMonster()
		local monsters = SceneManager.GetEntityManager().QueryPuppets(HookSelectMonster)
		local function DistanceSort(p1,p2)
           return monsters[p1].ApproachDistance < monsters[p2].ApproachDistance
        end
        local key_table = {} 
		for key,_ in pairs(monsters) do  
          table.insert(key_table,key)  
        end 
		table.sort(key_table,DistanceSort)
        currentTarget = monsters[key_table[1]]
		if currentTarget ~= nil  then
           AddTargetFlag()
		   return currentTarget
		else
		   return nil
		end
    end
	
    return self

end

TargetManager = TargetManager or CreateTargetManager()