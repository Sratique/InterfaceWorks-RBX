local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local ValueModule = {}
local ValueObject = {}
ValueObject.__index = function(self, key)
	if key == "Value" then
		return self.__Value
	end
	return setmetatable(ValueObject, BaseObject)[key]
end
ValueObject.__newindex = function(self, key, value)
	if key == "Value" then
		if value == self.__Value then
			return
		end

		rawset(self, "__Value", value)

		for _, v: () -> () in pairs(self.ChangeFunctions) do
			v()
		end
	end
	rawset(self, key, value)
end

function ValueModule.New(DefaultValue: number): InterfaceWorksValue
	local NewBaseObject = BaseObject.New()

	local NewValue = setmetatable(NewBaseObject, ValueObject)

	ProtectedObject.LayerInheritance(NewValue, "InterfaceWorksValue")

	NewValue.ChangeFunctions = {}
	NewValue.ID = 0

	NewValue.__Value = DefaultValue

	return NewValue
end

function ValueObject:OnChange(func: () -> ())
	table.insert(self.ChangeFunctions, func)
end

function ValueObject:Set(NewValue: any)
	if NewValue == self.__Value then
		return
	end

	rawset(self, "__Value", NewValue)

	for _, v: () -> () in pairs(self.ChangeFunctions) do
		v()
	end
end

function ValueObject:Destroy()
	self:__Destroy()
end

return ValueModule
