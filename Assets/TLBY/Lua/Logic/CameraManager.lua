---------------------------------------------------
-- auth： yanwei
-- date： 2017/2/6
-- desc： 相机管理
---------------------------------------------------
require "Common/basic/LuaObject"


local function CreateCameraManager()
    local self = CreateObject()
    self.CameraController = UnityEngine.Camera.main.gameObject:GetComponent("CameraController")
	self.uiCamera = UnityEngine.GameObject.Find("Canvas"):GetComponent("Canvas").worldCamera
    self.SetTarget = function(data)
        self.CameraController.target_ = data
    end
	
	function self.GetUIPos(rectTransform,worldPos)
       ret,position = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform,worldPos, self.uiCamera, 1)
	   return position
    end
	
    return self
end

CameraManager = CameraManager or CreateCameraManager()

