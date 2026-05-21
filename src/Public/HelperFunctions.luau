local HelperFunctions = {}

--Should always be the last element in a children's table since the returned value is a tuple
function HelperFunctions.ForEach(itertable: { [any]: any }, iteratorfunction: (Index: any, key: any) -> any)
	local Temp = {}

	for i, v in itertable do
		local newvalue = iteratorfunction(i, v)

		table.insert(Temp, newvalue)
	end

	return table.unpack(Temp)
end

return HelperFunctions
