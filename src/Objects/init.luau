local ProtectedObject = require("@Root/Internal/ProtectedObject")
local RootProperties = ProtectedObject.GetProxy("RootProperties")

local BaseObject = {}
BaseObject.__index = BaseObject

function BaseObject.New(SourceInstance: Instance?)
	local NewBaseObject = setmetatable({}, BaseObject)

	NewBaseObject[RootProperties] = {}
	NewBaseObject[RootProperties].Children = {}
	NewBaseObject[RootProperties].Destroying = {}
	NewBaseObject[RootProperties].Inheritance = {}

	NewBaseObject.Host = SourceInstance

	return NewBaseObject
end

function BaseObject:__Remove(index: number | string)
	self[index] = nil
end

function BaseObject:__Destroy()
	for _, v in pairs(self:GetChildren()) do
		v:Destroy()
	end

	for _, v: () -> () in pairs(self[RootProperties].Destroying) do
		v()
	end

	if self.Parent then
		self.Parent:__Remove(self.Name)
	end

	setmetatable(self, nil)
	table.clear(self)
end

function BaseObject:IsA(ClassName: string)
	return ClassName == (self[RootProperties].ClassName or "InterfaceWorksBase")
		or self[RootProperties].Inheritance and table.find(self[RootProperties].Inheritance, ClassName) ~= nil
end

function BaseObject:GetChildren()
	return self[RootProperties].Children
end

function BaseObject:GetTreeRoot()
	return self[RootProperties].TreeRoot
end

function BaseObject:Destroying(callback: () -> ())
	table.insert(self[RootProperties].Destroying, callback)
end

function BaseObject:Insert(Object, ID: string)
	table.insert(self[RootProperties].Children, Object)
	Object[RootProperties].TreeRoot = if self[RootProperties].TreeRoot == nil
		then self
		else self[RootProperties].TreeRoot
	Object.Parent = self
	Object.Name = ID
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
