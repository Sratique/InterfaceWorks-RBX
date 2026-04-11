local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject

local RunService = game:GetService("RunService")

local Worker = require("@Objects/Worker")
local InputTypesEnums = require("@Root/Public/InputTypesEnums")

return {

	[InputTypesEnums.Click] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any) -- No need for a seperate worker
		if self.Host:IsA("TextButton") or self.Host:IsA("ImageButton") then
			self.Host.Activated:Connect(function()
				Callback(self)
			end)
		else
			self.Host.InputEnded:Connect(function(key)
				if key.UserInputType == Enum.UserInputType.MouseButton1 then
					Callback(self)
				end
			end)
		end
	end,
	[InputTypesEnums.BeganClick] = function(
		self: InterfaceWorksObject,
		Callback: (self: InterfaceWorksObject) -> ...any
	)
		self.Host.InputBegan:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				Callback(self)
			end
		end)
	end,
	[InputTypesEnums.Drag] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any) -- No need for a seperate worker
		local CanDrag = false

		self.Host.InputBegan:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				CanDrag = true
			end
		end)

		self.Host.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				CanDrag = false
			end
		end)

		local RenderUsage = RunService.RenderStepped:Connect(function()
			if CanDrag then
				Callback(self)
			end
		end)

		return Worker.New(RenderUsage)
	end,
	[InputTypesEnums.RightClick] = function(
		self: InterfaceWorksObject,
		Callback: (self: InterfaceWorksObject) -> ...any
	) -- No need for a seperate worker
		self.Host.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton2 then
				Callback(self)
			end
		end)
	end,
	[InputTypesEnums.RightBeganClick] = function(
		self: InterfaceWorksObject,
		Callback: (self: InterfaceWorksObject) -> ...any
	)
		self.Host.InputBegan:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton2 then
				Callback(self)
			end
		end)
	end,
	[InputTypesEnums.RightDrag] = function(
		self: InterfaceWorksObject,
		Callback: (self: InterfaceWorksObject) -> ...any
	) -- No need for a seperate worker
		local CanDrag = false

		self.Host.InputBegan:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton2 then
				CanDrag = true
			end
		end)

		self.Host.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton2 then
				CanDrag = false
			end
		end)

		local RenderUsage = RunService.RenderStepped:Connect(function()
			if CanDrag then
				Callback(self)
			end
		end)

		return Worker.New(RenderUsage)
	end,
	[InputTypesEnums.Focus] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any)
		if self.Host:IsA("TextBox") then
			self.Host.Focused:Connect(function()
				Callback(self)
			end)
		else
			warn("This API is only accessible to TextBoxes. For other GuiObjects use the Click API.")
		end
	end,
	[InputTypesEnums.FocusLost] = function(
		self: InterfaceWorksObject,
		Callback: (self: InterfaceWorksObject) -> ...any
	)
		if self.Host:IsA("TextBox") then
			self.Host.FocusLost:Connect(function()
				Callback(self)
			end)
		else
			warn("This API is only accessible to TextBoxes.")
		end
	end,
	[InputTypesEnums.Enter] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any)
		self.Host.MouseEnter:Connect(function()
			Callback(self)
		end)
	end,
	[InputTypesEnums.Leave] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any)
		self.Host.MouseLeave:Connect(function()
			Callback(self)
		end)
	end,
	[InputTypesEnums.Once] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any)
		return Worker.New(Callback(self))
	end,
	[InputTypesEnums.Render] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ...any)
		Callback(self)
		return nil
	end,
}
