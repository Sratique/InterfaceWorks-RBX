local Types = {}

export type InterfaceWorksType = "Object" | "Property"

export type InterfaceWorksMaterial = {

	Targets: { InterfaceWorksObject },
	ReactivityWorkers: InterfaceWorksWorker,
	ReactivityFunction: (InterfaceWorksObject) -> ...RBXScriptConnection,
	ConstantReactivityWorker: InterfaceWorksWorker,
	AddTarget: (self: InterfaceWorksMaterial, InterfaceWorksObject) -> (),
}

export type InterfaceWorksBase = {

	Insert: (self: InterfaceWorksBase, any, any) -> (),
	GetChildren: (self: InterfaceWorksBase) -> { InterfaceWorksBase },
	GetTreeRoot: (self: InterfaceWorksBase) -> InterfaceWorksBase,
	IsA: (self: InterfaceWorksBase, ClassName: string) -> boolean,
	Host: any,
}

export type InterfaceWorksRoot = {

	Attach: (self: InterfaceWorksRoot, Composition: _InterfaceWorksComposition, ID: string?) -> (),
	DestroyStroke: (self: InterfaceWorksRoot, ID: string | "Main") -> (),
}

export type InterfaceWorksObject = {

	Host: GuiObject,
	Insert: (self: InterfaceWorksObject, any, any) -> (),
	Destroy: (self: InterfaceWorksObject) -> (),
	Workers: { InterfaceWorksWorker },
	GetChildren: (self: InterfaceWorksObject) -> { InterfaceWorksBase },
	GetTreeRoot: (self: InterfaceWorksObject) -> InterfaceWorksBase,
	IsA: (self: InterfaceWorksObject, ClassName: string) -> boolean,
	Destroying: (self: InterfaceWorksObject, callback: () -> ()) -> (),
	Animations: {},
}

export type InterfaceWorksElementData = {

	Properties: {
		[string]: any,
	}?,
	Functions: {
		[InterfaceWorksType | string]: (any) -> any,
	}?,
	Material: InterfaceWorksMaterial?,
	Animation: InterfaceWorksAnimationData?,
}

export type InterfaceWorksElement = {

	ID: string,
	Type: "Object" | "Property" | "Fragment",
	Ps: { [string]: any }?,
	Fs: { [InterfaceWorksType | string]: (any) -> any }?,
	Cn: { [string | number]: InterfaceWorksElement }?,
	Mt: InterfaceWorksMaterial?,
	An: InterfaceWorksAnimationData?,
	Composition: _InterfaceWorksComposition?,
	FragmentArguments: { any }?,
}

export type InterfaceWorksWorker = {

	Disconnect: (self: InterfaceWorksWorker) -> nil,
	SelfProcesses: { RBXScriptConnection | (any) -> any },
	ChildProcesses: { InterfaceWorksWorker },
}

export type _InterfaceWorksComposition = (...any) -> { InterfaceWorksElement }

export type InterfaceWorksValue = {

	Value: any,
	OnChange: (self: InterfaceWorksValue, () -> ()) -> (),
	Set: (self: InterfaceWorksValue, any) -> (),
	Destroy: (self: InterfaceWorksValue, any) -> (),
}

export type InterfaceWorksAnimationData = {
	Goals: { [string]: any },
	BeginningPoint: { any }?,
	BeginningPointRepeats: boolean?,
	TI: TweenInfo,
}

export type InterfaceWorksStroke = {

	API: { string: (any) -> any },
	Values: { number: any },
	RetracingComposition: _InterfaceWorksComposition,
	CurrentComposition: { InterfaceWorksElement },
	Children: { InterfaceWorksElement },
	InsertValue: (InterfaceWorksValue) -> (),
	Insert: (self: InterfaceWorksStroke, any, any) -> (),
	Host: GuiObject,
	GetCurrentValue: (self: InterfaceWorksStroke) -> InterfaceWorksValue,
	ResetPosition: (self: InterfaceWorksStroke) -> (),
	GetChildren: (self: InterfaceWorksStroke) -> { InterfaceWorksBase },
	GetTreeRoot: (self: InterfaceWorksStroke) -> InterfaceWorksBase,
	CurrentPosition: number,
	IsA: (self: InterfaceWorksStroke, ClassName: string) -> boolean,
}

return Types
