local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksValue = types.InterfaceWorksValue
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")
local Mouse = require("./Mouse")

local Stroke = {}
Stroke.__index = setmetatable(Stroke, BaseObject)

function Stroke.New(Composition: _InterfaceWorksComposition, ID: string?, Reuse: Instance?): InterfaceWorksStroke
	local VirtualHost = Reuse or Instance.new("Frame")
	if not Reuse then
		VirtualHost.Size = UDim2.fromScale(1, 1)
		VirtualHost.BackgroundTransparency = 1
		VirtualHost.Name = ID or "Stroke"
	end

	local NewBaseObject = BaseObject.New(VirtualHost)

	local NewStroke = setmetatable(NewBaseObject, Stroke)

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

function Stroke:__Init()
	self[RootProperties].Init = true
end

function Stroke:MaxPointer(callback: () -> ())
	table.insert(self[RootProperties].MaxPointerConnections, callback)
end

function Stroke:AdvanceValuePosition()
	self.CurrentValuePosition += 1
	if self[RootProperties].Init and self.CurrentValuePosition == self.TotalValues then
		for i, v in pairs(self[RootProperties].MaxPointerConnections) do
			v()
			self[RootProperties].MaxPointerConnections[i] = nil
		end
	end
end

function Stroke:AdvanceEventPosition()
	self.CurrentEventPosition += 1
end

function Stroke:GetCurrentValue()
	self:AdvanceValuePosition()
	return self.Values[self.CurrentValuePosition]
end

function Stroke:GetCurrentEvent()
	self:AdvanceEventPosition()
	return self.Events[self.CurrentEventPosition]
end

function Stroke:InsertValue(Value: InterfaceWorksValue)
	self.TotalValues += 1
	local ID = #self.Values + 1
	Value.ID = ID
	self.Values[ID] = Value
end

function Stroke:InsertEvent(Event: InterfaceWorksWorker)
	table.insert(self.Events, Event)
end

function Stroke:ResetPosition()
	self.CurrentValuePosition = 0
	self.CurrentEventPosition = 0
end

function Stroke:UnMount()
	if self.LastParent then
		return
	end

	self.LastParent = self.Host.Parent
	self.Host.Parent = nil

	--Do other stuff for state clean up
end

function Stroke:ReMount()
	if not self.LastParent then
		return
	end

	self.Host.Parent = self.LastParent
end

function Stroke:Destroy()
	for _, v: InterfaceWorksWorker in pairs(self.Events) do
		v:Disconnect()
	end
	for _, v: InterfaceWorksValue in pairs(self.Values) do
		v:Destroy()
	end
	self:__Destroy()
end

function Stroke:GetMouse()
	self.Mouse = self.Mouse or Mouse.New(self)
	return self.Mouse
end

return Stroke
