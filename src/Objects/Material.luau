--!nonstrict

local RunService = game:GetService("RunService")

local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase
local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker
local InterfaceWorksObject = require("@Objects/Object")
type InterfaceWorksObject = InterfaceWorksObject.InterfaceWorksObject

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local MaterialObject = {}
MaterialObject.__index = setmetatable(MaterialObject, BaseObject)

export type InterfaceWorksMaterial =
	BaseObject.InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			Targets: { InterfaceWorksObject },
			ReactivityWorkers: { InterfaceWorksWorker },
			ReactivityFunction: (InterfaceWorksObject) -> ...() -> (),
			ConstantReactivityWorker: InterfaceWorksWorker,
			Properties: { [string | "Default"]: { [string]: any } },
		},
		MaterialObject
	))

function MaterialObject.New(
	DefaultProperties: { [string | "Default"]: { [string]: any } },
	Reactivity: (InterfaceWorksObject) -> ...() -> (),
	ConstantReactivity: (InterfaceWorksObject) -> ()?
): InterfaceWorksMaterial
	local NewBaseObject: InterfaceWorksBase = BaseObject.New()

	local NewMaterialObject = setmetatable(NewBaseObject :: InterfaceWorksMaterial, MaterialObject)

	ProtectedObject.LayerInheritance(NewMaterialObject, "InterfaceWorksMaterial")

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
	if not Object.Host or not Object.Host:IsA("GuiObject") then
		return
	end

	for name: string, data: any in pairs(self.Properties.Default or {}) do
		Object.Host[name] = data
	end
	for name: string, data: any in pairs(self.Properties[Object.Host.ClassName] or {}) do
		Object.Host[name] = data
	end
	if self.ReactivityFunction then
		self.ReactivityWorkers[Object.Host] = InterfaceWorksWorker.New(self.ReactivityFunction(Object))
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

	self:__Destroy()
end

return MaterialObject
