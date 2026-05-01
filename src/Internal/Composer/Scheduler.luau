local TweenService = game:GetService("TweenService")

local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type InterfaceWorksWorker = types.InterfaceWorksWorker
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksBase = types.InterfaceWorksBase
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksRenderingSchedule = types.InterfaceWorksRenderingSchedule
type InterfaceWorksRenderingTicket = types.InterfaceWorksRenderingTicket

local ComposerScheduler = {}
ComposerScheduler._VERSION = _G.SchedulerVersion

local Jobs = require("@Root/Internal/Composer/Jobs")
local InputTypes = require("@Root/Internal/InputTypesFunctions")
local InputTypesEnums = require("@Root/Public/InputTypesEnums")
local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local StrokeObject = require("@Objects/Stroke")
local Object = require("@Objects/Object")

local function CreateStroke(
	Render: InterfaceWorksRenderingTicket,
	Reuse
): (InterfaceWorksStroke, { InterfaceWorksElement })
	local CurrentComposition = Render.Composition

	local NewStroke = StrokeObject.New(CurrentComposition, Render.ID, Reuse)

	ComposerScheduler.CurrentComposition = NewStroke

	local NewBuild = CurrentComposition(unpack(Render.Arguments or {}))
	NewStroke.CurrentComposition = NewBuild

	return NewStroke, NewBuild
end

local function CreateObject(
	Element: InterfaceWorksElement,
	ElementName: string,
	SourceObject: InterfaceWorksBase
): InterfaceWorksObject
	local Host: any = Instance.new(Element.ID)
	Host.Name = ElementName

	if Element.Ps then
		for prop: string, val: any in Element.Ps do
			Host[prop] = val
		end
	end

	local NewElementObject: InterfaceWorksObject = Object.New(Host)
	SourceObject:Insert(NewElementObject, ElementName)

	if Element.Fs then
		for fndata: string | number, fn: (any) -> any in Element.Fs do
			if InputTypes[fndata] then
				local Worker: InterfaceWorksWorker? = InputTypes[fndata](NewElementObject, fn)

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
		local AD = Element.An

		if AD.BeginningPoint then
			for prop, data in AD.BeginningPoint do
				Host[prop] = data
			end
		end

		local Tween = TweenService:Create(Host, AD.TI, AD.Goals)

		table.insert(NewElementObject.Animations, Tween)

		Tween.Completed:Connect(function()
			table.remove(NewElementObject.Animations, table.find(NewElementObject.Animations, Tween))
			Tween:Destroy()
		end)

		Tween:Play()
	end

	return NewElementObject
end

function ComposerScheduler.Compose_Create(StartingComposition: _InterfaceWorksComposition)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				["Parent"] = nil,
				["Composition"] = StartingComposition,
				["Arguments"] = {},
				["ID"] = nil,
				["IsRoot"] = true,
			},
		}
		for _, Render in RenderQueue do
			local NewStroke, NewBuild = CreateStroke(Render)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: { InterfaceWorksElement & { Parent: InterfaceWorksObject | InterfaceWorksStroke, Name: string } } =
				{}
			local ChildrenPointer = 0

			for name, element in NewBuild do
				element["Name"] = name
				element["Parent"] = NewStroke
				table.insert(Children, element :: any)
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer
				local ElementName = ElementContainer.Name
				local SourceObject: InterfaceWorksBase = ElementContainer.Parent

				if Element.Type == "Object" then
					local NewObject = CreateObject(Element, ElementName, SourceObject)

					for name: string | number, ChildElement: InterfaceWorksElement in Element.Cn do
						ChildElement["Parent"] = NewObject
						ChildElement["Name"] = name
						table.insert(
							Children,
							ChildElement :: InterfaceWorksElement & { Parent: InterfaceWorksObject, Name: string }
						)
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
			NewStroke[RootProperties].Init = true
		end
		ComposerScheduler.CurrentComposition = nil
	end)
end

function ComposerScheduler.Compose_Reuse(StartingComposition: _InterfaceWorksComposition, Reuse: Instance)
	return Jobs.CreateJob(function(Environment)
		local RenderQueue: InterfaceWorksRenderingSchedule = {
			{
				["Parent"] = nil,
				["Composition"] = StartingComposition,
				["Arguments"] = {},
				["ID"] = nil,
				["IsRoot"] = true,
				["Reuse"] = Reuse,
			},
		}
		for _, Render in RenderQueue do
			local NewStroke, NewBuild = CreateStroke(Render, Render.Reuse)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: {
				InterfaceWorksElement
				& { Name: string, Parent: InterfaceWorksElement | InterfaceWorksStroke, ParentInstance: Instance }
			} =
				{}
			local ChildrenPointer = 0

			for name, element in NewBuild do
				element["Name"] = name
				element["Parent"] = NewStroke
				element["ParentInstance"] = Render.Reuse
				table.insert(Children, element)
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer
				local ElementName = ElementContainer.Name
				local SourceObject = ElementContainer.Parent
				local SourceInstance = ElementContainer.ParentInstance

				local DirtyHost: Instance? = SourceInstance[ElementName]

				if not DirtyHost then
					continue
				end

				if Element.Type == "Object" then
					local NewElementObject: InterfaceWorksObject = Object.New(DirtyHost)
					SourceObject:Insert(NewElementObject, ElementName, true)

					for fndata: string, fn: (any) -> any in Element.Fs or {} do
						if InputTypes[fndata] then
							local Worker: InterfaceWorksWorker? = InputTypes[fndata](NewElementObject, fn)

							if Worker then
								table.insert(NewElementObject.Workers, Worker)
							end
							continue
						end
						NewElementObject[fndata] = function()
							fn(NewElementObject)
						end
					end

					for name: string | number, element in Element.Cn do
						element["Name"] = name
						element["Parent"] = NewElementObject
						element["ParentInstance"] = DirtyHost
						table.insert(Children, element)
					end

					if Element.Mt then
						Element.Mt:AddTarget(NewElementObject)
					end
					if Element.An then
						local AD = Element.An

						if AD.BeginningPoint then
							for prop, data in AD.BeginningPoint do
								DirtyHost[prop] = data
							end
						end

						local Tween = TweenService:Create(DirtyHost, AD.TI, AD.Goals)

						table.insert(NewElementObject.Animations, Tween)

						Tween.Completed:Connect(function()
							table.remove(NewElementObject.Animations, table.find(NewElementObject.Animations, Tween))
							Tween:Destroy()
						end)

						Tween:Play()
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
			NewStroke[RootProperties].Init = true
		end
		ComposerScheduler.CurrentComposition = nil
	end)
end

function ComposerScheduler.ReCompose(Init: InterfaceWorksStroke)
	return Jobs.CreateJob(function(Environment: { [string]: { any } })
		local Strokes = { Init }
		for _, Stroke in Strokes do
			ComposerScheduler.CurrentComposition = Stroke

			Stroke:ResetPosition()

			local OldBuild = Environment.Last or Stroke.CurrentComposition
			local NewBuild = Stroke.RetracingComposition()
			Environment.Last = NewBuild

			local Children: {
				InterfaceWorksElement & {
					Object: InterfaceWorksObject,
					Old: (InterfaceWorksElement & { IsProcessed: boolean? })?,
					Name: string?,
					ParentObject: InterfaceWorksObject?,
				}
			} =
				{}

			local function CompareChildren(
				Old: { InterfaceWorksElement },
				New: { InterfaceWorksElement },
				ParentObject: InterfaceWorksBase
			)
				for i: number, InterfaceWorksElement in New do
					if Old[i] == nil then
						InterfaceWorksElement["Name"] = i
						InterfaceWorksElement["ParentObject"] = ParentObject
						table.insert(Children, InterfaceWorksElement)
					elseif InterfaceWorksElement.Type ~= "Property" then
						InterfaceWorksElement["Object"] = ParentObject[i]
						InterfaceWorksElement["Old"] = Old[i]
						table.insert(Children, InterfaceWorksElement)
					end
				end
				for i: number, InterfaceWorksElement in Old do
					if New[i] == nil then
						local OldInstance: any = ParentObject[i]
						OldInstance:Destroy()
					end
				end
			end

			CompareChildren(OldBuild, NewBuild, Stroke)

			local Pointer = 0

			Environment.Changes = Environment.Changes or {}

			while #Children ~= Pointer do
				Pointer += 1

				local CurrentStruct = Children[Pointer]
				local CurrentElement = CurrentStruct
				local OldElement = CurrentStruct.Old
				CurrentStruct.Old = nil -- keep this to prevent old compositions not being garbage collected

				local ElementObject = CurrentStruct.Object
					or CreateObject(CurrentElement, CurrentStruct.Name, CurrentStruct.ParentObject)
				local ElementInstance = ElementObject.Host

				if
					CurrentElement.Type == "Object" and Environment.Changes[ElementInstance] == nil
					or Environment.Changes[ElementInstance] == true
				then -- this line very broken yes yes
					if OldElement then
						Environment.Changes[ElementInstance] = false
						for prop, val in CurrentElement.Ps or {} do
							if OldElement.Ps[prop] ~= val then
								ElementInstance[prop] = val
								Environment.Changes[ElementInstance] = true
							end
						end

						if CurrentElement.Fs and CurrentElement.Fs[InputTypesEnums.Render] then
							InputTypes[InputTypesEnums.Render](ElementObject, CurrentElement.Fs[InputTypesEnums.Render])
						end

						if CurrentElement.An then
							local AD = CurrentElement.An

							if AD.BeginningPoint and AD.BeginningPointRepeats then
								for prop, data in AD.BeginningPoint or {} do
									ElementInstance[prop] = data
								end
							end

							local Tween = TweenService:Create(ElementInstance, AD.TI, AD.Goals)

							table.insert(ElementObject.Animations, Tween)

							Tween.Completed:Connect(function()
								table.remove(ElementObject.Animations, table.find(ElementObject.Animations, Tween))
								Tween:Destroy()
							end)

							Tween:Play()
						end
					end

					CompareChildren(OldElement.Cn, CurrentElement.Cn, ElementObject)
				elseif CurrentElement.Type == "Fragment" then
					for dt, val in CurrentElement.FragmentArguments or {} do
						if OldElement.FragmentArguments[dt] ~= val then
							table.insert(Strokes, ElementObject)
							break
						end
					end
				end
			end

			Stroke.CurrentComposition = NewBuild
		end
	end)
end

return ComposerScheduler
