local function JoinTable(a, b)
	for index, value in pairs(b) do
		a[index] = value
	end

	return a
end

local function AssembleProperty(ID: string, Ps: { any })
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
	["Stroke"] = function(Thickness: number, Color, OtherProperties)
		return AssembleProperty(
			"UIStroke",
			if OtherProperties
				then JoinTable({ Thickness = Thickness, Color = Color }, OtherProperties)
				else { Thickness = Thickness, Color = Color }
		)
	end,
}
