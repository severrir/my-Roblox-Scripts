-- server script

local TweenService = game:GetService("TweenService")

local IceConfig = require(script:WaitForChild("IceConfig"))

local IcesFolder = workspace:WaitForChild("Ices")
local WarningFolder = IcesFolder:WaitForChild("warning")

local tweeninfoRise = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweeninfoDown = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function flick(warning, duration)
	local elapsed = 0
	while elapsed < duration do
		warning.Transparency = 1
		task.wait(0.3)
		warning.Transparency = 0.1
		task.wait(0.3)
		elapsed += 0.6
	end
	warning.Transparency = 0.4
end

local function runIce(icePart)

	local config = IceConfig[icePart.Name]
	if not config then
		warn("No config for", icePart.Name)
		return
	end

	local riseHeights = config.riseHeights
	local downSize = config.downSize

	local timer = icePart:FindFirstChild("Timer")

	local number = icePart.Name:match("%d+")
	local warning = WarningFolder:FindFirstChild("warning" .. number)

	if not warning then
		warn("Missing warning for", icePart.Name)
		return
	end

	local riseTweens = {}
	for i = 1, 4 do
		riseTweens[i] = TweenService:Create(
			icePart,
			tweeninfoRise,
			{Size = riseHeights[i]}
		)
	end

	local downTween = TweenService:Create(
		icePart,
		tweeninfoDown,
		{Size = downSize}
	)

	while true do

		local randomTime = math.random(5, 20)
		local randomHeight = math.random(1, 4)

		local chosenTween = riseTweens[randomHeight]

		-- Warning preview
		warning.Size = riseHeights[randomHeight]
		warning.Size = downSize

		chosenTween:Play()
		chosenTween.Completed:Wait()

		task.wait(randomTime)

		downTween:Play()

		for i = randomTime, 0, -1 do

			if i == 4 then
				task.delay(1.5, function()
					warning.Size = riseHeights[randomHeight]
					flick(warning, 3)
					warning.Size = downSize
				end)
			end

			if timer then
				timer.Value = i
			end

			task.wait(1)
		end
	end
end

-- Start all ices
for _, ice in ipairs(IcesFolder:GetChildren()) do
	if ice:IsA("BasePart") then
		task.spawn(runIce, ice)
	end
end