---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

require "Logic/Entity/Behavior/NameBar"
require "Logic/Entity/Behavior/ChatBar"
require "Logic/Entity/Behavior/HPBar"
require "Logic/Entity/Behavior/DungeonGuideBar"

local resConfig = require "Logic/Scheme/common_art_resource"
local vocationConfig = require "Logic/Scheme/growing_actor"
local confingTable = GetConfig("MotionEffects")

local CommonBehavior = require "Common/combat/Entity/Behavior/CommonBehavior"
local Behavior = ExtendClass(CommonBehavior)

function Behavior:__ctor(owner)
    self.behavior = nil

    self.behaviorLength = 0
    self.nameColor = 'white'
    self.transform = nil
    self.gameObject = nil

    self.defaultPrefab = ''
    self.defaultScale = 1
    self.soulPrefab = 'Hero/linghunti/linghunti'
    self.barDestroyTimer = nil

    self.isOnBehitCD = false -- 被攻击的动作CD
end

function Behavior:SetNameColor(color)
    if not self.nameBar then
        self.nameBar = CreateNameBar(self.owner,self.behavior, 0, 100,'',0)
    end
    self.nameColor = color
    self.nameBar.UpdateName(color)
end

function Behavior:GetObjectSettingScale()         --角色配置大小，即副本等场景配置Scale

    local ownerScale = self.owner.data.Scale
    if (not ownerScale) or (tonumber(ownerScale) <= 0) then ownerScale = 1  end
    
    return tonumber(ownerScale)
end

function Behavior:GetCurrentBehaviorLength()
    return self.behaviorLength
end
function Behavior:GetModelData(modelId)
    local item = resConfig.Model[modelId]
    return item
end

function Behavior:GetCurrentAnim()
    if self.behavior then
        return self.behavior.currentAnim
    end
    return nil
end

function Behavior:SetRunAnimation(anim)
    if self.behavior then
        self.behavior.runAnimation = anim
    end
end

function Behavior:SetDefaultAnimation(anim)
    if self.behavior then
        self.behavior.defaultAnimation = anim
    end
end

-- 展示动作
function Behavior:UpdateBehavior(animation)
    if self.behavior then
        if not self.behavior.IsDied then
            self.behaviorLength = self.behavior:PlayAnimation(animation)
        end
    end
end

-- 停止展示动作
function Behavior:StopBehavior(animation)
    if self.behavior then
        self.behavior:StopAnimation(animation)
    end
end

function Behavior:UpdateMoveto(pos, speed, rotation, delaytime)
    if self.behavior then
        self.behavior:UpdateMoveto(pos, speed, rotation, delaytime)
    end
end
function Behavior:Moveto(pos)
    if self.behavior then
        self.behavior:Moveto(pos)
    end
end

function Behavior:StopAt(pos,rotation)
    if self.behavior then
        self.behavior:StopAt(pos, rotation)
    end
end

function Behavior:MoveDir(direction)
    if self.behavior then
        self.behavior:MoveDir(direction)
    end
end

-- 停止移动
function Behavior:StopMove()
    if self.behavior then
        self.behavior:StopMove()
    end
end

-- 同步位置到服务器
function Behavior:SetSyncPosition(b)
    if self.behavior then
        self.behavior.IsSyncPosition = b
    end
end
function Behavior:GetSyncPosition()
    if self.behavior then
        return self.behavior.IsSyncPosition
    end
end

-- function Behavior:SetNavMesh(b)
--     if self.behavior then
--         -- self.behavior.IsNavMesh = b
--     end
-- end
-- function Behavior:GetNavMesh()
--     if self.behavior then
--         return false
--         -- return self.behavior.IsNavMesh
--     end
-- end


function Behavior:IsValidPos(pos)
    if self.behavior then
        return self.behavior:IsValidPos(pos)
    end
    return false
end

function Behavior:IsMoving()
    if self.behavior then
        return self.behavior.IsMoving
    end
    return false
end

function Behavior:BehaveIdle()
    if self.behavior.currentAnim ~= self.behavior.defaultAnimation then
        self:UpdateBehavior(self.behavior.defaultAnimation)
    end
end

function Behavior:BebaveDie(callback)
    self:UpdateBehavior('die')
    self.behavior.AutoSwitchNextAnimation = false
    self.behavior.IsDied = true
        
    self.barDestroyTimer = Timer.Delay(0.7,function() self:DestroyBar() end)

    self.owner:GetTimer().Delay(self:GetCurrentBehaviorLength(), callback)

end

function Behavior:DestroyBar()
    if self.hpBar then
        self.hpBar.DestroyBar()
        self.hpBar = nil
    end
    if self.nameBar then
        self.nameBar.DestroyBar()
        self.nameBar = nil
    end
    if self.chatBar then
        self.chatBar.DestroyBar()
        self.chatBar = nil
    end
    if self.barDestroyTimer then
        Timer.Remove(barDestroyTimer)
        self.barDestroyTimer = nil
    end
    
end

function Behavior:OnLevelUp()
    self:RemoveEffect('Common/eff_common@upgrade')
    self:AddEffect('Common/eff_common@upgrade')
end

function Behavior:AddEffect(resName, rootName, recyle, pos, angle, scale, detach, lossyScale)
    if not resName then
        return 
    end
    if not self.behavior then
        print("对象已经销毁")
        return
    end
    local r = rootName
    local rec = recyle
    local p = pos
    local a = angle
    local s = scale
    local d = detach
    local l = lossyScale
    if r == nil then
        r = 'root'
    end
    if rec == nil then
        rec = 0
    end
    if p == nil then
        p = Vector3.zero
    end
    if a == nil then
        a = Vector3.zero
    end
    if s == nil then
        s = Vector3.one
    end
    if d == nil then
        d = false
    end
    if l == nil then
        l = false
    end
    self.behavior:AddEffectGameObject(resName, r, rec, p, a, s, d, l)
end

function Behavior:RemoveEffect(res)
    if self.behavior then
        self.behavior:RemoveEffectGameObject(res)
    end
end
function Behavior:RemoveAllEffect()
    if self.behavior then
        self.behavior:RemoveAllEffectGameObject()
    end
end

function Behavior:Destroy()
    self:RemoveAllEffect()
    self:DestroyBar()
	if self.DungeonGuide then
        self.DungeonGuide.DestroyBar()
        self.DungeonGuide = nil
    end 
    EntityBehaviorManager.Destroy(self.owner.uid)
    self.behavior = nil
end

-- 展示被攻击动作

function Behavior:startBehitCD()
    self.isOnBehitCD = true
    Timer.Delay(0.3, function()
        self.isOnBehitCD = false
    end)
end

function Behavior:BehaveBehit(damage, event_type)
    if self.isOnBehitCD then
        return
    end
    if self.behavior.currentAnim == 'behit' or self.behavior.currentAnim == self.behavior.defaultAnimation then -- 只有在default状态下
        self:StopBehavior('behit')
        self:UpdateBehavior('behit')
        self:startBehitCD()
    end
end

function Behavior:BehaveAddHp(num)
    self:ShowDamage(num)
end

function Behavior:BehaveAddMp(num)
    self:AddMp(num)
end

function Behavior:LookAt(pos)
    if self.behavior then
        self.behavior:SetLookAt(pos)
    end
end

function Behavior:SetRadius(r)
    if self.behavior then
        self.behavior.Radius = r
    end
end
function Behavior:GetRaduis()
    if self.behavior then
        return self.behavior.Radius
    end
end

function Behavior:GetAnimationLength(animation)
    if self.behavior then
        return self.behavior:GetAnimationLength(animation)
    end
    return 0
end    
-- Default = 0,Once = 1,Clamp = 1,Loop = 2,PingPong = 4,ClampForever = 8
function Behavior:GetAnimationWrapMode(animation)
    if self.behavior then
        return self.behavior:GetAnimationWrapMode(animation)
    end
    return -1
end
function Behavior:IsAnimationLoop(animation)
    return self:GetAnimationWrapMode(animation) == 2
end
function Behavior:HasAnimation(animation)
    if self.behavior then
        return self.behavior:HasAnimation(animation)
    end
    return false
end
function Behavior:SetAnimationSpeed(animation, speed)
    if self.behavior then
        return self.behavior:SetAnimationSpeed(animation, speed)
    end
end

function Behavior:SetSpeed(s)
    if self.behavior and self.behavior.Speed ~= s then
        self.behavior.Speed = s
    end
end
function Behavior:GetSpeed()
    if self.behavior then
        return self.behavior.Speed
    end
end

function Behavior:GetPosition()
    if self.behavior then
        return self.behavior.gameObject.transform.position;
    end
    return nil
end

function Behavior:GetPartPosition(name)
    if self.behavior then
        local part = self.behavior.gameObject.transform:FindChild('Body/'..name)
        if not part then
            return self:GetPosition()
        end
        return part.position
    end
    return self:GetPosition()
end

function Behavior:SetPosition(pos)
    if self.behavior then
        self.behavior:SetPosition(pos)
    end
end

function Behavior:SetStoppingDistance(sd) 
    if self.behavior and self.behavior.StoppingDistance ~= sd then      
        self.behavior.StoppingDistance = sd     
    end
end

function Behavior:GetStoppingDistance()   
    if self.behavior then       
        return self.behavior.StoppingDistance       
    end 
end

function Behavior:GetRotation()
    if self.behavior then
        return self.behavior:GetRotation()
    end
end
function Behavior:SetRotation(rotation)
    if self.behavior then
        self.behavior:SetRotation(rotation)
    end
end

function Behavior:SpurtTo(dir, speed, btime, time, atime, visible, bspeed, aspeed, stopFrame) 
    if self.behavior then
        if visible == nil then
            visible = true
        end
        if stopFrame == nil then
            stopFrame = true
        end
        self.behavior:SpurtTo(dir, speed, btime, time, atime, visible, (bspeed or 0), (aspeed or 0), stopFrame) 
    end
end

function Behavior:SetModel(prefab, scale)
    if self.behavior then
	    ResourceManager.CreateCharacter(prefab,function(obj)
            if self.behavior then
                self.behavior:SetModel(obj, scale)
    			if self.hpBar then self.hpBar:UpdateFollowingTarget() end
    			if self.chatBar then self.chatBar:UpdateFollowingTarget() end
    			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
            end
		end)
    end
end

function Behavior:ResetModel()
end

function Behavior:SetScale(scale)
    if self.behavior then
        self.behavior:SetScale(scale)
    end 
end

-- function Behavior:ToBesoul(prefab, scale)
--     if self.behavior then
--         self.behavior:SetModel(prefab, scale)
--     end
-- end
-- function Behavior:ToBeResurrect()
--     if self.behavior then
--         self.behavior:ToBeResurrect()
--         self.behavior.IsDied = false
--     end
-- end

function Behavior:AddSoundEvent(animation, time, soundRes)
    if self.behavior then
        self.behavior:AddSoundEvent(animation, time, soundRes)
    end
end

function Behavior:AddEffectEvent(animation, time, effRes, root, isDetach, duration,delayDestroy, pos, rotation, scale)
    if self.behavior then
        self.behavior:AddEffectEvent(animation, time, effRes, root, isDetach, duration,delayDestroy, pos, rotation, scale)
    end
end

function Behavior:PlayShakeEvent( shakeRange,duration)
    if self.behavior then
        self.behavior:PlayShake(shakeRange, duration)
    end
end

local skill_config = GetConfig("growing_skill")

function Behavior:PlayHitEffect(attacker, skill_id, is_bullet, damage, event_type)
    is_bullet = is_bullet or false
    local skill_data = skill_config.Skill[tonumber(skill_id)]
    local behit_datas
    if skill_data ~= nil then
        behit_datas = SkillAPI.GetSkillBehitData(attacker, skill_id)
        if is_bullet or skill_data.Bullet ~= 1 then
            
            if behit_datas then
                
                for _,behit_data in pairs(behit_datas) do
                    local function play()
                        --[[if self.owner.entityType == EntityType.Monster and self:IsBoss() then
                            self:AddEffect(behit_data.effectPath, behit_data.node, 3, nil, nil, Vector3.New(2, 2, 2))
                        else]]
                            self:AddEffect(behit_data.effectPath, behit_data.node, 3)
                        --end
                    end

                    if behit_data.startTime and behit_data.startTime >0.0001 then
                        self.owner:GetTimer().Delay(behit_data.startTime, play)
                    else
                        play()
                    end
                end
                
            end
        end 
    end


local function playNum()
        if event_type == DamageType.Miss then
            self:ShowState(attacker.entityType,'miss')
        elseif event_type == DamageType.Block then
            self:ShowState(attacker.entityType,'block')
        elseif event_type == DamageType.Puncture then
            self:ShowState(attacker.entityType,'puncture')
        end
        if event_type == DamageType.Crit then
            self:ShowCritDamage(attacker.entityType,0-damage)
        elseif event_type ~= DamageType.Miss then
            self:ShowDamage(attacker.entityType,0-damage)
        end
    end

    if damage > 0 then
        if behit_datas and behit_datas[1] and behit_datas[1].startTime and behit_datas[1].startTime >0.0001 then
            self.owner:GetTimer().Delay(behit_datas[1].startTime, playNum)
        else
            playNum()
        end
    end
end
    
    local SetFollowTarget = function(transform,obj)
        if IsNil(transform) then
            return
        end
        local followTarget = transform:Find('Body/head')
        if followTarget then
            if followTarget.position.y - transform.position.y > 2.5 then
                obj:GetComponent('UIFollowingTarget').worldOffset = Vector3.New(0,2.5-(followTarget.position.y - transform.position.y),0)
            end
        else
            followTarget = transform
        end
        obj:GetComponent('UIFollowingTarget').target = followTarget
    end
    
    local ShowDamageNum = function(font,num)
        local cache = math.ceil(math.abs(num))
        local str = ''
        while(cache > 0)do
            str = string.format('<sprite=%s" index=%d>%s',font,cache%10,str)
            cache = math.floor(cache/10)
        end
        return str
    end
    
    local ShowHealNum = function(item,num,font)
        local cache = math.ceil(math.abs(num))
        local numbers = {}
        while(cache > 0)do
            table.insert(numbers,cache%10)
            cache = math.floor(cache/10)
        end
        for i=1,9 do
            local numberItem = item.transform:Find('green'..i).gameObject
            numberItem:SetActive(i<=#numbers)
            if i<=#numbers then
                numberItem:GetComponent('TextMeshProUGUI').text = string.format('<sprite=%s" index=%d>',font,numbers[#numbers-i+1])
            end
        end
    end

    local left = 0
    function Behavior:ShowDamage(entityType,damage)
        if damage < 0 then
            local prefab = 'A_eff_UI@damage_appear_right'
            local font = 'RedNum'
            local scale = 1
            if entityType == EntityType.Hero or entityType == EntityType.Pet then
                prefab = 'A_eff_UI@damage_appear_left'
                font = 'OrangeNum'
            end
            if entityType == EntityType.Pet then
                scale = 0.7
            end
            ResourceManager.CreateUI("HpBarUI/damage",1.1,function(clone)
                UIManager.SetParent(clone,LayerGroup.sceneDamage)
                SetFollowTarget(self.transform,clone)
                local textTransform = clone.transform:Find('damage/text')
                textTransform:GetComponent('TextMeshProUGUI').text = ShowDamageNum(font,-damage)
                textTransform.localPosition = Vector3.New(math.random()*50-25,0,0)
                clone.transform:Find('damage'):GetComponent('Animation'):Play(prefab)  
                clone.transform.localScale = Vector3.New(scale,scale,1)                
			end)
        elseif damage > 0 then
            ResourceManager.CreateUI("HpBarUI/heal",1.1,function(obj)
			local clone = obj
			UIManager.SetParent(clone,LayerGroup.sceneDamage)
            SetFollowTarget(self.transform,clone)
            ShowHealNum(clone,damage,'GreenNum')
			end)
        end
    end
    
    function Behavior:AddMp(num)
        ResourceManager.CreateUI("HpBarUI/addMp",1.1,function(clone)
		UIManager.SetParent(clone,LayerGroup.sceneDamage)
        SetFollowTarget(self.transform,clone)
        ShowHealNum(clone,num,'BlueNum')
		end)
    end
    
    function Behavior:ShowState(entityType,state,damage)
       ResourceManager.CreateUI("HpBarUI/"..state,1,function(clone)
        local scale = 1
        if entityType == EntityType.Pet then
            scale = 0.7
        end
        clone.transform.localScale = Vector3.New(scale,scale,1)
		 UIManager.SetParent(clone,LayerGroup.sceneDamage)
        SetFollowTarget(self.transform,clone)
        if damage and damage ~= 0 then
            self:ShowDamage(damage)
        end
		end)
    end
    
    function Behavior:ShowCritDamage(entityType,damage)
       ResourceManager.CreateUI("HpBarUI/crit",1,function(clone)
            local scale = 1
            if entityType == EntityType.Pet then
                scale = 0.7
            end
            clone.transform.localScale = Vector3.New(scale,scale,1)
            UIManager.SetParent(clone,LayerGroup.sceneDamage)
            SetFollowTarget(self.transform,clone)
            clone.transform:Find('crit/text'):GetComponent('TextMeshProUGUI').text = ShowDamageNum('YellowNum',-damage)
		end)
    end
    

function Behavior:AddSpurtEvent(animation, evtTime, spurtSpeed, suprtTime, beforeSpeed, beforeTime, afterSpeed, afterTime, visible, stopFrame)
    if self.behavior then
        if visible == nil then
            visible = true
        end
        if stopFrame == nil then
            stopFrame = true
        end
        if afterSpeed == nil then
            afterSpeed = 0
        end
        if beforeSpeed == nil then
            beforeSpeed = 0
        end
        self.behavior:AddSpurtEvent(animation, evtTime, spurtSpeed, beforeTime, suprtTime, afterTime, visible, beforeSpeed, afterSpeed, stopFrame)
    end
end

function Behavior:BindEffectByModelId(id)
    if confingTable[id] == nil then return end
    for clip, tb in pairs(confingTable[id]) do  
        if tb.motionEffects then 
            for _,v in pairs(tb.motionEffects)do
                self:AddEffectEvent(v.clipName, v.delayTime, v.effectPath, v.nodePath, v.detach, v.duration,
                    v.delayDestroyTime or 0, Vector3.New(v.positionX, v.positionY, v.positionZ),
                    Vector3.New(v.rotationX, v.rotationY, v.rotationZ),
                    Vector3.New(v.scaleX, v.scaleY, v.scaleZ))
            end
        else
            print('未给单位的动作配置特效 id=' .. id)
        end
        if tb.otherData and tb.otherData.soundRes then
            self:AddSoundEvent(tb.otherData.clipName, tb.otherData.soundPlayTime, tb.otherData.soundRes)
        end
    end 
end

function Behavior:BindLowEffectByModelId(id)
    if confingTable[id] == nil then return end
    for clip, tb in pairs(confingTable[id]) do  
        if tb.motionEffects then 
            for _,v in pairs(tb.motionEffects)do
                -- print((string.gsub(v.effectPath,'Hero','Hero_S',1)))
                self:AddEffectEvent(v.clipName, v.delayTime, (string.gsub(v.effectPath,'Hero','Hero_S',1))..'_S', v.nodePath, v.detach, v.duration,
                    v.delayDestroyTime or 0, Vector3.New(v.positionX, v.positionY, v.positionZ),
                    Vector3.New(v.rotationX, v.rotationY, v.rotationZ),
                    Vector3.New(v.scaleX, v.scaleY, v.scaleZ))
            end
        else
            print('未给单位的动作配置特效 id=' .. id)
        end
        if tb.otherData and tb.otherData.soundRes then
            self:AddSoundEvent(tb.otherData.clipName, tb.otherData.soundPlayTime, tb.otherData.soundRes)
        end
    end 
end

function Behavior:CastEffect(effect_name, ...)
	local args = {...}
    if self.behavior then
        self.behavior:CastEffect(effect_name,unpack(args))
    end
end

function Behavior:RevertEffect()
    self.behavior:RevertEffect()
end

function Behavior:SetCurrentAnimationSpeed(speed)
    self.behavior:SetCurrentAnimationSpeed(speed)
end

function Behavior:SetBodyActive(b)
    self.behavior.IsBodyActive = b
end
function Behavior:GetBodyActive()
    return self.behavior.IsBodyActive
end
function Behavior:SetPlayEffect(b)
    self.behavior.IsPlayEffect = b
end
function Behavior:GetPlayEffect()
    return self.behavior.IsPlayEffect
end

return Behavior
