local types = require("@Root/types")
type InterfaceWorksTicketType = types.InterfaceWorksTicketType
type InterfaceWorksTicket = types.InterfaceWorksTicket

local ComposerTickets = {}
ComposerTickets._VERSION = _G.TicketsVersion
ComposerTickets.CurrentTicket = nil
ComposerTickets.Queue = {}
ComposerTickets.Parallel = {}

local Ticket = require("@Objects/Ticket")

--[[

Returns a ticket and a boolean which is true if the returned ticket was already in the queue or was already being rendered

]]
function ComposerTickets.New(
	Type: InterfaceWorksTicketType,
	ID: string?,
	callback: (self: InterfaceWorksTicket) -> ()
): (InterfaceWorksTicket, boolean)
	local ExistingTicket: InterfaceWorksTicket? = ComposerTickets.CurrentTicket
	if ExistingTicket and ExistingTicket.ID ~= nil and ExistingTicket.ID == ID then
		return ExistingTicket, true
	end

	for _, v in pairs(ComposerTickets.Queue) do
		if v.ID == ID then
			return v, true
		end
	end

	local ExistingParallel: InterfaceWorksTicket? = ComposerTickets.Parallel[ID]
	if ExistingParallel then
		return ExistingParallel, true
	end

	local CurrentTicket = Ticket.New(ID, callback)

	if Type == "Recompose" then
		table.insert(ComposerTickets.Queue, CurrentTicket)
	elseif Type == "Compose" then
		table.insert(ComposerTickets.Queue, 1, CurrentTicket)
	else
		warn("Unknown composer type - InterfaceWorks:Tickets")
	end
	if not ComposerTickets.CurrentTicket then
		ComposerTickets.Next()
	end
	return CurrentTicket, false
end

function ComposerTickets.ExistsParallel(ID: string): (InterfaceWorksTicket?, boolean)
	local ExistingParallel: InterfaceWorksTicket? = ComposerTickets.Parallel[ID]
	if ExistingParallel then
		return ExistingParallel, true
	end
	return nil, false
end

function ComposerTickets.ExistsQueue(ID: string): (InterfaceWorksTicket?, boolean)
	local ExistingTicket: InterfaceWorksTicket? = ComposerTickets.CurrentTicket
	if ExistingTicket and ExistingTicket.ID ~= nil and ExistingTicket.ID == ID then
		return ExistingTicket, true
	end

	for _, v in pairs(ComposerTickets.Queue) do
		if v.ID == ID then
			return v, true
		end
	end
	return nil, false
end

function ComposerTickets.Reintroduce(CurrentTicket)
	ComposerTickets.Parallel[CurrentTicket.ID] = nil
	table.insert(ComposerTickets.Queue, 1, CurrentTicket)
	if not ComposerTickets.CurrentTicket then
		ComposerTickets.Next()
	end
end

function ComposerTickets.SetParallel()
	ComposerTickets.Parallel[ComposerTickets.CurrentTicket.ID] = ComposerTickets.CurrentTicket

	ComposerTickets.CurrentTicket = nil

	if #ComposerTickets.Queue > 0 then
		ComposerTickets.Next()
	end
end

function ComposerTickets.InvalidateParallel(TicketID: string)
	ComposerTickets.Parallel[TicketID]:Destroy()
	ComposerTickets.Parallel[TicketID] = nil
end

function ComposerTickets.Invalidate()
	local TempTicket = ComposerTickets.CurrentTicket
	ComposerTickets.CurrentTicket = nil

	if #ComposerTickets.Queue > 0 then
		ComposerTickets.Next()
	end

	TempTicket:Destroy()
end

function ComposerTickets.Next()
	ComposerTickets.CurrentTicket = ComposerTickets.Queue[1]
	table.remove(ComposerTickets.Queue, 1)
	local ExistingTicket: InterfaceWorksTicket = ComposerTickets.CurrentTicket
	ExistingTicket.Job()
end

return ComposerTickets
