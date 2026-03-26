local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")

local Object = {}
Object.__index = setmetatable(Object, BaseObject)

function Object.New(SourceInstance: GuiObject): InterfaceWorksObject
	local NewBaseObject = BaseObject.New(SourceInstance)

	local NewObject = setmetatable(NewBaseObject, Object)

	ProtectedObject.LayerInheritance(Object, "InterfaceWorksObject")

	NewObject.Workers = {}
	NewObject.Animations = {}

	return NewObject
end

function Object:Destroy()
	for _, v: InterfaceWorksWorker in pairs(self.Workers) do
		v:Disconnect()
	end

	self:__Destroy()
end

return Object
