local types = require("@Root/types")
type InterfaceWorksElement = types.InterfaceWorksElement
type InterfaceWorksObject = types.InterfaceWorksObject
type InterfaceWorksBase = types.InterfaceWorksBase

local Object = require("@BaseObject/Object")
local InputTypesEnums = require("@Root/Forward/InputTypesEnums")
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
	for childname, legacychild: InterfaceWorksElement in pairs(LegacyElements or {}) do
		local currentchild = CurrentElements[childname]
		local legacyObject = Base[childname]

		if not currentchild then
			if legacyObject then
				legacyObject:Destroy()
			end
		end
	end
	for childname: number | string, currentchild: InterfaceWorksElement in pairs(CurrentElements or {}) do
		local legacychild: InterfaceWorksElement? = LegacyElements[childname]
		local currentObject: InterfaceWorksObject = Base[childname]

		if not legacychild then
			if not currentObject then
				helper.Build(Base, { [childname] = currentchild })
			end
			continue
		end

		--Set all properties

		for propname, propdata in pairs(currentchild.Ps or {}) do
			if legacychild.Ps[propname] ~= propdata then
				currentObject.Host[propname] = propdata
			end
		end

		--Retrace function event

		local Retrace = currentchild.Fs and currentchild.Fs[InputTypesEnums.Render]
		if Retrace then
			InputTypes[InputTypesEnums.Render](currentObject, Retrace)
		end

		--Continue children

		if currentchild.Cn and legacychild.Cn then
			helper.Retrace(currentObject, currentchild.Cn, legacychild.Cn)
		end
	end
end

return helper
