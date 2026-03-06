local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")

local Worker = {}
Worker.__index = setmetatable(Worker, BaseObject)

function Worker.New(...): InterfaceWorksWorker
	local NewBaseObject = BaseObject.New()

	local NewWorker: InterfaceWorksWorker = setmetatable(NewBaseObject, Worker)
	NewWorker.SelfProcesses = {}

	for i, v: RBXScriptConnection | () -> () in { ... } do
		NewWorker.SelfProcesses[i] = v
	end

	return NewWorker
end

function Worker:Disconnect()
	for _, v: RBXScriptConnection in pairs(self.SelfProcesses) do
		v:Disconnect()
	end
end

return Worker
