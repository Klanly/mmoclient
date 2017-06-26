----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Entity/Attribute/AttributeConst"
local uitext = require("Logic/Scheme/common_char_chinese").UIText

local function CreatePropertyChangeItemUI()
	local self = CreateViewBase();
	local numberTimer = nil
	self.Awake = function()
		self.imgSplitline = self.transform:FindChild("@imgSplitline").gameObject;
		self.text1 = self.transform:FindChild("@text1").gameObject;
		self.number1 = self.transform:FindChild("@number1").gameObject;
		self.numberdecline = self.transform:FindChild("@numberdecline").gameObject;
		self.Arrow1 = self.transform:FindChild("@Arrow1").gameObject;
		self.RiseArrow = self.transform:FindChild("@RiseArrow").gameObject;
		self.declineArrow = self.transform:FindChild("@declineArrow").gameObject;
		self.Init()
	end

	self.Init = function()
		self.textPropertyName = self.text1:GetComponent("Text")
		self.textNumber1 = self.number1:GetComponent("Text")
		self.textNumber2 = self.numberdecline:GetComponent("Text")
	end

	--property属性编号
	--number1变化之前
	--number2变化之后
	--line 是否显示底线(最后一条不显示底线)
	self.SetData = function(property,number1,number2,line)
		if property == 0 then
			--战斗力
			self.textPropertyName.text = uitext[1114109].NR
		elseif property == -1 then
			--综合实力
			self.textPropertyName.text = uitext[1114108].NR
		else
			self.textPropertyName.text = AttributeConst.GetAttributeNameByIndex(property)
		end
		self.textNumber1.text = number1
		self.textNumber2.text = number1
		if number1 > number2 then
			self.RiseArrow:SetActive(false)
			self.declineArrow:SetActive(true)
			self.textNumber2.color = Color.New(230/255,67/255,86/255)
		elseif number1 < number2 then
			self.RiseArrow:SetActive(true)
			self.declineArrow:SetActive(false)
			self.textNumber2.color = Color.New(121/255,208/255,101/255)
		else
			self.RiseArrow:SetActive(false)
			self.declineArrow:SetActive(false)
			self.textNumber2.color = Color.New(243/255,229/255,216/255)
		end
		if line then
			self.imgSplitline:SetActive(true)
		else
			self.imgSplitline:SetActive(false)
		end
		self.RemoveTimer()
		local count = 30
		local abs = math.abs(number1 - number2)
		if abs <= 1 then
			abs = 1
		end
		if abs < 30 then
			count = abs
		end

		local current_count = 0
		numberTimer = Timer.Numberal(0.033,count,function()
			current_count = current_count + 1
			self.textNumber2.text = number1 + math.floor((number2-number1)*current_count/count)
			if current_count >= count then
				self.RemoveTimer()
			end
		end)
	end

	self.RemoveTimer = function()
		if numberTimer then
			Timer.Remove(numberTimer)
		end
		numberTimer = nil
	end

	self.onUnload = function()
		self.RemoveTimer()
	end

	return self;
end
return CreatePropertyChangeItemUI();
