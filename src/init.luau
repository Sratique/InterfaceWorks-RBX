local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement

local Root = require("@BaseObject/Root")
local InputTypes = require("@Root/Forward/InputTypesEnums")
local Property = require("@Root/Forward/Property")
local Value = require("@Root/Forward/ValueController")

local InterfaceWorks = {}
InterfaceWorks.Trees = {}

InterfaceWorks.Value = Value
InterfaceWorks.InputTypes = InputTypes
InterfaceWorks.CreateProperty = Property
InterfaceWorks.Types = types

function InterfaceWorks.GetRoot(RID: string)
	return InterfaceWorks.Trees[RID]
end

function InterfaceWorks.CreateRoot(Container: Instance?, SaveAs: string?)
	local Base = Container or Instance.new("ScreenGui")

	local NewTreeRoot = Root.New(Base)

	if SaveAs then
		InterfaceWorks.Trees[SaveAs] = NewTreeRoot
	end

	return NewTreeRoot
end

function InterfaceWorks.CreateElement(Classname: string, Properties, Functions, Children): InterfaceWorksElement
	local Struct = {

		ID = Classname,
		Ps = Properties,
		Fs = Functions,
		Cn = Children,
		Type = "Object",
	}

	return Struct
end

function InterfaceWorks.CreateFragment(Composition: () -> InterfaceWorksElement, FragmentName: string)
	local Struct = {
		Type = "Fragment",
		Composition = Composition,
		FragmentName = FragmentName,
	}

	return Struct
end

return InterfaceWorks
