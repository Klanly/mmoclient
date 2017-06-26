--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/10 0010
-- Time: 14:01
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateMyHeroManager()
    local self = CreateObject()
    self.heroData = nil
    self.clientServerTimeDelta = 0

    local function OnReceiveSkillUpgradeResult(data)
    	if data.result == 0 then
    		print('升级成功')
            UIManager.GetCtrl(ViewAssets.SkillSet).OnSkillUpgrade()
    	else
    		print('升级失败:', data.result)
            if data.result ~= CommonDefine.error_item_not_enough then
                UIManager.ShowNotice(MSG_ERROR[data.result])
            else
                local item_config = require "Logic/Scheme/common_item"
                local text = item_config.Item[data.items_lack[1]].Name1
                UIManager.ShowNotice( text .. '不足' )
            end
    	end
    end

    local function OnPlanChangeResult(data)
    	if data.result == 0 then
    		print('切换方案成功')
    	else
    		print('切换方案失败:', data.result)
            UIManager.ShowNotice(MSG_ERROR[data.result])
    	end
    end

    local function OnReceiveSkillChange(data)
        if data.result == 0 then
            print('更换技能成功')
        else
            print('更换技能失败:', data.result)
            UIManager.ShowNotice(MSG_ERROR[data.result])
        end
    end

    -- 英雄登录数据
    local function OnLogin(data)
        if data.result == 0 then    
            if data.login_data and data.login_data.property and data.login_data.property[14] then
                data.login_data.property[14] = data.login_data.property[14]
            end
            if data.login_data and data.login_data.server_time then
                local clientTime = networkMgr:GetConnection():GetSecondTimestamp()
                self.clientServerTimeDelta = data.login_data.server_time - clientTime
            end
            self.heroData = data.login_data
        else
            UIManager.ShowErrorMessage(data.result)
        end
    end

    -- 英雄数据更新（增量更新）
    local oldLevel = -1
    local function OnUpdateData(data) 
        -- if data.result == 0 then    --update消息里没有result
        if data and data.property and data.property[14] then
            data.property[14] = data.property[14]
        end
            if self.heroData then 
                table.update(self.heroData, data)
            end
            if oldLevel == -1 and self.heroData then
                oldLevel = self.heroData.level
            end
            if SceneManager.GetEntityManager().hero then                                   --更新英雄属性
                SceneManager.GetEntityManager().hero:RefreshSkills()

                if self.heroData.level > oldLevel then
                    SceneManager.GetEntityManager().hero:OnLevelUp()
                end
            end
            if self.heroData then
                oldLevel = self.heroData.level
            end
            if self.heroData and data.pet_list then 
                local petDetailUI = UIManager.GetCtrl(ViewAssets.PetDetailUI)
                if petDetailUI.isLoaded then petDetailUI.HandleOnFight(data) end
            end
            if data.exp then 
                local mainLandUI = UIManager.GetCtrl(ViewAssets.MainLandUI)
                if mainLandUI.isLoaded then mainLandUI.UpdateExpBar() end
            end
            -- 宠物出战更新
            -- if self.heroData and ( data.pet_list or data.pet_on_fight) then
            --     for k, v in pairs(self.heroData.pet_list)do
            --         if v.fight_index and v.fight_index > 0 then
            --             if SceneManager.GetEntityManager().hero then
            --                 SceneManager.GetEntityManager().CreatePet(v)
            --             end
            --         else
            --             SceneManager.GetEntityManager().DestroyPuppet(v.entity_id)
            --         end
            --     end
            -- end
    end
 
    self.Init = function()
        self.CampSore = nil
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_SKILL_UPGRADE, OnReceiveSkillUpgradeResult)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_PLAN_SWITCH, OnPlanChangeResult)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_SKILL_CHANGE, OnReceiveSkillChange)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, OnLogin)        
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)

        MessageRPCManager.AddUser(self, 'GetFightDataStatisticsRet')
        MessageRPCManager.AddUser(self, 'GetActivityInfoRet')
        MessageRPCManager.AddUser(self, 'OpenActivityBoxRet')
		MessageRPCManager.AddUser(self, 'MoveToAppointPos')
		MessageRPCManager.AddUser(self, 'GetFashionRet')
		MessageRPCManager.AddUser(self, 'ChangeFashionRet')
        MessageRPCManager.AddUser(self,'FightServerDisconnetRet')
        MessageRPCManager.AddUser(self,'CountryWarEnd')
        MessageRPCManager.AddUser(self,'SyncCountryWarInfo')
    end

    self.UpgradeSkill = function(slot_id)
    	MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_SKILL_UPGRADE , {place = slot_id})
	end

	self.ChangeSkill = function(slot_id, skill_id, plan_index)
	    print('ChangeSkill', slot_id, skill_id, plan_index)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_SKILL_CHANGE , 
			{
			place = slot_id,
			skill_id = skill_id,
			plan_index = plan_index,
			})
	end

    -- self.CS_CastSkill = function(slot_id, target_entity_id)
    --     MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_CAST_SKILL, 
    --         {
    --             entity_id = SceneManager.GetEntityManager().hero.uid,
    --             slot_id = slot_id,
    --             target_entity_id = target_entity_id,
    --         })
    -- end

	self.ChangeSkillPlan = function(plan_index)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_PLAN_SWITCH, {plan_index = plan_index})
	end

    self.RequestFightDataStatistics = function()
        local data = {}
        data.func_name = 'on_get_fight_data_statistics'
        MessageManager.RequestLua(SceneManager.GetRPCMSGCode(), data)
    end

    self.ResetFightDataStatistics = function()
        local data = {}
        data.func_name = 'on_reset_fight_data_statistics'
        MessageManager.RequestLua(SceneManager.GetRPCMSGCode(), data)
    end

    self.GetFightDataStatisticsRet = function(data)
        UIManager.GetCtrl(ViewAssets.FightStatisUI).PassData(data)
    end

    -- 日常活动
    self.RequestActivityInfo = function()
        local data = {}
        data.func_name = 'on_get_activity_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end

    self.GetActivityInfoRet = function(data)
        UIManager.GetCtrl(ViewAssets.DailyTask).PassData(data)
        if UIManager.GetCtrl(ViewAssets.DailyTaskTip2) then
            UIManager.GetCtrl(ViewAssets.DailyTaskTip2).PassData(data)
        end
        
    end

    self.RequestOpenBox = function(box_id)
        local data = {}
        data.func_name = 'on_open_activity_box'
        data.box_id = box_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end

    self.OpenActivityBoxRet = function(data)
        log('msg', table.toString(data, 'OpenActivityBoxRet'))
    end
	
	 self.RequestGetFashion = function()
        local data = {}
        data.func_name = 'on_get_fashion'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
	
	self.GetFashionRet = function(data)
		if UIManager.GetCtrl(ViewAssets.RoleappearanceUI).isLoaded then
		   UIManager.GetCtrl(ViewAssets.RoleappearanceUI).InitFashionData(data)
		end
	end
	
	self.ChangeFashionRet = function(data)
		local herobehavior = SceneManager.GetEntityManager().hero.behavior
		local HeadFashionId = data.appearance[constant.TYPE_HEAD_FASHION]
		local ClothFashionId  = data.appearance[constant.TYPE_CLOTH_FASHION]
        LuaUIUtil.ChangeClothes(herobehavior.gameObject,HeadFashionId,ClothFashionId)
		if UIManager.GetCtrl(ViewAssets.RoleUI).isLoaded and UIManager.GetCtrl(ViewAssets.BagUI).isLoaded then
            UIManager.ShowDialog(texttable.UIText[1135031].NR, texttable.UIText[1101006].NR, texttable.UIText[1101007].NR, function()
			   UIManager.UnloadView(ViewAssets.BagUI)
               UIManager.UnloadView(ViewAssets.RoleUI)
			   UIManager.PushView(ViewAssets.RoleappearanceUI)
		       UIManager.GetCtrl(ViewAssets.RoleappearanceUI).preAssetUI = ViewAssets.RoleUI
			end ,nil)
        end
		self.GetFashionRet(data)
	end
	
	self.MoveToAppointPos = function(data)
		local hero = SceneManager.GetEntityManager().hero
		if not hero then
			return
		end
		
		if hero.lowFlyManager.IsShowLocus() then
			hero.lowFlyManager.CanceLocus()
		end

		local pos = data.pos
		local heroPos = Vector3.New(pos[1] / 100, pos[2] / 100, pos[3] / 100)
		 --此位置可能不在navmash上，所以需要先设navmash为false
        hero:StopMoveImmediately()
        hero.commandManager.Clear()
		hero:SetPosition(heroPos)
		local pets = hero:GetPets()
		for k, v in pairs(pets) do
			v:StopMoveImmediately()
			v.commandManager.Clear()
			local calculatePosition = v:CalculatePosition(heroPos)
			v:SetPosition(v:CalculatePosition(heroPos))
		end
	end

    self.FightServerDisconnetRet = function(data)
        UIManager.ShowTopNotice(texttable.UIText[1114107].NR)
    end
    
    self.campScore = nil
    
    self.SyncCountryWarInfo = function(data)
        if data.country_total_score then
            self.campScore = data.country_total_score
            UIManager.GetCtrl(ViewAssets.MainLandUI).RefreshCampBattle()
        end
    end
    
    self.CountryWarEnd = function(data)
        self.campScore = nil
        UIManager.GetCtrl(ViewAssets.MainLandUI).RefreshCampBattle()
        UIManager.PushView(ViewAssets.CampBattleScoreUI,nil,data)
    end

    self.Init()

    return self
end

MyHeroManager = MyHeroManager or CreateMyHeroManager()

