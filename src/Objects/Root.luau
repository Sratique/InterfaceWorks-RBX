local types = require("@Root/types")
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksRoot = types.InterfaceWorksRoot
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksRootArguements = types.InterfaceWorksRootArguments

local BaseObject = require("@BaseObject")

local Composer = require("@Root/Internal/Composer")
local ProtectedObject = require("@Root/Internal/ProtectedObject")

local TreeRoot = {}
TreeRoot.__index = setmetatable(TreeRoot, BaseObject)

function TreeRoot.New(SourceInstance: Instance): InterfaceWorksRoot
	local NewBaseObject = BaseObject.New(SourceInstance)

	local NewTreeRoot = setmetatable(NewBaseObject, TreeRoot)

	ProtectedObject.LayerInheritance(NewTreeRoot, "InterfaceWorksRoot")

	return NewTreeRoot
end

function TreeRoot:Attach(Composition: _InterfaceWorksComposition, Arguments: InterfaceWorksRootArguements)
	Arguments = Arguments or {}

	local SID = Arguments.StrokeID
	local CID = Arguments.ComposerID
	Composer.Main.Compose(Composition, function(ComposedStroke: InterfaceWorksStroke)
		ComposedStroke.Host.Name = SID or "Main"

		self:Insert(ComposedStroke, SID or "Main")
	end, CID)
end

function TreeRoot:Destroy()
	self.Host = nil
	self:__Destroy()
end

function TreeRoot:DestroyStroke(ID: string | "Main")
	local Object = self[ID or "Main"]
	if Object then
		Object:Destroy()
	end
end

return TreeRoot
