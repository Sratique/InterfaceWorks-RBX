local Job = require("@Objects/Job")
local ComposerJobs = {}

function ComposerJobs.CreateJob(Function: (Environment: { [any]: any }, ...any) -> (), ...: any)
	local NewJob = Job.New(Function)

	if select("#", ...) > 0 then
		NewJob:SetArgs(...)
	end

	return NewJob
end

return ComposerJobs
