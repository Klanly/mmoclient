---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/16
-- desc： ctrl的基类
---------------------------------------------------
require "UI/LuaUIUtil"
require "Common/basic/LuaObject"

function CreateScrollviewItem(template)
	local self = CreateObject()
	self.gameObject = GameObject.Instantiate(template)
	self.transform = self.gameObject.transform
	self.transform:SetParent(template.transform.parent, false)
	self.transform.localScale = Vector3.one
	self.gameObject:SetActive(true)
	template:SetActive(false)
	return self
end
function DestroyScrollviewItem(item)
	GameObject.Destroy(item.gameObject)
end

function CreateCtrlBase()
	local self = CreateObject()
    self.layer = LayerGroup.pop
    
	self.asset = nil
	self.luaBehaviour = nil
	self.view = nil
	self.isLoaded = false
	self.isLoading = false -- 是否正在加载
	self.isActived = false
	self.isLock = false -- 锁住时不能unload
    self.preAssetUI = nil  --保存它的前一个UI，当前UI关闭时显示它
    self.args = nil
    self.enableCache = true -- 可以加入缓存
    self.isClosed = false
    self.onLoadCallback = nil
	
	local childCtrl = {}
	
	self.AddChildCtrl = function(ctrl)
		if not childCtrl[ctrl.asset[1]] then
			childCtrl[ctrl.asset[1]] = ctrl
		end
	end
	self.RemoveChildCtrl = function(ctrl)
		if childCtrl[ctrl.asset[1]] then
			childCtrl[ctrl.asset[1]] = nil
		end
	end
	self.RemoveAllChild = function()
		childCtrl = {}
	end

	self.AddClick = function(go, func)
		ClickEventListener.Get(go).onClick = func
	end

	self.RemoveClick = function(go)
		ClickEventListener.Get(go).onClick = nil
	end

	-- 使image变灰/正常
	self.setButtonEnable = function(go, enabled, pressed, disabled)
		local img = go:GetComponent("Image")
		if not img then
			return
		end
		if enabled then
			img.material = nil
        	UIUtil.AddButtonEffect(go, pressed, disabled)
		else
			img.material = UIGrayMaterial.GetUIGrayMaterial()
        	UIUtil.RemoveButtonEffect(go)
		end
	end

	self.hide = function()
		if self.isLoaded then
			self.view.gameObject:SetActive(false)
		end
	end
	self.show = function()
		if self.isLoaded then
			self.view.gameObject:SetActive(true)
		end
	end

	self.close = function()
		if self.isLock then
			print('ctrl is locked, can not close!!')
			return
		end
		for k, v in pairs(childCtrl) do
			v.close()
		end
 
		UIManager.UnloadView(self.asset)
		if self.preAssetUI ~= nil then
		   UIManager.PushView(self.preAssetUI)
		   self.preAssetUI = nil 
		end
	end

	-- 当view获得焦点时（比如从底层到顶层，或view加载之前）
	self.onActive = function(...)
	end

	-- 当失去焦点时事件（比如，从顶层到底层、或view卸载之前）
	self.onDeactive = function()
	end

	-- 当加载完时
	self.onLoad = function(...)
	end

	-- 当销毁(回收)时
	self.onUnload = function()
	end
	return self
end

