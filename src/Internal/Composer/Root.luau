local types = require("@Root/structs")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksValueID = types.InterfaceWorksValueID
type _InterfaceWorksComposition = types._InterfaceWorksComposition

local InterfaceWorksJob = require("@Objects/Job")
type InterfaceWorksJob = InterfaceWorksJob.InterfaceWorksJob
local InterfaceWorksStroke = require("@Objects/Stroke")
type InterfaceWorksStroke = InterfaceWorksStroke.InterfaceWorksStroke
local InterfaceWorksTicket = require("@Objects/Ticket")
type InterfaceWorksTicket = InterfaceWorksTicket.InterfaceWorksTicket

local ComposerRoot = {}

local Tickets = require("@Root/Internal/Composer/Tickets")
local Scheduler = require("./Scheduler")

function ComposerRoot.Compose(
	Composition: _InterfaceWorksComposition,
	callback: (InterfaceWorksStroke) -> ()?,
	ID: string?
)
	local Ticket: InterfaceWorksTicket, Existing = Tickets.New("Compose", ID, function(self)
		local ComposeJob = Scheduler.Compose_Create(Composition)

		ComposeJob:Finished(function()
			local NewStroke = ComposeJob.Environment.Stroke

			Tickets.Invalidate()
			ComposeJob:Destroy()
			if callback then
				callback(NewStroke)
			end
		end)

		self.Environment.Job = ComposeJob

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
				print(Dirty)
				Tickets.New("Compose", nil, function()
					local DirtyComposeJob = Scheduler.Compose_Reuse(Composition, Dirty)

					DirtyComposeJob:Finished(function()
						Tickets.Invalidate()

						local NewStroke = DirtyComposeJob.Environment.Stroke

						DirtyComposeJob:Destroy()
						if callback then
							callback(NewStroke)
						end
					end)

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
		print("Ticket already exists! Skipping!")
		return
	end

	local ParallelTicket: InterfaceWorksTicket?, ExistsParallel = Tickets.ExistsParallel(TicketID)

	if ExistsParallel and ParallelTicket then
		Tickets.Reintroduce(ParallelTicket)
		return
	end

	local DiffJob = Scheduler.ReCompose(Stroke)

	Tickets.New("Recompose", TicketID, function(self: InterfaceWorksTicket)
		Stroke:MaxPointer(function()
			Tickets.SetParallel()
		end)
		DiffJob:Finished(function()
			DiffJob:Destroy()
			if not self.ID then
				return
			end
			Tickets.InvalidateParallel(self.ID)
		end)
		DiffJob:Run()
	end)
end

return ComposerRoot
