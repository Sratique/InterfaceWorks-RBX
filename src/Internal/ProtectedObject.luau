local ProtectedObject = {}

local Proxies = {}

function ProtectedObject.GetProxy(ProxyID: string) -- Returns a proxy that is used for unique indexes
	if not Proxies[ProxyID] then
		Proxies[ProxyID] = newproxy()
	end
	return Proxies[ProxyID]
end

function ProtectedObject.LayerInheritance(CurrentObject, DesiredClass: string)
	local RootProperties = ProtectedObject.GetProxy("RootProperties")

	local OldClass = CurrentObject[RootProperties].ClassName or "BaseObject"

	table.insert(CurrentObject[RootProperties].Inheritance, OldClass)

	CurrentObject[RootProperties].ClassName = DesiredClass

	return true
end

return ProtectedObject
