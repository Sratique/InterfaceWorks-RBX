local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local Value = {}
Value.__index = setmetatable(Value, BaseObject)

function Value.New(DefaultValue: number): InterfaceWorksValue
	local NewBaseObject = BaseObject.New()

	local NewValue = setmetatable(NewBaseObject, Value)

	ProtectedObject.LayerInheritance(NewValue, "InterfaceWorksValue")

	NewValue.ChangeFunctions = {}

	NewValue.Value = DefaultValue

	return NewValue
end

function Value:OnChange(func: () -> ())
	table.insert(self.ChangeFunctions, func)
end

function Value:Set(NewValue: any)
	self.Value = NewValue

	for _, v: () -> () in pairs(self.ChangeFunctions) do
		v()
	end
end

function Value:Destroy()
	self:__Destroy()
end

return Value
