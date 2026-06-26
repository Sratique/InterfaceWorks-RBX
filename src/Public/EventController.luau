local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker
local Composer = require("@Root/Internal/Composer")

local Event = {}

function Event.New(Event: () -> () -> ()): InterfaceWorksWorker
	local Exists: InterfaceWorksWorker? = Composer.Event.NextEvent()

	if Exists then
		return Exists
	end

	local NewEvent = InterfaceWorksWorker.New(Event())

	Composer.Event.IndexEvent(NewEvent)

	return NewEvent
end

return Event
