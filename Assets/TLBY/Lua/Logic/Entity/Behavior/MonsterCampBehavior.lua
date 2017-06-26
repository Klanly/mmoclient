---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

require "Logic/Entity/Behavior/BehaviorTalkComp"
local MonsterBehavior = require "Logic/Entity/Behavior/MonsterBehavior"
local MonsterCampBehavior = ExtendClass(MonsterBehavior)

function MonsterCampBehavior:__ctor(owner)
	if self.owner.configID then
		local config = require "Logic/Scheme/common_npc"     
		self.npcConfig = config.NPC[self.owner.configID]
	
		local chat = ""
		self.show = nil  

		if self.npcConfig then
			chat = LuaUIUtil.GetTextByID(self.npcConfig,'Chat')
			self.owner.name = LuaUIUtil.GetTextByID(self.npcConfig,'Name')
			self.owner.title = LuaUIUtil.GetTextByID(self.npcConfig,'Title')
		else
			error("NPC configId doesnot exsit:" .. self.owner.configID)
		end
	end
end

function MonsterCampBehavior:OnCreate()   
    MonsterBehavior.OnCreate(self)

    self.talkComp = CreateBehaviorTalkComp(self.owner)
end

function MonsterCampBehavior:InterAct()
	if not self.owner.configID then
        print(self.owner.configID)
		return
	end
	
	local hero = SceneManager.GetEntityManager().hero
	if hero == nil then
		return
	end
	
	if self.owner:IsEnemy(hero) then
		return
	end
	
    hero:LookAt(self.owner:GetPosition())
    self.owner:LookAt(hero:GetPosition())
    self.talkComp.OnInterAct(self.npcConfig.Function, self.npcConfig.CommonChat1)
end

return MonsterCampBehavior