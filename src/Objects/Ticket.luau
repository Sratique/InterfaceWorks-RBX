local types = require("@Root/types")
type InterfaceWorksTicket = types.InterfaceWorksTicket

local BaseObject = require("@BaseObject")

local TicketObject = {}
TicketObject.__index = setmetatable(TicketObject, BaseObject)

function TicketObject.New(ID: string?, Job: (self: InterfaceWorksTicket) -> ()): InterfaceWorksTicket
	local NewBaseObject = BaseObject.New()

	local NewTicketObject = setmetatable(NewBaseObject, TicketObject)

	NewTicketObject.Job = function()
		Job(NewTicketObject)
	end
	NewTicketObject.ID = ID

	NewTicketObject.Environment = {}

	return NewTicketObject
end

function TicketObject:Destroy()
	self:__Destroy()
end

return TicketObject
