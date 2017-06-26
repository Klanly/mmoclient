-- auth： zhangzeng
-- date： 2017/6/5
require "UI/View/LuaViewBase"

local function CreateCampOfficeEleItem()
	local self = CreateViewBase()
	local tmpInputField
	local editText
	local isSetValue = false
	self.owner = nil
	self.dataIndex = nil
	
	self.Awake = function()
		self.imgframedown = self.transform:FindChild("imgframedown").gameObject;
		self.imgframe = self.transform:FindChild("imgframe").gameObject;
		self.textRanking = self.transform:FindChild("textRanking").gameObject;
		self.textgainvotes = self.transform:FindChild("textgainvotes").gameObject;
		self.officename1 = self.transform:FindChild("officename1").gameObject;
		self.officename2 = self.transform:FindChild("officename2").gameObject;
		self.officename3 = self.transform:FindChild("officename3").gameObject;
		self.notice = self.transform:FindChild("notice").gameObject;
		self.offbg1 = self.transform:FindChild("offbg1").gameObject;
		self.offbg2 = self.transform:FindChild("offbg2").gameObject;
		self.offbg3 = self.transform:FindChild("offbg3").gameObject;
		self.name = self.transform:FindChild("name").gameObject;
		self.war = self.transform:FindChild("war").gameObject;
		self.numble = self.transform:FindChild("numble").gameObject;
		self.btnedit = self.transform:FindChild("btnedit").gameObject;
		self.com_text_btn_edit = self.btnedit.transform:FindChild('com_text_btn_edit').gameObject
	end
	
	self.OnDestroy = function()
		MessageRPCManager.RemoveUser(self, 'ModifyParticipateDeclarationRet')
		UIUtil.RemoveTMP_InputFieldOnValueChanged(self.notice)
		tmpInputField = nil
	end
	
	self.SetVote = function(vote)
		self.textgainvotes:GetComponent('TextMeshProUGUI').text = vote
	end
	
	self.ModifyParticipateDeclarationRet = function() --修改竞选宣言反馈
		
	end
	
	self.SetText = function(text)
		isSetValue = true
		tmpInputField.text = text
	end
	
	self.OnNotice = function()
		local text = editText.text
		if text == '编辑' then
			editText.text = '保存'
			UnityEngine.EventSystems.EventSystem.current:SetSelectedGameObject(self.notice)
		else
			self.OnChangeNotice(tmpInputField.text)
			editText.text = '编辑'
		end
	end
	
	self.OnChangeNotice = function(content)
		local data = {}
		data.func_name = 'on_modify_participate_declaration'
		data.declaration =  content
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end
	
	self.SetIndex = function(dataIndex)
		self.dataIndex = dataIndex
	end
	
	self.SetOwner = function(owner)
		self.owner = owner
	end
	
	self.OnSelectItem = function()
		self.owner.selectItemIndex = self.dataIndex
	end
	
	self.Init = function()
		for i = 1, 3 do
			self['offbg'..i]:SetActive(false)
			self['officename'..i]:SetActive(false)
		end
		
		isSetValue = false
		tmpInputField = self.notice:GetComponent('TMP_InputField')
		editText = self.com_text_btn_edit:GetComponent('TextMeshProUGUI')
		--self.imgframedown:SetActive(false)
		MessageRPCManager.AddUser(self, 'ModifyParticipateDeclarationRet')
		ClickEventListener.Get(self.btnedit).onClick = self.OnNotice  	--宣言
		ClickEventListener.Get(self.imgframe).onClick = self.OnSelectItem
		
		UIUtil.AddTMP_InputFieldOnValueChanged(self.notice, 
							function(value)
								if tmpInputField.interactable then
									--self.OnChangeNotice(value)
									if isSetValue == false then
										editText.text = '保存'
									else
										isSetValue = false
										editText.text = '编辑'
									end
								end
							end)
	end


	return self
end

return CreateCampOfficeEleItem()
