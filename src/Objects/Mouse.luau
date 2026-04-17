local UserInputService = game:GetService("UserInputService")

local types = require("@Root/types")
type InterfaceWorksMouse = types.InterfaceWorksMouse
type InterfaceWorksRoot = types.InterfaceWorksRoot

local BaseObject = require("@BaseObject")

local ProtectedObject = require("@Root/Internal/ProtectedObject")

--Shared object for both UI types
local MouseShared = {}
MouseShared.__index = setmetatable(MouseShared, BaseObject)

--Needed since these two operate differently
local MouseScreenGui = {}
MouseScreenGui.__index = setmetatable(MouseScreenGui, MouseShared)
local MousePlugin = {}
MousePlugin.__index = setmetatable(MousePlugin, MouseShared)

function MouseShared.New(Root: InterfaceWorksStroke): InterfaceWorksMouse
	local NewBaseObject = BaseObject.New(Root.Host and Root.Host:FindFirstAncestorWhichIsA("DockWidgetPluginGui"))

	local Host = if NewBaseObject.Host then MousePlugin else MouseScreenGui

	local NewMouse = setmetatable(NewBaseObject, Host)

	NewMouse.Root = Root

	ProtectedObject.LayerInheritance(NewMouse, "InterfaceWorksMouse")

	return NewMouse
end

function MouseShared:Destroy()
	self.Root = nil
	self:__Destroy()
end

--Plugin instruction set--

function MousePlugin:GetLocation(): Vector2
	local Dock = self.Host

	return Dock:GetRelativeMousePosition()
end

--ScreenGui instruction set--

function MouseScreenGui:GetLocation(): Vector2
	return UserInputService:GetMouseLocation()
end

return MouseShared
