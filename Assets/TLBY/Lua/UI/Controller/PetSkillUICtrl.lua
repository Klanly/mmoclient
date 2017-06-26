require "UI/Controller/LuaCtrlBase"

local function CreatePetSkillUICtrl()

    local self = CreateCtrlBase()
    self.resourceBar = {}
    local petDataList
    local petUI = nil
	local allSkillBooksDatas   --所有可能的技能书，包括拥有和未拥有的技能书
	local petData
	local selectPetIndex = 2
	local skillBooks = {}
    local itemPrefab = nil
	local selectSkillIndex = 1

	local skillBookItems           --拥有的技能书
	self.selectPos = 1
	self.itemIndex = 1
	local skillBookShowDatas = {}  --可以展现的技能书数据
	local owner
	local skill_upgrade_cost = {}
	local view = nil
	local scrolview
    
    local OnFight = function(data)
        return data.fight_index and data.fight_index > 0
    end
    
	local function SortBookShowDatas(a, b)   --对拥有技能书或则未拥有进行排序
	
		local ret = false
		if (a.count	> 0 and b.count == 0) then
		
			ret = true
		end
		
		return ret
	end
	
	local GetSkillName = function(skillType,skillID)   --获取技能或则buff名称
	
		local skillName
		if (math.floor(tonumber(skillType)) == 1) then
		
			skillName = growingSkillScheme.Skill[math.floor(tonumber(skillID))].Name1
		elseif (math.floor(tonumber(skillType)) == 2) then
		
			skillName = growingSkillScheme.Buff[math.floor(tonumber(skillID))].Name1
		end
		
		return skillName
	end
	
	local ShowEffect = function(fieldIndex)     --播放解锁技能槽以及升级，学习技能成功播放特效
	
		local sucEffect	= view["iconSkill"..fieldIndex].transform:FindChild("eff_UI@qianghua_succeed").gameObject
		sucEffect:SetActive(false)
		sucEffect:SetActive(true)
	end
	
	local function SetSkillBookShowDatas()    --设置技能书数据
	
		if (table.isEmptyOrNil(allSkillBooksDatas)) then
		
			return
		end

		skillBookShowDatas = {}
		for i = 1, #allSkillBooksDatas do
			
			skillBookShowDatas[i] = allSkillBooksDatas[i]
			skillBookShowDatas[i].count = 0
			if (not table.isEmptyOrNil(skillBookItems)) then
			
				for k, v in pairs(skillBookItems) do
		
					if (v.id == skillBookShowDatas[i].ID) then
				
						skillBookShowDatas[i].count = v.count
						break
					end
				end
			end
		end
		
		table.sort(skillBookShowDatas, SortBookShowDatas)
	end
	
	local function OnUpdateData(data)          --跟新服务端updata数据
	
		if (data.items) then
		
			skillBookItems = data.items
			SetSkillBookShowDatas()
			self.UpdateSkillBooksInfo()
		end
		
		local petList = data.pet_list
		if (petList) then
			petData = petList[selectPetIndex]
			self.RefreshSkillInfo(owner, petData, selectPetIndex)
			local pet = SceneManager.GetEntityManager().GetPuppet(petData.entity_id)
			if pet then	pet:UpdatePetSkill(petData) end 		--跟新宠物技能等级
		end
	end
	
	local function SetSkillItem(index, itemInfo)     --设置技能
	
		local skillItem = view["iconSkill"..index]
		local skillID = itemInfo[1]			
		local skillLevel = itemInfo[2]
		local skillType = itemInfo[3]
		local skill = view["iconDesign" .. index]
		local image = skill:GetComponent("Image")
		if (skillType == 1) then                      --主动技能
		
			local icon = growingSkillScheme.Skill[skillID].Icon
			image.overrideSprite = ResourceManager.LoadSprite(string.format("SkillIcons/%s", icon))
		elseif (skillType == 2) then				 --被动技能
		
			local icon = growingSkillScheme.Buff[skillID].Icon
			image.overrideSprite = ResourceManager.LoadSprite(string.format("SkillIcons/%s", icon))
		end
		skill:SetActive(true)
		
		local skillNum = view["skillNum" .. index]
		local text = skillNum:GetComponent("TextMeshProUGUI")
		text.text = "Lv." .. skillLevel
		skillNum:SetActive(true)
		
		view["iconLockDesign" .. index]:SetActive(false)
		view["iconAddDesign" .. index]:SetActive(false)
	end
	
	local function OnSkillButton(index)     --点击技能button事件
		selectSkillIndex = index
		local skillFieldNum = petData.skill_field_num
		for i = 1, skillFieldNum do
			local skillItem = view["selectIcon" .. i]
            skillItem:SetActive(i == index)
		end
        self.UpdateSkillBooksInfo()
	end
	
	local RequsteUnlockPetSKillSlot = function (index)
	
		local data = {}
		
		data.pet_index = selectPetIndex
		data.pet_uid = petData.entity_id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_PET_FIELD_UNLOCK, data)
		--owner.ShowPetModel()
	end
	
	local function OnUnLock(index)    --
	
		UIManager.PushView(ViewAssets.UnLockPetSkillTipUI,
			function(ctrl)
				local items = GrowingPet.SkillnumUnlock[index].Item
				local data = {}
				data.okHandler = RequsteUnlockPetSKillSlot
				data.title = '解锁宠物'..LuaUIUtil.GetPetName(petData.pet_id)..'第'..(petData.skill_field_num + 1)..'个技能槽?'
				data.index = index
				data.items = items
				ctrl.Show(data)
			end
		) --解锁技能槽提示
		--owner.HideModel()
    end
	
	local function UnlockMsg(data)    --解锁技能槽服务端返回
	
		if (not (data.result == 0)) then	
			UIManager.ShowErrorMessage(data.result)
			return
		end
		
		ShowEffect(data.field)
		UIManager.ShowNotice("技能槽解锁成功！")
	end
	
	local function OnSkillUpgradeMsg(data)    --升级和学习服务端返回
	
		if (not (data.result == 0)) then
            UIManager.ShowErrorMessage(data.result)
			return
		end
		
		UIManager.PushView(ViewAssets.PromptUI)
		if data.study_mode == "study" then
		
			UIManager.GetCtrl(ViewAssets.PromptUI).UpdateMsg("技能学习成功！")
		else
		
			UIManager.GetCtrl(ViewAssets.PromptUI).UpdateMsg("技能升级成功！")
		end
		
		ShowEffect(data.skill_index)
	end
	
	local RequstStudy = function()          --向服务端发送请求学习协议
	
		local data = {}
		local skillBookData = skillBookShowDatas[self.itemIndex]
		--owner.ShowPetModel()
		if (skillBookData.count == 0) then
			
			UIManager.ShowNotice("技能书数量不足")
			return
		end
			
		data.pet_index = selectPetIndex
		data.pet_uid = petData.entity_id
		data.skill_index = selectSkillIndex
		data.book_id = 	skillBookData.ID
		data.study_mode = "study"
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_PET_SKILL_UPGRADE, data)
	end
	
	local IsStudy = function(skillId)
	
		local ret = false
		local skillInfo = petData.skill_info
		for k, v in pairs(skillInfo) do
		
			if v[1] == skillId then
			
				ret = true
				break
			end
		end
		
		return ret
	end
	
	local function OnStudy()
			local skillBookData = skillBookShowDatas[self.itemIndex]
			local skillID = skillBookData.Para2
			if IsStudy(math.floor(tonumber(skillID))) then
			
				UIManager.ShowNotice("该宠物技能已学习")
				return
			end
			--owner.HideModel()
			local skillInfo = petData.skill_info
			local skilldata = skillInfo[selectSkillIndex]
			if (not skilldata) then
				
				RequstStudy()
				return
			end
			
			skillID = skilldata[1]
			skillType = skilldata[3]
			local skillLevel = skilldata[2]
			local currentSkillName = GetSkillName(skillType, skillID)
			if (not currentSkillName) then
		
				--owner.ShowPetModel()
				return
			end
			
			local changeSkillName = GetSkillName(skillType, skillID)
			if (not changeSkillName) then
				return
			end
			local str = '是否将'..currentSkillName..'Lv'..skillLevel..'替换为'..changeSkillName..'Lv1?\n本次操作不可逆转，请慎重选择'
            UIManager.ShowDialog(str,'确定','取消',RequstStudy)
	end

	local OnUpGradeHandle = function()
		local data = {}
		local skillBookData = skillBookShowDatas[self.itemIndex]
		if (skillBookData.count == 0) then

			UIManager.ShowNotice("技能书数量不足")
			return
		end

		data.pet_index = selectPetIndex
		data.pet_uid = petData.entity_id
		data.skill_index = selectSkillIndex
		data.book_id = skillBookData.ID
		data.study_mode = "upgrade"
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_PET_SKILL_UPGRADE, data)
	end

	local function OnUpGrade()

			local skillBookData = skillBookShowDatas[self.itemIndex]
			if (skillBookData.count == 0) then
				UIManager.ShowNotice("技能书数量不足")
				return
			end
			if BagManager.CheckItemIsEnough(skill_upgrade_cost) == false then
				return
			end
			BagManager.CheckBindCoinIsEnough(skill_upgrade_cost,OnUpGradeHandle)

	end
	
	local function ShowSkillInfo(data)    
	
		local skillInfo = data.skill_info
		local skillFieldNum = data.skill_field_num
		for i = 1, skillFieldNum do
		
			view["iconSkill"..i]:SetActive(true)
			view["skillNum" .. i]:SetActive(false)
			view["iconDesign" .. i]:SetActive(false)
			view["iconLockDesign" .. i]:SetActive(false)
			view["iconAddDesign" .. i]:SetActive(true)
		end
		
		view["selectIcon" .. selectSkillIndex]:SetActive(true)
		
		for k, v in pairs(skillInfo) do
		
			SetSkillItem(k, v)
		end
	end
	
	local function OnLongPress(i)
	
		local skillInfo = petData.skill_info
		local skilldata = skillInfo[i]
		if (skilldata) then
		
			local skillID = skilldata[1]			
			local skillLevel = skilldata[2]
			local skillType = skilldata[3]
			--UIManager.PushView(ViewAssets.CampTitle)\			local description
			if skillType == 1 then
				description = SkillAPI.GetSkillDescription(skillID, skillLevel)
			elseif skillType == 2 then
				description = SkillAPI.GetBuffDescription(skillID, skillLevel)
			end
			
			if description == nil then
				return
			end
			
			local commTextTipUICtrl = UIManager.PushView(ViewAssets.CommTextTipUI)
			-- if (skillType == 1) then --主动技能
			
				-- commTextTipUICtrl.SetData(growingSkillScheme.Skill[skillID].Description1)

			-- elseif skillType == 2 then --被动技能
			
				-- commTextTipUICtrl.SetData(growingSkillScheme.Buff[skillID].Description1)
			-- end
            commTextTipUICtrl.SetData(description)
			commTextTipUICtrl.SetPosition(view["iconDesign"..i].transform.position)
			
		end
	end
	
	local ShowConstText = function(constId, num)
		view.iconsilver2:GetComponent('Image').overrideSprite = LuaUIUtil.GetItemIcon(constId)
		view.textscore2:GetComponent("TextMeshProUGUI").text = num
	end
	
	local GetNeedSkillBookNum = function(itemData)    --获取学习或则升级技能需要消耗数目
	
		local num = 0
		local isOwnerItem = false
		local skillInfo = petData.skill_info
		local skillLevel = 0
		local selectSkillBook = skillBookShowDatas[itemData.itemIndex]
		local selectSkillID = math.floor(tonumber(selectSkillBook.Para2))
		for i = 1, #skillInfo do
		
			local skilldata = skillInfo[i]
			if (skilldata) then
		
				local skillID = skilldata[1]
				if (selectSkillID == skillID) then
				
					skillLevel = skilldata[2]
					isOwnerItem = true
					break
				end
			end
		end

		local skill_up_config = GrowingPet.Skillup[skillLevel + 1]
		if skill_up_config == nil then --该技能已经是最大等级
			num = 0
			local cost = GrowingPet.Skillup[1].cost   --获取消耗品ID，数量应该为0，因为该技能最大级，不需要任何消耗品
			ShowConstText(cost[1], 0)
			table.insert(skill_upgrade_cost,{cost[1], 0})
		else
			num = GrowingPet.Skillup[skillLevel + 1].SkillBook		--返回的消耗数量，学习和升级都是根据技能等级来
			local cost = GrowingPet.Skillup[skillLevel + 1].cost
			ShowConstText(cost[1], cost[2])
			table.insert(skill_upgrade_cost,table.copy(GrowingPet.Skillup[skillLevel + 1].cost))
		end
		
		return num
	end
	
	local RetSelectItem = function(data)

		self.selectPos = data.pos
		self.itemIndex = data.itemIndex
		self.UpdateSkillBooksInfo()
	end
    
    local SortPetData = function(a,b)
        local aFightValue = 0
        local bFightValue = 0
        if a.fight_index and a.fight_index > 0  then aFightValue = 1 end
        if b.fight_index and b.fight_index > 0 then bFightValue = 1 end
        if aFightValue ~= bFightValue then return aFightValue > bFightValue end
        return a.pet_score > b.pet_score
    end
	
	function self.UpdateSkillBooksInfo()     --跟新技能书显示
        --if (not itemPrefab) then
			--itemPrefab = ResourceManager.CreateUI("Common/ItemUI")
			--itemPrefab.transform:SetParent(nil,false)
		--end
		local currentMaxBagItemCount = #skillBookShowDatas
		local skillInfo = petData.skill_info
		local skillID = skillInfo[1][1]
		local data = {}
		local posIndex = 1
		for i = 1, currentMaxBagItemCount do
		
			while true do
			
				local skillBookData = skillBookShowDatas[i]
				if ((math.floor(tonumber(skillBookData.Para1)) == 1) and
					(math.floor(tonumber(skillBookData.Para2)) ~= skillID) ) then			--不是自己的主动技能
			
					break
				end
			
				local id = skillBookData.ID
				local count = skillBookData.count
				local selectFlag = false
				if (i == self.itemIndex) then
			
					selectFlag = true
				end
				
				local itemData = { pos = posIndex, itemIndex = i, count = count, id = id, unlock = currentMaxBagItemCount, sell = false, select = selectFlag, isNeedNum = true,  GetNeedNum = GetNeedSkillBookNum, ClickHandle = RetSelectItem}
				table.insert(data, itemData)
				posIndex = posIndex + 1
				break
			end
		end
		
        local function itemUpdate(itemGo,index)
            itemGo:GetComponent("LuaBehaviour").luaTable.SetData(data[index + 1])
        end
		
		local bookDesText = view.textskillbooksmessage:GetComponent("TextMeshProUGUI")
		bookDesText.text = skillBookShowDatas[self.itemIndex].Description1   --描述
		
		local bookNameText = view.textlevel1book:GetComponent("TextMeshProUGUI")
		bookNameText.text = skillBookShowDatas[self.itemIndex].Name1         --名字

        --local scv = view.SkillBooksScrollView:GetComponent(typeof(UIMultiScroller))
        --if scv then
            --scv:Init(view.SkillItemUI, itemWidth, itemHeight, itemPadding, viewCount, maxPerline)    
            scrolview:UpdateData(posIndex - 1, itemUpdate)
        --end
        
        local same = petData.skill_info[selectSkillIndex] and skillBookShowDatas[self.itemIndex] and tonumber(skillBookShowDatas[self.itemIndex].Para2) == petData.skill_info[selectSkillIndex][1]
        view.btnstudy:SetActive(not same)
        view.btnupgrade:SetActive(same)
	end
    
    local UpdatePetItem = function(item,index) 
        local key = index + 1
        if petDataList[key] == nil then 
            item:SetActive(false) 
            return 
        else 
            item:SetActive(true) 
        end
        local data = petDataList[key]

        local onFightFlag = item.transform:FindChild("onFight").gameObject
        onFightFlag:SetActive(OnFight(data))
        local name = item.transform:FindChild("name").gameObject:GetComponent("TextMeshProUGUI")
        name.text = LuaUIUtil.GetPetName(data.pet_id)
        local starLv = item.transform:FindChild("star").gameObject:GetComponent("TextMeshProUGUI")
        starLv.text = data.pet_star
        local petLv = item.transform:FindChild("level").gameObject:GetComponent("TextMeshProUGUI")
        petLv.text = data.pet_level or 1
        local icon = item.transform:FindChild("mask/icon"):GetComponent("Image")
        icon.overrideSprite = LuaUIUtil.GetPetIcon(data.pet_id)
        
        local bg = item.transform:Find("bg").gameObject
        bg:GetComponent('Toggle').isOn = data == petUI.selectPetData
        item.transform:Find("light"):GetComponent('Image').color = Color.New(1,1,1,1)
        item.transform:Find("dark").gameObject:SetActive(false)
        local mainPet = item.transform:Find("mainPet").gameObject
        local vicePet = item.transform:Find("vicePet").gameObject
        mainPet:SetActive(false)
        vicePet:SetActive(false)
        self.AddClick(bg, function() selectSkillIndex = 1 self.RefreshSkillInfo(self, data, data.index) end)
    end
    
	function self.onLoad()
        view = self.view
        for i = 1, 8 do
            ClickEventListener.Get(view["iconDesign"..i]).onClick = function() OnSkillButton(i) end
			LongPressEventListener.Get(view["iconDesign"..i]).onLongPress = function () OnLongPress(i) end
			ClickEventListener.Get(view["iconLockDesign"..i]).onClick = function () OnUnLock(i)  end
			ClickEventListener.Get(view["iconAddDesign"..i]).onClick = function () OnSkillButton(i)  end
        end
		
		ClickEventListener.Get(view["btnstudy"]).onClick = OnStudy
		ClickEventListener.Get(view["btnupgrade"]).onClick = OnUpGrade
		--ClickEventListener.Get(view["btnreturn"]).onClick = OnBookPageReturn
		petDataList = {}
		allSkillBooksDatas = {}
		
		local itemWidth = 175
        local itemHeight = 155
        local itemPadding = 0
        local maxPerline = 4
		local viewCount = 5
		scrolview = view.SkillBooksScrollView:GetComponent(typeof(UIMultiScroller))
        if scrolview then
            scrolview:Init(view.SkillItemUI, itemWidth, itemHeight, itemPadding, viewCount, maxPerline)    
        end
		
		local items = commonItem.Item
		for k, v in pairs(items) do
		
			if v.Type == 106 then    --该类型表示是技能
			
				table.insert(allSkillBooksDatas, v)
			end
		end
        for i = 1, 8 do	
			local sucEffect	= view["iconSkill"..i].transform:FindChild("eff_UI@qianghua_succeed").gameObject
			sucEffect:SetActive(false)
		end
		SetSkillBookShowDatas()       
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_PET_FIELD_UNLOCK, UnlockMsg)
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		MessageManager.RegisterMessage(constant.SC_MESSAGE_LUA_PET_SKILL_UPGRADE, OnSkillUpgradeMsg)
        petUI = UIManager.GetCtrl(ViewAssets.PetUI)
        
        petDataList = {}
        for i=1,#MyHeroManager.heroData.pet_list do
            local data = MyHeroManager.heroData.pet_list[i]
            data.index = i
            if petUI.selectPetData and petUI.selectPetData.entity_id == data.entity_id then petUI.selectPetData = data end        
            table.insert(petDataList,data)
		end
        table.sort(petDataList,SortPetData)
        if petUI.selectPetData == nil then
            petUI.selectPetData = petDataList[1]
        end
        petUI.UpdatePetList(#petDataList,UpdatePetItem)
        self.RefreshSkillInfo(self, petUI.selectPetData, petUI.selectPetData.index)
	end
	
	function self.onUnload()
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_PET_FIELD_UNLOCK, UnlockMsg)
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
		MessageManager.UnregisterMessage(constant.SC_MESSAGE_LUA_PET_SKILL_UPGRADE, OnSkillUpgradeMsg)
        if showTimer then
            Timer.Remove(showTimer)
            showTimer = nil
        end
		petDataList = nil
		allSkillBooksDatas = nil
	end
	
	function self.RefreshSkillInfo(ownerObject, data, selectIndex)
		
		if (ownerObject) then
		
			owner = ownerObject
		end
		
		petData = data
		selectPetIndex = selectIndex
		skillBookItems = MyHeroManager.heroData.items
		SetSkillBookShowDatas()
		
		for i = 1, 8 do
			view["iconDesign" .. i]:SetActive(false)
			view["iconLockDesign" .. i]:SetActive(true)
			view["iconAddDesign" .. i]:SetActive(false)
			view["selectIcon" .. i]:SetActive(false)
			view["skillNum" .. i]:SetActive(false)
		end
		ShowSkillInfo(data)
        OnSkillButton(selectSkillIndex)
	end
	
	return self
end

return CreatePetSkillUICtrl()