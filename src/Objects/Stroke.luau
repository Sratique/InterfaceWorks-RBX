local structs = require("@Root/structs")
type _InterfaceWorksComposition = structs._InterfaceWorksComposition
type InterfaceWorksElement = structs.InterfaceWorksElement

local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase
local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker
local InterfaceWorksValue = require("@Objects/Value")
type InterfaceWorksValue = InterfaceWorksValue.InterfaceWorksValue
local InterfaceWorksMouse = require("@Objects/Mouse")
type InterfaceWorksMouse = InterfaceWorksMouse.InterfaceWorksMouse

local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local Stroke = {}
Stroke.__index = setmetatable(Stroke, BaseObject)

export type InterfaceWorksStroke =
	InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			CurrentValuePosition: number,
			CurrentEventPosition: number,
			Events: { InterfaceWorksWorker },
			Values: { any },
			TotalValues: number,
			ID: any,
			RetracingComposition: _InterfaceWorksComposition,
			SelfArguments: { any }?,
			CurrentComposition: { InterfaceWorksElement }?,
			Host: Frame,
			LastParent: Instance?,
			Mouse: any,
		},
		Stroke
	))

function Stroke.New(
	Composition: _InterfaceWorksComposition,
	ID: (string | number)?,
	Reuse: Frame?
): InterfaceWorksStroke
	local VirtualHost: Frame = Reuse or Instance.new("Frame")
	if not Reuse then
		VirtualHost.Size = UDim2.fromScale(1, 1)
		VirtualHost.BackgroundTransparency = 1
		VirtualHost.Name = tostring(ID or "Stroke")
	end

	local NewBaseObject: InterfaceWorksBase = BaseObject.New(VirtualHost)

	local NewStroke = setmetatable(NewBaseObject :: InterfaceWorksStroke, Stroke)

	NewStroke.Values = {}
	NewStroke.TotalValues = 0
	NewStroke.CurrentValuePosition = 0
	NewStroke.Events = {}
	NewStroke.CurrentEventPosition = 0

	NewStroke.ID = newproxy()
	NewStroke.RetracingComposition = Composition
	NewStroke.CurrentComposition = nil

	NewStroke[RootProperties].MaxPointerConnections = {}
	NewStroke[RootProperties].Init = false

	ProtectedObject.LayerInheritance(NewStroke, "InterfaceWorksStroke")

	return NewStroke
end

function Stroke.__Init(self: InterfaceWorksStroke)
	self[RootProperties].Init = true
end

function Stroke.MaxPointer(self: InterfaceWorksStroke, callback: () -> ())
	table.insert(self[RootProperties].MaxPointerConnections, callback)
end

function Stroke.AdvanceValuePosition(self: InterfaceWorksStroke)
	self.CurrentValuePosition += 1
	if self[RootProperties].Init and self.CurrentValuePosition == self.TotalValues then
		for i, v in pairs(self[RootProperties].MaxPointerConnections) do
			v()
			self[RootProperties].MaxPointerConnections[i] = nil
		end
	end
end

function Stroke.AdvanceEventPosition(self: InterfaceWorksStroke)
	self.CurrentEventPosition += 1
end

function Stroke.GetCurrentValue(self: InterfaceWorksStroke)
	self:AdvanceValuePosition()
	return self.Values[self.CurrentValuePosition]
end

function Stroke.GetCurrentEvent(self: InterfaceWorksStroke)
	self:AdvanceEventPosition()
	return self.Events[self.CurrentEventPosition]
end

function Stroke.InsertValue(self: InterfaceWorksStroke, Value: InterfaceWorksValue)
	self.TotalValues += 1
	local ID = #self.Values + 1
	Value.ID = ID
	self.Values[ID] = Value
end

function Stroke.InsertEvent(self: InterfaceWorksStroke, Event: InterfaceWorksWorker)
	table.insert(self.Events, Event)
end

function Stroke.ResetPosition(self: InterfaceWorksStroke)
	self.CurrentValuePosition = 0
	self.CurrentEventPosition = 0
end

function Stroke.UnMount(self: InterfaceWorksStroke)
	if self.LastParent then
		return
	end

	self.LastParent = self.Host.Parent
	self.Host.Parent = nil

	--Do other stuff for state clean up
end

function Stroke.ReMount(self: InterfaceWorksStroke)
	if not self.LastParent then
		return
	end

	self.Host.Parent = self.LastParent
end

function Stroke.Destroy(self: InterfaceWorksStroke)
	for _, v: InterfaceWorksWorker in pairs(self.Events) do
		v:Disconnect()
	end
	for _, v: InterfaceWorksValue in pairs(self.Values) do
		v:Destroy()
	end
	self:__Destroy()
end

function Stroke.GetMouse(self: InterfaceWorksStroke): InterfaceWorksMouse
	self.Mouse = self.Mouse or InterfaceWorksMouse.New(self.Host)
	return self.Mouse
end

return Stroke
