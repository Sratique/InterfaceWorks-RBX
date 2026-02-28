local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local BaseObject = require("@BaseObject")

local Value = {}
Value.__index = setmetatable(Value, BaseObject)

function Value.New(DefaultValue: number): InterfaceWorksValue
	local NewBaseObject = BaseObject.New()

	local NewValue = setmetatable(NewBaseObject, Value)

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
	table.clear(self.ChangeFunctions)
	self.Value = nil
	self.ChangeFunctions = nil
	setmetatable(self, nil)
	table.clear(self)
end

return Value
