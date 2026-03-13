local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksValue = types.InterfaceWorksValue

local BaseObject = require("@BaseObject")

local Stroke = {}
Stroke.__index = setmetatable(Stroke, BaseObject)

function Stroke.New(Composition: () -> any): InterfaceWorksStroke
	local VirtualHost = Instance.new("Frame")
	VirtualHost.Size = UDim2.fromScale(1, 1)
	VirtualHost.BackgroundTransparency = 1

	local NewBaseObject = BaseObject.New(VirtualHost)

	local NewStroke = setmetatable(NewBaseObject, Stroke)

	NewStroke.Values = {}
	NewStroke.CurrentPosition = 0

	NewStroke.RetracingComposition = Composition

	return NewStroke
end

function Stroke:AdvancePosition()
	self.CurrentPosition += 1
end

function Stroke:GetCurrentValue()
	self:AdvancePosition()
	return self.Values[self.CurrentPosition]
end

function Stroke:InsertValue(Value: InterfaceWorksValue)
	table.insert(self.Values, Value)
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
	for _, v in pairs(self:GetChildren()) do
		v:Destroy()
	end

	for _, v: InterfaceWorksValue in pairs(self.Values) do
		v:Destroy()
	end
	table.clear(self.Values)
	setmetatable(self, nil)
	table.clear(self)
end

return Stroke
