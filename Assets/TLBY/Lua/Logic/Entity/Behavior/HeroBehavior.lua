---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

local Behavior = require "Logic/Entity/Behavior/Behavior"
local HeroBehavior = ExtendClass(Behavior)

function HeroBehavior:__ctor(owner)
	self.modelId = nil
	self:OnCreate()
end

function HeroBehavior:createBar()
	if not self.hpBar then
	    self.hpBar = CreateHPBar(self.owner, self.behavior, 0, 30, 6, 0)
	end
	if not self.nameBar then
	    self.nameBar = CreateNameBar(self.owner,self.behavior, 0, 100,'#05e487',0)
	end
end
function HeroBehavior:OnCreate()
	local vocation = self.owner.data.vocation
	local sex = self.owner.data.sex
	local modelId = LuaUIUtil.GetHeroModelID(vocation,sex)
    local item = artResourceScheme.Model[modelId]
	self.modelId = modelId
	local ownerScale = self:GetObjectSettingScale()
	self.modelScale = ownerScale * item.Scale
	self.behavior = EntityBehaviorManager.CreateHero(
        vocation,sex,
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, 
		self.owner.entityType, 
		self.owner:GetBornPosition(), 
		self.modelScale,function() 
            self:BindEffect()
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.chatBar then self.chatBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
		end,self.owner.appearance_1,self.owner.appearance_2,self.owner.appearance_3)
	self.defaultPrefab = item.Prefab
	self.soulPrefab = 'Hero/linghunti/linghunti'
	self.defaultScale = modelScale
	
	self:createBar()

    self.chatBar = CreateChatBar(self.behavior, 0, 40)
	local const = require "Common/constant"
	if SceneManager.IsOnDungeonScene() then -- 副本则添加指路标示
        self.DungeonGuide = CreateDungeonGuideBar(self.behavior)
	end
	self.gameObject = self.behavior.gameObject
	self.transform = self.behavior.transform
	self.behavior.runAnimation = 'run'
	self.behavior.defaultAnimation = 'NormalStandby'

end

function HeroBehavior:ResetModel()
    if self.behavior then
	    LuaUIUtil.GetHeroModel(self.owner.data.vocation, self.owner.data.sex, function(obj) 
	    	if not self.owner or self.owner:IsDestroy() then
	    		return
		    end
			self.behavior:SetModel(obj, self.modelScale)
			if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.chatBar then self.chatBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
		end
		,self.owner.appearance_1, self.owner.appearance_2, self.owner.appearance_3)
    end
end

function HeroBehavior:BindEffect()		

	self:AddSpurtEvent('skill131', 0.001, 50, 0.2, 3, 0.33, 1.3, 0.5, false, true)
	self:AddSpurtEvent('skill999', 0, 10, 0.7, 0, 0, 0, 0, true, false)
	--spurtSpeed, beforeTime, suprtTime, afterTime, visible, bspeed, aspeed)
    self:BindEffectByModelId(self.modelId)

end

function HeroBehavior:SetOnFall(cb)
	self.behavior.OnFall = cb
end

function HeroBehavior:SetOnColliderHit(cb)
	self.behavior.OnColliderHit = cb
end

function HeroBehavior:CastCameraEffect(effectName , ...)
	local args = {...}
	self.behavior:CastCameraEffect(effectName,unpack(args))
end

function HeroBehavior:RemoveCameraEffect(effectName)
	self.behavior:RemoveCameraEffect(effectName)
end

return HeroBehavior
