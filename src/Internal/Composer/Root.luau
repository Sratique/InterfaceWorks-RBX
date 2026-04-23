local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type InterfaceWorksWorker = types.InterfaceWorksWorker
type InterfaceWorksObject = types.InterfaceWorksObject
type _InterfaceWorksComposition = types._InterfaceWorksComposition

local ComposerRoot = {}

local Tickets = require("@Root/Internal/Composer/Tickets")
local Scheduler = require("./Scheduler")
local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

function ComposerRoot.Compose(
	Composition: _InterfaceWorksComposition,
	callback: (InterfaceWorksStroke) -> ()?,
	ID: string?
)
	debug.setmemorycategory("Composer_New:TYPE(StrokeObject)")

	local Ticket, Existing = Tickets.New("Compose", ID, function(self)
		local ComposeJob = Scheduler.Compose_Create(Composition)

		ComposeJob:Finished(function()
			local NewStroke = ComposeJob.Environment.Stroke

			NewStroke[RootProperties].Init = true
			Tickets.Invalidate()
			ComposeJob:Destroy()
			if callback then
				debug.setmemorycategory("Composer_Callback:TYPE(Stroke")
				callback(NewStroke)
			end
		end)

		self.Environment.Job = ComposeJob

		debug.setmemorycategory("Composer_Create:TYPE(Stroke)")
		ComposeJob:Run()
	end)

	if Existing then
		Ticket:Destroying(function()
			if Ticket.Environment.Job then
				local Dirty: Instance = Ticket.Environment.Job.Environment.Stroke.Host:Clone()
				warn("Cloned ticket artefact. Reusing dirty hosts.")
				Tickets.New("Compose", nil, function()
					local DirtyComposeJob = Scheduler.Compose_Reuse(Composition, Dirty)

					DirtyComposeJob:Finished(function()
						Tickets.Invalidate()

						local NewStroke = DirtyComposeJob.Environment.Stroke

						NewStroke[RootProperties].Init = true
						DirtyComposeJob:Destroy()
						if callback then
							debug.setmemorycategory("Composer_Callback:TYPE(Stroke")
							callback(NewStroke)
						end
					end)

					debug.setmemorycategory("Composer_Create:TYPE(Stroke)")
					DirtyComposeJob:Run()
				end)
			end
		end)
	end
end

function ComposerRoot.ReCompose(Stroke: InterfaceWorksStroke, Initiator: InterfaceWorksValueID, Arguments: { any }?)
	--[[local StrokeID = tostring(Stroke.ID)]]

	--[[local DiffJob = Jobs.CreateJob(function(Environment: { [any]: any }, NewBuild, OldBuild)
		if Environment.Changes then
		else
			Environment.Changes = {}
		end
	end)]]

	--[[Tickets.New("Recompose", StrokeID .. Initiator, function()
		DiffJob:Run()
	end)]]
end

return ComposerRoot
