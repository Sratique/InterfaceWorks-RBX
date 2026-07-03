local InterfaceWorksObject = require("@Objects/Object")
export type InterfaceWorksObject = InterfaceWorksObject.InterfaceWorksObject
local InterfaceWorksRoot = require("@Objects/Root")
export type InterfaceWorksRoot = InterfaceWorksRoot.InterfaceWorksRoot
local InterfaceWorksValue = require("@Objects/Value")
export type InterfaceWorksValue = InterfaceWorksValue.InterfaceWorksValue
local InterfaceWorksStroke = require("@Objects/Stroke")
export type InterfaceWorksStroke = InterfaceWorksStroke.InterfaceWorksStroke

return if _G.CHANNEL == "development"
	then {

		["Object"] = InterfaceWorksObject,
		["Root"] = InterfaceWorksRoot,
		["Value"] = InterfaceWorksValue,
	}
	else {}
