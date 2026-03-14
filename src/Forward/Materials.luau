local types = require("@Root/types")
type InterfaceWorksMaterial = types.InterfaceWorksMaterial
type InterfaceWorksObject = types.InterfaceWorksObject

local Materials = {}

local MaterialObject = require("@Root/Objects/Material")

function Materials.New(
	DefaultProperties: { [string | "Default"]: { [string]: any } },
	Reactivity: (InterfaceWorksObject) -> ...RBXScriptConnection,
	ConstantReactivity: (InterfaceWorksObject) -> ()
): InterfaceWorksMaterial
	local NewMaterialObject = MaterialObject.New(DefaultProperties, Reactivity, ConstantReactivity)

	return NewMaterialObject
end

function Materials.Remove() end

return Materials
