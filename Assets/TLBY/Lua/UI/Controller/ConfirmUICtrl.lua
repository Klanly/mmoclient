--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/9 0009
-- Time: 15:18
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"

local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateConfirmUICtrlCtrl()
    local self = CreateCtrlBase()
    self.okHandler = nil
    self.okData = nil
    self.cancelHandler = nil
    self.cancelData = nil

    local function OnOkBtnClick()
        if self.okHandler then
            self.okHandler(self.okData)
        end
        self.close()
    end

    local function OnCancelBtnClick()
        if self.cancelHandler then
            self.cancelHandler(self.cancelData)
        end
       self.close()
    end
	
	local function OnDoNothing()
	
	end

    self.onLoad = function()
        self.textok = self.view.textok:GetComponent("TextMeshProUGUI")
        self.textok.text = texttable.UIText[1101006].NR
        self.msg = self.view.text:GetComponent("TextMeshProUGUI")
        ClickEventListener.Get(self.view.btnNormal).onClick = OnOkBtnClick
        ClickEventListener.Get(self.view.btnclose).onClick = OnCancelBtnClick
        ClickEventListener.Get(self.view.imgbagbg).onClick = OnDoNothing
		self.view.iconImag:SetActive(false)
        self.view.transform.anchoredPosition3D = Vector3.New(self.view.transform.anchoredPosition3D.x,self.view.transform.anchoredPosition3D.y,-10)
    end

    --okHandler 确定回调
    --okData 确定回调参数
    --cancelHandler 取消回调
    --cancelData 取消回调参数
    --msg 展示消息
    self.Show = function(data)
        self.msg.text = data.msg
        self.okHandler = data.okHandler
        self.okData = data.okData
        self.cancelHandler = data.cancelHandler
        self.cancelData = data.cancelData
		
		if (data.needHideClose) then
		
			self.view.btnclose:SetActive(false)
		end
		
		if (data.icon) then
			self.view.iconImag:SetActive(true)
			local image = self.view.iconImag:GetComponent('Image')
			image.overrideSprite = data.icon
		end
    end

    return self
end

return CreateConfirmUICtrlCtrl()


