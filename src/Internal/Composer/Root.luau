local TweenService = game:GetService("TweenService")

local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type InterfaceWorksWorker = types.InterfaceWorksWorker
type InterfaceWorksObject = types.InterfaceWorksObject
type _InterfaceWorksComposition = types._InterfaceWorksComposition

local ComposerRoot = {}
ComposerRoot.CurrentComposition = nil

local Tickets = require("@Root/Internal/Composer/Tickets")
local Jobs = require("@Root/Internal/Composer/Jobs")
local InputTypes = require("@Root/Internal/InputTypesFunctions")
local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local Stroke = require("@Objects/Stroke")
local Object = require("@Objects/Object")

function ComposerRoot.Compose(
	Composition: _InterfaceWorksComposition,
	callback: (InterfaceWorksStroke) -> ()?,
	Arguments: { any }?,
	IsFragment: boolean?
)
	local Countdown = os.clock()

	local NewStroke = Stroke.New(Composition)
	local StrokeID = tostring(NewStroke.ID)

	local ComposeJob = Jobs.CreateJob(function(Environment: {}, NewBuild: { InterfaceWorksElement })
		if NewBuild == nil then
			error("Composition does not exist. Are you sure you are returning the composition?")
		end

		local Children = {}
		local Pointer = 0

		for name, element in pairs(NewBuild) do
			table.insert(Children, {
				["Name"] = name,
				["Element"] = element,
				["Parent"] = NewStroke,
			})
		end

		while Pointer ~= #Children do
			Pointer += 1

			local ElementContainer = Children[Pointer]
			local Element = ElementContainer.Element
			local ElementName = ElementContainer.Name
			local SourceObject = ElementContainer.Parent

			if Element.Type == "Fragment" then
				if not Element.Composition then
					continue
				end
				ComposerRoot.Compose(Element.Composition, function(NewFragment: InterfaceWorksStroke)
					NewFragment.Host.Name = ElementName
					SourceObject:Insert(NewFragment, ElementName)
				end, Element.FragmentArguments, true)
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
				if Element.Cn then
					for name, element in pairs(Element.Cn) do
						table.insert(Children, {
							["Name"] = name,
							["Element"] = element,
							["Parent"] = NewElementObject,
						})
					end
				end
			end
		end
	end)

	ComposeJob:Finished(function()
		print("Finished stroke! (" .. os.clock() - Countdown .. " ms)")
		print(NewStroke)
		NewStroke[RootProperties].Init = true
		ComposeJob:Destroy()
		Tickets.Invalidate()
	end)

	Tickets.New(if IsFragment then "Fragment" else "Compose", StrokeID, function()
		ComposerRoot.CurrentComposition = NewStroke

		local NewBuild = Composition(unpack(Arguments or {}))
		NewStroke.CurrentComposition = NewBuild

		ComposeJob:Run(NewBuild)
	end)

	if callback then
		callback(NewStroke)
	end
end

function ComposerRoot.ReCompose(Stroke: InterfaceWorksStroke, Initiator: InterfaceWorksValueID, Arguments: { any }?)
	local StrokeID = tostring(Stroke.ID)

	local ReComposeJob = Jobs.CreateJob(function(Environment: { [any]: any }, NewBuild)
    
        
    
    end)

	Tickets.New("Recompose", StrokeID .. Initiator, function()
    
        
    
    end)
end

return ComposerRoot
