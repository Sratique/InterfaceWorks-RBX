local UserInputService = game:GetService("UserInputService")

local types = require("@Root/types")
type InterfaceWorksMouse = types.InterfaceWorksMouse
type InterfaceWorksStroke = types.InterfaceWorksStroke
type InterfaceWorksWorker = types.InterfaceWorksWorker

local BaseObject = require("@BaseObject")
local Worker = require("@Objects/Worker")

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

function MousePlugin:Focused(callback: () -> ()): RBXScriptConnection
	local Dock: DockWidgetPluginGui = self.Host

	return Dock.WindowFocused:Connect(callback)
end

function MousePlugin:FocusLost(callback: () -> ()): RBXScriptConnection
	local Dock: DockWidgetPluginGui = self.Host

	return Dock.WindowFocusReleased:Connect(callback)
end

--ScreenGui instruction set--

function MouseScreenGui:GetLocation(): Vector2
	return UserInputService:GetMouseLocation()
end

--This burns my eyes please make this less painful to look at sometime in the future

function MouseScreenGui.FocusLost(self: InterfaceWorksMouse, callback: () -> ()): InterfaceWorksWorker
	local ContainerFrame: Frame = self.Root.Host

	local HitBox = false

	local IsFocused = false

	local MouseEnterEvent = ContainerFrame.MouseEnter:Connect(function()
		HitBox = true
	end)

	local MouseLeaveEvent = ContainerFrame.MouseLeave:Connect(function()
		HitBox = false
	end)

	local UISEvent = UserInputService.InputBegan:Connect(function(InpO: InputObject)
		if
			(
				InpO.UserInputType == Enum.UserInputType.MouseButton1
				or InpO.UserInputType == Enum.UserInputType.MouseButton2
			)
			and not HitBox
			and IsFocused
		then
			IsFocused = false
			callback()
		elseif
			(
				InpO.UserInputType == Enum.UserInputType.MouseButton1
				or InpO.UserInputType == Enum.UserInputType.MouseButton2
			) and HitBox
		then
			IsFocused = true
		end
	end)

	local NewWorker = Worker.New(function()
		MouseEnterEvent:Disconnect()
		MouseLeaveEvent:Disconnect()
		UISEvent:Disconnect()
	end)

	return NewWorker
end

function MouseScreenGui.Focused(self: InterfaceWorksMouse, callback: () -> ()): InterfaceWorksWorker
	local ContainerFrame: Frame = self.Root.Host

	local HitBox = false

	local IsFocused = false

	local MouseEnterEvent = ContainerFrame.MouseEnter:Connect(function()
		HitBox = true
	end)

	local MouseLeaveEvent = ContainerFrame.MouseLeave:Connect(function()
		HitBox = false
	end)

	local UISEvent = UserInputService.InputBegan:Connect(function(InpO: InputObject)
		if
			(
				InpO.UserInputType == Enum.UserInputType.MouseButton1
				or InpO.UserInputType == Enum.UserInputType.MouseButton2
			)
			and HitBox
			and not IsFocused
		then
			IsFocused = true
			callback()
		elseif
			(
				InpO.UserInputType == Enum.UserInputType.MouseButton1
				or InpO.UserInputType == Enum.UserInputType.MouseButton2
			) and not HitBox
		then
			IsFocused = false
		end
	end)

	local NewWorker = Worker.New(function()
		MouseEnterEvent:Disconnect()
		MouseLeaveEvent:Disconnect()
		UISEvent:Disconnect()
	end)

	return NewWorker
end

return MouseShared
