local module = {}

local HttpService = game:GetService("HttpService")

-- ? Renseigne ici ton URL de webhook de test
local WEBHOOK_URL = "https://n8n.srv798490.hstgr.cloud/webhook-test/roblox-folder-structure"

-- Ordre des services comme dans l'Explorer de Roblox
local OrderedServices = {
	"Workspace",
	"Players",
	"Lighting",
	"MaterialService",
	"NetworkClient",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Teams",
	"SoundService",
	"TextChatService",
}

-- ?? Scan uniquement les Folder
local function serializeFoldersOnly(instance)
	local result = {}

	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("Folder") then
			result[child.Name] = serializeFoldersOnly(child)
		end
	end

	return result
end

function module.Export()
	local fullStructure = {}

	for _, serviceName in ipairs(OrderedServices) do
		local success, service = pcall(function()
			return game:GetService(serviceName)
		end)

		if success and service then
			fullStructure[serviceName] = serializeFoldersOnly(service)
		end
	end

	return fullStructure

	--[[local payload = {
		project = "MyRobloxProject",
		timestamp = os.time(),
		folderStructure = fullStructure
	}

	local jsonPayload = HttpService:JSONEncode(payload)

	local success, response = pcall(function()
		return HttpService:PostAsync(WEBHOOK_URL, jsonPayload, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		print("? Folder-only structure sent!")
	else
		warn("? Failed to send folder structure:", response)
	end]]
end


return module