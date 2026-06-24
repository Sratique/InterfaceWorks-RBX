local ContentProvider = game:GetService("ContentProvider")

local Assets = {}
Assets.Loaded = {}
Assets.Colors = {
	Background = Color3.new(0, 0, 0),
	Secondary = Color3.new(0.180392, 0.180392, 0.180392),
	Foreground = Color3.new(0.313725, 0.313725, 0.313725),
	Element = Color3.new(0.419608, 0.419608, 0.419608),
	Eyecatcher = Color3.new(1, 0.360784, 0.360784),
	Text = Color3.new(1, 1, 1),
}

local function LoadAssets(AssetsTable, Callback: () -> ()?)
	for _, v in pairs(AssetsTable) do
		if Assets.Loaded[v] then
			continue
		end

		ContentProvider:PreloadAsync({ v })
		Assets.Loaded[v] = true
	end
	if Callback then
		Callback()
	end
end

function Assets.Preload(AssetID: string, Async: boolean?, Callback: () -> ()?): string
	if not Async then
		task.spawn(function()
			LoadAssets({ AssetID }, Callback)
		end)
	else
		LoadAssets({ AssetID }, Callback)
	end
	return AssetID
end

function Assets.BulkPreload(AssetsTable: { string }, Async: boolean?, Callback: () -> ()?): { [any]: string }
	if not Async then
		task.spawn(function()
			LoadAssets(AssetsTable, Callback)
		end)
	else
		LoadAssets(AssetsTable, Callback)
	end
	return AssetsTable
end

function Assets.SetColorScheme(
	Background: Color3,
	Secondary: Color3,
	Foreground: Color3,
	Element: Color3,
	Eyecatcher: Color3,
	Text: Color3
)
	Assets.Colors.Background = Background or Assets.Colors.Background
	Assets.Colors.Secondary = Secondary or Assets.Colors.Secondary
	Assets.Colors.Foreground = Foreground or Assets.Colors.Foreground
	Assets.Colors.Element = Element or Assets.Colors.Element
	Assets.Colors.Eyecatcher = Eyecatcher or Assets.Colors.Eyecatcher
	Assets.Colors.Text = Text or Assets.Colors.Text
end

return Assets
