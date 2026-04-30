local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type InterfaceWorksWorker = types.InterfaceWorksWorker
type InterfaceWorksObject = types.InterfaceWorksObject
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksJob = types.InterfaceWorksJob

local ComposerRoot = {}

local Tickets = require("@Root/Internal/Composer/Tickets")
local Scheduler = require("./Scheduler")

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
			local InitJob: InterfaceWorksJob = Ticket.Environment.Job
			if InitJob then
				local Stroke: InterfaceWorksStroke? = InitJob.Environment.Stroke
				if not Stroke then
					warn("Corrupted ticket. - InterfaceWorks:Root")
					return
				end
				local Dirty: Instance = Stroke.Host:Clone()
				Tickets.New("Compose", nil, function()
					local DirtyComposeJob = Scheduler.Compose_Reuse(Composition, Dirty)

					DirtyComposeJob:Finished(function()
						Tickets.Invalidate()

						local NewStroke = DirtyComposeJob.Environment.Stroke

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
	local StrokeID = tostring(Stroke.ID)
	local TicketID = StrokeID .. Initiator

	local _, Exists = Tickets.ExistsQueue(TicketID)

	if Exists then
		return
	end

	local ParallelTicket, ExistsParallel = Tickets.ExistsParallel(TicketID)

	if ExistsParallel then
		Tickets.Reintroduce(ParallelTicket)
	end

	local DiffJob = Scheduler.ReCompose(Stroke)

	Tickets.New("Recompose", TicketID, function(self)
		Stroke:MaxPointer(function()
			Tickets.SetParallel()
		end)
		DiffJob:Finished(function()
			Tickets.InvalidateParallel(self.ID)
			DiffJob:Destroy()
		end)
		DiffJob:Run()
	end)
end

return ComposerRoot
