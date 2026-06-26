local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local Worker = {}
Worker.__index = setmetatable(Worker, BaseObject)

export type InterfaceWorksWorker =
	InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			SelfProcesses: { () -> () },
		},
		Worker
	))

function Worker.New(...: any): InterfaceWorksWorker
	local NewBaseObject = BaseObject.New()

	local NewWorker: InterfaceWorksWorker = setmetatable(NewBaseObject :: InterfaceWorksWorker, Worker)

	ProtectedObject.LayerInheritance(NewWorker, "InterfaceWorksWorker")

	NewWorker.SelfProcesses = {}

	for i, v: () -> () in { ... } do
		NewWorker.SelfProcesses[i] = v
	end

	return NewWorker
end

function Worker.Destroy(self: InterfaceWorksWorker)
	for _, v: () -> () in pairs(self.SelfProcesses) do
		v()
	end

	self:__Destroy()
end

function Worker.Disconnect(self: InterfaceWorksWorker)
	for _, v: () -> () in pairs(self.SelfProcesses) do
		v()
	end

	self:__Destroy()
end

return Worker
