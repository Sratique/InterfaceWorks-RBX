local Types = {}

--DATA TYPES

export type InterfaceWorksElementType = "Object" | "Property" | "Fragment"

export type InterfaceWorksElement = {

	ID: string?,
	Key: string?,
	Type: InterfaceWorksElementType,
	Ps: { [string]: any }?,
	Fs: { [InterfaceWorksInputType | string]: (any) -> any }?,
	Cn: { [string | number]: InterfaceWorksElement? }?,
	Mt: any?,
	An: InterfaceWorksAnimationData?,
	Composition: _InterfaceWorksComposition?,
	FragmentArguments: { any }?,
}

export type InterfaceWorksElementData = {

	Key: string?,
	Properties: {
		[string]: any,
	}?,
	Functions: {
		[InterfaceWorksInputType | string]: (any) -> any,
	}?,
	Material: any?,
	Animation: InterfaceWorksAnimationData?,
}

export type InterfaceWorksAnimationData = {
	Goals: { [string]: any },
	BeginningPoint: { any }?,
	BeginningPointRepeats: boolean?,
	TI: TweenInfo,
}

export type InterfaceWorksInputType = number
export type InterfaceWorksValueID = number
export type InterfaceWorksTicketType = "Compose" | "Recompose"
export type _InterfaceWorksComposition = (...any) -> { InterfaceWorksElement }
export type InterfaceWorksRootArguments = {
	["StrokeID"]: string? | "Main",
	["ComposerID"]: string?,
}
return Types
