local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksValue = types.InterfaceWorksValue
type _InterfaceWorksComposition = types._InterfaceWorksComposition

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

	NewStroke.Mouse = Mouse.New(NewStroke)

	NewStroke.Values = {}
	NewStroke.TotalValues = 0
	NewStroke.CurrentPosition = 0

	NewStroke.ID = newproxy()
	NewStroke.RetracingComposition = Composition
	NewStroke.CurrentComposition = nil

	NewStroke[RootProperties].MaxPointerConnections = {}
	NewStroke[RootProperties].Init = false

	ProtectedObject.LayerInheritance(NewStroke, "InterfaceWorksStroke")

	return NewStroke
end

function Stroke:MaxPointer(callback: () -> ())
	table.insert(self[RootProperties].MaxPointerConnections, callback)
end

function Stroke:AdvancePosition()
	self.CurrentPosition += 1
	if self[RootProperties].Init and self.CurrentPosition == self.TotalValues then
		for i, v in pairs(self[RootProperties].MaxPointerConnections) do
			v()
			self[RootProperties].MaxPointerConnections[i] = nil
		end
	end
end

function Stroke:GetCurrentValue()
	self:AdvancePosition()
	return self.Values[self.CurrentPosition]
end

function Stroke:InsertValue(Value: InterfaceWorksValue)
	self.TotalValues += 1
	local ID = #self.Values + 1
	Value.ID = ID
	self.Values[ID] = Value
end

function Stroke:ResetPosition()
	self.CurrentPosition = 0
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
	for _, v: InterfaceWorksValue in pairs(self.Values) do
		v:Destroy()
	end
	self:__Destroy()
end

function Stroke:GetMouse()
	return self.Mouse
end

return Stroke
