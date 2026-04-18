local types = require("@Root/types")
type InterfaceWorksTicketType = types.InterfaceWorksTicketType
type InterfaceWorksTicket = types.InterfaceWorksTicket

local Ticket = require("@Objects/Ticket")

local ComposerTickets = {}
ComposerTickets.CurrentTicket = nil
ComposerTickets.Queue = {}
ComposerTickets.Parallel = {}

function ComposerTickets.New(Type: InterfaceWorksTicketType, ID: string, callback: () -> ())
	for _, v in pairs(ComposerTickets.Queue) do
		if v.ID == ID then
			return
		end
	end

	local ExistingTicket: InterfaceWorksTicket? = ComposerTickets.CurrentTicket
	if ExistingTicket and ExistingTicket.ID == ID then
		ExistingTicket.Job()
		return
	end

	if ComposerTickets.Parallel[ID] then
		ComposerTickets.Parallel[ID].Job()
		return
	end

	local CurrentTicket = Ticket.New(ID, callback)

	if #ComposerTickets.Queue == 0 then
		ComposerTickets.CurrentTicket = CurrentTicket
		CurrentTicket.Job()
		return
	end

	if Type == "Recompose" or Type == "Fragment" then
		table.insert(ComposerTickets.Queue, CurrentTicket)
	elseif Type == "Compose" then
		table.insert(ComposerTickets.Queue, 1, CurrentTicket)
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
	ComposerTickets.CurrentTicket:Destroy()
	ComposerTickets.CurrentTicket = nil

	if #ComposerTickets.Queue > 0 then
		ComposerTickets.Next()
	end
end

function ComposerTickets.Next()
	ComposerTickets.CurrentTicket = ComposerTickets.Queue[1]
	table.remove(ComposerTickets.Queue, 1)
	local ExistingTicket: InterfaceWorksTicket = ComposerTickets.CurrentTicket
	ExistingTicket.Job()
end

return ComposerTickets
