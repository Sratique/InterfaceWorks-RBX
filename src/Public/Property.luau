local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement

local function AssembleProperty(ID: string, Ps: { [any]: any }): InterfaceWorksElement
	return {

		ID = ID,
		Ps = Ps,
		Cn = {},
		Type = "Property",
	}
end

return {

	["Corner"] = function(Offset: UDim)
		return AssembleProperty("UICorner", { CornerRadius = Offset })
	end,
	["Stroke"] = function(
		Thickness: number?,
		Color: Color3?,
		ApplyStrokeMode: Enum.ApplyStrokeMode?,
		BorderOffset: UDim?,
		BorderStrokePosition: Enum.BorderStrokePosition?,
		LineJoinMode: Enum.LineJoinMode?,
		StrokeSizingMode: Enum.StrokeSizingMode?,
		ZIndex: number?
	)
		return AssembleProperty("UIStroke", {
			Thickness = Thickness,
			Color = Color,
			ApplyStrokeMode = ApplyStrokeMode,
			BorderOffset = BorderOffset,
			BorderStrokePosition = BorderStrokePosition,
			LineJoinMode = LineJoinMode,
			StrokeSizingMode = StrokeSizingMode,
			ZIndex = ZIndex,
		})
	end,
	["Padding"] = function(Padding: UDim)
		return AssembleProperty("UIPadding", {
			PaddingBottom = Padding,
			PaddingLeft = Padding,
			PaddingRight = Padding,
			PaddingTop = Padding,
		})
	end,
	["PaddingSpecific"] = function(PaddingBottom: UDim?, PaddingLeft: UDim?, PaddingRight: UDim?, PaddingTop: UDim?)
		return AssembleProperty("UIPadding", {
			["PaddingBottom"] = PaddingBottom or UDim.new(),
			["PaddingLeft"] = PaddingLeft or UDim.new(),
			["PaddingRight"] = PaddingRight or UDim.new(),
			["PaddingTop"] = PaddingTop or UDim.new(),
		})
	end,
	["Gradient"] = function(
		UserColorSequence: ColorSequence?,
		UserTransparency: NumberSequence | number?,
		UserRotation: number?,
		UserOffset: Vector2?
	)
		return AssembleProperty("UIGradient", {
			Color = UserColorSequence or ColorSequence.new(Color3.new(1, 1, 1)),
			Transparency = UserTransparency or 0,
			Rotation = UserRotation,
			Offset = UserOffset or Vector2.new(),
		})
	end,
}
