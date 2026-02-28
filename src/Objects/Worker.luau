local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject

local BaseObject = require("@BaseObject")

local Worker = {}
Worker.__index = setmetatable(Worker, BaseObject)

function Worker.Env(
	self: InterfaceWorksObject,
	SandboxContainer: (self: InterfaceWorksObject) -> ()
): (Object: InterfaceWorksObject) -> ()
	return function()
		SandboxContainer(self)
	end
end

function Worker.Sandbox(...)
	local Connections: { RBXScriptConnection } = { ... }

	return function()
		for _, v: RBXScriptConnection in pairs(Connections) do
			v:Disconnect()
		end
	end
end

return Worker
