local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local ValueClass = require("@Objects/Value")
local Composer = require("@Root/Internal/Composer")

local Value = {}
Value.Globals = {}

function Value.NewGlobal() end

function Value.New(default: any): InterfaceWorksValue
	local Exists: InterfaceWorksValue? = Composer.Value.NextValue()

	if Exists then
		return Exists
	end

	local Value: InterfaceWorksValue = ValueClass.New(default)

	Composer.Value.IndexValue(Value)

	return Value
end

return Value
