local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")

local Object = {}
Object.__index = setmetatable(Object, BaseObject)

function Object.New(SourceInstance: GuiObject): InterfaceWorksObject
	local NewBaseObject = BaseObject.New(SourceInstance)

	local NewObject = setmetatable(NewBaseObject, Object)

	NewObject.Workers = {}

	return NewObject
end

function Object:Destroy()
	self.Host:Destroy()
	self:_Destroy()
	self.Host = nil
	for _, v in pairs(self:GetChildren()) do
		v:Destroy()
	end
	for _, v: InterfaceWorksWorker in pairs(self.Workers) do
		v:Disconnect()
	end

	self.Parent:_Remove(self.Name)

	setmetatable(self, nil)
	table.clear(self)
	self = nil
end

return Object
