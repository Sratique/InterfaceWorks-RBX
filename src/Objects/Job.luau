local BaseObject = require("@BaseObject")

local JobObject = {}
JobObject.__index = setmetatable(JobObject, BaseObject)

export type InterfaceWorksJob =
	BaseObject.InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			Environment: { [any]: any },
			Current: thread?,
			Function: (Environment: { [any]: any }, ...any) -> (),
			FinishedConnections: { () -> () },
			Arguments: { [any]: any },
			Init: boolean,
		},
		JobObject
	))

function JobObject.New(Function: (Environment: { [any]: any }, ...any) -> ()): InterfaceWorksJob
	local NewBaseObject = BaseObject.New()

	local NewJobObject = setmetatable(NewBaseObject :: InterfaceWorksJob, JobObject)

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
		table.clear(self.FinishedConnections)
		coroutine.close(self.Current)
	end

	self.Init = true

	self.Current = task.defer(coroutine.create(function()
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
	self.Function = nil
	table.clear(self.FinishedConnections)
	table.clear(self.Environment)
	table.clear(self.Arguments)

	self:__Destroy()
end

return JobObject
