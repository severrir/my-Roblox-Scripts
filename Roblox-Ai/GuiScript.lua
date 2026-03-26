-- local guiu script in gui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AskClaude = ReplicatedStorage:WaitForChild("AskClaude")

local textBox = script.Parent:WaitForChild("TextBox")
local textLabel = script.Parent:WaitForChild("TextLabel")

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local message = textBox.Text
		if message ~= "" then
			textLabel.Text = "Thinking..."
			local reply = AskClaude:InvokeServer(message)
			textLabel.Text = reply
			textBox.Text = ""
		end
	end
end)
