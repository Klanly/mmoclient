require "Common/basic/LuaObject"
require "Logic/Bag/QualityConst"
require "Logic/Entity/Attribute/VocationConst"

local function CreateLuaUIUtil()
    local self = CreateObject()
    local petConfig = require"Logic/Scheme/growing_pet"
    local resTable = require "Logic/Scheme/common_art_resource"
    local itemtable = require "Logic/Scheme/common_item"
    local friendsChatTable = require "Logic/Scheme/system_friends_chat"
    local systemLoginCreate = require "Logic/Scheme/system_login_create"
    local arenaScheme = GetConfig('challenge_arena')
    local skilltable = GetConfig('growing_skill')
    local dressTable = GetConfig('growing_fashion').Fashion
    local dungeonTable = GetConfig('challenge_main_dungeon')

    local const = require "Common/constant"
    local equipPart = {
        [const.equip_name_to_type.Weapon] = '武器',
        [const.equip_name_to_type.Necklace] = '项链',
        [const.equip_name_to_type.Ring] = '戒指',
        [const.equip_name_to_type.Helmet] = '头盔',
        [const.equip_name_to_type.Armor] = '胸甲',
        [const.equip_name_to_type.Belt] = '腰带',
        [const.equip_name_to_type.Legging] = '裤腿',
        [const.equip_name_to_type.Boot] = '靴子',}
    
    self.priceType = {
        [1012] = 'SliverPrice',
        [1001] = 'SliverPrice',
        [1006] = 'SilveringotPrice',
        [1002] = 'IngotPrice',
        [1011] = 'TributePrice',
        [1013] = 'FeatsPrice',
        [1007] = 'CopyPrice',
        [1005] = 'AthleticsPrice',
    }
    
    self.SceneTypeToColor = {
        [2] = '<color=#ffb40a>',
        [3] = '<color=#f93954>',
        [13] = '<color=#29c6c6>',
    }
    
    self.GetTextByID = function(data,v)
        if not data or not v then
            return ""
        end
        local text = require "Logic/Scheme/common_char_chinese"    
        if data[v] and data[v] ~= 0 then
            local tb = text.TableText[data[v]]
            if tb then
                return tb.NR or ''
            end
        end
        local str = data[v..'1']
        if str == '0' or str == nil or str == '' then
            return ''
        end
        return str
    end
    
    self.DummyNameColor = 
    {
        Green  = '#05e487',
        Darkgreen = '#ba4d2f',
        Yellow = '#FF7800',
        Red = '#f93954',
    }
    
    self.SetPicGray = function(pic,gray)
        if gray then
            pic.material = UIGrayMaterial.GetUIGrayMaterial()
        else
            pic.material = nil
        end
    end
    
    self.EquipPartName = function(key)
        return equipPart[key] or ''
    end

    self.GetTitleByFriendValue = function(value)
        local friendTb = friendsChatTable.Friendly
        local title = friendTb[#friendTb].Title
        for i=1,#friendTb do
            if value < friendTb[i].Friendly then
                title = friendTb[1].Title
            end
        end
        return title
    end
    
    self.GetFloorTableItem = function(tb,index,num)
        for i=1,#tb do
            if tb[i][index] >= num then
                return tb[i]
            end
        end
        return tb[#tb]
    end
    
    self.GetHeroModelID = function(vocation ,sex)
        local vocationSeg = 'Male'
        if sex == 2 then	
            vocationSeg = 'Female'
        end
        return systemLoginCreate.RoleModel[vocation][vocationSeg]
    end
    
    self.GetCampName = function(country)
        return self.GetTextByID(systemLoginCreate.Camp[country],'Name')
    end

    self.GetHeroIcon = function(vocation ,sex)
        local path = resTable.Model[self.GetHeroModelID(vocation or 1,sex or 1)].icon
        return ResourceManager.LoadSprite(path)
    end
    self.GetHeroImage = function(vocation ,sex)
        local path = resTable.Model[self.GetHeroModelID(vocation,sex)].Image
        return ResourceManager.LoadSprite(path)
    end

    self.GetHeroModel = function(vocation,sex,func,head,body,weapon)
        local vocationSuit = 'MaleSuit'
        if sex == 2 then
            vocationSuit = 'FemaleSuit'
        end
        path = resTable.Model[self.GetHeroModelID(vocation,sex)].Prefab
 
        if not head then  head = systemLoginCreate.RoleModel[vocation][vocationSuit][1] end
        if not body then  body = systemLoginCreate.RoleModel[vocation][vocationSuit][2] end
        if not weapon then  weapon = systemLoginCreate.RoleModel[vocation][vocationSuit][3] end
        ResourceManager.CreateCharacter(path,function(obj) 
		    local prefab =  obj
			local animation = Util.GetComponentInChildren(prefab,'Animation')
            local dress = animation.gameObject:GetComponent('Dress')
            if not dress then animation.gameObject:AddComponent(typeof(Dress)) end
            self.ChangeClothes(prefab,head,body)
            if weapon then self.ChangeWeapon(vocation,sex,prefab,weapon) end
			func(prefab)
	    end)
    end
    
    self.IsEnemyForHero = function(campType,factionID)
        if factionID then
			return MyHeroManager.heroData.faction_id ~= factionID
		end
        local heroCamp = MyHeroManager.heroData.country
        if heroCamp == campType then
            return false
        end
        if campType == nil or campType == const.CAMP_TYPE.NEUTRAL then
            return false
        end
        return true
    end
    
    self.GetCharacterModel = function(resourceID,func)
        local suitInfo = resTable.Model[resourceID].SuitID
        ResourceManager.CreateCharacter(resTable.Model[resourceID].Prefab,function(obj)
			local prefab = obj
			 if suitInfo[1] == 0 then suitInfo[1] = nil end
			 if suitInfo[2] == 0 then suitInfo[2] = nil end
			 if suitInfo[3] == 0 then suitInfo[3] = nil end
			
			 if suitInfo[1] and suitInfo[2] then
				local animation = Util.GetComponentInChildren(prefab,'Animation')
				local dress = animation.gameObject:GetComponent('Dress')
				if not dress then animation.gameObject:AddComponent(typeof(Dress)) end
				self.ChangeClothes(prefab,suitInfo[1],suitInfo[2])
				local vocation = dressTable[suitInfo[1]].Faction[1]
				local sex = dressTable[suitInfo[1]].Gender
				if suitInfo[3] then self.ChangeWeapon(vocation,sex,prefab,suitInfo[3]) end
			 end
			 if func then
				func(prefab)
			 end
			end)

    end
    
    self.ChangeClothes = function(prefab,head,body)
        local dress = Util.GetComponentInChildren(prefab,'Dress')
        if dress then
            local change = (head and dress.dressParts[0]~=dressTable[head].Prefab) or (body and dress.dressParts[1]~=dressTable[body].Prefab)
            if head then dress.dressParts[0] = dressTable[head].Prefab end
            if body then dress.dressParts[1] = dressTable[body].Prefab end
            if change then dress:Merge() end
        end
    end
    
    self.ChangeWeapon = function(vocation,sex,prefab,weapon)
        if weapon == nil then return end
        
        local dress = Util.GetComponentInChildren(prefab,'Dress')
        local weaponStrs = string.split(dressTable[weapon].Prefab,'|')
        local weaponStr = weaponStrs[sex] or weaponStrs[1]
        
        if vocation == VocationConst.BOXER then
            local change = dress.dressParts[2]~=weaponStr
            if change then 
                dress.dressParts[2] = weaponStr
                dress:Merge() 
            end
        else
            local preWeapon = dress.transform:Find('Bip001/Bip001 Prop1/weapon')
            if preWeapon then RecycleObject(preWeapon.gameObject) end
             ResourceManager.CreateCharacter(weaponStr,function(obj)
			   local weaponPrefab = obj
			   weaponPrefab.name = 'weapon'
               weaponPrefab.transform:SetParent(dress.transform:Find('Bip001/Bip001 Prop1'),false)
               weaponPrefab.transform.localPosition = Vector3.zero
               weaponPrefab.transform.localScale = Vector3.one
               weaponPrefab.transform.localRotation = Vector3.zero
			   if #dressTable[weapon].ZoomScale> 1 and weaponPrefab.transform.childCount > 0 then
			      local Scale = dressTable[weapon].ZoomScale[sex]
			      weaponPrefab.transform:GetChild(0).localScale = Vector3.New(Scale,Scale,Scale)
			   end
			end)
        end
    end
    
    self.GetPetIcon = function(petID)
        if petID then
            return ResourceManager.LoadSprite(resTable.Model[petConfig.Attribute[petID].ModelID].icon)
        end
    end
    
    self.GetPetModel = function(petID,func)      
        ResourceManager.CreateCharacter(resTable.Model[petConfig.Attribute[petID].ModelID].Prefab,func)
    end
    
    self.GetPuppetIcon = function(puppet)
        if puppet and puppet.behavior and puppet.behavior.modelId then
            return ResourceManager.LoadSprite(resTable.Model[puppet.behavior.modelId].icon)
        end
    end
    -- 半身像
    self.GetPuppetImage = function(uid)
        local puppet = SceneManager.GetEntityManager().GetPuppet(uid)
        if puppet and puppet.behavior and puppet.behavior.modelId then
            return ResourceManager.LoadSprite(resTable.Model[puppet.behavior.modelId].Image)
        end
    end
    
    self.GetPetName = function(petID)    
        if petID then
            return self.GetTextByID(petConfig.Attribute[petID],'Name')
        end
    end

    self.GetItemName = function(id)
        local itemconfig = itemtable.Item[id]
        if itemconfig == nil then
            print('item not exsit '..id)
            return
        end
        return self.GetTextByID(itemconfig,'Name')
    end
    
    self.GetSceneName = function(id)
        return self.GetTextByID(GetConfig('common_scene').MainScene[id] ,'Name')     
    end
    
    self.GetItemColorName = function(id)
        local itemconfig = itemtable.Item[id]
        return string.format('<color=%s>%s</color>',QualityConst.GetQualityColor2String(itemconfig.Quality),self.GetTextByID(itemconfig,'Name'))
    end
    
    self.GetItemIcon = function(id)
        local itemconfig = itemtable.Item[id]
        return ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
    end

    self.GetItemQuality = function(id)
        local itemconfig = itemtable.Item[id]
        return ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
    end
    
    self.CostItem = function(id, num, showUI)
        local ret = BagManager.GetItemNumberById(id) >= num
        if not ret and showUI then
            UIManager.ShowNotice(string.format("%s不足",self.GetItemName(id)))
        end
        return ret
    end
    
    self.FormatCostOwnText = function(cost,own)
        local color = 'green'
        if own < cost then color = 'red' end
        return string.format('%d/<color=%s>%d</color>',own,color,cost)
    end
    
    self.FormatCostText = function(cost,own)
        local color = 'black'
        if own < cost then color = 'red' end
        return string.format('<color=%s>%d</color>',color,cost)
    end

    -- 获取段位名称
    self.getGradeText = function(id)
        local grade = arenaScheme.QualifyingGrade[id]
        -- return {
        --  main = textScheme.TableText[grade.MainGrade],
        --  sub = textScheme.TableText[grade.SubGrade]
        -- }
        return {
            main = grade.MainGrade1,
            sub = grade.SubGrade1
        }
    end

    -- 获取职业名称
    self.getVocationName = function(vocation)
        return systemLoginCreate.RoleModel[vocation].Name1 
    end

    -- 获取职业的技能
    self.getPlayerSkills = function(vocation, level)
        local skills = {}
        for i = 1, 4 do
            local skill = table.copy(skilltable.SkillMoves[vocation * 1000 + i])            
            table.insert(skills, skill)
        end
        table.sort(skills, function(a, b)
            return a.int < b.int
        end)
        return skills
    end
    self.isSkillLock = function(skillid, level)
        return level < skilltable.SkillUnlock[tonumber(skillid)].PlayerLv
    end
    self.getSkillIcon = function(skillid)
        local skill_data = skilltable.Skill[tonumber(skillid)]
        if not skill_data then
            return 'imgskill111'
        end
        return skill_data.Icon
    end

    -- 获取购买次数所需花费
    self.getConsume = function(buycount, ty)
        local consumNum = -1
        for i = 1, #arenaScheme.PurchaseLimit do
            local v = arenaScheme.PurchaseLimit[i]
            if v.Type == ty then
                if consumNum < 0 then
                    consumNum = v.Value
                end
                if buycount >= v.Lowerlimt then
                    consumNum = v.Value
                end
            end
        end
        return consumNum
    end

    -- 获取强退混战赛惩罚数值
    self.getQuitFightPunish = function()
        local punish = {
            items = '',
            time = 0
        }
        for i, v in ipairs(arenaScheme.Parameter[43].Value) do
            if i%2 == 0 then
                local name = self.GetItemName(arenaScheme.Parameter[43].Value[i - 1])
                local num = arenaScheme.Parameter[43].Value[i]
                punish.items = punish.items .. num .. name
                if i < #arenaScheme.Parameter[43].Value then
                    punish.items = punish.items .. '和'
                end
            end
        end
        punish.time = math.floor(arenaScheme.Parameter[44].Value[1]/60) .. '分钟'
        return punish
    end

    self.getPkModeIcon = function(mode)
        if mode == PKMode.Peace then
            return ''
        elseif mode == PKMode.Contry then
            return 'Common/zhenyin'
        elseif mode == PKMode.Party then
            return 'Common/bangpai'
        elseif mode == PKMode.Killed then
            return 'Common/shalu'
        elseif mode == PKMode.GoodEvil then
            return 'Common/shane'
        end
    end

    self.getDungeonMarkByTime = function(costtime, totalTime)
        local gradeTable = dungeonTable.TranscriptMark
        local timePro = (totalTime - costtime)/totalTime
        for k, v in ipairs(gradeTable) do
            if timePro >= (v.RestTime/100) then
                return v
            end
        end
        error('没有找到副本相关的评价 costtime=' .. costtime .. ' totalTime:' .. totalTime)
    end
    self.getDungeonMarkById = function(markid)
        if markid == 1 then -- sss
            return ResourceManager.LoadSprite('AutoGenerate/MainLandUI/sss_mark')
        elseif markid == 2 then  -- Ss
            return ResourceManager.LoadSprite('AutoGenerate/MainLandUI/ss_mark')
        elseif markid == 3 then -- s
            return ResourceManager.LoadSprite('AutoGenerate/MainLandUI/s_mark')
        elseif markid == 4 then -- a
            return ResourceManager.LoadSprite('AutoGenerate/MainLandUI/a_mark')
        elseif markid == 5 then -- b
            return ResourceManager.LoadSprite('AutoGenerate/MainLandUI/b_mark')
        else
            error('没有这个mark id=' .. markid)
        end
    end
    self.getMarkData = function(markId)
        local gradeTable = dungeonTable.TranscriptMark
        for id, v in ipairs(gradeTable) do
            if id == markId then
                return v
            end
        end
        error('没有找到副本相关的评价：id=' .. markId)
    end
    return self
end

LuaUIUtil = LuaUIUtil or CreateLuaUIUtil()