local PathfindingService = game:GetService("PathfindingService")

local npc = script.Parent -- Ensure this references your NPC model
local humanoid = npc:WaitForChild("Humanoid") -- Assuming your NPC has a Humanoid

local function computePath(startPosition, finishPosition)
	local path = PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = false,
		Costs = {
			Snow = math.huge,
			Metal = math.huge,
		},
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(startPosition, finishPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		return path
	else
		print(`Path unable to be computed, error: {errorMessage}`)
		return nil
	end
end

local function visualizePath(path)
	for _, waypoint in path:GetWaypoints() do
		local part = Instance.new("Part")
		part.Position = waypoint.Position
		part.Size = Vector3.new(0.5, 0.5, 0.5)
		part.Color = Color3.new(1, 0, 1)
		part.Anchored = true
		part.CanCollide = false
		part.Parent = workspace
	end
end

local function moveToWaypoints(humanoid, waypoints, onComplete)
	local currentWaypointIndex = 1

	local function moveToNextWaypoint()
		if currentWaypointIndex > #waypoints then
			if onComplete then
				onComplete()
			end
			return
		end

		local currentWaypoint = waypoints[currentWaypointIndex]
		humanoid:MoveTo(currentWaypoint.Position)

		humanoid.MoveToFinished:Wait()
		currentWaypointIndex = currentWaypointIndex + 1
		moveToNextWaypoint()
	end

	moveToNextWaypoint()
end

local function main()
	local startPosition = npc.PrimaryPart.Position

	-- Function to handle moving to the next set of waypoints
	local function moveToNextDestination()
		local rnd1 = math.random(-100, 100)
		local rnd2 = math.random(0, 10)
		local rnd3 = math.random(-100, 100)
		local finishPosition = Vector3.new(rnd1, 5, rnd3)

		local path = computePath(startPosition, finishPosition)
		if path then
			visualizePath(path)
			moveToWaypoints(humanoid, path:GetWaypoints(), function()
				startPosition = finishPosition  -- Update startPosition to the last finishPosition
				moveToNextDestination()
			end)
		else
			print("Retrying path computation...")
			moveToNextDestination()
		end
	end

	moveToNextDestination()
end

main()
