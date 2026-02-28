local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksBase = types.InterfaceWorksBase

local Object = require("@BaseObject/Object")
local InputTypes = require("./InputTypes")

local helper = {}

function helper.Build(SourceObject: InterfaceWorksBase, Elements: { [string | number]: InterfaceWorksElement })
	for ElementName: number | string, Element: InterfaceWorksElement in pairs(Elements) do
		local Host: any = Instance.new(Element.ID)
		Host.Name = ElementName

		for prop: string, val: any in pairs(Element.Ps or {}) do
			Host[prop] = val
		end

		local NewElementObject: InterfaceWorksObject = Object.New(Host)

		for fndata: string, fn: (any) -> any in pairs(Element.Fs or {}) do
			if InputTypes[fndata] then
				local Worker = InputTypes[fndata](NewElementObject, fn)

				if Worker then
					table.insert(NewElementObject.Workers, Worker)
				end
				continue
			end
			NewElementObject[fndata] = function()
				fn(NewElementObject)
			end
		end

		SourceObject:Insert(NewElementObject, ElementName)

		if Element.Cn then
			helper.Build(NewElementObject, Element.Cn)
		end
	end
end

function helper.Retrace(
	Base: InterfaceWorksBase,
	CurrentElements: { [number | string]: InterfaceWorksElement },
	LegacyElements: { [number | string]: InterfaceWorksElement }
)
	for childname: number | string, currentchild: InterfaceWorksElement in pairs(CurrentElements or {}) do --Make this handle more destroying stuff cuz rn if all children of newelement are destroyed nothing happens
		local legacychild: InterfaceWorksElement? = LegacyElements[childname]
		local Object: InterfaceWorksObject = Base[childname]

		if not legacychild then
			if currentchild.Type == "Object" then
				Object:Destroy()
			end

			continue
		end

		for propname, propdata in pairs(currentchild.Ps) do
			if legacychild[propname] ~= propdata then
				Object.Host[propname] = propdata
			end
		end

		if currentchild.Cn and legacychild.Cn then
			helper.Retrace(Object, currentchild.Cn, legacychild.Cn)
		end
	end
end

return helper
