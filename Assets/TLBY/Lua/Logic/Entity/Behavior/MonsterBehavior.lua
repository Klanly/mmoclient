---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------
local const = require "Common/constant"
local Behavior = require "Logic/Entity/Behavior/Behavior"
local MonsterBehavior = ExtendClass(Behavior)
local fightbaseTable = GetConfig("common_fight_base")
local resConfig = require "Logic/Scheme/common_art_resource"
function MonsterBehavior:__ctor(owner)
    self.fadeInOutEffect = nil
    self.modelId = nil
    self:OnCreate()
end

function MonsterBehavior:UpdateBehavior(animation)
    if self.owner:GetMonsterType() == 1 then
        if animation == 'run' or animation == 'die' or animation == 'behit' then
            Behavior.UpdateBehavior(self, animation)
        else
            if self.isOnBehitCD then
                return
            end
            Behavior.UpdateBehavior(self, animation)
        end 
    else
        Behavior.UpdateBehavior(self, animation)
    end
end

function MonsterBehavior:OnCreate()   
    self.modelId = self.owner.data.ModelID
    local item = self:GetModelData(self.modelId)
    local ownerScale = self:GetObjectSettingScale()
    self.modelScale = ownerScale * item.Scale * self.owner.data.Scale
         
     self.behavior = EntityBehaviorManager.CreateMonster(
        SceneManager.GetCurServerSceneId(), 
        self.owner.uid, self.owner.entityType, 
        self.owner:GetBornPosition(), self.modelId, 
        self.modelScale,function() 
            self:BindEffect()
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end)
    self.gameObject = self.behavior.gameObject
    self.transform = self.behavior.transform
    
    local type = 1
    local nameColor = '#FFA400'
    
    if not LuaUIUtil.IsEnemyForHero(self.owner.camp_type,self.owner.faction_id) then
        type = 5
        nameColor = '#ffb40a'
    else
        local delay = 3
        if self:IsBoss() then delay = 0 type = 5 end
        if self.owner.data.monsterSetting and self.owner.data.monsterSetting.AttackType == 1 then
            nameColor = '#f93954'
        else
            nameColor = '#FFA400'
        end
        self.hpBar = CreateHPBar(self.owner,self.behavior, 0, 30, type,delay)
    end

    self.nameBar = CreateNameBar(self.owner,self.behavior,0,100,nameColor,0)
    
    self.behavior.runAnimation = 'run'
    self.behavior.defaultAnimation = 'NormalStandby'

    if self.owner.source == EntitySource.Default then
       self:CastEffect('DissolveBornEffect')
    end
	self:BossShowTime()
end

function MonsterBehavior:BossShowTime()
	if self.owner.data.Type == const.MONSTER_TYPE.BOSS and self.owner.data.Para1 ~= '' then
		local bossAnimationId = tonumber(self.owner.data.Para1)
		local resAni =  fightbaseTable.BossAnimation[bossAnimationId].Animation
		ResourceManager.CreateCharacter(resAni,function(obj)
			local aniModel = obj
			local aniduration = fightbaseTable.BossAnimation[bossAnimationId].Time / 1000
			Game.SetGameSpeed(aniduration,0,function() 
			EntityBehaviorManager.ModelParent:SetActive(true)
			UIManager.ShowAllUI(true)
			CameraManager.CameraController.gameObject:SetActive(true)
			 GameObject.Destroy(aniModel)
			end)
			EntityBehaviorManager.ModelParent:SetActive(false)
			UIManager.ShowAllUI(false)
			CameraManager.CameraController.gameObject:SetActive(false)
			local CameraTarget = aniModel.transform:FindChild("CameraTarget")
			local modelId = self.owner.data.ModelID
			ResourceManager.CreateCharacter(resConfig.Model[modelId].Prefab,function(obj)
				local item = obj
				item.transform:SetParent(CameraTarget, false)
				item.transform.localPosition = Vector3.zero
			end)
		end)
	end
end

function MonsterBehavior:IsBoss()
    return self.owner.data.Type and commonFightBase.Type[self.owner.data.Type].Mutiblood == 2
end

function MonsterBehavior:BindEffect()        
    self:BindEffectByModelId(self.owner.data.ModelID)
end
function MonsterBehavior:Destroy()
    if not IsNil(self.fadeInOutEffect) then
        UnityEngine.GameObject.DestroyImmediate(self.fadeInOutEffect)
        self.fadeInOutEffect = nil
    end 
    Behavior.Destroy(self)
end

function MonsterBehavior:ShowBar()
    if self.hpBar then
        self.hpBar:ShowHpBar()
    end
    if self.nameBar then
        self.nameBar:ShowNameBar()
    end
end

function MonsterBehavior:FadeInOut(StartDelay, FadeInSpeed, FadeOutDelay, FadeOutSpeed, UseSharedMaterial, FadeOutAfterCollision, UseHideStatus, ShaderColorName)
    if self.behavior then
        self.fadeInOutEffect = self.behavior.gameObject:AddComponent(typeof(FadeInOutEffect))
        if ShaderColorName ~= nil then self.fadeInOutEffect.ShaderColorName = ShaderColorName end
        if StartDelay ~= nil then self.fadeInOutEffect.StartDelay = StartDelay end
        if FadeInSpeed ~= nil then self.fadeInOutEffect.FadeInSpeed = FadeInSpeed end
        if FadeOutDelay ~= nil then self.fadeInOutEffect.FadeOutDelay = FadeOutDelay end
        if FadeOutSpeed ~= nil then self.fadeInOutEffect.FadeOutSpeed = FadeOutSpeed end
        if UseSharedMaterial ~= nil then self.fadeInOutEffect.UseSharedMaterial = UseSharedMaterial end
        if FadeOutAfterCollision ~= nil then self.fadeInOutEffect.FadeOutAfterCollision = FadeOutAfterCollision end
        if UseHideStatus ~= nil then self.fadeInOutEffect.UseHideStatus = UseHideStatus end
    end
    Timer.Delay(StartDelay + FadeInSpeed + 1, function()
        if self.behavior and not IsNil(self.fadeInOutEffect) then
            UnityEngine.GameObject.DestroyImmediate(self.fadeInOutEffect)
            self.fadeInOutEffect = nil
        end
    end)
end

function MonsterBehavior:BehaveBehit(damage, event_type)
    if self:IsBoss() then
        self:CastEffect('BeHitHighlightEffect')
    end

    if self.owner:GetMonsterType() == 1 then
        if self.isOnBehitCD then
            return
        end
        self:StopBehavior(self.behavior.currentAnim)
        self:UpdateBehavior('behit')
        self:startBehitCD()
    else
        Behavior.BehaveBehit(self,damage,event_type)
    end
end

function MonsterBehavior:BebaveDie(callback)
    local function Dissolve()
        self:SetAnimationSpeed('die', 0)
        self:CastEffect("DissolveEffect", "Death")
        self.owner:GetTimer().Delay(1.9, callback)
    end
        
    Behavior.BebaveDie(self, Dissolve)
    
    if self:IsBoss() then
        if self.owner:GetSceneType() == const.SCENE_TYPE.WILD or self.owner:GetSceneType() == const.SCENE_TYPE.CITY then
            return 
        end
        Game.SetGameSpeed(2, 0.2)
    end
end
return MonsterBehavior