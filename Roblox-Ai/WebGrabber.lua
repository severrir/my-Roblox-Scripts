-- server script this should be in serverscriptservice
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AskClaude = ReplicatedStorage:WaitForChild("AskClaude")
local PROXY_URL = "https://my-roblox-scripts.onrender.com/chat"

AskClaude.OnServerInvoke = function(player, message)
	local success, response = pcall(function()
		return HttpService:PostAsync(
			PROXY_URL,
			HttpService:JSONEncode({ message = message }),
			Enum.HttpContentType.ApplicationJson
		)
	end)
	if success then
		local data = HttpService:JSONDecode(response)
		return data.reply
	else
		return "Error contacting AI"
	end
end
