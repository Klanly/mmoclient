---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/16
-- desc： view的基类，即所有view类（如自动生成的view）的view类都继承于此类
---------------------------------------------------

require "Common/basic/LuaObject"


function CreateViewBase()
	local self = CreateObject()
	return self
end