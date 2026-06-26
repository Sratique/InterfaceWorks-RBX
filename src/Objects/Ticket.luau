local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase

local TicketObject = {}
TicketObject.__index = setmetatable(TicketObject, BaseObject)

export type InterfaceWorksTicket =
	InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			ID: string?,
			Job: () -> (),
			Environment: { [any]: any },
		},
		TicketObject
	))

function TicketObject.New(ID: string?, Job: (self: InterfaceWorksTicket) -> ()): InterfaceWorksTicket
	local NewBaseObject: InterfaceWorksBase = BaseObject.New()

	local NewTicketObject: InterfaceWorksTicket = setmetatable(NewBaseObject :: InterfaceWorksTicket, TicketObject)

	NewTicketObject.ID = ID

	NewTicketObject.Job = function()
		Job(NewTicketObject)
	end

	NewTicketObject.Environment = {}

	return NewTicketObject
end

function TicketObject:Destroy()
	self:__Destroy()
end

return TicketObject
