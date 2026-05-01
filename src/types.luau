local Types = {}

--CLASSES

export type InterfaceWorksBase = {
	__Destroy: (self: InterfaceWorksBase) -> (),
	__Remove: (self: InterfaceWorksBase, index: number | string) -> (),
	IsA: (self: InterfaceWorksBase, ClassName: string) -> boolean,
	GetChildren: (self: InterfaceWorksBase) -> { InterfaceWorksBase },
	GetTreeRoot: (self: InterfaceWorksBase) -> InterfaceWorksRoot,
	Destroying: (self: InterfaceWorksBase, callback: () -> ()) -> (),
	Insert: (
		self: InterfaceWorksBase,
		Child: InterfaceWorksBase,
		ID: string | number | string? | nil,
		SkipHost: boolean?
	) -> (),
	Parent: InterfaceWorksBase?,
	Host: Instance?,
}

export type InterfaceWorksRoot = InterfaceWorksBase & {

	Attach: (
		self: InterfaceWorksRoot,
		Composition: _InterfaceWorksComposition,
		Arguments: InterfaceWorksRootArguments
	) -> (),
	DestroyStroke: (self: InterfaceWorksRoot, ID: string | "Main") -> (),
	Destroy: (self: InterfaceWorksRoot) -> (),
}

export type InterfaceWorksStroke = InterfaceWorksBase & {

	InsertValue: (self: InterfaceWorksStroke, Value: InterfaceWorksValue) -> (),
	GetCurrentValue: (self: InterfaceWorksStroke) -> InterfaceWorksValue,
	ResetPosition: (self: InterfaceWorksStroke) -> (),
	Destroy: (self: InterfaceWorksStroke) -> (),
	GetMouse: (self: InterfaceWorksStroke) -> InterfaceWorksMouse,
	MaxPointer: (self: InterfaceWorksStroke, callback: (any) -> any) -> (),
	__Init: () -> (),
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
	SetArgs: (self: InterfaceWorksJob, ...any) -> (),
	SetEnv: (self: InterfaceWorksJob, Env: { [any]: any }) -> (),
	GetArtifact: (self: InterfaceWorksJob) -> ...any,
	Finished: (self: InterfaceWorksJob, callback: () -> ()) -> (),
	Run: (self: InterfaceWorksJob, ...any) -> (),
	Environment: { [any]: any },
	Current: thread?,
}

export type InterfaceWorksTicket = InterfaceWorksBase & {

	Destroy: (self: InterfaceWorksTicket) -> (),
	Job: () -> (),
	ID: string?,
	Environment: { [any]: any },
}

--DATA TYPES

export type InterfaceWorksElement = {

	ID: string,
	Type: "Object" | "Property" | "Fragment",
	Ps: { [string]: any }?,
	Fs: { [InterfaceWorksInputType | string]: (any) -> any }?,
	Cn: { [string | number]: InterfaceWorksElement },
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
export type InterfaceWorksTicketType = "Compose" | "Recompose"
export type _InterfaceWorksComposition = (...any) -> { InterfaceWorksElement }
export type InterfaceWorksRootArguments = {
	["StrokeID"]: string? | "Main",
	["ComposerID"]: string?,
}
export type InterfaceWorksRenderingSchedule = { InterfaceWorksRenderingTicket }
export type InterfaceWorksRenderingTicket = {
	Parent: (InterfaceWorksBase | InterfaceWorksElement | InterfaceWorksStroke)? | nil,
	Composition: _InterfaceWorksComposition,
	Arguments: { any }?,
	ID: string | nil,
	IsRoot: boolean?,
	Reuse: Instance?,
}
return Types
