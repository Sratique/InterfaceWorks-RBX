local ProtectedObject = require("@Root/Internal/ProtectedObject")

local BaseObject = {}
BaseObject.__index = BaseObject

local RootProperties = ProtectedObject.GetProxy("RootProperties")

function BaseObject.New(SourceInstance: Instance?)
	local NewBaseObject = setmetatable({}, BaseObject)

	NewBaseObject[RootProperties] = {}
	NewBaseObject[RootProperties].Children = {}

	NewBaseObject.Host = SourceInstance

	return NewBaseObject
end

function BaseObject:GetChildren()
	return self[RootProperties].Children
end

function BaseObject:Insert(Object, ID: string?)
	table.insert(self[RootProperties].Children, Object)
	Object.Parent = self
	if ID then
		self[ID] = Object
	else
		table.insert(self, Object)
	end
	if Object.Host and self.Host then
		Object.Host.Parent = self.Host
	end
end

return BaseObject
