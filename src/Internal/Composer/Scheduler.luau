--!nonstrict

--Rewriting this at 1AM might have it's consequences.

local types = require("@Root/structs")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type _InterfaceWorksComposition = types._InterfaceWorksComposition

local InterfaceWorksStroke = require("@Objects/Stroke")
type InterfaceWorksStroke = InterfaceWorksStroke.InterfaceWorksStroke
local InterfaceWorksObject = require("@Objects/Object")
type InterfaceWorksObject = InterfaceWorksObject.InterfaceWorksObject
local InterfaceWorksBase = require("@BaseObject")
type InterfaceWorksBase = InterfaceWorksBase.InterfaceWorksBase

local Jobs = require("@Root/Internal/Composer/Jobs")
local InputTypes = require("@Root/Internal/InputTypesFunctions")
local InputTypesEnums = require("@Root/Public/InputTypesEnums")
local Animations = require("./Animations")

type InterfaceWorksRenderingTicket = {
	Parent: InterfaceWorksBase?,
	Composition: _InterfaceWorksComposition,
	Arguments: { any }?,
	ID: (number | string)?,
	IsRoot: boolean?,
	Reuse: Instance?,
}

export type InterfaceWorksRenderingSchedule = { InterfaceWorksRenderingTicket }

type InterfaceWorksRecomposingTicket = {
	Stroke: InterfaceWorksBase,
	Arguments: { any }?,
	ID: string?,
}

export type InterfaceWorksRecomposingSchedule = { InterfaceWorksRecomposingTicket }

type InterfaceWorksRenderingElement = InterfaceWorksElement & {
	Name: (string | number)?,
	ParentObject: InterfaceWorksObject,
	ParentInstance: Instance?,
	Parent: InterfaceWorksBase,
	Object: InterfaceWorksObject?,
	Old: InterfaceWorksElement?,
}

local ComposerScheduler = {}
ComposerScheduler.CurrentComposition = nil :: InterfaceWorksStroke?
ComposerScheduler._VERSION = _G.SchedulerVersion :: string

--[[

    Push to the main pipeline if it's free. Errors if a current stroke is already being rendered,
    because the ticket system should prevent this really, but just in case.
    REMEMBER TO RELEASE THE CURRENTCOMPOSITION PROPERTY LATER BECAUSE IT GETS FUCKED IF U DONT.

]]
local function PushStroke(Stroke: InterfaceWorksStroke, Arguments: { any }?): { InterfaceWorksElement }
	if ComposerScheduler.CurrentComposition then
		error("Failed to push stroke to main pipeline.")
	end

	ComposerScheduler.CurrentComposition = Stroke

	Stroke:ResetPosition()

	local NewBuild = Stroke.RetracingComposition(unpack(Arguments or Stroke.SelfArguments or {}))
	Stroke.CurrentComposition = NewBuild

	return NewBuild
end

--[[

    Just create the stroke and assemble it but don't execute any of the pipeline instructions.

]]
local function CreateStroke(Render: InterfaceWorksRenderingTicket, Reuse: Frame?): InterfaceWorksStroke
	local CurrentComposition = Render.Composition

	local NewStroke = InterfaceWorksStroke.New(CurrentComposition, Render.ID, Reuse)
	NewStroke.SelfArguments = Render.Arguments

	if Render.Parent then
		Render.Parent:Insert(NewStroke, Render.ID)
	end

	return NewStroke
end

--[[

    Updates the object according to changes in Elements.
    Returns already compared children of the object.

]]
local function PushObject(Object: InterfaceWorksBase, New: InterfaceWorksRenderingElement, Old: InterfaceWorksElement)
	local Host = Object.Host

	if New.Ps and Old.Ps then
		for prop, val in New.Ps do
			if Old.Ps[prop] ~= val then
				Host[prop] = val
			end
		end
	end

	if New.Fs and New.Fs[InputTypesEnums.Render] then
		InputTypes[InputTypesEnums.Render](Object, New.Fs[InputTypesEnums.Render])
	end

	if New.An then
		Animations.Play(Object :: InterfaceWorksObject, New.An, true)
	end
end

--[[

    Creates the object and sets properties.

]]
local function CreateObject(
	SourceObject: InterfaceWorksBase,
	Element: InterfaceWorksRenderingElement,
	ReuseHost: Instance?
)
	local Host: any = ReuseHost or Instance.new(Element.ID or "")
	Host.Name = Element.Name

	if Element.Ps and not ReuseHost then
		for prop: string, val: any in Element.Ps do
			Host[prop] = val
		end
	end

	local NewElementObject: InterfaceWorksObject = InterfaceWorksObject.New(Host)
	SourceObject:Insert(NewElementObject, Element.Name)

	if Element.Fs then
		for fndata: string | number, fn: (any) -> any in Element.Fs do
			if typeof(fndata) == "number" and InputTypes[fndata] then
				local Worker = InputTypes[fndata](NewElementObject, fn)

				if Worker then
					table.insert(NewElementObject.Workers, Worker)
				end
				continue
			end
			NewElementObject[fndata] = function(): any
				return fn(NewElementObject)
			end
		end
	end

	if Element.Mt then
		Element.Mt:AddTarget(NewElementObject)
	end
	if Element.An then
		Animations.Play(NewElementObject, Element.An)
	end

	return NewElementObject
end

--Exported functions

--[[

    Creates a new stroke without getting anything from a cache.

]]
function ComposerScheduler.Compose_Create(StartingComposition: _InterfaceWorksComposition, StartingArguments: { any }?)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				["Parent"] = nil,
				["Composition"] = StartingComposition,
				["Arguments"] = StartingArguments,
				["ID"] = nil,
				["IsRoot"] = true,
			},
		}
		for _, Render in RenderQueue do
			local NewStroke = CreateStroke(Render)
			local NewBuild = PushStroke(NewStroke, Render.Arguments)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: { InterfaceWorksRenderingElement } = {}
			local ChildrenPointer = 0

			for name, element in NewBuild do
				element["Name"] = element.Key or name
				element["Parent"] = NewStroke
				table.insert(Children, element :: any)
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer
				local ElementName = ElementContainer.Name
				local SourceObject: InterfaceWorksBase? = ElementContainer.Parent

				if not SourceObject then
					continue
				end

				if Element.Type == "Object" then
					local NewObject = CreateObject(SourceObject, Element)

					for name: string | number, ChildElement: InterfaceWorksElement? in Element.Cn do
						if not ChildElement then
							continue
						end
						ChildElement["Parent"] = NewObject
						ChildElement["Name"] = ChildElement.Key or name
						table.insert(Children, ChildElement :: InterfaceWorksRenderingElement)
					end
				elseif Element.Type == "Property" then
					local HeadlessHost = Instance.new(Element.ID)
					if Element.Ps then
						for prop: string, val: any in Element.Ps do
							HeadlessHost[prop] = val
						end
					end
					HeadlessHost.Parent = SourceObject.Host
				else
					if not Element.Composition then
						continue
					end
					table.insert(RenderQueue, {
						["Parent"] = SourceObject,
						["Composition"] = Element.Composition,
						["Arguments"] = Element.FragmentArguments,
						["ID"] = ElementName,
					})
				end
			end
			--Set stroke state to init=true
			NewStroke:__Init()
			ComposerScheduler.CurrentComposition = nil
		end
	end)
end

--[[

    Creates a stroke based on already rendered instances in the cache.

]]
function ComposerScheduler.Compose_Reuse(
	StartingComposition: _InterfaceWorksComposition,
	Reuse: Instance,
	StartingArguments: { any }?
)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				["Parent"] = nil,
				["Composition"] = StartingComposition,
				["Arguments"] = StartingArguments,
				["ID"] = nil,
				["IsRoot"] = true,
				["Reuse"] = Reuse,
			},
		}
		for _, Render in RenderQueue do
			local NewStroke = CreateStroke(Render)
			local NewBuild = PushStroke(NewStroke, Render.Arguments)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: { InterfaceWorksRenderingElement } = {}
			local ChildrenPointer = 0

			for name, element in NewBuild do
				element["Name"] = element.Key or name
				element["Parent"] = NewStroke
				element["ParentInstance"] = Render.Reuse
				table.insert(Children, element :: InterfaceWorksRenderingElement)
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer
				local ElementName = ElementContainer.Name
				local SourceObject = ElementContainer.Parent

				local DirtyHost: Instance? = Element.ParentInstance[ElementName]

				if not DirtyHost then
					continue
				end

				if Element.Type == "Object" then
					local NewElementObject = CreateObject(SourceObject, Element, DirtyHost)

					for name: string | number, element in Element.Cn do
						if not element then
							continue
						end
						element["Name"] = element.Key or name
						element["Parent"] = NewElementObject
						element["ParentObject"] = SourceObject
						element["ParentInstance"] = DirtyHost
						table.insert(Children, element :: InterfaceWorksRenderingElement)
					end
				else
					if not Element.Composition then
						continue
					end
					table.insert(RenderQueue, {
						["Parent"] = SourceObject,
						["Composition"] = Element.Composition,
						["Arguments"] = Element.FragmentArguments,
						["ID"] = ElementName,
						["Reuse"] = DirtyHost,
					})
				end
			end
			--Set stroke state to init=true
			NewStroke:__Init()
			ComposerScheduler.CurrentComposition = nil
		end
	end)
end

--[[

    Does a full Element scan and updates properties to new values.

]]
function ComposerScheduler.ReCompose(Init: InterfaceWorksStroke)
	return Jobs.CreateJob(function()
		local Strokes: InterfaceWorksRecomposingSchedule =
			{ {

				Stroke = Init,
				Arguments = Init.SelfArguments,
			} }
		for _, Ticket: InterfaceWorksRecomposingTicket in Strokes do
			local Stroke = Ticket.Stroke
			local Arguments = Ticket.Arguments

			local OldBuild = Stroke.CurrentComposition or {}
			local NewBuild = PushStroke(Stroke, Arguments)

			local Children: { InterfaceWorksRenderingElement } = {}

			local function CompareChildren(
				Old: { [any]: InterfaceWorksElement? },
				New: { [any]: InterfaceWorksElement? },
				ParentObject: InterfaceWorksBase
			)
				local KeyedOld: { [string | number]: InterfaceWorksElement } = {}
				local KeyedNew: { [string | number]: InterfaceWorksElement } = {}

				for i, v in Old do
					if not v then
						continue
					end
					if v.Key then
						KeyedOld[v.Key] = v
						continue
					end
					KeyedOld[i] = v
				end

				for i, v in New do
					if not v then
						continue
					end
					if v.Key then
						KeyedNew[v.Key] = v
						continue
					end
					KeyedNew[i] = v
				end

				for i: string | number, InterfaceWorksElement in KeyedNew do
					if KeyedOld[i] == nil then
						InterfaceWorksElement["Name"] = i
						InterfaceWorksElement["ParentObject"] = ParentObject
						table.insert(Children, InterfaceWorksElement :: InterfaceWorksRenderingElement)
					elseif InterfaceWorksElement.Type ~= "Property" then
						InterfaceWorksElement["Object"] = ParentObject[i]
						InterfaceWorksElement["Old"] = KeyedOld[i]
						table.insert(Children, InterfaceWorksElement :: InterfaceWorksRenderingElement)
					end
				end
				for i: string | number, InterfaceWorksElement in KeyedOld do
					if KeyedNew[i] == nil then
						local OldInstance: any = ParentObject[i]
						OldInstance:Destroy()
					end
				end
			end

			CompareChildren(OldBuild, NewBuild, Stroke)

			local Pointer = 0

			while #Children ~= Pointer do
				Pointer += 1

				local CurrentElement = Children[Pointer]
				local OldElement = CurrentElement.Old
				CurrentElement.Old = nil :: any -- keep this to prevent old compositions not being garbage collected

				local ElementObject: InterfaceWorksBase = CurrentElement.Object

				if not ElementObject then
					if CurrentElement.Type == "Object" then
						ElementObject = CreateObject(CurrentElement.ParentObject, CurrentElement)
					elseif CurrentElement.Type == "Fragment" then
						local RenderingTicket: InterfaceWorksRenderingTicket = {
							Composition = CurrentElement.Composition,
							Arguments = CurrentElement.FragmentArguments,
							Parent = CurrentElement.ParentObject,
							ID = CurrentElement.Name,
						}
						ElementObject = CreateStroke(RenderingTicket)
					elseif CurrentElement.Type == "Property" then
						local HeadlessHost = Instance.new(CurrentElement.ID)
						if CurrentElement.Ps then
							for prop: string, val: any in CurrentElement.Ps do
								HeadlessHost[prop] = val
							end
						end
						HeadlessHost.Parent = CurrentElement.ParentObject.Host
						continue
					else
						continue
					end
				end

				if CurrentElement.Type == "Object" then
					PushObject(ElementObject, CurrentElement, OldElement or {})

					CompareChildren(OldElement and OldElement.Cn or {}, CurrentElement.Cn or {}, ElementObject)
					continue
				end

				if CurrentElement.Type == "Fragment" then
					local RecomposingTicket: InterfaceWorksRecomposingTicket = {
						Stroke = ElementObject,
						Arguments = CurrentElement.FragmentArguments,
					}

					if OldElement then
						for dt, val in pairs(CurrentElement.FragmentArguments or {}) do
							if OldElement.FragmentArguments[dt] ~= val then
								table.insert(Strokes, RecomposingTicket)
								break
							elseif typeof(val) == "table" then
								table.insert(Strokes, RecomposingTicket)
								break
							end
						end
					else
						table.insert(Strokes, RecomposingTicket)
					end
				end
			end

			--Wrap things up for this stroke
			Stroke.CurrentComposition = NewBuild
			ComposerScheduler.CurrentComposition = nil
		end
	end)
end

return ComposerScheduler
