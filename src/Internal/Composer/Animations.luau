--!nonstrict

local TweenService = game:GetService("TweenService")

local InterfaceWorksObject = require("@Objects/Object")
type InterfaceWorksObject = InterfaceWorksObject.InterfaceWorksObject

local Structs = require("@Root/structs")
type AnimationData = Structs.InterfaceWorksAnimationData

local Animations = {}

function Animations.Play(Object: InterfaceWorksObject, AnimationData: AnimationData, IsRecompose: boolean?)
	if AnimationData.Type == "Default" then
		local Host: Instance = Object.Host

		if
			(AnimationData.BeginningPoint and (AnimationData.BeginningPointRepeats and IsRecompose))
			or (AnimationData.BeginningPoint and not IsRecompose)
		then
			for prop, data in AnimationData.BeginningPoint do
				Host[prop] = data
			end
		end

		local Tween = TweenService:Create(Object.Host, AnimationData.TI, AnimationData.Goals)

		table.insert(Object.Animations, Tween)

		Tween.Completed:Connect(function()
			table.remove(Object.Animations, table.find(Object.Animations, Tween))
			Tween:Destroy()
		end)

		Tween:Play()
	end
end

return Animations
