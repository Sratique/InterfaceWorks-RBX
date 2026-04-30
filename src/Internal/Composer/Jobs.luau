local ComposerJobs = {}
ComposerJobs._VERSION = _G.JobsVersion

local Job = require("@Objects/Job")

function ComposerJobs.CreateJob(Function: (Environment: { [any]: any }, ...any) -> (), ...: any)
	local NewJob = Job.New(Function)

	if select("#", ...) > 0 then
		NewJob:SetArgs(...)
	end

	return NewJob
end

return ComposerJobs
