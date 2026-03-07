local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject

local RunService = game:GetService("RunService")

local Worker = require("@BaseObject/Worker")
local InputTypesEnums = require("@Root/Forward/InputTypesEnums")

return {

	[InputTypesEnums.Click] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ()) -- No need for a seperate worker
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
	[InputTypesEnums.BeganClick] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ())
		self.Host.InputBegan:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				Callback(self)
			end
		end)
	end,
	[InputTypesEnums.Drag] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ()) -- No need for a seperate worker
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
	[InputTypesEnums.Once] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ())
		return Worker.New(Callback(self))
	end,
	[InputTypesEnums.Render] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ())
		Callback(self)
		return nil
	end,
}
