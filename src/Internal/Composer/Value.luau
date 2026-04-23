local types = require("@Root/types")
type InterfaceWorksValue = types.InterfaceWorksValue

local ComposerValues = {}

local ComposerRoot = require("./Root")
local ComposerScheduler = require("./Scheduler")

function ComposerValues.NextValue(): InterfaceWorksValue?
	return ComposerScheduler.CurrentComposition:GetCurrentValue()
end

function ComposerValues.IndexValue(ValueObject: InterfaceWorksValue)
	assert(ComposerScheduler.CurrentComposition, "Unhandled exception: No Composer job, but a value has been added.")

	local CurrentComposition = ComposerScheduler.CurrentComposition

	ValueObject:OnChange(function()
		ComposerRoot.ReCompose(CurrentComposition, ValueObject.ID)
	end)

	ComposerScheduler.CurrentComposition:InsertValue(ValueObject)
end

return ComposerValues
