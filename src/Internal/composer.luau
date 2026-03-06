local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValue = types.InterfaceWorksValue
type _InterfaceWorksComposition = types._InterfaceWorksComposition

local Stroke = require("@BaseObject/Stroke")
local helper = require("./helpercomposer")

local composer = {}
composer.Compositions = {}
composer.CurrentComposition = nil
composer.RenderSchedule = {}

--Local

local function ScheduleRender(
	Base: _InterfaceWorksComposition | InterfaceWorksStroke,
	callback: (InterfaceWorksStroke) -> ()?,
	Priority: number?,
	Type: "ReCompose" | "Compose"
)
	table.insert(composer.RenderSchedule, {

		Base = Base,
		Callback = callback,
		Priority = Priority,
		Type = Type,
	})
end

local function NextRender()
	if #composer.RenderSchedule == 0 then
		return
	end
	task.spawn(function()
		local LastMax = 1

		for i, v in pairs(composer.RenderSchedule) do
			if composer.RenderSchedule[LastMax].Priority < v.Priority then
				LastMax = i
			end
		end

		local RenderTicket = composer.RenderSchedule[LastMax]
		table.remove(composer.RenderSchedule, LastMax)

		if RenderTicket.Type == "Compose" then
			composer.Compose(RenderTicket.Base, RenderTicket.Callback)
		else
			composer.ReCompose(RenderTicket.Base)
		end

		return
	end)
end

--Forward

function composer.NextValue(): InterfaceWorksValue?
	return composer.CurrentComposition:GetCurrentValue()
end

function composer.IndexValue(ValueObject: InterfaceWorksValue)
	assert(composer.CurrentComposition, "Unhandled exception: No composer job, but a value has been added.")

	local CurrentComposition = composer.CurrentComposition

	ValueObject:OnChange(function()
		composer.ReCompose(CurrentComposition)
	end)

	composer.CurrentComposition:InsertValue(ValueObject)
end

function composer.ReCompose(Stroke: InterfaceWorksStroke)
	if composer.CurrentComposition then
		ScheduleRender(Stroke, nil, 1, "ReCompose")

		return
	end
	composer.CurrentComposition = Stroke

	Stroke:ResetPosition()

	local NewBuildTable: { InterfaceWorksElement } = Stroke.RetracingComposition()

	helper.Retrace(Stroke, NewBuildTable, Stroke.CurrentComposition)
	Stroke.CurrentComposition = NewBuildTable

	composer.CurrentComposition = nil
	NextRender()
end

function composer.Compose(
	Composition: _InterfaceWorksComposition,
	callback: (InterfaceWorksStroke) -> ()?,
	Priority: number?
) -- Priority is optional. Higher = faster render
	if composer.CurrentComposition then
		ScheduleRender(Composition, callback, Priority or 99, "Compose")

		return
	end

	local NewStroke: InterfaceWorksStroke = Stroke.New(Composition)
	composer.CurrentComposition = NewStroke

	local BuildTable: { InterfaceWorksElement } = Composition()
	NewStroke.CurrentComposition = BuildTable
	helper.Build(NewStroke, BuildTable)

	composer.CurrentComposition = nil

	if callback then
		callback(NewStroke)
	end

	NextRender()
end

return composer
