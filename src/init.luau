if game:GetService("RunService"):IsRunning() or game:GetService("RunService"):IsServer() then
	warn(
		"Running InterfaceWorks (combined) version: "
			.. _G.VERSION
			.. "@"
			.. _G.CHANNEL
			.. " on interpreter version: "
			.. version()
	)
end

if _G.InterfaceWorksDebug then
	local SpecificVersion = string.split(version(), ".")

	local ShellGeneration = SpecificVersion[1]
	local ReleaseVer = SpecificVersion[2]
	local PatchNmbr = SpecificVersion[3]
	local CommitID = SpecificVersion[4]

	local Scheduler = require("@Root/Internal/Composer/Scheduler")
	local Jobs = require("@Root/Internal/Composer/Jobs")
	local Tickets = require("@Root/Internal/Composer/Tickets")

	warn(
		"Debugging info: \n"
			.. "----------------------[ROBLOX CLIENT INFO]----------------------\n"
			.. "Shell generation: "
			.. ShellGeneration
			.. "\n"
			.. "ReleaseVer: "
			.. ReleaseVer
			.. "\n"
			.. "Patch number: "
			.. PatchNmbr
			.. "\n"
			.. "Internal Commit ID: "
			.. CommitID
			.. "\n"
			.. "---------------------[InterfaceWorks INFO]----------------------\n"
			.. "Launched in: "
			.. elapsedTime()
			.. " seconds from *Client* start.\n"
			.. "Scheduler version: "
			.. Scheduler._VERSION
			.. "\n"
			.. "Jobs version: "
			.. Jobs._VERSION
			.. "\n"
			.. "Tickets version: "
			.. Tickets._VERSION
	)

	if _G.InterfaceWorksDebuggerKernel then
		_G.InterfaceWorksDebuggerKernel:CanInit(script)
	end
end

local types = require("@Root/structs")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksElementData = types.InterfaceWorksElementData
type InterfaceWorksAnimationData = types.InterfaceWorksAnimationData
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksElementType = types.InterfaceWorksElementType

local Root = require("@Objects/Root")
local InputTypes = require("@Root/Public/InputTypesEnums")
local Property = require("@Root/Public/Property")
local Materials = require("@Root/Public/MaterialController")
local Value = require("@Root/Public/ValueController")
local Event = require("@Root/Public/EventController")
local Assets = require("@Root/Public/AssetsBank")
local HelperFunctions = require("@Root/Public/HelperFunctions")

local InterfaceWorks = {}

InterfaceWorks.Value = Value
InterfaceWorks.Event = Event
InterfaceWorks.InputTypes = InputTypes
InterfaceWorks.CreateProperty = Property
InterfaceWorks.Materials = Materials
InterfaceWorks.Assets = Assets

function InterfaceWorks.CreateRoot(Container: Instance?)
	local Base = Container or Instance.new("ScreenGui")

	local NewTreeRoot = Root.New(Base)

	return NewTreeRoot
end

function InterfaceWorks.CreateElement(
	Classname: string,
	Data: InterfaceWorksElementData?,
	Children: { [number | string]: InterfaceWorksElement? }?
): InterfaceWorksElement
	Data = Data or {}
	Children = Children or {}

	local ElementType: InterfaceWorksElementType = "Object"

	local Struct = {

		ID = Classname,
		Key = Data and Data.Key,
		Ps = Data and Data.Properties,
		Fs = Data and Data.Functions,
		Mt = Data and Data.Material,
		An = Data and Data.Animation,
		Cn = Children,
		Type = ElementType,
	}

	return Struct
end

function InterfaceWorks.CreateAnimation(AnimationData: {
	Goals: { [string]: any },
	BeginningPoint: { any }?,
	BeginningPointRepeats: boolean?,
	Duration: number,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
	RepeatCount: number?,
	Reverses: boolean?,
	delayTime: number?,
}): InterfaceWorksAnimationData
	local NewAnimationData = {
		Goals = AnimationData.Goals,
		BeginningPoint = AnimationData.BeginningPoint,
		BeginningPointRepeats = AnimationData.BeginningPointRepeats,
		TI = TweenInfo.new(
			AnimationData.Duration,
			AnimationData.EasingStyle or Enum.EasingStyle.Linear,
			AnimationData.EasingDirection or Enum.EasingDirection.In,
			AnimationData.RepeatCount or 0,
			AnimationData.Reverses or false,
			AnimationData.delayTime or 0
		),
	}

	return NewAnimationData
end

function InterfaceWorks.CreateFragment(Composition: _InterfaceWorksComposition, ...: any): InterfaceWorksElement
	local ElementType: InterfaceWorksElementType = "Fragment"

	local Struct = {
		ID = nil,
		Type = ElementType,
		Composition = Composition,
		FragmentArguments = { ... },
		Cn = {},
	}

	return Struct
end

return setmetatable(InterfaceWorks, { __index = HelperFunctions })
