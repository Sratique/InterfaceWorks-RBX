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
	Reuse: Frame?,
}

export type InterfaceWorksRenderingSchedule = { InterfaceWorksRenderingTicket }

type InterfaceWorksRecomposingTicket = {
	Stroke: InterfaceWorksStroke,
	Arguments: { any }?,
	ID: string?,
}

export type InterfaceWorksRecomposingSchedule = { InterfaceWorksRecomposingTicket }

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

]]
local function PushObject(Object: InterfaceWorksBase, New: InterfaceWorksElement, Old: InterfaceWorksElement)
	local Host: Instance = Object.Host :: Instance

	for prop, val in New.Ps do
		if Old.Ps[prop] ~= val then
			Host[prop] = val
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
	Element: InterfaceWorksElement,
	ElementName: string | number,
	ReuseHost: Instance?
)
	local Host: any = ReuseHost or Instance.new(Element.ID)
	Host.Name = ElementName

	if not ReuseHost then
		for prop: string, val: any in Element.Ps do
			Host[prop] = val
		end
	end

	local NewElementObject: InterfaceWorksObject = InterfaceWorksObject.New(Host)
	SourceObject:Insert(NewElementObject, ElementName)

	for fndata: string | number, fn: (any) -> any in Element.Fs do
		if InputTypes[fndata] then
			local Worker: any = InputTypes[fndata](NewElementObject, fn)

			if Worker then
				table.insert(NewElementObject.Workers, Worker)
			end
			continue
		end
		NewElementObject[fndata] = function(): any
			return fn(NewElementObject)
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

local function CreateProperty(SourceObject: InterfaceWorksBase, Element: InterfaceWorksElement)
	local HeadlessHost = Instance.new(Element.ID)
	if Element.Ps then
		for prop: string, val: any in Element.Ps do
			HeadlessHost[prop] = val
		end
	end
	HeadlessHost.Parent = SourceObject.Host
end

--Exported functions

--[[

    Creates a new stroke without getting anything from a cache.

]]
function ComposerScheduler.Compose_Create(StartingComposition: _InterfaceWorksComposition, StartingArguments: { any }?)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				Parent = nil,
				Composition = StartingComposition,
				Arguments = StartingArguments,
				ID = nil,
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

			local Children: { { [string | number]: InterfaceWorksElement? } } = {
				NewBuild,
			}
			local Hierarchy: { InterfaceWorksBase } = {
				NewStroke,
			}
			local Pointer = 0

			while Pointer ~= #Children do
				Pointer += 1

				local CurrentBatch = Children[Pointer]
				local Parent = Hierarchy[Pointer]

				for i, Element in CurrentBatch do
					if not Element then
						continue
					end
					local ElementName = Element.Key or i

					if Element.Type == "Object" then
						local NewObject = CreateObject(Parent, Element, ElementName)

						NewObject.IsOrigin = true

						local NewIndex = #Children + 1
						Hierarchy[NewIndex] = NewObject

						Children[NewIndex] = Element.Cn

						continue
					end

					if Element.Type == "Property" then
						CreateProperty(Parent, Element)
						continue
					end

					if Element.Type == "Fragment" and Element.Composition then
						table.insert(RenderQueue, {
							Parent = Parent,
							Composition = Element.Composition,
							Arguments = Element.FragmentArguments,
							ID = ElementName,
						})
						continue
					end
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
	Reuse: Frame,
	StartingArguments: { any }?
)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				Parent = nil,
				Composition = StartingComposition,
				Arguments = StartingArguments,
				ID = nil,
				Reuse = Reuse,
			},
		}
		for _, Render in RenderQueue do
			local NewStroke = CreateStroke(Render, Render.Reuse)
			local NewBuild = PushStroke(NewStroke, Render.Arguments)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: { { [string | number]: InterfaceWorksElement? } } = {
				NewBuild,
			}
			local Hierarchy: { InterfaceWorksBase } = {
				NewStroke,
			}
			local Pointer = 0

			while Pointer ~= #Children do
				Pointer += 1

				local CurrentBatch = Children[Pointer]
				local Parent = Hierarchy[Pointer]

				for i, Element in CurrentBatch do
					if not Element then
						continue
					end
					local ElementName = Element.Key or i

					local ParentHost: Instance = Parent.Host :: Instance
					local DirtyHost: Frame? = ParentHost[ElementName] :: Frame?

					if not DirtyHost then
						warn(
							"Corrupted Host! This means the composition changes during the initial recomposition. Use seperate CIDs."
						)
						return
					end

					if Element.Type == "Object" then
						local NewObject = CreateObject(Parent, Element, ElementName, DirtyHost)

						local NewIndex = #Children + 1
						Hierarchy[NewIndex] = NewObject

						Children[NewIndex] = Element.Cn

						continue
					end

					if Element.Type == "Fragment" and Element.Composition then
						table.insert(RenderQueue, {
							Parent = Parent,
							Composition = Element.Composition,
							Arguments = Element.FragmentArguments,
							ID = ElementName,
							Reuse = DirtyHost,
						})
						continue
					end
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
			local Stroke: InterfaceWorksStroke = Ticket.Stroke
			local Arguments: { any }? = Ticket.Arguments

			local OldBuild: { InterfaceWorksElement }? = Stroke.CurrentComposition
			local NewBuild: { InterfaceWorksElement } = PushStroke(Stroke, Arguments)

			local NewChildren: { { [number | string]: InterfaceWorksElement? } } = {
				NewBuild,
			}
			local OldChildren: { { [number | string]: InterfaceWorksElement? }? } = {
				OldBuild,
			}
			local Hierarchy: { InterfaceWorksBase } = {
				Stroke,
			}

			local Pointer = 0

			while Pointer ~= #NewChildren do
				Pointer += 1

				local New: { [number | string]: InterfaceWorksElement? } = NewChildren[Pointer]
				local Old: { [number | string]: InterfaceWorksElement? }? = OldChildren[Pointer]
				local Parent: InterfaceWorksBase = Hierarchy[Pointer]

				local Renew = {}

				for NewIndex: number | string, NewElement: InterfaceWorksElement? in New do
					if not NewElement then
						continue
					end

					local Found: boolean = false
					local NewName: number | string = NewElement.Key or NewIndex

					if Old then
						for OldIndex: number | string, OldElement: InterfaceWorksElement? in Old do
							if not OldElement then
								continue
							end

							if NewElement.Key then
								if NewElement.Key ~= OldElement.Key then
									continue
								end
							else
								if NewIndex ~= OldIndex then
									continue
								end
							end

							Found = true
							Renew[OldElement.Key or OldIndex] = true

							if NewElement.Type == "Object" then
								PushObject(Parent[NewName], NewElement, OldElement)
								local NewChildrenIndex = #NewChildren + 1
								NewChildren[NewChildrenIndex] = NewElement.Cn
								OldChildren[NewChildrenIndex] = OldElement.Cn
								Hierarchy[NewChildrenIndex] = Parent[NewName]
							end

							if NewElement.Type == "Fragment" then
								local RecomposingTicket: InterfaceWorksRecomposingTicket = {
									Stroke = Parent[NewName],
									Arguments = NewElement.FragmentArguments,
								}

								if OldElement and NewElement.FragmentArguments and OldElement.FragmentArguments then
									for dt, val in NewElement.FragmentArguments do
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

							break
						end
					end

					if Found then
						continue
					end

					if NewElement.Type == "Object" then
						local NewParent = CreateObject(Parent, NewElement, NewName)
						local NewChildrenIndex = #NewChildren + 1
						NewChildren[NewChildrenIndex] = NewElement.Cn
						OldChildren[NewChildrenIndex] = nil
						Hierarchy[NewChildrenIndex] = NewParent
					elseif NewElement.Type == "Property" then
						CreateProperty(Parent, NewElement)
					elseif NewElement.Type == "Fragment" and NewElement.Composition then
						local RenderingTicket: InterfaceWorksRenderingTicket = {
							Composition = NewElement.Composition,
							Arguments = NewElement.FragmentArguments,
							Parent = Parent,
							ID = NewName,
						}
						local NewStroke = CreateStroke(RenderingTicket)
						table.insert(Strokes, {
							Stroke = NewStroke,
							Arguments = NewElement.FragmentArguments,
						})
					end
				end

				if Old then
					for OldIndex, OldElement in Old do
						if not OldElement then
							continue
						end
						local OldName = OldElement.Key or OldIndex
						if not Renew[OldName] then
							Parent[OldName]:Destroy()
						end
					end
				end
			end

			--Wrap things up for this stroke.
			Stroke.CurrentComposition = NewBuild
			ComposerScheduler.CurrentComposition = nil
		end
	end)
end

return ComposerScheduler
