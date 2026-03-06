local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksRoot = types.InterfaceWorksRoot

local BaseObject = require("@BaseObject")
local Composer = require("@Root/Internal/composer")

local TreeRoot = {}
TreeRoot.__index = setmetatable(TreeRoot, BaseObject)

function TreeRoot.New(SourceInstance: Instance): InterfaceWorksRoot
	local NewBaseObject = BaseObject.New(SourceInstance)

	local NewTreeRoot = setmetatable(NewBaseObject, TreeRoot)

	return NewTreeRoot
end

function TreeRoot:Attach(Composition: () -> types.InterfaceWorksElement, ID: string?)
	Composer.Compose(Composition, function(ComposedStroke: InterfaceWorksStroke)
		ComposedStroke.Host.Name = ID or "Main"

		self:Insert(ComposedStroke, ID or "Main")
	end)
end

function TreeRoot:DestroyStroke(ID: string | "Main")
	local Object = self[ID or "Main"]
	if Object then
		Object:Destroy()
	end
end

return TreeRoot
