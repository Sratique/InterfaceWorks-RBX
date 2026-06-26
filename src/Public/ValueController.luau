local InterfaceWorksValue = require("@Objects/Value")
type InterfaceWorksValue = InterfaceWorksValue.InterfaceWorksValue
local Composer = require("@Root/Internal/Composer")

local Value = {}
Value.Globals = {}

function Value.NewGlobal() end

function Value.New(default: any): InterfaceWorksValue
	local Exists: InterfaceWorksValue? = Composer.Value.NextValue()

	if Exists then
		return Exists
	end

	local NewValue: InterfaceWorksValue = InterfaceWorksValue.New(default)

	Composer.Value.IndexValue(NewValue)

	return NewValue
end

return Value
