local InterfaceWorksObject = require("@Objects/Object")
type InterfaceWorksObject = InterfaceWorksObject.InterfaceWorksObject

local InterfaceWorksMaterial = require("@Root/Objects/Material")
type InterfaceWorksMaterial = InterfaceWorksMaterial.InterfaceWorksMaterial

local Materials = {}

function Materials.New(
	DefaultProperties: { [string | "Default"]: { [string]: any } },
	Reactivity: (InterfaceWorksObject) -> ...() -> (),
	ConstantReactivity: (InterfaceWorksObject) -> ()?
): InterfaceWorksMaterial
	local NewMaterialObject = InterfaceWorksMaterial.New(DefaultProperties, Reactivity, ConstantReactivity)

	return NewMaterialObject
end

function Materials.Remove() end

return Materials
