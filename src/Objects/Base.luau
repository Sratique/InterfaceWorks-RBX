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
	if self[RootProperties].Children[index] then
		self[RootProperties].Children[index] = nil
	end
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

	if self.Host then
		self.Host:Destroy()
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
	return self[RootProperties].TreeRoot.Parent or self[RootProperties].TreeRoot
end

function BaseObject:Destroying(callback: () -> ())
	table.insert(self[RootProperties].Destroying, callback)
end

function BaseObject:Insert(Object, ID: string)
	table.insert(self[RootProperties].Children, Object) -- add to the internal table so that the getchildren function will also return this object

	Object[RootProperties].TreeRoot = if self[RootProperties].TreeRoot
			== nil -- Add the treeroot instance for the api of that instance especially if its a dockwidgetui
		then self
		else self[RootProperties].TreeRoot

	Object.Parent = self -- set the hierarchy stuff

	Object.Name = ID -- for when you need to do indexing stuff idk
	if ID then
		self[ID] = Object
	else
		table.insert(self, Object)
	end

	if Object.Host and self.Host then -- actually kinda like parent it finally
		Object.Host.Parent = self.Host
	end
end

return BaseObject
