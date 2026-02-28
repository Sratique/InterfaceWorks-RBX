local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValue = types.InterfaceWorksValue

local Stroke = require("@BaseObject/Stroke")
local helper = require("./helpercomposer")

local composer = {}
composer.Compositions = {}
composer.CurrentComposition = nil
composer.RendererScheduler = {}

function composer.ScheduledValue(): InterfaceWorksValue?
	return composer.CurrentComposition:GetCurrentValue()
end

function composer.ScheduleValue(ValueObject: InterfaceWorksValue)
	assert(composer.CurrentComposition, "Unhandled exception: No composer job, but a value has been added.")

	local CurrentComposition = composer.CurrentComposition

	ValueObject:OnChange(function()
		composer.ReCompose(CurrentComposition)
	end)

	composer.CurrentComposition:InsertValue(ValueObject)
end

function composer.Schedule(composition: () -> InterfaceWorksElement)
	table.insert(composer.RendererScheduler, composition)
end

function composer.SchedulerResume()
	task.spawn(function()
		if composer.RendererScheduler[1] then
			local temp = composer.RendererScheduler[1]
			table.remove(composer.RendererScheduler, 1)
			composer.Compose(temp)
		end
	end)
end

function composer.ReCompose(Composition: InterfaceWorksStroke)
	composer.CurrentComposition = Composition

	Composition:ResetPosition()

	local NewBuildTable: { InterfaceWorksElement } = Composition.RetracingComposition()

	helper.Retrace(Composition, NewBuildTable, Composition.CurrentComposition)

	Composition.CurrentComposition = NewBuildTable
end

function composer.Compose(composition: () -> InterfaceWorksElement): InterfaceWorksStroke
	if composer.CurrentComposition then
		composer.Schedule(composition)
	end

	local NewStroke: InterfaceWorksStroke = Stroke.New(composition)
	composer.CurrentComposition = NewStroke

	local BuildTable: { InterfaceWorksElement } = composition()
	NewStroke.CurrentComposition = BuildTable
	helper.Build(NewStroke, BuildTable)

	composer.CurrentComposition = nil

	composer.SchedulerResume()

	return NewStroke
end

return composer
