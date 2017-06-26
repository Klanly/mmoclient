---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------
local const = require "Common/constant"


local vocationConfig = require "Logic/Scheme/growing_actor"

local Behavior = require "Logic/Entity/Behavior/Behavior"
local DummyBehavior = ExtendClass(Behavior)

function DummyBehavior:__ctor(owner)
	self.nameColor = LuaUIUtil.DummyNameColor.Green

	self.modelId = nil
	self.defaultPrefab = ""

	self:OnCreate()
end

function DummyBehavior:createBar()
    if not self.hpBar then
        if self:IsEnemy() then
            self.hpBar = CreateHPBar(self.owner, self.behavior, 0, 30, 3, 0)
        else
            local delay = -1
            if TeamManager.InTeam(self.owner.uid) then delay = 0 end
            self.hpBar = CreateHPBar(self.owner, self.behavior, 0, 30, 4, delay)
        end
    end

	if not self.nameBar then
        if self:IsEnemy() or SceneManager.currentSceneType == const.SCENE_TYPE.ARENA then -- 竞技场时所有玩家名字为红
            self.nameColor = LuaUIUtil.DummyNameColor.Red
        else
            self.nameColor = LuaUIUtil.DummyNameColor.Green
        end
	    self.nameBar = CreateNameBar(self.owner,self.behavior, 0, 100,self.nameColor,0)
	end
end

function DummyBehavior:OnCreate()
	local vocation = self.owner.data.vocation
	local sex = self.owner.data.sex
	self.modelId = LuaUIUtil.GetHeroModelID(vocation,sex)
    local item = artResourceScheme.Model[self.modelId]
	local ownerScale = self:GetObjectSettingScale()
	self.modelScale = ownerScale * item.Scale
	self.behavior = EntityBehaviorManager.CreateDummy(
        self.owner.data.vocation,
        self.owner.data.sex,
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, self.owner.entityType, 
		self.owner:GetBornPosition(), self.modelScale,function() 
            self:BindEffect()
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.chatBar then self.chatBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end,self.owner.appearance_1,self.owner.appearance_2,self.owner.appearance_3)

	self.defaultPrefab = item.Prefab
	self.soulPrefab = 'Hero/linghunti/linghunti'
	self.defaultScale = self.modelScale

	self:createBar()

    self.chatBar = CreateChatBar(self.behavior, 0, 40)
    
	self.gameObject = self.behavior.gameObject
	self.transform = self.behavior.transform
	self.behavior.runAnimation = 'run'
	self.behavior.defaultAnimation = 'NormalStandby'
end

function DummyBehavior:IsEnemy()
    return self.owner.data.country ~= MyHeroManager.heroData.country
end

function DummyBehavior:ResetModel()
     if self.behavior then
	    LuaUIUtil.GetHeroModel(self.owner.data.vocation,self.owner.data.sex,function(obj) 
            self.behavior:SetModel(obj,self.modelScale)
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
            if self.chatBar then self.chatBar:UpdateFollowingTarget() end
            if self.nameBar then self.nameBar:UpdateFollowingTarget() end
		end
		,self.owner.appearance_1,self.owner.appearance_2,self.owner.appearance_3)
    end
end

function DummyBehavior:SetOnFall(cb)
	self.behavior.OnFall = cb
end

function DummyBehavior:SetOnColliderHit(cb)
	self.behavior.OnColliderHit = cb
end

function DummyBehavior:BindEffect()		

	self:AddSpurtEvent('skill131', 0.001, 50, 0.2, 3, 0.33, 1.3, 0.5, false, true)
	self:AddSpurtEvent('skill161', 0, 10, 0.7, 0, 0, 0, 0, true, false)
	--spurtSpeed, beforeTime, suprtTime, afterTime, visible, bspeed, aspeed)
    self:BindLowEffectByModelId(self.modelId)
end

return DummyBehavior
