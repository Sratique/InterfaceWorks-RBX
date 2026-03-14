warn("Running InterfaceWorks version: " .. _G.VERSION .. "@" .. _G.CHANNEL)

local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksElementData = types.InterfaceWorksElementData
type InterfaceWorksMaterial = types.InterfaceWorksMaterial

local Root = require("@BaseObject/Root")
local InputTypes = require("@Root/Forward/InputTypesEnums")
local Property = require("@Root/Forward/Property")
local Materials = require("@Root/Forward/Materials")
local Value = require("@Root/Forward/ValueController")

local InterfaceWorks = {}

InterfaceWorks.Value = Value
InterfaceWorks.InputTypes = InputTypes
InterfaceWorks.CreateProperty = Property
InterfaceWorks.Types = types
InterfaceWorks.Materials = Materials

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
		Cn = Children,
		Type = "Object",
	}

	return Struct
end

function InterfaceWorks.CreateFragment(
	Composition: () -> InterfaceWorksElement,
	FragmentName: string
): InterfaceWorksElement
	local Struct = {
		ID = nil,
		Type = "Fragment",
		Composition = Composition,
		FragmentName = FragmentName,
	}

	return Struct
end

return InterfaceWorks
