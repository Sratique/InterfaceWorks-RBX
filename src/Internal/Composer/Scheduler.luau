local TweenService = game:GetService("TweenService")

local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type InterfaceWorksWorker = types.InterfaceWorksWorker
type InterfaceWorksObject = types.InterfaceWorksObject
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksRenderingSchedule = types.InterfaceWorksRenderingSchedule

local ComposerScheduler = {}
ComposerScheduler._VERSION = _G.SchedulerVersion

local Jobs = require("@Root/Internal/Composer/Jobs")
local InputTypes = require("@Root/Internal/InputTypesFunctions")
local InputTypesEnums = require("@Root/Public/InputTypesEnums")
local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local StrokeObject = require("@Objects/Stroke")
local Object = require("@Objects/Object")

local function CreateStroke(Render, Reuse): (InterfaceWorksStroke, { InterfaceWorksElement })
	local CurrentComposition = Render.Composition

	local NewStroke = StrokeObject.New(CurrentComposition, Render.ID, Reuse)

	ComposerScheduler.CurrentComposition = NewStroke

	local NewBuild = CurrentComposition(unpack(Render.Arguments))
	NewStroke.CurrentComposition = NewBuild

	return NewStroke, NewBuild
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
		for _, Render in pairs(RenderQueue) do
			local NewStroke, NewBuild = CreateStroke(Render)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children: { InterfaceWorksElement & { Parent: InterfaceWorksObject | InterfaceWorksStroke, Name: string } } =
				{}
			local ChildrenPointer = 0

			for name, element in pairs(NewBuild) do
				element["Name"] = name
				element["Parent"] = NewStroke
				table.insert(Children, element)
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer
				local ElementName = ElementContainer.Name
				local SourceObject = ElementContainer.Parent

				if Element.Type == "Object" then
					local Host: any = Instance.new(Element.ID)
					Host.Name = ElementName

					for prop: string, val: any in pairs(Element.Ps or {}) do
						Host[prop] = val
					end

					local NewElementObject: InterfaceWorksObject = Object.New(Host)
					SourceObject:Insert(NewElementObject, ElementName)

					for fndata: string, fn: (any) -> any in pairs(Element.Fs or {}) do
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

					for name: string | number, ChildElement in pairs(Element.Cn) do
						ChildElement["Parent"] = NewElementObject
						ChildElement["Name"] = name
						table.insert(Children, ChildElement)
					end

					if Element.Mt then
						Element.Mt:AddTarget(NewElementObject)
					end
					if Element.An then
						local AD = Element.An

						if AD.BeginningPoint then
							for prop, data in pairs(AD.BeginningPoint) do
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
				elseif Element.Type == "Property" then
					local HeadlessHost = Instance.new(Element.ID)
					for prop: string, val: any in pairs(Element.Ps or {}) do
						HeadlessHost[prop] = val
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
		for _, Render in pairs(RenderQueue) do
			local NewStroke, NewBuild = CreateStroke(Render, Render.Reuse)

			if Render.Parent then
				Render.Parent:Insert(NewStroke, Render.ID)
			else
				Environment.Stroke = NewStroke
			end

			local Children = {}
			local ChildrenPointer = 0

			for name, element in pairs(NewBuild) do
				table.insert(Children, {
					["Name"] = name,
					["Element"] = element,
					["Parent"] = NewStroke,
					["ParentInstance"] = Render.Reuse,
				})
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer.Element
				local ElementName = ElementContainer.Name
				local SourceObject = ElementContainer.Parent
				local SourceInstance = ElementContainer.ParentInstance

				local DirtyHost: GuiObject? = SourceInstance[ElementName]

				if not DirtyHost then
					continue
				end

				if Element.Type == "Object" then
					local NewElementObject: InterfaceWorksObject = Object.New(DirtyHost)
					SourceObject:Insert(NewElementObject, ElementName, true)

					for fndata: string, fn: (any) -> any in pairs(Element.Fs or {}) do
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

					for name: string | number, element: InterfaceWorksElement in pairs(Element.Cn) do
						table.insert(Children, {
							["Name"] = name,
							["Element"] = element,
							["Parent"] = NewElementObject,
							["ParentInstance"] = DirtyHost,
						})
					end

					if Element.Mt then
						Element.Mt:AddTarget(NewElementObject)
					end
					if Element.An then
						local AD = Element.An

						if AD.BeginningPoint then
							for prop, data in pairs(AD.BeginningPoint) do
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
	debug.setmemorycategory("Scheduler_ChildrenTable:CREATE")

	return Jobs.CreateJob(function(Environment: { [string]: { any } })
		local t = os.clock()
		local Strokes = { Init }
		for _, Stroke in Strokes do
			ComposerScheduler.CurrentComposition = Stroke

			Stroke:ResetPosition()

			local OldBuild = Environment.Last or Stroke.CurrentComposition
			local NewBuild = Stroke.RetracingComposition()
			Environment.Last = NewBuild

			local Children: { InterfaceWorksElement & { Object: InterfaceWorksObject, New: InterfaceWorksElement } } =
				{}
			local Pointer = 0

			--Function--(A)--

			for i: number, InterfaceWorksElement in pairs(OldBuild) do
				if NewBuild[i] == nil then
					local OldInstance: any = Stroke[i]
					OldInstance:Destroy()
				else
					InterfaceWorksElement["Object"] = Stroke[i]
					InterfaceWorksElement["New"] = NewBuild[i]
					table.insert(Children, InterfaceWorksElement)
				end
			end

			Environment.Changes = Environment.Changes or {}

			while #Children ~= Pointer do
				Pointer += 1

				local CurrentStruct = Children[Pointer]
				local CurrentElement = CurrentStruct.New
				local OldElement = CurrentStruct

				local ElementObject = CurrentStruct.Object
				local ElementInstance = ElementObject.Host

				if CurrentElement.Type == "Object" and not Environment.Changes[ElementInstance] then
					for prop, val in CurrentElement.Ps do
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
							for prop, data in pairs(AD.BeginningPoint) do
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

					--Function--(A)--

					for i: number, InterfaceWorksElement in pairs(OldElement.Cn) do
						if CurrentElement.Cn[i] == nil then
							local OldInstance: any = ElementObject[i]
							OldInstance:Destroy()
						else
							InterfaceWorksElement["Object"] = ElementObject[i]
							InterfaceWorksElement["New"] = CurrentElement.Cn[i]
							table.insert(Children, InterfaceWorksElement)
						end
					end
				elseif CurrentElement.Type == "Fragment" then
					for dt, val in CurrentElement.FragmentArguments do
						if OldElement.FragmentArguments[dt] ~= val then
							table.insert(Strokes, ElementObject)
							break
						end
					end
				end
				CurrentElement["IsProcessed"] = true and not Environment.Changes[ElementInstance]
			end

			Stroke.CurrentComposition = NewBuild
		end
		print(os.clock() - t)
	end)
end

return ComposerScheduler
