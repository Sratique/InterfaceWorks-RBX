local types = require("@Root/structs")
type _InterfaceWorksComposition = types._InterfaceWorksComposition
type InterfaceWorksRootArguements = types.InterfaceWorksRootArguments

local BaseObject = require("@BaseObject")
type InterfaceWorksBase = BaseObject.InterfaceWorksBase
local InterfaceWorksStroke = require("@Objects/Stroke")
type InterfaceWorksStroke = InterfaceWorksStroke.InterfaceWorksStroke

local Composer = require("@Root/Internal/Composer")
local ProtectedObject = require("@Root/Internal/ProtectedObject")

local TreeRoot = {}
TreeRoot.__index = setmetatable(TreeRoot, BaseObject)

export type InterfaceWorksRoot = InterfaceWorksBase & typeof(setmetatable({}, TreeRoot))

function TreeRoot.New(SourceInstance: Instance): InterfaceWorksRoot
	local NewBaseObject: InterfaceWorksBase = BaseObject.New(SourceInstance)

	local NewTreeRoot: InterfaceWorksRoot = setmetatable(NewBaseObject :: InterfaceWorksRoot, TreeRoot)

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
