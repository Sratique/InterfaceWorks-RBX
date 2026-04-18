local Types = {}

--CLASSES

export type InterfaceWorksBase = {
	__Destroy: (self: InterfaceWorksBase) -> (),
	__Remove: (self: InterfaceWorksBase, index: number | string) -> (),
	IsA: (self: InterfaceWorksBase, ClassName: string) -> boolean,
	GetChildren: (self: InterfaceWorksBase) -> { InterfaceWorksBase },
	GetTreeRoot: (self: InterfaceWorksBase) -> InterfaceWorksRoot,
	Destroying: (self: InterfaceWorksBase, callback: () -> ()) -> (),
	Insert: (self: InterfaceWorksBase, Child: InterfaceWorksBase, ID: string | number) -> (),
	Parent: InterfaceWorksBase?,
	Host: Instance?,
}

export type InterfaceWorksRoot = InterfaceWorksBase & {

	Attach: (self: InterfaceWorksRoot, Composition: _InterfaceWorksComposition, ID: string?) -> (),
	DestroyStroke: (self: InterfaceWorksRoot, ID: string | "Main") -> (),
	Destroy: (self: InterfaceWorksRoot) -> (),
}

export type InterfaceWorksStroke = InterfaceWorksBase & {

	InsertValue: (InterfaceWorksValue) -> (),
	Insert: (self: InterfaceWorksStroke, any, any) -> (),
	GetCurrentValue: (self: InterfaceWorksStroke) -> InterfaceWorksValue,
	ResetPosition: (self: InterfaceWorksStroke) -> (),
	Destroy: (self: InterfaceWorksStroke) -> (),
	GetMouse: (self: InterfaceWorksStroke) -> InterfaceWorksMouse,
	CurrentPosition: number,
	Values: { number: any },
	TotalValues: number,
	ID: any,
	RetracingComposition: _InterfaceWorksComposition,
	CurrentComposition: { InterfaceWorksElement },
	Host: Frame,
}

export type InterfaceWorksValue = InterfaceWorksBase & {

	Value: any,
	ID: number,
	OnChange: (self: InterfaceWorksValue, () -> ()) -> (),
	Set: (self: InterfaceWorksValue, any) -> (),
	Destroy: (self: InterfaceWorksValue, any) -> (),
}

export type InterfaceWorksObject = InterfaceWorksBase & {

	Destroy: (self: InterfaceWorksObject) -> (),
	GetTreeStroke: (self: InterfaceWorksObject) -> InterfaceWorksStroke,
	Workers: { InterfaceWorksWorker },
	Animations: { InterfaceWorksAnimationData },
	Host: GuiObject,
}

export type InterfaceWorksMaterial = InterfaceWorksBase & {

	Targets: { InterfaceWorksObject },
	ReactivityWorkers: InterfaceWorksWorker,
	ReactivityFunction: (InterfaceWorksObject) -> ...RBXScriptConnection,
	ConstantReactivityWorker: InterfaceWorksWorker,
	AddTarget: (self: InterfaceWorksMaterial, InterfaceWorksObject) -> (),
}

export type InterfaceWorksWorker = InterfaceWorksBase & {

	Disconnect: (self: InterfaceWorksWorker) -> nil,
	SelfProcesses: { RBXScriptConnection | (any) -> any },
	ChildProcesses: { InterfaceWorksWorker },
}

export type InterfaceWorksMouse = InterfaceWorksBase & {
	GetLocation: (self: InterfaceWorksMouse) -> Vector2,
	Root: InterfaceWorksRoot?,
}

--INTERNAL CLASSES

export type InterfaceWorksJob = InterfaceWorksBase & {

	Destroy: (self: InterfaceWorksJob) -> (),
	Pause: (self: InterfaceWorksJob) -> (),
	SetArgs: (self: InterfaceWorksJob, ...any) -> (),
	GetArtifact: (self: InterfaceWorksJob) -> ...any,
	Finished: (self: InterfaceWorksJob, callback: () -> ()) -> (),
	Run: (self: InterfaceWorksJob, ...any) -> (),
}

export type InterfaceWorksTicket = InterfaceWorksBase & {

	Destroy: (self: InterfaceWorksTicket) -> (),
	Job: () -> (),
	ID: string,
}

--DATA TYPES

export type InterfaceWorksElement = {

	ID: string,
	Type: "Object" | "Property" | "Fragment",
	Ps: { [string]: any }?,
	Fs: { [InterfaceWorksInputType | string]: (any) -> any }?,
	Cn: { [string | number]: InterfaceWorksElement }?,
	Mt: InterfaceWorksMaterial?,
	An: InterfaceWorksAnimationData?,
	Composition: _InterfaceWorksComposition?,
	FragmentArguments: { any }?,
}

export type InterfaceWorksElementData = {

	Properties: {
		[string]: any,
	}?,
	Functions: {
		[InterfaceWorksInputType | string]: (any) -> any,
	}?,
	Material: InterfaceWorksMaterial?,
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
export type InterfaceWorksTicketType = "Compose" | "Recompose" | "Fragment"
export type _InterfaceWorksComposition = (...any) -> { InterfaceWorksElement }

return Types
