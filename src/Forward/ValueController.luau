local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local ValueClass = require("@BaseObject/Value")
local composer = require("@Root/Internal/composer")

local Value = {}
Value.Globals = {}

function Value.NewGlobal() end

function Value.New(default: any): InterfaceWorksValue
	local Exists: InterfaceWorksValue? = composer.NextValue()

	if Exists then
		return Exists
	end

	local Value: InterfaceWorksValue = ValueClass.New(default)

	composer.IndexValue(Value)

	return Value
end

return Value
