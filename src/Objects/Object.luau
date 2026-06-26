local types = require("@Root/structs")
type InterfaceWorksAnimationData = types.InterfaceWorksAnimationData

local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase
local InterfaceWorksStroke = require("@Objects/Stroke")
type InterfaceWorksStroke = InterfaceWorksStroke.InterfaceWorksStroke
local InterfaceWorksWorker = require("@Objects/Worker")
type InterfaceWorksWorker = InterfaceWorksWorker.InterfaceWorksWorker

local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local Object = {}
Object.__index = setmetatable(Object, BaseObject)

export type InterfaceWorksObject =
	InterfaceWorksBase
	& typeof(setmetatable(
		{} :: {

			Workers: { InterfaceWorksWorker },
			Animations: { InterfaceWorksAnimationData },
		},
		Object
	))

function Object.New(SourceInstance: Instance): InterfaceWorksObject
	local NewBaseObject: InterfaceWorksBase = BaseObject.New(SourceInstance)

	local NewObject = setmetatable(NewBaseObject :: InterfaceWorksObject, Object)

	ProtectedObject.LayerInheritance(NewObject, "InterfaceWorksObject")

	NewObject.Workers = {}
	NewObject.Animations = {}

	return NewObject
end

function Object:GetTreeStroke(): InterfaceWorksStroke
	return self[RootProperties].TreeRoot
end

function Object:Destroy()
	for _, v: InterfaceWorksWorker in pairs(self.Workers) do
		v:Disconnect()
	end

	self:__Destroy()
end

return Object
