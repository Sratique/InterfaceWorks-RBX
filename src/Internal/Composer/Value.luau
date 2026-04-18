local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local ComposerValues = {}

local ComposerRoot = require("./Root")

function ComposerValues.NextValue(): InterfaceWorksValue?
	return ComposerRoot.CurrentComposition:GetCurrentValue()
end

function ComposerValues.IndexValue(ValueObject: InterfaceWorksValue)
	assert(ComposerRoot.CurrentComposition, "Unhandled exception: No Composer job, but a value has been added.")

	local CurrentComposition = ComposerRoot.CurrentComposition

	ValueObject:OnChange(function()
		ComposerRoot.ReCompose(CurrentComposition, ValueObject.ID)
	end)

	ComposerRoot.CurrentComposition:InsertValue(ValueObject)
end

return ComposerValues
