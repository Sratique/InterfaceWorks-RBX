local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker
local InterfaceWorksValue = require("@Objects/Value")
type InterfaceWorksValue = InterfaceWorksValue.InterfaceWorksValue
local Composer = require("@Root/Internal/Composer")

local Event = {}

function Event.New(Event: () -> (() -> ())?, ...: InterfaceWorksValue): InterfaceWorksWorker
	local Exists: InterfaceWorksWorker? = Composer.Event.NextEvent()

	if Exists then
		return Exists
	end

	local OnChangeValues: { InterfaceWorksValue } = { ... }

	local NewEvent = InterfaceWorksWorker.New(Event() or function()
		if _G.SENSITIVE then
			warn("Missing cleanup function in Event!")
		end
	end)

	for i = 1, #OnChangeValues, 1 do
		local v = OnChangeValues[i]
		v:OnChange(function()
			NewEvent:Update()
		end)
	end

	NewEvent.Reference = Event

	Composer.Event.IndexEvent(NewEvent)

	return NewEvent
end

return Event
