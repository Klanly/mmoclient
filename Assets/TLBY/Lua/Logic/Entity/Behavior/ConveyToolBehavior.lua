---------------------------------------------------
-- auth： zhangzeng
-- date： 2016/9/12
-- desc： 加载屏障
---------------------------------------------------
local Behavior = require "Logic/Entity/Behavior/Behavior"
local ConveyToolBehavior = ExtendClass(Behavior)

function ConveyToolBehavior:__ctor(owner)
    self.modelId = nil
	self:OnCreate()
end

function ConveyToolBehavior:OnCreate()
	local data = self.owner.data
	self.data = data
    self.modelId = data.ModelID
    local item = self:GetModelData(self.modelId)
	local pos = Vector3.New(data.posX, data.posY, data.posZ)
	local rect = Vector3.New(2, 2, 2)
	self.behavior = EntityBehaviorManager.CreateConveyTool(SceneManager.GetCurServerSceneId(), 
	data.entity_id, item.Prefab, 1, pos, rect, self.owner)
	
	self.name = LuaUIUtil.GetTextByID(self.data,'Name')
	self.nameBar = CreateNameBar(self, self.behavior, 0, 200, '#ffb40a',0)
	self.nameBar:ShowNameBar()
	
    self.gameObject = self.behavior.gameObject
    self.transform = self.behavior.transform
end

function ConveyToolBehavior:Destroy()
	EntityBehaviorManager.Destroy(self.owner.uid)
	
	if self.nameBar then
        self.nameBar.DestroyBar()
        self.nameBar = nil
    end
end

return ConveyToolBehavior