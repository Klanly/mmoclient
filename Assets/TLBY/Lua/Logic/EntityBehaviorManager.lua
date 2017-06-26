---------------------------------------------------
-- auth：huasong
---------------------------------------------------
local log = require "basic/log"
entityBehavMgr = EntityBehaviorMgr.Instance()
local function CreateEntityBehaviorManager()
    local self = CreateObject()
    self.ModelParent = nil
     local function CreateEntity(bornPos,scale)
       if self.ModelParent == nil then
			 self.ModelParent = GameObject.New()
			 self.ModelParent.transform.localScale = Vector3.one 
			 self.ModelParent.name = 'Models'
		end
        local parent = GameObject.New()
        parent.transform.localScale = Vector3.one * scale
        parent.transform.position = bornPos
        parent.transform:SetParent(self.ModelParent.transform, false)
        return parent
    end
    
    self.CreateHero = function(vocation,sex,sceneid,uid,entityType,bornPos,scale,func,head,body,weapon)
        local go = CreateEntity(bornPos,scale)
        local hero = entityBehavMgr:CreateHero(sceneid,uid,entityType,go)
		CameraManager.CameraController.target_ = hero.gameObject.transform;
        hero.audioSource.volume = SoundManager.GetAudioEffectVolume()
		LuaUIUtil.GetHeroModel(vocation,sex,function(obj)
            if IsNil(go) then
              return
            end
            obj.transform:SetParent(go.transform, false)
            obj.transform.localPosition = Vector3.zero  
            go.name = obj.name
            obj.name = "Body"
            
            if func then
              func(hero)
            end
		end,head,body,weapon)
        return hero
    end
    
    self.CreateDummy = function(vocation,sex,sceneid,uid,entityType,bornPos,scale,func)
        local go = CreateEntity(bornPos,scale)
        local dummy = entityBehavMgr:CreateDummy(sceneid,uid,entityType,go)
        dummy.audioSource.volume = SoundManager.GetAudioEffectVolume()
		LuaUIUtil.GetHeroModel(vocation,sex,function(obj)
            if IsNil(go) then
              return
            end
            obj.transform:SetParent(go.transform, false)
            obj.transform.localPosition = Vector3.zero  
            go.name = obj.name
            obj.name = "Body"
            if func then
              func(dummy)
            end
		end)

        return dummy
    end
    
    self.CreateMonster = function(sceneid,uid,entityType,bornPos,modelID,scale,func)
        local go = CreateEntity(bornPos,scale)
		LuaUIUtil.GetCharacterModel(modelID,function(obj)
		if IsNil(go) then
		  return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func()
		end
		end)
        local monster = entityBehavMgr:CreateMonster(sceneid,uid,entityType,go)
        monster.audioSource.volume = SoundManager.GetAudioEffectVolume()
        return monster
    end
	
	self.CreateBarrierBehavior = function(sceneid,uid,entityType,bornPos,dir,scale,prefab)
		local go = CreateEntity(bornPos, 1)
		ResourceManager.CreateEffect(prefab,function(obj)
		if IsNil(go) then
		  return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		end)
		local barrierBehavior = entityBehavMgr:CreateBarrierBehavior(sceneid,uid,entityType,
																bornPos,dir,scale,go)
		return barrierBehavior
	end
    
    
    self.CreatePet = function(sceneid,uid,entityType,bornPos,prefab,scale,func)
        local go = CreateEntity(bornPos,scale)
		ResourceManager.CreateCharacter(prefab,function(obj)
		if IsNil(go) then
		  return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func()
		end
		end)
        local pet = entityBehavMgr:CreatePet(sceneid,uid,entityType,go)
       
        pet.audioSource.volume = SoundManager.GetAudioEffectVolume()
        return pet
    end
    
    self.CreateNPC = function(sceneid,uid,entityType,bornPos,modelID,scale,forwardY,func)
       local go = CreateEntity(bornPos,scale)
		LuaUIUtil.GetCharacterModel(modelID,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func()
		end
		end)
		go.transform.localEulerAngles = Vector3.New(0,forwardY,0)
        local npc =  entityBehavMgr:CreateNPC(sceneid,uid,entityType,go)
       
        npc.audioSource.volume = SoundManager.GetAudioEffectVolume()
        return npc
    end
    
    self.CreateSummon = function(sceneid,uid,entityType,bornPos,prefab,scale,func)
        local go = CreateEntity(bornPos,scale)
		ResourceManager.CreateCharacter(prefab,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func()
		end
		end)
        local t = entityBehavMgr:CreateSummon(sceneid,uid,entityType,go)
       
        return t
    end
    
    self.CreateBullet = function(sceneid,uid,entityType,bornPos,prefab,scale,func)
        local go = CreateEntity(bornPos,scale)
		ResourceManager.CreateCharacter(prefab,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func()
		end
		end)
        local t =  entityBehavMgr:CreateBullet(sceneid,uid,entityType,go)
       
        return t
    end
    
    self.CreateDrop = function(sceneid,uid,entityType,bornPos,prefab,scale,func)
        local go = CreateEntity(bornPos,scale)
		ResourceManager.CreateCharacter(prefab,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		if func then
		  func(go)
		end
		end)
        local t = entityBehavMgr:CreateDrop(sceneid,uid,entityType,go)
       
        return t
    end
    
    self.CreateEmptyGo = function(sceneid,uid,entityType,bornPos,prefab)
        local go = CreateEntity(bornPos,1)
		ResourceManager.CreateCharacter(prefab,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		end)
        local t = entityBehavMgr:CreateEmptyGo(sceneid,uid,entityType,go)
       
        return t
    end
	
    self.CreateConveyTool = function(sceneid,uid,prefab,scale,pos,rect,luaTable)
       local go = CreateEntity(pos, scale);
		ResourceManager.CreateEffect(prefab,function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		end)
        local t = entityBehavMgr:CreateConveyTool(sceneid,uid,rect,go,luaTable)
       
        return t
    end

    self.CreateTrick = function(sceneid, uid, entityType, bornPos, prefab, scale) 
        local go = CreateEntity(bornPos, scale)
		ResourceManager.CreateCharacter('Toy/empty',function(obj)
		if IsNil(go) then
		 return
		end
		obj.transform:SetParent(go.transform, false)
        obj.transform.localPosition = Vector3.zero  
        go.name = obj.name
        obj.name = "Body"
		end)
        local trick = entityBehavMgr:CreateTrick(sceneid,uid,entityType,go)
      
        return trick
    end
	
	self.Destroy = function(uid)
		 entityBehavMgr:Destroy(uid)
	end
   
    return self
end

EntityBehaviorManager = EntityBehaviorManager or CreateEntityBehaviorManager()