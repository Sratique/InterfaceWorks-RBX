local Types = {}

export type InterfaceWorksType = "Object" | "Property"

export type InterfaceWorksBase = {

	Insert: (self: any, any, any) -> (),
	GetChildren: () -> { InterfaceWorksBase },
	GetTreeRoot: () -> InterfaceWorksBase,
	Host: any,
}

export type InterfaceWorksRoot = {

	Attach: (Composition: _InterfaceWorksComposition, ID: string?) -> (),
	DestroyStroke: (ID: string | "Main") -> (),
}

export type InterfaceWorksObject = {

	Host: GuiObject,
	Insert: (self: any, any, any) -> (),
	Destroy: (self: any) -> (),
	Workers: { InterfaceWorksWorker },
	GetChildren: () -> { InterfaceWorksBase },
	GetTreeRoot: () -> InterfaceWorksBase,
}

export type InterfaceWorksElement = {

	ID: string,
	Ps: { [string]: any },
	Fs: { [InterfaceWorksType | string]: (any) -> any }?,
	Cn: { [string | number]: InterfaceWorksElement }?,
	Type: "Object" | "Property",
}

export type InterfaceWorksWorker = {

	Disconnect: (self: InterfaceWorksWorker) -> nil,
	SelfProcesses: { RBXScriptConnection | (any) -> any },
	ChildProcesses: { InterfaceWorksWorker },
}

export type _InterfaceWorksComposition = () -> InterfaceWorksElement

export type InterfaceWorksValue = {

	Value: any,
	OnChange: (self: InterfaceWorksValue, () -> ()) -> (),
	Set: (any) -> (),
	Destroy: (any) -> (),
}

export type InterfaceWorksStroke = {

	API: { string: (any) -> any },
	Values: { number: any },
	RetracingComposition: _InterfaceWorksComposition,
	CurrentComposition: { InterfaceWorksElement },
	Children: { InterfaceWorksElement },
	InsertValue: (InterfaceWorksValue) -> (),
	Insert: (self: InterfaceWorksStroke, any, any) -> (),
	Host: Frame,
	GetCurrentValue: () -> InterfaceWorksValue,
	ResetPosition: (self: InterfaceWorksStroke) -> (),
	GetChildren: () -> { InterfaceWorksBase },
	GetTreeRoot: () -> InterfaceWorksBase,
	CurrentPosition: number,
}

return Types
