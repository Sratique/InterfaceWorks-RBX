if not game:GetService("RunService"):IsStudio() then
	warn("Running InterfaceWorks version: " .. _G.VERSION .. "@" .. _G.CHANNEL)
end

local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksElementData = types.InterfaceWorksElementData
type InterfaceWorksMaterial = types.InterfaceWorksMaterial
type InterfaceWorksAnimationData = types.InterfaceWorksAnimationData

local Root = require("@Objects/Root")
local InputTypes = require("@Root/Public/InputTypesEnums")
local Property = require("@Root/Public/Property")
local Materials = require("@Root/Public/MaterialController")
local Value = require("@Root/Public/ValueController")
local Assets = require("@Root/Public/AssetsBank")

local InterfaceWorks = {}

InterfaceWorks.Value = Value
InterfaceWorks.InputTypes = InputTypes
InterfaceWorks.CreateProperty = Property
InterfaceWorks.Types = types
InterfaceWorks.Materials = Materials
InterfaceWorks.Assets = Assets

function InterfaceWorks.CreateRoot(Container: Instance?)
	local Base = Container or Instance.new("ScreenGui")

	local NewTreeRoot = Root.New(Base)

	return NewTreeRoot
end

function InterfaceWorks.CreateElement(
	Classname: string,
	Data: InterfaceWorksElementData,
	Children
): InterfaceWorksElement
	Data = Data or {}
	Children = Children or {}

	local Struct = {

		ID = Classname,
		Ps = Data.Properties,
		Fs = Data.Functions,
		Mt = Data.Material,
		An = Data.Animation,
		Cn = Children,
		Type = "Object",
	}

	return Struct
end

function InterfaceWorks.CreateAnimation(AnimationData: {
	Goals: { [string]: any },
	Duration: number,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
	RepeatCount: number?,
	Reverses: boolean?,
	delayTime: number?,
}): InterfaceWorksAnimationData
	local NewAnimationData = {
		Goals = AnimationData.Goals,
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

function InterfaceWorks.CreateFragment(Composition: () -> InterfaceWorksElement, ...: any): InterfaceWorksElement
	local Struct = {
		ID = nil,
		Type = "Fragment",
		Composition = Composition,
		FragmentArguments = { ... },
	}

	return Struct
end

return InterfaceWorks
