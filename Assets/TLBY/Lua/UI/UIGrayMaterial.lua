--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/27 0027
-- Time: 15:08
-- To change this template use File | Settings | File Templates.
--
require "Common/basic/LuaObject"


local function CreateUIGrayMaterial()
    local self = CreateObject()
    local material = nil

    self.GetUIGrayMaterial = function()
        if material == nil then
            material = ResourceManager.GetMaterial("Gray")
        end
        return material
    end

    return self
end

UIGrayMaterial = UIGrayMaterial or CreateUIGrayMaterial()

