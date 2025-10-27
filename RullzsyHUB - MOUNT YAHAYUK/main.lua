-------------------------------------------------------------
-- LOAD LIBRARY UI
-------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------------------
-- WINDOW PROCESS
-------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "RullzsyHUB | MOUNT YAHAYUK VIP",
   Icon = "braces",
   LoadingTitle = "Created By RullzsyHUB",
   LoadingSubtitle = "Follow Tiktok: @rullzsy99",
})

-------------------------------------------------------------
-- TAB MENU
-------------------------------------------------------------
local BypassTab = Window:CreateTab("Bypass", "shield")
local AutoWalkTab = Window:CreateTab("Auto Walk", "bot")
local ServerTab = Window:CreateTab("Server Finding", "globe")
local VisualTab = Window:CreateTab("Visual", "layers")
local RunAnimationTab = Window:CreateTab("Run Animation", "person-standing")
local UpdateTab = Window:CreateTab("Update Script", "file")
local CreditsTab = Window:CreateTab("Credits", "scroll-text")

-------------------------------------------------------------
-- SERVICES
-------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-------------------------------------------------------------
-- IMPORT
-------------------------------------------------------------
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local setclipboard = setclipboard or toclipboard
local LocalPlayer = Players.LocalPlayer



-- =============================================================
-- BYPAS AFK
-- =============================================================
getgenv().AntiIdleActive = false
local AntiIdleConnection
local MovementLoop

-- Fungsi untuk mulai bypass AFK
local function StartAntiIdle()
    -- Disconnect lama biar tidak dobel
    if AntiIdleConnection then
        AntiIdleConnection:Disconnect()
        AntiIdleConnection = nil
    end
    if MovementLoop then
        MovementLoop:Disconnect()
        MovementLoop = nil
    end
    AntiIdleConnection = LocalPlayer.Idled:Connect(function()
        if getgenv().AntiIdleActive then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
    MovementLoop = RunService.Heartbeat:Connect(function()
        if getgenv().AntiIdleActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            if tick() % 60 < 0.05 then
                root.CFrame = root.CFrame * CFrame.new(0, 0, 0.1)
                task.wait(0.1)
                root.CFrame = root.CFrame * CFrame.new(0, 0, -0.1)
            end
        end
    end)
end

-- Respawn Validation
local function SetupCharacterListener()
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("HumanoidRootPart", 10)
        if getgenv().AntiIdleActive then
            StartAntiIdle()
        end
    end)
end

StartAntiIdle()
SetupCharacterListener()

-- Section
local Section = BypassTab:CreateSection("List All Bypass")

BypassTab:CreateToggle({
    Name = "Bypass AFK",
    CurrentValue = false,
    Flag = "AntiIdleToggle",
    Callback = function(Value)
        getgenv().AntiIdleActive = Value
        if Value then
            StartAntiIdle()
            Rayfield:Notify({
                Image = "shield",
                Title = "Bypass AFK",
                Content = "Bypass AFK diaktifkan",
                Duration = 5
            })
        else
            if AntiIdleConnection then
                AntiIdleConnection:Disconnect()
                AntiIdleConnection = nil
            end
            if MovementLoop then
                MovementLoop:Disconnect()
                MovementLoop = nil
            end
            Rayfield:Notify({
                Image = "shield",
                Title = "Bypass AFK",
                Content = "Bypass AFK dimatikan",
                Duration = 5
            })
        end
    end,
})
-- =============================================================
-- BYPAS AFK - END
-- =============================================================



-------------------------------------------------------------
-- AUTO WALK
-------------------------------------------------------------
-----| AUTO WALK VARIABLES |-----
-- Setup folder save file json
local mainFolder = "RullzsyHUB"
local jsonFolder = mainFolder .. "/js_mount_yahayuk_vip_patch_new_003"
if not isfolder(mainFolder) then
    makefolder(mainFolder)
end
if not isfolder(jsonFolder) then
    makefolder(jsonFolder)
end

-- Server URL and JSON checkpoint file list
local baseURL = "https://raw.githubusercontent.com/0x0x0x0xblaze/json/refs/heads/main/json_mount_yahayuk_vip/"
local jsonFiles = {
    "spawnpoint.json",
    "checkpoint_1.json",
    "checkpoint_2.json",
    "checkpoint_3.json",
    "checkpoint_4.json",
    "checkpoint_5.json",
}

-- Variables to control auto walk status
local isPlaying = false
local playbackConnection = nil
local autoLoopEnabled = false
local currentCheckpoint = 0

-- PERBAIKAN: Tambahkan monitoring variables
local lastActivityTime = 0
local activityCheckConnection = nil
local ACTIVITY_TIMEOUT = 30 -- 30 detik tanpa activity = restart

--Variables for pause and resume features
local isPaused = false
local manualLoopEnabled = false
local pausedTime = 0
local pauseStartTime = 0

-- FPS Independent Playback Variables
local lastPlaybackTime = 0
local accumulatedTime = 0

-- Looping Variables
local loopingEnabled = false
local isManualMode = false
local manualStartCheckpoint = 0

-- Avatar Size Compensation Variables
local recordedHipHeight = nil
local currentHipHeight = nil
local hipHeightOffset = 0

-- Speed Control Variables
local playbackSpeed = 1.0

-- Footstep Sound Variables
local lastFootstepTime = 0
local footstepInterval = 0.35
local leftFootstep = true

-- Rotate/Flip Variables
local isFlipped = false
local FLIP_SMOOTHNESS = 0.05
local currentFlipRotation = CFrame.new()
-------------------------------------------------------------

-----| AUTO WALK FUNCTIONS |-----
-- Function to convert Vector3 to table
local function vecToTable(v3)
    return {x = v3.X, y = v3.Y, z = v3.Z}
end

-- Function to convert a table to Vector3
local function tableToVec(t)
    return Vector3.new(t.x, t.y, t.z)
end

-- Linear interpolation function for numbers
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Linear interpolation function for Vector3
local function lerpVector(a, b, t)
    return Vector3.new(lerp(a.X, b.X, t), lerp(a.Y, b.Y, t), lerp(a.Z, b.Z, t))
end

-- Linear interpolation function for rotation angle
local function lerpAngle(a, b, t)
    local diff = (b - a)
    while diff > math.pi do diff = diff - 2*math.pi end
    while diff < -math.pi do diff = diff + 2*math.pi end
    return a + diff * t
end

-- Function to calculate HipHeight offset
local function calculateHipHeightOffset()
    if not humanoid then return 0 end
    
    currentHipHeight = humanoid.HipHeight
    
    -- If no recorded hip height, assume standard avatar (2.0)
    if not recordedHipHeight then
        recordedHipHeight = 2.0
    end
    
    -- Calculate offset based on hip height difference
    hipHeightOffset = recordedHipHeight - currentHipHeight
    
    return hipHeightOffset
end

-- Function to adjust position based on avatar size
local function adjustPositionForAvatarSize(position)
    if hipHeightOffset == 0 then return position end
    
    -- Apply vertical offset to compensate for hip height difference
    return Vector3.new(
        position.X,
        position.Y - hipHeightOffset,
        position.Z
    )
end

-- Function to play footstep sounds
local function playFootstepSound()
    if not humanoid or not character then return end
    
    pcall(function()
        -- Get the HumanoidRootPart for raycasting
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Raycast downward to detect floor material
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -5, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if rayResult and rayResult.Instance then
            local material = rayResult.Material
            
            -- Create a sound instance for footstep
            local sound = Instance.new("Sound")
            sound.Volume = 0.8
            sound.RollOffMaxDistance = 100
            sound.RollOffMinDistance = 10
            
            local soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            
            sound.SoundId = soundId
            sound.Parent = hrp
            sound:Play()
            
            -- Cleanup sound after it finishes
            game:GetService("Debris"):AddItem(sound, 1)
        end
    end)
end

-- Function to simulate natural movement for footsteps
local function simulateNaturalMovement(moveDirection, velocity)
    if not humanoid or not character then return end
    
    -- Calculate horizontal movement speed (ignore Y axis)
    local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
    local speed = horizontalVelocity.Magnitude
    
    -- Check if character is on ground
    local onGround = false
    pcall(function()
        local state = humanoid:GetState()
        onGround = (state == Enum.HumanoidStateType.Running or 
                   state == Enum.HumanoidStateType.RunningNoPhysics or 
                   state == Enum.HumanoidStateType.Landed)
    end)
    
    -- Only play footsteps if moving and on ground
    if speed > 0.5 and onGround then
        local currentTime = tick()
        
        -- Adjust footstep interval based on speed and playback speed
        local speedMultiplier = math.clamp(speed / 16, 0.3, 2)
        local adjustedInterval = footstepInterval / (speedMultiplier * playbackSpeed)
        
        if currentTime - lastFootstepTime >= adjustedInterval then
            playFootstepSound()
            lastFootstepTime = currentTime
            leftFootstep = not leftFootstep
        end
    end
end

-- Function to ensure the JSON file is available (download if it does not exist)
local function EnsureJsonFile(fileName)
    local savePath = jsonFolder .. "/" .. fileName
    if isfile(savePath) then return true, savePath end
    local ok, res = pcall(function() return game:HttpGet(baseURL..fileName) end)
    if ok and res and #res > 0 then
        writefile(savePath, res)
        return true, savePath
    end
    return false, nil
end

-- Function to read and decode JSON checkpoint files
local function loadCheckpoint(fileName)
    local filePath = jsonFolder .. "/" .. fileName
    
    if not isfile(filePath) then
        warn("File not found:", filePath)
        return nil
    end
    
    local success, result = pcall(function()
        local jsonData = readfile(filePath)
        if not jsonData or jsonData == "" then
            error("Empty file")
        end
        return HttpService:JSONDecode(jsonData)
    end)
    
    if success and result then
        if result[1] and result[1].hipHeight then
            recordedHipHeight = result[1].hipHeight
        end
        return result
    else
        warn("❌ Load error for", fileName, ":", result)
        return nil
    end
end

-- Binary search for better performance
local function findSurroundingFrames(data, t)
    if #data == 0 then return nil, nil, 0 end
    if t <= data[1].time then return 1, 1, 0 end
    if t >= data[#data].time then return #data, #data, 0 end
    
    local left, right = 1, #data
    while left < right - 1 do
        local mid = math.floor((left + right) / 2)
        if data[mid].time <= t then
            left = mid
        else
            right = mid
        end
    end
    
    local i0, i1 = left, right
    local span = data[i1].time - data[i0].time
    local alpha = span > 0 and math.clamp((t - data[i0].time) / span, 0, 1) or 0
    
    return i0, i1, alpha
end

-- Function to stop auto walk playback
local function stopPlayback()
    isPlaying = false
    isPaused = false
    pausedTime = 0
    accumulatedTime = 0
    lastPlaybackTime = 0
    lastFootstepTime = 0
    recordedHipHeight = nil
    hipHeightOffset = 0
    isFlipped = false
    currentFlipRotation = CFrame.new()
    if playbackConnection then
        playbackConnection:Disconnect()
        playbackConnection = nil
    end
    -- PERBAIKAN: Stop activity monitor
    if activityCheckConnection then
        activityCheckConnection:Disconnect()
        activityCheckConnection = nil
    end
end

-- PERBAIKAN: Fungsi untuk memulai activity monitor
local function startActivityMonitor()
    lastActivityTime = tick()
    
    if activityCheckConnection then
        activityCheckConnection:Disconnect()
    end
    
    activityCheckConnection = RunService.Heartbeat:Connect(function()
        if not autoLoopEnabled or not loopingEnabled then
            if activityCheckConnection then
                activityCheckConnection:Disconnect()
                activityCheckConnection = nil
            end
            return
        end
        
        local currentTime = tick()
        
        if isPlaying then
            lastActivityTime = currentTime
        elseif (currentTime - lastActivityTime) > ACTIVITY_TIMEOUT then
            warn("⚠️ Auto walk stuck detected! Restarting...")
            stopPlayback()
            if isManualMode then
                local restartCheckpoint = math.max(1, currentCheckpoint)
                
                Rayfield:Notify({
                    Title = "Auto Walk Recovery",
                    Content = "Mendeteksi stuck, restart dari checkpoint " .. restartCheckpoint,
                    Duration = 3,
                    Image = "refresh-cw"
                })
                
                task.wait(2)
                startManualAutoWalkSequence(restartCheckpoint)
            end
            
            lastActivityTime = currentTime
        end
    end)
end

-- IMPROVED: FPS-independent playback with avatar size compensation and rotate feature
local function startPlayback(data, onComplete)
    if not data or #data == 0 then
        warn("No data to play!")
        if onComplete then onComplete() end
        return
    end
    
    if isPlaying then stopPlayback() end
    
    isPlaying = true
    isPaused = false
    pausedTime = 0
    accumulatedTime = 0
    local playbackStartTime = tick()
    lastPlaybackTime = playbackStartTime
    local lastJumping = false
    
    calculateHipHeightOffset()
    
    if playbackConnection then
        playbackConnection:Disconnect()
        playbackConnection = nil
    end

    -- Teleport directly to the starting point JSON with size adjustment
    local first = data[1]
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local firstPos = tableToVec(first.position)
        firstPos = adjustPositionForAvatarSize(firstPos)
        local firstYaw = first.rotation or 0
        local startCFrame = CFrame.new(firstPos) * CFrame.Angles(0, firstYaw, 0)
        hrp.CFrame = startCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        if humanoid then
            humanoid:Move(tableToVec(first.moveDirection or {x=0,y=0,z=0}), false)
        end
    end

    -- FPS-INDEPENDENT PLAYBACK LOOP (IMPROVED WITH SAFETY CHECKS)
    playbackConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isPlaying then return end
        
        -- PERBAIKAN: Validate character setiap frame
        if not character or not character.Parent then
            warn("⚠️ Character lost during playback, stopping...")
            stopPlayback()
            if onComplete then onComplete() end
            return
        end
        
        -- Handle pause
        if isPaused then
            if pauseStartTime == 0 then
                pauseStartTime = tick()
            end
            lastPlaybackTime = tick()
            return
        else
            if pauseStartTime > 0 then
                pausedTime = pausedTime + (tick() - pauseStartTime)
                pauseStartTime = 0
                lastPlaybackTime = tick()
            end
        end
        
        if not character:FindFirstChild("HumanoidRootPart") then 
            warn("⚠️ HumanoidRootPart missing, stopping...")
            stopPlayback()
            if onComplete then onComplete() end
            return 
        end
        
        if not humanoid or humanoid.Parent ~= character then
            humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then
                warn("⚠️ Humanoid missing, stopping...")
                stopPlayback()
                if onComplete then onComplete() end
                return
            end
            calculateHipHeightOffset()
        end
        
        local currentTime = tick()
        local actualDelta = currentTime - lastPlaybackTime
        lastPlaybackTime = currentTime
        
        actualDelta = math.min(actualDelta, 0.1)
        
        accumulatedTime = accumulatedTime + (actualDelta * playbackSpeed)
        
        local totalDuration = data[#data].time
        
        -- Check if playback is complete
        if accumulatedTime > totalDuration then
            local final = data[#data]
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local finalPos = tableToVec(final.position)
                finalPos = adjustPositionForAvatarSize(finalPos)
                local finalYaw = final.rotation or 0
                local targetCFrame = CFrame.new(finalPos) * CFrame.Angles(0, finalYaw, 0)
                
                -- Apply flip rotation if enabled
                local targetFlipRotation = isFlipped and CFrame.Angles(0, math.pi, 0) or CFrame.new()
                currentFlipRotation = currentFlipRotation:Lerp(targetFlipRotation, FLIP_SMOOTHNESS)
                
                hrp.CFrame = targetCFrame * currentFlipRotation
                if humanoid then
                    humanoid:Move(tableToVec(final.moveDirection or {x=0,y=0,z=0}), false)
                end
            end
            stopPlayback()
            if onComplete then 
                -- PERBAIKAN: Delay callback sedikit untuk stabilitas
                task.wait(0.1)
                onComplete() 
            end
            return
        end
        
        -- Interpolation with binary search
        local i0, i1, alpha = findSurroundingFrames(data, accumulatedTime)
        local f0, f1 = data[i0], data[i1]
        if not f0 or not f1 then return end
        
        local pos0 = tableToVec(f0.position)
        local pos1 = tableToVec(f1.position)
        local vel0 = tableToVec(f0.velocity or {x=0,y=0,z=0})
        local vel1 = tableToVec(f1.velocity or {x=0,y=0,z=0})
        local move0 = tableToVec(f0.moveDirection or {x=0,y=0,z=0})
        local move1 = tableToVec(f1.moveDirection or {x=0,y=0,z=0})
        local yaw0 = f0.rotation or 0
        local yaw1 = f1.rotation or 0
        
        local interpPos = lerpVector(pos0, pos1, alpha)
        interpPos = adjustPositionForAvatarSize(interpPos)
        
        local interpVel = lerpVector(vel0, vel1, alpha)
        local interpMove = lerpVector(move0, move1, alpha)
        local interpYaw = lerpAngle(yaw0, yaw1, alpha)
        
        local hrp = character.HumanoidRootPart
        local targetCFrame = CFrame.new(interpPos) * CFrame.Angles(0, interpYaw, 0)
        
        -- Apply flip/rotate transformation
        local targetFlipRotation = isFlipped and CFrame.Angles(0, math.pi, 0) or CFrame.new()
        currentFlipRotation = currentFlipRotation:Lerp(targetFlipRotation, FLIP_SMOOTHNESS)
        
        local lerpFactor = math.clamp(1 - math.exp(-10 * actualDelta), 0, 1)
        hrp.CFrame = hrp.CFrame:Lerp(targetCFrame * currentFlipRotation, lerpFactor)
        
        pcall(function()
            hrp.AssemblyLinearVelocity = interpVel
        end)
        
        if humanoid then
            humanoid:Move(interpMove, false)
        end
        
        simulateNaturalMovement(interpMove, interpVel)
        
        -- Handle jumping
        local jumpingNow = f0.jumping or false
        if f1.jumping then jumpingNow = true end
        if jumpingNow and not lastJumping then
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        lastJumping = jumpingNow
    end)
end

-- Function to run the auto walk sequence from start to finish
local function startAutoWalkSequence()
    currentCheckpoint = 0

    local function playNext()
        if not autoLoopEnabled then return end
        
        currentCheckpoint = currentCheckpoint + 1
        if currentCheckpoint > #jsonFiles then
            if loopingEnabled then
                Rayfield:Notify({
                    Title = "Auto Walk",
                    Content = "Semua checkpoint selesai! Looping dari awal...",
                    Duration = 3,
                    Image = "repeat"
                })
                task.wait(1)
                startAutoWalkSequence()
            else
                autoLoopEnabled = false
                Rayfield:Notify({
                    Title = "Auto Walk",
                    Content = "Auto walk selesai! Semua checkpoint sudah dilewati.",
                    Duration = 5,
                    Image = "check-check"
                })
            end
            return
        end

        local checkpointFile = jsonFiles[currentCheckpoint]

        local ok, path = EnsureJsonFile(checkpointFile)
        if not ok then
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to download: ",
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
            return
        end

        local data = loadCheckpoint(checkpointFile)
        if data and #data > 0 then
            Rayfield:Notify({
                Title = "Auto Walk (Automatic)",
                Content = "Auto walk berhasil di jalankan",
                Duration = 2,
                Image = "bot"
            })
            task.wait(0.5)
            startPlayback(data, playNext)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Error loading: " .. checkpointFile,
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
        end
    end

    playNext()
end

-- Function to run manual auto walk with looping (IMPROVED - NO TIMEOUT)
local function startManualAutoWalkSequence(startCheckpoint)
    currentCheckpoint = startCheckpoint - 1
    isManualMode = true
    autoLoopEnabled = true

    local function walkToStartIfNeeded(data)
        -- Validate character existence
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            warn("⚠️ Character not ready, retrying in 2 seconds...")
            task.wait(2)
            -- Retry dengan character baru
            character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                return false
            end
        end

        local hrp = character.HumanoidRootPart
        if not data or not data[1] or not data[1].position then
            return true
        end

        local startPos = tableToVec(data[1].position)
        local distance = (hrp.Position - startPos).Magnitude

        -- PERBAIKAN: Jika terlalu jauh, teleport langsung (untuk looping)
        if distance > 100 then
            if loopingEnabled then
                -- Dalam mode looping, langsung teleport ke posisi start
                hrp.CFrame = CFrame.new(startPos)
                task.wait(0.5)
                return true
            else
                Rayfield:Notify({
                    Title = "Auto Walk (Manual)",
                    Content = string.format("Terlalu jauh (%.0f studs). Maks 100 studs untuk memulai.", distance),
                    Duration = 4,
                    Image = "alert-triangle"
                })
                autoLoopEnabled = false
                isManualMode = false
                return false
            end
        end

        -- Jika dekat (< 100 studs), berjalan normal
        local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
        if not humanoidLocal then
            warn("⚠️ Humanoid not found, teleporting instead...")
            hrp.CFrame = CFrame.new(startPos)
            task.wait(0.5)
            return true
        end

        -- PERBAIKAN: Gunakan coroutine untuk MoveTo dengan auto-recovery
        local reached = false
        local moveConnection
        
        moveConnection = humanoidLocal.MoveToFinished:Connect(function(r)
            reached = true
            if moveConnection then
                moveConnection:Disconnect()
                moveConnection = nil
            end
        end)

        humanoidLocal:MoveTo(startPos)

        -- PERBAIKAN: Timeout dengan auto-teleport recovery
        local startTime = tick()
        local maxWaitTime = 15
        
        while not reached and (tick() - startTime) < maxWaitTime and autoLoopEnabled do
            -- Check if character still exists
            if not character or not character.Parent then
                warn("⚠️ Character removed during walk, waiting for respawn...")
                if moveConnection then
                    moveConnection:Disconnect()
                    moveConnection = nil
                end
                task.wait(3)
                character = player.Character
                return false
            end
            
            task.wait(0.25)
        end

        -- Cleanup connection
        if moveConnection then
            moveConnection:Disconnect()
            moveConnection = nil
        end

        -- PERBAIKAN: Jika timeout dalam looping mode, teleport langsung
        if not reached then
            if loopingEnabled and autoLoopEnabled then
                warn("⚠️ MoveTo timeout, teleporting to start position...")
                pcall(function()
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(startPos)
                    end
                end)
                task.wait(0.5)
                return true
            else
                return false
            end
        end

        return true
    end

    local function playNext()
        -- PERBAIKAN: Tambahkan retry mechanism
        local retryCount = 0
        local maxRetries = 3
        
        while retryCount < maxRetries and autoLoopEnabled do
            if not autoLoopEnabled then return end

            -- Validate character before continuing
            if not character or not character.Parent then
                warn("⚠️ Character missing, waiting for respawn...")
                retryCount = retryCount + 1
                task.wait(3)
                character = player.Character
                if retryCount >= maxRetries then
                    warn("❌ Max retries reached, stopping...")
                    autoLoopEnabled = false
                    isManualMode = false
                    return
                end
                continue
            end

            currentCheckpoint = currentCheckpoint + 1
            if currentCheckpoint > #jsonFiles then
                if loopingEnabled then
                    -- Reset to start checkpoint
                    currentCheckpoint = 0
                    task.wait(0.5)
                    -- Continue looping
                    continue
                else
                    autoLoopEnabled = false
                    isManualMode = false
                    Rayfield:Notify({
                        Title = "Auto Walk (Manual)",
                        Content = "Auto walk selesai!",
                        Duration = 2,
                        Image = "check-check"
                    })
                    return
                end
            end

            local checkpointFile = jsonFiles[currentCheckpoint]
            
            -- PERBAIKAN: Retry download jika gagal
            local ok, path = EnsureJsonFile(checkpointFile)
            if not ok then
                warn("⚠️ Failed to download, retrying...")
                retryCount = retryCount + 1
                task.wait(2)
                continue
            end

            local data = loadCheckpoint(checkpointFile)
            if not data or #data == 0 then
                warn("⚠️ Failed to load checkpoint, retrying...")
                retryCount = retryCount + 1
                task.wait(2)
                continue
            end

            -- PERBAIKAN: Always check distance and teleport if needed
            local okWalk = walkToStartIfNeeded(data)
            if not okWalk then
                if loopingEnabled and autoLoopEnabled then
                    warn("⚠️ Walk failed, retrying...")
                    retryCount = retryCount + 1
                    task.wait(2)
                    continue
                else
                    autoLoopEnabled = false
                    isManualMode = false
                    return
                end
            end

            -- Reset retry count on success
            retryCount = 0
            
            -- Start playback
            startPlayback(data, playNext)
            return
        end

        -- If we get here, max retries exceeded
        if autoLoopEnabled then
            warn("❌ Max retries exceeded, stopping auto walk...")
            autoLoopEnabled = false
            isManualMode = false
            Rayfield:Notify({
                Title = "Auto Walk Error",
                Content = "Auto walk stopped due to repeated errors",
                Duration = 5,
                Image = "ban"
            })
        end
    end

    playNext()
end

-- Function to rotate a single checkpoint (manual)
local function playSingleCheckpointFile(fileName, checkpointIndex)
    if loopingEnabled then
        stopPlayback()
        startManualAutoWalkSequence(checkpointIndex)
        return
    end

    autoLoopEnabled = false
    isManualMode = false
    stopPlayback()

    local ok, path = EnsureJsonFile(fileName)
    if not ok then
        Rayfield:Notify({
            Title = "Error",
            Content = "Failed to ensure JSON checkpoint",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    local data = loadCheckpoint(fileName)
    if not data or #data == 0 then
        Rayfield:Notify({
            Title = "Error",
            Content = "File invalid / kosong",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Rayfield:Notify({
            Title = "Error",
            Content = "HumanoidRootPart tidak ditemukan!",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    local startPos = tableToVec(data[1].position)
    local distance = (hrp.Position - startPos).Magnitude

    if distance > 100 then
        Rayfield:Notify({
            Title = "Auto Walk (Manual)",
            Content = string.format("Terlalu jauh (%.0f studs)! Harus dalam jarak 100.", distance),
            Duration = 4,
            Image = "alert-triangle"
        })
        return
    end

    Rayfield:Notify({
        Title = "Auto Walk (Manual)",
        Content = string.format("Menuju ke titik awal... (%.0f studs)", distance),
        Duration = 3,
        Image = "walk"
    })

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local moving = true
    humanoid:MoveTo(startPos)

    local reachedConnection
    reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
        if reached then
            moving = false
            reachedConnection:Disconnect()

            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Sudah sampai di titik awal, mulai playback...",
                Duration = 2,
                Image = "play"
            })

            task.wait(0.5)
            startPlayback(data, function()
                Rayfield:Notify({
                    Title = "Auto Walk (Manual)",
                    Content = "Auto walk selesai!",
                    Duration = 2,
                    Image = "check-check"
                })
            end)
        else
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Gagal mencapai titik awal!",
                Duration = 3,
                Image = "ban"
            })
            moving = false
            reachedConnection:Disconnect()
        end
    end)

    task.spawn(function()
        local timeout = 20
        local elapsed = 0
        while moving and elapsed < timeout do
            task.wait(1)
            elapsed += 1
        end
        if moving then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Tidak bisa mencapai titik awal (timeout)!",
                Duration = 3,
                Image = "ban"
            })
            humanoid:Move(Vector3.new(0,0,0))
            moving = false
            if reachedConnection then reachedConnection:Disconnect() end
        end
    end)
end

-- Event listener when the player respawns (IMPROVED)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- PERBAIKAN: Jika sedang looping, otomatis resume setelah respawn
    if autoLoopEnabled and loopingEnabled then
        warn("🔄 Character respawned, resuming auto walk in 3 seconds...")
        task.wait(3)
        
        -- Resume from current checkpoint
        if isManualMode then
            -- Continue from where we left off
            local resumeCheckpoint = math.max(1, currentCheckpoint)
            Rayfield:Notify({
                Title = "Auto Walk Resumed",
                Content = "Melanjutkan dari checkpoint " .. resumeCheckpoint,
                Duration = 3,
                Image = "play"
            })
            startManualAutoWalkSequence(resumeCheckpoint)
        end
    elseif isPlaying then
        -- Stop if not in looping mode
        stopPlayback()
    end
end)

-------------------------------------------------------------

-------------------------------------------------------------
-- PAUSE/ROTATE UI (MOBILE FRIENDLY & DRAGGABLE - EMOJI ONLY)
-------------------------------------------------------------
local BTN_COLOR = Color3.fromRGB(38, 38, 38)
local BTN_HOVER = Color3.fromRGB(55, 55, 55)
local TEXT_COLOR = Color3.fromRGB(230, 230, 230)
local WARN_COLOR = Color3.fromRGB(255, 140, 0)
local SUCCESS_COLOR = Color3.fromRGB(0, 170, 85)
local ROTATE_COLOR = Color3.fromRGB(100, 100, 255)

local function createPauseRotateUI()
    local ui = Instance.new("ScreenGui")
    ui.Name = "PauseRotateUI"
    ui.IgnoreGuiInset = true
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ui.Parent = CoreGui

    -- Background container with semi-transparent black background
    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "PR_Background"
    bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFrame.BackgroundTransparency = 0.4
    bgFrame.BorderSizePixel = 0
    bgFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    bgFrame.Position = UDim2.new(0.5, 0, 0.85, 0)
    bgFrame.Size = UDim2.new(0, 130, 0, 70)
    bgFrame.Visible = false
    bgFrame.Parent = ui

    -- Rounded corners for background
    local bgCorner = Instance.new("UICorner", bgFrame)
    bgCorner.CornerRadius = UDim.new(0, 20)

    -- Drag indicator (3 dots at top)
    local dragIndicator = Instance.new("Frame")
    dragIndicator.Name = "DragIndicator"
    dragIndicator.BackgroundTransparency = 1
    dragIndicator.Position = UDim2.new(0.5, 0, 0, 8)
    dragIndicator.Size = UDim2.new(0, 40, 0, 6)
    dragIndicator.AnchorPoint = Vector2.new(0.5, 0)
    dragIndicator.Parent = bgFrame

    local dotLayout = Instance.new("UIListLayout", dragIndicator)
    dotLayout.FillDirection = Enum.FillDirection.Horizontal
    dotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    dotLayout.Padding = UDim.new(0, 6)

    -- Create 3 dots
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. i
        dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        dot.BackgroundTransparency = 0.3
        dot.BorderSizePixel = 0
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Parent = dragIndicator

        local dotCorner = Instance.new("UICorner", dot)
        dotCorner.CornerRadius = UDim.new(1, 0)
    end

    -- Main draggable frame (transparent, sits on top of background)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "PR_Main"
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.6, 0)
    mainFrame.Size = UDim2.new(1, -10, 0, 50)
    mainFrame.Parent = bgFrame

    -- Make it draggable (improved system)
    local dragging = false
    local dragInput, dragStart, startPos
    local UserInputService = game:GetService("UserInputService")

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        bgFrame.Position = newPos
    end

    bgFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = bgFrame.Position

            -- Animate dots when dragging starts
            for i, dot in ipairs(dragIndicator:GetChildren()) do
                if dot:IsA("Frame") then
                    TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0
                    }):Play()
                end
            end

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- Reset dots color when dragging ends
                    for i, dot in ipairs(dragIndicator:GetChildren()) do
                        if dot:IsA("Frame") then
                            TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                                BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                                BackgroundTransparency = 0.3
                            }):Play()
                        end
                    end
                end
            end)
        end
    end)

    bgFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- Reset dots color
                for i, dot in ipairs(dragIndicator:GetChildren()) do
                    if dot:IsA("Frame") then
                        TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                            BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                            BackgroundTransparency = 0.3
                        }):Play()
                    end
                end
            end
        end
    end)

    -- Layout
    local layout = Instance.new("UIListLayout", mainFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)

    -- Helper: create circular button with emoji only
    local function createButton(emoji, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.BackgroundColor3 = BTN_COLOR
        btn.BackgroundTransparency = 0.1
        btn.TextColor3 = TEXT_COLOR
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 24
        btn.Text = emoji
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame

        -- Circular shape
        local c = Instance.new("UICorner", btn)
        c.CornerRadius = UDim.new(1, 0)
        
        -- Hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                BackgroundColor3 = BTN_HOVER,
                Size = UDim2.new(0, 54, 0, 54)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                BackgroundColor3 = color or BTN_COLOR,
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)

        return btn
    end

    local pauseResumeBtn = createButton("⏸️", BTN_COLOR)
    local rotateBtn = createButton("🔄", BTN_COLOR)

    -- State tracking
    local currentlyPaused = false

    -- Animation functions
    local tweenTime = 0.25
    local showScale = 1
    local hideScale = 0

    local function showUI()
        bgFrame.Visible = true
        bgFrame.Size = UDim2.new(0, 130 * hideScale, 0, 70 * hideScale)
        TweenService:Create(bgFrame, TweenInfo.new(tweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 130 * showScale, 0, 70 * showScale)
        }):Play()
    end

    local function hideUI()
        TweenService:Create(bgFrame, TweenInfo.new(tweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 130 * hideScale, 0, 70 * hideScale)
        }):Play()
        task.delay(tweenTime, function()
            bgFrame.Visible = false
        end)
    end

    -- Pause/Resume button logic
    pauseResumeBtn.MouseButton1Click:Connect(function()
        if not isPlaying then
            Rayfield:Notify({
                Title = "Auto Walk",
                Content = "❌ Tidak ada auto walk yang sedang berjalan!",
                Duration = 3,
                Image = "alert-triangle"
            })
            return
        end

        if not currentlyPaused then
            -- Pause the auto walk
            isPaused = true
            currentlyPaused = true
            pauseResumeBtn.Text = "▶️"
            pauseResumeBtn.BackgroundColor3 = SUCCESS_COLOR
            Rayfield:Notify({
                Title = "Auto Walk",
                Content = "⏸️ Auto walk dijeda.",
                Duration = 2,
                Image = "pause"
            })
        else
            -- Resume the auto walk
            isPaused = false
            currentlyPaused = false
            pauseResumeBtn.Text = "⏸️"
            pauseResumeBtn.BackgroundColor3 = BTN_COLOR
            Rayfield:Notify({
                Title = "Auto Walk",
                Content = "▶️ Auto walk dilanjutkan.",
                Duration = 2,
                Image = "play"
            })
        end
    end)

    -- Rotate button logic
    rotateBtn.MouseButton1Click:Connect(function()
        if not isPlaying then
            Rayfield:Notify({
                Title = "Rotate",
                Content = "❌ Auto walk harus berjalan terlebih dahulu!",
                Duration = 3,
                Image = "alert-triangle"
            })
            return
        end

        isFlipped = not isFlipped
        
        if isFlipped then
            rotateBtn.Text = "🔃"
            rotateBtn.BackgroundColor3 = SUCCESS_COLOR
            Rayfield:Notify({
                Title = "Rotate",
                Content = "🔄 Mode rotate AKTIF (jalan mundur)",
                Duration = 2,
                Image = "rotate-cw"
            })
        else
            rotateBtn.Text = "🔄"
            rotateBtn.BackgroundColor3 = BTN_COLOR
            Rayfield:Notify({
                Title = "Rotate",
                Content = "🔄 Mode rotate NONAKTIF",
                Duration = 2,
                Image = "rotate-ccw"
            })
        end
    end)

    -- Reset UI state when auto walk stops
    local function resetUIState()
        currentlyPaused = false
        pauseResumeBtn.Text = "⏸️"
        pauseResumeBtn.BackgroundColor3 = BTN_COLOR
        isFlipped = false
        rotateBtn.Text = "🔄"
        rotateBtn.BackgroundColor3 = BTN_COLOR
    end

    return {
        mainFrame = bgFrame,
        showUI = showUI,
        hideUI = hideUI,
        resetUIState = resetUIState
    }
end

-- Create UI instance
local pauseRotateUI = createPauseRotateUI()

-- Override stopPlayback to reset UI state
local originalStopPlayback = stopPlayback
stopPlayback = function()
    originalStopPlayback()
    pauseRotateUI.resetUIState()
end

-------------------------------------------------------------
-- TOGGLE
-------------------------------------------------------------
local WalkSpeedEnabled = false
local WalkSpeedValue = 16

-- Function to apply walk speed
local function ApplyWalkSpeed(Humanoid)
    if WalkSpeedEnabled then
        Humanoid.WalkSpeed = WalkSpeedValue
    else
        Humanoid.WalkSpeed = 16
    end
end

-- Function to set up on respawn
local function SetupCharacter(Char)
    local Humanoid = Char:WaitForChild("Humanoid")
    ApplyWalkSpeed(Humanoid)
end

-- Connect when player respawns
LocalPlayer.CharacterAdded:Connect(function(Char)
    task.wait(1)
    SetupCharacter(Char)
end)

-- Initial setup for current character
if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

-- Section
local Section = AutoWalkTab:CreateSection("Walk Speed Menu")

-- // UI Toggles
AutoWalkTab:CreateToggle({
    Name = "Enable Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        WalkSpeedEnabled = Value
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            ApplyWalkSpeed(Char.Humanoid)
        end
    end,
})

AutoWalkTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 26},
    Increment = 1,
    Suffix = "x Speed",
    CurrentValue = 20,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        WalkSpeedValue = Value
        local Char = LocalPlayer.f
        if Char and Char:FindFirstChild("Humanoid") and WalkSpeedEnabled then
            Char.Humanoid.WalkSpeed = WalkSpeedValue
        end
    end,
})

-- Section
local Section = AutoWalkTab:CreateSection("Auto Walk (Settings)")

local Toggle = AutoWalkTab:CreateToggle({
    Name = "Pause/Rotate Menu",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            pauseRotateUI.showUI()
        else
            pauseRotateUI.hideUI()
        end
    end,
})

-- Slider Speed Auto
local SpeedSlider = AutoWalkTab:CreateSlider({
    Name = "⚡ Set Speed",
    Range = {0.5, 1.2},
    Increment = 0.10,
    Suffix = "x Speed",
    CurrentValue = 1.0,
    Callback = function(Value)
        playbackSpeed = Value

        local speedText = "Normal"
        if Value < 1.0 then
            speedText = "Lambat (" .. string.format("%.1f", Value) .. "x)"
        elseif Value > 1.0 then
            speedText = "Cepat (" .. string.format("%.1f", Value) .. "x)"
        else
            speedText = "Normal (" .. Value .. "x)"
        end
    end,
})
-------------------------------------------------------------

-----| MENU 1.5 > AUTO WALK LOOPING |-----
local Section = AutoWalkTab:CreateSection("Auto Walk (Looping)")

local LoopingToggle = AutoWalkTab:CreateToggle({
   Name = "🔄 Enable Looping",
   CurrentValue = false,
   Callback = function(Value)
       loopingEnabled = Value
       if Value then
           Rayfield:Notify({
               Title = "Looping",
               Content = "Fitur looping diaktifkan!",
               Duration = 3,
               Image = "repeat"
           })
       else
           Rayfield:Notify({
               Title = "Looping",
               Content = "Fitur looping dinonaktifkan!",
               Duration = 3,
               Image = "x"
           })
       end
   end,
})

-------------------------------------------------------------

-----| MENU 3 > AUTO WALK (MANUAL) |-----
local Section = AutoWalkTab:CreateSection("Auto Walk (Manual)")

-- Toggle Auto Walk (Spawnpoint)
local SCPToggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Spawnpoint)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("spawnpoint.json", 1)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 1)
local CP1Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 1)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_1.json", 2)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 2)
local CP2Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 2)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_2.json", 3)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 3)
local CP3Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 3)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_3.json", 4)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 4)
local CP4Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 4)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_4.json", 5)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 5)
local CP5Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 5)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_5.json", 6)
            -- PERBAIKAN: Start monitor jika looping aktif
            if loopingEnabled then
                startActivityMonitor()
            end
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})
-------------------------------------------------------------
-- AUTO WALK - END
-------------------------------------------------------------



-------------------------------------------------------------
-- SERVER FINDING
-------------------------------------------------------------
local ServerSection = ServerTab:CreateSection("Server Menu")

-- Varibale Server
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId
local Servers = {}

local function FetchServers()
    local Cursor = ""
    Servers = {}

    repeat
        local URL = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s", PlaceId, Cursor ~= "" and "&cursor="..Cursor or "")
        local Response = game:HttpGet(URL)
        local Data = HttpService:JSONDecode(Response)

        for _, server in pairs(Data.data) do
            table.insert(Servers, server)
        end

        Cursor = Data.nextPageCursor
        task.wait(0.5)
    until not Cursor

    return Servers
end

-- Function Join Server
local function CreateServerButtons()
    ServerTab:CreateParagraph({Title = "🔍 Mencari Server...", Content = "Tunggu sebentar sedang mencari data server..."})
    local allServers = FetchServers()
    ServerTab:CreateSection(" ")

    for _, server in pairs(allServers) do
        local playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
        local isSafe = server.playing <= (server.maxPlayers / 2)

        local emoji = isSafe and "🟢" or "🟥"
        local safety = isSafe and "Safe" or "No Safe"

        local name = string.format("%s Server [%s] - %s", emoji, playerCount, safety)

        ServerTab:CreateButton({
            Name = name,
            Callback = function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, server.id)
            end,
        })
    end

    ServerTab:CreateParagraph({Title = "✅ Selesai!", Content = "Pilih salah satu server sepi di atas untuk join."})
end

-- Toggle Start Find Server
ServerTab:CreateButton({
    Name = "🔄 START FIND SERVER",
    Callback = function()
        CreateServerButtons()
    end,
})

local Divider = ServerTab:CreateDivider()
-------------------------------------------------------------
-- SERVER FINDING - END
-------------------------------------------------------------



-- =============================================================
-- VISUAL
-- =============================================================
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Full Bright
local LightSection = VisualTab:CreateSection("Lightning Menu")

local FullBrightToggle = VisualTab:CreateToggle({
    Name = "💡 Full Bright",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end,
})

-- Hide Nametag
local PlayerSection = VisualTab:CreateSection("Player Menu")

local HideNametagToggle = VisualTab:CreateToggle({
    Name = "🏷️ Hide Player Nametags",
    CurrentValue = false,
    Callback = function(Value)
        local function hideNametagsForCharacter(character)
            if not character then return end
            local head = character:FindFirstChild("Head")
            if not head then return end
            for _, obj in pairs(head:GetChildren()) do
                if obj:IsA("BillboardGui") then
                    obj.Enabled = false
                end
            end
        end

        local function showNametagsForCharacter(character)
            if not character then return end
            local head = character:FindFirstChild("Head")
            if not head then return end
            for _, obj in pairs(head:GetChildren()) do
                if obj:IsA("BillboardGui") then
                    obj.Enabled = true
                end
            end
        end

        local function setNametagsVisible(state)
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    if state then
                        showNametagsForCharacter(player.Character)
                    else
                        hideNametagsForCharacter(player.Character)
                    end
                end
            end
        end

        if Value then
            -- Sembunyikan semua yang ada sekarang
            setNametagsVisible(false)

            -- Listener untuk pemain baru & respawn
            nametagConnections = {}

            local function connectPlayer(player)
                local charAddedConn
                charAddedConn = player.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    hideNametagsForCharacter(char)
                end)
                table.insert(nametagConnections, charAddedConn)
            end

            for _, player in pairs(Players:GetPlayers()) do
                connectPlayer(player)
            end

            table.insert(nametagConnections, Players.PlayerAdded:Connect(connectPlayer))

        else
            -- Tampilkan semua nametag
            setNametagsVisible(true)

            -- Bersihkan koneksi event
            if nametagConnections then
                for _, conn in pairs(nametagConnections) do
                    if conn.Connected then conn:Disconnect() end
                end
            end
            nametagConnections = nil
        end
    end,
})

-- Hide Player
local HidePlayerToggle = VisualTab:CreateToggle({
    Name = "🧍 Hide Other Players",
    CurrentValue = false,
    Callback = function(Value)
        local function setPlayerVisible(player, visible)
            if not player.Character then return end
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = visible and 0 or 1
                end
            end
        end

        local function setAllPlayersVisible(visible)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    setPlayerVisible(player, visible)
                end
            end
        end

        if Value then
            -- Sembunyikan semua player yang ada sekarang
            setAllPlayersVisible(false)

            hidePlayerConnections = {}

            local function connectPlayer(player)
                -- Saat karakter player baru muncul, langsung sembunyikan lagi
                local charAddedConn
                charAddedConn = player.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    setPlayerVisible(player, false)
                end)
                table.insert(hidePlayerConnections, charAddedConn)
            end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    connectPlayer(player)
                end
            end

            table.insert(hidePlayerConnections, Players.PlayerAdded:Connect(function(player)
                connectPlayer(player)
            end))

        else
            -- Tampilkan semua kembali
            setAllPlayersVisible(true)

            -- Bersihkan koneksi listener
            if hidePlayerConnections then
                for _, conn in pairs(hidePlayerConnections) do
                    if conn.Connected then conn:Disconnect() end
                end
            end
            hidePlayerConnections = nil
        end
    end,
})

-- =============================================================
-- VISUAL - END
-- =============================================================



-------------------------------------------------------------
-- RUN ANIMATION
-------------------------------------------------------------
local Section = RunAnimationTab:CreateSection("Animation Pack List")

-----| ID ANIMATION |-----
local RunAnimations = {
    ["Run Animation 1"] = {
        Idle1   = "rbxassetid://122257458498464",
        Idle2   = "rbxassetid://102357151005774",
        Walk    = "http://www.roblox.com/asset/?id=18537392113",
        Run     = "rbxassetid://82598234841035",
        Jump    = "rbxassetid://75290611992385",
        Fall    = "http://www.roblox.com/asset/?id=11600206437",
        Climb   = "http://www.roblox.com/asset/?id=10921257536",
        Swim    = "http://www.roblox.com/asset/?id=10921264784",
        SwimIdle= "http://www.roblox.com/asset/?id=10921265698"
    },
    ["Run Animation 2"] = {
        Idle1   = "rbxassetid://122257458498464",
        Idle2   = "rbxassetid://102357151005774",
        Walk    = "rbxassetid://122150855457006",
        Run     = "rbxassetid://82598234841035",
        Jump    = "rbxassetid://75290611992385",
        Fall    = "rbxassetid://98600215928904",
        Climb   = "rbxassetid://88763136693023",
        Swim    = "rbxassetid://133308483266208",
        SwimIdle= "rbxassetid://109346520324160"
    },
    ["Run Animation 3"] = {
        Idle1   = "http://www.roblox.com/asset/?id=18537376492",
        Idle2   = "http://www.roblox.com/asset/?id=18537371272",
        Walk    = "http://www.roblox.com/asset/?id=18537392113",
        Run     = "http://www.roblox.com/asset/?id=18537384940",
        Jump    = "http://www.roblox.com/asset/?id=18537380791",
        Fall    = "http://www.roblox.com/asset/?id=18537367238",
        Climb   = "http://www.roblox.com/asset/?id=10921271391",
        Swim    = "http://www.roblox.com/asset/?id=99384245425157",
        SwimIdle= "http://www.roblox.com/asset/?id=113199415118199"
    },
    ["Run Animation 4"] = {
        Idle1   = "http://www.roblox.com/asset/?id=118832222982049",
        Idle2   = "http://www.roblox.com/asset/?id=76049494037641",
        Walk    = "http://www.roblox.com/asset/?id=92072849924640",
        Run     = "http://www.roblox.com/asset/?id=72301599441680",
        Jump    = "http://www.roblox.com/asset/?id=104325245285198",
        Fall    = "http://www.roblox.com/asset/?id=121152442762481",
        Climb   = "http://www.roblox.com/asset/?id=507765644",
        Swim    = "http://www.roblox.com/asset/?id=99384245425157",
        SwimIdle= "http://www.roblox.com/asset/?id=113199415118199"
    },
    ["Run Animation 5"] = {
        Idle1   = "http://www.roblox.com/asset/?id=656117400",
        Idle2   = "http://www.roblox.com/asset/?id=656118341",
        Walk    = "http://www.roblox.com/asset/?id=656121766",
        Run     = "http://www.roblox.com/asset/?id=656118852",
        Jump    = "http://www.roblox.com/asset/?id=656117878",
        Fall    = "http://www.roblox.com/asset/?id=656115606",
        Climb   = "http://www.roblox.com/asset/?id=656114359",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 6"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616006778",
        Idle2   = "http://www.roblox.com/asset/?id=616008087",
        Walk    = "http://www.roblox.com/asset/?id=616013216",
        Run     = "http://www.roblox.com/asset/?id=616010382",
        Jump    = "http://www.roblox.com/asset/?id=616008936",
        Fall    = "http://www.roblox.com/asset/?id=616005863",
        Climb   = "http://www.roblox.com/asset/?id=616003713",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 7"] = {
        Idle1   = "http://www.roblox.com/asset/?id=1083195517",
        Idle2   = "http://www.roblox.com/asset/?id=1083214717",
        Walk    = "http://www.roblox.com/asset/?id=1083178339",
        Run     = "http://www.roblox.com/asset/?id=1083216690",
        Jump    = "http://www.roblox.com/asset/?id=1083218792",
        Fall    = "http://www.roblox.com/asset/?id=1083189019",
        Climb   = "http://www.roblox.com/asset/?id=1083182000",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 8"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616136790",
        Idle2   = "http://www.roblox.com/asset/?id=616138447",
        Walk    = "http://www.roblox.com/asset/?id=616146177",
        Run     = "http://www.roblox.com/asset/?id=616140816",
        Jump    = "http://www.roblox.com/asset/?id=616139451",
        Fall    = "http://www.roblox.com/asset/?id=616134815",
        Climb   = "http://www.roblox.com/asset/?id=616133594",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 9"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616088211",
        Idle2   = "http://www.roblox.com/asset/?id=616089559",
        Walk    = "http://www.roblox.com/asset/?id=616095330",
        Run     = "http://www.roblox.com/asset/?id=616091570",
        Jump    = "http://www.roblox.com/asset/?id=616090535",
        Fall    = "http://www.roblox.com/asset/?id=616087089",
        Climb   = "http://www.roblox.com/asset/?id=616086039",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 10"] = {
        Idle1   = "http://www.roblox.com/asset/?id=910004836",
        Idle2   = "http://www.roblox.com/asset/?id=910009958",
        Walk    = "http://www.roblox.com/asset/?id=910034870",
        Run     = "http://www.roblox.com/asset/?id=910025107",
        Jump    = "http://www.roblox.com/asset/?id=910016857",
        Fall    = "http://www.roblox.com/asset/?id=910001910",
        Climb   = "http://www.roblox.com/asset/?id=616086039",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 11"] = {
        Idle1   = "http://www.roblox.com/asset/?id=742637544",
        Idle2   = "http://www.roblox.com/asset/?id=742638445",
        Walk    = "http://www.roblox.com/asset/?id=742640026",
        Run     = "http://www.roblox.com/asset/?id=742638842",
        Jump    = "http://www.roblox.com/asset/?id=742637942",
        Fall    = "http://www.roblox.com/asset/?id=742637151",
        Climb   = "http://www.roblox.com/asset/?id=742636889",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 12"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616111295",
        Idle2   = "http://www.roblox.com/asset/?id=616113536",
        Walk    = "http://www.roblox.com/asset/?id=616122287",
        Run     = "http://www.roblox.com/asset/?id=616117076",
        Jump    = "http://www.roblox.com/asset/?id=616115533",
        Fall    = "http://www.roblox.com/asset/?id=616108001",
        Climb   = "http://www.roblox.com/asset/?id=616104706",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 13"] = {
        Idle1   = "http://www.roblox.com/asset/?id=657595757",
        Idle2   = "http://www.roblox.com/asset/?id=657568135",
        Walk    = "http://www.roblox.com/asset/?id=657552124",
        Run     = "http://www.roblox.com/asset/?id=657564596",
        Jump    = "http://www.roblox.com/asset/?id=658409194",
        Fall    = "http://www.roblox.com/asset/?id=657600338",
        Climb   = "http://www.roblox.com/asset/?id=658360781",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 14"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616158929",
        Idle2   = "http://www.roblox.com/asset/?id=616160636",
        Walk    = "http://www.roblox.com/asset/?id=616168032",
        Run     = "http://www.roblox.com/asset/?id=616163682",
        Jump    = "http://www.roblox.com/asset/?id=616161997",
        Fall    = "http://www.roblox.com/asset/?id=616157476",
        Climb   = "http://www.roblox.com/asset/?id=616156119",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 15"] = {
        Idle1   = "http://www.roblox.com/asset/?id=845397899",
        Idle2   = "http://www.roblox.com/asset/?id=845400520",
        Walk    = "http://www.roblox.com/asset/?id=845403856",
        Run     = "http://www.roblox.com/asset/?id=845386501",
        Jump    = "http://www.roblox.com/asset/?id=845398858",
        Fall    = "http://www.roblox.com/asset/?id=845396048",
        Climb   = "http://www.roblox.com/asset/?id=845392038",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 16"] = {
        Idle1   = "http://www.roblox.com/asset/?id=782841498",
        Idle2   = "http://www.roblox.com/asset/?id=782845736",
        Walk    = "http://www.roblox.com/asset/?id=782843345",
        Run     = "http://www.roblox.com/asset/?id=782842708",
        Jump    = "http://www.roblox.com/asset/?id=782847020",
        Fall    = "http://www.roblox.com/asset/?id=782846423",
        Climb   = "http://www.roblox.com/asset/?id=782843869",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
    ["Run Animation 17"] = {
        Idle1   = "http://www.roblox.com/asset/?id=891621366",
        Idle2   = "http://www.roblox.com/asset/?id=891633237",
        Walk    = "http://www.roblox.com/asset/?id=891667138",
        Run     = "http://www.roblox.com/asset/?id=891636393",
        Jump    = "http://www.roblox.com/asset/?id=891627522",
        Fall    = "http://www.roblox.com/asset/?id=891617961",
        Climb   = "http://www.roblox.com/asset/?id=891609353",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
    ["Run Animation 18"] = {
        Idle1   = "http://www.roblox.com/asset/?id=750781874",
        Idle2   = "http://www.roblox.com/asset/?id=750782770",
        Walk    = "http://www.roblox.com/asset/?id=750785693",
        Run     = "http://www.roblox.com/asset/?id=750783738",
        Jump    = "http://www.roblox.com/asset/?id=750782230",
        Fall    = "http://www.roblox.com/asset/?id=750780242",
        Climb   = "http://www.roblox.com/asset/?id=750779899",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
}

-------------------------------------------------------------
-----| FUNCTION RUN ANIMATION |-----
local OriginalAnimations = {}
local CurrentPack = nil

local function SaveOriginalAnimations(Animate)
    OriginalAnimations = {}
    for _, child in ipairs(Animate:GetDescendants()) do
        if child:IsA("Animation") then
            OriginalAnimations[child] = child.AnimationId
        end
    end
end

local function ApplyAnimations(Animate, Humanoid, AnimPack)
    Animate.idle.Animation1.AnimationId = AnimPack.Idle1
    Animate.idle.Animation2.AnimationId = AnimPack.Idle2
    Animate.walk.WalkAnim.AnimationId   = AnimPack.Walk
    Animate.run.RunAnim.AnimationId     = AnimPack.Run
    Animate.jump.JumpAnim.AnimationId   = AnimPack.Jump
    Animate.fall.FallAnim.AnimationId   = AnimPack.Fall
    Animate.climb.ClimbAnim.AnimationId = AnimPack.Climb
    Animate.swim.Swim.AnimationId       = AnimPack.Swim
    Animate.swimidle.SwimIdle.AnimationId = AnimPack.SwimIdle
    Humanoid.Jump = true
end

local function RestoreOriginal()
    for anim, id in pairs(OriginalAnimations) do
        if anim and anim:IsA("Animation") then
            anim.AnimationId = id
        end
    end
end

local function SetupCharacter(Char)
    local Animate = Char:WaitForChild("Animate")
    local Humanoid = Char:WaitForChild("Humanoid")
    SaveOriginalAnimations(Animate)
    if CurrentPack then
        ApplyAnimations(Animate, Humanoid, CurrentPack)
    end
end

Players.LocalPlayer.CharacterAdded:Connect(function(Char)
    task.wait(1)
    SetupCharacter(Char)
end)

if Players.LocalPlayer.Character then
    SetupCharacter(Players.LocalPlayer.Character)
end

-------------------------------------------------------------
-----| TOGGLES RUN ANIMATION |-----
for i = 1, 18 do
    local name = "Run Animation " .. i
    local pack = RunAnimations[name]

    RunAnimationTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = name .. "Toggle",
        Callback = function(Value)
            if Value then
                CurrentPack = pack
            elseif CurrentPack == pack then
                CurrentPack = nil
                RestoreOriginal()
            end

            local Char = Players.LocalPlayer.Character
            if Char and Char:FindFirstChild("Animate") and Char:FindFirstChild("Humanoid") then
                if CurrentPack then
                    ApplyAnimations(Char.Animate, Char.Humanoid, CurrentPack)
                else
                    RestoreOriginal()
                end
            end
        end,
    })
end
-------------------------------------------------------------
-- RUN ANIMATION - END
-------------------------------------------------------------



-------------------------------------------------------------
-- UPDATE SCRIPT
-------------------------------------------------------------
-----| UPDATE SCRIPT VARIABLES |-----
-- Variables to control the update process
local updateEnabled = false
local stopUpdate = {false}

-------------------------------------------------------------

-----| MENU 1 > UPDATE SCRIPT STATUS |-----
-- Label to display the status of checking JSON files
local Section = UpdateTab:CreateSection("Update Script Menu")

local Label = UpdateTab:CreateLabel("Pengecekan file...")

-- Task for checking JSON files during startup
task.spawn(function()
    for i, f in ipairs(jsonFiles) do
        local ok = EnsureJsonFile(f)
        Label:Set((ok and "✔ Proses Cek File: " or "❌ Gagal: ").." ("..i.."/"..#jsonFiles..")")
        task.wait(0.5)
    end
    Label:Set("✔ Semua file aman")
end)

-------------------------------------------------------------

-----| MENU 2 > UPDATE SCRIPT TOGGLE |-----
-- Toggle to start the script update process (redownload all JSON)
UpdateTab:CreateToggle({
    Name = "Mulai Update Script",
    CurrentValue = false,
    Callback = function(state)
        if state then
            updateEnabled = true
            stopUpdate[1] = false
            task.spawn(function()
                Label:Set("🔄 Proses update file...")
                
                -- Delete all existing JSON files
                for _, f in ipairs(jsonFiles) do
                    local savePath = jsonFolder .. "/" .. f
                    if isfile(savePath) then
                        delfile(savePath)
                    end
                end
                
                -- Re-download all JSON files
                for i, f in ipairs(jsonFiles) do
                    if stopUpdate[1] then break end
                    
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "Proses Update " .. " ("..i.."/"..#jsonFiles..")",
                        Duration = 2,
                        Image = "file",
                    })
                    
                    local ok, res = pcall(function() return game:HttpGet(baseURL..f) end)
                    if ok and res and #res > 0 then
                        writefile(jsonFolder.."/"..f, res)
                        Label:Set("📥 Proses Update: ".. " ("..i.."/"..#jsonFiles..")")
                    else
                        Rayfield:Notify({
                            Title = "Update Script",
                            Content = "❌ Update script gagal",
                            Duration = 3,
                            Image = "file",
                        })
                        Label:Set("❌ Gagal: ".. " ("..i.."/"..#jsonFiles..")")
                    end
                    task.wait(0.3)
                end
                
                -- Update result notification
                if not stopUpdate[1] then
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "Telah berhasil!",
                        Duration = 5,
                        Image = "check-check",
                    })
                else
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "❌ Update canceled",
                        Duration = 3,
                        Image = 4483362458,
                    })
                end
				
                -- Re-check all files after updating
                for i, f in ipairs(jsonFiles) do
                    local ok = EnsureJsonFile(f)
                    Label:Set((ok and "✔ Cek File: " or "❌ Failed: ").." ("..i.."/"..#jsonFiles..")")
                    task.wait(0.3)
                end
                Label:Set("✔ Semua file aman")
            end)
        else
            updateEnabled = false
            stopUpdate[1] = true
        end
    end,
})
-------------------------------------------------------------
-- UPDATE SCRIPT - END
-------------------------------------------------------------



-------------------------------------------------------------
-- CREDITS
-------------------------------------------------------------
local Section = CreditsTab:CreateSection("Credits List")

-- Credits: 1
CreditsTab:CreateLabel("UI: Rayfield Interface")
-- Credits: 2
CreditsTab:CreateLabel("Dev: RullzsyHUB")
-------------------------------------------------------------
-- CREDITS - END

-------------------------------------------------------------