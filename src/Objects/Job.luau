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
	NewJobObject.IsRunning = false

	NewJobObject.Coro = coroutine.create(function()
		NewJobObject.Function(NewJobObject.Environment, unpack(NewJobObject.Arguments))
		for _, v in pairs(NewJobObject.FinishedConnections) do
			v()
		end
		NewJobObject.IsRunning = false
	end)

	return NewJobObject
end

function JobObject:SetArgs(...: any)
	self.Arguments = { ... }
end

function JobObject:GetArtifact()
	return self.Environment
end

function JobObject:Run(...: any)
	if self.IsRunning then
		return
	end

	if select("#", ...) > 0 then
		self:SetArgs(...)
	end

	self.Init = true
	self.IsRunning = true

	task.spawn(self.Coro)
end

function JobObject:Finished(callback: () -> ())
	table.insert(self.FinishedConnections, callback)
end

function JobObject:Destroy()
	self:__Destroy()
end

return JobObject
