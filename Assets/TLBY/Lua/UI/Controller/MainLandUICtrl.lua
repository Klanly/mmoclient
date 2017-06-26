--songhua--

require "UI/Controller/LuaCtrlBase"
require "Logic/TargetManager"
require "Common/combat/Skill/SkillManager"
require "UI/Controller/MainUITeamCtrl"
require "UI/Controller/MainUITaskCtrl"
require "UI/Controller/BuffDetailUICtrl"
require "Logic/Effect/ArrestPet"
require "UI/Controller/MainUIFightCtrl"

local const = require "Common/constant"

-- 英雄是否存在并活着
local isHeroDied = function()
    local hero = SceneManager.GetEntityManager().hero
    if not hero or hero:IsDied() or hero:IsDestroy() then
        return true
    end
    return false
end
local showDieNotice = function()
    UIManager.ShowNotice('英雄已经死亡, 无法操作! ')
end

-- 菜单栏基类，包含展开/收缩功能
local function CreateMenuCtrl()
    local self = CreateObject()
    self.isExpand = true
    self.toPos = Vector2.zero
    self.duration = 0.2
    self.menuItems = {}

    self.CollapseImmediately = function()
        for k, v in pairs(self.menuItems) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = self.toPos
            v.gameObject:SetActive(false)
        end
        self.isExpand = false
    end
    self.ExpandImmediately = function()
        for k, v in pairs(self.menuItems) do
            v.gameObject:GetComponent("RectTransform").anchoredPosition = v.defaultPos
        end
        self.isExpand = true
    end
    local tween = {}
    self.Collapse = function() 
        for k, v in pairs(self.menuItems) do
            if tween[k] then
                GameObject.Destroy(tween[k])
            end
            tween[k] = BETween.anchoredPosition(v.gameObject, self.duration, self.toPos)
            tween[k].onFinish = function()
                v.gameObject:SetActive(false)
                tween[k] = nil
            end           
        end
        self.isExpand = false
    end

    self.Expand = function() 
        for k, v in pairs(self.menuItems) do
            if tween[k] then
                GameObject.Destroy(tween[k])
            end
            v.gameObject:SetActive(true)
            tween[k] = BETween.anchoredPosition(v.gameObject, self.duration, v.defaultPos)
            tween[k].onFinish = function()
                tween[k] = nil
            end
        end
        self.isExpand = true
    end

    self.Switch = function()
        if self.isExpand then
            self.Collapse()
        else
            self.Expand()
        end
    end

    self.onUnload = function()
        self.ExpandImmediately()
    end
    
    return self 
end

-- 底部菜单UI　
local function CreateBottomMenuCtrl(view)
    local self = CreateMenuCtrl()
    local base = self.base()
    self.menuItems = {
        social = {
            gameObject = view.imgMenuSocial,
            defaultPos = view.imgMenuSocial:GetComponent("RectTransform").anchoredPosition,
        },
        skills = {
            gameObject = view.imgMenuSkills,
            defaultPos = view.imgMenuSkills:GetComponent("RectTransform").anchoredPosition,
        },
        role = {
            gameObject = view.imgMenuRole,
            defaultPos = view.imgMenuRole:GetComponent("RectTransform").anchoredPosition,
        },
        cast = {
            gameObject = view.imgMenuCast,
            defaultPos = view.imgMenuCast:GetComponent("RectTransform").anchoredPosition,
        },
        weapons = {
            gameObject = view.imgMenuWeapons,
            defaultPos = view.imgMenuWeapons:GetComponent("RectTransform").anchoredPosition,
        },
        task = {
            gameObject = view.imgMenuTask,
            defaultPos = view.imgMenuTask:GetComponent("RectTransform").anchoredPosition,
        },
        list = {
            gameObject = view.imgMenuList,
            defaultPos = view.imgMenuList:GetComponent("RectTransform").anchoredPosition,
        },
        set = {
            gameObject = view.imgMenuSet,
            defaultPos = view.imgMenuSet:GetComponent("RectTransform").anchoredPosition,
        },
        faction = {
            gameObject = view.imgMenuFaction,
            defaultPos = view.imgMenuFaction:GetComponent("RectTransform").anchoredPosition,
        },
    }
    self.toPos = view.imgMenuRole:GetComponent("RectTransform").anchoredPosition

        -- for k, v in pairs(self.menuItems) do
        --     print("x:" .. v.defaultPos.x)
        -- end
    self.CollapseImmediately = function()
        base.CollapseImmediately()
        view.imgMenuBg.transform.localScale = Vector3.New(0, 1, 1)
        view.imgMenuSwitchBg:SetActive(self.isExpand)
        view.imgMenuSwitchDown:SetActive(not self.isExpand)
    end
    self.Collapse = function() 
        base.Collapse()
        BETween.scale(view.imgMenuBg, self.duration, Vector3.New(0, 1, 1))
        UIManager.GetCtrl(ViewAssets.MainLandUI).chatUI.OnCollapse()
        view.imgMenuSwitchBg:SetActive(self.isExpand)
        view.imgMenuSwitchDown:SetActive(not self.isExpand)
    end

    self.Expand = function() 
        base.Expand()

        BETween.scale(view.imgMenuBg, self.duration, Vector3.New(1, 1, 1))
        view.FightGroup:SetActive(false)
        view.phoneGroup:SetActive(false)
        UIManager.GetCtrl(ViewAssets.MainLandUI).chatUI.OnExpand()
        view.imgMenuSwitchBg:SetActive(self.isExpand)
        view.imgMenuSwitchDown:SetActive(not self.isExpand)
    end

    self.OnPetClick = function()
        if isHeroDied() then showDieNotice(); return end
        
        UIManager.GetCtrl(ViewAssets.PetUI).ShowPetUI()
    end
	
	self.OnSystemSettingClick = function()
        UIManager.PushView(ViewAssets.SystemSettingUI)
    end

    self.OnRoleClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.RoleUI)
    end

    self.OnEquipmentClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.EquipmentUI)
    end
    
    self.OnSkillClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.SkillSet)
    end
    
    self.OnMailClick = function()
        UIManager.GetCtrl(ViewAssets.MailUI).OpenUI()
    end
    
    self.OnFactionClick = function()
        if isHeroDied() then showDieNotice(); return end
		if FactionManager.InFaction() then
			UIManager.PushView(ViewAssets.FactionUI)
        else
			UIManager.PushView(ViewAssets.UnionListUI)
        end
    end
	
	self.OnHookClick = function()
        if isHeroDied() then showDieNotice(); return end
        local hero = SceneManager.GetEntityManager().hero
		if hero.lowFlyManager.IsShowLocus() and not GlobalManager.isHook then
    		UIManager.ShowNotice('轻功中，不能自动战斗！')
    		return
        end

       if TeamManager.InTeam() then
            local data = {}
            data.func_name = 'on_change_on_hook'
            data.b_on_hook = not GlobalManager.isHook
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
       else
            local hookCombat = require "Logic/OnHookCombat"
            hookCombat.SetHook(not GlobalManager.isHook)
       end
    end

    self.OnTaskClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.TaskUI)
    end
	
	self.OnRankListClick = function()
        if isHeroDied() then showDieNotice(); return end
		UIManager.PushView(ViewAssets.RankingListUI)
	end
       
    local InitUIAnchor = function()        
        UIUtil.SetRectPivot(view.imgMenuBg, Vector2.New(0, 0.5))
        UIUtil.SetRectAttachment(view.buttomMenu, "lb")  -- 贴左下角
        UIUtil.SetRectAttachment(view.showBtn, "rb")  -- 贴右下角
      --  UIUtil.SetRectAttachment(view.FightGroup, "rb")  -- 贴右下角
        UIUtil.SetRectAttachment(view.PetGroup, "rt")  -- 贴右上角
        UIUtil.SetRectAttachment(view.Rocker, "lb")
        -- UIUtil.SetRectAttachment(view.chatGroup, "b")
        UIUtil.SetRectAttachment(view.phoneGroup, "lb")
        UIUtil.SetRectAttachment(view.roleSelect, "lt")
        UIUtil.SetRectAttachment(view.role, "lt")
        UIUtil.SetRectAttachment(view.topMenu, "rt")
        UIUtil.SetRectAttachment(view.imgMap, "rt")
        UIUtil.SetRectAttachment(view.proExp, "b")
    end
    local create = function()
        ClickEventListener.Get(view.imgMenuSwitchBg).onClick = self.Switch
        ClickEventListener.Get(view.imgMenuSwitchDown).onClick = self.Switch
        ClickEventListener.Get(view.imgMenuWeapons).onClick = self.OnPetClick
        UIUtil.AddButtonEffect(view.imgMenuWeapons, nil, nil)
        ClickEventListener.Get(view.imgMenuRole).onClick = self.OnRoleClick
        UIUtil.AddButtonEffect(view.imgMenuRole, nil, nil)
        ClickEventListener.Get(view.imgMenuCast).onClick = self.OnEquipmentClick
        UIUtil.AddButtonEffect(view.imgMenuCast, nil, nil)
        ClickEventListener.Get(view.imgMenuSkills).onClick = self.OnSkillClick
        ClickEventListener.Get(view.imgMenuSocial).onClick = self.OnMailClick
        ClickEventListener.Get(view.imgMenuFaction).onClick = self.OnFactionClick
        UIUtil.AddButtonEffect(view.imgMenuSkills, nil, nil)
		ClickEventListener.Get(view.imgMenuSet).onClick = self.OnSystemSettingClick
		ClickEventListener.Get(view.btnAuto).onClick = self.OnHookClick
        ClickEventListener.Get(view.imgMenuTask).onClick = self.OnTaskClick
        ClickEventListener.Get(view.imgMenuList).onClick = self.OnRankListClick
        view.buttomMenu:SetActive(false)
        self.CollapseImmediately()
        self.duration = 0.15
        view.buttomMenu:SetActive(true)
        InitUIAnchor()
        view.btnAuto:GetComponent('Toggle').isOn = GlobalManager.isHook
    end

    create()
    return self
end

-- 顶部菜单UI
local function CreateTopMenuCtrl(view)
    local self = CreateMenuCtrl()
    local base = self.base()
    self.menuItems = {
        challenge = {
            gameObject = view.imgMenuChallenge,
            defaultPos = view.imgMenuChallenge:GetComponent("RectTransform").anchoredPosition,
        },
        dailytask = {
            gameObject = view.imgMenuDailytask,
            defaultPos = view.imgMenuDailytask:GetComponent("RectTransform").anchoredPosition,
        },
        exchange = {
            gameObject = view.imgMenuExchange,
            defaultPos = view.imgMenuExchange:GetComponent("RectTransform").anchoredPosition,
        },
        first = {
             gameObject = view.imgMenuFirst,
             defaultPos = view.imgMenuFirst:GetComponent("RectTransform").anchoredPosition,
        },
        activity = {
            gameObject = view.imgMenuActivity,
            defaultPos = view.imgMenuActivity:GetComponent("RectTransform").anchoredPosition,
        },
    }
    self.toPos = view.imgMenuChallenge:GetComponent("RectTransform").anchoredPosition

    self.CollapseImmediately = function()
        base.CollapseImmediately()
        view.imgMenuExtend.transform.rotation = Vector3.New(0, 0, 180)
        view.dungeonInfoParent:SetActive(true)
    end
    self.Collapse = function() 
        base.Collapse()
        BETween.rotation(view.imgMenuExtend, self.duration, Vector3.New(0, 0, 180)).onFinish = function()
        view.dungeonInfoParent:SetActive(true) end
    end

    self.Expand = function() 
        base.Expand()
        BETween.rotation(view.imgMenuExtend, self.duration, Vector3.New(0, 0, 0)) 
        view.dungeonInfoParent:SetActive(false)
    end
    
    self.ExpandImmediately = function()
        base.ExpandImmediately()
        view.dungeonInfoParent:SetActive(false)
    end

    local onChallengeClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.ChallengeUI)
    end
    local onShopClick = function()
        UIManager.GetCtrl(ViewAssets.MallUI).OpenUI()
    end
    local onArenaClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.ArenaSelect)
    end
    local onActiveClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.DailyTask)
    end
    local onFightStatusClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.FightStatisUI)
    end
	
	local OnCampUIClick = function()
        if isHeroDied() then showDieNotice(); return end
		UIManager.PushView(ViewAssets.CampUI)
	end
	
    -- 绑定按键事件
    local bingEvent = function()
        ClickEventListener.Get(view.imgMenuChallenge).onClick = onChallengeClick
        UIUtil.AddButtonEffect(view.imgMenuChallenge, nil, nil) 
        ClickEventListener.Get(view.imgMenuExchange).onClick = onShopClick
        UIUtil.AddButtonEffect(view.imgMenuExchange, nil, nil) 
        ClickEventListener.Get(view.imgMenuDailytask).onClick = onArenaClick
        UIUtil.AddButtonEffect(view.imgMenuDailytask, nil, nil)
        ClickEventListener.Get(view.fightStatus).onClick = onFightStatusClick
        UIUtil.AddButtonEffect(view.fightStatus, nil, nil)
		ClickEventListener.Get(view.imgMenuFirst).onClick = OnCampUIClick
        UIUtil.AddButtonEffect(view.imgMenuFirst, nil, nil)
        ClickEventListener.Get(view.imgMenuActivity).onClick = onActiveClick
    end
    local create = function()
        ClickEventListener.Get(view.imgMenuExtend).onClick = self.Switch
        view.topMenu:SetActive(false)
        self.duration = 0.15
        view.topMenu:SetActive(true)
        bingEvent()
    end

    create()
    return self
end

-- 聊天窗口UI
local function CreateChatCtrl(view)
    local self = CreateObject()
    
    local tween = nil
    self.OnCollapse = function()
        if tween then GameObject.Destroy(tween) end
        tween = BETween.anchoredPosition(view.chatGroup, self.duration, self.defaultPos)
        tween.onFinish = function()
            view.FightGroup:SetActive(true)
            view.phoneGroup:SetActive(true)
            tween = nil
        end

        local rect = view.chatGroup:GetComponent("RectTransform").sizeDelta
    end

    self.OnExpand = function()
        if tween then GameObject.Destroy(tween) end
        tween = BETween.anchoredPosition(view.chatGroup, self.duration, Vector2.New(self.defaultPos.x + 520, self.defaultPos.y))
        tween.onFinish = function() tween = nil end
        local rect = view.chatGroup:GetComponent("RectTransform").sizeDelta
    end
    
    local Create = function()
        self.defaultPos = Vector2.New(-17,12)
        view.chatGroup:GetComponent("RectTransform").anchoredPosition = self.defaultPos
        self.duration = 0.15
        self.defaultWidth = view.imgChatBg:GetComponent("RectTransform").sizeDelta.x
        self.defaultHeight = view.imgChatBg:GetComponent("RectTransform").sizeDelta.y
    end
    Create()
    return self
end

-- 当前选中目标UI
local function CreateTargetUICtrl(view)
    local self = CreateObject()
    self.visible = true
    local timer = nil
    local target = nil
    local showValue = 7
    local trueValue = 7
    local colors = {view.hp0:GetComponent('Image').sprite,view.hp1:GetComponent('Image').sprite,view.hp2:GetComponent('Image').sprite,view.hp3:GetComponent('Image').sprite,view.hp4:GetComponent('Image').sprite,view.hp5:GetComponent('Image').sprite}
    local resConfig = artResourceScheme
    local parameterTable = require'Logic/Scheme/common_parameter_formula'
    
    local CalHpValue = function(target)
        local hpMax = target.hp_max() or 1
        local currentHp = target.hp
        if currentHp < 0 then
            currentHp = 0
        end
        if target.entityType == EntityType.Monster and target.behavior:IsBoss() then
            local level = target.level or 1
            local maxPreline = 1000
            local tb = parameterTable
            local hpTable = tb.HaemalStrand
            for i=#hpTable,1,-1 do
                if level >= hpTable[i].LowerLevel then
                    maxPreline = hpTable[i].BloodVolumePoints
                    break
                end
            end
            
            if hpMax > maxPreline then
                local line = math.ceil(hpMax / maxPreline)
                local hpPerLine = hpMax / line
                return currentHp / hpPerLine
            end
        end
        return currentHp / hpMax
    end
    
    local SetValue = function(image,value)
        if value == 0 then
            image.fillAmount = 0
        elseif value % 1 == 0 then
            image.fillAmount = 1
        else
            image.fillAmount = value % 1
        end
    end
    
    local UpdateHp = function()
        local trueLayer = math.ceil(trueValue)
        local showLayer = math.ceil(showValue)
        local half = Color.New(0.6,0.6,0.6,1)
        if showLayer - trueLayer >= 2 then
            self.hpImg1.overrideSprite = colors[((showLayer-1) % #colors) + 1]
            self.hpImg1.color = half
            SetValue(self.hpImg1,showValue)
            self.hpImg2.overrideSprite = colors[((showLayer-1) % #colors)]
            self.hpImg2.color = half
            self.hpImg2.fillAmount = 1
            self.hpImg2.gameObject:SetActive(true)
            self.hpImg3.gameObject:SetActive(false)
            
        elseif showLayer - trueLayer == 1 then
            self.hpImg1.overrideSprite = colors[((showLayer-1) % #colors) + 1]
            self.hpImg1.color = half
            SetValue(self.hpImg1,showValue)
            self.hpImg2.overrideSprite = colors[((trueLayer-1) % #colors) + 1]
            SetValue(self.hpImg2,trueValue)
            self.hpImg2.color = Color.white
            self.hpImg2.gameObject:SetActive(true)
            self.hpImg3.overrideSprite = colors[((trueLayer-1) % #colors) + 1]
            self.hpImg3.color = half
            self.hpImg3.fillAmount = 1
            self.hpImg3.gameObject:SetActive(true)
     
        else 
            local c = colors[((trueLayer-1) % #colors) + 1]
            self.hpImg1.overrideSprite = c
            SetValue(self.hpImg1,trueValue)
            self.hpImg1.color = Color.white
            self.hpImg2.overrideSprite = c
            self.hpImg2.color = half
            self.hpImg2.gameObject:SetActive(true)    
            SetValue(self.hpImg2,showValue)
            self.hpImg3.gameObject:SetActive(trueLayer > 1)
            if trueLayer > 1 then
                self.hpImg3.overrideSprite = colors[((trueLayer-1) % #colors)]
                self.hpImg3.color = Color.white
                self.hpImg3.fillAmount = 1
            end
        end
        local lineNum = ""
        if showLayer > 1 then lineNum = 'x'..showLayer end
        view.hpLineCount:GetComponent("TextMeshProUGUI").text = lineNum
    end
    
    local UpdateBox = function(target)
        view.playerBox:SetActive(false)
        view.petBox:SetActive(false)
        view.npcBox:SetActive(false)
        for i=1,10 do
            view['monsterBox'..i]:SetActive(false)
        end
    
        if target.entityType == EntityType.Dummy then
            view.playerBox:SetActive(true)
        elseif target.entityType == EntityType.Pet or target.entityType == EntityType.WildPet then
            view.petBox:SetActive(true)
        elseif (target.entityType == EntityType.MonsterCamp or target.entityType == EntityType.Monster) and view['monsterBox'..target.data.Type] then
            view['monsterBox'..target.data.Type]:SetActive(true)
        else
            view.npcBox:SetActive(true)
        end
    end
    
    local ShowPlayerOpUI = function(target)
        if isHeroDied() then showDieNotice(); return end
        if target.entityType ~= EntityType.Dummy then
            return
        end
        ContactManager.QuestPlayerInfo(target.uid,view.imgTargetHead.transform.position)
    end
    
    local cacheChargeTime = 0
    local showChargetTime = 0
    local Update = function()
        if not TargetManager then
            return
        end
        local currentTarget = TargetManager.GetCurrentTarget()
 
        if not currentTarget then--or target:IsDied() then
            self.SetActive(false)
            target = nil
            view.skillProgress3:GetComponent("Slider").value = 0
        else
            self.SetActive(true)
            trueValue = CalHpValue(currentTarget)
            if target ~= currentTarget then
                BETween.alpha(view.roleSelect,0.3,0,1)
                target = currentTarget
                view.textSelectName:GetComponent("TextMeshProUGUI").text = target.name
                view.textSelectLevel:GetComponent("TextMeshProUGUI").text = target.level or 1
                view.imgTargetHead:GetComponent('Image').overrideSprite = LuaUIUtil.GetPuppetIcon(target)
                ClickEventListener.Get(view.playerBox).onClick = function() ShowPlayerOpUI(target) end
                view.comp:SetActive(target.data.country ~= nil)
                view.iconCamp1:SetActive(target.data.country == 1)
                view.iconCamp2:SetActive(target.data.country == 2)
                showValue = trueValue
                UpdateBox(target)
                UpdateHp()
            elseif trueValue ~= showValue then                    
            --view.hp0:GetComponent('Image').fillAmount = target.hp/target.base_hp_max()       
                showValue = showValue - 0.03
                if showValue - trueValue <0.03 then --加血
                    showValue = trueValue
                end
                UpdateHp()
            end
            local currentSkill = target.skillManager:GetSkillInCastStart()
            view.skillProgress1:SetActive(currentSkill and currentSkill.can_break and target.skillManager.xuli_time_left > 0)
            view.skillProgress2:SetActive(currentSkill and not currentSkill.can_break and target.skillManager.xuli_time_left > 0)
            if target.skillManager.xuli_time ~= 0 then
                if target.skillManager.xuli_time_left ~= cacheChargeTime then -- 平滑显示进度条
                    showChargetTime = target.skillManager.xuli_time - target.skillManager.xuli_time_left
                    cacheChargeTime = target.skillManager.xuli_time_left
                else
                    showChargetTime = showChargetTime + UnityEngine.Time.deltaTime
                end
                local value = (showChargetTime + UnityEngine.Time.deltaTime)/target.skillManager.xuli_time
                if currentSkill and currentSkill.can_break then
                    view.skillProgress1:GetComponent("Slider").value = value
                else
                    view.skillProgress2:GetComponent("Slider").value = value
                end
            end
            if target.entityType == EntityType.Monster and target:GetMonsterType() == const.MONSTER_TYPE.WILD_ELITE_BOSS then
                local anger_value = target.anger_value/target.max_anger_value
                if not view.skillProgress3.activeSelf then
                    view.skillProgress3:SetActive(true)
                else
                    local cur_value = view.skillProgress3:GetComponent("Slider").value
                    local delta_value = parameterTable.Parameter[47].Parameter * UnityEngine.Time.deltaTime/target.max_anger_value
                    if cur_value > anger_value then
                        delta_value = delta_value * (-1)
                    end
                    if math.abs(anger_value - cur_value) > delta_value then
                        view.skillProgress3:GetComponent("Slider").value = cur_value + delta_value
                    end
                end
            else
                view.skillProgress3:SetActive(false)
                view.skillProgress3:GetComponent("Slider").value = 0
            end
        end	
    end

    self.SetActive = function(b)
        if self.visible ~= b then
            view.roleSelect:SetActive(b)
            self.visible = b
        end
    end

    local Create = function()
        self.SetActive(false)
        UpdateBeat:Add(Update,self)
        self.hpImg1 = view.hpImg1:GetComponent('Image')
        self.hpImg2 = view.hpImg2:GetComponent('Image')
        self.hpImg3 = view.hpImg3:GetComponent('Image')
    end
    self.onUnload = function()
        UpdateBeat:Remove(Update,self)
    end
    Create()
    return self
end

-- 主角UI
local function CreateHeroUICtrl(view)
    local self = CreateObject()
    local timer = nil
    local pkmode = ''
    local buffItems = {}
    
    local UpdateBuffItem = function(item,data)
        item:SetActive(data ~= nil)
        if data then
            local buffIcon = item.transform:FindChild('buffbox/mask/icon'):GetComponent('Image')
            --local overlay = item.transform:FindChild('buffbox/overlay'):GetComponent('Image')
            local count = item.transform:FindChild('count'):GetComponent('TextMeshProUGUI')
            --overlay.fillAmount = data.remain_time/data.last_time
            count.text = data.count
            count.gameObject:SetActive(data.count > 1)
            buffIcon.overrideSprite = ResourceManager.LoadSprite(data.Icon)
            if data.remain_time < 3 then
                if not item:GetComponent('Animation').isPlaying then
                    item:GetComponent('Animation'):Play()
                end
            else
                item:GetComponent('CanvasGroup').alpha = 1
            end
        end
    end
    
    local Update = function ()
        local hero = SceneManager.GetEntityManager().hero
        if hero then
            view.textRoleName:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.actor_name
            view.textRoleLevel:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.level
            -- view.iconCountry1:SetActive(MyHeroManager.heroData.country == 1)
            -- view.iconCountry2:SetActive(MyHeroManager.heroData.country == 2)
            view.imgRoleHp:GetComponent('RectTransform').sizeDelta = Vector2.New(hero.hp/hero.hp_max()*253,14)
            view.imgRoleMp:GetComponent('RectTransform').sizeDelta = Vector2.New(hero.mp/hero.mp_max()*226,14)
            view.imgRoleHead:GetComponent('Image').overrideSprite = LuaUIUtil.GetPuppetIcon(hero)
            
            local heroPkData = PKManager.getPkData(hero.uid)
            if heroPkData and heroPkData.pkMode ~= pkmode and heroPkData.pkMode ~= PKMode.Peace then
                view.imgPkMode:GetComponent('Image').sprite = ResourceManager.LoadSprite(LuaUIUtil.getPkModeIcon(heroPkData.pkMode))
                pkmode = heroPkData.pkMode
            end
            
            local showBuffs = {}
            for _,v in pairs(hero.skillManager.buffs) do
                if v.Icon then
                    table.insert(showBuffs,v)
                end
            end
            table.sort(showBuffs,function(a,b) return a.IconPRI > b.IconPRI end)
            for i=1,6 do
                if buffItems[i] == nil then
                    buffItems[i] = GameObject.Instantiate(view.buffItem)
                    buffItems[i].transform:SetParent(view.buffs.transform,false)
                end
                UpdateBuffItem(buffItems[i],showBuffs[i])
            end
        end
    end

    self.SetActive = function(b)
        view.role:SetActive(b)
    end
    self.onUnload = function()
        Timer.Remove(timer)
        for i=1,6 do
            if buffItems[i] ~= nil then
                GameObject.Destroy(buffItems[i])
                buffItems[i] = nil
            end
        end
    end

    local onPkModeClick = function()
        local hero = SceneManager.GetEntityManager().hero
        if hero then
            UIManager.PushView(ViewAssets.PKUI)
        end
    end

    local Create = function()        
        timer = Timer.Repeat(0.2, Update)
        view.buffItem:SetActive(false)
        ClickEventListener.Get(view.imgPkMode).onClick = onPkModeClick
        UIUtil.AddButtonEffect(view.imgPkMode, nil, nil)        
    end
    Create()
    return self
end


-- 技能面板UI
local function CreateFightUICtrl(view)
    local self = CreateObject()
	local preHeroHeight
	local currentCD = 0
	local cdTimeinfo
	
	function self.IsShowLocus()	
		local ret = false
		local hero = SceneManager.GetEntityManager().hero
		if hero and not hero:IsDied() then

			ret = hero.lowFlyManager.IsShowLocus()
		end
		
		return ret
	end
	
	self.FlyButtonGray = function(flag)	
		local hero = SceneManager.GetEntityManager().hero
		if (flag) then   --变灰
		
			local material = UIGrayMaterial.GetUIGrayMaterial()
			view.imgDodge:GetComponent("Image").material = material
			view.imgDodgeBg:GetComponent("Image").material = material
			view.circleBg:GetComponent("Image").material = material
			view.circle:GetComponent("Image").material = material
			
			if hero then
				hero.lowFlyManager.EndLowFly()
			end
		else 
		
			view.imgDodge:GetComponent("Image").material = nil
			view.imgDodgeBg:GetComponent("Image").material = nil
			view.circleBg:GetComponent("Image").material = nil
			view.circle:GetComponent("Image").material = nil
		end
	end
	
    local function CastSkill(slot_id)
        if isHeroDied() then showDieNotice(); return end
        if (self.IsShowLocus()) then
            return
        end
        local hero = SceneManager.GetEntityManager().hero
        if hero and not hero:IsDied() then
            local target = nil

            if SceneManager.GetEntityManager().hero.skillManager:IsLimitPlayerControl() then
                return 
            end
            
            if SceneManager.GetEntityManager().hero.skillManager.skills[slot_id] == nil then
                return 
            end

            local cast_target_type = SceneManager.GetEntityManager().hero.skillManager.skills[slot_id].cast_target_type
            -- 攻击敌方目标时候的判断
            if cast_target_type == CastTargetType.CAST_TARGET_UNIT then
                target = TargetManager.GetCurrentTarget()
                if not target or target:IsDied() or target:IsDestroy() then
                    target = TargetManager.GetTarget(bit:_or(EntityType.Monster, EntityType.Dummy))
                end
                if target then
                    if TeamManager.InTeam(target.uid) then
                        UIManager.ShowNotice('不能攻击队友 ')
                        return
                    elseif TargetManager.CanAttack(target) == false then
                        UIManager.ShowNotice('不能攻击该目标 ')
                        return
                    end
                end
            -- 攻击友方目标时候的判断
            elseif cast_target_type == CastTargetType.CAST_TARGET_ALLY then
                target = TargetManager.GetCurrentTarget() or SceneManager.GetEntityManager().hero
                if not TargetManager.CanHelp(target) then
                    target = SceneManager.GetEntityManager().hero
                end
            end
            --print('target', target.uid)

            local is_ok, code = SceneManager.GetEntityManager().hero.skillManager:IsSkillAvailable(slot_id)
            if not is_ok and slot_id ~= SlotIndex.Slot_Attack then
                if SceneManager.GetEntityManager().hero.skillManager.skills[slot_id].cd_left > 0.1 or 
                    code == constant.error_skill_lack_mp then
                    UIManager.ShowErrorMessage(code)
                    return 
                end
            end
            if target == nil then
                -- TODO 朝天放技能
                SceneManager.GetEntityManager().hero:CastSkillToSky(slot_id)
            else
                SceneManager.GetEntityManager().hero.target = target
                SceneManager.GetEntityManager().hero:ApproachAndCastSkill( slot_id, target)
            end
            hero:OnControl('skill')
        end
    end

    self.onSkill1Cast = function()	
        CastSkill(SlotIndex.Slot_Skill1)
    end

    self.onSkill2Cast = function()
        CastSkill(SlotIndex.Slot_Skill2)
    end
	
    self.onSkill3Cast = function()
        CastSkill(SlotIndex.Slot_Skill3)
    end
    self.onSkill4Cast = function()
        CastSkill(SlotIndex.Slot_Skill4)
    end

	local function CDUpdate()	
		currentCD = currentCD - 0.01
		if (currentCD <= 0) then
		
			currentCD = 0
			if (cdTimeinfo) then
			
				Timer.Remove(cdTimeinfo)
				cdTimeinfo = nil
			end
		end
	end

	self.ShowFlyPow = function(fillAmount)	
		view.circle:GetComponent("Image").fillAmount = fillAmount
	end

	local function ShowFlyButton()     --轻功按钮切换
		local state = 1
		local hero = SceneManager.GetEntityManager().hero
		if (hero and (hero.fightState == FightState.Fight)) then   --战斗状态下
			
			state = 2
			--hero.lowFlyManager.EndLowFly()
		end
	
		if (state == 1) then				  --轻功
		
			view.btnBlink.gameObject:SetActive(false)
			view.btnDodge.gameObject:SetActive(true)
		elseif (state == 2) then		  --瞬移
		
			view.btnBlink.gameObject:SetActive(true)
			view.btnDodge.gameObject:SetActive(false)
			
			hero.lowFlyManager.SetTeleport()
		end
	end
	
	
	self.onFlyCast = function()
        if isHeroDied() then showDieNotice(); return end
	
		local material = view.imgDodge:GetComponent("Image").material
		local hero = SceneManager.GetEntityManager().hero
		if (hero and (hero.fightState == FightState.Fight)) then   --战斗状态下
			local isShowLocus = hero.lowFlyManager.IsShowLocus()
			if isShowLocus then --当前在轻功中
				UIManager.ShowNotice('当前在轻功中，不能瞬移')
				return
			end
			
			self.FlyButtonGray(false)
			hero.lowFlyManager.OnTeleport(SlotIndex.Slot_Skill5) --瞬移
			return
		end
		
		if (material.name == "Gray") then   --说明该image变灰了，不能按
			return
		end
	
		hero.lowFlyManager.onFlyCast()
        hero:OnControl('fly')
	end
    
    local swithToMonster = function()
        if isHeroDied() then showDieNotice(); return end
        TargetManager.UpdateTarget(EntityType.Monster)
        BETween.color(view.btnmonster, 0.2,Color.gray, Color.white)
        local hero = SceneManager.GetEntityManager().hero
        hero:OnControl('switch')
    end
    
    local swithToDummy= function()
        if isHeroDied() then showDieNotice(); return end
        TargetManager.UpdateTarget(EntityType.Dummy)
        BETween.color(view.btnplayer, 0.2,Color.gray, Color.white)
        local hero = SceneManager.GetEntityManager().hero
        hero:OnControl('switch')
    end
    
    local onSwitchTarget = function(o, v )
        if v.x >= 0 and v.y>=0 then
            swithToDummy()
        elseif v.x <=0 and v.y <=0 then
            swithToMonster()
        end
    end

    local updateSkillCD = function() 
        local hero = SceneManager.GetEntityManager().hero
        if hero and (not hero:IsDied()) and view['bgcountdown1'] then
            for i = 1, 5 do
                local skill = hero.skillManager.skills[i]
                if skill and skill.cd > 0 then
                    local fillAmount = skill.cd_left/skill.cd
					local angle
                    if fillAmount > 0.001 then
                        view['bgcountdown'..i].gameObject:SetActive(true)
                        view['bgcountdown'..i].fillAmount = fillAmount
						if i == 5 then						
							angle = fillAmount * 90
						else						
							angle = fillAmount * 360
                            view['linecountdown'..i]:SetActive(true)
						end
                        view['linecountdown'..i].transform.rotation = Quaternion.AngleAxis(angle, Vector3.New(0,0,1))
                    else
                        view['bgcountdown'..i].gameObject:SetActive(false)
                        view['linecountdown'..i]:SetActive(false)
                    end
                end
            end
            self.cd_left = self.cd
			
			ShowFlyButton() --检测轻功示哪个Button
        end
    end
	
	self.onAttackButtonClick = function(eventData)
        CastSkill(SlotIndex.Slot_Attack)
        if not eventData.dragging then
        end
    end
	
    local create = function()
        ClickEventListener.Get(view.imgAttack).onClick = self.onAttackButtonClick

		ClickEventListener.Get(view.imgDodgeBg).onClick = self.onFlyCast
		ClickEventListener.Get(view.imgBlinkBg).onClick = self.onFlyCast
        ClickEventListener.Get(view.btnmonster).onClick = swithToMonster
        ClickEventListener.Get(view.btnplayer).onClick = swithToDummy
        DragEventListener.Get(view.imgAttack).onForwardDrag = onSwitchTarget  
		view.FightGroup:SetActive(true)
		self.FlyButtonGray(true)
		view.circle:GetComponent("Image").fillAmount = 1
        
        -- for i = 1, 5 do
        --     if i == 5 then -- 半环
        --         UIUtil.SetRectPivot(view['linecountdown'..i], Vector2.New(1, 0));
        --         UIUtil.SetImageFillType(view['bgcountdown'..i], 'radial90', 'bottom_right')
        --         view['linecountdown'..i]:SetActive(false)
        --         view['bgcountdown'..i]:SetActive(false)                
        --     else
        --         UIUtil.SetRectPivot(view['linecountdown'..i], Vector2.New(1, 0));
        --         UIUtil.SetImageFillType(view['bgcountdown'..i], 'radial360', 'top')
        --         view['linecountdown'..i]:SetActive(false)
        --         view['bgcountdown'..i]:SetActive(false)
        --     end
        -- end
        if not self.timerinfo then
            self.timerinfo = Timer.Repeat(0.01, updateSkillCD)
        end
        
    end
    self.SetSkillImg = function(slot_id, res)
        if slot_id >= 0 and slot_id <= 4 then
            local btn = view.imgAttack
            if slot_id == 0 then
            else
                btn = view.SpecialSkills.transform:Find('btnSkill'..slot_id..'/imgSkill').gameObject
                if res == "" or res == nil then
                    btn:SetActive(false)
                else
                    btn:SetActive(true)
                    btn:GetComponent('Image').sprite = ResourceManager.LoadSprite(res)
                end
            end
        end
    end

    self.onUnload = function()
	
		--if heroLocusTimerInfo then
		
			--Timer.Remove(heroLocusTimerInfo)
			--heroLocusTimerInfo = nil
		--end
		local hero = SceneManager.GetEntityManager().hero
		if hero and not hero:IsDied() then

			hero.lowFlyManager.CanceLocus()
		end

        if self.timerinfo then
            Timer.Remove(self.timerinfo)
            self.timerinfo = nil
        end
    end

    create()

    return self
end

local CreateCatchPetUI = function(view)
    local self = CreateObject()
	self.timer = nil

    self.ShowEffect = function(flag)    
        view.eff_commonhunting_warning:SetActive(flag)
    end
    
    self.OnCatchStampClick = function(go)    
        if isHeroDied() then showDieNotice(); return end
		local hero = SceneManager.GetEntityManager().hero
        if hero and hero.enabled then
			if hero.lowFlyManager.IsShowLocus() then
				UIManager.ShowNotice('当前正在轻功中')
				return
			end
        end
		
        ArrestPetInstance.Start()
		if ArrestPetInstance.catchPetCDCtrl then
		
			ArrestPetInstance.catchPetCDCtrl.callback = self.ShowCatchPetCD
		end
    end
	
	self.OnCatchPetCDClick = function()
	
		UIManager.ShowNotice('抓宠物技能冷却中')
	end

    --local timer = nil
    self.stopTimer = function()
        if self.timer then
            Timer.Remove(self.timer)
        end
        self.timer = nil
    end
	
	local UpdateTicks = function()
        local target = TargetManager.GetCurrentTarget()
        self.ShowEffect(target and target.entityType == EntityType.WildPet and not target:IsDied())
	end
	
    self.startTimer = function()
        self.stopTimer()
        self.timer = Timer.Repeat(0.1, UpdateTicks)
    end
	
	self.ShowCatchPetCD = function(value)
	
		local ret = true
		local catchPetCD = view.catchPetCD
		local textCatchPetCD = view.textCatchPetCD
		if value > catchPetTotalCD then
		
			value = catchPetTotalCD
			catchPetCD:SetActive(false)
			textCatchPetCD:SetActive(false)
			if not self.timer then
				self.startTimer()
			end
			ret = false
		else
		
			catchPetCD:SetActive(true)
			textCatchPetCD:SetActive(true)
			self.stopTimer()
			self.ShowEffect(false)
		end
		
		local timeLeft = catchPetTotalCD - value
		catchPetCD:GetComponent('Image').fillAmount = timeLeft / catchPetTotalCD
		textCatchPetCD:GetComponent('TextMeshProUGUI').text = math.floor(timeLeft)..'S'
		
		return ret
	end
    
    self.onLoad = function()
	
		if not self.timer then
			self.startTimer()
		end
		
        ClickEventListener.Get(view.imgStamp).onClick = self.OnCatchStampClick
		ClickEventListener.Get(view.catchPetCD).onClick = self.OnCatchPetCDClick
		view.catchPetCD:SetActive(false)
		view.textCatchPetCD:SetActive(false)
		catchPetTotalCD = commonParameterFormula.Parameter[4].Parameter
    end

    self.onUnload = function()
	
		if ArrestPetInstance.catchPetCDCtrl then
			ArrestPetInstance.catchPetCDCtrl.callback = nil
		end
        self.stopTimer()
    end
    self.onLoad()
    return self
end
--宠物管理
local CreatePetGroupUICtrl = function(view)
	local self = CreateObject()
    local pet1 = {} --两个字段，'pet'
    local pet2 = {}	--两个字段，'pet'
	local isHeroDead = false
    local timer = nil
    -- UI
    local headImg1
    local headImg2
    local hpImg1
    local hpImg2
    local stampImg1
    local stampImg2
    local text1
    local text2
    local cd1
    local cd2

    self.bindPet = function(pet)
        if pet.index == 1 then
            pet1.pet = pet
        else
            pet2.pet = pet
        end
    end

    local stopTimer = function()
        if timer then
            Timer.Remove(timer)
        end
        timer = nil
    end
	
	local SetPetIcon = function(pet, index)
		if not pet then
			return
		end
		
		if index == 1 then
			headImg1.overrideSprite = LuaUIUtil.GetPetIcon(pet.data.pet_id)
		elseif index == 2 then
			headImg2.overrideSprite = LuaUIUtil.GetPetIcon(pet.data.pet_id)
		end
	end
	
	local SetPetEffectInactive = function(index)
		view['eff_commonhunting_warningPet'..index]:SetActive(false)
	end
	
	local OnUpdateData = function(data)			--更新出站宠物
		local petOnFightData = data.pet_on_fight_entity
		if petOnFightData == nil then
			return
		end
		
		if pet1.pet then
			pet1.pet.data = nil
		end
		
		if pet2.pet then
			pet2.pet.data = nil
		end
		
		for k, v in pairs(petOnFightData) do
			local petData =  petOnFightData[k]
			if petData.fight_index == 1 then
				local pet = pet1.pet
				if pet then
					pet.data = petData
				else
					pet = {}
					pet.data = petData
					pet.isDead = true
					pet.index = 1
					pet1.pet = pet
				end
			else
				local pet = pet2.pet
				if pet then
					pet.data = petData
				else
					pet = {}
					pet.data = petData
					pet.isDead = true
					pet.index = 2
					pet2.pet = pet
				end
			end
		end
	end
	
	self.PetDieRet = function(data)			--宠物死亡推送
		local pet = pet1.pet
		if pet and pet.data and pet.data.entity_id == data.uid then
			pet.data.rebirth_time = data.rebirth_time   --复活时间
			pet.data.dead_time = data.dead_time		--死亡时间
		end

		pet = pet2.pet
		if pet and pet.data and pet.data.entity_id == data.uid then
			pet.data.rebirth_time = data.rebirth_time	--死亡时间
			pet.data.dead_time = data.dead_time		--复活时间
		end
	end
	
	self.PetRebirthRet = function(data)		--宠物复活推送
		--data.uid
	end
	
	self.onPlayerRebirth = function(data)	--英雄复活推送
		isHeroDead = false
    end
	
	self.PlayerDieRet = function(data)		--英雄死亡推送
		isHeroDead = true
	end
	
    local update = function(pet)
        local textUI = nil
        local cdUI = nil
        local hpUI = nil
        local stampUI = nil
        if pet.index == 1 then
            textUI = text1
            cdUI = cd1
            hpUI = hpImg1
            stampUI = stampImg1
			SetPetIcon(pet, 1)
        else
            textUI = text2
            cdUI = cd2
            hpUI = hpImg2
            stampUI = stampImg2
			SetPetIcon(pet, 2)
        end

        if pet:IsDied() then    --self.leftResuSeconds = self.resuSeconds
            textUI.gameObject:SetActive(true)
			local leftTime = pet.data.rebirth_time + 15 - os.time()
			if leftTime < 1 then
				leftTime = 1
			end
			
            textUI.text = math.floor(leftTime) .. 'S'
            stampUI.gameObject:SetActive(true)
            stampUI.fillAmount = leftTime / (pet.data.rebirth_time - pet.data.dead_time)
            cdUI.gameObject:SetActive(false)
            hpUI.fillAmount = 0
        else
            textUI.gameObject:SetActive(false)
            stampUI.gameObject:SetActive(false)
            for k, v in pairs(pet.skillManager.skills) do   		
                local skill = pet.skillManager.skills[k]
                if skill and skill.cd > 0 then
                    if skill:GetSkillType() ~= '1' then -- 是技能非普攻
                        local fillAmount = skill.cd_left / skill.cd
                        if fillAmount > 0.001 then                    
                            cdUI.gameObject:SetActive(true)
                            cdUI.fillAmount = fillAmount
                        else  
							if cdUI.gameObject.activeSelf then --宠物技能冷却时间结束播放提醒特效
							
								view['eff_commonhunting_warningPet'..pet.index]:SetActive(true)
								Timer.Delay(1, SetPetEffectInactive, pet.index)
							end
							
                            cdUI.gameObject:SetActive(false)
                        end
                        break
                    end
                end
            end
            hpUI.fillAmount = pet.hp/pet.hp_max()
        end
    end

    local startTimer = function()
        timer = Timer.Repeat(0.02, function()
            local currentPetNum = 0
			local pet = pet1.pet
            if not isHeroDead then
				if pet and pet.data and pet.index > 0 and not pet:IsDestroy() then
					view.Pet1:SetActive(true)
					update(pet)
				else
					view.Pet1:SetActive(false)
				end
            elseif isHeroDead then
                view.Pet1:SetActive(false)
            end
			
			pet = pet2.pet
            if not isHeroDead then
				if pet and pet.data and pet.index > 0 and not pet:IsDestroy() then
					view.Pet2:SetActive(true)
					update(pet)
				else
					view.Pet2:SetActive(false)
				end
            elseif isHeroDead then
                view.Pet2:SetActive(false)
            end
        end)
    end
	
	function IsOnAttackDistance(pet, target)
		local followDistance = GetConfig('common_fight_base').Parameter[25].Value
		local attackDistance = pet.skillManager:GetSkillDistance(SlotIndex.Slot_Skill1)
		return (Vector3.InDistance(pet.owner:GetPosition(), target:GetPosition(), (followDistance + attackDistance)))				
	end
	
	local GetPetTarget = function(pet)
		local target
		if not pet then
			return nil
		end
		
		target = pet:GetTarget()
		local owner = pet.owner
		if owner then
			--如果拥有者有目标，则把宠物的目标设为拥有者的目标
			local ownerTarget = owner:GetTarget()
			if ownerTarget then
				target = ownerTarget
			end
		end
		
		if target and not target:IsAlive() then
			target = nil
		end
		
		if target and not IsOnAttackDistance(pet, target) then
			target = nil
		end
		
		if target and owner:IsAlly(target) then
			target = nil
		end
		
		if not target then  --没有目标
			-- 设置攻击玩家的目标
			if owner and owner:GetAttacker() then
				target = owner:GetAttacker() 
			-- 设置攻击自己的目标
			elseif pet:GetAttacker() then 
				target = pet:GetAttacker()
			end
			
			if target and not target:IsAlive() then
				target = nil
			end
		
			if target and not IsOnAttackDistance(pet, target) then
				target = nil
			end
	
			if target and owner:IsAlly(target) then
				target = nil
			end
		end
		return target
	end
	
    local OnCastPetSkill = function(pet)
        if isHeroDied() then showDieNotice(); return end
        if pet and not pet:IsDied() and not pet:IsDestroy() then
			local slot_id = SlotIndex.Slot_Skill1
            pet.skillManager:ClearCommonCD() 
			
			local target = TargetManager.GetCurrentTarget() --选中的目标优先
			if target and target:IsAlive() then
				if target and not TargetManager.CanAttack(target) then
					UIManager.ShowNotice('当前选中的目标不可攻击')
					return
				elseif not IsOnAttackDistance(pet, target) then
				
					UIManager.ShowNotice('当前选中的目标距离太远')
					return	
				end
			end
		
			if not target or not target:IsAlive() then
				target = GetPetTarget(pet)
			end
			pet.target = target
							
			local is_ok, code = pet.skillManager:IsSkillAvailable(slot_id)
            if not is_ok and slot_id ~= SlotIndex.Slot_Attack then
                if pet.skillManager.skills[slot_id].cd_left > 0.1 then
                    UIManager.ShowErrorMessage(code)
                    return 
                end
            end
			
            if not target then
                pet:CastSkillToSky(slot_id)
            else
				if pet.skillManager:IsInCastRange(slot_id, target) then
					pet:StopMove()
					pet:CastSkill(slot_id, target)
				elseif not pet:IsOnApproachTarget(target) then
					pet:StopApproachTarget()
					pet:ApproachAndCastSkill(slot_id, target)
				end
            end
        end
    end
	
    local showConfirm = function(pet)  
--[[	
        local param = {}
        local ingot = BagManager.GetIngot()
        local ingotPrice = commonItem.Item[4030].IngotPrice
        if BagManager.GetItemNumberById(4030) > 0 then   --拥有复活丹
            param.msg = "是否使用重生丹立刻复活该宠物?"
            param.okHandler = function() pet:Resurrect() end
            param.okData = 1
        elseif ingot and ingot >= ingotPrice then
            param.msg = "是否花费" .. ingotPrice .. "元宝, 复活宠物"
            param.okHandler = function() pet:Resurrect() end
            param.okData = 1
        else
            param.msg = "元宝不够!请充值"
        end
        UIManager.PushView(ViewAssets.ConfirmUI).Show(param)
		]]
    end
	
    self.onLoad = function()
		headImg1 = view.imgPet1Head:GetComponent('Image')
		headImg2 = view.imgPet2Head:GetComponent('Image')
		hpImg1 = view.imgPet1Hp:GetComponent('Image')
		hpImg2 = view.imgPet2Hp:GetComponent('Image')
		stampImg1 = view.stampMask1:GetComponent('Image')
		stampImg2 = view.stampMask2:GetComponent('Image')
		text1 = view.deadDC1:GetComponent("TextMeshProUGUI")
		text2 = view.deadDC2:GetComponent("TextMeshProUGUI")
		cd1 = view.skillCDMask1:GetComponent("Image")
		cd2 = view.skillCDMask2:GetComponent("Image")
		
		MessageRPCManager.AddUser(self, 'PetDieRet')
		MessageRPCManager.AddUser(self, 'PetRebirthRet')
		MessageRPCManager.AddUser(self, 'onPlayerRebirth')
		MessageRPCManager.AddUser(self, 'PlayerDieRet')
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		
		isHeroDead = false
	
        ClickEventListener.Get(headImg1.gameObject).onClick = function()
			local pet = pet1.pet
            if pet then
                if pet:IsDied() then
                    showConfirm(pet)
                else
                    OnCastPetSkill(pet) 
                end
            end
        end
        ClickEventListener.Get(headImg2.gameObject).onClick = function()
			local pet = pet2.pet
            if pet then
                if pet:IsDied() then
                    showConfirm(pet)
                else
                    OnCastPetSkill(pet) 
                end
            end
        end

        startTimer()

        local hero = SceneManager.GetEntityManager().hero
        if hero then
			pet1.pet = nil
			pet2.pet = nil
            local pets = hero:GetPets()
			local index = 1
            for k, v in pairs(pets) do
                self.bindPet(v, index)
				index = index + 1
            end
        end
    end
    self.onUnload = function()
        stopTimer()
		isHeroDead = false
		MessageRPCManager.RemoveUser(self, 'PetDieRet')
		MessageRPCManager.RemoveUser(self, 'PetRebirthRet')
		MessageRPCManager.RemoveUser(self, 'onPlayerRebirth')
		MessageRPCManager.RemoveUser(self, 'PlayerDieRet')
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
    end
	return self
end
-- 小地图UI
local CreateMiniMapUI = function(view)
    local self = CreateObject()
    local sceneTable = require'Logic/Scheme/common_scene'
    local map = nil
    local npcFlags = {}
    local sceneData = nil
    local mapWidth = 0
    local mapHeight = 0
    local TransSceneToMap = function(posX,posZ)  
        local lengthX = sceneData.MaxX - sceneData.MinX
        local lengthZ = sceneData.MaxZ - sceneData.MinZ
        local x = (posX - sceneData.MinX)/lengthX
        local z = (posZ - sceneData.MinZ)/lengthZ
        return Vector2(mapWidth*z, mapHeight*(1-x))
    end
    
    local Update = function()
        if sceneData == nil then return end
        if not SceneManager.GetEntityManager().hero then return end
        view.dotOwn.transform.localEulerAngles = Vector3.New(0,0,-SceneManager.GetEntityManager().hero.behavior.transform.localEulerAngles.y)
        local heroPos = TransSceneToMap(SceneManager.GetEntityManager().hero.behavior.transform.localPosition.x,SceneManager.GetEntityManager().hero.behavior.transform.localPosition.z)
        self.posInfo.text = string.format('%d线(%d,%d)',SceneLineManager.curLineId,SceneManager.GetEntityManager().hero.behavior.transform.localPosition.x,SceneManager.GetEntityManager().hero.behavior.transform.localPosition.z)
        self.mapRect.anchoredPosition = Vector2(121-heroPos.x,88-heroPos.y)
    end
    
    local HideNPC = function()
        for i=#npcFlags,1,-1 do
            GameObject.Destroy(npcFlags[i])
            table.remove(npcFlags,i)
        end
        npcFlags = {}
    end
    
    local ShowNPC = function()
        HideNPC()
        local sceneObjectTable = SceneManager.GetCurSceneLayoutScheme()
        if sceneObjectTable == nil then 
            return 
        end
        for k,v in pairs(sceneObjectTable) do
            if v.MapName ~= '' then
                local npcFlag = GameObject.Instantiate(view.dotNPC)
                table.insert(npcFlags,npcFlag)  
                npcFlag:SetActive(true)
                npcFlag.transform:SetParent(map.transform,false)
                npcFlag:GetComponent('RectTransform').anchoredPosition = TransSceneToMap(v.PosX, v.PosZ)
                npcFlag:GetComponent('TextMeshProUGUI').text = (LuaUIUtil.SceneTypeToColor[v.Type] or '')..v.MapName
            end
        end
    end
    
    self.onLoad = function()
        local tb = require'Logic/Scheme/common_parameter_formula'
        map = view.mapContent:GetComponent('Image')
        sceneData = SceneManager.GetCurSceneMapData()    
        if sceneData == nil then return end
        map.overrideSprite = ResourceManager.LoadSprite('Map/'..sceneData.ResourceID)
        mapWidth = (sceneData.MaxZ - sceneData.MinZ)/(tb.Parameter[34].Parameter) * 194
        mapHeight = map.preferredHeight/map.preferredWidth*mapWidth
        self.mapRect = map:GetComponent('RectTransform')
        self.mapRect.sizeDelta = Vector2.New(mapWidth,mapHeight)
        local tableData = SceneManager.GetCurSceneData()
        view.sceneName:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(tableData,'Name')
        self.posInfo = view.posInfo:GetComponent('TextMeshProUGUI')
        UpdateBeat:Add(Update,self)
        ShowNPC()
	end
    
	self.onUnload = function()
        UpdateBeat:Remove(Update,self)
        HideNPC()
	end
    
    return self
end
local function CreatePhoneGroup(view)
    local self = CreateObject()
    local stm = networkMgr:GetConnection()
    local timer = nil

    -- local msgcount = 0
    local tick = function()
        view.textPhoneTime:GetComponent('TextMeshProUGUI').text = os.date("%H:%M")
        -- local interval = stm.pingInterval
        local delay = stm.delayTime
        local str = "" -- string.format("delay:%04d", interval) .. "|"
        if delay < 200 then
            str = str .. "<color=white>" .. delay .. "</color>"
        else
            str = str .. "<color=red>" .. delay .. "</color>"
        end
        str = str .. 'ms '
        -- str = str .. (gameMgr:GetLuaModule().recvCount - msgcount)
        -- msgcount = gameMgr:GetLuaModule().recvCount
        view.textNetDelay:GetComponent('TextMeshProUGUI').text = str
    end
    self.onLoad = function()
        if not timer then
            timer = Timer.Repeat(1, tick)
        end        
    end

    self.onUnload = function()
        if timer then
            Timer.Remove(timer)
        end
        timer = nil
    end    
    self.onLoad()
    return self
end
local function CreateMainLandUICtrl()
    local self = CreateCtrlBase();
    self.layer = LayerGroup.base
   
    local onPlayerClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.RoleUI)
    end
    
    local onMapClick = function()
        if isHeroDied() then showDieNotice(); return end
        UIManager.PushView(ViewAssets.SceneMapUI)
    end
    
    local onLineClick = function()
        UIManager.PushView(ViewAssets.SwitchChannelUI)
    end
    
    local onFriendClick = function()
        ContactManager.PushView(ViewAssets.FriendsUI)
    end

    local onChatVoiceClick = function()
        UIManager.PushView(ViewAssets.TalentUI)
    end

    local onGoldenFingerClick = function()
        UIManager.PushView(ViewAssets.GoldenFingerUI)
    end
    
    local onChatClick = function()
        UIManager.PushView(ViewAssets.ChatUI)
    end

    self.OnHook = function()
        self.view.btnAuto:GetComponent('Toggle').isOn = GlobalManager.isHook
	end
	
    self.SwitchUIState = function(self, normal)
        if self.view then
            self.view.UI:SetActive(normal)
            self.view.showBtn:SetActive(not normal)
        end
    end
    
    local old_exp = -1
    self.UpdateExpBar = function()
        self.view.expEffect:SetActive(false)
        local level_config = GetConfig('common_levels').Level[MyHeroManager.heroData.level]
        if level_config then
            local amount = MyHeroManager.heroData.exp / level_config.Exp
            self.view.imgExpFg:GetComponent('Image').fillAmount = amount
        end
        if old_exp ~= MyHeroManager.heroData.exp then
            if old_exp ~= -1 then             
                self.view.expEffect:SetActive(true)
                self.view.expEffect.transform.localPosition = Vector3.New(1626*(MyHeroManager.heroData.exp / level_config.Exp-0.5),0,0)
            end
            old_exp = MyHeroManager.heroData.exp
        end
    end
        
    local showUIBtnClick = function()
        CameraManager.CameraController:ResetPosition()
        self:SwitchUIState(true)
    end
    
    self.UpdateRedDot = function()
        if self.isLoaded then
            self.view.friendRedDot:SetActive(ChatManager.application or ChatManager.unreadMessage or ChatManager.unreadMail)
        end
    end
    
    self.RefreshChatText = function(chats)
        if not self.view then
            return
        end
        for i =1,3 do
            self.view['chatItem'..i]:SetActive(chats[i] ~= nil)
            if chats[i] then
                local chatText = self.view['chatText'..i]:GetComponent('TextMeshProUGUI')
                chatText.text = chats[i].chat
                self.view['chatChannel'..i]:GetComponent('TextMeshProUGUI').text = chats[i].channel
                local height = chatText.preferredHeight
                if height < 30 then height = 40 end
                self.view['chatItem'..i]:GetComponent('LayoutElement').preferredHeight = height
            end
        end
    end
    
    self.initUI = function() 
        local rectTran = self.view.gameObject:GetComponent("RectTransform")
        rectTran.offsetMax = Vector2.zero
        rectTran.offsetMin = Vector2.zero
        self.view.SkillSet.gameObject:SetActive(false)

        if MainDungeonManager.IsOnDungeoning() then -- RongYanfb
            ClickEventListener.Get(self.view.btnQuitFight).onClick = function()
                MainDungeonManager.RequstQuitDungeon()
            end
        elseif ArenaManager.IsOnFighting() then
            ClickEventListener.Get(self.view.btnQuitFight).onClick = function()
                ArenaManager.QuitFight()
            end
        elseif MainDungeonManager.IsOnDungeoning() then
            ClickEventListener.Get(self.view.btnQuitFight).onClick = function()
                MainDungeonManager.RequestLevelTaskDungeon()
            end
        elseif TeamDungeonManager.IsOnFighting() then
            ClickEventListener.Get(self.view.btnQuitFight).onClick = function()
                UIManager.ShowDialog("退出副本会退出队伍，并且无法继续，是否确定？",'确定','取消',TeamManager.SendLeaveTeam)
            end
        end

        CameraManager.CameraController.MainLandUI = self
        self:SwitchUIState(true)
        self.UpdateExpBar()
	end

    self.onLoad = function() 
        self.initUI()
		self.isDrag = false
        ClickEventListener.Get(self.view.imgRoleHead).onClick = onPlayerClick
        self.AddClick(self.view.campBattle,function() UIManager.PushView(ViewAssets.CampUI,function(ctrl) ctrl.OnPage(3) end) end)
        ClickEventListener.Get(self.view.mapContent).onClick = onMapClick
        --ClickEventListener.Get(self.view.mapBg).onClick = onLineClick
        ClickEventListener.Get(self.view.imgChatBg).onClick = onChatClick
        ClickEventListener.Get(self.view.btnGM).onClick = onGoldenFingerClick
        self.view.btnGM:SetActive(true)
        ClickEventListener.Get(self.view.imgShowBtn).onClick = showUIBtnClick
        ClickEventListener.Get(self.view.imgChatFriend).onClick = onFriendClick
        ClickEventListener.Get(self.view.imageChatVoice).onClick = onChatVoiceClick
        ClickEventListener.Get(self.view.buffPanelClose).onClick = function() 
            if isHeroDied() then showDieNotice(); return end
            self.buffDetailCtrl.ShowPanel(not self.view.buffDetailUI.activeSelf) 
        end
        ClickEventListener.Get(self.view.buffs).onClick = function() 
            if isHeroDied() then showDieNotice(); return end
            self.buffDetailCtrl.ShowPanel(not self.view.buffDetailUI.activeSelf) 
        end
        local luaBehavior = self.view.Rocker:GetComponent(typeof(LuaBehaviour)) --AddComponent(typeof(LuaBehaviour))
        if not luaBehavior then
            luaBehavior = UIUtil.AddLuaBehavComponent(self.view.Rocker, "UI/Joystick")
            if not CameraManager.CameraController then
                print("not found cc")
            end
            CameraManager.CameraController.Joystick = luaBehavior.luaTable
        end

        luaBehavior = self.view.UI:GetComponent(typeof(LuaBehaviour))        
        if not luaBehavior then
            luaBehavior = UIUtil.AddLuaBehavComponent(self.view.UI, "UI/TouchMove")
        end

        -- 英雄UI
        self.heroUI = CreateHeroUICtrl(self.view)
        -- 聊天面板
        self.chatUI = CreateChatCtrl(self.view)
        -- 底部菜单
        self.buttomMenu = CreateBottomMenuCtrl(self.view)
        -- 顶部菜单
        self.topMenu = CreateTopMenuCtrl(self.view)
        
        if MainDungeonManager.IsOnDungeoning() then
            self.topMenu.CollapseImmediately()
        else
            self.topMenu.ExpandImmediately()
        end
        -- 目标面板
        self.targetUI = CreateTargetUICtrl(self.view)
        -- 战斗面板
        self.fightUI = CreateFightUICtrl(self.view)
        self.UpdateSkill()
        -- 组队面板
        self.mainUITeamCtrl = CreateMainUITeamCtrl(self.view)
        -- 任务面板
        self.mainUITaskCtrl = CreateMainUITaskCtrl(self.view)

        --buff面板
        self.buffDetailCtrl = CreateBuffDetailUICtrl(self.view)
        -- 副本面板
        self.fightInfoUI = CreateMainUIFightCtrl(self.view)
        -- 时间面板
        self.phoneCtrl = CreatePhoneGroup(self.view)
        
		if not self.catchPetUI then
			self.catchPetUI = CreateCatchPetUI(self.view)
		else
			self.catchPetUI.onLoad()
		end

        if SceneManager.GetEntityManager().hero and not self.heroUI then
            self.heroUI = CreateHeroUICtrl(self.view)
        end

		if not self.petGroupUI then
		
			self.petGroupUI = CreatePetGroupUICtrl(self.view)
		end
		self.petGroupUI.onLoad()
		
        -- 主界面红点
        self.UpdateRedDot()
        self.miniMap = CreateMiniMapUI(self.view)
        self.miniMap.onLoad()
        SceneManager.AddLoginListener(self.UpdateRedDot)
        self.RefreshCampBattle()
        
	end
    
    local countDown = nil
    self.onUnload = function()
        self.buttomMenu.onUnload()
        self.topMenu.onUnload()
        self.heroUI.onUnload()
        self.targetUI.onUnload()
        self.fightInfoUI.onUnload()
		self.petGroupUI.onUnload()
        self.catchPetUI.onUnload()
        self.miniMap.onUnload()
        self.fightUI.onUnload()
        self.mainUITeamCtrl.onUnload()
        self.mainUITaskCtrl.onUnload()
        self.buffDetailCtrl.onUnload()
        self.phoneCtrl.onUnload()
        -- MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, self.UpdateRedDot)
        SceneManager.RemoveLoginListener(self.UpdateRedDot)
        if countDown then
            Timer.Remove(countDown)
        end
    end
    
    
    local campTime = GetConfig('pvp_country_war').Parameter[5].Value
    self.RefreshCampBattle = function()
        if self.isLoaded then
            if (SceneManager.currentSceneType == const.SCENE_TYPE.WILD or SceneManager.currentSceneType == const.SCENE_TYPE.CITY) and MyHeroManager.campScore then
                self.view.campBattle:SetActive(true)
                local value = 0.5
                if (MyHeroManager.campScore[1]+MyHeroManager.campScore[2]) ~= 0 then
                    value = MyHeroManager.campScore[1]/(MyHeroManager.campScore[1]+MyHeroManager.campScore[2])
                end
                self.view.textCamp1:GetComponent('TextMeshProUGUI').text = string.format('%.2f%%',value*100)
                self.view.textCamp2:GetComponent('TextMeshProUGUI').text = string.format('%.2f%%',100-value*100)
                self.view.redCampSlider:GetComponent('Slider').value = 1-value
                Timer.Remove(countDown)     
                countDown = Timer.Repeat(1,function()
                        local serverTime = networkMgr:GetConnection().ServerSecondTimestamp
                        local temp = os.date("*t", serverTime)
                        local clockTime = temp.hour*3600+temp.min *60+temp.sec
                        local endTime = campTime[4]*60 + campTime[3]*3600
                        local leftTime = endTime - clockTime 
                        self.view.campBattleTime:GetComponent('TextMeshProUGUI').text = string.format('%02d:%02d:%02d',math.floor(leftTime/3600),math.floor(leftTime/60)%60,leftTime%60)
                    end)
            else
                self.view.campBattle:SetActive(false)
            end
        end
    end
    
	local function OnUpdateSkllCurText(duration)
		self.view.SkillSet.gameObject:SetActive(true)
	  if MyHeroManager.heroData.cur_plan == 1 then
		self.view.SkillSetTxt:GetComponent('TextMeshProUGUI').text = '壹'
	  elseif MyHeroManager.heroData.cur_plan == 2 then
	    self.view.SkillSetTxt:GetComponent('TextMeshProUGUI').text = '贰'
	  elseif MyHeroManager.heroData.cur_plan == 3 then
	    self.view.SkillSetTxt:GetComponent('TextMeshProUGUI').text = '叁'
	  end
	  
	  BETween.alpha(self.view.SkillSet,duration,1,0).method = BETweenMethod.easeInOut
	end
				
    self.UpdateSkill = function()
        if self.isLoaded and self.fightUI then
           local skillsNum  = #MyHeroManager.heroData.skill_plan[MyHeroManager.heroData.cur_plan]
			if skillsNum < 1 and self.view.SpecialSkills:GetComponent('ScrollViewLoop'):GetCurrentIndex() < 1 then
				for slot_id = 1, 4 do
					self.fightUI.SetSkillImg(slot_id, "") 
				end
			end
			if MyHeroManager.heroData.cur_plan >0 then
			   self.ChangeSkillIndex(MyHeroManager.heroData.cur_plan)
			end

            --[[for k, v in pairs(SceneManager.GetEntityManager().hero.skillManager.skills) do
                self.fightUI.SetSkillImg(v.slot_id, v.Icon) 
            end--]]
        end
    end
   
    self.ChangeSkillIndex = function(index)
		local ScrollViewLoop = self.view.SpecialSkills:GetComponent('ScrollViewLoop')
		 if not self.isDrag  then
		   self.InitAllSkill()
		end

		if ScrollViewLoop:GetCurrentIndex() > 0  then
			ScrollViewLoop:SetPage(index)
		end
		self.isDrag = false
		for slot_id = 1, 4 do
		self.view['imgSkill' .. slot_id] =  ScrollViewLoop:GetItemIndex(slot_id):FindChild('imgSkill').gameObject
		self.view['bgcountdown'..slot_id] = ScrollViewLoop:GetItemIndex(slot_id):FindChild('bgcountdown'):GetComponent('Image')
		self.view['linecountdown'..slot_id] = ScrollViewLoop:GetItemIndex(slot_id):FindChild('linecountdown').gameObject
		end
		ClickEventListener.Get(self.view.imgSkill1).onClick =  function() self.fightUI.onSkill1Cast() end
		ClickEventListener.Get(self.view.imgSkill2).onClick =  function() self.fightUI.onSkill2Cast() end
		ClickEventListener.Get(self.view.imgSkill3).onClick = function() self.fightUI.onSkill3Cast() end
		ClickEventListener.Get(self.view.imgSkill4).onClick = function() self.fightUI.onSkill4Cast() end
	  end
    
	self.InitAllSkill = function()
		local ScrollViewLoop = self.view.SpecialSkills:GetComponent('ScrollViewLoop')
		ScrollViewLoop:InitAllChild()
		local skilindex = 1
		local total = 12
		local config = GetConfig("growing_skill")
		local ClonSkill = function(skilldata)
			if skilldata == nil then return end
			local skill_data = config.Skill[skilldata]
            if skill_data == nil then return end
			if skilindex == total then
			    skilindex = 0
			end
			local name = 'btnSkill'..skilindex
			local clone = self.view.SpecialSkills.transform:FindChild(name).gameObject
			local res = 'SkillIcons/'..skill_data.Icon
			clone.transform:FindChild('imgSkill'):GetComponent('Image').sprite = ResourceManager.LoadSprite(res)
			clone.transform:FindChild('imgSkill').gameObject:SetActive(true)
		
	     end
		if self.isLoaded  then
			local skills =  MyHeroManager.heroData.skill_plan
			for i=1,#skills do
				for j = 1,4 do
				    ClonSkill(skills[i][j])
					skilindex = skilindex+1
					end
				end	
			ScrollViewLoop:Init(function()
				MyHeroManager.heroData.cur_plan = ScrollViewLoop:GetCurrentIndex()
				self.isDrag = true
				UIManager.GetCtrl(ViewAssets.SkillSet).choosePresetItem(MyHeroManager.heroData.cur_plan)
				for slot_id = 1, 4 do
					self.view['imgSkill' .. slot_id] =  ScrollViewLoop:GetItemIndex(slot_id):FindChild('imgSkill').gameObject
					self.view['bgcountdown'..slot_id] = ScrollViewLoop:GetItemIndex(slot_id):FindChild('bgcountdown'):GetComponent('Image')
					self.view['linecountdown'..slot_id] = ScrollViewLoop:GetItemIndex(slot_id):FindChild('linecountdown').gameObject
				end
			    OnUpdateSkllCurText(0.8)
				ClickEventListener.Get(self.view.imgSkill1).onClick =  function() self.fightUI.onSkill1Cast() end
				ClickEventListener.Get(self.view.imgSkill2).onClick =  function() self.fightUI.onSkill2Cast() end
				ClickEventListener.Get(self.view.imgSkill3).onClick = function() self.fightUI.onSkill3Cast() end
				ClickEventListener.Get(self.view.imgSkill4).onClick = function() self.fightUI.onSkill4Cast() end
			end, function() OnUpdateSkllCurText(1.5) end)
		end
   
	end
     
	
	local function OnServerNoticeMag(data)
	
		local msgType = data.type
		if (msgType == "pet_field_unlock") then
			--{type = "pet_field_unlock", pet_uid = "宠物uid"}
			UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg("技能槽解锁")
            end)			
		elseif msgType == "pet_skill_upgrade" then
		--{type = "pet_skill_upgrade", pet_uid = "宠物uid", skill_array = “升级的技能列表”}
			UIManager.PushView(ViewAssets.PromptUI, function(ctrl)
                ctrl.UpdateMsg("宠物升级")
            end)
		end
	end

	local function Create()
	
		 MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_SERVER_INFO, OnServerNoticeMag)
	end
	
	Create()
    
    return self
end

return CreateMainLandUICtrl()