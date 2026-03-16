local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local ValueClass = require("@BaseObject/Value")
local Composer = require("@Root/Internal/Composer")

local Value = {}
Value.Globals = {}

function Value.NewGlobal() end

function Value.New(default: any): InterfaceWorksValue
	local Exists: InterfaceWorksValue? = Composer.NextValue()

	if Exists then
		return Exists
	end

	local Value: InterfaceWorksValue = ValueClass.New(default)

	Composer.IndexValue(Value)

	return Value
end

return Value
