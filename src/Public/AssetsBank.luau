local ContentProvider = game:GetService("ContentProvider")

local Assets = {}
Assets.Loaded = {}

local function LoadAssets(AssetsTable, Callback)
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

function Assets.Preload(AssetID: string, Async: boolean?, Callback: () -> ()): string
	if not Async then
		task.spawn(function()
			LoadAssets({ AssetID }, Callback)
		end)
	else
		LoadAssets({ AssetID }, Callback)
	end
	return AssetID
end

function Assets.BulkPreload(AssetsTable: { string }, Async: boolean?, Callback: () -> ()): { [any]: string }
	if not Async then
		task.spawn(function()
			LoadAssets(AssetsTable, Callback)
		end)
	else
		LoadAssets(AssetsTable, Callback)
	end
	return AssetsTable
end

return Assets
