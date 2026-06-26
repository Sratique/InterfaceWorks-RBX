local types = require("@Root/structs")
type InterfaceWorksTicketType = types.InterfaceWorksTicketType

export type TicketsData = {

	CurrentTicket: InterfaceWorksTicket?,
	Queue: { InterfaceWorksTicket? },
	Parallel: { [number | string]: InterfaceWorksTicket? },
}

local TicketsData: TicketsData = {} :: TicketsData
TicketsData.CurrentTicket = nil
TicketsData.Queue = {}
TicketsData.Parallel = {}

local ComposerTickets = {}
ComposerTickets._VERSION = _G.TicketsVersion

local InterfaceWorksTicket = require("@Objects/Ticket")
type InterfaceWorksTicket = InterfaceWorksTicket.InterfaceWorksTicket

--[[

Returns a ticket and a boolean which is true if the returned ticket was already in the queue or was already being rendered

]]
function ComposerTickets.New(
	Type: InterfaceWorksTicketType,
	ID: string?,
	callback: (self: InterfaceWorksTicket) -> ()
): (InterfaceWorksTicket, boolean)
	local ExistingTicket: InterfaceWorksTicket? = TicketsData.CurrentTicket
	if ExistingTicket and ExistingTicket.ID ~= nil and ExistingTicket.ID == ID then
		return ExistingTicket, true
	end

	for _, v: InterfaceWorksTicket? in pairs(TicketsData.Queue) do
		if v and v.ID == ID then
			return v, true
		end
	end

	if ID then
		local ExistingParallel: InterfaceWorksTicket? = TicketsData.Parallel[ID]
		if ExistingParallel then
			return ExistingParallel, true
		end
	end

	local CurrentTicket = InterfaceWorksTicket.New(ID, callback)

	if Type == "Recompose" then
		table.insert(TicketsData.Queue, CurrentTicket)
	elseif Type == "Compose" then
		table.insert(TicketsData.Queue, 1, CurrentTicket)
	else
		warn("Unknown composer type - InterfaceWorks:Tickets")
	end
	if not TicketsData.CurrentTicket then
		ComposerTickets.Next()
	end
	return CurrentTicket, false
end

function ComposerTickets.ExistsParallel(ID: string): (InterfaceWorksTicket?, boolean)
	local ExistingParallel: InterfaceWorksTicket? = TicketsData.Parallel[ID]
	if ExistingParallel then
		return ExistingParallel, true
	end
	return nil, false
end

function ComposerTickets.ExistsQueue(ID: string): (InterfaceWorksTicket?, boolean)
	local ExistingTicket: InterfaceWorksTicket? = TicketsData.CurrentTicket
	if ExistingTicket and ExistingTicket.ID ~= nil and ExistingTicket.ID == ID then
		return ExistingTicket, true
	end

	for _, v in pairs(TicketsData.Queue) do
		if v and v.ID == ID then
			return v, true
		end
	end
	return nil, false
end

function ComposerTickets.Reintroduce(CurrentTicket: InterfaceWorksTicket)
	if not CurrentTicket.ID then
		return
	end
	TicketsData.Parallel[CurrentTicket.ID] = nil
	table.insert(TicketsData.Queue, 1, CurrentTicket)
	if not TicketsData.CurrentTicket then
		ComposerTickets.Next()
	end
end

function ComposerTickets.SetParallel()
	if not TicketsData.CurrentTicket or not TicketsData.CurrentTicket.ID then
		return
	end

	TicketsData.Parallel[TicketsData.CurrentTicket.ID] = TicketsData.CurrentTicket

	TicketsData.CurrentTicket = nil

	if #TicketsData.Queue > 0 then
		ComposerTickets.Next()
	end
end

function ComposerTickets.InvalidateParallel(TicketID: string)
	local Ticket = TicketsData.Parallel[TicketID]

	if not Ticket then
		return
	end

	Ticket:Destroy()
	TicketsData.Parallel[TicketID] = nil
end

function ComposerTickets.Invalidate()
	if not TicketsData.CurrentTicket then
		return
	end

	local TempTicket = TicketsData.CurrentTicket
	TicketsData.CurrentTicket = nil

	if #TicketsData.Queue > 0 then
		ComposerTickets.Next()
	end

	TempTicket:Destroy()
end

function ComposerTickets.Next()
	local CurrentTicket = TicketsData.Queue[1]
	if not CurrentTicket then
		return
	end
	TicketsData.CurrentTicket = CurrentTicket
	table.remove(TicketsData.Queue, 1)
	CurrentTicket.Job()
end

return ComposerTickets
