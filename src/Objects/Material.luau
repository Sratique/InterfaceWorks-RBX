local RunService = game:GetService("RunService")

local types = require("@Root/types")
type InterfaceWorksMaterial = types.InterfaceWorksMaterial
type InterfaceWorksObject = types.InterfaceWorksObject

local BaseObject = require("@BaseObject")
local Worker = require("@BaseObject/Worker")

local MaterialObject = {}
MaterialObject.__index = setmetatable(MaterialObject, BaseObject)

function MaterialObject.New(
	DefaultProperties: { [string | "Default"]: { [string]: any } },
	Reactivity: (InterfaceWorksObject) -> ...RBXScriptConnection?,
	ConstantReactivity: (InterfaceWorksObject) -> ()?
): InterfaceWorksMaterial
	local NewBaseObject = BaseObject.New()

	local NewMaterialObject = setmetatable(NewBaseObject, MaterialObject)

	NewMaterialObject.Properties = DefaultProperties
	NewMaterialObject.Targets = {}
	NewMaterialObject.ReactivityWorkers = {}
	NewMaterialObject.ReactivityFunction = Reactivity

	if ConstantReactivity then
		NewMaterialObject.ConstantReactivityWorker = RunService.RenderStepped:Connect(function()
			for _, v: InterfaceWorksObject in pairs(NewMaterialObject.Targets) do
				ConstantReactivity(v)
			end
		end)
	end

	return NewMaterialObject
end

function MaterialObject:AddTarget(Object: InterfaceWorksObject)
	for name: string, data: any in pairs(self.Properties.Default or {}) do
		Object.Host[name] = data
	end
	for name: string, data: any in pairs(self.Properties[Object.Host.ClassName] or {}) do
		Object.Host[name] = data
	end
	if self.ReactivityFunction then
		self.ReactivityWorkers[Object.Host] = Worker.New(self.ReactivityFunction(Object))
	end

	table.insert(self.Targets, Object)
	Object:Destroying(function()
		table.remove(self.Targets, table.find(self.Targets, Object))
		self.ReactivityWorkers[Object.Host]:Disconnect()
	end)
end

function MaterialObject:Destroy()
	if self.ConstantReactivityWorker then
		self.ConstantReactivityWorker:Disconnect()
	end
	for _, v in pairs(self.ReactivityWorkers) do
		v:Disconnect()
	end
end

return MaterialObject
