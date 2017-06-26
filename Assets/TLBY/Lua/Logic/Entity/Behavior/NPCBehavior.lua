---------------------------------------------------
-- auth： wupeifeng
-- date： 2016/12/1
-- desc： 单位表现
---------------------------------------------------
require "UI/LuaUIUtil"
require "Logic/Entity/Behavior/BehaviorTalkComp"
local Behavior = require "Logic/Entity/Behavior/Behavior"
local NPCBehavior = ExtendClass(Behavior)
local log = require "basic/log"

function NPCBehavior:__ctor(owner)
    self.transform = nil
    self.gameObject = nil
    self:OnCreate()

    local nearHero = false
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
    self.nameBar = CreateNameBar(self.owner,self.behavior, 0, 100, '#ffb40a',-1)
    self.chatBar = CreateChatBar(self.behavior,0,40)
    self.talkComp = CreateBehaviorTalkComp(self.owner)

    
    local ifBar = chat ~= ""

    self.Update = function()
        if not SceneManager.GetEntityManager().hero or not self.owner.behavior 
            or not SceneManager.GetEntityManager().hero.behavior or not MyHeroManager.heroData then
            return
        end
        
        if self.show == nil then
            self.show = true
        end
        
        if self.owner.behavior.gameObject.activeSelf ~= self.show then
            self.owner.behavior.gameObject:SetActive(self.show)
        end
        
        if not self.show then
            self.chatBar.DestroyBar()
            self.nameBar.DestroyBar()     
            return
        end
        
        local distance = Vector3.Distance2D( self.owner:GetPosition(), SceneManager.GetEntityManager().hero:GetPosition())
        --self.owner.behavior.gameObject:SetActive(self.show and distance < 15)
        
        if distance < 15 and self.nameBar and self.nameBar.delay == -1 then
            self.nameBar.delay = 0
            self.nameBar.ShowNameBar()            
        end
        
        if distance > 15 and self.nameBar and self.nameBar.delay == 0  then
            self.nameBar.delay = -1
            self.nameBar.DestroyBar()
        end
        
        if ifBar then
            if distance < 4 then
                if not nearHero and math.random() > 0.5 then
                    self.chatBar.PushChat(chat)
                end
                nearHero = true
            else
                nearHero = false
            end
        end

    end

    UpdateBeat:Add(self.Update, self)
end

function NPCBehavior:OnCreate()                  
    self.modelId = self.owner.data.ModelID
	local forwardY = self.owner.data.ForwardY
    local item = self:GetModelData(self.modelId)
    local ownerScale = self:GetObjectSettingScale()
    self.modelScale = ownerScale * item.Scale * self.owner.data.Scale
    self.behavior = EntityBehaviorManager.CreateNPC(
        SceneManager.GetCurServerSceneId(), 
        self.owner.uid, self.owner.entityType, 
        self.owner:GetBornPosition(), self.modelId, self.modelScale,forwardY,function() 
            if self.chatBar then self.chatBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end)
    
    self.gameObject = self.behavior.gameObject
    self.transform = self.behavior.transform
    self.behavior.runAnimation = 'run'
    self.behavior.defaultAnimation = 'NormalStandby'
    self:UpdateBehavior(self.behavior.defaultAnimation)
end

function NPCBehavior:ShowNPC()
    self.show = true
end

function NPCBehavior:HideNPC()
    self.show = false
end

function NPCBehavior:InterAct()
    SceneManager.GetEntityManager().hero:LookAt(self.owner:GetPosition())
    self.owner:LookAt(SceneManager.GetEntityManager().hero:GetPosition())
    self.talkComp.OnInterAct(self.npcConfig.Function, self.npcConfig.CommonChat1)
end

function NPCBehavior:Destroy()
	Behavior.Destroy(self)
    UpdateBeat:Remove(self.Update, self)
end

return NPCBehavior
