local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local Worker = {}
Worker.__index = setmetatable(Worker, BaseObject)

function Worker.New(...: any): InterfaceWorksWorker
	local NewBaseObject = BaseObject.New()

	local NewWorker: InterfaceWorksWorker = setmetatable(NewBaseObject, Worker)

	ProtectedObject.LayerInheritance(NewWorker, "InterfaceWorksWorker")

	NewWorker.SelfProcesses = {}

	for i, v: () -> () in { ... } do
		NewWorker.SelfProcesses[i] = v
	end

	return NewWorker
end

function Worker:Destroy()
	for _, v: () -> () in pairs(self.SelfProcesses) do
		v()
	end

	self:__Destroy()
end

function Worker:Disconnect()
	for _, v: () -> () in pairs(self.SelfProcesses) do
		v()
	end

	self:__Destroy()
end

return Worker
