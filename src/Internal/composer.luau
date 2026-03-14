local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValue = types.InterfaceWorksValue
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksBase = types.InterfaceWorksBase

local Stroke = require("@BaseObject/Stroke")
local Object = require("@BaseObject/Object")
local InputTypesEnums = require("@Root/Forward/InputTypesEnums")
local InputTypes = require("./InputTypes")

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

--			Main functions

function HelperCompose(SourceObject: InterfaceWorksBase, Elements: { [string | number]: InterfaceWorksElement })
	for ElementName: number | string, Element: InterfaceWorksElement in pairs(Elements) do
		if Element.Type == "Fragment" then
			if not Element.Composition then
				continue
			end
			composer.Compose(Element.Composition, function(NewFragment: InterfaceWorksStroke)
				SourceObject:Insert(Stroke, Element.FragmentName)
			end, 100)
		else
			local Host: any = Instance.new(Element.ID)
			Host.Name = ElementName

			for prop: string, val: any in pairs(Element.Ps or {}) do
				Host[prop] = val
			end

			local NewElementObject: InterfaceWorksObject = Object.New(Host)

			for fndata: string, fn: (any) -> any in pairs(Element.Fs or {}) do
				if InputTypes[fndata] then
					local Worker = InputTypes[fndata](NewElementObject, fn)

					if Worker then
						table.insert(NewElementObject.Workers, Worker)
					end
					continue
				end
				NewElementObject[fndata] = function()
					fn(NewElementObject)
				end
			end

			SourceObject:Insert(NewElementObject, ElementName)

			if Element.Mt then
				Element.Mt:AddTarget(NewElementObject)
			end
			if Element.Cn then
				HelperCompose(NewElementObject, Element.Cn)
			end
		end
	end
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
	HelperCompose(NewStroke, BuildTable)

	composer.CurrentComposition = nil

	if callback then
		callback(NewStroke)
	end

	NextRender()
end

function HelperReCompose(
	Base: InterfaceWorksBase,
	CurrentElements: { [number | string]: InterfaceWorksElement },
	LegacyElements: { [number | string]: InterfaceWorksElement }
)
	for childname, legacychild: InterfaceWorksElement in pairs(LegacyElements or {}) do
		local currentchild = CurrentElements[childname]
		local legacyObject = Base[childname]

		if not currentchild then
			if legacyObject then
				legacyObject:Destroy()
			end
		end
	end
	for childname: number | string, currentchild: InterfaceWorksElement in pairs(CurrentElements or {}) do
		local legacychild: InterfaceWorksElement? = LegacyElements[childname]
		local currentObject: any = Base[childname]

		if currentchild.Type == "Fragment" then
			if currentObject:IsA("InterfaceWorksStroke") then
				composer.ReCompose(currentObject)
			end
		else
			if not legacychild then
				if not currentObject then
					HelperCompose(Base, { [childname] = currentchild })
				end
				continue
			end

			--Set all properties

			for propname, propdata in pairs(currentchild.Ps or {}) do
				if legacychild.Ps and legacychild.Ps[propname] ~= propdata then
					currentObject.Host[propname] = propdata
				end
			end

			--Retrace function event

			local Retrace = currentchild.Fs and currentchild.Fs[InputTypesEnums.Render]
			if Retrace then
				InputTypes[InputTypesEnums.Render](currentObject, Retrace)
			end

			--Continue children

			if currentchild.Cn and legacychild.Cn then
				HelperReCompose(currentObject, currentchild.Cn, legacychild.Cn)
			end
		end
	end
end

function composer.ReCompose(Stroke: InterfaceWorksStroke)
	if composer.CurrentComposition then
		ScheduleRender(Stroke, nil, 1, "ReCompose")

		return
	end
	composer.CurrentComposition = Stroke

	Stroke:ResetPosition()

	local NewBuildTable: { InterfaceWorksElement } = Stroke.RetracingComposition()

	HelperReCompose(Stroke, NewBuildTable, Stroke.CurrentComposition)
	Stroke.CurrentComposition = NewBuildTable

	composer.CurrentComposition = nil
	NextRender()
end

return composer
