local function JoinTable(a, b)
	for index, value in pairs(b) do
		a[index] = value
	end

	return a
end

return {

	["Corner"] = function(Offset: number)
		return "UICorner", { CornerRadius = UDim.new(0, Offset) }
	end,
	["Stroke"] = function(Thickness: number, Color, OtherProperties)
		return "UIStroke",
			if OtherProperties
				then JoinTable({ Thickness = Thickness, Color = Color }, OtherProperties)
				else { Thickness = Thickness, Color = Color }
	end,
}
