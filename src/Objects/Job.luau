local types = require("@Root/types")
type InterfaceWorksJob = types.InterfaceWorksJob

local BaseObject = require("@BaseObject")

local JobObject = {}
JobObject.__index = setmetatable(JobObject, BaseObject)

function JobObject.New(Function: (Environment: { [any]: any }, ...any) -> ()): InterfaceWorksJob
	local NewBaseObject = BaseObject.New()

	local NewJobObject = setmetatable(NewBaseObject, JobObject)

	NewJobObject.Function = Function
	NewJobObject.FinishedConnections = {}
	NewJobObject.Environment = {}
	NewJobObject.Arguments = {}

	NewJobObject.Init = false

	return NewJobObject
end

function JobObject:SetArgs(...: any)
	self.Arguments = { ... }
end

function JobObject:SetEnv(Env: { [any]: any })
	self.Environment = Env
end

function JobObject:GetArtifact()
	return self.Environment
end

function JobObject:Run(...: any)
	if select("#", ...) > 0 then
		self:SetArgs(...)
	end

	if self.Current then
		coroutine.close(self.Current)
	end

	self.Init = true

	self.Current = task.spawn(coroutine.create(function()
		self.Function(self.Environment, unpack(self.Arguments))
		for _, v in pairs(self.FinishedConnections) do
			v()
		end
	end))
end

function JobObject:Finished(callback: () -> ())
	table.insert(self.FinishedConnections, callback)
end

function JobObject:Destroy()
	self:__Destroy()
end

return JobObject
