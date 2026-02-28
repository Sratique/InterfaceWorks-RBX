local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke

local BaseObject = require("@BaseObject")
local Composer = require("@Root/Internal/composer")

local TreeRoot = {}
TreeRoot.__index = setmetatable(TreeRoot, BaseObject)

function TreeRoot.New(SourceInstance: Instance)
	local NewBaseObject = BaseObject.New(SourceInstance)

	local NewTreeRoot = setmetatable(NewBaseObject, TreeRoot)

	return NewTreeRoot
end

function TreeRoot:Attach(Composition, ID: string?)
	local ComposedStroke: InterfaceWorksStroke = Composer.Compose(Composition)

	ComposedStroke.Host.Name = ID or "Main"

	self:Insert(ComposedStroke, ID or "Main")
end

function TreeRoot:DestroyStroke(ID: string | "Main")
	local Object = self[ID or "Main"]
	if Object then
		Object:Destroy()
	end
end

return TreeRoot
