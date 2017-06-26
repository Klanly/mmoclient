---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/5
-- desc： 战斗设置
---------------------------------------------------
local skilltable = GetConfig('growing_skill')
local maxSelectPetNum = 2
local function CreateArenaPetSettingCtrl()
	local self = CreateCtrlBase()

	-------------- pet list ------------
	local selectPetItems = {}
	self.selectPetUID = nil

	local updatePetItem = function(go, data)
		local headimg = go.transform:FindChild('petHeadImg').gameObject:GetComponent('Image')
		local nametxt = go.transform:FindChild('@textpetname').gameObject:GetComponent('TextMeshProUGUI')
		local startxt = go.transform:FindChild('@textStarlv').gameObject:GetComponent('TextMeshProUGUI')

		nametxt.text = LuaUIUtil.GetPetName(data.pet_id)
		headimg.sprite = LuaUIUtil.GetPetIcon(data.pet_id)
		startxt.text = '星:' .. data.pet_star
	end
	local getPetData = function(uid)
		for k, v in pairs(MyHeroManager.heroData.pet_list)do
			if v.entity_id == uid then
				return v
			end
		end
	end
	local updateSelectPetItems = function()
		for k, v in ipairs(selectPetItems) do
			DestroyScrollviewItem(v)
		end
		selectPetItems = {}

		for k, v in ipairs(self.selectPetUID) do
			local data = getPetData(v)
			if data then
				local item = CreateScrollviewItem(self.view.selectPetItem1)
				table.insert(selectPetItems, item)

				updatePetItem(item.gameObject, data)
			else
				print('error! not found pet uid=' .. v)
			end
		end
	end
	-- select index
	local removeSelectPet = function(data)
		local delete = -1
		for i, v in ipairs(self.selectPetUID) do
			if v == data.entity_id then
				delete = i
				break
			end
		end
		if delete > 0 then
			table.remove(self.selectPetUID, delete)
		end
	end
	local addSelectPet = function(data)
		--
		table.insert(self.selectPetUID, data.entity_id)
	end
	local isSelectPet = function(data)
		for k, v in pairs(self.selectPetUID) do
			if v == data.entity_id then
				return true
			end
		end
		return false
	end

	local onSelectPetItem = function(go, data)
		if isSelectPet(data) then
			go.transform:FindChild('partselect1').gameObject:SetActive(false)
			removeSelectPet(data)
		else
			if #self.selectPetUID >= 2 then
				UIManager.ShowNotice('已经选满2个宠物了')
				-- print('已经选满' .. maxSelectPetNum .. '个宠物了')
				return
			end
			go.transform:FindChild('partselect1').gameObject:SetActive(true)
			addSelectPet(data)
		end
		updateSelectPetItems()
	end

	local onItemUpdate = function(go, index)
		index = index + 1
		local petimg = go.transform:FindChild('petHeadImg').gameObject

		local data = MyHeroManager.heroData.pet_list[index]
		updatePetItem(go, data)

		ClickEventListener.Get(petimg).onClick = function() 
			onSelectPetItem(go, data) 
		end

		if isSelectPet(data) then
			go.transform:FindChild('partselect1').gameObject:SetActive(true)
		else
			go.transform:FindChild('partselect1').gameObject:SetActive(false)
		end
	end

	local initPetList = function()
		if MyHeroManager.heroData.pet_list then
			self.scrollview:UpdateData(#MyHeroManager.heroData.pet_list, onItemUpdate)
			updateSelectPetItems()
		end
	end

	--------------- sub skill ---------------
	local selectSkillItem = nil -- skill item
	local subSkillItems = {}
	local selectSubSkillItem = nil
	local onSelectSubItem = nil
	self.selectSubSkillId = nil
	local initSubSkillGroup = function(skill)
		for k, v in ipairs(subSkillItems) do
			DestroyScrollviewItem(v)
		end
		subSkillItems = {}

		self.view.skillpartgroup:SetActive(true)
		selectSubSkillItem = nil
		for k, v in ipairs(skill.SkillID) do 
			local item = CreateScrollviewItem(self.view.skillpartitem)
			table.insert(subSkillItems, item)

			local textName = item.transform:FindChild('@partname1'):GetComponent('TextMeshProUGUI')			
			textName.text = skilltable.Skill[v] and skilltable.Skill[v].Name1 or '无名'

			local skillImg = item.transform:FindChild('@partimg1'):GetComponent('Image')
			skillImg.sprite = ResourceManager.LoadSprite('SkillIcons/'..LuaUIUtil.getSkillIcon(v))

			if self.selectSubSkillId[skill.int] == v then
				item.transform:FindChild('partselect1').gameObject:SetActive(true)
			else
				item.transform:FindChild('partselect1').gameObject:SetActive(false)
			end
			if LuaUIUtil.isSkillLock(v, MyHeroManager.heroData.level) then
				skillImg.material = UIGrayMaterial.GetUIGrayMaterial()
				ClickEventListener.Get(skillImg.gameObject).onClick = nil
			else
				skillImg.material = nil
				ClickEventListener.Get(skillImg.gameObject).onClick = function()
					-- onSelectSubItem(skill.int, v)
					if selectSubSkillItem then
						selectSubSkillItem.transform:FindChild('partselect1').gameObject:SetActive(false)
					end
					selectSubSkillItem = item
					selectSubSkillItem.transform:FindChild('partselect1').gameObject:SetActive(true)
					self.selectSubSkillId[skill.int] = v
					self.view.skillpartgroup:SetActive(false)

					local skillObj = selectSkillItem.transform:FindChild('@skillimg1').gameObject
					skillObj:GetComponent('Image').sprite = skillImg.sprite
				end
			end
		end
		self.view.textframeskilltitle:GetComponent('TextMeshProUGUI').text = tableText(skill.Name)
	end
	
	---------------- skill -----------------
	local skillItems = {}
	local onSelectSkillItem = nil
	local initSkillGroup = function()
		for k, v in ipairs(skillItems) do
			DestroyScrollviewItem(v)
		end
		skillItems = {}

		local skills = LuaUIUtil.getPlayerSkills(MyHeroManager.heroData.vocation)
		for k, v in ipairs(skills) do
			local item = CreateScrollviewItem(self.view.skillItem)
			table.insert(skillItems, item)

			local textName = item.transform:FindChild('@textSkillname1'):GetComponent('TextMeshProUGUI')
			textName.text = tableText(v.Name)

			local skillImg = item.transform:FindChild('@skillimg1'):GetComponent('Image')
			if self.selectSubSkillId[v.int] then
				skillImg.sprite = ResourceManager.LoadSprite('SkillIcons/'..LuaUIUtil.getSkillIcon(self.selectSubSkillId[v.int]))
			else
				skillImg.sprite = ResourceManager.LoadSprite('Common/buttons/com_btnitem')
			end

			ClickEventListener.Get(skillImg.gameObject).onClick = function()
				onSelectSkillItem(k, v)
			end
		end
	end
	onSelectSkillItem = function(index, skill)
		-- if selectSkillItem then
		-- 	selectSkillItem.transform:FindChild('partselect1').gameObject:SetActive(false)
		-- end
		selectSkillItem = skillItems[index]
		-- selectSkillItem.transform:FindChild('partselect1').gameObject:SetActive(true)
		initSubSkillGroup(skill)
	end

	-------------------------------------
	local onOkClick = function()
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_ARENA_PET_SETTING, {
			defend_pet = self.selectPetUID,
			arena_defend_skill = self.selectSubSkillId
		})
	end
	local OnOK = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		self.close()
	end
	
	local closeClick = function()
		self.close()
	end
	
	self.onLoad = function(arenaData)
		self.arenaData = arenaData or self.arenaData
		self.selectSubSkillId = {}
		if self.arenaData.arena_info.arena_defend_skill then
			self.selectSubSkillId = table.copy(self.arenaData.arena_info.arena_defend_skill)
		end
		self.selectPetUID = {}
		if self.arenaData.arena_info.defend_pet then
			self.selectPetUID = table.copy(self.arenaData.arena_info.defend_pet)
		end
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_ARENA_PET_SETTING, OnOK)

		ClickEventListener.Get(self.view.btnclose2).onClick = closeClick
        UIUtil.AddButtonEffect(self.view.btnclose2, nil, nil)

		ClickEventListener.Get(self.view.btnok).onClick = onOkClick
        UIUtil.AddButtonEffect(self.view.btnok, nil, nil)

        self.scrollview = self.view.petlistgroupsv:GetComponent(typeof(UIMultiScroller))
		self.scrollview:Init(self.view.optionPetItem, 160, 160, 15, 4, 3)
		self.view.optionPetItem:SetActive(false)
		initPetList()
		initSkillGroup()
	end
	
	self.onUnload = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_ARENA_PET_SETTING, OnOK)
		self.view.skillpartgroup:SetActive(false)
		self.selectSubSkillId = {}
	end
	
	self.onActive = function()
	end

	self.onDeactive = function()
	end

	return self
end

return CreateArenaPetSettingCtrl()