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
			Reference: { (...any) -> ...any },
		},
		Worker
	))

function Worker.New(...: (...any) -> ...any): InterfaceWorksWorker
	local NewBaseObject = BaseObject.New()

	local NewWorker: InterfaceWorksWorker = setmetatable(NewBaseObject :: InterfaceWorksWorker, Worker)

	ProtectedObject.LayerInheritance(NewWorker, "InterfaceWorksWorker")

	NewWorker.SelfProcesses = {}
	NewWorker.Reference = { ... }

	for i, v in { ... } do
		NewWorker.SelfProcesses[i] = v
	end

	return NewWorker
end

function Worker.__Clear(self: InterfaceWorksWorker)
	for _, v: () -> () in pairs(self.SelfProcesses) do
		v()
	end
end

function Worker.Update(self: InterfaceWorksWorker)
	self:__Clear()

	for i, v in self.Reference do
		self.SelfProcesses[i] = v
	end
end

function Worker.Destroy(self: InterfaceWorksWorker)
	self:__Clear()

	table.clear(self.Reference)

	self:__Destroy()
end

function Worker.Disconnect(self: InterfaceWorksWorker)
	self:__Clear()

	table.clear(self.Reference)

	self:__Destroy()
end

return Worker
