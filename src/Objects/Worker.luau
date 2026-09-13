local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local Worker = {}
Worker.__index = setmetatable(Worker, BaseObject)

export type InterfaceWorksWorker =
	InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			SelfProcess: () -> ()?,
			Reference: (() -> (() -> ())?)?,
		},
		Worker
	))

function Worker.New(Cleanup: (...any) -> ...any): InterfaceWorksWorker
	local NewBaseObject = BaseObject.New()

	local NewWorker: InterfaceWorksWorker = setmetatable(NewBaseObject :: InterfaceWorksWorker, Worker)

	ProtectedObject.LayerInheritance(NewWorker, "InterfaceWorksWorker")

	NewWorker.SelfProcess = Cleanup

	return NewWorker
end

function Worker.__Clear(self: InterfaceWorksWorker, Final: boolean?)
	if self.SelfProcess then
		self.SelfProcess()
	end

	if Final then
		self.Reference = nil
	end
end

function Worker.Update(self: InterfaceWorksWorker)
	self:__Clear()

	if not self.Reference then
		return
	end

	self.SelfProcess = self.Reference()
end

function Worker.Destroy(self: InterfaceWorksWorker)
	self:__Clear(true)
	self:__Destroy()
end

function Worker.Disconnect(self: InterfaceWorksWorker)
	self:__Clear(true)
	self:__Destroy()
end

return Worker
