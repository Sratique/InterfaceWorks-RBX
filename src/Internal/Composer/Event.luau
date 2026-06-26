local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker

local ComposerEvents = {}

local ComposerScheduler = require("./Scheduler")

function ComposerEvents.NextEvent(): InterfaceWorksWorker?
	return ComposerScheduler.CurrentComposition:GetCurrentEvent()
end

function ComposerEvents.IndexEvent(Event: InterfaceWorksWorker)
	assert(ComposerScheduler.CurrentComposition, "Unhandled exception: No Composer job, but an event has been added.")

	local CurrentComposition = ComposerScheduler.CurrentComposition

	CurrentComposition:InsertEvent(Event)
end

return ComposerEvents
