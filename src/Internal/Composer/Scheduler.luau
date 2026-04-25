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

local Stroke = require("@Objects/Stroke")
local Object = require("@Objects/Object")

local function CreateStroke(Render, Reuse): (InterfaceWorksStroke, { InterfaceWorksElement })
	local CurrentComposition = Render.Composition

	local NewStroke = Stroke.New(CurrentComposition, Render.ID, Reuse)

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

			local Children = {}
			local ChildrenPointer = 0

			for name, element in pairs(NewBuild) do
				table.insert(Children, {
					["Name"] = name,
					["Element"] = element,
					["Parent"] = NewStroke,
				})
			end

			while ChildrenPointer ~= #Children do
				ChildrenPointer += 1

				local ElementContainer = Children[ChildrenPointer]
				local Element = ElementContainer.Element
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

					for name: string | number, element: InterfaceWorksElement in pairs(Element.Cn) do
						table.insert(Children, {
							["Name"] = name,
							["Element"] = element,
							["Parent"] = NewElementObject,
						})
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

				local DirtyHost = SourceInstance:FindFirstChild(ElementName)

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
		end
		ComposerScheduler.CurrentComposition = nil
	end)
end

function ComposerScheduler.ReCompose(Stroke: InterfaceWorksStroke) end

return ComposerScheduler
