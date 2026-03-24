local TweenService = game:GetService("TweenService")

local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValue = types.InterfaceWorksValue
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksBase = types.InterfaceWorksBase
type InterfaceWorksAnimationData = types.InterfaceWorksElementData

local Stroke = require("@BaseObject/Stroke")
local Object = require("@BaseObject/Object")
local InputTypesEnums = require("@Root/Public/InputTypesEnums")
local InputTypes = require("./InputTypesFunctions")

local Composer = {}
Composer.Compositions = {}
Composer.CurrentComposition = nil
Composer.RenderSchedule = {}

--Local

local function ScheduleRender(
	Base: _InterfaceWorksComposition | InterfaceWorksStroke,
	callback: (InterfaceWorksStroke) -> ()?,
	Priority: number?,
	Type: "ReCompose" | "Compose",
	Arguments: { any }?
)
	table.insert(Composer.RenderSchedule, {

		Base = Base,
		Callback = callback,
		Priority = Priority,
		Type = Type,
		Arguments = Arguments,
	})
end

local function NextRender()
	if #Composer.RenderSchedule == 0 then
		return
	end
	task.spawn(function()
		local LastMax = 1

		for i, v in pairs(Composer.RenderSchedule) do
			if Composer.RenderSchedule[LastMax].Priority < v.Priority then
				LastMax = i
			end
		end

		local RenderTicket = Composer.RenderSchedule[LastMax]
		table.remove(Composer.RenderSchedule, LastMax)

		if RenderTicket.Type == "Compose" then
			Composer.Compose(RenderTicket.Base, RenderTicket.Callback, RenderTicket.Priority, RenderTicket.Arguments)
		else
			Composer.ReCompose(RenderTicket.Base, RenderTicket.Arguments)
		end

		return
	end)
end

--Forward

function Composer.NextValue(): InterfaceWorksValue?
	return Composer.CurrentComposition:GetCurrentValue()
end

function Composer.IndexValue(ValueObject: InterfaceWorksValue)
	assert(Composer.CurrentComposition, "Unhandled exception: No Composer job, but a value has been added.")

	local CurrentComposition = Composer.CurrentComposition

	ValueObject:OnChange(function()
		Composer.ReCompose(CurrentComposition)
	end)

	Composer.CurrentComposition:InsertValue(ValueObject)
end

--			Main functions

function HelperCompose(SourceObject: InterfaceWorksBase, Elements: { [string | number]: InterfaceWorksElement })
	for ElementName: number | string, Element: InterfaceWorksElement in pairs(Elements) do
		if Element.Type == "Fragment" then
			if not Element.Composition then
				continue
			end
			Composer.Compose(Element.Composition, function(NewFragment: InterfaceWorksStroke)
				SourceObject:Insert(NewFragment, ElementName)
			end, 100, Element.FragmentArguments)
		elseif Element.Type == "Property" then
			local HeadlessHost = Instance.new(Element.ID)
			for prop: string, val: any in pairs(Element.Ps or {}) do
				HeadlessHost[prop] = val
			end
			HeadlessHost.Parent = SourceObject.Host
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

					print("Creating")

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
			if Element.An then
				local AD = Element.An

				local Tween = TweenService:Create(Host, AD.TI, AD.Goals)

				table.insert(NewElementObject.Animations, Tween)

				Tween.Completed:Connect(function()
					table.remove(NewElementObject.Animations, table.find(NewElementObject.Animations, Tween))
					Tween:Destroy()
				end)

				Tween:Play()
			end
			if Element.Cn then
				HelperCompose(NewElementObject, Element.Cn)
			end
		end
	end
end

function Composer.Compose(
	Composition: _InterfaceWorksComposition,
	callback: (InterfaceWorksStroke) -> ()?,
	Priority: number?,
	CompositionArguments: { any }?
) -- Priority is optional. Higher = faster render
	if Composer.CurrentComposition then
		ScheduleRender(Composition, callback, Priority or 99, "Compose", CompositionArguments)

		return
	end

	local NewStroke: InterfaceWorksStroke = Stroke.New(Composition)
	Composer.CurrentComposition = NewStroke

	local BuildTable: { InterfaceWorksElement } = Composition(unpack(CompositionArguments or {}))
	NewStroke.CurrentComposition = BuildTable
	HelperCompose(NewStroke, BuildTable)

	Composer.CurrentComposition = nil

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
				Composer.ReCompose(currentObject, currentchild.FragmentArguments)
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

			if currentchild.An then
				local AD = currentchild.An

				local Tween = TweenService:Create(currentObject.Host, AD.TI, AD.Goals)

				table.insert(currentObject.Animations, Tween)

				Tween.Completed:Connect(function()
					table.remove(currentObject.Animations, table.find(currentObject.Animations, Tween))
					Tween:Destroy()
				end)

				Tween:Play()
			end
			if currentchild.Cn and legacychild.Cn then
				HelperReCompose(currentObject, currentchild.Cn, legacychild.Cn)
			end
		end
	end
end

function Composer.ReCompose(Stroke: InterfaceWorksStroke, Arguments: { any }?)
	if Composer.CurrentComposition then
		ScheduleRender(Stroke, nil, 1, "ReCompose", Arguments)

		return
	end
	Composer.CurrentComposition = Stroke

	Stroke:ResetPosition()

	local NewBuildTable: { InterfaceWorksElement } = Stroke.RetracingComposition(unpack(Arguments or {}))

	HelperReCompose(Stroke, NewBuildTable, Stroke.CurrentComposition)
	Stroke.CurrentComposition = NewBuildTable

	Composer.CurrentComposition = nil
	NextRender()
end

return Composer
