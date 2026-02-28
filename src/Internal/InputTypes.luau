local types = require("@Root/types")
type InterfaceWorksObject = types.InterfaceWorksObject

local RunService = game:GetService("RunService")

return {

	["Click"] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ()) -- No need for a seperate worker
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
	["Drag"] = function(self: InterfaceWorksObject, Callback: (self: InterfaceWorksObject) -> ()) -- No need for a seperate worker
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

		return RunService.RenderStepped:Connect(function()
			if CanDrag then
				Callback(self)
			end
		end)
	end,
}
