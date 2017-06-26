----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"
require "Logic/Bag/QualityConst"
require "UI/TextAnchor"

local itemtable = require "Logic/Scheme/common_item"

local itemconfigs = itemtable.Item

local function CreatePurchaseItemUI()
	local self = CreateViewBase();
	self.id = 0

	local function OnClick()
		if not UIManager.GetCtrl(ViewAssets.PurchaseUI).isLoaded then
			return
		end
		UIManager.GetCtrl(ViewAssets.PurchaseUI).selectId = self.id
		UIManager.GetCtrl(ViewAssets.PurchaseUI).UpdateView()
	end

	self.Awake = function()
		self.Quality = self.transform:FindChild("@Quality").gameObject;
		self.prop = self.transform:FindChild("@prop").gameObject;
		self.choosepropdown = self.transform:FindChild("@choosepropdown").gameObject;
		self.textequipmentdigital = self.transform:FindChild("@textequipmentdigital").gameObject;
		self.Init()
	end

	self.Init = function()
		self.imgQuality = self.Quality:GetComponent("Image")
		self.textNumber = self.textequipmentdigital:GetComponent("TextMeshProUGUI")
		--self.textNumber.fontSize = 26
		--self.textNumber.color = Color.New(1,1,1)
		--self.textequipmentdigital:GetComponent("RectTransform").sizeDelta = Vector2.New(100,41)
		--UIUtil.SetTextAlignment(self.textNumber,TextAnchor.MiddleRight)
		self.imgProp = self.prop:GetComponent("Image")
		ClickEventListener.Get(self.prop).onClick = OnClick
	end

	self.SetData = function(data)
		self.id = data
		local itemconfig = itemconfigs[data]
		if itemconfig then
			self.imgQuality.overrideSprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(itemconfig.Quality))
			self.imgProp.overrideSprite = ResourceManager.LoadSprite("ItemIcon/"..itemconfig.Icon)
			local number = BagManager.GetItemNumberById(data)
			self.textNumber.text = number
			if number > 0 then
				self.imgQuality.material = nil
				self.imgProp.material = nil
			else
				self.imgQuality.material = UIGrayMaterial.GetUIGrayMaterial()
				self.imgProp.material = UIGrayMaterial.GetUIGrayMaterial()
			end

			if UIManager.GetCtrl(ViewAssets.PurchaseUI).isLoaded then
				if UIManager.GetCtrl(ViewAssets.PurchaseUI).selectId == self.id then
					self.choosepropdown:SetActive(true)
				else
					self.choosepropdown:SetActive(false)
				end
			end
		end
	end

	return self;
end
return CreatePurchaseItemUI()
