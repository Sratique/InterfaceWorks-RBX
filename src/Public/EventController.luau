local types = require("@Root/types")
type InterfaceWorksWorker = types.InterfaceWorksWorker

local WorkerClass = require("@Objects/Worker")
local Composer = require("@Root/Internal/Composer")

local Event = {}

function Event.New(Event: () -> () -> ()): InterfaceWorksWorker
	local Exists: InterfaceWorksWorker? = Composer.Event.NextEvent()

	if Exists then
		return Exists
	end

	local NewEvent = WorkerClass.New(Event())

	Composer.Event.IndexEvent(NewEvent)

	return NewEvent
end

return Event
